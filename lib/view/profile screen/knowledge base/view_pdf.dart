import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:external_path/external_path.dart';

import '../../../utilities/app_colors.dart';
import '../../../utilities/app_fonts.dart';
import '../../../utilities/snackbar_utils.dart';



class ViewPdfScreen extends StatefulWidget {
  final String url;

  const ViewPdfScreen({super.key, required this.url});

  @override
  State<ViewPdfScreen> createState() => _ViewPdfScreenState();
}

class _ViewPdfScreenState extends State<ViewPdfScreen> {
  bool loading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        surfaceTintColor: AppColors.backgroundColor,
        backgroundColor: AppColors.backgroundColor,
        title: const Text(
          'View Document',
          style: TextStyle(
            fontFamily: AppFonts.palatino,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
      ),
      body: Container(
          child: Column(
            children: [
              // Container(
              //   height: MediaQuery
              //       .of(context)
              //       .size
              //       .height * 0.17,
              // ),
              Expanded(child: SfPdfViewer.network( "https://${widget.url}",),),
              !loading ?ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      foregroundColor: Colors.white),
                  onPressed: () {
                _downloadPdf();
              }, child: const Icon(Icons.download))
                  :const Padding(
                padding: EdgeInsets.all(10),
                child: CircularProgressIndicator(),
              ),
              Container(

                height: MediaQuery
                    .of(context)
                    .size
                    .height * 0.08,
              ),
            ],
          )
      ),
    );
  }


  Future<void> _downloadPdf() async {
    setState(() {
      loading = true;
    });

    try {
      Dio dio = Dio();
      String appDownloadPath = await ExternalPath.getExternalStoragePublicDirectory(ExternalPath.DIRECTORY_DOWNLOADS);
      List fileNameList = widget.url.split("/");
      String fileName = fileNameList.elementAt(fileNameList.length-1);
      String filePath = '$appDownloadPath/Yeotaskin/$fileName';

      await dio.download(
          "https://${widget.url}",
          filePath
      );


      SnackBarUtils.show(title: 'File downloaded to: $filePath', isError: false, duration: 3);
      if (kDebugMode) {
        print("File downloaded to: $filePath");
      }

    } catch (e) {
      SnackBarUtils.show(title: 'Something went wrong while downloading!', isError: true);
      if (kDebugMode) {
        print("Error downloading PDF: $e");
      }
    }

    setState(() {
      loading = false;
    });
  }

}
