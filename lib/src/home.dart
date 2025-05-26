import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/weather_provider.dart';
import 'location_bar.dart';
import 'package:weather_icons/weather_icons.dart';

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

    Icon getWeatherIcon() {
      final code = currentWeather["weatherCode"]?.toInt() ?? 0;
      final size = 180.0;
      if (code == 0) return Icon(Icons.sunny, size: size, color: Colors.amber);
      if (code == 1 || code == 2) return Icon(WeatherIcons.day_cloudy, size: size, color: Colors.blueGrey);
      if (code == 3) return Icon(WeatherIcons.cloud, size: size, color: Colors.grey);
      if (code == 45 || code == 48) return Icon(WeatherIcons.fog, size: size, color: Colors.grey.shade400);
      if (code >= 51 && code <= 57) return Icon(WeatherIcons.sprinkle, size: size, color: Colors.lightBlueAccent);
      if (code >= 61 && code <= 65) return Icon(WeatherIcons.rain, size: size, color: Colors.blueAccent);
      if (code >= 66 && code <= 67) return Icon(WeatherIcons.rain_mix, size: size, color: Colors.blueAccent);
      if (code >= 71 && code <= 75) return Icon(WeatherIcons.snow, size: size, color: Colors.lightBlue.shade100);
      if (code == 77) return Icon(WeatherIcons.snowflake_cold, size: size, color: Colors.cyan);
      if (code >= 80 && code <= 82) return Icon(WeatherIcons.showers, size: size, color: Colors.blue.shade700);
      if (code >= 85 && code <= 86) return Icon(WeatherIcons.snow_wind, size: size, color: Colors.blueGrey.shade200);
      if (code == 95) return Icon(WeatherIcons.thunderstorm, size: size, color: Colors.deepPurple);
      if (code == 96 || code == 99) return Icon(WeatherIcons.thunderstorm, size: size, color: Colors.deepPurple);
      return Icon(WeatherIcons.na, size: size, color: Colors.black26);
    }

    String getCyclingText() {
      final code = currentWeather["weatherCode"]?.toInt() ?? 0;
      if (code == 0) {
        return "SUNNY: GOOD DAY FOR A RIDE!";
      } else if (code == 1 || code == 2 || code == 3) {
        return "CLOUDY: GOOD DAY FOR A RIDE!";
      } else if (code == 45 || code == 48) {
        return "FOGGY: BE CAUTIOUS!";
      } else if (code >= 50 && code <= 59) {
        return "DRIZZLE: BE CAUTIOUS!";
      } else if (code >= 60 && code <= 69) {
        return "RAIN: BE CAUTIOUS!";
      } else if (code >= 70 && code <= 79) {
        return "SNOW: ROADS MAY BE ICY!";
      } else if (code >= 80 && code <= 82) {
        return "SHOWERS: BE CAUTIOUS!";
      } else if (code >= 85 && code <= 86) {
        return "HEAVY SNOW: ROADS MAY BE ICY!";
      } else if (code == 95 || code == 96 || code == 99) {
        return "THUNDERSTORM: STAY INDOORS!";
      } else {
        return "CONSIDER ANOTHER DAY!";
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
              Stack(
                alignment: Alignment.center,
                children: [
                  Image.asset(
                    "assets/compass.png",
                    width: 350,
                  ),
                 Transform.translate(
                    offset: Offset(0, 33), // Adjust the offset to position the icon correctly
                    child: Transform.rotate(
                      angle: getWindDirRadians(),
                      child: Transform.scale(
                        scaleY: 2.0,
                        child: Icon(Icons.north, size: 120, color: Color.fromARGB(255, 0, 0, 0))
                      ),
                    ),
                  )
                ],    
              ),
            ],
          )
        )
      );
    }

    return Scaffold(
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
                  getWeatherIcon(),
                  Text(
                    "${currentWeather["temperature"].round()}°C",
                    style: TextStyle(color: Colors.black, fontSize: 34),
                  )
                ]
              ),
              SizedBox(height: 20),
              Image.asset(
                "assets/cycle.png",
                width: 250
              ),
              Text(
                getCyclingText(),
                style: TextStyle(color: Colors.black, fontSize: 24),
              ),
              SizedBox(height: 15),
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
              SizedBox(height: 15),
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
                      child: Container(
                        margin: EdgeInsets.all(7),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("PRECIPITATION", style: TextStyle(fontSize: 15)),
                            SizedBox(height: 20),
                            Text(getPercipitationText(), style: TextStyle(fontSize: 10)),
                            SizedBox(height: 20),
                          ],
                        ),
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