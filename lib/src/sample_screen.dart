import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/weather_provider.dart';
import 'location_bar.dart';

class SampleScreen extends StatefulWidget {
  const SampleScreen({super.key});

  @override
  State<SampleScreen> createState() => _SampleScreenState();
}

class _SampleScreenState extends State<SampleScreen> {
  @override
  void initState() {
    super.initState();

    // fetch once at start
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchWeather();
    });
  }

  void _fetchWeather() {
    final locationProvider = Provider.of<LocationProvider>(context, listen: false);
    final weatherProvider = Provider.of<WeatherProvider>(context, listen: false);
    
    weatherProvider.fetchWeather(
      locationProvider.currentLocation.latitude,
      locationProvider.currentLocation.longitude,
    );
  }

  @override
  Widget build(BuildContext context) {
    final weatherProvider = Provider.of<WeatherProvider>(context);
    final locationProvider = Provider.of<LocationProvider>(context);
    final weatherData = weatherProvider.weatherData;
    final weatherService = weatherProvider.weatherService;

    final currentWeather = weatherData != null 
        ? weatherService.getCurrentWeather(weatherData)
        : null;
    final dailyWeather = weatherData != null 
        ? weatherService.getDailyWeather(weatherData)
        : null;

    return Scaffold(
      body: Column(
        children: [
          const LocationBar(),
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Remove the latitude/longitude input fields since we're using LocationBar
                      const SizedBox(height: 32),
                      Text(
                        'Location: ${locationProvider.currentLocation.latitude.toStringAsFixed(4)}°N, ${locationProvider.currentLocation.longitude.toStringAsFixed(4)}°E',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                
                      // Current weather
                      if (currentWeather != null)
                        Column(
                          children: [
                            SizedBox(
                              width: 600,
                              child: Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    children: [
                                      const Text('Current Weather', 
                                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 8),
                                      Text('Temperature: ${currentWeather['temperature'].round()}°C'),
                                      Text('Feels like: ${currentWeather['apparentTemperature'].round()}°C'),
                                      Text('Wind: ${currentWeather['windSpeed'].round()} km/h'),
                                      Text('Wind Gusts: ${currentWeather['windGusts'].round()} km/h'),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      
                      const SizedBox(height: 32),
                      
                      // Daily forecast scrollable
                      if (dailyWeather != null) ...[
                        const Text('7-Day Forecast', 
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: 600,
                          height: 160,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: dailyWeather.length,
                            itemBuilder: (context, index) {
                              final day = dailyWeather[index];
                              return Card(
                                margin: const EdgeInsets.symmetric(horizontal: 8),
                                child: Container(
                                  width: 100,
                                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        '${day['date'].day}/${day['date'].month}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Max: ${day['maxTemperature'].round()}°',
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                      Text(
                                        'Min: ${day['minTemperature'].round()}°',
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Rain: ${day['precipitationProbability'].round()}%',
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                      Text(
                                        'UV Index: ${day['uvIndex'].round()}',
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}