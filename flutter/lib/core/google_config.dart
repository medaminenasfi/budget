/// Google Sign-In on **Chrome / web only**.
///
/// 1. Open https://console.cloud.google.com/
/// 2. Create (or pick) a project
/// 3. APIs & Services → Credentials → Create credentials → OAuth client ID
/// 4. Application type: **Web application**
/// 5. Authorized JavaScript origins:
///    - http://localhost
///    - http://localhost:port   (use the port from `flutter run -d chrome`)
/// 6. Create, copy the Client ID (ends with `.apps.googleusercontent.com`)
/// 7. Paste it between the quotes below, then hot restart
///
/// Android and iPhone do **not** use this file. They use the app package name
/// and SHA-1 in an Android OAuth client instead.
const String kGoogleWebClientId = '';
