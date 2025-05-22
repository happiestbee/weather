import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';
import 'package:weather/data/weather_provider.dart';
import 'package:weather_icons/weather_icons.dart';
import 'package:weather/src/location_bar.dart';


class DailyWeather extends StatefulWidget {
  @override
  State<DailyWeather> createState() => _DailyWeatherState();
}

class _DailyWeatherState extends State<DailyWeather> {
  // late List<ChartSampleData> chartData;
  int selectedIndex = 0;

  /* @override
  void initState() {
    _chartData = getChartData();
    selectedIndex = 0;
    super.initState();
  } */

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final locationProvider = Provider.of<LocationProvider>(context, listen: false);
      final weatherProvider = Provider.of<WeatherProvider>(context, listen: false);
      final loc = locationProvider.currentLocation;
      weatherProvider.fetchWeather(loc.latitude, loc.longitude);
    });
  }


Widget _infoBox({required String label, required String value}) {
  return Expanded(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white,
            fontWeight: FontWeight.bold
          ),
        ),
        SizedBox(height: 1),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white
          ),
        )
      ],
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    final weatherProvider = Provider.of<WeatherProvider>(context);
    final dailyData = weatherProvider.weatherData != null
      ? weatherProvider.weatherService.getDailyWeather(weatherProvider.weatherData!)
      : [];

      if (dailyData.isEmpty) {
        return Scaffold(
          //backgroundColor: Color.fromARGB(0, 255, 255, 255),
          body: Center(child: CircularProgressIndicator()),
        );
      }

      final List<ChartSampleData> chartData = dailyData.map((day) {
        return ChartSampleData(
          x: day['date'] as DateTime,
          high: day['maxTemperature']?.roundToDouble() ?? 0,
          low: day['minTemperature'].roundToDouble() ?? 0,
          rain: day['precipitationProbability']?.toInt() ?? 0,
          windSpeed: day['windSpeed']?.toInt() ?? 0,
          windDirection: day['windDirection']?.toDouble() ?? 0.0,
        );
      }).toList();

      final selectedDay = dailyData[selectedIndex];
      final selectedChart = chartData[selectedIndex];

    return SafeArea(
      child: Scaffold(
        //backgroundColor:  Color.fromARGB(0, 255, 255, 255),
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 30),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal:20, vertical:10),
                  child: LocationBar()
                ),

                const SizedBox(height: 20),
            
                SizedBox(
                  width: 350,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    /*children: List.generate(_chartData.length, (index) {
                      final data = _chartData[index];
                      final isSelected = selectedIndex == index;*/
                    children: List.generate(dailyData.length, (index) {
                      final date = dailyData[index]['date'] as DateTime;
                      final isSelected = selectedIndex == index;
                      return Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            boxShadow: [BoxShadow(color: const Color.fromARGB(15, 0, 0, 0), blurRadius: 6, offset: Offset(0, 3),
                            ),]
                          ),
                          child: OutlinedButton(
                            onPressed: () {
                              setState(() {
                                selectedIndex = index;
                              });
                            },
                            style: OutlinedButton.styleFrom(
                              backgroundColor: isSelected
                                ? Colors.white 
                                : Color.fromARGB(60,209,238, 252),
                              padding: EdgeInsets.zero,
                              shape: const CircleBorder(),
                              side: BorderSide(color: Colors.white, width: 1),
                            ),
                            child: Text(
                              DateFormat.E().format(date)[0],
                              style: TextStyle(
                                color: isSelected
                                ? Theme.of(context).primaryColor 
                                : Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),

                SizedBox(height: 20),

                SizedBox(
                  width: 350,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: List.generate(dailyData.length, (index) {
                      final isSelected = index == selectedIndex;
                      final weatherCode = (dailyData[index]['weatherCode'] as num?)?.toInt() ?? 0;

                      return Expanded(
                        child: Icon(
                          getWeatherIcon(weatherCode),
                          size: 30,
                          color: isSelected
                          ? Colors.white
                          : const Color.fromARGB(103, 255, 255, 255)

                        ));
                    }))),
                

                const SizedBox(height: 10),
            
                SizedBox(
                  width: 370,
                  height: 400,
                  child: SfCartesianChart(
                    borderWidth: 0,
                    plotAreaBorderWidth: 0,
                    series: <RangeColumnSeries>[
                      RangeColumnSeries<ChartSampleData, DateTime>(
                        dataSource: chartData,
                        xValueMapper: (ChartSampleData data, _) => data.x,
                        highValueMapper: (ChartSampleData data, _) => data.high,
                        lowValueMapper: (ChartSampleData data, _) => data.low,
            
                        pointColorMapper: (data, index) {
                          return index == selectedIndex
                            ? Colors.white
                            : const Color.fromARGB(60, 209, 238, 252);
                        },
            
                        dataLabelSettings: const DataLabelSettings(
                          isVisible: true,
                          textStyle: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        borderRadius: const BorderRadius.all(Radius.circular(20)),
                        borderWidth: 1.0,
                        borderColor: Colors.white,
                      )
                    ],
                    primaryXAxis: DateTimeAxis(
                      edgeLabelPlacement: EdgeLabelPlacement.shift,
                      dateFormat: DateFormat.E(),
                      intervalType: DateTimeIntervalType.days,
                      interval: 1,
                      labelAlignment: LabelAlignment.start,
                      isVisible: false,
                    ),
                    primaryYAxis: NumericAxis(
                      isVisible: false,
                      labelFormat: '{value}°C',
                      majorGridLines: const MajorGridLines(width: 0),
                    ),
                  ),
                ),
            
                const SizedBox(height: 5),
            
                SizedBox(
                  width: 350,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: List.generate(chartData.length, (index) {
                      final data = chartData[index];
                      final isSelected = index == selectedIndex;
                      return Expanded(
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 4),
                          padding: EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                              ? Colors.white
                              : Color.fromARGB(60, 209, 238, 252),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(width: 1.0, color: Colors.white),
                          ),
                          child: Column(
                            children: [
                              Icon(Icons.water_drop, size: 24, color: isSelected ? Theme.of(context).primaryColor : Colors.white),
                              SizedBox(height: 4),
                              Text("${data.rain}%",
                                style: TextStyle(color: isSelected ? Theme.of(context).primaryColor : Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                              SizedBox(height: 15),
                              Transform.rotate(
                                angle: directionToRadians(data.windDirection),
                                child: Icon(Icons.arrow_upward, size: 20, color: isSelected ? Theme.of(context).primaryColor : Colors.white)),
                              SizedBox(height: 2),
                              Text("${data.windSpeed}",
                              textAlign: TextAlign.center,
                              style: TextStyle(color: isSelected ? Theme.of(context).primaryColor : Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                                Text("KM/H",
                              textAlign: TextAlign.center,
                              style: TextStyle(color: isSelected ? Theme.of(context).primaryColor : Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                             ],
                          ),
                        ),
                      );
                    }),
                  ),
                ),
            
                const SizedBox(height: 30),
                Padding(
                  padding: EdgeInsets.fromLTRB(32, 10, 20, 0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      DateFormat('EEEE d MMMM yyyy').format(selectedChart.x).toUpperCase(),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),)),
                Padding(
                  padding: const EdgeInsets.only(top:4.0),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(60, 255, 255, 255),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white, width: 1)
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _infoBox(
                              label: "UV INDEX",
                              value: "${(selectedDay['uvIndex'] ?? 0).round()}"
                            ),
                            _infoBox(
                              label: "HUMIDITY",
                              value: "${(selectedDay['humidity'] ?? 0).round()}%"
                            ),
                            _infoBox(
                              label: "VISIBILITY",
                              value: "${((selectedDay['visibility'] ?? 0) / 1000).toStringAsFixed(1)} KM"

                            ),
                          ]
                        ),
                        SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _infoBox(
                              label: "PRESSURE",
                              value: "${(selectedDay['pressure'] ?? 0).round()} MB"
                            ),
                            _infoBox(
                              label: "TOTAL PRECIPITATION",
                              value: "${(selectedDay['totalPrecipitation']).toStringAsFixed(1)} MM",
                            ),
                            _infoBox(
                              label: "CLOUD COVER",
                              value: "${(selectedDay['cloudCover'] ?? 0).round()}%"
                            )
                          ],
                        )
                      ],)
                  ),
                )
              ],
            
            ),
          ),
        ),
      ),
    );
  }
}

/*List<ChartSampleData> getChartData() {
  return <ChartSampleData>[
    ChartSampleData(DateTime(2025, 5, 16), 18, 10, 50, 18, "N", 5, 35, 50, "high", 1018, 35),
    ChartSampleData(DateTime(2025, 5, 17), 20, 11, 45, 10, "W", 6, 40, 50, "high", 1020, 15),
    ChartSampleData(DateTime(2025, 5, 18), 22, 13, 20, 5, "SE", 5, 43, 55, "low", 1032, 13),
    ChartSampleData(DateTime(2025, 5, 19), 25, 17, 15, 15, "SSE", 7, 34, 65, "high", 1023, 5),
    ChartSampleData(DateTime(2025, 5, 20), 27, 22, 0, 11, "ENE", 9, 56, 70, "high", 1017, 2),
    ChartSampleData(DateTime(2025, 5, 21), 24, 21, 5, 16, "SW", 8, 43, 60, "high", 1020, 3),
    ChartSampleData(DateTime(2025, 5, 22), 21, 13, 18, 20, "SE", 6, 48, 53, "low", 1022, 73),
  ];
}*/

class ChartSampleData {
  ChartSampleData({required this.x, required this.high, required this.low, required this.rain, required this.windSpeed, required this.windDirection,});
  final DateTime x;
  final double high;
  final double low;
  final int rain;
  final int windSpeed;
  final double windDirection;  
}

double directionToRadians(num directionDegrees) {
  return directionDegrees * (3.1415926535 / 180);
}

String degreesToCompass(double degrees) {
  const directions = [
    'N', 'NNE', 'NE', 'ENE',
    'E', 'ESE', 'SE', 'SSE',
    'S', 'SSW', 'SW', 'WSW',
    'W', 'WNW', 'NW', 'NNW',
  ];

  final index = ((degrees % 360) / 22.5).round() % 16;
  return directions[index];
}



void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => WeatherProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: DailyWeather(),
      ),
    ),
  );
}

IconData getWeatherIcon(int code) {
  if (code == 0) return WeatherIcons.day_sunny;
  if (code == 1 || code == 2) return WeatherIcons.day_cloudy;
  if (code == 3) return WeatherIcons.cloud;
  if (code == 45 || code == 48) return WeatherIcons.fog;
  if (code >= 51 && code <= 55) return WeatherIcons.sprinkle;
  if (code >= 56 && code <= 57) return WeatherIcons.raindrop;
  if (code >= 61 && code <= 65) return WeatherIcons.rain;
  if (code >= 66 && code <= 67) return WeatherIcons.rain_mix;
  if (code >= 71 && code <= 75) return WeatherIcons.snow;
  if (code == 77) return WeatherIcons.snowflake_cold;
  if (code >= 80 && code <= 82) return WeatherIcons.showers;
  if (code >= 85 && code <= 86) return WeatherIcons.snow_wind;
  if (code == 95) return WeatherIcons.thunderstorm;
  if (code == 96 || code == 99) return WeatherIcons.thunderstorm;
  return WeatherIcons.na;
}