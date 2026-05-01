# Food Calorie Frontend

Flutter frontend for an AI-powered food calorie recognition app. The app lets users pick or capture one food photo or upload a batch of images, sends them to a backend prediction API, and displays predicted food name, calories, confidence, nutrition, ingredients, portion-adjusted calories, healthier alternatives, and recent scan history.

## Key Features

- Capture photos using camera or pick from gallery.
- Support single-image and batch uploads with preview before submit.
- Send image or batch data to the backend as multipart upload.
- Show flexible prediction output (food, calories, confidence, nutrition, ingredients).
- Adjust portion multiplier and fetch updated calories from the backend.
- Load healthier alternatives with calorie reduction details.
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
- `POST /predict/batch`, `POST /batch-predict`, or `POST /predict-batch` for multiple image predictions
- `POST /portion-adjust`, `POST /adjust-portion`, or `POST /predict/portion` for portion multiplier updates
- `POST /healthier-alternatives`, `POST /alternatives`, or `POST /food/alternatives` for lighter option suggestions

Upload format for `POST /predict`:

- Content type: `multipart/form-data`
- Image field name: `file`

Batch upload field names that the frontend will try:

- `files`
- `images`
- `file`

Minimal response example:

```json
{
  "food": "Pizza",
  "calories": 285,
  "confidence": 0.93,
  "ingredients": ["Dough", "Cheese", "Tomato Sauce"]
}
```

Batch responses can return a `results`, `items`, or `predictions` array. Ingredient details may include confidence, and portion/alternatives responses can add `adjustedCalories`, `adjustedNutrition`, or `alternatives` data.

## Project Structure

- [lib/main.dart](lib/main.dart): App entry point and theming
- [lib/app/app_shell.dart](lib/app/app_shell.dart): Bottom-nav app shell for scan, diet, history, and profile
- [lib/core/api_service.dart](lib/core/api_service.dart): API communication and timeout handling
- [lib/features/food_scan/view/screens/food_scan_screen.dart](lib/features/food_scan/view/screens/food_scan_screen.dart): Food scan screen
- [lib/features/food_scan/viewmodel/food_scan_view_model.dart](lib/features/food_scan/viewmodel/food_scan_view_model.dart): Food scan state and actions
- [lib/features/food_scan/model/food_scan_models.dart](lib/features/food_scan/model/food_scan_models.dart): Prediction data models
- [lib/features/diet/view/screens/diet_dashboard_screen.dart](lib/features/diet/view/screens/diet_dashboard_screen.dart): Diet dashboard
- [lib/features/diet/viewmodel/diet_view_model.dart](lib/features/diet/viewmodel/diet_view_model.dart): Diet state and actions
- [lib/features/diet/model/diet_models.dart](lib/features/diet/model/diet_models.dart): Diet and profile models
- [lib/features/user_profile/view/screens/profile_screen.dart](lib/features/user_profile/view/screens/profile_screen.dart): Profile setup screen
- [lib/features/user_profile/viewmodel/profile_view_model.dart](lib/features/user_profile/viewmodel/profile_view_model.dart): Profile state and actions
- [lib/features/history/view/history_page.dart](lib/features/history/view/history_page.dart): History view layer
- [lib/features/history/view/scan_detail_page.dart](lib/features/history/view/scan_detail_page.dart): History detail view

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
