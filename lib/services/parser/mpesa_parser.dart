import 'package:credit_passport/models/transaction.dart';
import 'base_parser.dart';

class MpesaParser implements BaseParser {
  @override
  bool isValidFormat(String rawText) {
    // Widened the net to catch both styles of M-Pesa statements
    return rawText.toLowerCase().contains('m-pesa statement') || 
           rawText.contains('Receipt No');
  }

  @override
  List<Transaction> parse(String rawText) {
    List<Transaction> extractedTransactions = [];

    final RegExp transactionPattern = RegExp(
      r'([A-Z0-9]{10})\s*\n(\d{4}-\d{2}-\d{2}\s\d{2}:\d{2}:\d{2})\s*\n([\s\S]*?)\nCompleted\s*\n([-\d,]+\.\d{2})\s*\n([-\d,]+\.\d{2})',
      multiLine: true,
    );

    final matches = transactionPattern.allMatches(rawText);

    for (final match in matches) {
      try {
        final String receipt = match.group(1) ?? '';
        final String dateString = match.group(2) ?? '';
        
        // Clean up the description by removing random line breaks
        final String description = match.group(3)?.replaceAll('\n', ' ').trim() ?? '';
        
        // Remove commas so Dart can parse it as a double (e.g., "1,500.00" -> "1500.00")
        final String amountString = match.group(4)?.replaceAll(',', '') ?? '0';

        final double rawAmount = double.parse(amountString);

        extractedTransactions.add(
          Transaction(
            date: DateTime.parse(dateString), // Perfectly parses "2026-06-15 17:01:12"
            receiptNumber: receipt,
            amount: rawAmount.abs(), // We keep the absolute amount positive for the UI
            description: description,
            isInflow: rawAmount > 0, // If it's a positive number, money came in!
          ),
        );
      } catch (e) {
        print('Error parsing row: $e');
        // If one transaction fails, we skip it and keep reading the rest
        continue;
      }
    }

    return extractedTransactions;
  }
}