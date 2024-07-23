import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:yeotaskin/APIs/urls.dart';

import '../../../../utilities/app_colors.dart';
import '../../../../utilities/app_fonts.dart';

class InvoiceViewScreen extends StatelessWidget {
  final String orderId;
  const InvoiceViewScreen({super.key,required this.orderId});

  @override
  Widget build(BuildContext context) {
    print("${URLs.baseURL}${URLs.viewInvoiceURL}/$orderId");
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        surfaceTintColor: AppColors.backgroundColor,
        backgroundColor: AppColors.backgroundColor,
        title: const Text(
          'Invoice',
          style: TextStyle(
            fontFamily: AppFonts.palatino,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
      ),
      body: InAppWebView(
        initialUrlRequest: URLRequest(url: Uri.parse("${URLs.baseURL}${URLs.viewInvoiceURL}/$orderId")),
        initialOptions: InAppWebViewGroupOptions(
          crossPlatform: InAppWebViewOptions(
            javaScriptEnabled: true,
          ),
        ),
      ),
    );
  }
}
