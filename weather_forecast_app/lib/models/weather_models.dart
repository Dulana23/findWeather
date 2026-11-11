/// Current weather conditions for a city.
class CurrentWeather {
  final String city;
  final String country;
  final double temperature; // °C
  final int humidity; // %
  final double windSpeed; // km/h
  final String description;
  final String iconCode; // OpenWeather icon code, e.g. "10d"

  const CurrentWeather({
    required this.city,
    required this.country,
    required this.temperature,
    required this.humidity,
    required this.windSpeed,
    required this.description,
    required this.iconCode,
  });
}

/// One 3-hour forecast entry.
class ForecastEntry {
  final DateTime time; // city-local time
  final double temperature;
  final String description;
  final String iconCode;

  const ForecastEntry({
    required this.time,
    required this.temperature,
    required this.description,
    required this.iconCode,
  });
}

/// One day in the 5-day forecast.
class DailyForecast {
  final DateTime date;
  final double minTemp;
  final double maxTemp;
  final String description;
  final String iconCode;

  const DailyForecast({
    required this.date,
    required this.minTemp,
    required this.maxTemp,
    required this.description,
    required this.iconCode,
  });
}

/// Everything returned for one search.
class WeatherData {
  final CurrentWeather current;
  final List<ForecastEntry> hourly;
  final List<DailyForecast> daily;

  const WeatherData({
    required this.current,
    required this.hourly,
    required this.daily,
  });
}
