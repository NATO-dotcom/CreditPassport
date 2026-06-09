import 'package:credit_passport/models/transaction.dart';

import 'base_parser.dart';


class MpesaParser implements BaseParser {
  @override
  bool isValidFormat(String rawText) {
    // A simple check to ensure the user didn't upload a random document
    return rawText.toLowerCase().contains('safaricom') &&
        rawText.toLowerCase().contains('m-pesa statement');
  }

  @override
  List<Transaction> parse(String rawText) {
    List<Transaction> extractedTransactions = [];

    // Safaricom statements usually have lines like:
    // "QHT8Y... 12-05-2023 14:30 Customer Transfer to John Doe 500.00 1500.00"
    // This is a simplified Regex to catch standard receipt patterns.
    // As the structures change, you only ever have to update this one block of code.
    final RegExp transactionPattern = RegExp(
      r'([A-Z0-9]{10})\s+(\d{2}-\d{2}-\d{4})\s+\d{2}:\d{2}\s+(.+?)\s+([\d,]+\.\d{2})',
    );

    final matches = transactionPattern.allMatches(rawText);

    for (final match in matches) {
      final receipt = match.group(1) ?? '';
      final dateStr = match.group(2) ?? '';
      final description = match.group(3) ?? '';
      final amountStr = match.group(4)?.replaceAll(',', '') ?? '0';

      // Basic logic to determine if it's money in or out based on keywords
      final isOutflow =
          description.toLowerCase().contains('paybill') ||
          description.toLowerCase().contains('send') ||
          description.toLowerCase().contains('withdrawal');

      try {
        extractedTransactions.add(
          Transaction(
            // In a production environment, we'd format the date properly
            date: DateTime.now(),
            receiptNumber: receipt,
            amount: double.parse(amountStr),
            description: description.trim(),
            isInflow: !isOutflow,
          ),
        );
      } catch (e) {
        // If a row fails to parse, we skip it and move on to keep the ETL pipeline moving
        print('Error parsing row: $e');
      }
    }

    return extractedTransactions;
  }
}
