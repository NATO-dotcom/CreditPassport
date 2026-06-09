import 'package:credit_passport/models/transaction.dart';

abstract class BaseParser {
  /// Takes raw text extracted from a PDF and returns a list of standardized transactions.
  List<Transaction> parse(String rawText);

  /// A helper to verify if the uploaded text actually matches this specific parser.
  bool isValidFormat(String rawText);
}