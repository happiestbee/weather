import 'dart:math';
import 'package:weather/src/route_map.dart';

class Journey { 

  WeatherMarker? start;
  List<WeatherMarker> waypoints = [];
  WeatherMarker? dest;

  DateTime? startTime;
  DateTime? endTime;

  Journey();

  Future<void> addWaypoint(WeatherMarker marker, {int? i}) async{
    if (i == null) {
      waypoints.add(marker);
    } else {
      waypoints.insert(i, marker);
    }
  }
  
  void removeWaypoint(int i) {
    if (i < waypoints.length) {
      waypoints.removeAt(i);
    }
  }

  String shortenedName(WeatherMarker? marker) {
    if (marker == null || marker.name.isEmpty) {
      return "???";
    }
    return marker.name.substring(0, min(3, marker.name.length)).toUpperCase();
  }

  void setStartName(String name) {
    if (start != null) {
      start!.name = name;
    }
  }

  void setDestName(String name) {
    if (dest != null) {
      dest!.name = name;
    }
  }

  void setWaypointName(String name, int i) {
    if (i < waypoints.length) {
      waypoints[i].name = name;
    }
  }

  @override
  String toString(){
      return "${shortenedName(start)} - ${shortenedName(dest)}";
  }
}
