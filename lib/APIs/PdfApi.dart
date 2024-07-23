import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart' ;
import 'package:yeotaskin/view/profile%20screen/pdf_view_screen.dart';

class PdfApi {
  static Future<File> generatePDF({required ByteData imageSignature,required String icNumber}) async {
    final ByteData data = await rootBundle.load('assets/docs/Yeota_Sdn_Bhd.pdf');
    final Uint8List bytes = data.buffer.asUint8List();

    PdfDocument document = PdfDocument(inputBytes: bytes);
    final page = document.pages[8];
    final page1 = document.pages[0];
    drawSignature(page,page1 ,imageSignature,icNumber);
    return saveFile(document);
  }

  static Future<File> saveFile(PdfDocument document) async {
    final path = await getApplicationDocumentsDirectory();
    final fileName = '${path.path}/register_pdf.pdf';
    // const fileName1 = '/storage/emulated/0/Download/abc1.pdf';
    final file = File(fileName);
    file.writeAsBytes(await document.save());
    document.dispose();

    return file;
  }

  static void drawSignature(PdfPage page,PdfPage page1, ByteData imageSignature,String icNumber) {
    final pageSize = page.getClientSize();
    PdfFont font = PdfStandardFont(PdfFontFamily.helvetica, 12);
    final PdfBitmap image = PdfBitmap(imageSignature.buffer.asUint8List());
    page1.graphics.drawString(icNumber,font,bounds: Rect.fromLTWH(pageSize.width - 480, pageSize.height - 642, 200, 100), brush: PdfSolidBrush(PdfColor(0, 0, 0)));
    page.graphics.drawString(icNumber,font,bounds: Rect.fromLTWH(pageSize.width - 280, pageSize.height - 310, 200, 100), brush: PdfSolidBrush(PdfColor(0, 0, 0)));
    page.graphics.drawImage(image,
        Rect.fromLTWH(pageSize.width - 300, pageSize.height - 450, 200, 100));
  }
}

class PdfApiIcNumber {
  static Future<File> generatePDF({required String icNumber}) async {
    final ByteData data = await rootBundle.load('assets/docs/Yeota_Sdn_Bhd.pdf');
    final Uint8List bytes = data.buffer.asUint8List();

    PdfDocument document = PdfDocument(inputBytes: bytes);
    final page = document.pages[8];
    final page1 = document.pages[0];
    drawSignature(page,page1 ,icNumber);
    return saveFile(document);
  }

  static Future<File> saveFile(PdfDocument document) async {
    final path = await getApplicationDocumentsDirectory();
    final fileName = '${path.path}/register_pdf.pdf';
    // const fileName1 = '/storage/emulated/0/Download/abc1.pdf';
    final file = File(fileName);
    file.writeAsBytes(await document.save());
    document.dispose();

    return file;
  }

  static void drawSignature(PdfPage page,PdfPage page1,String icNumber) {
    final pageSize = page.getClientSize();
    PdfFont font = PdfStandardFont(PdfFontFamily.helvetica, 12);

    page1.graphics.drawString(icNumber,font,bounds: Rect.fromLTWH(pageSize.width - 480, pageSize.height - 642, 200, 100), brush: PdfSolidBrush(PdfColor(0, 0, 0)));
    page.graphics.drawString(icNumber,font,bounds: Rect.fromLTWH(pageSize.width - 280, pageSize.height - 310, 200, 100), brush: PdfSolidBrush(PdfColor(0, 0, 0)));

  }
}