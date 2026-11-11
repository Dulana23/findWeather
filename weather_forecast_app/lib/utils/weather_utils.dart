import 'package:flutter/material.dart';

/// Helpers for OpenWeather icon codes (e.g. "01d", "10n").
class WeatherUtils {
  static String iconUrl(String code) =>
      'https://openweathermap.org/img/wn/$code@2x.png';

  /// Offline fallback if the icon image cannot be downloaded.
  static IconData fallbackIcon(String code) {
    final night = code.endsWith('n');
    final id = code.length >= 2 ? code.substring(0, 2) : '';
    switch (id) {
      case '01':
        return night ? Icons.nightlight_round : Icons.wb_sunny;
      case '02':
        return night ? Icons.nights_stay : Icons.wb_cloudy;
      case '03':
      case '04':
        return Icons.cloud;
      case '09':
      case '10':
        return Icons.water_drop;
      case '11':
        return Icons.thunderstorm;
      case '13':
        return Icons.ac_unit;
      case '50':
        return Icons.foggy;
      default:
        return Icons.help_outline;
    }
  }

  /// Background gradient based on the icon code.
  static List<Color> gradient(String code) {
    if (code.endsWith('n')) return const [Color(0xFF0F2027), Color(0xFF2C5364)];
    final id = code.length >= 2 ? code.substring(0, 2) : '';
    switch (id) {
      case '01':
      case '02':
        return const [Color(0xFF2193B0), Color(0xFF6DD5ED)];
      case '03':
      case '04':
      case '50':
        return const [Color(0xFF606C88), Color(0xFF3F4C6B)];
      case '11':
        return const [Color(0xFF373B44), Color(0xFF4286F4)];
      case '13':
        return const [Color(0xFF83A4D4), Color(0xFFB6FBFF)];
      default:
        return const [Color(0xFF4B79A1), Color(0xFF283E51)];
    }
  }

  static String capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }
}
