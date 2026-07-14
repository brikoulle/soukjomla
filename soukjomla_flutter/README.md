# SoukJomla Flutter App

B2B marketplace mobile app for connecting buyers and sellers in Morocco.

## Project Structure

```
lib/
├── config/              # Configuration & theme
│   ├── app_config.dart
│   └── design_system.dart
├── models/              # Data models
├── screens/             # UI screens
├── services/            # API & business logic
├── widgets/             # Reusable UI components
├── utils/               # Utilities (error handling, logging)
└── main.dart            # Entry point
```

## Environment Configuration

### Development
```bash
flutter run \
  --dart-define=FLAVOR=development \
  --dart-define=ENVIRONMENT=development \
  --dart-define=API_BASE_URL=http://localhost:8000
```

### Staging
```bash
flutter run \
  --dart-define=FLAVOR=staging \
  --dart-define=ENVIRONMENT=staging \
  --dart-define=API_BASE_URL=https://staging-api.soukjomla.ma
```

### Production
```bash
flutter run \
  --dart-define=FLAVOR=production \
  --dart-define=ENVIRONMENT=production \
  --dart-define=API_BASE_URL=https://api.soukjomla.ma
```

## Building for Release

See [RELEASE.md](RELEASE.md) for detailed instructions on:
- Generating keystore
- Building APK & App Bundle
- Signing & uploading to Play Store
- Managing versions and releases

## Dependencies

- **State Management**: Provider
- **HTTP**: Dio
- **UI**: Flutter Material 3
- **Image Handling**: image_picker, cached_network_image
- **Splash Screen**: flutter_native_splash
- **App Icons**: flutter_launcher_icons
- **Pagination**: infinite_scroll_pagination
- **WebSocket**: web_socket_channel
- **Analytics**: Firebase

## Design System

- **Primary Color**: Indigo (#22335C)
- **Accent Color**: Saffron (#DFA426)
- **Fonts**: Outfit (primary), Inter (secondary)
- **Language**: Arabic (RTL)

## Getting Started

```bash
# Install dependencies
flutter pub get

# Generate necessary code
flutter pub run build_runner build

# Run app in development
flutter run --dart-define=ENVIRONMENT=development
```

## Testing

```bash
# Run unit tests
flutter test

# Run widget tests
flutter test test/

# Run integration tests
flutter drive --target=test_driver/app.dart
```

## API Integration

API client automatically:
- Handles JWT token attachment
- Manages token refresh on 401
- Provides user-friendly error messages
- Supports pagination
- Has configurable base URL per environment

## Troubleshooting

### Build fails
```bash
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

### Permissions issues
- Check `android/app/src/main/AndroidManifest.xml` for required permissions
- Check iOS `Info.plist` for required keys

### Image picker not working
- Android: Grant CAMERA and STORAGE permissions
- iOS: Add camera/photo usage descriptions in Info.plist

## Release Checklist

- [ ] All features tested
- [ ] No debug prints or TODOs
- [ ] Error handling complete
- [ ] Version bumped in pubspec.yaml
- [ ] All permissions documented
- [ ] Screenshots prepared for store
- [ ] Privacy policy finalized
- [ ] Backend API URLs configured

See [RELEASE.md](RELEASE.md) for full release guide.
