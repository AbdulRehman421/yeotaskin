import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:yeotaskin/utilities/snackbar_utils.dart';

import '../models/product_model.dart';

class Cart {
  List<ProductModel> items = [];

  Cart() {
    loadCart();
  }

  Future<void> clearCart() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('cart');
  }

  Future<void> addToCart(ProductModel product, int quantity) async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    int index = -1;
    bool existProduct = false;

    for (int i = 0; i < items.length; i++) {
      if (items[i].id == product.id) {
        existProduct = true;
        index = i;
        break;
      }
    }
    if (existProduct) {
      int? preCount = items[index].productCount;
      double prePrice = items[index].price!;
      double priceToAdd = (prePrice / preCount!) * quantity;
      items[index].price = (prePrice + priceToAdd);
      items[index].productCount = (preCount + quantity);

      SnackBarUtils.show(
        title: "Cart updated",
        isError: false,
      );
    } else {
      ProductModel productToAdd = ProductModel.fromJsonCart(product.toJson());
      productToAdd.productCount = quantity;
      productToAdd.price =
          (productToAdd.price ?? 0) * (productToAdd.productCount ?? 0);
      items.add(productToAdd);
      SnackBarUtils.show(title: "Added to cart", isError: false);
    }
    final cartData = items.map((item) => json.encode(item.toJson())).toList();
    await prefs.setStringList('cart', cartData);
  }

  Future<void> removeFromCart(int index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    items.removeAt(index);
    final cartData = items.map((item) => json.encode(item.toJson())).toList();
    await prefs.setStringList('cart', cartData);
  }

  void addQuantity(int index) {
    int? prevQuantity = items[index].productCount;
    items[index].productCount = (prevQuantity! + 1);

    updateItemPriceAndSaveCart(index, "add");
  }

  void removeQuantity(int index) {
    int? prevQuantity = items[index].productCount;
    if (prevQuantity! > 1) {
      items[index].productCount = (prevQuantity - 1);
      updateItemPriceAndSaveCart(index, "remove");
    }
  }

  Future<void> updateItemPriceAndSaveCart(int index, String type) async {
    if (index >= 0 && index < items.length) {
      if (type == "add") {
        int? prevQuantity = items[index].productCount! - 1;
        double prePrice = items[index].price!;
        double priceToAdd = prePrice / prevQuantity;
        items[index].price = (prePrice + priceToAdd);
        SharedPreferences prefs = await SharedPreferences.getInstance();
        final cartData =
            items.map((item) => json.encode(item.toJson())).toList();
        await prefs.setStringList('cart', cartData);
      } else {
        int? prevQuantity = items[index].productCount! + 1;
        double priceToSubtract = items[index].price! / prevQuantity;
        items[index].price = (items[index].price! - priceToSubtract);
        SharedPreferences prefs = await SharedPreferences.getInstance();
        final cartData =
            items.map((item) => json.encode(item.toJson())).toList();
        await prefs.setStringList('cart', cartData);
      }
    }
  }

  void loadCart() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final cartData = prefs.getStringList('cart') ?? [];
    items = cartData
        .map((item) => ProductModel.fromJsonCart(json.decode(item)))
        .toList();
  }

  double calculateTotalPrice() {
    double totalPrice = 0.0;
    items.map(
      (item) {
        totalPrice += item.price!;
      },
    ).toList();

    return totalPrice;
  }
  int calculateTotalQuantity() {
    int totalQuantity = 0;
    items.map(
          (item) {
        totalQuantity += item.productCount ?? 0;
      },
    ).toList();

    return totalQuantity;
  }

  void saveCart() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final cartData = items.map((item) => json.encode(item.toJson())).toList();
    await prefs.setStringList('cart', cartData);
  }
}
