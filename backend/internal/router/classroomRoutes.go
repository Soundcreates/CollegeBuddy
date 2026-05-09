package routes

import (
	"net/http"
	handler "somaiya-ext/internal/handlers"
	"somaiya-ext/internal/middleware"
)

func registerClassroomRoutes(h *handler.Handler, router *http.ServeMux) {
	router.HandleFunc("GET /classroom/courses", middleware.WithAuth(h)(h.HandleListCourses))
	router.HandleFunc("GET /classroom/assignments", middleware.WithAuth(h)(h.HandleListAllAssignments))
	router.HandleFunc("GET /classroom/course/assignments", middleware.WithAuth(h)(h.HandleListCourseAssignments))
	router.HandleFunc("GET /classroom/attachment", middleware.WithAuth(h)(h.HandleGetAttachment))
	router.HandleFunc("POST /classroom/ai-help", middleware.WithAuth(h)(h.HandleAIHelp))
}
