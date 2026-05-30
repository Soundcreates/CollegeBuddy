package models

// Student represents a user of the system. Student.ID is a string (Google id)
type Student struct {
	ID                 string   `json:"id" gorm:"primaryKey"`
	Name               string   `json:"name"`
	SVVNetId           string   `json:"svv_net_id" gorm:"unique"`
	SVVEmail           string   `json:"email" gorm:"column:svv_email;unique"`
	ProfilePic         string   `json:"picture"`
	VerifiedEmail      bool     `json:"verified_email"`
	ORefreshToken      string   `json:"o_refresh_token" gorm:"column:o_refresh_token"`
	OAccessToken       string   `json:"o_access_token" gorm:"column:o_access_token"`
	OAccessTokenExpiry int64    `json:"o_access_token_expiry"` // Unix timestamp
	JWTToken           string   `json:"jwt-token" gorm:"column:jwt-token"`
	JWTRefresh         string   `json:"jwt-refresh" gorm:"column:jwt-refresh"`
	Courses            []Course `json:"courses" gorm:"foreignKey:StudentID;constraint:OnDelete:CASCADE"`
}

type AssignmentAnswer struct {
	ID         string  `json:"id" gorm:primaryKey`
	StudentID  string  `json:"student_id" gorm:"index;column:student_id"`
	Student    Student `json:"-" gorm:"foreignKey:StudentID`
	CourseID   string  `json:"course_id" gorm:"index;column:course_id"`
	Course     Course  `json:"-" gorm:"foreignKey:CourseID"`
	AnswerText string  `json:"answer_text"`
}
type CourseResponse struct {
	ID          string `json:"id"`
	Name        string `json:"name"`
	Section     string `json:"section"`
	Description string `json:"description"`
	Room        string `json:"room"`
	EnrollCode  string `json:"enroll_code"`
	State       string `json:"state"`
}

type Course struct {
	ID          string `json:"id" gorm:"primaryKey"`
	Name        string `json:"name"`
	Section     string `json:"section"`
	Description string `json:"description"`
	Room        string `json:"room"`
	EnrollCode  string `json:"enroll_code"`
	State       string `json:"state"`

	StudentID string  `json:"student_id" gorm:"index;column:student_id"`
	Student   Student `json:"-" gorm:"foreignKey:StudentID"`
}

type GoogleUser struct {
	ID            string `json:"id"`
	Email         string `json:"email"`
	VerifiedEmail bool   `json:"verified_email"`
	Name          string `json:"name"`
	Picture       string `json:"picture"`
	GivenName     string `json:"given_name"`
	FamilyName    string `json:"family_name"`
}
