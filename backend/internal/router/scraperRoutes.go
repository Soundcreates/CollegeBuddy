package routes


import(
	"net/http"
	handler "somaiya-ext/internal/handlers"
)

func registerScraperRoutes(h *handler.Handler, router *http.ServeMux){
	
	router.HandleFunc("POST /scrape/gmail", h.HandleScrapeGmail)
}