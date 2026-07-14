class AppConfig {
  // Build flavor - set via --dart-define at build time
  static const String flavor = String.fromEnvironment(
    'FLAVOR',
    defaultValue: 'development',
  );

  // API Base URL - switches per environment
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8000',
  );

  static const String environment = String.fromEnvironment(
    'ENVIRONMENT',
    defaultValue: 'development',
  );

  static const bool isDevelopment = environment == 'development';
  static const bool isProduction = environment == 'production';
  static const bool isStaging = environment == 'staging';

  // App Info
  static const String appName = 'SoukJomla';
  static const String packageName = 'com.soukjomla.app';
  static const String appVersion = '1.0.0';
  static const int appBuildNumber = 1;

  // Feature Flags
  static const bool enableLogging = isDevelopment;
  static const bool enableCrashReporting = isProduction || isStaging;
  static const bool enableAnalytics = isProduction || isStaging;

  // Timeouts
  static const int connectTimeoutMs = 30000; // 30 seconds
  static const int receiveTimeoutMs = 30000; // 30 seconds
  static const int sendTimeoutMs = 30000; // 30 seconds

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Retry policy
  static const int maxRetries = 3;
  static const int retryDelayMs = 1000;

  // Environment info string for debugging
  static String get environmentInfo => 
    'Flavor: $flavor | Env: $environment | API: $apiBaseUrl';
}
