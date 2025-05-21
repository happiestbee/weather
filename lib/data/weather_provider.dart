import 'package:flutter/material.dart';
import 'package:open_meteo/open_meteo.dart';
import 'weather_service.dart';

class WeatherProvider with ChangeNotifier {
  ApiResponse<WeatherApi>? _weatherData;
  final WeatherService _weatherService = WeatherService();

  ApiResponse<WeatherApi>? get weatherData => _weatherData;

  Future<void> fetchWeather(double latitude, double longitude) async {
    try {
      _weatherData = await _weatherService.getWeatherData(latitude, longitude);
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching weather data: $e');
      // Handle error appropriately
      notifyListeners();
    }
  }

  Map<DateTime, num>? get temperatureValues {
    return _weatherData?.hourlyData[WeatherHourly.temperature_2m]?.values;
  }

  Map<DateTime, num>? get windspeedValues {
    return _weatherData?.hourlyData[WeatherHourly.wind_speed_10m]?.values;
  }

  WeatherService get weatherService => _weatherService;
}
