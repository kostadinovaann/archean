# Archean Flutter Web Frontend

This Flutter project is a minimal web frontend that connects to the Archean Flask backend at `http://localhost:5000`.

Prerequisites
- Flutter SDK installed and on PATH

Run (web):
```powershell
cd frontend
flutter pub get
flutter run -d chrome
```

Build for production:
```powershell
cd frontend
flutter build web
# deploy the contents of build/web to any static host
```

Configuration
- The API base URL is set to `http://localhost:5000` inside `lib/api_service.dart`. Change it if your backend runs elsewhere.
