# PointBox Mobile App

A Flutter mobile application for managing loyalty points and rewards using GetX state management.

## Features

- ✅ Login and Sign Up
- ✅ Profile page with linked accounts, redeem points, and QR codes
- ✅ Redeem points functionality
- ✅ Currency conversion (KWD to USD)
- ✅ Transaction history
- ✅ Contact support via email
- ✅ Promotional banners
- ✅ Brands list with linking capability
- ✅ Logout and Delete Account
- ✅ Multi-language support (Arabic and English)
- ✅ Responsive design with purple gradient theme

## Getting Started

### Prerequisites

- Flutter SDK (>=3.0.0)
- Dart SDK

### Installation

1. Clone the repository
2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

## Project Structure

```
lib/
├── app/
│   ├── modules/
│   │   ├── auth/          # Authentication (Login/Signup)
│   │   ├── home/           # Home screen
│   │   ├── profile/        # Profile and QR code
│   │   ├── redeem/         # Redeem points
│   │   ├── conversion/     # Currency conversion
│   │   ├── transactions/   # Transaction history
│   │   ├── support/        # Contact support
│   │   └── brands/         # Brands list
│   ├── routes/             # App routing
│   ├── services/           # Services (Storage, Localization, Theme)
│   ├── translations/       # Language translations
│   └── widgets/            # Reusable widgets
└── main.dart
```

## Dependencies

- `get`: State management and routing
- `shared_preferences`: Local storage
- `qr_flutter`: QR code generation
- `url_launcher`: Email support
- `intl`: Date formatting
- `flutter_localizations`: Multi-language support

## Color Scheme

The app uses a purple gradient theme:
- Purple 600: `#9333EA`
- Purple 700: `#7E22CE`
- Indigo 800: `#4F46E5`

## License

This project is licensed under the MIT License.

