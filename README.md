# 🍽️ Food Calorie Recognition App (Flutter Frontend)

A modern **Flutter-based frontend** for an AI-powered food calorie recognition system.
This app allows users to capture or upload food images, send them to a backend API, and receive intelligent predictions including **food name, calories, confidence score, ingredients**, and **scan history**.

---

## 🚀 Key Features

✨ **Image Input**

* Capture photos using the camera
* Select images from the gallery

🤖 **AI Prediction Integration**

* Sends images to a backend ML API
* Receives structured prediction data

📊 **Detailed Results View**

* Food name
* Estimated calories
* Confidence score
* Ingredient breakdown

📜 **Scan History**

* View previously scanned food items
* Lightweight and user-friendly history tracking

🎯 **Modern Architecture**

* State management using **Riverpod**
* Clean and scalable project structure
* Built with **Material 3 UI**

---

## 🛠️ Tech Stack

* **Framework:** Flutter
* **Language:** Dart
* **State Management:** Riverpod
* **UI Design:** Material 3

---

## 📋 Requirements

Ensure your development environment includes:

* Flutter SDK **3.10+**
* Dart **3.10+**
* A running backend API for predictions

Check your setup:

```bash
flutter doctor
```

---

## ⚙️ Setup & Installation

### 1️⃣ Clone the Repository

```bash
git clone https://github.com/your-username/your-repo-name.git
cd your-repo-name
```

### 2️⃣ Install Dependencies

```bash
flutter pub get
```

### 3️⃣ Configure Backend API

Default API configuration is located at:

```
lib/core/api_service.dart
```

To override dynamically:

```bash
flutter run --dart-define=API_BASE_URL=http://your-backend-host:8000
```

---

## ▶️ Running the App

```bash
flutter run
```

---

## 🔌 Backend API Contract

Your backend must support:

### ✅ Health Check

```
GET /
```

### ✅ Prediction Endpoint

```
POST /predict
```

**Request:**

* Multipart form-data
* Field name: `file` (image)

**Response (Example):**

```json
{
  "food": "Pizza",
  "calories": 285,
  "confidence": 0.92,
  "ingredients": ["cheese", "tomato", "flour"]
}
```

---

## 📂 Project Structure

```
lib/
│
├── main.dart                     # App entry point
│
├── core/
│   └── api_service.dart          # API communication layer
│
├── features/
│   └── home/
│       └── home_page.dart        # Main UI screen
```

---

## 🧪 Useful Commands

```bash
flutter analyze      # Code quality check
flutter test         # Run unit tests
flutter build apk    # Generate APK
flutter clean        # Clean build files
```

---

## 📌 Notes

* This project is marked as private:

  ```yaml
  publish_to: 'none'
  ```
* Ensure your backend is reachable from:

  * Emulator (use `10.0.2.2` for localhost)
  * Physical device (use your system IP)

---

## 🌟 Future Improvements

* 📈 Nutritional breakdown (protein, carbs, fat)
* 🔐 User authentication
* ☁️ Cloud-based scan history sync
* 📊 Analytics dashboard
* 🌍 Multi-language support

---

## 🤝 Contribution

Contributions are welcome!
Feel free to fork the repo and submit a pull request.

---

## 📧 Contact

For queries or collaboration:

* GitHub Issues
* Developer: *Your Name*

---

## ⭐ If you like this project...

Give it a ⭐ on GitHub and share it!

---
