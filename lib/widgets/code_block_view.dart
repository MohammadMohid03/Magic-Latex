import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class CodeBlockView extends StatelessWidget {
  final String code;
  final String title;

  const CodeBlockView({super.key, required this.code, this.title = 'LaTeX Code'});

  void _copyToClipboard(BuildContext context) {
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: AppColors.success, size: 18),
            const SizedBox(width: 8),
            Text('$title copied to clipboard'),
          ],
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.darkCard,
            borderRadius:
                const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
            border: Border.all(color: AppColors.divider),
          ),
          child: Row(
            children: [
              const Icon(Icons.code_rounded, color: AppColors.accent, size: 18),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: AppColors.accent,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const Spacer(),
              InkWell(
                onTap: () => _copyToClipboard(context),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.accent.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.copy_rounded, color: AppColors.accent, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        'Copy',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: AppColors.accent,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        // Code content
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF0D1117),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(12),
              bottomRight: Radius.circular(12),
            ),
            border: Border.all(color: AppColors.divider),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SelectableText(
              code,
              style: GoogleFonts.firaCode(
                fontSize: 13,
                color: const Color(0xFFC9D1D9),
                height: 1.6,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
