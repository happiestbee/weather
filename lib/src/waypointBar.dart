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
    // Create an input decoration for the text fields when provided with a label
  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      filled: true,
      fillColor: const Color.fromARGB(255, 183, 211, 224),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(     
          child: TextField(
            controller: widget.locationController,
            decoration: _inputDecoration("Waypoint"),
            onChanged: (value) {
              setState(() {
                switch (widget.type) {
                  case LocationType.start:
                    widget.route.setStart(value);
                  case LocationType.waypoint:
                    widget.route.setWaypoint(value, widget.waypointIndex!);
                  case LocationType.dest:
                    widget.route.setDest(value);
                }
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
            onTap: () {
              setState(() {            
                if (widget.type != LocationType.waypoint) {
                  
                  Future<TimeOfDay?> time = showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),                
                  );
                  time.then((value) {
                    if (value != null) {
                      DateTime dateTime = DateTime(
                        DateTime.now().year,
                        DateTime.now().month,
                        DateTime.now().day,
                        value.hour,
                        value.minute,
                      );
                      switch (widget.type) {
                        case LocationType.start:
                          widget.route.startTime = dateTime;
                          print(widget.route.startTime);
                        case LocationType.waypoint:
                          break;
                        case LocationType.dest:
                          widget.route.endTime = dateTime;
                      }
                    }
                    widget.timeController.text = value?.format(context) ?? "";
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