import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'data/weather_provider.dart';

class SampleScreen extends StatefulWidget {
  const SampleScreen({super.key});

  @override
  State<SampleScreen> createState() => _SampleScreenState();
}

class _SampleScreenState extends State<SampleScreen> {
  final TextEditingController _latController = TextEditingController(text: '42.3555');
  final TextEditingController _lonController = TextEditingController(text: '71.0565');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchWeather();
    });
  }

  void _fetchWeather() {
    final lat = double.tryParse(_latController.text) ?? 42.3555;
    final lon = double.tryParse(_lonController.text) ?? 71.0565;
    Provider.of<WeatherProvider>(context, listen: false).fetchWeather(lat, lon);
  }

  @override
  Widget build(BuildContext context) {
    final weatherProvider = Provider.of<WeatherProvider>(context);
    final weatherData = weatherProvider.weatherData;
    final weatherService = weatherProvider.weatherService;

    final currentWeather = weatherData != null 
        ? weatherService.getCurrentWeather(weatherData)
        : null;
    final dailyWeather = weatherData != null 
        ? weatherService.getDailyWeather(weatherData)
        : null;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Input fields and refresh button
                SizedBox(
                  width: 600, // Limit width for larger screens
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _latController,
                          decoration: const InputDecoration(
                            labelText: 'Latitude',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          controller: _lonController,
                          decoration: const InputDecoration(
                            labelText: 'Longitude',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _fetchWeather,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refresh Weather'),
                ),
                const SizedBox(height: 32),

                // Current weather
                if (currentWeather != null)
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

                const SizedBox(height: 32),

                // Daily forecast scrollable
                if (dailyWeather != null) ...[
                  const Text('7-Day Forecast', 
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: 600,
                    height: 160, // Reduced height since text is smaller
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _latController.dispose();
    _lonController.dispose();
    super.dispose();
  }
}