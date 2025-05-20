import 'dart:math';

class Journey {
  
  Location start = Location("???");
  var waypoints = <Location>[];
  Location dest = Location("???");

  Journey() {
    waypoints = List<Location>.empty(growable: true);
  }
  
  void setStart(Location start) {
    this.start=start;
  }

  void setDest(Location dest) {
    this.dest = dest;
  }

  void addWaypoint(Location waypoint, {int i = -1}) {
    if (i == -1) {
      waypoints.add(waypoint);
    } else {
      waypoints.insert(i, waypoint);
    }
  }

  void setWaypoint(Location waypoint, int i) {
    if (i < waypoints.length) {
      waypoints[i] = waypoint;
    }
  }

  void removeWaypoint(int i) {
    if (i < waypoints.length) {
      waypoints.removeAt(i);
    }
  }

  @override
  String toString(){
      return "${start.shortened()} - ${dest.shortened()}";
  }


   
}

class Location {

  final String name;     
  const Location(this.name); 

  String shortened() {
    return name.substring(0, min(3,name.length));
  }

  String getName() {return name;}

}