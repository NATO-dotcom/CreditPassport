import 'package:credit_passport/models/score.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


class TrustEngineClient {
  
  static const String baseUrl = 'http://192.168.109.19:8000/api/v1';

  Future<Map<String, dynamic>> signScore(Score score, int txCount) async {
    final url = Uri.parse('$baseUrl/sign-score');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'overall_score': score.overallScore,
          'consistency': score.consistency,
          'savings_ratio': score.savingsRatio,
          'investment_multiplier': score.investmentMultiplier,
          'transaction_count': txCount,
        }),
      );

      if (response.statusCode == 200) {
        
        return jsonDecode(response.body); 
      } else {
        throw Exception('Failed to sign score: ${response.body}');
      }
    } catch (e) {
      throw Exception('Could not connect to Trust Engine: $e');
    }
  }
}