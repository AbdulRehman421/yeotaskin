import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:yeotaskin/utilities/app_fonts.dart';
import 'package:yeotaskin/view/profile%20screen/order/customer%20order/widgets/customer_product_table.dart';

import '../../../../../utilities/app_colors.dart';
import '../../../../../utilities/price_converter.dart';
import '../../order history/widgets/product_table.dart';

class CustomerOrderCard extends StatefulWidget {
  final Map<String, dynamic> order;
  final String status;
  const CustomerOrderCard(
      {super.key, required this.order, required this.status});

  @override
  State<CustomerOrderCard> createState() => _CustomerOrderCardState();
}

class _CustomerOrderCardState extends State<CustomerOrderCard> {
  final ScrollController _scrollController = ScrollController();

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    startAutoScroll();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void startAutoScroll() {
    _timer = Timer.periodic(Duration(seconds: 4), (timer) {
      if (_scrollController.hasClients) {
        if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent) {
          _scrollController.jumpTo(_scrollController.position.minScrollExtent);
        } else {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: Duration(seconds: 4),
            curve: Curves.linear,
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: SizedBox(
        height: 120,
        child: Card(
          color: AppColors.backgroundColor,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // const Icon(Icons.shopping_basket),
                    Flexible(
                        child: Text(
                      "${widget.order['customer_name']}",
                      style: TextStyle(
                        fontFamily: AppFonts.palatino,
                      ),
                    )),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        'Order No. ${widget.order['order_id']}',
                        style: TextStyle(
                          fontFamily: AppFonts.palatino,
                        ),
                      ),
                    ),

                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryColor,
                            foregroundColor: Colors.white),
                        onPressed: () {
                          showAmmountDialogue(widget.status, widget.order);
                          //Navigator.push(context, MaterialPageRoute(builder: (context) =>  CustomerOrderDetailsScreen(orderDetails: widget.order, currentStatus : widget.status),));
                        },
                        child: const Text(
                          "View Details",
                          style: TextStyle(
                            fontFamily: AppFonts.palatino,
                            fontWeight: FontWeight.bold,
                          ),
                        ))
                  ],
                ),
                Container(
                  height: 40,
                  width: double.infinity,
                  color: AppColors.threeLevelColor,
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        const Icon(Icons.location_on),
                        const SizedBox(
                          width: 10,
                        ),
                        Text(
                          "${widget.order['customer_address']} ",
                          style: TextStyle(
                            fontFamily: AppFonts.palatino,
                          ),
                        ),
                        // SizedBox(width: 20,),
                        // Icon(Icons.location_on),
                        // SizedBox(width: 10,),
                        // Text("To: ${widget.order['billing_country'] ?? ""} "),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void showAmmountDialogue(
      String currentStatus, Map<String, dynamic> orderDetails) {
    showDialog(
      context: context,
      builder: (context) {
        print(orderDetails['order_items']);
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text(
            "Customer Order Details",
            style: TextStyle(
              fontFamily: AppFonts.palatino,
              fontWeight: FontWeight.bold,
              color: AppColors.accent,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              myRow("Order Number", orderDetails['order_id'].toString()),
              const Divider(color: Colors.black12),
              myRow("Quantity", orderDetails['quantity'].toString()),
              const Divider(color: Colors.black12),
              myRow("Order Status", currentStatus),
              const Divider(color: Colors.black12),
              myRow("Tracking code", orderDetails['trackNumber'].toString()),
              const Divider(color: Colors.black12),
              myRow("Courier", orderDetails['courier'].toString()),
              const Divider(color: Colors.black12),
              myRow("Customer Name", orderDetails['customer_name'].toString()),
              const Divider(color: Colors.black12),
              myRow("Phone Number", orderDetails['phone_number'].toString()),
              const Divider(color: Colors.black12),
              myRow("Customer Address",
                  orderDetails['customer_address'].toString()),
              const Divider(color: Colors.black12),
              myRow("Billing Country",
                  orderDetails['billing_country'].toString()),
              const Divider(color: Colors.black12),
              myRow(
                  "Customer Email", orderDetails['customer_email'].toString()),
              const Divider(color: Colors.black12),
              myRow(
                  "Order Amount",
                  PriceUtility.priceWithSymbol(
                      double.parse(orderDetails['order_amount'].toString()))),
              const Divider(color: Colors.black12),

              orderDetails['shipping_fee'] != null
              ?myRow(
                  "Shipping Fee",
                  PriceUtility.priceWithSymbol(
                      double.parse(orderDetails['shipping_fee'].toString())))
              :myRow(
                  "Shipping Fee",
                  orderDetails['shipping_fee'].toString()),
              const Divider(color: Colors.black12),
              SizedBox(height: 10,),
              CustomerProductTable(headerText: const ["","","Product","Qty",], columnData: orderDetails['order_items']),
              // const Divider(color: Colors.black12),
              // myRow("Customer Address", widget.orderDetails['customer_email'].toString()),
              // const Divider(color: Colors.black12),
              // myRow("Customer Address", widget.orderDetails['customer_email'].toString()),
              // const Divider(color: Colors.black12),
              // myRow("Customer Address", widget.orderDetails['customer_email'].toString()),
              // const Divider(color: Colors.black12),
            ],
          ),
        );
      },
    );
  }

  Row myRow(String key, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "$key: ",
          style: const TextStyle(
            fontSize: 14,
            fontFamily: AppFonts.optima,
            fontWeight: FontWeight.bold,
          ),
        ),
        Flexible(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontFamily: AppFonts.arial,
            ),
          ),
        ),
      ],
    );
  }
}
