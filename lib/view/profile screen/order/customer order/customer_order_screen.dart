import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:yeotaskin/utilities/app_colors.dart';
import 'package:yeotaskin/utilities/app_fonts.dart';
import 'package:yeotaskin/utilities/price_converter.dart';
import 'package:http/http.dart' as http;
import 'package:yeotaskin/view/profile%20screen/order/customer%20order/widgets/customer_order_card.dart';

import '../../../../APIs/urls.dart';
import '../../../../models/home_model.dart';
import '../../../../models/profile_model.dart';
import '../../../../services/user_profile_manager.dart';
import '../order history/order_history_screen.dart';

class CustomerOrderScreen extends StatefulWidget {
  const CustomerOrderScreen({super.key});

  @override
  State<CustomerOrderScreen> createState() => _CustomerOrderScreenState();
}

class _CustomerOrderScreenState extends State<CustomerOrderScreen> {
  bool loadingCustomerOrder = false;
  List customerOrder = [];
  List trackingNumber = [];
  String totalPrice = "";

  void setLoading(bool status) {
    setState(() {
      loadingCustomerOrder = status;
    });
  }

  Future<void> getTrackingNumber() async {
    setLoading(true);
    try {} catch (e) {
      debugPrint("getCustomerOrder(): $e");
    }
  }

  Future<void> getCustomerOrder() async {

    setLoading(true);
    ProfileModel profile = UserProfileManager().profile;
    String? token = await UserProfileManager().getUserToken();
    try {
      final response = await http.get(
          Uri.parse("${URLs.baseURL}${URLs.getCustomerOrderURL}"),
          headers: {"Authorization": "Bearer $token"});
      if (!mounted) {
        return;
      }
      double totalAmount = 0.0;
      if (response.statusCode == 200 &&
          jsonDecode(response.body)['success'] == true) {
        customerOrder.clear();
        List data = jsonDecode(response.body)['data'];
        data.map((item) {
          String createdAtString = item['created_at'];
          try {
            DateTime createdAt = DateTime.parse(
              DateFormat('dd-MM-yyyy').parse(createdAtString).toString(),
            );
            if ((fromDate == null || createdAt.isAfter(fromDate!)) &&
                (toDate == null || createdAt.isBefore(toDate!))) {
              if (item['agent_id'].toString() == profile.id.toString()) {
                totalAmount += double.parse(item['order_amount']);
                customerOrder.add(item);
              }
            }
          } catch (e) {
            setLoading(false);
            debugPrint("Error parsing createdAt: $e");
          }
        }).toList();
        totalPrice = totalAmount.toString();
        setState(() {});
      } else {
        debugPrint("getCustomerOrder(): error ${response.statusCode}");
      }
    } catch (e) {
      setLoading(false);
      debugPrint("getCustomerOrder(): $e");
    }
    setLoading(false);
  }

  String getOrderStatus(String statusCode) {
    switch (statusCode) {
      case "1":
        return "To Be Checked";
      case "2":
        return "Pending";
      case "3":
        return "Attached";
      case "4":
        return "Packing";
      case "5":
        return "Courier Pickup";
      case "9":
        return "Order Blocked";
      case "10":
        return "SKU not in system";
      default:
        return "";
    }
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
        getCustomerOrder();
      }
    }
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getTrackingNumber();
    getCustomerOrder();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        surfaceTintColor: AppColors.backgroundColor,
        backgroundColor: AppColors.backgroundColor,
        title: const Text(
          'Customer Order',
          style: TextStyle(
            fontFamily: AppFonts.palatino,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list,color: fromDate == null && toDate == null ? Colors.black : AppColors.primaryColor ,),
            onPressed: () {
              if(fromDate != null && toDate != null){
                fromDate = null;
                toDate = null;
                getCustomerOrder();
              }else{
                _showDateRangePicker(context);
              }

            },
          ),
        ],
      ),
      body: !loadingCustomerOrder
          ? customerOrder.isNotEmpty
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
                          salesAmount: customerOrder.length.toString(),
                          backgroundColors: [
                            AppColors.primaryColor,AppColors.primaryColor,
                          ],
                        ),
                      ]),
                  Expanded(
                    child: ListView.builder(
                        itemCount: customerOrder.length,
                        itemBuilder: (context, index) {
                          final reversedIndex = customerOrder.length - 1 - index;
                          String status = getOrderStatus(
                              customerOrder[reversedIndex]["status"].toString());
                          return CustomerOrderCard(
                              order: customerOrder[reversedIndex],
                              status: status);
                        },
                      ),
                  ),
                ],
              )
              : const Center(
                  child: Text(
                    "No Order found",
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
