import 'package:credit_passport/models/transaction.dart';
import 'package:credit_passport/services/parser/mpesa_parser.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


final uploadControllerProvider = StateNotifierProvider<UploadController, AsyncValue<List<Transaction>>>((ref) {
  return UploadController();
});

class UploadController extends StateNotifier<AsyncValue<List<Transaction>>> {
  UploadController() : super(const AsyncData([]));

  Future<void> processStatement(String filePath, String password) async {
    state = const AsyncLoading();
    
    try {
      
      String rawText = await _extractTextFromPdf(filePath, password); 

      
      final parser = MpesaParser();
      final transactions = parser.parse(rawText);

      state = AsyncData(transactions);

    } catch (e, stackTrace) {
      state = AsyncError(e, stackTrace);
    }
  }

  Future<String> _extractTextFromPdf(String filePath, String password) async {
    await Future.delayed(const Duration(seconds: 2));
    return "Safaricom M-Pesa Statement... [Mock Data]"; 
  }
}