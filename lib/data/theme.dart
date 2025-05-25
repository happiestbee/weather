import 'package:flutter/material.dart';

ThemeData getThemeForWeather(int code) {
  if (code >= 0 && code <= 2) {
    // Clear/Sunny
    return ThemeData(
      scaffoldBackgroundColor: const Color(0xFF32ADE6),
      primaryColor: const Color.fromARGB(255, 73, 175, 223),
      textTheme: const TextTheme(
        bodyMedium: TextStyle(color: Colors.black),
      ),
    );
  } else if ((code >= 51 && code <= 67) || (code >= 80 && code <= 82)) {
    // Rainy
    return ThemeData(
      scaffoldBackgroundColor: const Color.fromARGB(255, 92, 117, 145),
      primaryColor: Color.fromARGB(255, 92, 117, 145),
      textTheme: const TextTheme(
        bodyMedium: TextStyle(color: Colors.black),
      ),
    );
  } else if (code >= 3 && code <= 48) {
    // Cloudy
    return ThemeData(
      scaffoldBackgroundColor: Colors.grey.shade700,
      primaryColor: Colors.grey.shade600,
      textTheme: const TextTheme(
        bodyMedium: TextStyle(color: Colors.black),
      ),
    );
  } else if ((code >= 71 && code <= 77) || (code == 85 || code == 86)) {
    // Snowy
    return ThemeData(
      scaffoldBackgroundColor: const Color.fromARGB(255, 157, 171, 178),
      primaryColor: const Color.fromARGB(255, 166, 173, 176),
      textTheme: const TextTheme(
        bodyMedium: TextStyle(color: Colors.black),
      ),
    );
  } else if (code >= 95 && code <= 99) {
  // Cloudy
  return ThemeData(
    scaffoldBackgroundColor: Colors.grey.shade700,
    primaryColor: Colors.grey.shade600,
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: Colors.black),
    ),
  );
  } else {

    return ThemeData(
      scaffoldBackgroundColor: const Color.fromARGB(255, 120, 162, 182),
      primaryColor: const Color.fromARGB(255, 120, 162, 182),
      textTheme: const TextTheme(
        bodyMedium: TextStyle(color: Colors.black),
      ),
    );
  }
}
