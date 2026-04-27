# Food Calorie Frontend

Flutter frontend for an AI-powered food calorie recognition app. The app lets users pick or capture a food photo, sends it to a backend prediction API, and displays predicted food name, calories, confidence, ingredients, and recent scan history.

## Key Features

- Capture photos using camera or pick from gallery.
- Send image to backend as multipart upload.
- Show flexible prediction output (food, calories, confidence, ingredients).
- Maintain lightweight recent prediction history.
- Built with Riverpod and Material 3.

## Tech Stack

- Flutter
- Dart
- Riverpod / Flutter Riverpod
- image_picker
- http

## Requirements

- Flutter SDK compatible with Dart 3.10.4
- Dart SDK 3.10.4+
- Running backend API reachable from emulator/device

## Setup

1. Install dependencies.

```bash
flutter pub get
```

2. Run the app.

```bash
flutter run
```

## Configuration

### Backend Base URL

The app resolves backend URL in this order:

1. `API_BASE_URL` from `--dart-define`
2. Fallback constant in [lib/core/api_service.dart](lib/core/api_service.dart)

Run with a custom backend URL:

```bash
flutter run --dart-define=API_BASE_URL=http://your-backend-host:8000
```

Current default fallback URL is set in [lib/core/api_service.dart](lib/core/api_service.dart).

### Network Tips by Target

- Physical Android device: use your computer LAN IP, and ensure both devices share the same network.
- Android emulator: usually `http://10.0.2.2:8000` to reach host machine backend.
- iOS simulator: usually `http://127.0.0.1:8000` for local backend.
- Web: ensure backend CORS allows the web origin.

## Backend API Contract

The frontend expects these endpoints:

- `GET /` for connection test
- `POST /predict` for food classification

Upload format for `POST /predict`:

- Content type: `multipart/form-data`
- Image field name: `file`

Minimal response example:

```json
{
  "food": "Pizza",
  "calories": 285,
  "confidence": 0.93,
  "ingredients": ["Dough", "Cheese", "Tomato Sauce"]
}
```

## Project Structure

- [lib/main.dart](lib/main.dart): App entry point and theming
- [lib/core/api_service.dart](lib/core/api_service.dart): API communication and timeout handling
- [lib/features/home/home_page.dart](lib/features/home/home_page.dart): Main UI and user actions
- [lib/features/home/providers.dart](lib/features/home/providers.dart): Prediction state and response parsing

## Useful Commands

```bash
flutter analyze
flutter test
flutter build apk
flutter clean
```

## Notes

- This project is private (`publish_to: none`).
- Prediction history is currently in-memory and resets on app restart.
