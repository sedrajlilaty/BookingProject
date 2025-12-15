# Technology Stack

## Framework & Language
- **Flutter**: Cross-platform mobile/desktop framework
- **Dart**: Programming language (SDK ^3.7.0)
- **Material Design**: UI component library

## Dependencies

### Core Dependencies
- **flutter**: Flutter SDK framework
- **cupertino_icons**: ^1.0.8 - iOS-style icons
- **image_picker**: ^1.2.1 - Camera and gallery image selection
- **intl**: ^0.19.0 - Internationalization and localization support

### Development Dependencies
- **flutter_test**: Flutter testing framework
- **flutter_lints**: ^5.0.0 - Dart code linting and best practices

## Platform Support
- **Android**: Full native Android support with Gradle build system
- **iOS**: Native iOS support with Xcode project configuration
- **Windows**: Desktop Windows application support
- **Linux**: Desktop Linux application support  
- **macOS**: Desktop macOS application support
- **Web**: Progressive Web App (PWA) support

## Build Configuration

### Android
- **Gradle**: Build system with Kotlin DSL
- **Target SDK**: Modern Android versions
- **Architecture**: Supports arm64-v8a, armeabi-v7a, x86, x86_64

### iOS
- **Xcode**: Native iOS build system
- **Swift**: Native iOS code integration
- **Universal**: Supports iPhone and iPad

### Desktop Platforms
- **CMake**: Build system for Windows, Linux, macOS
- **Native Integration**: Platform-specific window management

## Development Commands

### Essential Commands
```bash
# Install dependencies
flutter pub get

# Run on connected device
flutter run

# Build for production
flutter build apk          # Android
flutter build ios          # iOS  
flutter build windows      # Windows
flutter build web          # Web

# Run tests
flutter test

# Analyze code
flutter analyze

# Clean build artifacts
flutter clean
```

### Development Workflow
```bash
# Hot reload during development
flutter run --hot

# Debug mode with detailed logging
flutter run --debug

# Profile mode for performance testing
flutter run --profile

# Release mode for production testing
flutter run --release
```

## Asset Management
- **Images**: Stored in `images/` directory
- **Icons**: Platform-specific icon sets for all supported platforms
- **Fonts**: Material Design fonts with Arabic language support

## Code Quality
- **Linting**: flutter_lints package for code quality enforcement
- **Analysis**: Static analysis with analysis_options.yaml configuration
- **Testing**: Widget and unit testing framework integration