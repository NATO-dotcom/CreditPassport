
class Transaction {
  final DateTime date;
  final String receiptNumber;
  final double amount;
  final String description;
  final bool isInflow; 

  Transaction({
    required this.date,
    required this.receiptNumber,
    required this.amount,
    required this.description,
    required this.isInflow,
  });

  @override
  String toString() {
    return '$date | $receiptNumber | $amount | Inflow: $isInflow | $description';
  }
}