# Food Calorie Frontend

Flutter frontend for a food calorie recognition app. The app lets you pick or capture a food photo, sends it to a backend prediction API, and shows the predicted food name, calories, confidence, ingredient details, and recent scan history.

## Highlights

- Capture a new food photo with camera or select one from gallery.
- Send image as multipart upload to backend prediction API.
- Display flexible prediction output (food, calories, confidence, ingredients).
- Keep up to 5 recent predictions in local in-memory history.
- Built with Riverpod and Material 3.

## Tech Stack

- Flutter
- Dart
- Riverpod and Flutter Riverpod
- image_picker
- http

## Requirements

- Flutter SDK compatible with Dart 3.10.4
- Dart SDK 3.10.4 or newer (as defined in pubspec)
- Running backend API reachable from your emulator/device

## Quick Start

1. Install dependencies.

```bash
flutter pub get
```

2. Run the app.

```bash
flutter run
```

3. Select a food image and press Predict.

## Configuration

### Backend Base URL

The app resolves backend URL in this order:

1. API_BASE_URL from dart-define
2. Fallback constant in [lib/core/api_service.dart](lib/core/api_service.dart)

Run with custom backend URL:

```bash
flutter run --dart-define=API_BASE_URL=http://your-backend-host:8000
```

Current fallback URL is defined in [lib/core/api_service.dart](lib/core/api_service.dart).

### Network Tips by Target

- Physical Android device: use your computer LAN IP, and both device and backend must be on same network.
- Android emulator: usually use http://10.0.2.2:8000 to reach host machine backend.
- iOS simulator: usually http://127.0.0.1:8000 works for local backend.
- Web: ensure backend CORS allows the web origin.

## Backend API Contract

The frontend expects these endpoints:

- GET / for connection test
- POST /predict for classification

Upload format for POST /predict:

- Content type: multipart/form-data
- Image field name: file

### Accepted Prediction Response Shapes

The app can parse multiple JSON shapes and field names.

Top-level or nested under one of:k

- data
- result
- prediction
- output

Supported food keys:

- food
- label
- class
- prediction

Supported calories keys:

- calories
- calorie
- kcal

Supported confidence keys:

- confidence
- probability
- score

Ingredients can be:

- List of strings
- List of objects
- Map
- Delimited string

Optional ingredient calorie maps supported:

- ingredient_calories
- ingredients_calories
- ingredients_with_calories

Minimal example response:

```json
{
	"food": "Pizza",
	"calories": 285,
	"confidence": 0.93,
	"ingredients": ["Dough", "Cheese", "Tomato Sauce"]
}
```

Nested example response:

```json
{
	"result": {
		"label": "Chicken Salad",
		"kcal": "210",
		"score": "0.88",
		"ingredients": [
			{ "name": "Chicken", "calories": 120 },
			{ "name": "Lettuce", "calories": 15 }
		]
	}
}
```

## Project Structure

- [lib/main.dart](lib/main.dart): App entry point and theme
- [lib/core/api_service.dart](lib/core/api_service.dart): API communication and timeout handling
- [lib/features/home/home_page.dart](lib/features/home/home_page.dart): Main UI and user actions
- [lib/features/home/providers.dart](lib/features/home/providers.dart): Prediction state and response parsing

## Common Issues

- Cannot connect to backend
	- Check API_BASE_URL value and backend host/port.
	- Verify emulator/device can reach backend network.
- Request timeout
	- Default timeout is 30 seconds. Check backend latency and logs.
- Prediction failed
	- Verify backend returns HTTP 200 and JSON response.
	- Confirm image field is named file in multipart request.

## Development Commands

```bash
flutter analyze
flutter test
flutter build apk
```

## Notes

- This project is configured as private (publish_to: none).
- Prediction history is stored in memory and resets when app restarts.
