import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/weather_provider.dart';

const List<String> locations = <String>[
  'CAMBRIDGE',
  'BOSTON',
  'NEW YORK',
];

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String location = locations[0];

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
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.warning),
          onPressed: () {
            // Add your onPressed logic here
          },
          ),
        title: Center(
          child: DropdownButton<String>(
            value: location,
            icon: const Icon(Icons.arrow_drop_down),
            elevation: 16,
            style: const TextStyle(color: Colors.black, fontSize: 20),
            underline: Container(
              height: 2,
              color: Colors.white,
            ),
            onChanged: (String? newValue) {
              setState(() {
                location = newValue!;
              });
            },
            items: <String>['CAMBRIDGE', 'BOSTON', 'NEW YORK']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          )
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.directions_bike),
            onPressed: () {
              // Add your onPressed logic here
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  Icons.sunny,
                  size: 200,
                  color: Colors.yellow,
                ),
                Text(
                  "${currentWeather?["temperature"]}°C",
                  style: TextStyle(color: Colors.black, fontSize: 36),
                )
              ]
            ),
            Icon(
              Icons.directions_bike,
              size: 200,
            ),
            Text(
              "GOOD DAY FOR A RIDE!",
              style: TextStyle(color: Colors.black, fontSize: 24),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "HI: ${dailyWeather?[0]["maxTemperature"].round()}°C",
                  style: TextStyle(color: Colors.black, fontSize: 18),
                ),
                SizedBox(width: 20),
                Text(
                  "LO: ${dailyWeather?[0]["minTemperature"].round()}°C",
                  style: TextStyle(color: Colors.black, fontSize: 18),
                )
              ],
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.height * 0.15,
                  height: MediaQuery.of(context).size.height * 0.15,
                  child: Card(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("WIND", style: TextStyle(fontSize: 18)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.arrow_back,
                              size: 50,
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text((currentWeather?["windSpeed"]).toString(), style: TextStyle(fontSize: 24)),
                                Text("km/h"),
                              ],
                            ),
                          ],
                        ),
                        Text("??? WINDS, ${currentWeather?["windDirection"]}", style: TextStyle(fontSize: 10)),
                      ],
                    ),
                  )
                ),
                SizedBox(width: 20),
                SizedBox(
                  width: MediaQuery.of(context).size.height * 0.15,
                  height: MediaQuery.of(context).size.height * 0.15,
                  child: Card(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Wrap(
                            children: [
                              Text("NO PERCIPITATION FOR AT LEAST 60 MINS", style: TextStyle(fontSize: 10)),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.auto_graph,
                          size: 50, 
                        ),
                      ],
                    ),
                  ),

                ),
              ],
            ),
          ],
        )
      )
    );
  }
}