package models

import "time"

// CachedAssignment stores a snapshot of a Google Classroom assignment in
// PostgreSQL so the /sync endpoint can serve delta queries without hitting
// the Classroom API on every request.
type CachedAssignment struct {
	ID            string    `json:"id" gorm:"primaryKey"`
	StudentID     string    `json:"student_id" gorm:"index;column:student_id"`
	CourseID      string    `json:"course_id"`
	CourseName    string    `json:"course_name"`
	Title         string    `json:"title"`
	Description   string    `json:"description"`
	State         string    `json:"state"`
	DueDate       string    `json:"due_date"`
	CreationTime  string    `json:"creation_time"`
	UpdateTime    string    `json:"update_time"` // From Google — change-detection key.
	MaxPoints     float64   `json:"max_points"`
	WorkType      string    `json:"work_type"`
	AlternateLink string    `json:"alternate_link"`
	MaterialsJSON string    `json:"materials_json" gorm:"column:materials_json"`
	CachedAt      time.Time `json:"cached_at" gorm:"autoUpdateTime"`
}

// SyncResponse is the payload returned by GET /sync.
type SyncResponse struct {
	Deadlines     []map[string]interface{} `json:"deadlines"`
	Announcements []map[string]interface{} `json:"announcements"`
	Courses       []map[string]interface{} `json:"courses"`
	ServerTime    time.Time                `json:"server_time"`
}
