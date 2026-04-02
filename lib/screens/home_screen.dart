import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/scan_provider.dart';
import '../widgets/glowing_card.dart';
import '../widgets/action_button.dart';
import '../widgets/recent_scan_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _onCameraTap() async {
    final provider = Provider.of<ScanProvider>(context, listen: false);
    provider.reset();
    final success = await provider.pickFromCamera();
    if (mounted) {
      if (success) {
        Navigator.of(context).pushNamed('/preview');
      } else if (provider.selectedImage == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Camera was cancelled or permission denied')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('File too large. Maximum size is 10MB.')),
        );
      }
    }
  }

  Future<void> _onGalleryTap() async {
    final provider = Provider.of<ScanProvider>(context, listen: false);
    provider.reset();
    final success = await provider.pickFromGallery();
    if (mounted) {
      if (success) {
        Navigator.of(context).pushNamed('/preview');
      } else if (provider.selectedImage == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gallery picker was cancelled or permission denied')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('File too large. Maximum size is 10MB.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ScanProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [AppColors.accent, AppColors.accentDark],
                ),
              ),
              child: const Icon(Icons.document_scanner_rounded, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            Text(
              'DocScan AI',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            onPressed: () => Navigator.of(context).pushNamed('/settings'),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              // Hero Card
              Expanded(
                child: Center(
                  child: GlowingCard(
                    onTap: _onCameraTap,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Pulsing camera icon
                        AnimatedBuilder(
                          animation: _pulseController,
                          builder: (context, child) {
                            return Container(
                              width: 90,
                              height: 90,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.accent.withValues(
                                    alpha: 0.3 + (_pulseController.value * 0.4),
                                  ),
                                  width: 2 + (_pulseController.value * 2),
                                ),
                              ),
                              child: Container(
                                margin: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: [
                                      AppColors.accent.withValues(alpha: 0.2),
                                      AppColors.accentDark.withValues(alpha: 0.1),
                                    ],
                                  ),
                                ),
                                child: const Icon(
                                  Icons.camera_alt_rounded,
                                  color: AppColors.accent,
                                  size: 36,
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Tap to scan a document',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'or upload from gallery',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.textTertiary,
                              ),
                        ),
                        const SizedBox(height: 28),
                        // Action buttons
                        Row(
                          children: [
                            Expanded(
                              child: ActionButton(
                                label: 'Camera',
                                icon: Icons.camera_alt_rounded,
                                onPressed: _onCameraTap,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ActionButton(
                                label: 'Gallery',
                                icon: Icons.photo_library_rounded,
                                isPrimary: false,
                                onPressed: _onGalleryTap,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ).animate().fade(duration: 500.ms).slideY(begin: 0.05, end: 0, duration: 500.ms),
              ),
              const SizedBox(height: 24),
              // Recent Scans
              Text(
                'Recent Scans',
                style: Theme.of(context).textTheme.titleLarge,
              ).animate().fade(delay: 200.ms, duration: 400.ms),
              const SizedBox(height: 12),
              SizedBox(
                height: 130,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: provider.recentScans.length,
                  itemBuilder: (context, index) {
                    return RecentScanCard(
                      scan: provider.recentScans[index],
                    )
                        .animate()
                        .fade(delay: Duration(milliseconds: 300 + index * 100), duration: 400.ms)
                        .slideX(
                          begin: 0.1,
                          end: 0,
                          delay: Duration(milliseconds: 300 + index * 100),
                          duration: 400.ms,
                        );
                  },
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
