// @dart=2.9
import 'package:flutter/cupertino.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationProvider with ChangeNotifier {
  SharedPreferences _prefs;
  LocationPermission _permission = LocationPermission.denied;
  bool _permissionChecked = false;
  Position _position;
  Placemark _address;

  Placemark get address => _address;

  // Get location
  LatLng location() {
    return LatLng(_position.latitude, _position.longitude);
  }

  bool isPermissionChecked() => _permissionChecked;

  bool hasPermission() =>
      _permission == LocationPermission.always ||
      _permission == LocationPermission.whileInUse;

  LocationProvider() {
    initialize();
  }

  void initialize() async {
    _prefs = await SharedPreferences.getInstance();
    _position = await _determinePosition();

    print("///////LOCATION////");
    print(_position);

    if (_position != null) {
      List<Placemark> placemarks = await placemarkFromCoordinates(
          _position.latitude, _position.longitude);
      _address = placemarks[0];
    }
    /*_permission = await Geolocator.checkPermission();
    _permissionChecked = true;

    print("///////LOCATION////");
    print(_permission);

    if (hasPermission()) {
      _prefs.setBool('locationPermission', true);
      _position = await Geolocator.getLastKnownPosition();
      if (_position != null) {
        List<Placemark> placemarks = await placemarkFromCoordinates(
            _position.latitude, _position.longitude);
        _address = placemarks[0];
      }
    } */
    notifyListeners();
  }

  /// Determine the current position of the device.
  ///
  /// When the location services are not enabled or permissions
  /// are denied the `Future` will return an error.
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;
    _prefs = await SharedPreferences.getInstance();

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permantly denied, we cannot request permissions.');
    }

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        return Future.error(
            'Location permissions are denied (actual value: $permission).');
      }
    }

    return await Geolocator.getCurrentPosition();
  }

  void setPosition(Position position) async {
    _permission = await Geolocator.checkPermission();
    _position = position;
    List<Placemark> placemarks =
        await placemarkFromCoordinates(_position.latitude, _position.longitude);
    _address = placemarks[0];
    notifyListeners();
  }

  LatLng getLocation() {
    return LatLng(_position.latitude, _position.longitude);
  }

  Placemark getAddress() {
    return _address;
  }

  String shortAddress() {
    if (_address != null) {
      return "${_address.street} ${_address.subLocality}";
    }

    return "Cargando dirección...";
  }
}
