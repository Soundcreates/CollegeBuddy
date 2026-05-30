package handlers

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"strings"
	"time"

	"somaiya-ext/internal/models"
	"somaiya-ext/service"
)

// HandleSync serves GET /api/sync?since=<RFC3339 timestamp>
//
// Delta sync logic:
//   - If `since` is absent or zero, returns ALL records (first-time sync).
//   - Otherwise, returns only records created/updated after `since`.
//
// Response shape:
//
//	{
//	  "deadlines":     [ ...assignments... ],
//	  "announcements": [ ...mails...       ],
//	  "courses":       [ ...courses...     ],
//	  "server_time":   "2026-05-30T12:00:00Z"
//	}
func (h *Handler) HandleSync(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	log.Println("[SYNC] HandleSync called")

	// ── Parse JWT / identify user ──────────────────────────────────────────
	token := strings.TrimPrefix(r.Header.Get("Authorization"), "Bearer ")
	profile, err := h.BackendProfile(token)
	if err != nil {
		log.Printf("[SYNC] Failed to fetch profile: %v", err)
		http.Error(w, "unauthorized", http.StatusUnauthorized)
		return
	}
	studentData, ok := profile["user"].(map[string]interface{})
	if !ok {
		http.Error(w, "invalid user data", http.StatusInternalServerError)
		return
	}
	email, _ := studentData["email"].(string)

	// ── Parse `since` timestamp ────────────────────────────────────────────
	var since time.Time
	if sinceStr := r.URL.Query().Get("since"); sinceStr != "" {
		since, err = time.Parse(time.RFC3339Nano, sinceStr)
		if err != nil {
			http.Error(w, "invalid since timestamp; use RFC3339", http.StatusBadRequest)
			return
		}
	}
	isFullSync := since.IsZero()
	log.Printf("[SYNC] User: %s | since: %v | fullSync: %v", email, since, isFullSync)

	serverTime := time.Now().UTC()

	// ── Fetch announcements (mails) ────────────────────────────────────────
	announcements, err := h.fetchMailsDelta(email, since, isFullSync)
	if err != nil {
		log.Printf("[SYNC] Failed to fetch mails delta: %v", err)
		// Partial failure: return empty slice rather than aborting.
		announcements = []map[string]interface{}{}
	}

	// ── Fetch deadlines (assignments) ──────────────────────────────────────
	deadlines, err := h.fetchAssignmentsDelta(r, token, email, since, isFullSync)
	if err != nil {
		log.Printf("[SYNC] Failed to fetch assignments delta: %v", err)
		deadlines = []map[string]interface{}{}
	}

	// ── Fetch courses ──────────────────────────────────────────────────────
	courses, err := h.fetchCoursesDelta(email, since, isFullSync)
	if err != nil {
		log.Printf("[SYNC] Failed to fetch courses delta: %v", err)
		courses = []map[string]interface{}{}
	}

	log.Printf("[SYNC] Returning %d deadlines, %d announcements, %d courses",
		len(deadlines), len(announcements), len(courses))

	json.NewEncoder(w).Encode(models.SyncResponse{
		Deadlines:     deadlines,
		Announcements: announcements,
		Courses:       courses,
		ServerTime:    serverTime,
	})
}

// ── Mail delta ────────────────────────────────────────────────────────────────

func (h *Handler) fetchMailsDelta(
	email string,
	since time.Time,
	isFullSync bool,
) ([]map[string]interface{}, error) {
	var messages []models.GmailMessage

	query := h.DB.Where("student = ?", email)
	if !isFullSync {
		// Filter by created_at once the column exists (added via AutoMigrate).
		query = query.Where("created_at > ?", since)
	}

	if err := query.Find(&messages).Error; err != nil {
		return nil, fmt.Errorf("mail query failed: %w", err)
	}

	result := make([]map[string]interface{}, 0, len(messages))
	for _, m := range messages {
		result = append(result, map[string]interface{}{
			"id":               m.ID,
			"thread_id":        m.ThreadID,
			"subject":          m.Subject,
			"from":             m.From,
			"to":               m.To,
			"date":             m.Date,
			"snippet":          m.Snippet,
			"body":             m.Body,
			"attachments":      m.Attatchments,
			"server_created_at": m.CreatedAt,
		})
	}
	return result, nil
}

// ── Assignment delta ──────────────────────────────────────────────────────────

// fetchAssignmentsDelta serves assignments from the CachedAssignment table.
// On full sync (or when the cache is empty), it re-fetches from the Classroom
// API and populates the cache, then returns all records for this student.
func (h *Handler) fetchAssignmentsDelta(
	r *http.Request,
	token, email string,
	since time.Time,
	isFullSync bool,
) ([]map[string]interface{}, error) {
	var student models.Student
	if err := h.DB.Where("svv_email = ?", email).First(&student).Error; err != nil {
		return nil, fmt.Errorf("student not found: %w", err)
	}

	// Count cached assignments for this student.
	var count int64
	h.DB.Model(&models.CachedAssignment{}).Where("student_id = ?", student.ID).Count(&count)

	// Refresh cache if: full sync requested, or no cache exists at all.
	if isFullSync || count == 0 {
		if err := h.refreshAssignmentCache(r, token, student.ID); err != nil {
			log.Printf("[SYNC] Assignment cache refresh failed: %v", err)
			// Don't abort — fall through and return whatever is cached.
		}
	}

	// Query the cache for the delta window.
	var cached []models.CachedAssignment
	query := h.DB.Where("student_id = ?", student.ID)
	if !isFullSync {
		query = query.Where("cached_at > ?", since)
	}

	if err := query.Find(&cached).Error; err != nil {
		return nil, fmt.Errorf("assignment cache query failed: %w", err)
	}

	result := make([]map[string]interface{}, 0, len(cached))
	for _, a := range cached {
		var materials interface{}
		if err := json.Unmarshal([]byte(a.MaterialsJSON), &materials); err != nil {
			materials = []interface{}{}
		}
		result = append(result, map[string]interface{}{
			"id":             a.ID,
			"course_id":      a.CourseID,
			"course_name":    a.CourseName,
			"title":          a.Title,
			"description":    a.Description,
			"state":          a.State,
			"due_date":       a.DueDate,
			"creation_time":  a.CreationTime,
			"update_time":    a.UpdateTime,
			"max_points":     a.MaxPoints,
			"work_type":      a.WorkType,
			"alternate_link": a.AlternateLink,
			"materials":      materials,
		})
	}
	return result, nil
}

// refreshAssignmentCache fetches all assignments from the Classroom API and
// upserts them into the cached_assignments table.
func (h *Handler) refreshAssignmentCache(r *http.Request, _ string, studentID string) error {
	svc, _, err := h.classroomClientForRequest(r)
	if err != nil {
		return fmt.Errorf("classroom client error: %w", err)
	}

	coursesResp, err := svc.Courses.List().CourseStates("ACTIVE").PageSize(50).Do()
	if err != nil {
		return fmt.Errorf("courses list failed: %w", err)
	}

	// Collect all assignments across courses.
	var toUpsert []models.CachedAssignment
	for _, course := range coursesResp.Courses {
		assignments, err := fetchAssignments(svc, course.Id)
		if err != nil {
			log.Printf("[SYNC] Skipping course %s: %v", course.Name, err)
			continue
		}
		for _, a := range assignments {
			matsJSON, _ := json.Marshal(a.Materials)
			toUpsert = append(toUpsert, models.CachedAssignment{
				ID:            a.ID,
				StudentID:     studentID,
				CourseID:      course.Id,
				CourseName:    course.Name,
				Title:         a.Title,
				Description:   a.Description,
				State:         a.State,
				DueDate:       a.DueDate,
				CreationTime:  a.CreationTime,
				UpdateTime:    a.UpdateTime,
				MaxPoints:     a.MaxPoints,
				WorkType:      a.WorkType,
				AlternateLink: a.AlternateLink,
				MaterialsJSON: string(matsJSON),
			})
		}
	}

	if len(toUpsert) == 0 {
		return nil
	}

	// Upsert in batches of 100 to stay within DB parameter limits.
	batchSize := 100
	for i := 0; i < len(toUpsert); i += batchSize {
		end := i + batchSize
		if end > len(toUpsert) {
			end = len(toUpsert)
		}
		if err := h.DB.Save(toUpsert[i:end]).Error; err != nil {
			log.Printf("[SYNC] Batch upsert failed (offset %d): %v", i, err)
		}
	}

	log.Printf("[SYNC] Cached %d assignments for student %s", len(toUpsert), studentID)
	return nil
}

// ── Course delta ──────────────────────────────────────────────────────────────

func (h *Handler) fetchCoursesDelta(email string, _ time.Time, _ bool) ([]map[string]interface{}, error) {
	var student models.Student
	if err := h.DB.Preload("Courses").Where("svv_email = ?", email).First(&student).Error; err != nil {
		return nil, fmt.Errorf("student not found: %w", err)
	}

	result := make([]map[string]interface{}, 0, len(student.Courses))
	for _, c := range student.Courses {
		result = append(result, map[string]interface{}{
			"id":          c.ID,
			"name":        c.Name,
			"section":     c.Section,
			"description": c.Description,
			"room":        c.Room,
			"enroll_code": c.EnrollCode,
			"state":       c.State,
		})
	}
	return result, nil
}

// ── helpers (used by refreshAssignmentCache) ──────────────────────────────────

// classroomOauthToken extracts the Google OAuth access + refresh tokens from
// the backend profile for the given JWT.
func (h *Handler) classroomOauthToken(token string) (accessToken, refreshToken, email string, err error) {
	profile, err := h.BackendProfile(token)
	if err != nil {
		return "", "", "", err
	}
	studentData, ok := profile["user"].(map[string]interface{})
	if !ok {
		return "", "", "", fmt.Errorf("invalid user data in profile")
	}
	email, _ = studentData["email"].(string)
	accessToken, _ = studentData["o_access_token"].(string)
	refreshToken, _ = studentData["o_refresh_token"].(string)
	return
}

// classroomHTTPClient returns an auto-refreshing OAuth HTTP client for Drive/Classroom.
func (h *Handler) classroomHTTPClient(r *http.Request, jwtToken string) (*http.Client, error) {
	accessToken, refreshToken, email, err := h.classroomOauthToken(jwtToken)
	if err != nil {
		return nil, err
	}
	client := service.GoogleHTTPClientFromStoredToken(
		r.Context(),
		h.Config.OAUTH_CLIENT_ID,
		h.Config.OAUTH_CLIENT_SECRET,
		accessToken,
		refreshToken,
		email,
		h.DB,
	)
	return client, nil
}
