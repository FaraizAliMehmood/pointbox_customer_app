# PointBox Mobile App - Setup Guide

## Quick Start

1. **Install Flutter dependencies:**
   ```bash
   flutter pub get
   ```

2. **Run the app:**
   ```bash
   flutter run
   ```

## Features Implemented

✅ **Authentication**
- Login with email and password
- Sign up with name, email, phone, and password
- Password visibility toggle
- Form validation

✅ **Profile Page**
- User information display
- Total points counter
- Linked accounts list
- QR code generation and display
- Language switcher (Arabic/English)
- Logout functionality
- Delete account with confirmation

✅ **Redeem Points**
- Available points display
- Points redemption form
- Validation and error handling

✅ **Conversion Rate**
- KWD to USD conversion
- Real-time rate display
- Currency conversion calculator

✅ **Transaction History**
- List of all transactions
- Transaction types (Earned/Redeemed)
- Date formatting
- Pull to refresh

✅ **Contact Support**
- Email form (subject and message)
- Opens default email client
- Pre-filled with user email

✅ **Promotional Banners**
- Horizontal scrolling banners on home screen
- Gradient design

✅ **Brands List**
- Search functionality
- Brand linking capability
- Points rate display
- Linked status indicator

✅ **Multi-Language Support**
- English (default)
- Arabic (RTL support)
- Language switcher in profile

✅ **Design**
- Purple gradient theme (purple-600 → purple-700 → indigo-800)
- Responsive layout
- Modern Material Design 3
- Smooth animations

## Project Structure

```
lib/
├── app/
│   ├── modules/          # Feature modules
│   │   ├── auth/        # Login & Signup
│   │   ├── home/        # Home screen
│   │   ├── profile/     # Profile & QR
│   │   ├── redeem/      # Redeem points
│   │   ├── conversion/  # Currency conversion
│   │   ├── transactions/# Transaction history
│   │   ├── support/     # Contact support
│   │   └── brands/      # Brands list
│   ├── routes/          # App routing
│   ├── services/        # Services (Storage, Localization, Theme)
│   ├── translations/    # Language files
│   └── widgets/         # Reusable widgets
└── main.dart
```

## State Management

The app uses **GetX** for:
- State management (Rx variables)
- Dependency injection (Bindings)
- Navigation (Get.toNamed, Get.back)
- Localization (Get.tr)
- Snackbars and dialogs

## Storage

User data is stored locally using **SharedPreferences**:
- Login status
- User email, name, phone
- Total points
- Language preference

## Next Steps

1. Connect to a real backend API
2. Implement actual authentication
3. Add image assets for brands
4. Implement QR code scanning
5. Add push notifications
6. Implement real-time conversion rates API

## Notes

- All API calls are currently simulated with delays
- Brand logos are placeholder icons
- QR code data format: `pointbox://user/{email}`
- Support email: `support@pointbox.com` (configurable)

