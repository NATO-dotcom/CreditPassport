import 'package:credit_passport/models/transaction.dart';
import 'base_parser.dart';

class MpesaParser implements BaseParser {
  @override
  bool isValidFormat(String rawText) {
    return rawText.toLowerCase().contains('safaricom') &&
        rawText.toLowerCase().contains('m-pesa statement');
  }

  @override
  List<Transaction> parse(String rawText) {
    List<Transaction> extractedTransactions = [];

    final RegExp transactionPattern = RegExp(
      r'([A-Z0-9]{10})\s+(\d{2}-\d{2}-\d{4})\s+\d{2}:\d{2}\s+(.+?)\s+([\d,]+\.\d{2})',
    );

    final matches = transactionPattern.allMatches(rawText);

    for (final match in matches) {
      final receipt = match.group(1) ?? '';
      final dateStr = match.group(2) ?? '';
      final description = match.group(3) ?? '';
      final amountStr = match.group(4)?.replaceAll(',', '') ?? '0';

      final isOutflow =
          description.toLowerCase().contains('paybill') ||
          description.toLowerCase().contains('send') ||
          description.toLowerCase().contains('withdrawal');

      try {
        extractedTransactions.add(
          Transaction(
            date: DateTime.now(),
            receiptNumber: receipt,
            amount: double.parse(amountStr),
            description: description.trim(),
            isInflow: !isOutflow,
          ),
        );
      } catch (e) {
        print('Error parsing row: $e');
      }
    }

    return extractedTransactions;
  }
}
