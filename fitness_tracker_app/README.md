# FitTrack - Advanced Fitness Tracker 🏋️‍♂️

[![Flutter](https://img.shields.io/badge/Flutter-v3.10.1-blue.svg?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-v3.0-blue.svg?logo=dart&logoColor=white)](https://dart.dev)
[![Supabase](https://img.shields.io/badge/Backend-Supabase-green.svg?logo=supabase&logoColor=white)](https://supabase.com)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

FitTrack is a comprehensive, production-grade fitness tracking application built with Flutter. It helps users monitor their physical activity, manage workouts, track nutrition, and visualize their progress with beautiful, interactive charts.

## ✨ Key Features

### 🏋️ Workout & Activity Tracking
- **Real-time Workout Monitor**: Track your active sessions with a live timer, set-by-set progress, and rep counting.
- **Custom Workout Builder**: Create personalized workout plans by choosing from a library of exercises or adding your own.
- **Pedometer Integration**: Automatic step counting using device sensors to track your daily movement.
- **Activity Logging**: Manually log various activities like running, swimming, or cycling with distance and calorie estimation.

### 📊 Comprehensive Analytics
- **Visual Progress Tracking**: Beautiful interactive charts (Line charts, Bar charts) powered by `fl_chart` to visualize your trends.
- **Health Metrics**: Monitor your BMI, body weight changes, and calorie deficit/surplus over time.
- **Goal Setting**: Set daily targets for steps, water intake, and calories, and track your achievement streaks.

### 🍎 Nutrition & Wellness
- **Meal Logger**: Detailed food logging system to keep track of your daily caloric intake and macronutrients.
- **Hydration Tracker**: Easy-to-use water intake logger with customizable reminders to stay hydrated.
- **Sleep Monitoring**: Record sleep duration and quality to analyze your recovery patterns.

### 🛠️ Advanced App Functionality
- **Seamless Cloud Sync**: Powered by Supabase, ensuring your fitness data is safely backed up and accessible on any device.
- **Smart Notifications**: Local notifications for workout reminders, hydration alerts, and goal milestones.
- **Dynamic Theme**: Full support for Dark and Light modes with a premium, modern aesthetic.
- **Multi-language Support**: Easily switch between languages within the app settings.

## 📱 App Screenshots

| Dashboard | Workout Builder | Analytics |
| :---: | :---: | :---: |
| ![Dashboard](https://via.placeholder.com/200x400?text=Dashboard) | ![Workout](https://via.placeholder.com/200x400?text=Workout+Builder) | ![Analytics](https://via.placeholder.com/200x400?text=Analytics) |

| Profile | Settings | Notifications |
| :---: | :---: | :---: |
| ![Profile](https://via.placeholder.com/200x400?text=Profile) | ![Settings](https://via.placeholder.com/200x400?text=Settings) | ![Notifications](https://via.placeholder.com/200x400?text=Notifications) |

> [!NOTE]
> *Replace the placeholder images above with your actual app screenshots by uploading them to an `assets/screenshots` folder in your repo.*

## 🛠️ Tech Stack

- **Frontend**: [Flutter](https://flutter.dev) (UI Framework)
- **State Management**: [Provider](https://pub.dev/packages/provider)
- **Backend**: [Supabase](https://supabase.com) (Auth, Database, Storage)
- **Navigation**: [Go Router](https://pub.dev/packages/go_router)
- **Charts**: [FL Chart](https://pub.dev/packages/fl_chart)
- **Animations**: [Lottie](https://pub.dev/packages/lottie), [Flutter Animate](https://pub.dev/packages/flutter_animate)
- **Icons**: [Lucide Icons](https://pub.dev/packages/lucide_icons)
- **Local Storage**: [Shared Preferences](https://pub.dev/packages/shared_preferences), [Flutter Secure Storage](https://pub.dev/packages/flutter_secure_storage)

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (v3.10.1 or higher)
- Android Studio / VS Code with Flutter extensions
- A Supabase Project

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/YourUsername/Fitness-Tracker-App.git
   cd Fitness-Tracker-App/fitness_tracker_app
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Configure Environment Variables:**
   Create a `.env` file or update your Supabase configuration in `lib/services/supabase_service.dart` (or wherever initialization happens):
   ```dart
   // Example configuration
   const SUPABASE_URL = 'https://your-project.supabase.co';
   const SUPABASE_ANON_KEY = 'your-anon-key';
   ```

4. **Run the app:**
   ```bash
   flutter run
   ```

## 📂 Project Structure

```text
lib/
├── models/      # Data models for Workouts, Users, etc.
├── providers/   # State management logic
├── screens/     # UI Pages (Dashboard, Analytics, etc.)
├── services/    # API and Third-party integrations
├── theme/       # App styling and colors
└── main.dart    # App entry point
```

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
