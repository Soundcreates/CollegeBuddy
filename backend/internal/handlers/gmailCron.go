package handlers

import (
	"context"
	"fmt"
	"log"
	"somaiya-ext/internal/models"
	"strings"

	"github.com/robfig/cron/v3"
)

const defaultGmailScrapeCronSpec = "0 */6 * * *"

func (h *Handler) StartGmailScrapeCron() (*cron.Cron, error) {
	spec := strings.TrimSpace(h.Config.GMAIL_SCRAPE_CRON)
	if spec == "" {
		spec = defaultGmailScrapeCronSpec
	}

	scheduler := cron.New()
	_, err := scheduler.AddFunc(spec, func() {
		h.runScheduledGmailScrape(context.Background())
	})
	if err != nil {
		return nil, fmt.Errorf("invalid gmail scrape cron schedule %q: %w", spec, err)
	}

	scheduler.Start()
	log.Printf("Gmail scrape cron started with schedule %q", spec)
	return scheduler, nil
}

func (h *Handler) runScheduledGmailScrape(ctx context.Context) {
	var students []models.Student
	err := h.DB.WithContext(ctx).
		Where("svv_email <> ''").
		Where("o_access_token <> ''").
		Find(&students).Error
	if err != nil {
		log.Printf("Failed to load students for gmail cron scrape: %v", err)
		return
	}

	if len(students) == 0 {
		log.Println("Gmail scrape cron run skipped: no users with access tokens")
		return
	}

	log.Printf("Starting scheduled Gmail scrape for %d users", len(students))
	for _, student := range students {
		response, err := h.scrapeAndFilterGmail(ctx, student.SVVEmail, student.OAccessToken, student.ORefreshToken)
		if err != nil {
			log.Printf("Scheduled Gmail scrape failed for %s: %v", student.SVVEmail, err)
			continue
		}

		totalEmails, _ := response["total_emails"].(int)
		filteredCount, _ := response["filtered_count"].(int)
		log.Printf(
			"Scheduled Gmail scrape completed for %s (total=%d, filtered=%d)",
			student.SVVEmail,
			totalEmails,
			filteredCount,
		)
	}
}
