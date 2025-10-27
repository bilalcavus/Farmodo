# Pomodoro Timer : Focus & Farm 🌾⏱️

Pomodoro Timer : Focus & Farm is a unique productivity application that combines the Pomodoro Technique with farm simulation to make time management fun and rewarding.

## 📱 About

FarmoPomodoro Timer : Focus & Farm transforms your productivity journey into an engaging experience. Complete tasks using the Pomodoro technique, earn XP, and use your rewards to feed and grow your virtual farm animals. The more productive you are, the more your farm flourishes!

## ✨ Features

### 🎯 Task Management
- Create and organize your daily tasks
- Set custom Pomodoro durations for each task
- Track task completion and history
- Visual progress indicators

### ⏱️ Pomodoro Timer
- Customizable work and break intervals
- Full-screen timer mode for better focus
- Background timer with notifications
- Sound alerts for completed sessions
- Home screen widget support (Android & iOS)

### 🐄 Farm Simulation
- Build and manage your virtual farm
- Unlock different farm animals as you progress
- Feed your animals with earned rewards
- Interactive 2D farm view with real-time updates
- Watch your farm grow with your productivity

### 🏆 Gamification System
- Earn XP for completed Pomodoro sessions
- Level up system with visual progression
- Unlock achievements and badges
- Quest system with daily and weekly challenges
- Reward store to purchase farm upgrades

### 📊 Leaderboard & Competition
- Global leaderboard rankings
- Compete in multiple categories:
  - Total XP earned
  - Pomodoro sessions completed
  - Level achievements
- Track your progress against other users

### 🎨 User Experience
- Modern and intuitive UI/UX design
- Dark and Light theme support
- Smooth animations and transitions
- Custom Inter font family
- Responsive design for all screen sizes

### 🔔 Notifications & Widgets
- Local notifications for timer events
- Home screen widgets (iOS & Android)
- Live Activities support (iOS)
- Background service for uninterrupted timing

## 🛠️ Technical Stack

### Framework & Language
- **Flutter** (3.8.1+) - Cross-platform development
- **Dart** - Programming language
- **GetX** - State management and routing

### Backend & Database
- **Firebase Authentication** - User authentication (Email, Google, Apple Sign-In)
- **Cloud Firestore** - Real-time database
- **Firebase Core** - Firebase integration
- **SQLite** - Local database storage

### Key Dependencies
- `flame` - 2D game engine for farm simulation
- `lottie` - Animations
- `home_widget` - Widget support
- `live_activities` - iOS Live Activities
- `flutter_local_notifications` - Push notifications
- `audioplayers` - Sound effects
- `percent_indicator` - Progress indicators
- `shared_preferences` - Local storage

## 🚀 Getting Started

### Prerequisites

- Flutter SDK 3.8.1 or higher
- Dart SDK 3.8.1 or higher
- Firebase account and project setup
- Android Studio / Xcode for platform-specific builds
- iOS development requires macOS with Xcode installed

### Installation

1. **Clone the repository**
```bash
git clone <repository-url>
cd Pomodoro Timer : Focus & Farm
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Firebase Setup**
- Create a new Firebase project
- Add Android and iOS apps to your Firebase project
- Download and place `google-services.json` in `android/app/`
- Download and place `GoogleService-Info.plist` in `ios/Runner/`
- Update `firebase_options.dart` with your configuration

4. **iOS specific setup**
```bash
cd ios
pod install
cd ..
```

5. **Run the app**
```bash
flutter run
```

### Build for Release

**Android:**
```bash
flutter build apk --release
# or
flutter build appbundle --release
```

**iOS:**
```bash
flutter build ios --release
```

## 📂 Project Structure

```
lib/
├── core/              # Core utilities and services
│   ├── di/           # Dependency injection
│   ├── init/         # App initialization
│   ├── services/     # Services (notifications, etc.)
│   └── theme/        # Theme configuration
├── data/             # Data models and repositories
├── feature/          # Feature modules
│   ├── auth/        # Authentication
│   ├── farm/        # Farm simulation
│   ├── gamification/ # XP, achievements, quests
│   ├── home/        # Home screen with timer
│   ├── leader_board/ # Leaderboards
│   ├── store/       # Reward store
│   └── tasks/       # Task management
└── main.dart        # App entry point
```

## 🎮 How to Play

1. **Create Tasks**: Add your daily tasks and set Pomodoro durations
2. **Start Timer**: Begin a Pomodoro session for focused work
3. **Earn Rewards**: Complete sessions to earn XP and coins
4. **Feed Animals**: Use your rewards to feed and unlock farm animals
5. **Level Up**: Gain levels and unlock new features
6. **Compete**: Check the leaderboard to see your ranking

## 📱 Platform Support

- ✅ Android (API 21+)
- ✅ iOS (13.0+)
- ⚠️ Web (Limited functionality)
- ⚠️ macOS (Limited functionality)
- ⚠️ Linux (Limited functionality)
- ⚠️ Windows (Limited functionality)

*Note: Primary focus is on Android and iOS platforms*

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🔄 Version

**Current Version:** v1.3.0

## 👨‍💻 Author

Developed by Bilal Cavus

---

*Stay productive, grow your farm! 🌾*