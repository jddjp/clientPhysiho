
import 'package:flutter/cupertino.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationProvider with ChangeNotifier {

  LocationPermission _permission = LocationPermission.denied;
  bool _permissionChecked = false;
  Position _position;
  Placemark _address;

  Placemark get address => _address;
  
  // Get location
  LatLng location () {
    return LatLng(_position.latitude, _position.longitude);
  }

  bool isPermissionChecked() => _permissionChecked;

  bool hasPermission() => _permission == LocationPermission.always || _permission == LocationPermission.whileInUse;

  LocationProvider() {
    initialize();
  }

  void initialize() async {
    _permission = await Geolocator.checkPermission();
    _permissionChecked = true;
    if (hasPermission()) {
      _position = await Geolocator.getLastKnownPosition();
      List<Placemark> placemarks = await placemarkFromCoordinates(_position.latitude, _position.longitude);
      _address = placemarks[0];
    }
    notifyListeners();
  }

  void setPosition(Position position) async {
    _permission = await Geolocator.checkPermission();
    _position = position;
    List<Placemark> placemarks = await placemarkFromCoordinates(_position.latitude, _position.longitude);
    _address = placemarks[0];
    notifyListeners();
  }

  LatLng getLocation() {
    return LatLng(_position.latitude, _position.longitude);
  }

  Placemark getAddress() {
    return _address;
  }
}