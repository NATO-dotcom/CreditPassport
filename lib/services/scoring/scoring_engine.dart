

import 'package:credit_passport/models/score.dart';
import 'package:credit_passport/models/transaction.dart';

class ScoringEngine {
  /// Analyzes a list of transactions and returns a calculated Score
  Score calculateScore(List<Transaction> transactions) {
    if (transactions.isEmpty) {
      return Score(overallScore: 0, consistency: 0, savingsRatio: 0, investmentMultiplier: 0);
    }

    double totalInflow = 0;
    double totalOutflow = 0;
    double investmentVolume = 0;
    
    // 1. Loop through all transactions to aggregate data
    for (var tx in transactions) {
      if (tx.isInflow) {
        totalInflow += tx.amount;
      } else {
        totalOutflow += tx.amount;
        
        // Check for investment/savings keywords (e.g., M-Shwari, KCB, locked savings)
        final desc = tx.description.toLowerCase();
        if (desc.contains('m-shwari') || desc.contains('kcb') || desc.contains('chama')) {
          investmentVolume += tx.amount;
        }
      }
    }

    // 2. Calculate Consistency (Max 100)
    // For a basic MVP, we look at transaction volume. A healthy account has steady activity.
    // Let's assume an arbitrary baseline: 50 transactions a month is "100% consistent".
    double consistencyRaw = (transactions.length / 50.0) * 100;
    double consistency = consistencyRaw > 100 ? 100 : consistencyRaw;

    // 3. Calculate Savings Ratio (Max 100)
    // How much money is retained vs spent?
    double savingsRatio = 0;
    if (totalInflow > 0) {
      double retained = totalInflow - totalOutflow;
      // If they spend more than they make, ratio is 0. Otherwise calculate percentage.
      double ratio = retained > 0 ? (retained / totalInflow) * 100 : 0;
      // We scale it so saving 20% of income gives a 100 score for this metric
      savingsRatio = (ratio / 20.0) * 100;
      if (savingsRatio > 100) savingsRatio = 100;
    }

    // 4. Calculate Investment Multiplier (Max 100)
    // Does this user actively move money into savings/investment vehicles?
    double investmentMultiplier = 0;
    if (totalOutflow > 0) {
      // Percentage of outflows going to investments
      double investPercent = (investmentVolume / totalOutflow) * 100;
      // Scaling: if 10% of outflows are investments, they get a perfect score here
      investmentMultiplier = (investPercent / 10.0) * 100;
      if (investmentMultiplier > 100) investmentMultiplier = 100;
    }

    // 5. Final Weighted Formula
    double overallScore = (consistency * 0.4) + (savingsRatio * 0.4) + (investmentMultiplier * 0.2);

    return Score(
      overallScore: overallScore,
      consistency: consistency,
      savingsRatio: savingsRatio,
      investmentMultiplier: investmentMultiplier,
    );
  }
}