import 'package:flutter/material.dart';

import '../models/weather_models.dart';
import '../services/weather_service.dart';
import '../utils/weather_utils.dart';
import '../widgets/city_search_bar.dart';
import '../widgets/current_weather_card.dart';
import '../widgets/error_view.dart';
import '../widgets/forecast_lists.dart';
import '../widgets/weather_detail_tile.dart';

enum _Status { idle, loading, success, error }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _controller = TextEditingController();
  final _service = WeatherService();

  _Status _status = _Status.idle;
  WeatherData? _data;
  String _errorMessage = '';
  bool _isNetworkError = false;
  String _lastCity = '';

  @override
  void initState() {
    super.initState();
    // Load a default city on start so the screen is not empty.
    _controller.text = 'Colombo';
    WidgetsBinding.instance.addPostFrameCallback((_) => _search());
  }

  @override
  void dispose() {
    _controller.dispose();
    _service.dispose();
    super.dispose();
  }

  Future<void> _search([String? cityOverride]) async {
    final city = (cityOverride ?? _controller.text).trim();
    FocusScope.of(context).unfocus();

    if (city.isEmpty) {
      setState(() {
        _status = _Status.error;
        _errorMessage = 'Please enter a city name.';
        _isNetworkError = false;
      });
      return;
    }

    _lastCity = city;
    setState(() => _status = _Status.loading);

    try {
      final data = await _service.getWeatherForCity(city);
      if (!mounted) return;
      setState(() {
        _data = data;
        _status = _Status.success;
      });
    } on NoInternetException catch (e) {
      _showError(e.message, network: true);
    } on WeatherException catch (e) {
      _showError(e.message);
    } catch (_) {
      _showError('Something went wrong. Please try again.');
    }
  }

  void _showError(String message, {bool network = false}) {
    if (!mounted) return;
    setState(() {
      _status = _Status.error;
      _errorMessage = message;
      _isNetworkError = network;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = (_status == _Status.success && _data != null)
        ? WeatherUtils.gradient(_data!.current.iconCode)
        : const [Color(0xFF4B79A1), Color(0xFF283E51)];

    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: colors,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    child: CitySearchBar(
                      controller: _controller,
                      onSearch: _search,
                      enabled: _status != _Status.loading,
                    ),
                  ),
                  Expanded(child: _buildBody()),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    switch (_status) {
      case _Status.idle:
        return const Center(
          child: Text(
            'Search for a city to see the weather',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        );

      case _Status.loading:
        return const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: Colors.white),
              SizedBox(height: 16),
              Text('Fetching weather...',
                  style: TextStyle(color: Colors.white, fontSize: 16)),
            ],
          ),
        );

      case _Status.error:
        return ErrorView(
          message: _errorMessage,
          isNetworkError: _isNetworkError,
          onRetry: () => _search(_lastCity.isEmpty ? null : _lastCity),
        );

      case _Status.success:
        return _buildWeather(_data!);
    }
  }

  Widget _buildWeather(WeatherData data) {
    return RefreshIndicator(
      color: Colors.blue,
      onRefresh: () => _search(_lastCity),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          CurrentWeatherCard(weather: data.current),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: WeatherDetailTile(
                  icon: Icons.water_drop_outlined,
                  label: 'Humidity',
                  value: '${data.current.humidity}%',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: WeatherDetailTile(
                  icon: Icons.air,
                  label: 'Wind speed',
                  value: '${data.current.windSpeed.toStringAsFixed(1)} km/h',
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const _SectionTitle('Next 24 hours (every 3 hours)'),
          const SizedBox(height: 8),
          HourlyForecastList(items: data.hourly),
          const SizedBox(height: 20),
          const _SectionTitle('5-day forecast'),
          const SizedBox(height: 8),
          DailyForecastList(items: data.daily),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
