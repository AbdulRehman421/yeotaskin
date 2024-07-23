import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:syncfusion_flutter_signaturepad/signaturepad.dart';
import 'package:yeotaskin/APIs/PdfApi.dart';

import 'package:yeotaskin/utilities/app_colors.dart';
import 'package:yeotaskin/view/auth/register-screen.dart';
import 'package:yeotaskin/view/auth/sign_doc_view_screen.dart';

import '../profile screen/pdf_view_screen.dart';

class SignatureCaptureScreen extends StatefulWidget {
  final Function saveSignature;
  final String icNumber;
  const SignatureCaptureScreen({super.key, required this.saveSignature,required this.icNumber});
  @override
  _SignatureCaptureScreenState createState() => _SignatureCaptureScreenState();
}

class _SignatureCaptureScreenState extends State<SignatureCaptureScreen> {
  final keySignaturePad = GlobalKey<SfSignaturePadState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        title: const Text("Capture Signature"),
      ),
      body: Center(
        child: Column(
          children: [
            SizedBox(
              height: 500,
              child: SfSignaturePad(
                key: keySignaturePad,
              ),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        foregroundColor: AppColors.backgroundColor),
                    onPressed: () {
                      keySignaturePad.currentState?.clear();
                    },
                    child: const Text("Clear Signature"),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        foregroundColor: AppColors.backgroundColor),
                    onPressed: saveSignature,
                    child: const Text("Save Signature"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future saveSignature() async {

    if (keySignaturePad.currentState!.toPathList().isEmpty) {
      return;
    }
    showDialog(barrierDismissible: true,
      context: context,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(
            color: AppColors.primaryColor,
          ),
        );
      },
    );
    final image = await keySignaturePad.currentState?.toImage();
    final imageSignature = await image!.toByteData(format: ImageByteFormat.png);
    final file = await PdfApi.generatePDF(imageSignature: imageSignature!, icNumber: widget.icNumber);
    documentPath = file.path;
   Navigator.of(context).pop();
    Navigator.of(context).pop();
    Navigator.of(context).pop();
    widget.saveSignature();

    //Navigator.push(context, MaterialPageRoute(builder: (context) => PViewScreen(url: documentPath),));
  }

}


/*
class PViewScreen extends StatelessWidget {
  final String url;
  const PViewScreen({super.key, required this.url});


  @override
  Widget build(BuildContext context) {
    print('object');
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
              Expanded(child: SfPdfViewer.asset( scrollDirection: PdfScrollDirection.horizontal, url)),
              Container(
                color: AppColors.backgroundColor,
                height: MediaQuery.of(context).size.height* 0.07,
              ),

            ],
          )
      ),
    );
  }
}
*/