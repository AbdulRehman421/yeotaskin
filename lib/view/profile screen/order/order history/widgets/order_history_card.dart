import 'dart:async';

import 'package:flutter/material.dart';
import 'package:yeotaskin/utilities/app_fonts.dart';
import 'package:yeotaskin/view/dashboard/widgets/table.dart';
import 'package:yeotaskin/view/profile%20screen/order/order%20history/invoice_view_screen.dart';
import 'package:intl/intl.dart';
import 'package:yeotaskin/view/profile%20screen/order/order%20history/widgets/product_table.dart';

import '../../../../../APIs/urls.dart';
import '../../../../../utilities/app_colors.dart';
import '../../../../../utilities/price_converter.dart';
import 'package:http/http.dart' as http;

class OrderHistoryCard extends StatefulWidget {
  final Map<String, dynamic> order;
  final String status;
  const OrderHistoryCard(
      {super.key, required this.order, required this.status});

  @override
  State<OrderHistoryCard> createState() => _OrderHistoryCardState();
}

class _OrderHistoryCardState extends State<OrderHistoryCard> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
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
                    const Icon(Icons.shopping_basket),
                    // Text("${widget.order['customer_name']}",),

                    Text(
                      'Order No. ${widget.order['id']}',
                      style: const TextStyle(
                        fontFamily: AppFonts.palatino,
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          foregroundColor: Colors.white),
                      onPressed: () {
                        showAmmountDialogue(widget.order);
                        //Navigator.push(context, MaterialPageRoute(builder: (context) =>  CustomerOrderDetailsScreen(orderDetails: widget.order, currentStatus : widget.status),));
                      },
                      child: const Text(
                        "View Details",
                        style: TextStyle(
                          fontFamily: AppFonts.palatino,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  ],
                ),
                Container(
                  height: 40,
                  width: double.infinity,
                  color: AppColors.threeLevelColor,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(children: [
                        const Icon(Icons.date_range),
                        const SizedBox(
                          width: 5,
                        ),
                        Text(
                          "${widget.order['created_at']} ",
                          style: const TextStyle(
                            fontFamily: AppFonts.palatino,
                          ),
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                      ],),
                      Row(
                        children: [
                          const Icon(Icons.monetization_on_outlined),
                          const SizedBox(
                            width: 5,
                          ),
                          Text(
                            "To: 123456789 ",
                            style: const TextStyle(
                              fontFamily: AppFonts.palatino,
                            ),
                          ),
                        ],
                      ),
                      TextButton(
                          onPressed: ()  {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => InvoiceViewScreen(orderId: widget.order['id'].toString())));
                          }, child: const Icon(Icons.document_scanner,))
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void showAmmountDialogue(Map<String, dynamic> orderHistory) {
    showDialog(
      context: context,
      builder: (context) {
        List products = orderHistory['product'] ?? [];
        String formattedDate = "";
        String formattedTime = "";
        if(orderHistory['product'][0]['created_at'] != null) {
          DateTime dateTime = DateTime.parse(
              orderHistory['product'][0]['created_at']).toLocal();
          formattedDate = DateFormat('yyyy-MM-dd').format(dateTime);
          formattedTime = DateFormat('HH:mm:ss').format(dateTime);
        }
        return AlertDialog(
          backgroundColor: Colors.white,
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Date",
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: AppFonts.optima,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(formattedDate,
                    style: const TextStyle(
                      fontSize: 16,
                      fontFamily: AppFonts.arial,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Time",
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: AppFonts.optima,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(formattedTime,
                    style: const TextStyle(
                      fontSize: 16,
                      fontFamily: AppFonts.arial,
                    ),
                  ),
                ],
              ),
              ProductTable(headerText: ["","","Product","Qty",], columnData: products),
              myRow("Amount Paid", orderHistory['total_price'].toString()),
              myRow("E-Wallet Use", orderHistory['ewallet_use'].toString()),
              myRow("Income Wallet Use", orderHistory['income_use'].toString()),
              myRow(
                  "Total Amount",
                  (double.parse(orderHistory['total_price'].toString()) +
                          double.parse(orderHistory['income_use']
                                      .toString()
                                      .isNotEmpty &&
                                  orderHistory['income_use'] != null
                              ? orderHistory['income_use'].toString()
                              : '0.00') +
                          double.parse(
                              orderHistory['ewallet_use'].toString().isNotEmpty
                                  ? orderHistory['ewallet_use'].toString()
                                  : '0.00'))
                      .toString()),


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
        Text(
          key,
          style: const TextStyle(
            fontSize: 16,
            fontFamily: AppFonts.optima,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          PriceUtility.priceWithSymbol(
              double.parse(ammount.isNotEmpty ? ammount : '0.00')),
          style: const TextStyle(
            fontSize: 16,
            fontFamily: AppFonts.arial,
          ),
        ),
      ],
    );
  }
}
