

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:clientPhysiho/src/config/constants.dart';
import 'package:clientPhysiho/src/helpers/utils_helper.dart';
import 'package:clientPhysiho/src/models/order_item_model.dart';
import 'package:clientPhysiho/src/models/order_model.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/extension_helper.dart';
import '../views/login_view.dart';
import 'login_provider.dart';

class CartProvider with ChangeNotifier {
  SharedPreferences? _prefs;
  OrderModel _order = OrderModel();
  String _orderInprogress1 = '';
  bool hasService = true; // We have service on client address?
  Map<String, dynamic>? _coupon;

  // Getter
  OrderModel get order => _order;
  List<OrderItemModel> get items => _order.items;
  String get orderInprogress1 => _orderInprogress1;
  Map<String, dynamic>? get coupon => _coupon;
  bool get hasCoupon => _coupon != null;

  // Constructor
  CartProvider() {
    initialize();
  }

  Future<void> initialize() async {
    _prefs ??= await SharedPreferences.getInstance();
    notifyListeners();
  }

  bool hasItems() => items.length > 0;
  bool hasOrderInprogress1() {
    return _orderInprogress1 != '';
  }

  void addItem(OrderItemModel orderItem) {
    final itemBusiness = orderItem.item?.business;
    if (itemBusiness != null && _order.business != null &&
        itemBusiness != _order.business) {
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

    if (itemBusiness != null) {
      _order.business = itemBusiness;
    }
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
    return _order.items.length == 0;
  }

  void clearOrderInprogress() {
    _prefs?.remove('orderInprogress');
    _orderInprogress1 = '';
    notifyListeners();
  }

  void setAddress(BuildContext context, LatLng location) async {
    _order.location = location;
    // Get address info
    List<Placemark> placemarks =
        await placemarkFromCoordinates(location.latitude, location.longitude);
    _order.deliveryAddress = placemarks.isNotEmpty ? placemarks[0] : null;



    //
    notifyListeners();
  }

  Placemark? getAddress(BuildContext context) {
    return _order.deliveryAddress;
  }

  LatLng? getLocation(BuildContext context) {
    return _order.location;
  }




  void deleteCoupon() {
    _coupon = null;
    notifyListeners();
  }

  double couponDiscount() {
    if (_coupon == null) return 0.0;
    switch (_coupon!['target']) {
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
  
    return 0.0;
  }

  String discountLabel() {
    if (_coupon == null) return 'Cupón de descuento';
    String label = "Cupón de descuento";
    if (_coupon!['discount_type'] == 'percentage') {
      return label + " ${_coupon!['amount']}%";
    }

    return label;
  }

  double calculateDiscount(amount) {
    if (_coupon == null) return 0.0;
    double couponAmount = (_coupon!['amount'] as num).toDouble();
    double discount = _coupon!['discount_type'] == 'fixed'
        ? couponAmount
        : (amount * (couponAmount / 100));
    return discount;
  }

  double deliveryCost() {
    if (_coupon != null && _coupon!['target'] == DISCOUNT_DELIVERY) {
      return order.deliveryCost - calculateDiscount(order.deliveryCost);
    }

    return order.deliveryCost;
  }

  double orderTotal() {
    double total = order.subtotal;
    final couponTarget = _coupon?['target'];

    switch (couponTarget) {
      case DISCOUNT_SUBTOTAL:
        total = total - couponDiscount() + order.deliveryCost;
        break;
      case DISCOUNT_DELIVERY:
        total = total + deliveryCost();
        break;
      case DISCOUNT_TOTAL:
        total = (total + order.deliveryCost) - couponDiscount();
        break;
      default:
        total = total + order.deliveryCost;
        break;
    }

    return total;
  }

  Future<DocumentReference> createOrder(BuildContext context) async {
    _prefs ??= await SharedPreferences.getInstance();

    if (!Provider.of<LoginProvider>(context, listen: false).isLoggedIn()) {
      _prefs?.setBool("cartWithItems", true);
      launchScreen(context, LoginView.routeName);
      return Future.error("No logged");
    }

    final uid = _prefs?.getString('uid');
    if (uid == null || uid.isEmpty) {
      return Future.error("No user uid");
    }

    CollectionReference orders =
        FirebaseFirestore.instance.collection('orders');
    DocumentReference client = FirebaseFirestore.instance
        .collection('users')
        .doc(uid);

    final businessRef = _order.business;
    if (businessRef == null) {
      return Future.error("No business selected");
    }

    DocumentSnapshot businessDoc = await businessRef.get();
    final businessData = businessDoc.data() as Map<String, dynamic>? ?? <String, dynamic>{};
    DocumentSnapshot clientDoc = await client.get();
    final clientData = clientDoc.data() as Map<String, dynamic>? ?? <String, dynamic>{};
    String phoneNumber = clientData['phone']?.toString() ?? '';
    if (phoneNumber.startsWith("+52")) {
      phoneNumber = phoneNumber.replaceAll("+", "").replaceFirst("52", "");
    }

    // Make order
    final deliveryAddress = _order.deliveryAddress;
    final location = _order.location;
    final itemImage = items.isNotEmpty && items.first.item?.image != null ? items.first.item!.image!.url : '';

    DocumentReference order = await orders.add({
      'number': getUID(6),
      'business': businessRef,
      'business_name': businessData['name'] ?? '',
      'business_address': businessData['address'] ?? '',
      'client': client,
      'client_name': clientData['name'] ?? '',
      'client_phone': phoneNumber.toString(),
      'client_address': deliveryAddress != null
          ? "${deliveryAddress.street}, ${deliveryAddress.subLocality ?? ''}"
          : '',
      'client_location': location != null
          ? GeoPoint(location.latitude, location.longitude)
          : const GeoPoint(0, 0),
      'subtotal': _order.subtotal,
      'delivery_cost': deliveryCost(),
      'delivery_distance': _order.distance,
      'discount': couponDiscount(),
      'total': orderTotal(),
      'payment_method': _order.paymentMethod,
      'payment_status': 'pending',
      'coupon': _coupon?['code'],
      'status': 'received',
      'status_step': 1,
      'time': FieldValue.serverTimestamp(),
      'comment': _order.comment != '' ? _order.comment : 'Sin comentarios',
      'items': items.map((OrderItemModel item) {
        final imageUrl = item.item?.image?.url ?? itemImage;
        return {
          'name': item.item?.name ?? '',
          'image': imageUrl,
          'description': item.item?.description ?? '',
          'quantity': item.quantity,
          'comment': item.comment,
          'subtotal': item.price,
          'total': item.total,
          'options': item.options
        };
      }).toList(),
      'order_processor': businessData['order_processor'],
      'driver_current_step': 1,
    });

    _prefs?.setString('orderInprogress1', order.id);

    // Reset current
    _order = new OrderModel();
    notifyListeners();

    // Finished
    return Future.value(order);
  }
}
