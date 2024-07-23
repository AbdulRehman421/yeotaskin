import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:yeotaskin/view/auth/signature-capture-screen.dart';

import '../../utilities/app_colors.dart';


class SignedDocViewScreen extends StatelessWidget {
  final String url;
  final Function saveSignature;
  final String icNumber;
  const SignedDocViewScreen({super.key, required this.saveSignature,required this.icNumber,required this.url});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        title: Text('Document to Sign'),
      ),
      body:Container(
        child: Column(
          children: [
            Container(
              color: AppColors.backgroundColor,
              height: MediaQuery.of(context).size.height* 0.07,
            ),
            Expanded(child: SfPdfViewer.asset( scrollDirection: PdfScrollDirection.horizontal,url)),
            Container(
              color: AppColors.backgroundColor,
              height: MediaQuery.of(context).size.height* 0.07,
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 20,horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
              style: ElevatedButton.styleFrom(
              foregroundColor:
                  AppColors.backgroundColor,
                  backgroundColor: AppColors.threeLevelColor),
                      onPressed: () {
                Navigator.pop(context);
                  }, child: Text("Cancel")),
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          foregroundColor:
                          AppColors.backgroundColor,
                          backgroundColor: AppColors.primaryColor),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                            builder: (context) =>
                            SignatureCaptureScreen(
                                saveSignature: saveSignature, icNumber: icNumber,),
                        ));
                      }, child: const Text("Agree to Sign")),
                ],
              ),
            )
          ],
        )
        ),
    );
  }
}
