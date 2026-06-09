// lib/features/upload/upload_controller.dart
import 'package:credit_passport/models/transaction.dart';
import 'package:credit_passport/services/parser/mpesa_parser.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


// The provider that exposes our controller to the UI
final uploadControllerProvider = StateNotifierProvider<UploadController, AsyncValue<List<Transaction>>>((ref) {
  return UploadController();
});

class UploadController extends StateNotifier<AsyncValue<List<Transaction>>> {
  UploadController() : super(const AsyncData([]));

  Future<void> processStatement(String filePath, String password) async {
    // 1. Immediately tell the UI to show a loading spinner
    state = const AsyncLoading();
    
    try {
      // 2. Extract raw text from the PDF using the password
      // (We will plug in the syncfusion_flutter_pdf logic here)
      String rawText = await _extractTextFromPdf(filePath, password); 

      // 3. Hand the raw text to your new Parser Factory
      final parser = MpesaParser();
      
      if (!parser.isValidFormat(rawText)) {
        throw Exception('Invalid document format. Please upload an M-Pesa statement.');
      }

      final transactions = parser.parse(rawText);

      // 4. Update the state with the successful data!
      state = AsyncData(transactions);

    } catch (e, stackTrace) {
      // 5. If decryption fails or the password is wrong, tell the UI
      state = AsyncError(e, stackTrace);
    }
  }

  // Placeholder for the actual PDF decryption logic
  Future<String> _extractTextFromPdf(String filePath, String password) async {
    // Simulate a 2-second extraction delay for now
    await Future.delayed(const Duration(seconds: 2));
    return "Safaricom M-Pesa Statement... [Mock Data]"; 
  }
}