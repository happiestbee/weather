import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:weather/src/journey.dart';
import '../data/weather_provider.dart';

enum MarkerType { start, waypoint, destination }

class RouteMap extends StatefulWidget {
  const RouteMap({
    super.key,
    required this.currentRoute,
    required this.onChanged,
  });

  final Journey currentRoute;
  final VoidCallback onChanged;

  @override
  State<RouteMap> createState() => _RouteMapState();
}

class _RouteMapState extends State<RouteMap> {
  late GoogleMapController mapController;

  final LatLng _center = const LatLng(52.20963295675581, 0.12386308381583826);

  bool _addingMarker = false;
  MarkerType? _markerTypeToAdd;
  // WeatherMarker? _startMarker;
  // WeatherMarker? _destinationMarker;
  // final List<WeatherMarker> _waypointMarkers = [];

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  Future<void> _onMapTapped(LatLng position) async {
    if (_addingMarker && _markerTypeToAdd != null) {
      setState(() {
        _addingMarker = false;
      });
      final weatherProvider = Provider.of<WeatherProvider>(context, listen: false);
      await weatherProvider.fetchWeather(position.latitude, position.longitude);
      final weatherData = weatherProvider.weatherData;
      double? temp;
      if (weatherData != null) {
        final current = weatherProvider.weatherService.getCurrentWeather(weatherData);
        temp = current['temperature']?.toDouble();
      }
      setState(() {
        if (_markerTypeToAdd == MarkerType.start) {
          // Create a new WeatherMarker for the start position
          // and assign it to the current route
          widget.currentRoute.start = WeatherMarker(
            position: position,
            temperature: temp,
            name: 'Start',
            type: MarkerType.start,
          );
        } else if (_markerTypeToAdd == MarkerType.destination) {
          // Create a new WeatherMarker for the destination position
          widget.currentRoute.dest = WeatherMarker(
            position: position,
            temperature: temp,
            name: 'Destination',
            type: MarkerType.destination,
          );
        } else if (_markerTypeToAdd == MarkerType.waypoint) {
          // Create a new WeatherMarker for the waypoint position
          widget.currentRoute.addWaypoint(
            WeatherMarker(
              position: position,
              temperature: temp,
              // Use the length of the waypoints list to name the waypoints in order
              // User can change the name in the text field
              name: 'Waypoint ${widget.currentRoute.waypoints.length + 1}',
              type: MarkerType.waypoint,
            ),
          );
        }
        widget.onChanged();
        _markerTypeToAdd = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    // Create Marker's based on the WeatherMarker objects in the current route
    Marker? startMarker = widget.currentRoute.start != null
        ? Marker(
            markerId: const MarkerId('start_marker'),
            position: widget.currentRoute.start!.position,
            infoWindow: InfoWindow(
              // Use the temperature from the WeatherMarker object
              // May want to display more weather data
              title: widget.currentRoute.start!.temperature != null ? 'Start: ${widget.currentRoute.start!.temperature!.toStringAsFixed(1)}°C' : 'Start: Loading...'),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          )
        : null; 

    Marker? destinationMarker = widget.currentRoute.dest != null
      ? Marker(
          markerId: const MarkerId('destination_marker'),
          position: widget.currentRoute.dest!.position,
          infoWindow: InfoWindow(
            title: widget.currentRoute.dest!.temperature != null ? 'Destination: ${widget.currentRoute.dest!.temperature!.toStringAsFixed(1)}°C' : 'Destination: Loading...'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        )
      : null;

    List<Marker> waypointMarkers = widget.currentRoute.waypoints.map((marker) {
      return Marker(
        markerId: MarkerId('waypoint_marker_${marker.position.latitude}_${marker.position.longitude}'),
        position: marker.position,
        infoWindow: InfoWindow(
          title: marker.temperature != null ? '${marker.name}: ${marker.temperature!.toStringAsFixed(1)}°C' : 'Waypoint: Loading...'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      );
    }).toList();

    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.green[700],
      ),
      home: Scaffold(
        body: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  flex: 2,
                  child: GoogleMap(
                    onMapCreated: _onMapCreated,
                    initialCameraPosition: CameraPosition(
                      target: _center,
                      zoom: 11.0,
                    ),
                    markers: {
                      if (startMarker != null) startMarker,
                      if (destinationMarker != null) destinationMarker,
                      ...waypointMarkers,
                    },
                    zoomGesturesEnabled: true,
                    onTap: _onMapTapped,
                  ),
                ),
              ],
            ),
            Positioned(
              top: 40,
              right: 20,
              child: CircleAvatar(
                radius: 21,
                backgroundColor: Colors.green[700],
                child: PopupMenuButton<MarkerType>(
                  color: Colors.white,
                  icon: const Icon(Icons.add, color: Colors.white, size: 24),
                  onSelected: (MarkerType type) {
                    setState(() {
                      _addingMarker = true;
                      _markerTypeToAdd = type;
                    });
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: MarkerType.start,
                      enabled: startMarker == null,
                      child: const Text('Add Start'),
                    ),
                    PopupMenuItem(
                      value: MarkerType.waypoint,
                      child: const Text('Add Waypoint'),
                    ),
                    PopupMenuItem(
                      value: MarkerType.destination,
                      enabled: destinationMarker == null,
                      child: const Text('Add Destination'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WeatherMarker {
  final LatLng position;
  final double? temperature;
  String name;
  final MarkerType type;
  WeatherMarker({required this.position, required this.temperature, required this.name, required this.type});
}