


# 🚨 Emergency Services App (MVP)  
A mobile application built for the **President Tech Award**. This app allows users to request emergency help (ambulance, police, fire) even when offline, and provides life-saving tutorials like CPR and allergy response.

---

## 🔧 Tech Stack
- **Frontend**: Flutter (Dart)
- **Backend**: Django REST Framework (handled by teammate)
- **State Management**: setState / Provider (MVP-level)
- **Storage**: SharedPreferences (for local cache)
- **Offline Support**: Built-in with SQLite and connectivity checks

---

## 📲 Features
- 🔐 User registration/login via phone or passport
- 🩺 Medical info storage (blood type, allergies, etc.)
- 📡 Request help online or offline (SMS fallback)
- 📚 Life-saving help topics available offline
- 📍 Location-aware emergency requests
- 🌐 Simple bottom nav UI: Home / Help / Settings

---

## 📁 Folder Structure
```

lib/
├── main.dart                   # Entry point & routing
├── screens/                   # UI screens
│   ├── splash\_screen.dart
│   ├── login\_screen.dart
│   ├── register\_screen.dart
│   ├── register\_medical\_screen.dart
│   ├── quick\_numbers\_screen.dart
│   ├── main\_screen.dart
│   ├── home\_screen.dart
│   ├── request\_help\_screen.dart
│   ├── help\_screen.dart
│   └── settings\_screen.dart
├── models/                    # User & emergency models
│   ├── user\_model.dart
│   └── emergency\_request.dart
├── services/                  # API, storage, connectivity
│   ├── api\_service.dart
│   ├── storage\_service.dart
│   └── connectivity\_service.dart
└── data/                      # Dummy and static data
├── dummy\_data.dart
└── help\_data.dart

````

---

## 🚀 Getting Started

### 1. Clone the repo:
```bash
git clone https://github.com/yourusername/emergency_services_app.git
cd emergency_services_app
````

### 2. Install dependencies:

```bash
flutter pub get
```

### 3. Run the app:

```bash
flutter run
```

> 🧪 Use `dummy_data.dart` to simulate server responses if backend isn't connected yet.

---

## 🧠 Author

Built with passion by Kamoliddin 💥
Backend: Teammate (Django Dev)
Part of President Tech Award 2025 submission

---

## 🛡 MVP Focus

✅ Simplicity
✅ Core functionality
✅ Realistic use in low-infrastructure areas
✅ Rapid deploy & test



