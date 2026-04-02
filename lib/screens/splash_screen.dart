import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo icon
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [AppColors.accent, AppColors.accentDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accent.withValues(alpha: 0.4),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Icon(
                Icons.document_scanner_rounded,
                color: Colors.white,
                size: 48,
              ),
            )
                .animate()
                .fade(duration: 600.ms)
                .scale(
                  begin: const Offset(0.5, 0.5),
                  end: const Offset(1, 1),
                  duration: 600.ms,
                  curve: Curves.easeOutBack,
                ),
            const SizedBox(height: 28),
            // App name
            Text(
              'DocScan AI',
              style: GoogleFonts.poppins(
                fontSize: 34,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: -0.5,
              ),
            )
                .animate()
                .fade(delay: 300.ms, duration: 500.ms)
                .slideY(begin: 0.3, end: 0, delay: 300.ms, duration: 500.ms),
            const SizedBox(height: 8),
            // Tagline
            Text(
              'Capture.  Extract.  Export.',
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondary,
                letterSpacing: 2,
              ),
            )
                .animate()
                .fade(delay: 600.ms, duration: 500.ms)
                .slideY(begin: 0.3, end: 0, delay: 600.ms, duration: 500.ms),
            const SizedBox(height: 48),
            // Loading indicator
            SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: AppColors.accent.withValues(alpha: 0.6),
              ),
            ).animate().fade(delay: 900.ms, duration: 400.ms),
          ],
        ),
      ),
    );
  }
}
