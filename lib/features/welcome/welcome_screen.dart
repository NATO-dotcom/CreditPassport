import 'package:flutter/material.dart';
import '../upload/upload_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 1. Add a premium full-screen gradient
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.teal.shade800, Colors.teal.shade300],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // 2. Expand the hero section to fill empty space
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      // Our new custom logo widget called here!
                      CreditPassportLogo(),
                      SizedBox(height: 24),
                      Text(
                        'CreditPassport',
                        style: TextStyle(
                          fontSize: 36, 
                          fontWeight: FontWeight.bold, 
                          color: Colors.white, 
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // 3. Group the text and button into a bottom card
              Container(
                padding: const EdgeInsets.all(32.0),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Your Financial Identity,\nVerified Locally.',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, height: 1.2),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Generate your verified passport instantly. 100% Private. Your data never leaves this device.',
                      style: TextStyle(fontSize: 16, color: Colors.black54, height: 1.4),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        backgroundColor: Colors.teal.shade700,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const UploadScreen()),
                        );
                      },
                      child: const Text('Get Started', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- CUSTOM WIDGETS ---

class CreditPassportLogo extends StatelessWidget {
  const CreditPassportLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      height: 150,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 1. The Ambient Glow
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withOpacity(0.2),
                  blurRadius: 40,
                  spreadRadius: 10,
                )
              ],
            ),
          ),
          
          // 2. The Background Card (Tilted) - IMPROVED OUTLINE
          Transform.rotate(
            angle: -0.2, // Tilts to the left
            child: Container(
              width: 85,
              height: 115,
              decoration: BoxDecoration(
                color: Colors.teal.shade900,
                borderRadius: BorderRadius.circular(16),
                // Sharper, semi-transparent border for a premium edge
                border: Border.all(color: Colors.teal.shade300.withOpacity(0.5), width: 1.5), 
                boxShadow: const [
                  BoxShadow(color: Colors.black45, blurRadius: 10, offset: Offset(-2, 4))
                ],
              ),
            ),
          ),

          // 3. The Main Front Card (The "Passport") - CRISPER SHADOWS
          Container(
            width: 90,
            height: 125,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.white, Colors.grey.shade100],
              ),
              borderRadius: BorderRadius.circular(16),
              // Crisp white outline to separate it cleanly from the background card
              border: Border.all(color: Colors.white, width: 2), 
              boxShadow: const [
                BoxShadow(color: Colors.black26, blurRadius: 15, offset: Offset(0, 8))
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.fingerprint, size: 50, color: Colors.teal.shade800),
                const SizedBox(height: 12),
                Container(
                  width: 45, height: 4, 
                  decoration: BoxDecoration(color: Colors.teal.shade200, borderRadius: BorderRadius.circular(2))
                ),
                const SizedBox(height: 6),
                Container(
                  width: 30, height: 4, 
                  decoration: BoxDecoration(color: Colors.teal.shade200, borderRadius: BorderRadius.circular(2))
                ),
              ],
            ),
          ),

          // 4. The Verification Badge - THICKER CUTOUT BORDER
          Positioned(
            bottom: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.amber.shade400,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2.5), // Acts as a clean cutout
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 3))
                ]
              ),
              child: Icon(Icons.check, size: 18, color: Colors.teal.shade900),
            ),
          )
        ],
      ),
    );
  }
}