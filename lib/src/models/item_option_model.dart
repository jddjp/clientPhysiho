
class ItemOptionModel {
  String? id;
  String? name;
  String? type;
  bool required = false;
  bool multiple = false;
  bool main = false;
  bool active = true;
  int min = 0;
  int max = 0;
  int index = 0;
  List<SingleItemOption> options = <SingleItemOption>[];

  ItemOptionModel({
    this.id,
    this.name,
    this.type,
    this.required = false,
    this.multiple = false,
    this.main = false,
    this.active = true,
    this.min = 0,
    this.max = 0,
    this.index = 0,
    List<SingleItemOption>? options,
  }) : options = options ?? <SingleItemOption>[];

  ItemOptionModel.fromJSON(Map<String, dynamic> json) {
    try {
      id = json['id']?.toString();
      name = json['name']?.toString();
      type = json['type']?.toString();
      required = json['required'] ?? false;
      multiple = json['multiple'] ?? false;
      main = json['main'] ?? false;
      min = json['min'] != null ? (json['min'] as num).toInt() : 0;
      max = json['max'] != null ? (json['max'] as num).toInt() : 0;
      index = json['index'] != null ? (json['index'] as num).toInt() : 0;
      if (json['options'] is List) {
        for (final option in json['options']) {
          options.add(SingleItemOption.fromJSON(Map<String, dynamic>.from(option)));
        }
      }
    } catch (e) {
      print('ItemOptionModel: Error');
      print(e);
    }
  }
}

class SingleItemOption {
  String? id;
  String? name;
  double price = 0.0;
  double discount = 0.0;
  String? discountType;
  bool withDiscount = false;
  bool active = true;

  SingleItemOption({
    this.id,
    this.name,
    this.price = 0.0,
    this.discount = 0.0,
    this.discountType,
    this.withDiscount = false,
    this.active = true,
  });

  SingleItemOption.fromJSON(Map<String, dynamic> json) {
    try {
      id = json['id']?.toString();
      name = json['name']?.toString();
      price = json['price'] != null ? (json['price'] as num).toDouble() : 0.0;
      discount = json['discount'] != null ? (json['discount'] as num).toDouble() : 0.0;
      discountType = json['discountType']?.toString();
      withDiscount = json['with_discount'] ?? false;
      active = json['active'] ?? true;
    } catch (e) {
      print('SingleItemOption: Error');
      print(e);
    }
  }
}