import 'package:flutter/material.dart';
import 'package:weather/src/journey.dart';

class RouteScreen extends StatefulWidget {
  const RouteScreen({super.key});

  @override
  State<StatefulWidget> createState() => _RouteScreenState();
  
}

class _RouteScreenState extends State<RouteScreen> { 
  
  // Currently journey's just store strings for locations
  // TODO: Match name to lat/lon
  Journey currentRoute = Journey();  
  var savedRoutes = <Journey>[];  

  late TextEditingController startController;
  late List<TextEditingController> waypointControllers;
  late TextEditingController destController;

  @override
  void initState() {
    super.initState();
    _initControllers();  
  }

  // Initialize the text controllers for the start, waypoints, and destination text fields
  void _initControllers() {
    startController = TextEditingController(text: currentRoute.start.getName());
    waypointControllers = currentRoute.waypoints.map(
      (w) => TextEditingController(text: w.getName()))
      .toList();
    destController = TextEditingController(text: currentRoute.dest.getName());
  }

  // Dispose of the text controllers to free up resources
  void _disposeControllers() {
    startController.dispose();
    for (var controller in waypointControllers) {
      controller.dispose();
    }
    destController.dispose();
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
      startController.text = currentRoute.start.getName();
      destController.text = currentRoute.dest.getName();
      // Dispose of the old waypoint controllers there may be more than we need
      for (var controller in waypointControllers) {
        controller.dispose();
      }
      // Create new waypoint controllers for the new route
      waypointControllers = currentRoute.waypoints.map(
        (w) => TextEditingController(text: w.getName()))
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
          // TODO: Edit text fields to apper more like as shown in the design          
          // TODO: Add ability to set start time or time at each waypoint?
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Start text field
                    TextField(
                      controller: startController,
                      decoration: InputDecoration(labelText: "Start"),
                      onChanged: (value) {
                        setState(() {
                          currentRoute.setStart(Location(value));
                        });
                      },
                    ),
                    // List of text fields for waypoints
                    ...List.generate(
                      currentRoute.waypoints.length,
                      (i) => TextField(
                        controller: waypointControllers[i],
                        decoration: InputDecoration(labelText: "Waypoint ${i + 1}"),
                        onChanged: (value) {
                          setState(() {
                            currentRoute.setWaypoint(Location(value), i);
                          });
                        },
                      ),
                    ),
                    // Button to add a new waypoint
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          currentRoute.addWaypoint(Location("New Waypoint"));
                          waypointControllers.add(TextEditingController());
                        });
                      },
                      child: Text("Add Waypoint"),
                    ),
                    // Destination text field
                    TextField(
                      controller: destController,
                      decoration: InputDecoration(labelText: "Destination"),
                      onChanged: (value) {
                        setState(() {
                          currentRoute.setDest(Location(value));
                        });
                      },
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
