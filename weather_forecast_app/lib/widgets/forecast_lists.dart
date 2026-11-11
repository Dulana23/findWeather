import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/weather_models.dart';
import '../utils/weather_utils.dart';
import 'weather_icon.dart';

/// Horizontal list of upcoming 3-hour forecast entries.
class HourlyForecastList extends StatelessWidget {
  final List<ForecastEntry> items;

  const HourlyForecastList({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 130,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final h = items[i];
          return Container(
            width: 78,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('h a').format(h.time),
                  style: const TextStyle(color: Colors.white70),
                ),
                WeatherIcon(iconCode: h.iconCode, size: 44),
                Text(
                  '${h.temperature.round()}°C',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Vertical list of the next days.
class DailyForecastList extends StatelessWidget {
  final List<DailyForecast> items;

  const DailyForecastList({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white.withValues(alpha: 0.18),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Column(
          children: [
            for (var i = 0; i < items.length; i++)
              _DailyRow(day: items[i], isToday: i == 0),
          ],
        ),
      ),
    );
  }
}

class _DailyRow extends StatelessWidget {
  final DailyForecast day;
  final bool isToday;

  const _DailyRow({required this.day, required this.isToday});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              isToday ? 'Today' : DateFormat('EEE, d MMM').format(day.date),
              style: const TextStyle(color: Colors.white, fontSize: 15),
            ),
          ),
          WeatherIcon(iconCode: day.iconCode, size: 44),
          const SizedBox(width: 4),
          Expanded(
            flex: 3,
            child: Text(
              WeatherUtils.capitalize(day.description),
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ),
          Text(
            '${day.minTemp.round()}° / ${day.maxTemp.round()}°C',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
