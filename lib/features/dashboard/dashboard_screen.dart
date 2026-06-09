import 'package:credit_passport/models/score.dart';
import 'package:credit_passport/services/scoring/scoring_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../upload/upload_controller.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 2. Grab the parsed transactions from the Riverpod state
    final uploadState = ref.watch(uploadControllerProvider);
    final transactions = uploadState.value ?? [];

    // 3. RUN THE REAL ENGINE!
    final scoringEngine = ScoringEngine();
    final Score userScore = scoringEngine.calculateScore(transactions);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Credit Passport', style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- SCORE CARD ---
              // Mapping the real overall score here
              _buildScoreCard(userScore.overallScore, transactions.length),
              
              const SizedBox(height: 32),
              
              // --- RADAR CHART (SPIDER WEB) ---
              const Text('Financial Blueprint', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              // Mapping the real metric variables into the chart
              _buildRadarChartCard(
                userScore.consistency, 
                userScore.savingsRatio, 
                userScore.investmentMultiplier
              ),

              const SizedBox(height: 32),
              const Text('Metric Breakdown', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),

              // --- METRICS LIST ---
              _buildMetricTile('Consistency', userScore.consistency, Icons.sync),
              _buildMetricTile('Savings Ratio', userScore.savingsRatio, Icons.account_balance_wallet),
              _buildMetricTile('Investment Multiplier', userScore.investmentMultiplier, Icons.trending_up),

              const SizedBox(height: 48),

              // --- MONETIZATION BUTTON ---
              ElevatedButton.icon(
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text('Export Verified PDF (50 KES)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  backgroundColor: Colors.black87,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Payment & Export coming soon!')),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScoreCard(double score, int txCount) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.teal.shade800, Colors.teal.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.teal.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8))
        ]
      ),
      child: Column(
        children: [
          const Text('VERIFIED SCORE', style: TextStyle(color: Colors.white70, fontSize: 14, letterSpacing: 1.5, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
            score.toStringAsFixed(1),
            style: const TextStyle(color: Colors.white, fontSize: 64, fontWeight: FontWeight.bold, height: 1.1),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
            child: Text(
              'Analyzed $txCount local transactions',
              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRadarChartCard(double consistency, double savings, double investments) {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.teal.shade100, width: 1),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15)],
      ),
      child: RadarChart(
        RadarChartData(
          tickCount: 4,
          ticksTextStyle: const TextStyle(color: Colors.transparent),
          tickBorderData: const BorderSide(color: Colors.black12),
          gridBorderData: const BorderSide(color: Colors.black12, width: 1.5),
          radarBackgroundColor: Colors.transparent,
          borderData: FlBorderData(show: false),
          radarBorderData: const BorderSide(color: Colors.transparent),
          getTitle: (index, angle) {
            const style = TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 12);
            switch (index) {
              case 0: return const RadarChartTitle(text: 'Consistency', angle: 0);
              case 1: return const RadarChartTitle(text: 'Savings', angle: 0);
              case 2: return const RadarChartTitle(text: 'Investments', angle: 0);
              default: return const RadarChartTitle(text: '');
            }
          },
          dataSets: [
            RadarDataSet(
              fillColor: Colors.teal.withOpacity(0.3),
              borderColor: Colors.teal.shade600,
              entryRadius: 4,
              borderWidth: 3,
              dataEntries: [
                RadarEntry(value: consistency),
                RadarEntry(value: savings),
                RadarEntry(value: investments),
              ],
            )
          ],
        ),
        swapAnimationDuration: const Duration(milliseconds: 800),
        swapAnimationCurve: Curves.easeInOut,
      ),
    );
  }

  Widget _buildMetricTile(String title, double value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.teal.shade50, borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: Colors.teal.shade700, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600))),
            Text('${value.toStringAsFixed(0)} / 100', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
          ],
        ),
      ),
    );
  }
}