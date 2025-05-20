import 'package:flutter/material.dart';


class HourlyScreen extends StatefulWidget{
  const HourlyScreen({super.key});
 
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
          HourlyUpdatedArea(),
          SizedBox(height: 100) // reserved for screen select
        ],
      )
    );   

  }
}

class HourlyUpdatedArea extends StatefulWidget{
  const HourlyUpdatedArea({super.key});
 
  @override
  State<StatefulWidget> createState() => _HourlyUpdatedArea();
}

class _HourlyUpdatedArea extends State<HourlyUpdatedArea>{

  var currentDay = SelectedDay();
  
  @override
  Widget build(BuildContext context){
    return Column(
      children: [
        DaySelect(updateOnSelect: this, currentDay: currentDay,),
        HourlyDisplay(currentDay: currentDay,),
      ]
    );
  }
}

class HourlyDisplay extends StatefulWidget{
  final SelectedDay currentDay;

  const HourlyDisplay({
    super.key,
    required this.currentDay,
  });
 
  @override
  State<StatefulWidget> createState() => _HourlyDisplayState();
}

class _HourlyDisplayState extends State<HourlyDisplay>{

  @override
  Widget build(BuildContext context){
    return SizedBox(
      width: 600,
      height: 300,
      child: ListView(
        itemExtent: 75,
        scrollDirection: Axis.horizontal,
        children: [
          for (var i = 0; i < 24; i++) HourData(ind: i, rainChance: (i*i*widget.currentDay.x)%101, windDir: i.toDouble(), windSpeed: i.toDouble(), uvVal: (i*i*i)%10,),
        ],
      ),
    );
  }
}
class HourData extends StatefulWidget{
  final int ind;
  final int rainChance;
  final double windDir;
  final double windSpeed;
  final int uvVal;


  const HourData({
    super.key,
    required this.ind,
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
        Text("${widget.rainChance.toString()}%", style: TextStyle(fontSize: 20),),
        
        Transform.rotate(angle: widget.windDir, child: SizedBox(
            height: 60,
            width: 40,
            child: Stack(children: 
                    [Align(alignment: Alignment(0.0,1.0), child: Icon(Icons.circle, size: 40, color: Color.fromARGB(255, 0, 0, 0),)),
                    Align(alignment: Alignment(0.0,-1.0), child: Icon(Icons.north, size: 40, color: Color.fromARGB(255, 0, 0, 0),)),
                    Align(alignment: Alignment(0.0, 0.5), child: Transform.rotate(angle: -widget.windDir, child: Text(widget.windSpeed.toString(), style: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),),))],),
        ),),
        
        Text(windCat, style: TextStyle(fontSize: 20.0),),
        Text("UV-${widget.uvVal}",style: TextStyle(fontSize: 20.0),)
      ],
    );
  }
}

class DaySelect extends StatefulWidget{
  final State<StatefulWidget> updateOnSelect;
  final SelectedDay currentDay;

  const DaySelect({
    super.key,
    required this.updateOnSelect,
    required this.currentDay,
  });
 
  @override
  State<StatefulWidget> createState() => _DaySelectState();
  
}


class _DaySelectState extends State<DaySelect>{

  @override
  Widget build(BuildContext context){

    return SizedBox(
      width: 600,
      height: 75,
      child: ListView(
        itemExtent: 100,
        padding: const EdgeInsets.fromLTRB(8,8,8,8),
        scrollDirection: Axis.horizontal,
        children: [
          for (var i = 0; i < 14; i++) DaySelectable(ind: i, sd: widget.currentDay, updateOnSelect: widget.updateOnSelect,),
        ],
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