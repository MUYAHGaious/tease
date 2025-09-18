# TEASE - Smart Bus Booking Platform

A modern, AI-powered Flutter application for seamless bus ticket booking and tracking. Built with cutting-edge technology to provide users with an intuitive and professional booking experience.

*This project was built with AI assistance to demonstrate modern mobile app development capabilities.*

## 🚀 Features

- **Smart Search & Booking**: Intelligent bus search with real-time availability
- **Live Bus Tracking**: Real-time GPS tracking with ETA predictions
- **Voice AI Assistant**: Professional voice-enabled booking assistance
- **Premium UI/UX**: Modern, responsive design with smooth animations
- **Secure Payments**: Integrated payment gateway with multiple options
- **QR Ticketing**: Digital tickets with QR codes for easy boarding
- **Multi-Platform**: Optimized for Android, iOS, and Web

## 🛠️ Technology Stack

- **Frontend**: Flutter 3.24+ with Dart
- **State Management**: Provider & Riverpod
- **UI/UX**: Custom widgets with Material 3 design
- **Maps**: Google Maps integration for tracking
- **Animations**: Lottie animations and custom transitions
- **Architecture**: Clean architecture with MVVM pattern

## 📱 Screenshots

The app features a professional interface with:
- Onboarding flow with smooth animations
- Dashboard with quick actions and recent bookings
- Advanced search with filters and sorting
- Seat selection with interactive bus layout
- Real-time tracking with live updates
- Secure payment processing

## 🏗️ Project Structure

```
lib/
├── core/                 # Core utilities and configurations
├── presentation/         # UI screens and widgets
│   ├── auth/            # Authentication screens
│   ├── home_dashboard/  # Main dashboard
│   ├── search_booking/  # Search and booking flow
│   ├── bus_tracking_map/ # Live tracking
│   ├── payment_gateway/ # Payment processing
│   └── ...
├── routes/              # App navigation
├── theme/               # UI theming
└── widgets/             # Reusable components
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.24+
- Dart 3.0+
- Android Studio / VS Code
- Android/iOS device or emulator

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd tease_new/frontend
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

### Building for Release

**Android APK:**
```bash
flutter build apk --release
```

**iOS:**
```bash
flutter build ios --release
```

**Web:**
```bash
flutter build web --release
```

## 🔧 Configuration

- **Maps API**: Add your Google Maps API key in `android/app/src/main/AndroidManifest.xml`
- **Firebase**: Configure Firebase for analytics and push notifications
- **Payment**: Set up payment gateway credentials

## 🚀 Deployment

The app is optimized for:
- **Mobile**: Android (API 21+) and iOS (12+)
- **Performance**: Optimized for low-end devices
- **Release**: ProGuard rules configured for APK optimization

## 🧪 Testing

```bash
flutter test                    # Unit tests
flutter integration_test        # Integration tests
flutter analyze                 # Code analysis
```

## 📝 Development Notes

- **Architecture**: Follows clean architecture principles
- **Performance**: Optimized for mobile with conservative resource usage
- **State Management**: Proper lifecycle management with mounted checks
- **Error Handling**: Comprehensive error handling for production stability

## 🤝 Contributing

This project demonstrates modern Flutter development practices including:
- Industry-standard architecture patterns
- Professional UI/UX design principles
- Performance optimization techniques
- Production-ready code quality

## 📄 License

This project is developed for demonstration purposes and showcases modern mobile app development capabilities.

---

*Built with Flutter ❤️ and AI assistance*
