/// Build-time configuration. Never put secrets here: the app binary is public.
/// Pass values with: flutter run --dart-define-from-file=env/dev.json
abstract final class AppConfig {
  static const env = String.fromEnvironment('APP_ENV', defaultValue: 'dev');

  /// 10.0.2.2 reaches the host machine from the Android emulator.
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8080/api/v1',
  );

  static bool get isProd => env == 'prod';
}
