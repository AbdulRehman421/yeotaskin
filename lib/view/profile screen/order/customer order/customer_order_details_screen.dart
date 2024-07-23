import 'package:flutter/material.dart';
import 'package:yeotaskin/utilities/price_converter.dart';

import '../../../../utilities/app_colors.dart';


class CustomerOrderDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> orderDetails;
  final String currentStatus;
  const CustomerOrderDetailsScreen({super.key, required this.orderDetails, required this.currentStatus,});

  @override
  State<CustomerOrderDetailsScreen> createState() => _CustomerOrderDetailsScreenState();
}

class _CustomerOrderDetailsScreenState extends State<CustomerOrderDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        surfaceTintColor: AppColors.backgroundColor,
        backgroundColor: AppColors.backgroundColor,
        title: const Text('Customer Order Details'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        children: [
          myRow("Order Number", widget.orderDetails['order_id'].toString()),
          const Divider(color: Colors.black12),
          myRow("Customer Address", widget.currentStatus),
          const Divider(color: Colors.black12),
          myRow("Customer Name", widget.orderDetails['customer_name'].toString()),
          const Divider(color: Colors.black12),
          myRow("Phone Number", widget.orderDetails['phone_number'].toString()),
          const Divider(color: Colors.black12),
          myRow("Customer Address", widget.orderDetails['customer_address'].toString()),
          const Divider(color: Colors.black12),
          myRow("Customer Address", widget.orderDetails['billing_country'].toString()),
          const Divider(color: Colors.black12),
          myRow("Customer Address", widget.orderDetails['customer_email'].toString()),
          const Divider(color: Colors.black12),
          myRow("Order Ammount", PriceUtility.priceWithSymbol(double.parse(widget.orderDetails['order_amount'].toString()))),
          const Divider(color: Colors.black12),
          myRow("Shipping Fee", PriceUtility.priceWithSymbol(double.parse(widget.orderDetails['shipping_fee'].toString()))),
          const Divider(color: Colors.black12),
          myRow("Customer Address", widget.orderDetails['quantity'].toString()),

          // const Divider(color: Colors.black12),
          // myRow("Customer Address", widget.orderDetails['customer_email'].toString()),
          // const Divider(color: Colors.black12),
          // myRow("Customer Address", widget.orderDetails['customer_email'].toString()),
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
  }
  Row myRow(String key, String value){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          key,
          style: const TextStyle(
              fontFamily: "youngSerif",
              fontSize: 16,
              fontWeight: FontWeight.normal),
        ),
        Text(
          value,
          style: const TextStyle(
              fontFamily: "youngSerif",
              fontSize: 16,
              fontWeight: FontWeight.normal),
        ),
      ],
    );
  }
}
