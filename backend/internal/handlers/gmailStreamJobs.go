package handlers

import (
	"crypto/rand"
	"encoding/hex"
	"sync"
	"time"
)

type GmailStreamJob struct {
	ID        string
	Email     string
	CreatedAt time.Time

	Messages []map[string]interface{}
	Done     bool
	Error    string
}

type gmailStreamJobStore struct {
	mu   sync.RWMutex
	jobs map[string]*GmailStreamJob
}

func newGmailStreamJobStore() *gmailStreamJobStore {
	return &gmailStreamJobStore{
		jobs: make(map[string]*GmailStreamJob),
	}
}

func (s *gmailStreamJobStore) Create(email string) *GmailStreamJob {
	job := &GmailStreamJob{
		ID:        newJobID(),
		Email:     email,
		CreatedAt: time.Now(),
		Messages:  make([]map[string]interface{}, 0),
		Done:      false,
		Error:     "",
	}
	s.mu.Lock()
	s.jobs[job.ID] = job
	s.mu.Unlock()
	return job
}

func (s *gmailStreamJobStore) Get(id string) (*GmailStreamJob, bool) {
	s.mu.RLock()
	job, ok := s.jobs[id]
	s.mu.RUnlock()
	return job, ok
}

func (s *gmailStreamJobStore) AppendMessages(id string, msgs []map[string]interface{}) {
	s.mu.Lock()
	job, ok := s.jobs[id]
	if ok {
		job.Messages = append(job.Messages, msgs...)
	}
	s.mu.Unlock()
}

func (s *gmailStreamJobStore) SetDone(id string) {
	s.mu.Lock()
	job, ok := s.jobs[id]
	if ok {
		job.Done = true
	}
	s.mu.Unlock()
}

func (s *gmailStreamJobStore) SetError(id string, errMsg string) {
	s.mu.Lock()
	job, ok := s.jobs[id]
	if ok {
		job.Error = errMsg
		job.Done = true
	}
	s.mu.Unlock()
}

func newJobID() string {
	b := make([]byte, 16)
	_, _ = rand.Read(b)
	return hex.EncodeToString(b)
}
