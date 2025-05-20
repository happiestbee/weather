import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:provider/provider.dart';
import 'package:weather/data/weather_provider.dart';

class LocationCoords {
  final String name;
  final double latitude;
  final double longitude;

  const LocationCoords({
    required this.name,
    required this.latitude,
    required this.longitude,
  });

  // Add equality operator to properly compare Location objects
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocationCoords &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          latitude == other.latitude &&
          longitude == other.longitude;

  @override
  int get hashCode => name.hashCode ^ latitude.hashCode ^ longitude.hashCode;
}

class LocationProvider with ChangeNotifier {
  final WeatherProvider _weatherProvider;
  
  LocationCoords _currentLocation = const LocationCoords(
    name: 'Jesus College',
    latitude: 52.23641063484651, 
    longitude: 0.12211946514801025,
  );
  final List<LocationCoords> _savedLocations = [LocationCoords(
    name: 'Jesus College',
    latitude: 52.23641063484651, 
    longitude: 0.12211946514801025,
  )];

  LocationProvider(this._weatherProvider);  // Constructor takes WeatherProvider

  LocationCoords get currentLocation => _currentLocation;
  List<LocationCoords> get savedLocations => _savedLocations;

  void setCurrentLocation(LocationCoords location) {
    _currentLocation = location;
    notifyListeners();
    // Now we can directly use the weather provider
    _weatherProvider.fetchWeather(location.latitude, location.longitude);
  }

  void addLocation(LocationCoords location) {
    if (!_savedLocations.contains(location)) {
      _savedLocations.add(location);
      notifyListeners();
    }
  }

  Future<void> addLocationFromName(String name) async {
    try {
      List<Location> locations = await locationFromAddress(name);
      if (locations.isNotEmpty) {
        LocationCoords loc = LocationCoords(
          name: name,
          latitude: locations[0].latitude,
          longitude: locations[0].longitude,
        );
        addLocation(loc);
        setCurrentLocation(loc);
      }
    } catch (e) {
      rethrow;
    }
  }

  void deleteLocation(LocationCoords location) {
    if (_savedLocations.length <= 1) {
      return;
    }
    _savedLocations.remove(location);
    // If we're deleting the current location, set the first saved location as current
    if (_currentLocation == location && _savedLocations.isNotEmpty) {
      _currentLocation = _savedLocations.first;
      _weatherProvider.fetchWeather(_currentLocation.latitude, _currentLocation.longitude);
    }
    notifyListeners();
  }
}

class LocationBar extends StatelessWidget {
  const LocationBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LocationProvider>(
      builder: (context, locationProvider, child) {
        return Container(
          padding: const EdgeInsets.only(top: 60),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Location icon
              const Icon(Icons.location_on, size: 20),
              const SizedBox(width: 8),
              // Location text with dropdown
              PopupMenuButton<LocationCoords>(
                offset: const Offset(0, 40),
                child: Row(
                  children: [
                    Text(
                      locationProvider.currentLocation.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Icon(Icons.arrow_drop_down),
                  ],
                ),
                itemBuilder: (context) => [
                  // Add new location option
                  const PopupMenuItem(
                    value: LocationCoords(name: 'add_new', latitude: 0, longitude: 0),
                    child: Row(
                      children: [
                        Icon(Icons.add),
                        SizedBox(width: 8),
                        Text('Add New Location'),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  // Saved locations
                  ...locationProvider.savedLocations.map((location) => PopupMenuItem(
                    value: location,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            location.name,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, size: 20),
                          onPressed: () {
                            // Show confirmation dialog
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Delete Location'),
                                content: Text('Are you sure you want to delete ${location.name}?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      locationProvider.deleteLocation(location);
                                      Navigator.pop(context);
                                      Navigator.pop(context); 
                                    },
                                    child: const Text('Delete'),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  )),
                ],
                onSelected: (LocationCoords? value) {
                  if (value == LocationCoords(name: 'add_new', latitude: 0, longitude: 0)) {
                    _showAddLocationDialog(context, locationProvider);
                  } else {
                    locationProvider.setCurrentLocation(value!);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddLocationDialog(BuildContext context, LocationProvider locationProvider) {
    final TextEditingController controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Location'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Location Name',
            hintText: 'Enter city name',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                try {
                  await locationProvider.addLocationFromName(controller.text);
                  Navigator.pop(context);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Error finding location')),
                  );
                }
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
