import '../services/user_profile_manager.dart';

class ProductModel {
  int? id;
  String? productImage;
  String? productName;
  String? sku;
  int? quantity;
  double? weight;
  int? productCount;
  String? createdAt;
  double? price;

  ProductModel(
      {this.id,
      this.productImage,
      this.productName,
      this.sku,
      this.quantity,
      this.weight,
      this.createdAt,
      this.price,
      this.productCount});

  ProductModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    productImage = json['product_image'] ?? '';
    productName = json['product_name'] ?? '';
    sku = json['sku'] ?? '';
    quantity = int.parse(json['quantity'].toString());
    weight = double.parse(json['weight'] != null ? json['weight'].toString() : '0.0');
    List priceList = json['product_level_price'];

    priceList.map((levelPrice) {
      if (levelPrice['level_id'].toString() ==
          UserProfileManager().profile.level.toString()) {
        price = double.parse(levelPrice['price'].toString());
      }
    }).toList();

    productCount = json['product_count'];
    createdAt = json['created_at'] ?? '';
  }
  ProductModel.fromJsonHistory(Map<String, dynamic> json) {
    id = json['id'];
    productImage = json['product_image'] ?? '';
    productName = json['product_name'] ?? '';
    sku = json['sku'] ?? '';
    weight = double.parse(json['weight'] != null ? json['weight'].toString() : '0.0');
    price = double.parse(json['price'].toString());
    productCount = json['product_count'];
    createdAt = json['created_at'] ?? '';
  }
  ProductModel.fromJsonCart(Map<String, dynamic> json) {
    id = json['id'];
    productImage = json['product_image'] ?? '';
    productName = json['product_name'] ?? '';
    sku = json['sku'] ?? '';
    quantity = json['quantity'] ?? '';
    weight = double.parse(json['weight'] != null ? json['weight'].toString() : '0.0');
    price = double.parse(json['price'].toString());
    productCount = json['product_count'];
    createdAt = json['created_at'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['product_image'] = productImage;
    data['product_name'] = productName;
    data['sku'] = sku;
    data['quantity'] = quantity;
    data['weight'] = weight;
    data['created_at'] = createdAt;
    data['price'] = price;
    data['product_count'] = productCount;
    return data;
  }
}
