import 'package:flutter/material.dart';

import '../utils/weather_utils.dart';

/// Weather icon loaded from OpenWeather, with an offline fallback.
class WeatherIcon extends StatelessWidget {
  final String iconCode;
  final double size;

  const WeatherIcon({super.key, required this.iconCode, this.size = 48});

  @override
  Widget build(BuildContext context) {
    return Image.network(
      WeatherUtils.iconUrl(iconCode),
      width: size,
      height: size,
      fit: BoxFit.contain,
      loadingBuilder: (context, child, progress) =>
          progress == null ? child : SizedBox(width: size, height: size),
      errorBuilder: (context, error, stack) => SizedBox(
        width: size,
        height: size,
        child: Icon(
          WeatherUtils.fallbackIcon(iconCode),
          size: size * 0.7,
          color: Colors.white,
        ),
      ),
    );
  }
}
