import 'package:flutter/material.dart';

ThemeData getThemeForWeather(int code) {
  if (code == 0) {
    // Clear/Sunny
    return ThemeData(
      scaffoldBackgroundColor: const Color(0xFF32ADE6),
      primaryColor: const Color.fromARGB(255, 73, 175, 223),
      textTheme: const TextTheme(
        bodyMedium: TextStyle(color: Colors.black),
      ),
    );
  } else if (code >= 61 && code <= 67) {
    // Rainy
    return ThemeData(
      scaffoldBackgroundColor: Colors.grey.shade700,
      primaryColor: Colors.grey.shade600,
      textTheme: const TextTheme(
        bodyMedium: TextStyle(color: Colors.black),
      ),
    );
  } else if (code >= 71 && code <= 77) {
    // Snowy
    return ThemeData(
      scaffoldBackgroundColor: const Color.fromARGB(255, 157, 171, 178),
      primaryColor: const Color.fromARGB(255, 166, 173, 176),
      textTheme: const TextTheme(
        bodyMedium: TextStyle(color: Colors.black),
      ),
    );
  } else {

    return ThemeData(
      scaffoldBackgroundColor: Colors.blueGrey.shade800,
      primaryColor: Colors.blueGrey.shade700,
      textTheme: const TextTheme(
        bodyMedium: TextStyle(color: Colors.black),
      ),
    );
  }
}
