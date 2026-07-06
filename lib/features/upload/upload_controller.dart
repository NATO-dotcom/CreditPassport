import 'dart:io';
import 'package:credit_passport/models/transaction.dart';
import 'package:credit_passport/services/parser/mpesa_parser.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

// The provider that exposes our controller to the UI
final uploadControllerProvider =
    StateNotifierProvider<UploadController, AsyncValue<List<Transaction>>>((
      ref,
    ) {
      return UploadController();
    });

class UploadController extends StateNotifier<AsyncValue<List<Transaction>>> {
  UploadController() : super(const AsyncData([]));

  Future<void> processStatement(String filePath, String password) async {
    state = const AsyncLoading();

    try {
      String rawText = await _extractTextFromPdf(filePath, password);

      // ADD THIS LINE: Print the raw text to your Debug Console
      print('--- RAW PDF TEXT START ---');
      print(rawText);
      print('--- RAW PDF TEXT END ---');

      // 2. Hand the raw text to your Parser Factory
      final parser = MpesaParser();

      // 3. Validate the document format
      if (!parser.isValidFormat(rawText)) {
        throw Exception(
          'Invalid document format. Please upload an official M-Pesa statement.',
        );
      }

      // 4. Extract the real transactions
      final transactions = parser.parse(rawText);

      if (transactions.isEmpty) {
        throw Exception(
          'We could not find any valid transactions in this document.',
        );
      }

      // 5. Update the state to transition to the Dashboard!
      state = AsyncData(transactions);
    } catch (e, stackTrace) {
      // Catch wrong passwords, bad files, or parsing errors and display them on the UI
      state = AsyncError(e, stackTrace);
    }
  }

  /// Unlocks the PDF using the user's password and extracts all text
  Future<String> _extractTextFromPdf(String filePath, String password) async {
    try {
      // Read the physical file from the device
      final File file = File(filePath);
      final List<int> bytes = await file.readAsBytes();

      // Load the document using Syncfusion (this will fail if the password is wrong)
      final PdfDocument document = PdfDocument(
        inputBytes: bytes,
        password: password,
      );

      // Extract all text from the pages
      String extractedText = PdfTextExtractor(document).extractText();

      // Free up device memory
      document.dispose();

      return extractedText;
    } catch (e) {
      // THIS will show us the real underlying issue on the red screen!
      throw Exception('DEBUG ERROR: $e');
    }
  }
}
