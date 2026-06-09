import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../upload/upload_controller.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Grab the successfully parsed data from our controller
    final uploadState = ref.watch(uploadControllerProvider);
    
    // We only want to show this screen if we have data. 
    // If it's somehow empty or loading, show a fallback.
    final transactions = uploadState.value ?? [];

    // Placeholder mock calculations (We will build the real math engine next!)
    final mockScore = 78.5; 
    final consistency = 82.0;
    final savingsRatio = 65.0;
    final investmentMultiplier = 90.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Credit Passport'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- SCORE CARD ---
              Container(
                padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.teal.shade700, Colors.teal.shade400],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.teal.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))
                  ]
                ),
                child: Column(
                  children: [
                    const Text('YOUR VERIFIED SCORE', style: TextStyle(color: Colors.white70, fontSize: 14, letterSpacing: 1.2)),
                    const SizedBox(height: 8),
                    Text(
                      mockScore.toStringAsFixed(1),
                      style: const TextStyle(color: Colors.white, fontSize: 64, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Based on ${transactions.length} local transactions',
                      style: const TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              const Text('Scoring Breakdown', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),

              // --- METRICS LIST ---
              _buildMetricTile('Consistency (40%)', consistency, Icons.sync),
              _buildMetricTile('Savings Ratio (40%)', savingsRatio, Icons.account_balance_wallet),
              _buildMetricTile('Investment Multiplier (20%)', investmentMultiplier, Icons.trending_up),

              const SizedBox(height: 48),

              // --- MONETIZATION BUTTON ---
              ElevatedButton.icon(
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text('Export Verified PDF (50 KES)', style: TextStyle(fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.black87,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  // TODO: Trigger M-Pesa STK Push and generate PDF
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

  // Helper widget to keep the UI clean
  Widget _buildMetricTile(String title, double value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.teal),
            const SizedBox(width: 16),
            Expanded(child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500))),
            Text('${value.toStringAsFixed(1)} / 100', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}