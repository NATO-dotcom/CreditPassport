import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'upload_controller.dart';
import '../dashboard/dashboard_screen.dart';

// THE FIX: We changed this from String? to PlatformFile? 
// Now it holds BOTH the file name and the file path!
final selectedFileProvider = StateProvider<PlatformFile?>((ref) => null);

class UploadScreen extends ConsumerStatefulWidget {
  const UploadScreen({super.key});

  @override
  ConsumerState<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends ConsumerState<UploadScreen> {
  late TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // THE FIX: Watch the whole file object now
    final selectedFile = ref.watch(selectedFileProvider);
    final uploadState = ref.watch(uploadControllerProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Upload Statement',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        foregroundColor: Colors.black,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (selectedFile == null) ...[
                const Text(
                  'Select your encrypted M-Pesa or Bank PDF statement to begin local extraction.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                const Spacer(),
                
                _buildCoolDropzone(),
                const Spacer(),
                
                _buildInstructionStepper(),
                const Spacer(),
              ] else ...[
                // THE FIX: Pass just the name to the UI card
                _buildFileCard(selectedFile.name),
                const Spacer(),
                uploadState.when(
                  loading: () => const Center(
                    child: CircularProgressIndicator(color: Colors.teal),
                  ),
                  error: (error, stack) => Column(
                    children: [
                      Text(
                        error.toString(),
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      // THE FIX: Pass the PATH to the button so the controller can find the file
                      _buildProcessButton(selectedFile.path!),
                    ],
                  ),
                  // THE FIX: Pass the PATH to the button
                  data: (_) => _buildProcessButton(selectedFile.path!),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCoolDropzone() {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: () async {
        FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['pdf'],
        );
        if (result != null) {
          // THE FIX: Save the entire file object instead of just result.files.single.name
          ref.read(selectedFileProvider.notifier).state = result.files.single;
        }
      },
      child: Container(
        width: double.infinity,
        height: 240, 
        decoration: BoxDecoration(
          color: Colors.teal.shade50.withOpacity(0.4),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Colors.teal.shade300,
            width: 2,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_upload, size: 80, color: Colors.teal.shade400),
            const SizedBox(height: 20),
            const Text(
              'Tap to Select PDF',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionStepper() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'How it works:',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 16),
        _StepItem(
          icon: Icons.insert_drive_file,
          text: 'Select your protected PDF statement.',
          iconColor: Colors.blue.shade700,
        ),
        _StepItem(
          icon: Icons.vpn_key,
          text: 'Enter your password to unlock it locally.',
          iconColor: Colors.amber.shade700,
        ),
        _StepItem(
          icon: Icons.phone_android,
          text: 'We analyze your data right on your phone.',
          iconColor: Colors.purple.shade700,
        ),
        _StepItem(
          icon: Icons.security,
          text: 'No data ever leaves your device.',
          iconColor: Colors.teal.shade700,
        ),
      ],
    );
  }

  Widget _buildFileCard(String fileName) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.picture_as_pdf,
                color: Colors.redAccent,
                size: 30,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  fileName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.cancel),
                onPressed: () =>
                    ref.read(selectedFileProvider.notifier).state = null,
              ),
            ],
          ),
          const Divider(height: 32),
          const Text(
            'Document Password',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              hintText: 'Enter PDF Password',
            ),
          ),
        ],
      ),
    );
  }

  // THE FIX: Notice this function now accepts the filePath string directly!
  Widget _buildProcessButton(String filePath) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 18),
          backgroundColor: Colors.teal.shade700,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        onPressed: () async {
          if (_passwordController.text.isNotEmpty) {
            
            // THE FIX: We pass the filePath string straight into the controller
            await ref
                .read(uploadControllerProvider.notifier)
                .processStatement(filePath, _passwordController.text);

            if (ref.read(uploadControllerProvider).hasValue && mounted) {
              _passwordController.clear();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DashboardScreen(),
                ),
              );
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Please enter password')),
            );
          }
        },
        child: const Text(
          'Process Locally',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class _StepItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color iconColor;

  const _StepItem({
    required this.icon,
    required this.text,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: iconColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}