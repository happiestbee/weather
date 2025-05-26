import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weather/data/weather_provider.dart';
import 'package:weather/src/location_bar.dart';

class HourlyScreen extends StatefulWidget{
  final WeatherProvider weatherProvider = WeatherProvider();

  HourlyScreen({
    super.key,
  });
 
  @override
  State<StatefulWidget> createState() => _HourlyScreenState();
}

class _HourlyScreenState extends State<HourlyScreen> {


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Column(
        children: [
          SizedBox(height: 150,child: LocationBar()),
          HourlyUpdatedArea(),
        ],
      )
    );   

  }
}

class HourlyUpdatedArea extends StatefulWidget{

  const HourlyUpdatedArea({
    super.key,
  });
 
  @override
  State<StatefulWidget> createState() => _HourlyUpdatedArea();
}

class _HourlyUpdatedArea extends State<HourlyUpdatedArea>{
  var currentDay = SelectedDay();

  @override
  Widget build(BuildContext context){
    final weatherProvider = Provider.of<WeatherProvider>(context);
    if (weatherProvider.weatherData != null){
      return Column(
        children: [
          DaySelect(updateOnSelect: this, currentDay: currentDay, weatherProvider: weatherProvider,),
          HourlyDisplay(currentDay: currentDay, weatherProvider: weatherProvider,),
        ]);
    }
    else{
      return Column(children: [Icon(Icons.square) ,Text("due to a error this has not loaded, this may be fixed by selecting a location")]);
    }
  }
}

class HourlyDisplay extends StatefulWidget{
  final SelectedDay currentDay;
  final WeatherProvider weatherProvider;

  const HourlyDisplay({
    super.key,
    required this.currentDay,
    required this.weatherProvider,
  });
 
  @override
  State<StatefulWidget> createState() => _HourlyDisplayState();
}

class _HourlyDisplayState extends State<HourlyDisplay>{


  @override
  Widget build(BuildContext context){
    var weatherService = widget.weatherProvider.weatherService;
    List<Map<String, dynamic>> dataSet;
    if (widget.weatherProvider.weatherData != null){
      dataSet = weatherService.getHourlyWeather(widget.weatherProvider.weatherData!);
    }
    else{
      return Icon(Icons.circle);
    }
    DateTime now = DateTime.now();
    DateTime then = now.add(Duration(days: widget.currentDay.x));

    List<Widget> cols = List.empty(growable: true);
    for (Map<String,dynamic> x in dataSet){
      if (then.day == x["time"].day){
        cols.add(HourData(ind: x["time"].hour,
        temperature: x["temperature"],
        rainChance: x["precipitationProbability"],
        windDir: x["windDirection"]*pi/180.0,
        windSpeed: x["windSpeed"],
        uvVal: x["uvIndex"],
        cloudCoverage: x["cloudCoverage"],
      ));
      }
    }
    //for (var i = 0; i < 24; i++) HourData(ind: i, rainChance: (i*i*widget.currentDay.x)%101, windDir: i.toDouble(), windSpeed: i.toDouble(), uvVal: (i*i*i)%10,),

    return SizedBox(
      height: 450,
      child: DecoratedBox(
        decoration: BoxDecoration(border: Border.symmetric(horizontal: BorderSide(color: Colors.white)), color: Color.fromARGB(19, 209, 238, 252),),
        child: ListView(
          itemExtent: 75,
          scrollDirection: Axis.horizontal,
          children: 
            cols,
        ),
      ),
    );
  }
}
class HourData extends StatefulWidget{
  final int ind;
  final double temperature;
  final double rainChance;
  final double windDir;
  final double windSpeed;
  final double uvVal;
  final double cloudCoverage;


  const HourData({
    super.key,
    required this.ind,
    required this.temperature,
    required this.rainChance,
    required this.windDir,
    required this.windSpeed,
    required this.uvVal,
    required this.cloudCoverage,
  });


  @override
  State<StatefulWidget> createState() => _HourDataState();
}

class _HourDataState extends State<HourData>{

  @override
  Widget build(BuildContext context){

    // mph not kmph
    // ref for bike users?
    var windCat = switch (widget.windSpeed) {
      >= 0 && < 7 => "still",
      >= 7 && < 13 => "calm",
      >= 13 && < 19 => "modest",
      >= 19 && < 25 => "strong",
      >= 25 && < 33 => "very strong",
      >= 33 && < 41 => "risk",
      >= 41 => "danger",
      _ => "error",
    };

    var rainLevel = switch (widget.rainChance){
      >= 60.0 => 2,
      >= 30.0 => 1,
      _ => 0
    };
    var cloudLevel = switch (widget.cloudCoverage){
      >= 75.0 => 2,
      >= 25.0 => 1,
      _ => 0
    };

    var weatherIcon = switch ([rainLevel, cloudLevel]){
      [2,_] => Icon(Icons.water_drop,size: 50, color: Color.fromRGBO(16, 2, 121, 1),),
      [1,_] => Icon(Icons.cloudy_snowing,size: 50, color: Color.fromRGBO(16, 2, 121, 1),),
      [0,2] => Icon(Icons.cloud, size: 50, color: Color.fromRGBO(161, 161, 161, 1),),
      _ => Icon(Icons.sunny,size: 50,color:Color.fromRGBO(243, 243, 11, 1)),
    };

    return Column(
      children: [
        SizedBox(height: 7),
        Text("${widget.ind.toString().padLeft(2,'0')}:00", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),),
        Container(padding: EdgeInsets.fromLTRB(0.0, 8.0, 0.0, 8.0),
          child: Column(children: [
            Text("${((widget.temperature*10.0).roundToDouble()/10.0)}°C", style: TextStyle(fontSize: 20),),
            weatherIcon,
        ],),),
        Text("${widget.rainChance.toString()}%", style: TextStyle(fontSize: 20),),
        
        Container(padding: EdgeInsets.fromLTRB(0.0, 12.0, 0.0, 4.0),
          child:
            SizedBox(height: 120,
              child: Column(children: [
                Transform.rotate(angle: widget.windDir, child: SizedBox(
                    height: 60,
                    width: 40,
                    child: Stack(children: 
                            [Align(alignment: Alignment(0.0,1.0), child: Icon(Icons.circle, size: 40, color: Color.fromARGB(255, 0, 0, 0),)),
                            Align(alignment: Alignment(0.0,-1.0), child: Icon(Icons.north, size: 40, color: Color.fromARGB(255, 0, 0, 0),)),
                            Align(alignment: Alignment(0.0, 0.5), child: Transform.rotate(angle: -widget.windDir, 
                              child: Text(((widget.windSpeed*10.0).roundToDouble()/10.0).toString(), style: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),),))],),
            ),),
            Text(windCat.toUpperCase(), style: TextStyle(fontSize: 16.0), textAlign: TextAlign.center,),
        ],),),),

        SizedBox(height: 150,
          child: Column(
            spacing: 5.0,
            children: [
            Text("UV\n${(widget.uvVal*10.0).roundToDouble()/10.0}",style: TextStyle(fontSize: 19.0), textAlign: TextAlign.center,),
            Text("CLOUD\n${(widget.cloudCoverage*10.0).roundToDouble()/10.0}%", style: TextStyle(fontSize: 19.0), textAlign: TextAlign.center),
        ],),),
      ],
    );
  }
}

class DaySelect extends StatefulWidget{
  final State<StatefulWidget> updateOnSelect;
  final SelectedDay currentDay;
  final WeatherProvider weatherProvider;

  const DaySelect({
    super.key,
    required this.updateOnSelect,
    required this.currentDay,
    required this.weatherProvider,
  });
 
  @override
  State<StatefulWidget> createState() => _DaySelectState();
  
}


class _DaySelectState extends State<DaySelect>{

  @override
  Widget build(BuildContext context){
    var weatherService = widget.weatherProvider.weatherService;
    DateTime now = DateTime.now();
    List<int> days = List.empty(growable: true);
    if (widget.weatherProvider.weatherData != null){
      List<Map<String, dynamic>> dataSet = weatherService.getHourlyWeather(widget.weatherProvider.weatherData!);
      for (Map<String,dynamic> x in dataSet){
        var daysTill = x["time"].difference(now).inDays;
        if (!days.contains(daysTill)){
          days.add(daysTill);
        }
      }
    }
    List<Widget> widgets = List.empty(growable: true);
    for (int x in days){
      widgets.add(
        DaySelectable(ind: x, sd: widget.currentDay, updateOnSelect: widget.updateOnSelect,)
      );
    }



    return SizedBox(
      width: 600,
      height: 75,
      child: ListView(
        itemExtent: 100,
        padding: const EdgeInsets.fromLTRB(8,8,8,8),
        scrollDirection: Axis.horizontal,
        children: widgets,
      )
    );

  }
}

class DaySelectable extends StatefulWidget{
  final int ind;
  final SelectedDay sd;
  final State<StatefulWidget> updateOnSelect;


  const DaySelectable({
    super.key,
    required this.ind,
    required this.sd,
    required this.updateOnSelect
  });

  @override
  State<StatefulWidget> createState() => _DaySelectableState();
}

class _DaySelectableState extends State<DaySelectable>{
  late int ind;
  late SelectedDay sd;
  late State<StatefulWidget> updateOnSelect;

  @override
  void initState() {
    super.initState();
    ind = widget.ind;
    sd = widget.sd;
    updateOnSelect = widget.updateOnSelect;
  }

  @override
  Widget build(BuildContext buildContext){

    var day = DateTime.now().add(Duration(days: ind));
    var weekDay = switch (day.weekday-1) {
      0 => "Mon",
      1 => "Tue",
      2 => "Wed",
      3 => "Thu",
      4 => "Fri",
      5 => "Sat",
      6 => "Sun",
      _ => "error"
    };

    return ElevatedButton.icon(
        onPressed: () {updateOnSelect.setState(() {sd.x = ind;});},
        label: Center(
          child: Text(
            "$weekDay\n${day.day}/${day.month}",
            style: TextStyle(
              color: sd.x == ind ? Theme.of(context).primaryColor : Colors.white,
              fontSize: 20.0,
            ),
            textAlign: TextAlign.center,
          )
        ),
        style: ElevatedButton.styleFrom(backgroundColor: sd.x == ind ? Colors.white : Color.fromARGB(60,209,238, 252)),
      );
  }
}

class SelectedDay{
  var x = 0;
}