// @dart=2.9
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:clientPhysiho/src/models/order_item_model.dart';

class OrderModel {
  // Business to send this order
  DocumentReference business;

  // Items
  List<OrderItemModel> items = [];
  Placemark deliveryAddress;
  double deliveryCost = 25.0;
  LatLng location;
  double distance;
  String comment = '';
  // Payment
  // TODO: More payment options for Stripe
  String paymentMethod = 'cash';

  double get subtotal {
    double subtotal = 0.0;
    items.forEach((item) {
      subtotal += item.total;
    });

    return subtotal;
  }

  double get total {
    return subtotal + deliveryCost;
  }
}
