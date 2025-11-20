# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is ReflectFlutter - a zen reflection app with interactive moments built in Flutter. The app focuses on mindfulness, mood tracking, goal setting, and analytics. It's a Spanish-language app ("Una app de reflexión zen y momentos interactivos") with comprehensive wellness tracking features.

## Key Technologies

- **Flutter SDK**: >=3.0.0 <4.0.0
- **Database**: SQLite via sqflite
- **Architecture**: Provider pattern with dependency injection (GetIt)
- **Platforms**: Android, iOS, macOS, Linux, Windows, Web

## Development Commands

### Build and Run
```bash
flutter clean
flutter pub get
flutter run
```

### Code Quality
```bash
flutter analyze
flutter test
dart format .
```

### Code Generation
```bash
dart run build_runner build --delete-conflicting-outputs
```

### Icon Generation
```bash
flutter pub run flutter_launcher_icons
```

## Project Architecture

### Core Architecture Pattern
The app uses a clean architecture with:
- **Dependency Injection**: Centralized in `injection_container_clean.dart`
- **State Management**: Provider pattern with optimized providers
- **Database Layer**: SQLite with optimized services
- **Data Models**: JSON serializable models with code generation

### Key Entry Points
- `main.dart` - App initialization with dependency injection and critical services setup
- `optimized_reflect_app.dart` - Main app widget with MultiProvider setup and routing
- `injection_container_clean.dart` - Complete dependency injection configuration

### Directory Structure
- `lib/core/themes/` - App theming system
- `lib/data/models/` - Data models with JSON serialization
- `lib/data/services/` - Database and external services
- `lib/presentation/providers/` - State management providers
- `lib/presentation/screens/` - UI screens organized by version (v2, v3, v4)
- `lib/presentation/widgets/` - Reusable UI components
- `lib/services/` - App services (notifications, voice recording)
- `lib/test_data/` - Test data generation system

### Screen Organization
Screens are versioned (v2, v3, v4) indicating iterative improvements:
- **v2**: Core screens (home, profile, analytics, etc.)
- **v3**: Enhanced features (roadmap screens)
- **v4**: Latest analytics implementations

### Provider System
The app uses a comprehensive provider system with:
- **Core Providers**: Auth, Theme, Database-dependent providers
- **Analytics Providers**: Multiple versions (v3, v4) with different capabilities
- **Specialized Providers**: Goals, Activities, Moments, Challenges, Streaks

## Database System

### Services
- `OptimizedDatabaseService` - Main database operations
- `AnalyticsConfigService` - Dynamic analytics configuration
- Multiple specialized services for different data types

### Models with Code Generation
Most models use JSON serialization:
```dart
// Generate code after model changes
dart run build_runner build --delete-conflicting-outputs
```

### Analytics System
Sophisticated analytics system with:
- **Configurable Analytics**: Dynamic configuration system (see `ANALYTICS_CONFIG_README.md`)
- **Multiple Versions**: v3 and v4 implementations with different features
- **Wellness Scoring**: Configurable component weights and thresholds
- **Correlation Analysis**: Dynamic correlation thresholds and significance testing

## Critical Services

### Notification System
- Local notifications with timezone support
- Default reminder setup during app initialization
- Configured in `services/notification_service.dart`

### Voice Recording
- Audio recording and playback capabilities
- Permission handling included
- Service initialized during app startup

### Image Handling
- Image picker service for user photos
- Photo moment creation and management

## Testing System

Located in `lib/test_data/`:
- **Simple Test Data**: Use `simple_test_data.dart` for quick UI testing
- **Specialized Generators**: Goals, analytics, and timeline data
- **Database Integration**: Available but requires method signature updates

## Development Notes

### Dependency Management
All dependencies are registered in `injection_container_clean.dart`. Services are singletons, providers are factories to avoid state issues during hot restarts.

### Error Handling
The app includes comprehensive error handling with fallback UI (`ErrorApp`) if initialization fails.

### Logging
Comprehensive logging system using the `logger` package with different configurations for development, production, and testing.

### Hot Restart Considerations
Providers are registered as factories rather than singletons to prevent state issues during development.

### Multi-Platform Support
The app is configured for all Flutter platforms with appropriate native configurations for each platform.

## Common Patterns

### Provider Usage
```dart
// Providers are auto-loaded when user authenticates
final provider = Provider.of<SomeProvider>(context, listen: false);
```

### Database Operations
```dart
// All database operations go through OptimizedDatabaseService
final dbService = sl<OptimizedDatabaseService>();
```

### Configuration Access
```dart
// Analytics configurations are dynamically loaded
final config = await configService.getConfigForUser(userId);
```