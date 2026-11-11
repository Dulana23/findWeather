/// OpenWeather API configuration.

class ApiConfig {
  static const String apiKey = String.fromEnvironment(
    'OPENWEATHER_API_KEY',
    defaultValue: '789c17f2d811905349e0fd674b20406a',
  );

  static const String baseHost = 'api.openweathermap.org';
  static const String currentPath = '/data/2.5/weather';
  static const String forecastPath = '/data/2.5/forecast';

  static bool get hasKey => apiKey.isNotEmpty && apiKey != 'YOUR_API_KEY_HERE';
}
