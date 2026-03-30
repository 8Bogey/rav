import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PrintService {
  // Print test page
  static Future<void> printTestPage({
    required String printerName,
    required String documentTitle,
    required String documentPhone,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a5,
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.Text(
                  documentTitle,
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  documentPhone,
                  style: const pw.TextStyle(fontSize: 14),
                ),
                pw.SizedBox(height: 30),
                pw.Container(
                  width: 100,
                  height: 2,
                  color: PdfColors.black,
                ),
                pw.SizedBox(height: 30),
                pw.Text(
                  'Test Print / اختبار الطباعة',
                  style: const pw.TextStyle(fontSize: 16),
                ),
                pw.SizedBox(height: 20),
                pw.Text(
                  '✓ Print successful!',
                  style: const pw.TextStyle(fontSize: 12),
                ),
              ],
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Test Print',
    );
  }

  // Print receipt
  static Future<void> printReceipt({
    required String subscriberName,
    required String subscriberCode,
    required double amount,
    required String workerName,
    required String date,
    required String documentTitle,
    required String documentPhone,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a5,
        build: (pw.Context context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(20),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Text(
                  documentTitle,
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 5),
                pw.Text(
                  documentPhone,
                  style: const pw.TextStyle(fontSize: 12),
                ),
                pw.SizedBox(height: 15),
                pw.Container(
                  width: 150,
                  height: 1,
                  color: PdfColors.black,
                ),
                pw.SizedBox(height: 15),
                pw.Text(
                  'إيصال دفع / Payment Receipt',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('المشترك:', style: const pw.TextStyle(fontSize: 12)),
                    pw.Text(subscriberName, style: const pw.TextStyle(fontSize: 12)),
                  ],
                ),
                pw.SizedBox(height: 5),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('الرقم:', style: const pw.TextStyle(fontSize: 12)),
                    pw.Text(subscriberCode, style: const pw.TextStyle(fontSize: 12)),
                  ],
                ),
                pw.SizedBox(height: 5),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('المبلغ:', style: const pw.TextStyle(fontSize: 12)),
                    pw.Text('$amount IQD', style: const pw.TextStyle(fontSize: 12)),
                  ],
                ),
                pw.SizedBox(height: 5),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('العامل:', style: const pw.TextStyle(fontSize: 12)),
                    pw.Text(workerName, style: const pw.TextStyle(fontSize: 12)),
                  ],
                ),
                pw.SizedBox(height: 5),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('التاريخ:', style: const pw.TextStyle(fontSize: 12)),
                    pw.Text(date, style: const pw.TextStyle(fontSize: 12)),
                  ],
                ),
                pw.SizedBox(height: 20),
                pw.Container(
                  width: 150,
                  height: 1,
                  color: PdfColors.black,
                ),
                pw.SizedBox(height: 20),
                pw.Text(
                  'شكراً لاستخدامكم خدمتنا',
                  style: const pw.TextStyle(fontSize: 10),
                ),
                pw.Text(
                  'Thank you for using our service',
                  style: const pw.TextStyle(fontSize: 10),
                ),
              ],
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Receipt - $subscriberName',
    );
  }
}
