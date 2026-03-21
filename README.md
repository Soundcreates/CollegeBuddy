git clone <repo-url>
cd Somaiya_ext

# CollegeBuddy

CollegeBuddy is a cross-platform productivity suite for students, featuring:

- **Backend API** (Go, PostgreSQL): Handles authentication, user data, and Gmail scraping.
- **Mobile App** (Flutter): Modern UI for managing tasks, deadlines, and Google OAuth login.
- **AI Scraper Service** (Python/FastAPI): Classifies and filters emails using NLP models.

---

## Project Structure

```
backend/         # Go backend API (REST, JWT, Gmail scraping, PostgreSQL)
mobile/          # Flutter mobile app (Android/iOS)
scraperService/  # Python FastAPI ML microservice (email classification)
```

---

## Backend (Go)
- RESTful API for user, auth, and Gmail endpoints
- JWT authentication
- PostgreSQL database (see docker-compose.yml)
- Gmail scraping and message parsing
- CORS for mobile/web clients

**Setup:**
1. `cd backend`
2. Copy `.env.example` to `.env` and fill secrets
3. `docker-compose up --build` (runs backend + Postgres + scraper)

---

## Mobile App (Flutter)
- Google Sign-In, secure storage
- Task/deadline management UI
- Connects to backend API

**Setup:**
1. `cd mobile`
2. `flutter pub get`
3. `flutter run`

---

## Scraper Service (Python/FastAPI)
- Email classification/filtering with HuggingFace models
- REST endpoint: `/text-classification`

**Setup:**
1. `cd scraperService`
2. `pip install -r requirements.txt`
3. `uvicorn app.app:app --reload`

---

## Contributing
PRs welcome! Please open issues for bugs or feature requests.

---

**Note:** This README omits the browser extension. See `extension/README.md` for extension setup.
