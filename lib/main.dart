import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'data/weather_provider.dart';
import 'sample_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => WeatherProvider(),
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: SampleScreen(),
    );
  }
}
