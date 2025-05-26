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
          WeatherCurrent.wind_gusts_10m,
          WeatherCurrent.precipitation,
          WeatherCurrent.rain,
          WeatherCurrent.showers,
          WeatherCurrent.snowfall,
          WeatherCurrent.weather_code,
        },
        daily: {
          WeatherDaily.temperature_2m_max,
          WeatherDaily.temperature_2m_min,
          WeatherDaily.precipitation_probability_max,
          WeatherDaily.uv_index_max,
          WeatherDaily.wind_speed_10m_max,
          WeatherDaily.wind_direction_10m_dominant,
          WeatherDaily.weather_code,
          WeatherDaily.sunrise,
          WeatherDaily.sunset,
          WeatherDaily.precipitation_sum,
        },
        hourly: {
          WeatherHourly.temperature_2m,
          WeatherHourly.precipitation_probability,
          WeatherHourly.uv_index,
          WeatherHourly.wind_direction_10m,
          WeatherHourly.wind_speed_10m,
          WeatherHourly.relative_humidity_2m,
          WeatherHourly.visibility,
          WeatherHourly.pressure_msl,
          WeatherHourly.cloud_cover,
        }
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  String getWindDirectionOrdinal(double windDirection) {
    const windDirections = [
      'N', 'NNE', 'NE', 'ENE', 'E', 'ESE', 'SE', 'SSE',
      'S', 'SSW', 'SW', 'WSW', 'W', 'WNW', 'NW', 'NNW'
    ];
    final index = ((windDirection + 11.25) / 22.5).round() % 16;
    return windDirections[index];
  }

  // Helper function to extract current weather data
  Map<String, dynamic> getCurrentWeather(ApiResponse<WeatherApi> response) {
    return {
      'temperature': response.currentData[WeatherCurrent.temperature_2m]?.value,
      'apparentTemperature': response.currentData[WeatherCurrent.apparent_temperature]?.value,
      'windSpeed': response.currentData[WeatherCurrent.wind_speed_10m]?.value,
      'windDirection': response.currentData[WeatherCurrent.wind_direction_10m]?.value,
      'windGusts': response.currentData[WeatherCurrent.wind_gusts_10m]?.value,
      'windDirectionOrdinal': getWindDirectionOrdinal(
        response.currentData[WeatherCurrent.wind_direction_10m]?.value ?? 0,
      ),
      'precipitation': response.currentData[WeatherCurrent.precipitation]?.value,
      'rain': response.currentData[WeatherCurrent.rain]?.value,
      'showers': response.currentData[WeatherCurrent.showers]?.value,
      'snowfall': response.currentData[WeatherCurrent.snowfall]?.value,
      'weatherCode': response.currentData[WeatherCurrent.weather_code]?.value,
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
        'windSpeed': response.dailyData[WeatherDaily.wind_speed_10m_max]?.values[date],
        'windDirection': response.dailyData[WeatherDaily.wind_direction_10m_dominant]?.values[date],
        'weatherCode': response.dailyData[WeatherDaily.weather_code]?.values[date],
        'sunrise': response.dailyData[WeatherDaily.sunrise]?.values[date],
        'sunset': response.dailyData[WeatherDaily.sunset]?.values[date],
        'totalPrecipitation': response.dailyData[WeatherDaily.precipitation_sum]?.values[date],     
      });

      final hourlyMetrics = {
        'humidity': {
          'field': WeatherHourly.relative_humidity_2m,
          'reduce': (List<double> vals) => vals.reduce((a, b) => a + b) / vals.length,
        },
        'visibility': {
          'field': WeatherHourly.visibility,
          'reduce': (List<double> vals) => vals.reduce((a, b) => a < b ? a : b),
        },
        'pressure': {
          'field': WeatherHourly.pressure_msl,
          'reduce': (List<double> vals) => vals.reduce((a, b) => a + b) / vals.length,
        },
        'cloudCover': {
          'field': WeatherHourly.cloud_cover,
          'reduce': (List<double> vals) => vals.reduce((a, b) => a + b) / vals.length,
        },
      };

      hourlyMetrics.forEach((key, config) {
        final metricValues = response.hourlyData[config['field']]?.values.entries
          .where((entry) =>
            entry.key.year == date.year &&
            entry.key.month == date.month &&
            entry.key.day == date.day
          )
          .map((e) => e.value.toDouble())
          .toList();

        final reducer = config['reduce'] as double Function(List<double>)?;
        if (reducer != null && metricValues != null && metricValues.isNotEmpty) {
          final reduced = reducer(metricValues);
          dailyData.last[key] = reduced;
        }
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
        'cloudCoverage': response.hourlyData[WeatherHourly.cloud_cover]?.values[time],
      });
    }

    return hourlyData;
  }

  int getNextPrecipitationIndex(ApiResponse<WeatherApi> response) {
    final hourlyWeather = getHourlyWeather(response);
    for (int i = 0; i < hourlyWeather.length; i++) {
      if (hourlyWeather[i]['precipitationProbability'] > 0.5) {
        return i;
      }
    }
    return -1; // No precipitation found
  }
}