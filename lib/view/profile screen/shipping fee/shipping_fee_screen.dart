import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:yeotaskin/utilities/app_fonts.dart';
import 'package:yeotaskin/view/profile%20screen/shipping%20fee/widgets/fee_table.dart';
import '../../../APIs/urls.dart';
import '../../../models/profile_model.dart';
import '../../../services/user_profile_manager.dart';
import '../../../utilities/app_colors.dart';

class ShippingFeeScreen extends StatefulWidget {
  const ShippingFeeScreen({super.key});

  @override
  State<ShippingFeeScreen> createState() => _ShippingFeeScreenState();
}

class _ShippingFeeScreenState extends State<ShippingFeeScreen> {
  bool loadingShippingFee = false;
  Map<String, dynamic> shippingFee = {};
  void setLoading(bool status) {
    setState(() {
      loadingShippingFee = status;
    });
  }

  Future<void> getShippingFee() async {
    //ProfileModel profile = UserProfileManager().profile;
    setLoading(true);
    try {
      final response =
          await http.get(Uri.parse("${URLs.baseURL}${URLs.getShippingFeeURL}"));
      if (response.statusCode == 200 &&
          jsonDecode(response.body)['success'] == true) {
        Map<String, dynamic> data = jsonDecode(response.body)['shippingData'];
        if (data.isNotEmpty) {
          shippingFee = data;
        }
        if (kDebugMode) {
          print(shippingFee);
        }
        setState(() {});
      } else {
        debugPrint("getShippingFee(): error");
      }
    } catch (e) {
      debugPrint("getShippingFee: $e");
    }
    setLoading(false);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getShippingFee();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        surfaceTintColor: AppColors.backgroundColor,
        backgroundColor: AppColors.backgroundColor,
        title: const Text(
          'Shipping Fee',
          style: TextStyle(
            fontFamily: AppFonts.palatino,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
      ),
      body: !loadingShippingFee
          ? shippingFee.isNotEmpty
              ? FeeTable(
                  feeData: shippingFee['state'],
                )
              : const Center(
                  child: Text(
                  "No data!",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: AppFonts.palatino,
                    fontSize: 18,
                  ),
                ))
          : const Center(
              child: CircularProgressIndicator(
              color: AppColors.primaryColor,
            )),
    );
  }
}
