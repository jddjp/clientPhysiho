// @dart=2.9

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:clientPhysiho/src/config/constants.dart';
import 'package:clientPhysiho/src/helpers/utils_helper.dart';
import 'package:clientPhysiho/src/models/order_item_model.dart';
import 'package:clientPhysiho/src/models/order_model.dart';
import 'package:clientPhysiho/src/providers/location_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/extension_helper.dart';
import '../views/login_view.dart';
import 'login_provider.dart';

class CartProvider with ChangeNotifier {
  SharedPreferences _prefs;
  OrderModel _order;
  String _orderInprogress1;
  bool hasService = true; // We have service on client address?
  Map<String, dynamic> _coupon;

  // Getter
  OrderModel get order => _order;
  List<OrderItemModel> get items => _order != null ? _order.items : [];
  String get orderInprogress1 => _orderInprogress1;
  Map<String, dynamic> get coupon => _coupon;
  bool get hasCoupon => _coupon != null;

  // Constructor
  CartProvider() {
    // Initialize cart model
    initialize();
  }

  void initialize() async {




    notifyListeners();
  }

  bool hasItems() => items.length > 0;
  bool hasOrderInprogress1() {
    return _orderInprogress1 != null && _orderInprogress1 != '';
  }

  void addItem(OrderItemModel orderItem) {
    if (_order.business != null && orderItem.item.business != _order.business) {
      Fluttertoast.showToast(
          msg:
              "No puedes hacer un pedido de diferentes negocios al mismo tiempo.");
      return;
    }

    if (hasOrderInprogress1()) {
      Fluttertoast.showToast(
          msg:
              "No puedes ordenar hasta que se complete tu pedido en progreso.");
      return;
    }

    _order.business = orderItem.item.business;
    _order.items.add(orderItem);
    notifyListeners();
  }

  void removeItem(String id) {
    _order.items.removeWhere((element) => element.id == id);
    notifyListeners();
  }

  /*
   * Check if cart is empty
   */
  bool isEmpty() {
    return _order == null || _order.items.length == 0;
  }

  void clearOrderInprogress() {
    _prefs.remove('orderInprogress');
    _orderInprogress1 = null;
    notifyListeners();
  }

  void setAddress(BuildContext context, LatLng location) async {
    _order.location = location;
    // Get address info
    List<Placemark> placemarks =
        await placemarkFromCoordinates(location.latitude, location.longitude);
    _order.deliveryAddress = placemarks[0];



    //
    notifyListeners();
  }

  Placemark getAddress(BuildContext context) {
    // Get from location
    if (_order.deliveryAddress == null) {
      _order.deliveryAddress =
          Provider.of<LocationProvider>(context).getAddress();
    }

    return _order.deliveryAddress;
  }

  LatLng getLocation(BuildContext context) {
    if (_order.location == null) {
      _order.location = Provider.of<LocationProvider>(context).getLocation();
    }

    return _order.location;
  }




  void deleteCoupon() {
    _coupon = null;
    notifyListeners();
  }

  double couponDiscount() {
    if (_coupon != null) {
      switch (_coupon['target']) {
        case DISCOUNT_SUBTOTAL:
          return calculateDiscount(order.subtotal);
          break;
        case DISCOUNT_DELIVERY:
          return calculateDiscount(order.deliveryCost);
          break;
        case DISCOUNT_TOTAL:
          return calculateDiscount(order.total);
          break;
      }
    }

    return 0.0;
  }

  String discountLabel() {
    String label = "Cupón de descuento";
    if (_coupon != null && _coupon['discount_type'] == 'percentage') {
      return label + " ${_coupon['amount']}%";
    }

    return label;
  }

  double calculateDiscount(amount) {
    double couponAmount = _coupon['amount'].toDouble();
    double discount = _coupon['discount_type'] == 'fixed'
        ? couponAmount
        : (amount * (couponAmount / 100));
    return discount;
  }

  double deliveryCost() {
    if (_coupon != null && _coupon['target'] == DISCOUNT_DELIVERY) {
      return order.deliveryCost - calculateDiscount(order.deliveryCost);
    }

    return order.deliveryCost;
  }

  double orderTotal() {
    double total = order.subtotal;

    if (_coupon != null) {
      switch (_coupon['target']) {
        case DISCOUNT_SUBTOTAL:
          total = total - couponDiscount() + order.deliveryCost;
          break;
        case DISCOUNT_DELIVERY:
          total = total + deliveryCost();
          break;
        case DISCOUNT_TOTAL:
          total = (total + order.deliveryCost) - couponDiscount();
          break;
      }
    } else {
      total += order.deliveryCost;
    }

    return total;
  }

  Future<DocumentReference> createOrder(BuildContext context) async {
    if (!Provider.of<LoginProvider>(context, listen: false).isLoggedIn()) {
      _prefs.setBool(
          "cartWithItems", true); // This hack will be used on main.dart
      launchScreen(context, LoginView.routeName);
      return Future.error("No logged");
    }

    CollectionReference orders =
        FirebaseFirestore.instance.collection('orders');
    DocumentReference client = FirebaseFirestore.instance
        .collection('users')
        .doc(_prefs.getString('uid'));

    if (_order.deliveryAddress == null) {
      _order.deliveryAddress =
          Provider.of<LocationProvider>(context, listen: false).getAddress();
    }

    if (_order.location == null) {
      _order.location =
          Provider.of<LocationProvider>(context, listen: false).location();
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
      'client_address':
          "${_order.deliveryAddress.street}, ${_order.deliveryAddress.subLocality}",
      'client_location':
          GeoPoint(_order.location.latitude, _order.location.longitude),
      'subtotal': _order.subtotal,
      'delivery_cost': deliveryCost(),
      'delivery_distance': _order.distance,
      'discount': couponDiscount(),
      'total': orderTotal(),
      'payment_method': _order.paymentMethod,
      'payment_status': 'pending',
      'coupon': _coupon != null ? _coupon['code'] : null,
      'status': 'received',
      'status_step': 1,
      'time':
          FieldValue.serverTimestamp(), // Time when this order has been created
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
    _prefs.setString('orderInprogress1', order.id);

    // Reset current
    _order = new OrderModel();
    notifyListeners();

    // Finished
    return Future.value(order);
  }
}
