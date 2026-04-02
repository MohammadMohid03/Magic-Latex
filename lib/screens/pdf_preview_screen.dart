import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class PdfPreviewScreen extends StatelessWidget {
  const PdfPreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF Preview'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          // Page counter
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            margin: const EdgeInsets.only(right: 4),
            decoration: BoxDecoration(
              color: AppColors.darkCard,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '1 / 3',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.share_rounded),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Share feature coming soon')),
              );
            },
            tooltip: 'Share',
          ),
          IconButton(
            icon: const Icon(Icons.download_rounded),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Row(
                    children: [
                      Icon(Icons.download_done_rounded, color: AppColors.success, size: 18),
                      SizedBox(width: 8),
                      Text('PDF downloaded successfully'),
                    ],
                  ),
                ),
              );
            },
            tooltip: 'Download',
          ),
        ],
      ),
      body: Center(
        // Since we have a mock PDF path, show a placeholder PDF representation
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Mock PDF content
                      Center(
                        child: Text(
                          'Scanned Document',
                          style: GoogleFonts.inter(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: Text(
                          'DocScan AI',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Center(
                        child: Text(
                          'March 2, 2026',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Colors.black45,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      Container(width: double.infinity, height: 1, color: Colors.black12),
                      const SizedBox(height: 24),
                      Text(
                        'The quick brown fox jumps over the lazy dog. This is a sample of extracted handwritten text from your document.',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Colors.black87,
                          height: 1.7,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris.',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Colors.black87,
                          height: 1.7,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Colors.black87,
                          height: 1.7,
                        ),
                      ),
                      const Spacer(),
                      Center(
                        child: Text(
                          '— Generated by DocScan AI —',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: Colors.black38,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ).animate().fade(duration: 400.ms).scale(
                begin: const Offset(0.95, 0.95),
                end: const Offset(1, 1),
                duration: 400.ms,
              ),
        ),
      ),
    );
  }
}
