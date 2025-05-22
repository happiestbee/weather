import 'dart:math';
import 'package:weather/src/location_bar.dart';

class Journey {
  
  LocationCoords start = LocationCoords(
    name: "", 
    latitude: .0, 
    longitude: .0,
  );

  var waypoints = <LocationCoords>[];

  LocationCoords dest = LocationCoords(
    name: "", 
    latitude: .0, 
    longitude: .0,
  );

  DateTime? startTime;
  DateTime? endTime;

  Journey() {
    waypoints = List<LocationCoords>.empty(growable: true);
  }

  Future<LocationCoords> createLocationFromName(String name) async {
    return LocationCoords(
        name: name,
        latitude: .0,
        longitude: .0,
      );
      // TODO: Use geocoding to get the latitude and longitude      
    }
  
  Future<void> setStart(String start) async {
    this.start=await createLocationFromName(start);
  }

  Future<void> setDest(String dest) async {
    this.dest = await createLocationFromName(dest);
  }

  Future<void> addWaypoint(String waypointName, {int i = -1}) async{
    LocationCoords waypoint = await createLocationFromName(waypointName);
    if (i == -1) {
      waypoints.add(waypoint);
    } else {
      waypoints.insert(i, waypoint);
    }
  }

  void addNewWaypoint() {
    waypoints.add(LocationCoords(
      name: "", 
      latitude: .0, 
      longitude: .0,
    ));
  }

  Future<void> setWaypoint(String waypointName, int i) async {
    LocationCoords waypoint = await createLocationFromName(waypointName);
    if (i < waypoints.length) {
      waypoints[i] = waypoint;
    }
  }

  void removeWaypoint(int i) {
    if (i < waypoints.length) {
      waypoints.removeAt(i);
    }
  }

  String shortenedName(LocationCoords location) {
    if (location.name.isEmpty) {
      return "???";
    }
    return location.name.substring(0, min(3,location.name.length));
  }

  @override
  String toString(){
      return "${shortenedName(start)} - ${shortenedName(dest)}";
  }

}
