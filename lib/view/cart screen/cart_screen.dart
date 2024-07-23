import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:yeotaskin/utilities/app_fonts.dart';
import 'package:yeotaskin/utilities/price_converter.dart';
import 'package:yeotaskin/utilities/snackbar_utils.dart';
import 'package:yeotaskin/view/cart%20screen/widgets/cart_item_card.dart';
import 'package:yeotaskin/view/cart%20screen/checkout_screen.dart';
import '../../APIs/urls.dart';
import '../../models/profile_model.dart';
import '../../services/user_profile_manager.dart';
import '../../utilities/app_colors.dart';
import '../../utilities/cart.dart';
import 'package:http/http.dart' as http;

class CartScreen extends StatefulWidget {
  final Function itemRemoved;
  const CartScreen({super.key, required this.itemRemoved});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen>
    with SingleTickerProviderStateMixin {
  ProfileModel profile = UserProfileManager().profile;
  late final Cart cart;
  bool loading = true;
  double totalAmmount = 0.0;
  String moq = '';
  int totalQuantity = 0;
  void getMoq() async{
    String? token = await UserProfileManager().getUserToken();
    try {
      final response = await http.get(
          Uri.parse("${URLs.baseURL}${URLs.getHomeURL}"),
          headers: {"Authorization": "Bearer $token"});

      if (response.statusCode == 200 &&
          jsonDecode(response.body)['success'] == true) {
        debugPrint("home loaded: ${jsonDecode(response.body)}");

        moq = jsonDecode(response.body)['data']['moq'];

      } else {
        debugPrint("getMoq(): error");
      }
    } catch (e) {
      debugPrint("getMoq(): $e");
    }
  }
  void loadCart() {
    cart = Cart();
    Future.delayed(
      const Duration(seconds: 1),
      () {
        setState(() {
          loading = false;
        });
        totalAmmount = cart.calculateTotalPrice();

      },
    );
  }

  @override
  void initState() {
    getMoq();
    loadCart();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        surfaceTintColor: AppColors.backgroundColor,
        backgroundColor: AppColors.backgroundColor,
        title: const Center(
          child: Text(
            "My Cart",
            style: TextStyle(
              fontFamily: AppFonts.palatino,
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
        ),
        actions: [
          const SizedBox(
            width: 10,
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
                // color: Colors.black12,
                borderRadius: BorderRadius.circular(100)),
            // child: const Icon(Icons.search)
          ),
          const SizedBox(
            width: 20,
          ),
        ],
      ),
      body: !loading
          ? cart.items.isNotEmpty
              ? ListView.builder(
                  physics: const ClampingScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 64),
                  shrinkWrap: true,
                  itemCount: cart.items.length,
                  itemBuilder: (context, index) {
                    return CartItemCard(
                      cartProduct: cart.items[index],
                      index: index,
                      cart: cart,
                      buttonPressed: () {
                        setState(() {
                          totalAmmount = cart.calculateTotalPrice();
                          widget.itemRemoved();
                        });
                      },
                      type: 'cart',
                    );
                  },
                )
              : const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shopping_cart_outlined),
                      Text(
                        "Nothing found!",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: AppFonts.palatino,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                )
          : const Center(
              child: CircularProgressIndicator(
              color: AppColors.primaryColor,
            )),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 32,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                totalPriceData("Subtotal", totalAmmount, isFinalPrice: true),
                // totalPriceData(
                //   "To Pay",
                //   totalAmmount - incomeWallet - eWallet,
                //   isFinalPrice: true,
                // ),
              ],
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: AppFonts.optima,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
              onPressed: cart.items.isNotEmpty
                  ? () {

                totalQuantity = cart.calculateTotalQuantity();

                if(totalQuantity >= int.parse(profile.moq ?? '0') || moq.toLowerCase() == "reached"){
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CheckoutScreen(
                        cart: cart,
                        itemRemoved: (){
                          setState(() {
                            totalAmmount = cart.calculateTotalPrice();
                          });
                          widget.itemRemoved();
                        },
                        totalAmount: totalAmmount,
                      ),
                    ),
                  );
                }else{
                  SnackBarUtils.show(title: "Total quantity can't less than ${profile.moq}", isError: true,duration: 2);
                }
                
              }
              :null,
              child: const Text('Checkout'),
            ),
          ],
        ),
      ),
    );
  }

  List<Divider> customDivider() {
    return List.generate(10, (index) => const Divider());
  }

  Widget totalPriceData(String key, double value, {bool isFinalPrice = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "$key: ",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            fontFamily: AppFonts.palatino,
          ),
        ),
        Text(
          PriceUtility.priceWithSymbol(value),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: isFinalPrice ? 18 : 16,
            fontFamily: AppFonts.arial,
            color: isFinalPrice ? Colors.orange.shade900 : Colors.black,
          ),
        ),
      ],
    );
  }
}
