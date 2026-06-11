import 'package:credit_passport/models/score.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfGenerator {
  static Future<void> exportPassport(
    Score score,
    String verificationId,
    int txCount,
  ) async {
    final pdf = pw.Document();

    final String verificationUrl =
        'https://verify.creditpassport.app/check/$verificationId';

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'CREDIT PASSPORT',
                        style: pw.TextStyle(
                          fontSize: 32,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.teal900,
                          letterSpacing: 1.5,
                        ),
                      ),
                      pw.SizedBox(height: 8),
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: pw.BoxDecoration(
                          color: PdfColors.teal50,
                          borderRadius: pw.BorderRadius.circular(4),
                        ),
                        child: pw.Text(
                          'CRYPTOGRAPHICALLY VERIFIED',
                          style: pw.TextStyle(
                            fontSize: 12,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.teal800,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                      pw.SizedBox(height: 12),
                      pw.Text(
                        'ID: $verificationId',
                        style: pw.TextStyle(
                          fontSize: 14,
                          color: PdfColors.grey700,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Text(
                        'Issued: ${DateTime.now().toLocal().toString().split(' ')[0]}',
                        style: pw.TextStyle(
                          fontSize: 12,
                          color: PdfColors.grey600,
                        ),
                      ),
                    ],
                  ),

                  pw.Container(
                    height: 90,
                    width: 90,
                    padding: const pw.EdgeInsets.all(4),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.teal200, width: 2),
                    ),
                    child: pw.BarcodeWidget(
                      barcode: pw.Barcode.qrCode(),
                      data: verificationUrl,
                      color: PdfColors.teal900,
                    ),
                  ),
                ],
              ),

              pw.SizedBox(height: 24),
              pw.Divider(thickness: 2, color: PdfColors.teal100),
              pw.SizedBox(height: 40),

              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text(
                      'FINANCIAL TRUST SCORE',
                      style: pw.TextStyle(
                        fontSize: 14,
                        color: PdfColors.grey600,
                        letterSpacing: 2,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      score.overallScore.toStringAsFixed(1),
                      style: pw.TextStyle(
                        fontSize: 90,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.teal900,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      'Based on $txCount securely analyzed local transactions',
                      style: pw.TextStyle(
                        fontSize: 12,
                        color: PdfColors.grey600,
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 60),

              pw.Text(
                'Algorithmic Breakdown',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blueGrey900,
                ),
              ),
              pw.SizedBox(height: 16),
              _buildMetricRow('Transaction Consistency', score.consistency),
              _buildMetricRow('Capital Savings Ratio', score.savingsRatio),
              _buildMetricRow(
                'Investment Multiplier',
                score.investmentMultiplier,
              ),

              pw.Spacer(),

              pw.Divider(color: PdfColors.grey300),
              pw.SizedBox(height: 16),
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text(
                      'Scan the QR code or visit the link below to verify this document.',
                      style: pw.TextStyle(
                        fontSize: 10,
                        color: PdfColors.grey800,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      verificationUrl,
                      style: pw.TextStyle(
                        fontSize: 10,
                        color: PdfColors.blue700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'CreditPassport_$verificationId.pdf',
    );
  }

  static pw.Widget _buildMetricRow(String title, double value) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 12),
      padding: const pw.EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey200),
        borderRadius: pw.BorderRadius.circular(8),
        color: PdfColors.grey50,
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blueGrey800,
            ),
          ),
          pw.Text(
            '${value.toStringAsFixed(1)} / 100.0',
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.teal800,
            ),
          ),
        ],
      ),
    );
  }
}
