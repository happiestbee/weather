import 'package:flutter/material.dart';
import 'package:weather/src/journey.dart';
import 'package:weather/src/location_bar.dart';
import 'package:weather/src/waypointBar.dart';

class RouteScreen extends StatefulWidget {
  const RouteScreen({super.key});

  @override
  State<StatefulWidget> createState() => _RouteScreenState();
  
}

class _RouteScreenState extends State<RouteScreen> { 
  
  // TODO: Match name to lat/lon
  Journey currentRoute = Journey();  
  var savedRoutes = <Journey>[];  

  late TextEditingController startController;
  late List<TextEditingController> waypointControllers;
  late TextEditingController destController;
  late TextEditingController startTimeController;
  late TextEditingController endTimeController;

  @override
  void initState() {
    super.initState();
    _initControllers();  
  }

  // Initialize the text controllers for the start, waypoints, and destination text fields
  void _initControllers() {
    startController = TextEditingController(text: currentRoute.start.name);
    waypointControllers = currentRoute.waypoints.map(
      (w) => TextEditingController(text: w.name))
      .toList();
    destController = TextEditingController(text: currentRoute.dest.name);
    startTimeController = TextEditingController(
      text: currentRoute.startTime != null
          ? currentRoute.startTime!.toString()
          : "");
    endTimeController = TextEditingController(
        text: currentRoute.endTime != null
            ? TimeOfDay.fromDateTime(currentRoute.endTime!).format(context)
            : "");
  }

  // Dispose of the text controllers to free up resources
  void _disposeControllers() {
    startController.dispose();
    for (var controller in waypointControllers) {
      controller.dispose();
    }
    destController.dispose();
    startTimeController.dispose();
    endTimeController.dispose(); 
  }

  // Helper to interpolate waypoint times
  List<TimeOfDay?> _interpolatedWaypointTimes() {
    if (currentRoute.startTime == null || currentRoute.endTime == null || currentRoute.waypoints.isEmpty) {
      return List.filled(currentRoute.waypoints.length, null);
    }
    final start = currentRoute.startTime!;
    final end = currentRoute.endTime!;
    final total = end.difference(start).inMinutes;
    final n = currentRoute.waypoints.length + 1;
    return List.generate(
      currentRoute.waypoints.length,
      (i) => TimeOfDay.fromDateTime(
        start.add(Duration(minutes: ((i + 1) * total ~/ n))),
      ),
    );
  }

  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
  }

  // Toggle the favorite status of the current route
  void favorite() {
    if (savedRoutes.contains(currentRoute)) {
      savedRoutes.remove(currentRoute);
    } else{
      savedRoutes.add(currentRoute);
    }
  }

  // Create a new route
  void newRoute() => changeRoute(Journey());

  // Change the current route to a new one and update the text controllers
  void changeRoute(Journey route) {
    setState(() {
      currentRoute = route;
      startController.text = currentRoute.start.name;
      destController.text = currentRoute.dest.name;
      startTimeController.text = currentRoute.startTime != null
          ? TimeOfDay.fromDateTime(currentRoute.startTime!).format(context)
          : "";
      endTimeController.text = currentRoute.endTime != null
          ? TimeOfDay.fromDateTime(currentRoute.endTime!).format(context)
          : "";
      // Dispose of the old waypoint controllers there may be more than we need
      for (var controller in waypointControllers) {
        controller.dispose();
      }
      // Create new waypoint controllers for the new route
      waypointControllers = currentRoute.waypoints.map(
        (w) => TextEditingController(text: w.name))
        .toList();
    });
  }

  @override
  Widget build(BuildContext context) {  

    // Icon to indicate whether the current route is saved or not
    IconData favoriteIcon = savedRoutes.contains(currentRoute)
        ? Icons.favorite      
        : Icons.favorite_border;      

    // List of routes that includes the current route as well as all saved routes
    // This is used to populate the dropdown menu
    List<Journey> dropdownRoutes = List.from(savedRoutes);
    if (!dropdownRoutes.contains(currentRoute)) {
      dropdownRoutes.add(currentRoute);
    }

    List<TimeOfDay?> waypointTimes = _interpolatedWaypointTimes();   

    return Scaffold(      
      body: Column(
        children: [
          Row(
            children: [
              // Save button in the top left
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        favorite();
                      });
                    },
                    icon: Icon(favoriteIcon),
                    label: Text("Save"),
                  ),
                ),
              ),
              // Route list in the top center
              Expanded(
                child: Align(
                  alignment: Alignment.center,
                  child: DropdownButton<Journey>(
                    hint: Text("Select Route"),
                    value: currentRoute,                    
                    items: dropdownRoutes.map((Journey r) {
                      return DropdownMenuItem<Journey>(
                        value: r,
                        child: Text(r.toString()),
                      );
                    }).toList(),
                    onChanged: (Journey? selected) {
                      if (selected != null) {
                        setState(() => changeRoute(selected));                        
                      }
                    },
                  ),
                ),
              ),
              // New Route button in the top right
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        newRoute();
                      });
                    },
                    child: Text("New Route"),
                  ),
                ),
              ),
            ],  
          ),
          // Route map placeholder
          // TODO: Replace with actual map widget
          Expanded(
            child: Container(
              color: Colors.blueGrey[100],
              child: Center(
                child: Text("Map Placeholder"),
              ),
            ),
          ),
          // Text fields for start, each waypoint, and destination
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Start text field
                    WaypointBar(
                      locationController: startController,
                      timeController: startTimeController,
                      route: currentRoute,                    
                      type: LocationType.start,
                      onChanged: () =>setState(() {}),                      
                    ),                                      
                    // List of text fields for waypoints
                    ...List.generate(
                      currentRoute.waypoints.length,
                      (i) => WaypointBar(
                        locationController: waypointControllers[i],
                        timeController: TextEditingController(
                          text: waypointTimes[i]?.format(context),
                        ),
                        route: currentRoute,
                        type: LocationType.waypoint,
                        waypointIndex: i,
                        onChanged: () => setState(() {}),
                      ),                        
                    ),                    
                    // Button to add a new waypoint
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          currentRoute.addNewWaypoint();
                          waypointControllers.add(TextEditingController());
                        });
                      },
                      child: Text("Add Waypoint"),
                    ),
                    // Destination text field                    
                    WaypointBar(
                      locationController: destController,
                      timeController: endTimeController,
                      route: currentRoute,
                      type: LocationType.dest, 
                      onChanged: () => setState(() {}),             
                    ),
                  ],
                ),
              ),
            ),
          ),
        ], 
      ),
    );
  }
}