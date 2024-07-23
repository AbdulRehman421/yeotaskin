import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:yeotaskin/utilities/app_fonts.dart';

import '../../utilities/app_colors.dart';

class PDFViewScreen extends StatelessWidget {
  final String stringURL;
  const PDFViewScreen({
    super.key,
    required this.stringURL,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        title: const Text(
          'Signed Document',
          style: TextStyle(
            fontFamily: AppFonts.palatino,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
      ),
      body: stringURL.isNotEmpty
          ? Container(
              child: SfPdfViewer.network(stringURL),
            )
          : const Center(child: Text("You don't have Signed Document")),
    );
  }
}
