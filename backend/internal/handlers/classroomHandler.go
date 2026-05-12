package handlers

import (
	"bytes"
	"encoding/base64"
	"encoding/json"
	"fmt"
	"io"
	"log"
	"net/http"
	"somaiya-ext/internal/models"
	"somaiya-ext/service"
	"strings"
	"time"

	"google.golang.org/api/classroom/v1"
)

// ──────────────────────────────────────────────
//  Helpers
// ──────────────────────────────────────────────

// classroomClientForRequest extracts JWT, fetches OAuth tokens, and returns a Classroom service.
func (h *Handler) classroomClientForRequest(r *http.Request) (*classroom.Service, string, error) {
	authHeader := r.Header.Get("Authorization")
	if authHeader == "" {
		return nil, "", fmt.Errorf("missing authorization header")
	}

	token := strings.TrimPrefix(authHeader, "Bearer ")
	if token == authHeader {
		return nil, "", fmt.Errorf("invalid authorization format")
	}

	claims, err := h.ParseJWTForScraping(token)
	if err != nil {
		return nil, "", fmt.Errorf("invalid token: %w", err)
	}

	email, ok := claims["email"].(string)
	if !ok {
		return nil, "", fmt.Errorf("email not found in token")
	}

	profile, err := h.BackendProfile(token)
	if err != nil {
		return nil, "", fmt.Errorf("failed to fetch profile: %w", err)
	}

	studentData, ok := profile["user"].(map[string]interface{})
	if !ok {
		return nil, "", fmt.Errorf("invalid student data")
	}

	accessToken, _ := studentData["o_access_token"].(string)
	if accessToken == "" {
		return nil, "", fmt.Errorf("no access token found")
	}
	refreshToken, _ := studentData["o_refresh_token"].(string)

	svc, err := service.ClassroomClientFromStoredToken(r.Context(), h.Config.OAUTH_CLIENT_ID, h.Config.OAUTH_CLIENT_SECRET, accessToken, refreshToken, email, h.DB)
	if err != nil {
		return nil, "", fmt.Errorf("failed to create classroom client: %w", err)
	}

	return svc, email, nil
}

// ──────────────────────────────────────────────
//  GET /classroom/courses
// ──────────────────────────────────────────────

func (h *Handler) HandleListCourses(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	log.Println("[CLASSROOM] HandleListCourses called")
	response_payload := make(map[string]interface{})
	
	// Extract token once at the start
	token := strings.TrimPrefix(r.Header.Get("Authorization"), "Bearer ")
	
	// Fetch profile once
	curr_user, err := h.BackendProfile(token)
	if err != nil {
		log.Printf("Failed to fetch backend profile: %v", err)
		http.Error(w, "failed to fetch backend profile", http.StatusInternalServerError)
		return
	}
	curr_user_mail := curr_user["user"].(map[string]interface{})["email"].(string)
	
	// Check if refresh param is set
	refresh_val := r.URL.Query().Get("refresh")
	if refresh_val == "" {
		log.Println("Trying to fetch courses from db")
		var student models.Student
		// Preload Courses association so we can return cached courses if present
		if err := h.DB.Preload("Courses").Where("svv_email = ?", curr_user_mail).First(&student).Error; err != nil {
			log.Printf("Failed to fetch classroom courses from DB for %s: %v", curr_user_mail, err)
		} else {
			log.Printf("Fetched student from db with ID = %s ; found %d courses", student.ID, len(student.Courses))
			if len(student.Courses) > 0 {
				cached := make([]models.CourseResponse, 0, len(student.Courses))
				for _, sc := range student.Courses {
					cached = append(cached, models.CourseResponse{
						ID:          sc.ID,
						Name:        sc.Name,
						Section:     sc.Section,
						Description: sc.Description,
						Room:        sc.Room,
						EnrollCode:  sc.EnrollCode,
						State:       sc.State,
					})
				}
				response_payload["success"] = true
				response_payload["courses"] = cached
				response_payload["count"] = len(cached)
				json.NewEncoder(w).Encode(response_payload)
				return
			}
		}
	}

	svc, _, err := h.classroomClientForRequest(r)
	if err != nil {
		log.Println("[CLASSROOM] Error:", err)
		http.Error(w, err.Error(), http.StatusUnauthorized)
		return
	}

	log.Println("Fetching classroom courses from API")
	resp, err := svc.Courses.List().CourseStates("ACTIVE").PageSize(50).Do()
	if err != nil {
		log.Println("[CLASSROOM] Failed to list courses:", err)
		http.Error(w, "failed to list courses: "+err.Error(), http.StatusInternalServerError)
		return
	}

	courses := make([]models.CourseResponse, 0, len(resp.Courses))
	for _, c := range resp.Courses {
		courses = append(courses, models.CourseResponse{
			ID:          c.Id,
			Name:        c.Name,
			Section:     c.Section,
			Description: c.DescriptionHeading,
			Room:        c.Room,
			EnrollCode:  c.EnrollmentCode,
			State:       c.CourseState,
		})
	}

	// Persist courses as associated Course records for the student (reuse profile from earlier)
	var student models.Student
	if err := h.DB.Where("svv_email = ?", curr_user_mail).First(&student).Error; err != nil {
		log.Printf("Failed to locate student to save courses for %s: %v", curr_user_mail, err)
	} else {
		// Remove existing courses for the student and insert fresh ones
		if err := h.DB.Where("student_id = ?", student.ID).Delete(&models.Course{}).Error; err != nil {
			log.Printf("Failed to delete old courses for %s: %v", curr_user_mail, err)
		}
		courseModels := make([]models.Course, 0, len(courses))
		for _, c := range courses {
			courseModels = append(courseModels, models.Course{
				ID:          c.ID,
				Name:        c.Name,
				Section:     c.Section,
				Description: c.Description,
				Room:        c.Room,
				EnrollCode:  c.EnrollCode,
				State:       c.State,
				StudentID:   student.ID,
			})
		}
		if len(courseModels) > 0 {
			if err := h.DB.Create(&courseModels).Error; err != nil {
				log.Printf("Failed to insert courses for %s: %v", curr_user_mail, err)
			} else {
				log.Println("Successfully stored courses for student", curr_user_mail)
			}
		}
	}

	json.NewEncoder(w).Encode(map[string]interface{}{
		"success": true,
		"courses": courses,
		"count":   len(courses),
	})
}


// ──────────────────────────────────────────────
//  GET /classroom/courses/{courseId}/assignments
// ──────────────────────────────────────────────

func (h *Handler) HandleListCourseAssignments(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	log.Println("[CLASSROOM] HandleListCourseAssignments called")

	courseID := r.URL.Query().Get("course_id")
	if courseID == "" {
		http.Error(w, "course_id is required", http.StatusBadRequest)
		return
	}

	svc, _, err := h.classroomClientForRequest(r)
	if err != nil {
		log.Println("[CLASSROOM] Error:", err)
		http.Error(w, err.Error(), http.StatusUnauthorized)
		return
	}

	assignments, err := fetchAssignments(svc, courseID)
	if err != nil {
		log.Println("[CLASSROOM] Failed to fetch assignments:", err)
		http.Error(w, "failed to fetch assignments: "+err.Error(), http.StatusInternalServerError)
		return
	}

	json.NewEncoder(w).Encode(map[string]interface{}{
		"success":     true,
		"assignments": assignments,
		"count":       len(assignments),
		"course_id":   courseID,
	})
}

// ──────────────────────────────────────────────
//  GET /classroom/assignments  (all courses)
// ──────────────────────────────────────────────

func (h *Handler) HandleListAllAssignments(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	log.Println("[CLASSROOM] HandleListAllAssignments called")

	svc, _, err := h.classroomClientForRequest(r)
	if err != nil {
		log.Println("[CLASSROOM] Error:", err)
		http.Error(w, err.Error(), http.StatusUnauthorized)
		return
	}

	coursesResp, err := svc.Courses.List().CourseStates("ACTIVE").PageSize(50).Do()
	if err != nil {
		log.Println("[CLASSROOM] Failed to list courses:", err)
		http.Error(w, "failed to list courses: "+err.Error(), http.StatusInternalServerError)
		return
	}

	type assignmentWithCourse struct {
		CourseName string      `json:"course_name"`
		CourseID   string      `json:"course_id"`
		Assignment interface{} `json:"assignment"`
	}

	allAssignments := make([]assignmentWithCourse, 0)
	for _, course := range coursesResp.Courses {
		assignments, err := fetchAssignments(svc, course.Id)
		if err != nil {
			log.Printf("[CLASSROOM] Skipping course %s (%s): %v", course.Name, course.Id, err)
			continue
		}
		for _, a := range assignments {
			allAssignments = append(allAssignments, assignmentWithCourse{
				CourseName: course.Name,
				CourseID:   course.Id,
				Assignment: a,
			})
		}
	}

	json.NewEncoder(w).Encode(map[string]interface{}{
		"success":     true,
		"assignments": allAssignments,
		"count":       len(allAssignments),
	})
}

// ──────────────────────────────────────────────
//  GET /classroom/attachment
// ──────────────────────────────────────────────

func (h *Handler) HandleGetAttachment(w http.ResponseWriter, r *http.Request) {
	log.Println("[CLASSROOM] HandleGetAttachment called")

	downloadURL := r.URL.Query().Get("url")
	if downloadURL == "" {
		http.Error(w, "url is required", http.StatusBadRequest)
		return
	}

	// We proxy the download through our server so the Flutter client
	// doesn't need its own Google auth for Drive file downloads.
	authHeader := r.Header.Get("Authorization")
	token := strings.TrimPrefix(authHeader, "Bearer ")

	claims, err := h.ParseJWTForScraping(token)
	if err != nil {
		http.Error(w, "invalid token", http.StatusUnauthorized)
		return
	}

	email, _ := claims["email"].(string)
	profile, err := h.BackendProfile(token)
	if err != nil {
		http.Error(w, "failed to fetch profile", http.StatusInternalServerError)
		return
	}

	studentData, _ := profile["user"].(map[string]interface{})
	accessToken, _ := studentData["o_access_token"].(string)

	_ = email // used for logging only

	// Download the file with the user's OAuth access token
	client := &http.Client{Timeout: 60 * time.Second}
	req, err := http.NewRequest("GET", downloadURL, nil)
	if err != nil {
		http.Error(w, "failed to create request", http.StatusInternalServerError)
		return
	}
	req.Header.Set("Authorization", "Bearer "+accessToken)

	resp, err := client.Do(req)
	if err != nil {
		log.Println("[CLASSROOM] Failed to download attachment:", err)
		http.Error(w, "failed to download attachment", http.StatusInternalServerError)
		return
	}
	defer resp.Body.Close()

	// Forward content type and body
	w.Header().Set("Content-Type", resp.Header.Get("Content-Type"))
	w.Header().Set("Content-Disposition", resp.Header.Get("Content-Disposition"))
	w.WriteHeader(resp.StatusCode)
	io.Copy(w, resp.Body)
}

// ──────────────────────────────────────────────
//  POST /classroom/ai-help
// ──────────────────────────────────────────────

func (h *Handler) HandleAIHelp(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	log.Println("[CLASSROOM] HandleAIHelp called")

	var requestBody struct {
		Title       string `json:"title"`
		Description string `json:"description"`
		FileURL     string `json:"file_url"`
	}

	if err := json.NewDecoder(r.Body).Decode(&requestBody); err != nil {
		http.Error(w, "invalid request body", http.StatusBadRequest)
		return
	}

	// Build the payload for the RAG service
	ragPayload := map[string]interface{}{
		"title":       requestBody.Title,
		"description": requestBody.Description,
		"file_url":    requestBody.FileURL,
	}

	// If there's a file URL, download it first and pass raw content
	if requestBody.FileURL != "" {
		// Get the user's access token to download the file
		authHeader := r.Header.Get("Authorization")
		token := strings.TrimPrefix(authHeader, "Bearer ")
		profile, err := h.BackendProfile(token)
		if err == nil {
			if studentData, ok := profile["user"].(map[string]interface{}); ok {
				if accessToken, ok := studentData["o_access_token"].(string); ok {
					client := &http.Client{Timeout: 30 * time.Second}
					req, _ := http.NewRequest("GET", requestBody.FileURL, nil)
					req.Header.Set("Authorization", "Bearer "+accessToken)
					resp, err := client.Do(req)
					if err == nil {
						defer resp.Body.Close()
						fileBytes, _ := io.ReadAll(resp.Body)
						// Base64 encode the file content for the RAG service
						ragPayload["file_content_base64"] = fmt.Sprintf("%s", encodeBase64(fileBytes))
						ragPayload["file_content_type"] = resp.Header.Get("Content-Type")
					}
				}
			}
		}
	}

	payloadBytes, _ := json.Marshal(ragPayload)

	// Use the new /rag/assignment-help endpoint for Q&A extraction
	scraperURL := h.Config.SCRAPER_SERVICE_URL + "/rag/assignment-help"
	log.Println("[CLASSROOM] Forwarding to RAG service:", scraperURL)

	client := &http.Client{Timeout: 120 * time.Second}
	resp, err := client.Post(scraperURL, "application/json", bytes.NewBuffer(payloadBytes))
	if err != nil {
		log.Println("[CLASSROOM] RAG service error:", err)
		http.Error(w, "AI service unavailable: "+err.Error(), http.StatusServiceUnavailable)
		return
	}
	defer resp.Body.Close()

	body, _ := io.ReadAll(resp.Body)

	w.WriteHeader(resp.StatusCode)
	w.Write(body)
}


// ──────────────────────────────────────────────
//  Internal helpers
// ──────────────────────────────────────────────

type assignmentResponse struct {
	ID            string             `json:"id"`
	Title         string             `json:"title"`
	Description   string             `json:"description"`
	State         string             `json:"state"`
	DueDate       string             `json:"due_date"`
	CreationTime  string             `json:"creation_time"`
	UpdateTime    string             `json:"update_time"`
	MaxPoints     float64            `json:"max_points"`
	WorkType      string             `json:"work_type"`
	AlternateLink string             `json:"alternate_link"`
	Materials     []materialResponse `json:"materials"`
}

type materialResponse struct {
	Title        string `json:"title"`
	URL          string `json:"url"`
	DownloadURL  string `json:"download_url"`
	Type         string `json:"type"` // "driveFile", "link", "youtubeVideo", "form"
	ThumbnailURL string `json:"thumbnail_url"`
}

func fetchAssignments(svc *classroom.Service, courseID string) ([]assignmentResponse, error) {
	resp, err := svc.Courses.CourseWork.List(courseID).OrderBy("dueDate desc").PageSize(50).Do()
	if err != nil {
		return nil, err
	}

	assignments := make([]assignmentResponse, 0, len(resp.CourseWork))
	for _, cw := range resp.CourseWork {
		dueDate := ""
		if cw.DueDate != nil {
			dueDate = fmt.Sprintf("%d-%02d-%02d", cw.DueDate.Year, cw.DueDate.Month, cw.DueDate.Day)
			if cw.DueTime != nil {
				dueDate += fmt.Sprintf(" %02d:%02d", cw.DueTime.Hours, cw.DueTime.Minutes)
			}
		}

		materials := make([]materialResponse, 0)
		for _, m := range cw.Materials {
			mat := materialResponse{}
			if m.DriveFile != nil && m.DriveFile.DriveFile != nil {
				mat.Title = m.DriveFile.DriveFile.Title
				mat.URL = m.DriveFile.DriveFile.AlternateLink
				mat.DownloadURL = "https://www.googleapis.com/drive/v3/files/" + m.DriveFile.DriveFile.Id + "?alt=media"
				mat.ThumbnailURL = m.DriveFile.DriveFile.ThumbnailUrl
				mat.Type = "driveFile"
			} else if m.Link != nil {
				mat.Title = m.Link.Title
				mat.URL = m.Link.Url
				mat.ThumbnailURL = m.Link.ThumbnailUrl
				mat.Type = "link"
			} else if m.YoutubeVideo != nil {
				mat.Title = m.YoutubeVideo.Title
				mat.URL = m.YoutubeVideo.AlternateLink
				mat.ThumbnailURL = m.YoutubeVideo.ThumbnailUrl
				mat.Type = "youtubeVideo"
			} else if m.Form != nil {
				mat.Title = m.Form.Title
				mat.URL = m.Form.FormUrl
				mat.ThumbnailURL = m.Form.ThumbnailUrl
				mat.Type = "form"
			}
			if mat.Type != "" {
				materials = append(materials, mat)
			}
		}

		assignments = append(assignments, assignmentResponse{
			ID:            cw.Id,
			Title:         cw.Title,
			Description:   cw.Description,
			State:         cw.State,
			DueDate:       dueDate,
			CreationTime:  cw.CreationTime,
			UpdateTime:    cw.UpdateTime,
			MaxPoints:     cw.MaxPoints,
			WorkType:      cw.WorkType,
			AlternateLink: cw.AlternateLink,
			Materials:     materials,
		})
	}

	return assignments, nil
}

func encodeBase64(data []byte) string {
	return base64.StdEncoding.EncodeToString(data)
}
