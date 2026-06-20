import 'package:flutter/material.dart';

class MpesaInstructionsSheet extends StatelessWidget {
  const MpesaInstructionsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Wraps tightly around the content
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'How to get your M-Pesa Statement',
            style: TextStyle(
              fontSize: 20, 
              fontWeight: FontWeight.bold,
              color: Colors.teal,
            ),
          ),
          const SizedBox(height: 24),
          
          // Option 1: The USSD Route
          _buildInstructionStep(
            icon: Icons.dialpad,
            title: 'Method 1: USSD (Any Phone)',
            details: '1. Dial *334#\n2. Select "My Account"\n3. Select "M-PESA Statements"\n4. Choose "Full Statement" and select your duration.\n5. The PDF password is your national ID.',
          ),
          
          const Divider(height: 32, thickness: 1),
          
          // Option 2: The App Route
          _buildInstructionStep(
            icon: Icons.smartphone,
            title: 'Method 2: Safaricom App',
            details: '1. Open the M-Pesa App\n2. Tap "Statements" at the bottom\n3. Tap the Download Icon (top right)\n4. Export as PDF to your phone files.',
          ),
          
          const SizedBox(height: 32),
          
          // A quick close button for good UX
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text('Got it, let\'s upload!'),
            ),
          ),
        ],
      ),
    );
  }

  // A helper function to keep the UI code clean
  Widget _buildInstructionStep({
    required IconData icon, 
    required String title, 
    required String details,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.teal[700], size: 28),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title, 
                style: const TextStyle(
                  fontWeight: FontWeight.bold, 
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                details, 
                style: TextStyle(
                  color: Colors.grey[800], 
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}