import 'dart:math';

import 'package:flutter/material.dart';
import 'package:weather/data/weather_provider.dart';

class HourlyScreen extends StatefulWidget{
  final WeatherProvider weatherProvider;

  const HourlyScreen({
    super.key,
    required this.weatherProvider,
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
          SizedBox(height: 200),// reserved for the location selector
          HourlyUpdatedArea(weatherProvider: widget.weatherProvider,),
          SizedBox(height: 100) // reserved for screen select
        ],
      )
    );   

  }
}

class HourlyUpdatedArea extends StatefulWidget{
  final WeatherProvider weatherProvider;

  const HourlyUpdatedArea({
    super.key,
    required this.weatherProvider,
  });
 
  @override
  State<StatefulWidget> createState() => _HourlyUpdatedArea();
}

class _HourlyUpdatedArea extends State<HourlyUpdatedArea>{
  bool ready = false;
  var currentDay = SelectedDay();

  @override
  void initState() {
    fetchData();
    super.initState();
  }
  
  @override
  Widget build(BuildContext context){
    if (ready){
      return Column(
        children: [
          DaySelect(updateOnSelect: this, currentDay: currentDay, weatherProvider: widget.weatherProvider,),
          HourlyDisplay(currentDay: currentDay, weatherProvider: widget.weatherProvider,),
        ]);
    }
    else{
      return Icon(Icons.square);
    }
  }

  void fetchData(){
    widget.weatherProvider.fetchWeather(50.0, 0.0).then((_){
        setState(() {
          ready = true;
        });
      }
    );
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
        uvVal: x["uvIndex"]
      ));
      }
    }
    //for (var i = 0; i < 24; i++) HourData(ind: i, rainChance: (i*i*widget.currentDay.x)%101, windDir: i.toDouble(), windSpeed: i.toDouble(), uvVal: (i*i*i)%10,),

    return SizedBox(
      width: 600,
      height: 300,
      child: ListView(
        itemExtent: 75,
        scrollDirection: Axis.horizontal,
        children: 
          cols
        ,
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


  const HourData({
    super.key,
    required this.ind,
    required this.temperature,
    required this.rainChance,
    required this.windDir,
    required this.windSpeed,
    required this.uvVal
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

    return Column(
      children: [
        Text("${widget.ind.toString().padLeft(2,'0')}:00", style: TextStyle(fontSize: 20),),
        Icon(Icons.sunny,size: 50,color: Color.fromARGB(255, 243, 243, 11),),
        Text(((widget.temperature*10.0).roundToDouble()/10.0).toString()),
        Text("${widget.rainChance.toString()}%", style: TextStyle(fontSize: 20),),
        
        Transform.rotate(angle: widget.windDir, child: SizedBox(
            height: 60,
            width: 40,
            child: Stack(children: 
                    [Align(alignment: Alignment(0.0,1.0), child: Icon(Icons.circle, size: 40, color: Color.fromARGB(255, 0, 0, 0),)),
                    Align(alignment: Alignment(0.0,-1.0), child: Icon(Icons.north, size: 40, color: Color.fromARGB(255, 0, 0, 0),)),
                    Align(alignment: Alignment(0.0, 0.5), child: Transform.rotate(angle: -widget.windDir, 
                      child: Text(((widget.windSpeed*10.0).roundToDouble()/10.0).toString(), style: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),),))],),
        ),),
        
        Text(windCat, style: TextStyle(fontSize: 20.0),),
        Text("UV-${(widget.uvVal*10.0).roundToDouble()/10.0}",style: TextStyle(fontSize: 20.0),)
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
    var day = switch (ind%7) {
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
            "$day, ${sd.x}",
            style: TextStyle(
              color: Color(0xFFFFFFFF),
              fontSize: 20.0
            )
          )
        ),
        style: ElevatedButton.styleFrom(backgroundColor: sd.x == ind ? Color(0xFF2255AA) : Color(0xFF5599FF)),
      );
  }
}

class SelectedDay{
  var x = 0;
}