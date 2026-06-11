import 'package:credit_passport/features/upload/upload_controller.dart';
import 'package:credit_passport/models/score.dart';
import 'package:credit_passport/services/api/trust_engine_client.dart';
import 'package:credit_passport/services/pdf/pdf_generator.dart';
import 'package:credit_passport/services/scoring/scoring_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';


class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
   
    final uploadState = ref.watch(uploadControllerProvider);
    final transactions = uploadState.value ?? [];

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
              
              _buildScoreCard(userScore.overallScore, transactions.length),
              
              const SizedBox(height: 32),
              
             
              const Text('Financial Blueprint', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _buildRadarChartCard(
                userScore.consistency, 
                userScore.savingsRatio, 
                userScore.investmentMultiplier
              ),

              const SizedBox(height: 32),
              const Text('Metric Breakdown', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),

            
              _buildMetricTile('Consistency', userScore.consistency, Icons.sync),
              _buildMetricTile('Savings Ratio', userScore.savingsRatio, Icons.account_balance_wallet),
              _buildMetricTile('Investment Multiplier', userScore.investmentMultiplier, Icons.trending_up),

              const SizedBox(height: 48),

             
              ElevatedButton.icon(
                icon: const Icon(Icons.verified_user),
                label: const Text('Verify & Export PDF', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  backgroundColor: Colors.black87,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () async {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Contacting Trust Engine...'), duration: Duration(seconds: 1)),
                  );

                  try {
                  
                    final client = TrustEngineClient();
                    final result = await client.signScore(userScore, transactions.length);
                    
                    final verificationId = result['verification_id'];
                    
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Success! Secured with ID: $verificationId'),
                          backgroundColor: Colors.green.shade700,
                        ),
                      );

                      await PdfGenerator.exportPassport(userScore, verificationId, transactions.length);
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
                      );
                    }
                  }
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