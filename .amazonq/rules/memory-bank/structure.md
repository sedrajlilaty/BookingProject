# Project Structure

## Directory Organization

### Core Application (`lib/`)
- **main.dart**: Application entry point with MaterialApp configuration
- **SplashScreen.dart**: Initial loading screen with app branding
- **welcome_screen.dart** & **welcomeScreen2.dart**: Onboarding screens
- **logIn.dart** & **signUp.dart**: Authentication screens
- **main_navigation.dart** & **main_navigation_screen.dart**: Navigation management

### Feature Modules
- **homePage.dart**: Main apartment browsing interface with search/filter
- **AppartementDetails.dart**: Detailed apartment view and booking
- **AddApartement.dart**: Add new apartment listings
- **favorateScreen.dart**: Manage favorite apartments
- **myBookingScreen.dart**: User booking history
- **fullbookingPage.dart**: Complete booking process
- **profile.dart** & **EditProfileScreen.dart**: User profile management
- **doneAdd.dart**: Confirmation screen for adding apartments

### UI Components
- **customButtomNavigation.dart**: Custom bottom navigation bar
- **buildEndDrower.dart**: Side drawer menu implementation
- **constants.dart**: App-wide constants and theme definitions

### Platform-Specific Code
- **android/**: Android platform configuration and native code
- **ios/**: iOS platform configuration and native code  
- **windows/**: Windows desktop platform support
- **linux/**: Linux desktop platform support
- **macos/**: macOS desktop platform support
- **web/**: Web platform assets and configuration

### Assets & Resources
- **images/**: Application images (crown_logo.png, logo.png)
- **test/**: Widget and unit tests

## Architectural Patterns

### State Management
- Uses StatefulWidget pattern for local state management
- Implements setState() for UI updates and reactive programming

### Navigation Architecture
- MaterialPageRoute for screen transitions
- Custom navigation wrapper for consistent routing
- Drawer-based side navigation for secondary features

### UI Architecture
- Material Design components throughout the app
- Responsive grid layouts for apartment listings
- Custom themed components with dark/light mode support
- Multilingual UI with dynamic text switching

### Data Architecture
- Local data structures for apartment information
- Mock data implementation (ready for API integration)
- Filter and search logic implemented in presentation layer

## Core Components

### Main Navigation Flow
1. SplashScreen → Welcome Screens → Authentication → Home
2. Bottom navigation between main features
3. Side drawer for additional functionality

### Feature Integration
- Search and filter system integrated into home screen
- Booking flow connects multiple screens
- Profile management accessible from navigation drawer
- Favorites system integrated across apartment views