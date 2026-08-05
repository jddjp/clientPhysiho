
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:clientPhysiho/src/models/order_item_model.dart';

class OrderModel {
  DocumentReference? business;
  List<OrderItemModel> items = [];
  Placemark? deliveryAddress;
  double deliveryCost = 25.0;
  LatLng? location;
  double? distance;
  String comment = '';
  String paymentMethod = 'cash';

  double get subtotal {
    double subtotal = 0.0;
    for (final item in items) {
      subtotal += item.total ?? 0.0;
    }
    return subtotal;
  }

  double get total {
    return subtotal + deliveryCost;
  }
}
