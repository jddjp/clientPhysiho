
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:clientPhysiho/src/models/image_model.dart';

class ItemModel {
  String id;
  bool active;
  DocumentReference business;
  String description;
  double discount;
  String discountType;
  bool featured;
  ImageModel image;
  int index;
  List <dynamic> keywords;
  bool multiplePrice;
  String name;
  double price = 0.0;
  // section
  bool withDiscount;

  ItemModel({
    this.id,
    this.active,
    this.description,
    this.discount,
    this.discountType,
    this.featured,
    this.image,
    this.index,
    this.keywords,
    this.multiplePrice,
    this.name,
    this.price,
    this.withDiscount
  });

  ItemModel.fromJSON(Map<String,dynamic> json) {
    print(json['business']);
    try {
      id = json['id'];
      business = json['business'];
      active = json['active']??true;
      description = json['description'];
      discount = json['discount'] != null ? json['discount'].toDouble() : 0.0;
      discountType = json['discountType'];
      featured = json['featured']??false;
      image = json['image'] != null ? ImageModel.fromJSON(json['image']) : null;
      index = json['index'].toInt();
      keywords = json['keywords'];
      multiplePrice = json['multiple_price']??false;
      name = json['name'];
      price = json['price'] != null ? json['price'].toDouble() : 0.0;
      withDiscount = json['with_discount']??false;
    } catch (e) {
      print("ItemModel: Error");
      print(e);
    }
  }
}