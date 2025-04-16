class AppConfig {
  // API Configuration
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3000',
  );
  
  static const int apiTimeoutSeconds = int.fromEnvironment(
    'API_TIMEOUT_SECONDS',
    defaultValue: 30,
  );

  // Cache Configuration
  static const int cacheExpirationHours = int.fromEnvironment(
    'CACHE_EXPIRATION_HOURS',
    defaultValue: 24,
  );

  // Feature Flags
  static const bool enableOfflineMode = bool.fromEnvironment(
    'ENABLE_OFFLINE_MODE',
    defaultValue: true,
  );

  static const bool enableAnalytics = bool.fromEnvironment(
    'ENABLE_ANALYTICS',
    defaultValue: false,
  );

  // Security
  static const int maxLoginAttempts = int.fromEnvironment(
    'MAX_LOGIN_ATTEMPTS',
    defaultValue: 3,
  );

  static const int sessionTimeoutMinutes = int.fromEnvironment(
    'SESSION_TIMEOUT_MINUTES',
    defaultValue: 30,
  );

  // UI Configuration
  static const bool enableDarkMode = bool.fromEnvironment(
    'ENABLE_DARK_MODE',
    defaultValue: false,
  );

  static const String defaultLocale = String.fromEnvironment(
    'DEFAULT_LOCALE',
    defaultValue: 'de_DE',
  );

  // Get duration for cache expiration
  static Duration get cacheExpirationDuration => 
      Duration(hours: cacheExpirationHours);

  // Get duration for API timeout
  static Duration get apiTimeoutDuration => 
      Duration(seconds: apiTimeoutSeconds);

  // Get duration for session timeout
  static Duration get sessionTimeoutDuration => 
      Duration(minutes: sessionTimeoutMinutes);
} 