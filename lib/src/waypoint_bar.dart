import 'package:flutter/material.dart';
import 'package:weather/src/journey.dart';

enum LocationType {
  start,
  waypoint,
  dest,
}

class WaypointBar extends StatefulWidget {  
  
  final VoidCallback onChanged;
  final TextEditingController locationController;
  final TextEditingController timeController;
  final Journey route;
  final LocationType type;
  final int? waypointIndex;

  const WaypointBar({
    super.key,
    required this.locationController,
    required this.timeController, 
    required this.route,
    required this.type,
    this.waypointIndex,
    required this.onChanged,
  });

  @override
  State<WaypointBar> createState() => _WaypointBarState();
}

class _WaypointBarState extends State<WaypointBar> {
  
  // Return an input decoration for text fields, provided with a label
  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      filled: true,
      fillColor: Theme.of(context).primaryColor, //Color.fromARGB(255, 183, 211, 224),
      labelStyle: TextStyle(
        color: Theme.of(context).textTheme.bodyMedium?.color,
      ),
    );
  }

  // Return a label for location field based on the type of location
  String get _label {
    switch (widget.type) {
      case LocationType.start:
        return "Start";
      case LocationType.waypoint:
        return "Waypoint ${widget.waypointIndex! + 1}";
      case LocationType.dest:
        return "Destination";
    }
  }

  @override
  Widget build(BuildContext context) {

    // If the location does not exist, user should not be able to 
    // set its name or time
    bool locationExists;
    // Check if the location exists based on the type
    switch(widget.type) {
      case LocationType.start:
        locationExists = widget.route.start != null;
      case LocationType.waypoint:
        locationExists = true; // if the waypoint did not exist, it would not be shown 
      case LocationType.dest:
        locationExists = widget.route.dest != null;
    }

    return Row(
      children: [
        Expanded(     
          child: TextField( // text field for the location name
            controller: widget.locationController,
            decoration: _inputDecoration(_label),            
            enabled: locationExists,
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
            onChanged: (value) {
              // update the name of the location based on the type
              setState(() {
                switch (widget.type) {
                  case LocationType.start:
                    widget.route.setStartName(value);
                  case LocationType.waypoint:
                    widget.route.setWaypointName(value, widget.waypointIndex!);
                  case LocationType.dest:
                    widget.route.setDestName(value);
                }
                // call the onChanged function to rebuil route_screen
                widget.onChanged();
              });
            },
          ),          
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.2,
          child: TextField(            
            controller: widget.timeController,
            decoration: _inputDecoration("Time"),
            readOnly: true,
            enabled: locationExists,
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
            onTap: () {
              setState(() {       
                // only able to edit time for start and destination
                // waypoint time is linearly intepolated 
                // could be changed to allow user to set time for waypoint    
                if (widget.type != LocationType.waypoint) {
                  
                  // User only allowed to select time of day
                  Future<TimeOfDay?> time = showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),                
                  );

                  time.then((value) {
                    if (value != null) {
                      DateTime dateTime = DateTime(
                        // day of the year is set to current day
                        DateTime.now().year,
                        DateTime.now().month,
                        DateTime.now().day,
                        value.hour,
                        value.minute,
                      );
                      // assign the time to the start or end of the route
                      switch (widget.type) {                        
                        case LocationType.start:
                          widget.route.startTime = dateTime;
                        case LocationType.waypoint:
                          break;
                        case LocationType.dest:
                          widget.route.endTime = dateTime;
                      }
                    } 
                    // update the text field with the selected time                   
                    widget.timeController.text = value?.format(context) ?? "";
                    // call the onChanged function to update the route
                    // this is needed to update the time of the waypoints
                    widget.onChanged();  
                  }); 
                }           
              });                                 
            },
          ),
        ),      
      ],
    );
  }
}