import 'package:open_meteo/open_meteo.dart';
// import 'dart:math';

class WeatherService {
  final WeatherApi weatherApi = WeatherApi();

  Future<ApiResponse<WeatherApi>> getWeatherData(double latitude, double longitude) async {
    try {
      final response = await weatherApi.request(
        latitude: latitude,
        longitude: longitude,
        current: {
          WeatherCurrent.temperature_2m, 
          WeatherCurrent.apparent_temperature,
          WeatherCurrent.wind_speed_10m, 
          WeatherCurrent.wind_direction_10m,
          WeatherCurrent.wind_gusts_10m},
        daily: {
          WeatherDaily.temperature_2m_max,
          WeatherDaily.temperature_2m_min,
          WeatherDaily.precipitation_probability_max,
          WeatherDaily.uv_index_max,
        },
        hourly: {
          WeatherHourly.temperature_2m,
          WeatherHourly.precipitation_probability,
          WeatherHourly.uv_index,
          WeatherHourly.wind_direction_10m,
          WeatherHourly.wind_speed_10m,
        }
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Helper function to extract current weather data
  Map<String, dynamic> getCurrentWeather(ApiResponse<WeatherApi> response) {
    return {
      'temperature': response.currentData[WeatherCurrent.temperature_2m]?.value,
      'apparentTemperature': response.currentData[WeatherCurrent.apparent_temperature]?.value,
      'windSpeed': response.currentData[WeatherCurrent.wind_speed_10m]?.value,
      'windDirection': response.currentData[WeatherCurrent.wind_direction_10m]?.value,
      'windGusts': response.currentData[WeatherCurrent.wind_gusts_10m]?.value,
    };
  }

  // Helper function to extract daily weather data
  List<Map<String, dynamic>> getDailyWeather(ApiResponse<WeatherApi> response) {
    final dailyData = <Map<String, dynamic>>[];
    final dates = response.dailyData[WeatherDaily.temperature_2m_max]?.values.keys.toList() ?? [];
    
    for (final date in dates) {
      dailyData.add({
        'date': date,
        'maxTemperature': response.dailyData[WeatherDaily.temperature_2m_max]?.values[date],
        'minTemperature': response.dailyData[WeatherDaily.temperature_2m_min]?.values[date],
        'precipitationProbability': response.dailyData[WeatherDaily.precipitation_probability_max]?.values[date],
        'uvIndex': response.dailyData[WeatherDaily.uv_index_max]?.values[date],
      });
    }

    return dailyData;
  }
  
  // Helper function to extract hourly weather data
  List<Map<String, dynamic>> getHourlyWeather(ApiResponse<WeatherApi> response) {
    final hourlyData = <Map<String, dynamic>>[];
    final times = response.hourlyData[WeatherHourly.temperature_2m]?.values.keys.toList() ?? [];
    for (final time in times) {
      hourlyData.add({
        'time': time,
        'temperature': response.hourlyData[WeatherHourly.temperature_2m]?.values[time],
        'precipitationProbability': response.hourlyData[WeatherHourly.precipitation_probability]?.values[time],
        'uvIndex': response.hourlyData[WeatherHourly.uv_index]?.values[time],
        'windSpeed': response.hourlyData[WeatherHourly.wind_speed_10m]?.values[time],
        'windDirection': response.hourlyData[WeatherHourly.wind_direction_10m]?.values[time],
      });
    }

    return hourlyData;
  }
}