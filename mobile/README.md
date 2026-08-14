# CollegeBuddy

Flutter client for the CollegeBuddy backend.

```bash
flutter pub get
flutter run
```

The Android emulator uses `http://10.0.2.2:8080` by default. Override the API
for iOS, a physical device, or a deployed backend:

```bash
flutter run --dart-define=API_URL=https://your-backend.example.com
```

Google OAuth also requires the backend `BACKEND_URL` to point to a reachable
public callback URL.
