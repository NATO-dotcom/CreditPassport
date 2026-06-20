import 'package:http/http.dart' as http;
import 'dart:convert';


import 'package:credit_passport/models/transaction.dart';

class TrustEngineClient {
  static const String baseUrl =
      'https://credit-passport-api-1.onrender.com/api/v1';
  
  Future<Map<String, dynamic>> signTransactions(
    List<Transaction> transactions,
  ) async {
    
    final url = Uri.parse('$baseUrl/sign-transactions');

    try {
      
      final List<Map<String, dynamic>> payload = transactions
          .map(
            (t) => {
              'id': t.receiptNumber,
              'date': t.date.toIso8601String(),
              'description': t.description,
              'amount': t.amount,
              'is_inflow': t.isInflow,
            },
          )
          .toList();

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to sign transactions: ${response.body}');
      }
    } catch (e) {
      throw Exception('Could not connect to Trust Engine: $e');
    }
  }
}
