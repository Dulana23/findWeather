import 'package:flutter/material.dart';

/// Rounded city search field with a search button.
class CitySearchBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSearch;
  final bool enabled;

  const CitySearchBar({
    super.key,
    required this.controller,
    required this.onSearch,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(30),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          const SizedBox(width: 8),
          const Icon(Icons.location_city, color: Colors.white70),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              enabled: enabled,
              style: const TextStyle(color: Colors.white),
              cursorColor: Colors.white,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => onSearch(),
              decoration: const InputDecoration(
                hintText: 'Search city (e.g. Colombo)',
                hintStyle: TextStyle(color: Colors.white60),
                border: InputBorder.none,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: enabled ? onSearch : null,
            tooltip: 'Search',
          ),
        ],
      ),
    );
  }
}
