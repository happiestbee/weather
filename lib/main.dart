import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weather/src/location_bar.dart';
import 'data/weather_provider.dart';
import 'sample_screen.dart';

final navigatorKey = GlobalKey<NavigatorState>();

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => WeatherProvider()),
        ChangeNotifierProxyProvider<WeatherProvider, LocationProvider>(
          create: (context) => LocationProvider(
            Provider.of<WeatherProvider>(context, listen: false),
          ),
          update: (context, weatherProvider, previous) => 
            previous ?? LocationProvider(weatherProvider),
        ),
      ],
      child: const MainApp(),
    ),
  );
}


class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      home: const SampleScreen(),
    );
  }
}
