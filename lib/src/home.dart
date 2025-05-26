import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/weather_provider.dart';
import 'location_bar.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

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

final windDirMap = {
  "N": 0, "NNE": 22.5, "NE": 45, "ENE": 67.5,
  "E": 90, "ESE": 112.5, "SE": 135, "SSE": 157.5,
  "S": 180, "SSW": 202.5, "SW": 225, "WSW": 247.5,
  "W": 270, "WNW": 292.5, "NW": 315, "NNW": 337.5,
};

class _HomeScreenState extends State<HomeScreen> {
  String location = locations[0];
  bool cycleMode = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final weatherProvider = Provider.of<WeatherProvider>(context, listen: false);
      final locationProvider = Provider.of<LocationProvider>(context, listen: false);
      weatherProvider.fetchWeather(locationProvider.currentLocation.latitude, locationProvider.currentLocation.longitude);
    });
  }

  @override
  Widget build(BuildContext context) {
    final weatherProvider = Provider.of<WeatherProvider>(context);
    final weatherData = weatherProvider.weatherData;
    final weatherService = weatherProvider.weatherService;

    final currentLocation = Provider.of<LocationProvider>(context).currentLocation;

    var dailyWeather, currentWeather;

    if (weatherData == null) {
      // return const Center(child: CircularProgressIndicator());
       currentWeather = {
        "temperature": 15,
        "windSpeed": 13,
        "windDirection": 20,
        "weather_code": 0,
        "windDirectionOrdinal": "N",
      };
      dailyWeather = [
        {
          "maxTemperature": 20,
          "minTemperature": 10,
          "precipitationProbabilityMax": 0,
          "uvIndexMax": 5,
          "windSpeedMax": 15,
          "windDirectionDominant": "N",
          "weatherCode": 0,
          "sunrise": DateTime.now(),
          "sunset": DateTime.now().add(Duration(hours: 12)),
          "precipitationSum": 0,
        }
      ];
    } else {
      currentWeather = weatherService.getCurrentWeather(weatherData);
      dailyWeather = weatherService.getDailyWeather(weatherData);
    }

    var windCat = switch (currentWeather["windSpeed"]) {
      >= 0 && < 7 => "still",
      >= 7 && < 13 => "calm",
      >= 13 && < 19 => "modest",
      >= 19 && < 25 => "strong",
      >= 25 && < 33 => "very strong",
      >= 33 && < 41 => "risk",
      >= 41 => "danger",
      _ => "error",
    };

    double getWindDirRadians() {
      return currentWeather["windDirection"] * (3.14 / 180);
    }

    String getPercipitationText() {
      final h = weatherData == null ? 0 : weatherService.getNextPrecipitationIndex(weatherData);
      if (h == -1 || h > 6) {
        return "NO PRECIPITATION FOR THE NEXT 6 HOURS";
      } else {
        return "EXPECTED PRECIPITATION IN $h HOUR${h == 1 ? "" : "S"}";
      }
    }

    if (cycleMode) {
      return Scaffold(
        appBar: AppBar(
          leading: Icon(Icons.warning, color: Colors.transparent),
          title: Center(
            child: Text(
              currentLocation.name, style: TextStyle(color: Colors.black)
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.house),
              onPressed: () {
                setState(() {
                  cycleMode = !cycleMode;
                });
              },
            ),
          ],
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "${currentWeather["temperature"].round()}°C",
                style: TextStyle(color: Colors.black, fontSize: 100),
              ),
              Text("$windCat WINDS, ${currentWeather["windDirectionOrdinal"]}", style: TextStyle(fontSize: 40)),
              SizedBox(height: 30),
              Image.asset(
                "assets/cycle.png",
                width: 200,
              ),
              SizedBox(height: 20),
              Card(
                child: Column(
                  children: [
                    Text("AT YOUR NEXT CHECKPOINT:", style: TextStyle(fontSize: 25)),
                    Text("??°C", style: TextStyle(fontSize: 25)),
                    Text("??? WINDS, ???", style: TextStyle(fontSize: 25)),
                    Text("??? RAIN", style: TextStyle(fontSize: 25)),
                  ],
                )
              )
            ],
          )
        )
      );
    }

    return Scaffold(
      backgroundColor: Color.fromARGB(255, 50, 173, 230),
      appBar: AppBar(
        leading: Tooltip(
          message: "Frost Alert",
          triggerMode: TooltipTriggerMode.tap,
          child: Icon(Icons.warning),
        ),
        title: Center(
          child: LocationBar()
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.directions_bike),
            onPressed: () {
              setState(() {
                cycleMode = !cycleMode;
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
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
                    "${currentWeather["temperature"].round()}°C",
                    style: TextStyle(color: Colors.black, fontSize: 36),
                  )
                ]
              ),
              Image.asset(
                "assets/cycle.png",
                width: 250
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
                    "HI: ${dailyWeather[0]["maxTemperature"].round()}°C",
                    style: TextStyle(color: Colors.black, fontSize: 18),
                  ),
                  SizedBox(width: 20),
                  Text(
                    "LO: ${dailyWeather[0]["minTemperature"].round()}°C",
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
                              Transform.rotate(angle: getWindDirRadians(), child: SizedBox(
                                  height: 40,
                                  width: 40,
                                  child: Icon(Icons.north, size: 40, color: Color.fromARGB(255, 0, 0, 0),)
                              ),),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text((currentWeather["windSpeed"].round()).toString(), style: TextStyle(fontSize: 24)),
                                  Text("km/h"),
                                ],
                              ),
                            ],
                          ),
                          Text("$windCat WINDS, ${currentWeather["windDirectionOrdinal"]}", style: TextStyle(fontSize: 10)),
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
                                Text("NO PRECIPITATION FOR AT LEAST 60 MINS", style: TextStyle(fontSize: 10)),
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
          ),
        )
      )
    );
  }
}