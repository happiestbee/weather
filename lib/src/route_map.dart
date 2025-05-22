import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../data/weather_provider.dart';

enum MarkerType { start, waypoint, destination }

class RouteMap extends StatefulWidget {
  const RouteMap({super.key});
  @override
  State<RouteMap> createState() => _RouteMapState();
}

class _RouteMapState extends State<RouteMap> {
  late GoogleMapController mapController;

  final LatLng _center = const LatLng(52.20963295675581, 0.12386308381583826);

  bool _addingMarker = false;
  MarkerType? _markerTypeToAdd;
  _WeatherMarker? _startMarker;
  _WeatherMarker? _destinationMarker;
  final List<_WeatherMarker> _waypointMarkers = [];

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
          _startMarker = _WeatherMarker(
            position: position,
            temperature: temp,
            name: 'Start',
            type: MarkerType.start,
          );
        } else if (_markerTypeToAdd == MarkerType.destination) {
          _destinationMarker = _WeatherMarker(
            position: position,
            temperature: temp,
            name: 'Destination',
            type: MarkerType.destination,
          );
        } else if (_markerTypeToAdd == MarkerType.waypoint) {
          _waypointMarkers.add(_WeatherMarker(
            position: position,
            temperature: temp,
            name: 'Waypoint',
            type: MarkerType.waypoint,
          ));
        }
        _markerTypeToAdd = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
                      if (_startMarker != null)
                        Marker(
                          markerId: const MarkerId('start_marker'),
                          position: _startMarker!.position,
                          infoWindow: InfoWindow(
                            title: _startMarker!.temperature != null ? 'Start: ${_startMarker!.temperature!.toStringAsFixed(1)}°C' : 'Start: Loading...'),
                          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
                        ),
                      if (_destinationMarker != null)
                        Marker(
                          markerId: const MarkerId('destination_marker'),
                          position: _destinationMarker!.position,
                          infoWindow: InfoWindow(
                            title: _destinationMarker!.temperature != null ? 'Destination: ${_destinationMarker!.temperature!.toStringAsFixed(1)}°C' : 'Destination: Loading...'),
                            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
                          ),                     
                      ..._waypointMarkers.asMap().entries.map((entry) => Marker(
                        markerId: MarkerId('waypoint_marker_${entry.key}_${entry.value.position.latitude}_${entry.value.position.longitude}'),
                        position: entry.value.position,
                        infoWindow: InfoWindow(
                          title: entry.value.temperature != null ? 'Waypoint: ${entry.value.temperature!.toStringAsFixed(1)}°C' : 'Waypoint: Loading...'),
                        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
                      )),
                    },
                    zoomGesturesEnabled: true,
                    onTap: _onMapTapped,
                  ),
                ),
                Expanded(
                  child: Stack(
                    children: [
                      Placeholder(color: Colors.blue),
                      if (_addingMarker)
                        Positioned.fill(
                          child: IgnorePointer(
                            child: Container(
                              color: Colors.black.withValues(alpha: 0.4),
                            ),
                          ),
                        ),
                    ],
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
                      enabled: _startMarker == null,
                      child: const Text('Add Start'),
                    ),
                    PopupMenuItem(
                      value: MarkerType.waypoint,
                      child: const Text('Add Waypoint'),
                    ),
                    PopupMenuItem(
                      value: MarkerType.destination,
                      enabled: _destinationMarker == null,
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

class _WeatherMarker {
  final LatLng position;
  final double? temperature;
  final String name;
  final MarkerType type;
  _WeatherMarker({required this.position, required this.temperature, required this.name, required this.type});
}