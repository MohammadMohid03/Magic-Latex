import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../theme/app_theme.dart';
import '../providers/scan_provider.dart';
import '../widgets/action_button.dart';

class PreviewScreen extends StatelessWidget {
  const PreviewScreen({super.key});

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ScanProvider>();
    final image = provider.selectedImage;

    if (image == null) {
      return const Scaffold(
        body: Center(child: Text('No image selected')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Preview'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Retake'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Image preview with shimmer
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Shimmer placeholder
                      Shimmer.fromColors(
                        baseColor: AppColors.darkCard,
                        highlightColor: AppColors.darkSurface,
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.darkCard,
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                      // Actual image
                      Image.file(
                        image,
                        fit: BoxFit.contain,
                      ).animate().fade(duration: 500.ms),
                    ],
                  ),
                ).animate().fade(duration: 400.ms).scale(
                      begin: const Offset(0.97, 0.97),
                      end: const Offset(1, 1),
                      duration: 400.ms,
                    ),
              ),
            ),
            // File metadata
            FutureBuilder<FileStat>(
              future: image.stat(),
              builder: (context, snapshot) {
                final stat = snapshot.data;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.darkCard,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.image_rounded, color: AppColors.accent, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              image.path.split(Platform.pathSeparator).last,
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    color: AppColors.textPrimary,
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (stat != null)
                              Text(
                                _formatFileSize(stat.size),
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                      color: AppColors.textTertiary,
                                    ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ).animate().fade(delay: 200.ms, duration: 300.ms);
              },
            ),
            const SizedBox(height: 20),
            // Extract Text CTA
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ActionButton(
                label: 'Extract Text →',
                icon: Icons.text_fields_rounded,
                width: double.infinity,
                onPressed: () {
                  Navigator.of(context).pushReplacementNamed('/processing');
                },
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
