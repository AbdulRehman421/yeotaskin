import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:yeotaskin/utilities/app_colors.dart';
import 'package:yeotaskin/utilities/app_fonts.dart';
import 'package:yeotaskin/utilities/price_converter.dart';
import 'package:http/http.dart' as http;
import '../../APIs/urls.dart';
import '../../models/profile_model.dart';
import '../../services/user_profile_manager.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  bool loadingOrderHistory = false;
  List orderHistory = [];
  void setLoading(bool status) {
    setState(() {
      loadingOrderHistory = status;
    });
  }

  Future<void> getOrderHistory() async {
    ProfileModel profile = UserProfileManager().profile;
    setLoading(true);
    String? token = await UserProfileManager().getUserToken();
    try {
      final response = await http.get(
          Uri.parse("${URLs.baseURL}${URLs.getOrderHistoryURL}"),
          headers: {"Authorization": "Bearer $token"});
      if (response.statusCode == 200 &&
          jsonDecode(response.body)['success'] == true) {
        List data = jsonDecode(response.body)['data'];

        data.map((item) {
          if (item['agent_id'].toString() == profile.id.toString()) {
            orderHistory.add(item);
          }
        }).toList();
        // filterData.map((item){
        //   List products = item['product'];
        //   products.map((product) {
        //     orderHistory.add(ProductModel.fromJsonHistory(product as Map<String, dynamic>));
        //   }).toList();
        // }).toList();
        setState(() {});
      } else {
        debugPrint("getOrderHistory(): error");
      }
    } catch (e) {
      debugPrint("getOrderHistory(): $e");
    }
    setLoading(false);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getOrderHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        surfaceTintColor: AppColors.backgroundColor,
        backgroundColor: AppColors.backgroundColor,
        title: const Text(
          'Order History',
          style: TextStyle(
            fontFamily: AppFonts.palatino,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
      ),
      body: !loadingOrderHistory
          ? orderHistory.isNotEmpty
              ? ListView.builder(
                  itemCount: orderHistory.length,
                  itemBuilder: (context, index) {
                    return Column(
                      children: [
                        ListTile(
                          onTap: () => showAmmountDialogue(index),
                          leading: Column(
                            children: [
                              const Text(
                                'Order Id',
                                style: TextStyle(fontSize: 16),
                              ),
                              Text(orderHistory[index]['id'].toString(),
                                  style: const TextStyle(fontSize: 16)),
                            ],
                          ),
                          title: Column(
                            children: [
                              const Text('DateTime'),
                              Text(
                                  orderHistory[index]['created_at'].toString()),
                            ],
                          ),
                          trailing: Column(
                            children: [
                              const Text('Total Price',
                                  style: TextStyle(fontSize: 16)),
                              Text(
                                  PriceUtility.priceWithSymbol(double.parse(
                                      orderHistory[index]['total_price']
                                          .toString())),
                                  style: const TextStyle(fontSize: 16)),
                            ],
                          ),
                        ),
                        const Divider(
                          color: AppColors.primaryColor,
                        )
                      ],
                    );
                  },
                )
              : const Center(
                  child: Text(
                    "No history found",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: AppFonts.palatino,
                      fontSize: 18,
                    ),
                  ),
                )
          : const Center(
              child: CircularProgressIndicator(color: AppColors.primaryColor)),
    );
  }

  void showAmmountDialogue(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          title: const Text(
            "Price Details",
            style: TextStyle(
              fontFamily: AppFonts.palatino,
              fontWeight: FontWeight.bold,
              color: AppColors.accent,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              myRow(
                  "Amount Paid", orderHistory[index]['total_price'].toString()),
              myRow("E-Wallet Use",
                  orderHistory[index]['ewallet_use'].toString()),
              myRow("Income Wallet Use",
                  orderHistory[index]['income_use'].toString()),
              myRow(
                  "Total Amount",
                  (double.parse(orderHistory[index]['total_price'].toString()) +
                          double.parse(orderHistory[index]['income_use']
                                  .toString()
                                  .isNotEmpty
                              ? orderHistory[index]['income_use'].toString()
                              : '0.00') +
                          double.parse(orderHistory[index]['ewallet_use']
                                  .toString()
                                  .isNotEmpty
                              ? orderHistory[index]['ewallet_use'].toString()
                              : '0.00'))
                      .toString())
            ],
          ),
        );
      },
    );
  }

  Row myRow(String key, String ammount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(key, style: const TextStyle(fontSize: 16)),
        Text(
            PriceUtility.priceWithSymbol(
                double.parse(ammount.isNotEmpty ? ammount : '0.00')),
            style: const TextStyle(fontSize: 16)),
      ],
    );
  }
}
