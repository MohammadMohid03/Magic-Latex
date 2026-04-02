import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/scan_provider.dart';
import '../widgets/pipeline_stepper.dart';

class ProcessingScreen extends StatefulWidget {
  const ProcessingScreen({super.key});

  @override
  State<ProcessingScreen> createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends State<ProcessingScreen> {
  @override
  void initState() {
    super.initState();
    _runPipeline();
  }

  Future<void> _runPipeline() async {
    final provider = Provider.of<ScanProvider>(context, listen: false);
    await provider.runPipeline();
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/result');
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ScanProvider>();

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Background animated particles effect
            ..._buildBackgroundParticles(),
            // Main content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 60),
                  // Header
                  Text(
                    'Processing Document',
                    style: GoogleFonts.poppins(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ).animate().fade(duration: 400.ms).slideY(begin: -0.1, end: 0, duration: 400.ms),
                  const SizedBox(height: 8),
                  Text(
                    'Please wait while we process your document...',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textTertiary,
                        ),
                    textAlign: TextAlign.center,
                  ).animate().fade(delay: 200.ms, duration: 400.ms),
                  const SizedBox(height: 48),
                  // Pipeline Stepper
                  PipelineStepper(currentStep: provider.processingStep),
                  const Spacer(),
                  // Scanning beam animation
                  _buildScanningBeam(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildBackgroundParticles() {
    return List.generate(
      6,
      (index) => Positioned(
        left: (index * 67.0) % MediaQuery.of(context).size.width,
        top: (index * 103.0) % MediaQuery.of(context).size.height,
        child: Container(
          width: 4 + (index * 2.0),
          height: 4 + (index * 2.0),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.accent.withValues(alpha: 0.1 + (index * 0.02)),
          ),
        )
            .animate(
              onPlay: (controller) => controller.repeat(reverse: true),
            )
            .moveY(
              begin: 0,
              end: -20 - (index * 5.0),
              duration: Duration(seconds: 2 + index),
            )
            .fade(
              begin: 0.3,
              end: 0.8,
              duration: Duration(seconds: 2 + index),
            ),
      ),
    );
  }

  Widget _buildScanningBeam() {
    return Container(
      width: 200,
      height: 3,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(2),
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            AppColors.accent.withValues(alpha: 0.6),
            AppColors.accent,
            AppColors.accent.withValues(alpha: 0.6),
            Colors.transparent,
          ],
        ),
      ),
    )
        .animate(onPlay: (controller) => controller.repeat())
        .moveX(begin: -100, end: 100, duration: 1500.ms)
        .then()
        .moveX(begin: 100, end: -100, duration: 1500.ms);
  }
}
