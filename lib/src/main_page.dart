import 'package:flutter/material.dart';
import 'home.dart';
import '../daily_weather.dart';
import 'package:weather/src/route_screen.dart';
import 'sample_screen.dart';

class MainPage extends StatefulWidget{
  const MainPage({super.key});
 
  @override
  State<StatefulWidget> createState() => _MainPageState();
    
}

class _MainPageState extends State<MainPage> {

  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    
    Widget page;
    switch (selectedIndex){
      case 0:
        page = HomeScreen(); // home screen
        break;
      case 1:
        page = SampleScreen(); // hourly
        break;
      case 2:
        page = DailyWeather(); // daily
        break;
      case 3:
        page = RouteScreen(); // route
        break;
      default:
        throw UnsupportedError('no widget for $selectedIndex');
    }

    return Scaffold(
      bottomNavigationBar: NavigationBar(
        destinations: [
          NavigationDestination(icon: Icon(Icons.house), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.access_time_rounded), label: 'Hourly'),
          NavigationDestination(icon: Icon(Icons.calendar_today), label: 'Daily'),
          NavigationDestination(icon: Icon(Icons.map_outlined), label: 'Route'),
        ],
        selectedIndex: selectedIndex,
        onDestinationSelected: (value) {
          setState((){
            selectedIndex = value;
          });
        },
      ),
      body: Expanded(
        child: Container(                  
          child: page,
        ),
      ),
    );  
  }
}