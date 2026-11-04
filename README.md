# Forge

Forge is a local-first code editor for Android, iOS, and Windows, built with Flutter.

## Features

- Edit text and source files in a device-local workspace. Edits save automatically, with `Ctrl+S` / `⌘S` also available on desktop.
- Create, import, export, and delete files. Imported files are copied into the app workspace.
- Use the editor offline. No account or cloud service is needed for local editing.
- On first launch, enter your own NVIDIA API key or continue offline and add it later in Settings. The key is stored with `flutter_secure_storage`: Android Keystore-backed encryption, Apple Keychain on iOS, and Windows Credential Manager on Windows. It is not stored in the project, preferences, or source control. AI requests go directly from the app to the configured provider.
- Use two-pass AI editing: Pass 1 sends a compact local project map and returns a plan plus file wishlist; review the steps, uncheck files, then start Pass 2. Only checked existing files are loaded for Pass 2. Proposed diffs stream into chat and are not applied automatically.
- Responsive workspace layout: split explorer/editor/assistant on desktop, drawer-based files and a mobile AI sheet on smaller screens.
- Select local GGUF files for the intent router (0.5B) and Pass 1 planner (1.5B on Android, 3B on Windows). The app auto-detects these filenames in the `model/` folder when launched from the project directory; Settings can also select a GGUF directly. Model weights stay local and are excluded from Git.
- Sign in from the Account page with GitHub through Supabase. Workspace manifests and file blobs sync on save and through the Realtime channel; conflicts are skipped and reported. The Account page can also push workspace files to a selected GitHub repository.

## Run on Windows

Install Flutter and Visual Studio with the Desktop development with C++ workload, then from this folder run:

```powershell
flutter pub get
Copy-Item supabase.local.example.json supabase.local.json
# Set your Supabase URL and publishable key in supabase.local.json.
flutter run -d windows --dart-define-from-file=supabase.local.json
```

To create a Windows release build:

```powershell
flutter build windows --release --dart-define-from-file=supabase.local.json
```

The built app is under `build/windows/x64/runner/Release/`.

## Run on Android

Install Flutter, Android Studio, and an Android SDK. Accept the SDK licenses once with `flutter doctor --android-licenses`, then run:

```powershell
flutter pub get
Copy-Item supabase.local.example.json supabase.local.json
# Set your Supabase URL and publishable key in supabase.local.json.
flutter run -d <device-id> --dart-define-from-file=supabase.local.json
```

Create a release APK with:

```powershell
flutter build apk --release --target-platform android-arm64 --dart-define-from-file=supabase.local.json
```

The APK is under `build/app/outputs/flutter-apk/app-release.apk`.

## Run on iOS

iOS builds require macOS, Xcode, and CocoaPods. From a Mac, run `flutter pub get`, then `flutter run -d <device-id>` or `flutter build ios --release`. The API key uses the Apple Keychain through `flutter_secure_storage`.

## Current scope

Files and editor state are stored locally under the app's documents directory. `supabase.local.json` contains the local Supabase URL and publishable key for developer builds; it is ignored by Git. Supabase session tokens use the device secure store. The publishable key is intended for client apps; never use a `service_role` or secret API key in a mobile or desktop client.

### Supabase and GitHub OAuth setup

1. Apply `supabase/migrations/20261104000000_forge_sync.sql` to the Supabase project.
2. In Supabase Dashboard, enable GitHub under Authentication → Providers and enter the GitHub OAuth App client ID and secret there. Do not put the GitHub OAuth client secret in the Flutter app; Supabase's GitHub sign-in flow uses the dashboard-configured provider.
3. Add `http://127.0.0.1:54321/auth/callback` to Supabase Auth's redirect URL allow list. The GitHub OAuth App callback URL remains the Supabase callback URL shown in your project.
4. Build with `--dart-define-from-file=supabase.local.json`, or enter the URL and publishable key in the Account page.

The migration must be applied and the GitHub provider enabled in the Supabase Dashboard before account login and sync can complete. First sync uploads local files; later syncs exchange changed files, and conflicting edits are left untouched for manual resolution. GitHub push uses the signed-in OAuth session and repository URL saved in Account. Android and Windows use a loopback browser callback; keep the redirect allow-list URL above exact.
