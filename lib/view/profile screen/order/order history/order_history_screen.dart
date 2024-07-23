import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:yeotaskin/models/product_model.dart';
import 'package:yeotaskin/utilities/app_colors.dart';
import 'package:yeotaskin/utilities/app_fonts.dart';
import 'package:yeotaskin/utilities/price_converter.dart';
import 'package:http/http.dart' as http;
import 'package:yeotaskin/view/profile%20screen/order/order%20history/widgets/order_history_card.dart';
import 'package:yeotaskin/view/profile%20screen/order/order%20history/widgets/order_history_widget.dart';

import '../../../../APIs/urls.dart';
import '../../../../models/home_model.dart';
import '../../../../models/profile_model.dart';
import '../../../../services/user_profile_manager.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  bool loadingOrderHistory = false;
  List orderHistory = [];
  String totalPrice = "";
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
        headers: {"Authorization": "Bearer $token"},
      );
      double totalAmount = 0.0;
      if (response.statusCode == 200 &&
          jsonDecode(response.body)['success'] == true) {
        List data = jsonDecode(response.body)['data'];
        orderHistory.clear();
        if (data.isNotEmpty) {
          for (var item in data) {
            String createdAtString = item['created_at'];
            try {
              DateTime createdAt = DateTime.parse(
                DateFormat('dd-MM-yyyy').parse(createdAtString).toString(),
              );
              if ((fromDate == null || createdAt.isAfter(fromDate!)) &&
                  (toDate == null || createdAt.isBefore(toDate!))) {
                if (item['agent_id'].toString() == profile.id.toString()) {
                  totalAmount += double.parse(item['total_price']);
                  orderHistory.add(item);
                }
              }
            } catch (e) {
              debugPrint("Error parsing createdAt: $e");
            }
          }
        }
        totalPrice = totalAmount.toString();
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

  DateTime? fromDate;
  DateTime? toDate;
  void _showDateRangePicker(BuildContext context) async {
    DateTime? pickedFromDate = await showDatePicker(
      helpText: "Select start date",
      context: context,
      initialDate: fromDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (pickedFromDate != null) {
      DateTime? pickedToDate = await showDatePicker(
        helpText: "Select end date",
        context: context,
        initialDate: fromDate ?? DateTime.now(),
        firstDate: pickedFromDate,
        lastDate: DateTime.now(),
      );

      if (pickedToDate != null) {
        fromDate = pickedFromDate;
        toDate = pickedToDate;
        getOrderHistory();
      }
    }
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
        actions: [
          IconButton(
            icon: Icon(
              Icons.filter_list,
              color: fromDate == null && toDate == null
                  ? Colors.black
                  : AppColors.primaryColor,
            ),
            onPressed: () {
              if (fromDate != null && toDate != null) {
                fromDate = null;
                toDate = null;
                getOrderHistory();
              } else {
                _showDateRangePicker(context);
              }
            },
          ),
        ],
      ),
      body: !loadingOrderHistory
          ? orderHistory.isNotEmpty
              ? Column(
                  children: [
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          salesCard(
                            onTap: () {},
                            salesType: 'Total Sales',
                            salesAmount: totalPrice,
                            backgroundColors: [
                              AppColors.primaryColor,AppColors.primaryColor,
                            ],
                          ),
                          salesCard(
                            onTap: () {},
                            salesType: 'Orders',
                            salesAmount: orderHistory.length.toString(),
                            backgroundColors: [
                              AppColors.primaryColor,AppColors.primaryColor,
                            ],
                          ),
                        ]),
                    Expanded(
                      child: ListView.builder(
                        itemCount: orderHistory.length,
                        itemBuilder: (context, index) {
                          final reversedIndex = orderHistory.length - 1 - index;
                          return OrderHistoryCard(
                            order: orderHistory[reversedIndex],
                            status: '',
                          );
                        },
                      ),
                    ),
                  ],
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
}

Widget salesCard({
  required GestureTapCallback onTap,
  required String salesType,
  required String salesAmount,
  required List<Color> backgroundColors,
}) =>
    Card(
      color: Colors.white,
      margin: const EdgeInsets.only(top: 20),
      child: Container(
        height: 80,
        width: 180,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: backgroundColors,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: walletAmountWidget(
            salesType,
            salesAmount,
            titleColor: Colors.white,
            centerTitle: false,
          ),
        ),
      ),
    );

Widget walletAmountWidget(
  String title,
  String amount, {
  Color? titleColor,
  Color textColor = Colors.white,
  bool centerTitle = true,
}) =>
    Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: titleColor ?? Colors.white.withOpacity(0.7),
            fontWeight: FontWeight.w600,
            fontFamily: AppFonts.optima,
          ),
        ),
        Flexible(
          child: Text(
            title=="Orders"
            ?amount
            :"$amount RM",
            maxLines: 2, softWrap: true,overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 16,
              fontFamily: AppFonts.optima,
            ),
          ),
        ),

      ],
    );
