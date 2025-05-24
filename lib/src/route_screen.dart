import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weather/src/journey.dart';
import 'package:weather/src/route_manager.dart';
import 'package:weather/src/route_map.dart';
import 'package:weather/src/waypoint_bar.dart';

class RouteScreen extends StatefulWidget {
  const RouteScreen({super.key});

  @override
  State<StatefulWidget> createState() => _RouteScreenState();
  
}

class _RouteScreenState extends State<RouteScreen> {  // Instance of the route manager
  
  // Text controllers for the locations
  late TextEditingController startController;
  late List<TextEditingController> waypointControllers;
  late TextEditingController destController;

  // Text controllers for the start and end times
  late TextEditingController startTimeController;
  late TextEditingController endTimeController;  

  @override
  void initState() {
    super.initState(); 
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final routeManager = Provider.of<RouteManager>(context, listen: false);
    
    // Initialize the text controllers    
    _initControllers(routeManager);
    
  }

  // return a text controller for the location text field of a given marker
  TextEditingController _locationController(WeatherMarker? marker) {
    return TextEditingController(text: 
      (marker != null) 
        ? marker.name 
        : ""
    );
  }

  // return a text controller for the time text field of a given time
  TextEditingController _timeController(DateTime? time) {
    return TextEditingController(text: 
      (time != null) 
        ? TimeOfDay.fromDateTime(time).format(context) 
        : ""
    );
  }

  // Initialize the text controllers for the start, waypoints, and destination text fields
  void _initControllers(RouteManager routeManager) {    
    final currentRoute = routeManager.currentRoute;

    startController = _locationController(currentRoute.start);
    destController = _locationController(currentRoute.dest);

    waypointControllers = currentRoute.waypoints.map(
      (w) => _locationController(w)).toList();    

    startTimeController = _timeController(currentRoute.startTime);
    endTimeController = _timeController(currentRoute.endTime);
  }

  // Dispose of the text controllers to free up resources
  void _disposeControllers() {
    startController.dispose();
    destController.dispose();

    for (var controller in waypointControllers) {
      controller.dispose();
    }
    
    startTimeController.dispose();
    endTimeController.dispose(); 
  }

  // Interpolate waypoint times
  List<TimeOfDay?> _interpolatedWaypointTimes(RouteManager rm) {
    final currentRoute = rm.currentRoute;
    if (currentRoute.startTime == null || currentRoute.endTime == null || currentRoute.waypoints.isEmpty) {
      // Cannot calculate times if start or end time is null or no waypoints
      return List.filled(currentRoute.waypoints.length, null);
    }
    final start = currentRoute.startTime!;
    final end = currentRoute.endTime!;
    final total = end.difference(start).inMinutes; // total duration in minutes
    if (total < 0) {
      // If the end time is after the start time, return null for all waypoints
      return List.filled(currentRoute.waypoints.length, null);
    }

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
  void favorite(RouteManager routeManager) {
    routeManager.toggleSaveCurrentRoute();
  }

  // Create a new route
  void newRoute(RouteManager rm) => changeRoute(rm, Journey());

  // Change the current route to a new one and update the text controllers
  void changeRoute(rm, Journey route) {
    setState(() {
      rm.currentRoute = route;
      _disposeControllers();
      _initControllers(rm);
    });
  }

  @override
  Widget build(BuildContext context) {  
    final routeManager = Provider.of<RouteManager>(context);
    final currentRoute = routeManager.currentRoute;
    final savedRoutes = routeManager.savedRoutes;

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

    List<TimeOfDay?> waypointTimes = _interpolatedWaypointTimes(routeManager); 
     
    return Scaffold(      
      body: Column(
        children: [
          Expanded(
            child: RouteMap(
              currentRoute: currentRoute,
              // On changed callback to update the controllers and route 
              // when a marker is added or deleted
              onChanged: () => setState(() {_disposeControllers(); _initControllers(routeManager);}),
            ),
          ),
          Row(
            children: [
              // Save button in the top left
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        favorite(routeManager);
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
                      // map each joruney to a dropDownMenu item for that journey
                      return DropdownMenuItem<Journey>(
                        value: r,
                        child: Text(r.toString()),
                      );
                    }).toList(),
                    onChanged: (Journey? selected) {
                      // When a route is selected, change the current route
                      if (selected != null) {
                        setState(() => changeRoute(routeManager, selected));                        
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
                        newRoute(routeManager);
                      });
                    },
                    child: Text("New Route"),
                  ),
                ),
              ),
            ],  
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
                      // onChanged used so this widget can be rebuilt when the waypointBar changes
                      onChanged: () => setState(() {}),                      
                    ), 
                    SizedBox(height: 16.0),                                     
                    // List of text fields for waypoints
                    ...List.generate(
                      currentRoute.waypoints.length,
                      (i) => WaypointBar(
                        locationController: waypointControllers[i],
                        timeController: TextEditingController(text: waypointTimes[i]?.format(context)),
                        route: currentRoute,
                        type: LocationType.waypoint,
                        waypointIndex: i,
                        onChanged: () => setState(() {}), 
                      ),                        
                    ),                    
                    // Button to add a new waypoint
                    SizedBox(height: 16.0),
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