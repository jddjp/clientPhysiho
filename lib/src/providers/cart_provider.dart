import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:clientPhysiho/src/config/constants.dart';
import 'package:clientPhysiho/src/helpers/utils_helper.dart';
import 'package:clientPhysiho/src/models/order_item_model.dart';
import 'package:clientPhysiho/src/models/order_model.dart';
import 'package:clientPhysiho/src/providers/location_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartProvider with ChangeNotifier {
  SharedPreferences _prefs;
  OrderModel _order;
  String _orderInProgress;
  bool hasService = true; // We have service on client address?

  // Getter
  OrderModel get order => _order;
  List<OrderItemModel> get items => _order != null ? _order.items : [];
  String get orderInProgress => _orderInProgress;

  // Constructor
  CartProvider() {
    // Initialize cart model
    initialize();
  }

  void initialize() async {
    _prefs = await SharedPreferences.getInstance();
    _order = new OrderModel();

    // Check for a order in progress
    _orderInProgress = _prefs.getString('orderInProgress');
    if (hasOrderInProgress()) {
      // Get order info
      DocumentSnapshot orderRef = await FirebaseFirestore.instance.collection('orders').doc(_orderInProgress).get();
      Map<String,dynamic> currentOrder = orderRef.data();

      // Delete order in progress
      if (currentOrder['status'] == ORDER_FINISHED || currentOrder['status'] == ORDER_CANCELED) {
        clearOrderInProgress();
      }
    }

    // Calulcate user distance
    calculateDeliveryData();

    notifyListeners();
  }

  bool hasItems() => items.length > 0;
  bool hasOrderInProgress() {
    return _orderInProgress != null && _orderInProgress != '';
  }

  void addItem(OrderItemModel orderItem) {
    if (_order.business != null && orderItem.item.business != _order.business ) {
      Fluttertoast.showToast(
        msg: "No puedes hacer un pedido de diferentes negocios al mismo tiempo."
      );
      return;
    }

    if (hasOrderInProgress()) {
      Fluttertoast.showToast(
        msg: "No puedes ordenar hasta que se complete tu pedido en progreso."
      );
      return;
    }

    _order.business = orderItem.item.business;
    _order.items.add(orderItem);
    notifyListeners();
  }

  void removeItem(String id){
    _order.items.removeWhere((element) => element.id == id);
    notifyListeners();
  }

  /*
   * Check if cart is empty
   */
  bool isEmpty() {
    return _order.items.length == 0;
  }

  void clearOrderInProgress() {
    _prefs.remove('orderInProgress');
    _orderInProgress = null;
    notifyListeners();
  }

  void setAddress(BuildContext context, LatLng location) async {
    _order.location = location;
    // Get address info
    List<Placemark> placemarks = await placemarkFromCoordinates(location.latitude, location.longitude);
    _order.deliveryAddress = placemarks[0];

    // Calculate new deliveryData
    calculateDeliveryData();

    //
    notifyListeners();
  }

  Placemark getAddress(BuildContext context) {
    // Get from location
    if (_order.deliveryAddress == null) {
      _order.deliveryAddress = Provider.of<LocationProvider>(context).getAddress();
    }

    return _order.deliveryAddress;
  }

  LatLng getLocation(BuildContext context) {
    if (_order.location == null) {
      _order.location = Provider.of<LocationProvider>(context).getLocation();
    }

    return _order.location;
  }

  void calculateDeliveryData({ LatLng userLocation }) async {
    LatLng centerLocation = LatLng(19.282906, -98.435506); // Zocalo de Texmelucan

    // If no set location, we calculate based on last known position
    if (userLocation == null) {
      if (_order.deliveryAddress == null || _order.location == null) {
        Position position = await Geolocator.getLastKnownPosition();
        userLocation = LatLng(
          position.latitude,
          position.longitude
        );
      } else {
        userLocation = _order.location;
      }
    }

    // Calculate delivery distance
    double distance = Geolocator.distanceBetween(
      centerLocation.latitude, centerLocation.longitude,
      userLocation.latitude, userLocation.longitude
    );

    _order.distance = distance;

    // San Martín Centro
    hasService = true;
    if (_order.distance < DELIVERY_ZONE0) {
      _order.deliveryCost = DELIVERY_COST_ZONE0;
    } else if (_order.distance < DELIVERY_ZONE1) {
      _order.deliveryCost = DELIVERY_COST_ZONE1;
    } else if (_order.distance < DELIVERY_ZONE2) {
      _order.deliveryCost = DELIVERY_COST_ZONE2;
    } else if (_order.distance < DELIVERY_ZONE3) {
      _order.deliveryCost = DELIVERY_COST_ZONE3;
    } else if (_order.distance < DELIVERY_ZONE4) {
      _order.deliveryCost = DELIVERY_COST_ZONE4;
    } else {
      hasService = false;
    }

    notifyListeners();
  }

  Future<DocumentReference> createOrder(BuildContext context) async {
    CollectionReference orders = FirebaseFirestore.instance.collection('orders');
    DocumentReference client = FirebaseFirestore.instance.collection('users').doc(_prefs.getString('uid'));

    if (_order.deliveryAddress == null) {
      _order.deliveryAddress = Provider.of<LocationProvider>(context, listen: false).getAddress();
    }

    if (_order.location == null) {
      _order.location = Provider.of<LocationProvider>(context, listen: false).location();
    }

    DocumentSnapshot businessDoc = await _order.business.get();
    Map<String, dynamic> businessData = businessDoc.data();
    DocumentSnapshot clientDoc = await client.get();
    Map<String, dynamic> clientData = clientDoc.data();
    String phoneNumber = clientData['phone'];
    if (phoneNumber != null && phoneNumber.startsWith("+52")) {
      phoneNumber = phoneNumber.replaceAll("+", "").replaceFirst("52", "");
    }

    // Make order
    DocumentReference order = await orders.add({
        'number': getUID(6),
        'business': _order.business,
        'business_name': businessData['name'],
        'business_address': businessData['address'],
        'client': client,
        'client_name': clientData['name'],
        'client_phone': phoneNumber.toString(),
        'client_address': "${_order.deliveryAddress.street}, ${_order.deliveryAddress.subLocality}",
        'client_location': GeoPoint(_order.location.latitude, _order.location.longitude ),
        'subtotal': _order.subtotal,
        'delivery_cost': _order.deliveryCost,
        'delivery_distance': _order.distance,
        'total': _order.total,
        'payment_method': _order.paymentMethod,
        'payment_status': 'pending',
        'status': 'received',
        'status_step': 1,
        'time': FieldValue.serverTimestamp(), // Time when this order has been created
        'comment': _order.comment != '' ? _order.comment : 'Sin comentarios',
        'items': items.map((OrderItemModel item) {
          return {
            'name': item.item.name,
            'image': item.item.image != null ? item.item.image.url : null,
            'description': item.item.description,
            'quantity': item.quantity,
            'comment': item.comment,
            'subtotal': item.price,
            'total': item.total,
            'options': item.options
          };
        }).toList(),
        'order_processor': businessData['order_processor'],
        'driver_current_step': 1, // For driver
      });

    // Save current order
    _prefs.setString('orderInProgress', order.id);


    // Reset current
    _order = new OrderModel();
    notifyListeners();

    // Finished
    return Future.value(order);
  }
}