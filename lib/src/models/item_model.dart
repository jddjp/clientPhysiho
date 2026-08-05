
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:clientPhysiho/src/models/image_model.dart';

class ItemModel {
  String? id;
  bool active = true;
  DocumentReference? business;
  String? description;
  double discount = 0.0;
  String? discountType;
  bool featured = false;
  ImageModel? image;
  int index = 0;
  List<dynamic> keywords = const [];
  bool multiplePrice = false;
  String? name;
  double price = 0.0;
  bool withDiscount = false;

  ItemModel({
    this.id,
    this.active = true,
    this.description,
    this.discount = 0.0,
    this.discountType,
    this.featured = false,
    this.image,
    this.index = 0,
    this.keywords = const [],
    this.multiplePrice = false,
    this.name,
    this.price = 0.0,
    this.withDiscount = false,
  });

  ItemModel.fromJSON(Map<String, dynamic> json) {
    try {
      id = json['id']?.toString();
      business = json['business'] as DocumentReference?;
      active = json['active'] ?? true;
      description = json['description']?.toString();
      discount = json['discount'] != null ? (json['discount'] as num).toDouble() : 0.0;
      discountType = json['discountType']?.toString();
      featured = json['featured'] ?? false;
      image = json['image'] != null ? ImageModel.fromJSON(Map<String, dynamic>.from(json['image'])) : null;
      index = json['index'] != null ? (json['index'] as num).toInt() : 0;
      keywords = json['keywords'] is List ? List<dynamic>.from(json['keywords']) : <dynamic>[];
      multiplePrice = json['multiple_price'] ?? false;
      name = json['name']?.toString();
      price = json['price'] != null ? (json['price'] as num).toDouble() : 0.0;
      withDiscount = json['with_discount'] ?? false;
    } catch (e) {
      print('ItemModel: Error');
      print(e);
    }
  }
}
