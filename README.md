# Phone Monitoring App

A Flutter application that monitors phone activities and logs them to Firebase.

## Features

-   **Battery Monitoring**: Logs when battery drops below 15%
-   **Network Monitoring**: Logs when device disconnects from network
-   **App Usage Monitoring** (Android only): Logs when unwanted apps (Instagram, TikTok, YouTube) are opened

## Setup Instructions

### 1. Firebase Setup

1. Create a new Firebase project at [Firebase Console](https://console.firebase.google.com/)
2. Add Android and iOS apps to your Firebase project
3. Download and add the `google-services.json` file to `android/app/`
4. Download and add the `GoogleService-Info.plist` file to `ios/Runner/`
5. Enable Cloud Firestore in your Firebase project

### 2. Android Setup

Additional steps for Android:

1. For app usage monitoring, users need to grant the "Usage Access" permission manually:
    - Go to Settings > Security > Apps with usage access
    - Find the app and toggle the permission on

### 3. Build and Run

```bash
flutter pub get
flutter run
```

## How It Works

-   The app runs monitoring services in both foreground and background
-   Background monitoring uses WorkManager to run periodic checks
-   All events are logged to Firebase Cloud Firestore in the `monitoring_logs` collection

## Required Permissions

-   Internet access
-   Network state access
-   Battery stats
-   Package usage stats (Android only)
-   Foreground service
-   Boot completed receiver

## Log Format

### Battery Low Event

```json
{
    "event": "Battery Low",
    "batteryLevel": 12,
    "timestamp": "2025-06-09T13:00:00"
}
```

### Network Disconnected Event

```json
{
    "event": "Network Disconnected",
    "timestamp": "2025-06-09T13:01:00"
}
```

### Unwanted App Opened Event

```json
{
    "event": "Unwanted App Opened",
    "appName": "TikTok",
    "timestamp": "2025-06-09T13:02:00"
}
```
