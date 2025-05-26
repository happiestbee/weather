import 'package:weather/src/journey.dart';
import 'package:flutter/material.dart';

class RouteManager extends ChangeNotifier {

  Journey currentRoute = Journey();
  List<Journey> savedRoutes = [];

  // Method to update the current route
  void setCurrentRoute(Journey newRoute) {
    currentRoute = newRoute;
    notifyListeners();
  }

  void toggleSaveCurrentRoute() {
    if (!savedRoutes.contains(currentRoute)) {
      savedRoutes.add(currentRoute);      
    } else {
      savedRoutes.remove(currentRoute);
    }
    notifyListeners();
  }

  void removeSavedRoute(Journey route) {
    savedRoutes.remove(route);
    notifyListeners();
  }

  void newRoute() {
    currentRoute = Journey();
    notifyListeners();
  }
}