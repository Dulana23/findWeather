import 'package:flutter/material.dart';

import '../models/weather_models.dart';
import '../utils/weather_utils.dart';
import 'weather_icon.dart';

/// Large card showing city, icon, temperature and condition.
class CurrentWeatherCard extends StatelessWidget {
  final CurrentWeather weather;

  const CurrentWeatherCard({super.key, required this.weather});

  @override
  Widget build(BuildContext context) {
    final location = weather.country.isEmpty
        ? weather.city
        : '${weather.city}, ${weather.country}';

    return Card(
      color: Colors.white.withValues(alpha: 0.18),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              location,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            WeatherIcon(iconCode: weather.iconCode, size: 110),
            Text(
              '${weather.temperature.round()}°C',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 64,
                fontWeight: FontWeight.w300,
              ),
            ),
            Text(
              WeatherUtils.capitalize(weather.description),
              style: const TextStyle(color: Colors.white70, fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }
}
