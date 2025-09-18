# 🎨 TEASE Frontend-Only Development

This is a **frontend-only** version of the TEASE bus booking app, perfect for UI/UX development and design work.

## ✨ What's Included

### 🎨 Enhanced Authentication Screens
- **Hi Screen** (`/hi`) - Initial entry point with email input
- **Enhanced Login** (`/enhanced-login`) - Modern login with teal theme
- **Enhanced Signup** (`/enhanced-signup`) - Comprehensive registration form
- **Auth Demo** (`/auth-demo`) - Demo screen to showcase all screens

### 🎨 Design Features
- **Dark Theme** with black background
- **Teal/Turquoise Color Scheme** matching the hero image
- **Hero Image Integration** - Beautiful woman with teal jacket
- **Smooth Animations** and transitions
- **Modern Typography** with Inter font
- **Responsive Design** using Sizer

### 🚫 What's Disabled (Frontend-Only)
- ❌ Backend API calls
- ❌ Real authentication
- ❌ Database connections
- ❌ Heavy packages (camera, connectivity, permissions)
- ❌ Network requests

## 🚀 Running the App

```bash
cd frontend
flutter clean
flutter pub get
flutter run
```

## 🎯 Current Setup

- **Initial Route**: `/auth-demo` (demo screen)
- **Navigation**: All screens navigate back to demo
- **Authentication**: Simulated with 2-second delays
- **Success Messages**: Show "(Demo)" to indicate frontend-only

## 🎨 Hero Image

Place your hero image at:
```
frontend/assets/images/NOBG-pexels-homie-visuals-2149299387-30534451.png
```

## 🎨 Color Scheme

- **Primary**: `#20B2AA` (Medium Turquoise)
- **Secondary**: `#0077B6` (Deep Blue)
- **Success**: `#20B2AA` (Same as primary)

## 📱 Testing the Screens

1. **Start with Demo Screen** - Shows all available screens
2. **Test Hi Screen** - Email input with social login options
3. **Test Login Screen** - Email/password with validation
4. **Test Signup Screen** - Full registration form

## 🔧 Customization

- **Colors**: Edit `frontend/lib/theme/app_theme.dart`
- **Animations**: Modify animation controllers in screen files
- **Layout**: Adjust spacing and sizing using Sizer
- **Typography**: Change fonts in Google Fonts imports

## 📝 Notes

- All authentication is **simulated** - no real backend calls
- Forms have **real validation** for UI testing
- Navigation works **between screens** only
- Perfect for **design iteration** and **UI development**

---

**Happy Frontend Development! 🎨✨**
