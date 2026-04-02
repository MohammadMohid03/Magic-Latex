import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/recent_scan.dart';

class RecentScanCard extends StatelessWidget {
  final RecentScan scan;
  final VoidCallback? onTap;

  const RecentScanCard({super.key, required this.scan, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.darkCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.divider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // File icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                child: Icon(
                  Icons.picture_as_pdf_rounded,
                  color: AppColors.accent,
                  size: 22,
                ),
              ),
            ),
            const SizedBox(height: 12),
            // File name
            Text(
              scan.fileName,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            // Time ago
            Text(
              scan.timeAgo,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.textTertiary,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
