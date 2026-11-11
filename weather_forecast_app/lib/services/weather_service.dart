import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/weather_models.dart';

/// Base class for all errors shown to the user.
class WeatherException implements Exception {
  final String message;
  const WeatherException(this.message);

  @override
  String toString() => message;
}

class CityNotFoundException extends WeatherException {
  const CityNotFoundException(String city)
      : super('City "$city" was not found. Please check the spelling.');
}

class NoInternetException extends WeatherException {
  const NoInternetException()
      : super('No internet connection. Please check your network.');
}

class ApiException extends WeatherException {
  const ApiException(super.message);
}

/// Talks to the OpenWeather API (current weather + 5-day / 3-hour forecast).
class WeatherService {
  static const _timeout = Duration(seconds: 12);

  final http.Client _client;
  WeatherService({http.Client? client}) : _client = client ?? http.Client();

  Future<WeatherData> getWeatherForCity(String city) async {
    final query = city.trim();
    if (query.isEmpty) {
      throw const WeatherException('Please enter a city name.');
    }
    if (!ApiConfig.hasKey) {
      throw const ApiException(
          'API key is missing. Add your OpenWeather key in lib/config/api_config.dart.');
    }

    final results = await Future.wait([
      _getJson(ApiConfig.currentPath, query),
      _getJson(ApiConfig.forecastPath, query),
    ]);

    try {
      return _parse(results[0], results[1]);
    } catch (_) {
      throw const ApiException('Weather data is currently unavailable.');
    }
  }

  Future<Map<String, dynamic>> _getJson(String path, String city) async {
    final uri = Uri.https(ApiConfig.baseHost, path, {
      'q': city,
      'appid': ApiConfig.apiKey,
      'units': 'metric',
    });

    try {
      final response = await _client.get(uri).timeout(_timeout);

      switch (response.statusCode) {
        case 200:
          return jsonDecode(response.body) as Map<String, dynamic>;
        case 404:
          throw CityNotFoundException(city);
        case 401:
          throw const ApiException(
              'Invalid API key. New keys can take a little while to activate.');
        case 429:
          throw const ApiException(
              'Too many requests. Please wait a moment and try again.');
        default:
          if (response.statusCode >= 500) {
            throw const ApiException(
                'The weather service is having problems. Try again later.');
          }
          throw ApiException(
              'Unexpected response from server (code ${response.statusCode}).');
      }
    } on SocketException {
      throw const NoInternetException();
    } on http.ClientException {
      throw const NoInternetException();
    } on TimeoutException {
      throw const ApiException(
          'The request timed out. Check your connection and retry.');
    } on FormatException {
      throw const ApiException('Received invalid data from the server.');
    }
  }

  WeatherData _parse(
      Map<String, dynamic> currentJson, Map<String, dynamic> forecastJson) {
    // ---- Current weather ----
    final w = (currentJson['weather'] as List).first as Map<String, dynamic>;
    final main = currentJson['main'] as Map<String, dynamic>;
    final wind = currentJson['wind'] as Map<String, dynamic>;
    final sys = currentJson['sys'] as Map<String, dynamic>? ?? {};

    final current = CurrentWeather(
      city: currentJson['name'] as String? ?? '',
      country: sys['country'] as String? ?? '',
      temperature: (main['temp'] as num).toDouble(),
      humidity: (main['humidity'] as num).round(),
      // API returns m/s for metric units -> convert to km/h
      windSpeed: (wind['speed'] as num).toDouble() * 3.6,
      description: w['description'] as String? ?? '',
      iconCode: w['icon'] as String? ?? '',
    );

    // ---- Forecast (3-hour steps) ----
    final tzOffset = (forecastJson['city']['timezone'] as num).toInt();
    final list = (forecastJson['list'] as List).cast<Map<String, dynamic>>();

    DateTime toLocal(num dt) => DateTime.fromMillisecondsSinceEpoch(
          dt.toInt() * 1000,
          isUtc: true,
        ).add(Duration(seconds: tzOffset));

    final entries = <ForecastEntry>[];
    final grouped = <String, List<Map<String, dynamic>>>{};
    final groupedTimes = <String, List<DateTime>>{};

    for (final item in list) {
      final t = toLocal(item['dt'] as num);
      final fw = (item['weather'] as List).first as Map<String, dynamic>;
      final fm = item['main'] as Map<String, dynamic>;

      entries.add(ForecastEntry(
        time: t,
        temperature: (fm['temp'] as num).toDouble(),
        description: fw['description'] as String? ?? '',
        iconCode: fw['icon'] as String? ?? '',
      ));

      final key = '${t.year}-${t.month}-${t.day}';
      grouped.putIfAbsent(key, () => []).add(item);
      groupedTimes.putIfAbsent(key, () => []).add(t);
    }

    final hourly = entries.take(8).toList(); // next 24 hours

    // ---- Daily summary built from the 3-hour data ----
    final daily = <DailyForecast>[];
    grouped.forEach((key, items) {
      final times = groupedTimes[key]!;
      var minT = double.infinity;
      var maxT = -double.infinity;
      var bestIndex = 0;
      var bestDiff = 99;

      for (var i = 0; i < items.length; i++) {
        final m = items[i]['main'] as Map<String, dynamic>;
        minT = [minT, (m['temp_min'] as num).toDouble()]
            .reduce((a, b) => a < b ? a : b);
        maxT = [maxT, (m['temp_max'] as num).toDouble()]
            .reduce((a, b) => a > b ? a : b);

        final diff = (times[i].hour - 12).abs();
        if (diff < bestDiff) {
          bestDiff = diff;
          bestIndex = i;
        }
      }

      final rep =
          (items[bestIndex]['weather'] as List).first as Map<String, dynamic>;
      final day = times.first;

      daily.add(DailyForecast(
        date: DateTime(day.year, day.month, day.day),
        minTemp: minT,
        maxTemp: maxT,
        description: rep['description'] as String? ?? '',
        iconCode: (rep['icon'] as String? ?? '').replaceAll('n', 'd'),
      ));
    });

    return WeatherData(
      current: current,
      hourly: hourly,
      daily: daily.take(5).toList(),
    );
  }

  void dispose() => _client.close();
}
