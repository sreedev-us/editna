# Forge

Forge is a local-first code editor for Android, iOS, and Windows, built with Flutter.

## Features

- Edit text and source files in a device-local workspace. Edits save automatically, with `Ctrl+S` / `⌘S` also available on desktop.
- Create, import, export, and delete files. Imported files are copied into the app workspace.
- Use the editor offline. No account or cloud service is needed for local editing.
- On first launch, enter your own NVIDIA API key or continue offline and add it later in Settings. The key is stored with `flutter_secure_storage`: Android Keystore-backed encryption, Apple Keychain on iOS, and Windows Credential Manager on Windows. It is not stored in the project, preferences, or source control. AI requests go directly from the app to the configured provider.
- Use two-pass AI editing: Pass 1 sends a compact local project map and returns a plan plus file wishlist; review the steps, uncheck files, then start Pass 2. Only checked existing files are loaded for Pass 2. Proposed diffs stream into chat and are not applied automatically.
- Responsive workspace layout: split explorer/editor/assistant on desktop, drawer-based files and a mobile AI sheet on smaller screens.

## Run on Windows

Install Flutter and Visual Studio with the Desktop development with C++ workload, then from this folder run:

```powershell
flutter pub get
flutter run -d windows
```

To create a Windows release build:

```powershell
flutter build windows --release
```

The built app is under `build/windows/x64/runner/Release/`.

## Run on Android

Install Flutter, Android Studio, and an Android SDK. Accept the SDK licenses once with `flutter doctor --android-licenses`, then run:

```powershell
flutter pub get
flutter run -d <device-id>
```

Create a release APK with:

```powershell
flutter build apk --release
```

The APK is under `build/app/outputs/flutter-apk/app-release.apk`.

## Run on iOS

iOS builds require macOS, Xcode, and CocoaPods. From a Mac, run `flutter pub get`, then `flutter run -d <device-id>` or `flutter build ios --release`. The API key uses the Apple Keychain through `flutter_secure_storage`.

## Current scope

Files and editor state are stored locally under the app's documents directory. Cross-device sync, a bundled on-device language model, syntax highlighting, and applying AI patches are not implemented yet. Automatic AI routing currently uses lightweight keyword rules; it is not an on-device SLM. Provider model IDs can change or require account access, so check availability with your provider.
