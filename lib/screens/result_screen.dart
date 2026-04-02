import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/scan_provider.dart';
import '../widgets/code_block_view.dart';
import '../widgets/action_button.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    final provider = Provider.of<ScanProvider>(context, listen: false);
    _textController = TextEditingController(
      text: provider.scanResult?.extractedText ?? '',
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _copyText() {
    Clipboard.setData(ClipboardData(text: _textController.text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle_outline, color: AppColors.success, size: 18),
            SizedBox(width: 8),
            Text('Text copied to clipboard'),
          ],
        ),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ScanProvider>();
    final result = provider.scanResult;

    if (result == null) {
      return const Scaffold(
        body: Center(child: Text('No result available')),
      );
    }

    final wordCount = _textController.text.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
    final charCount = _textController.text.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Results'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            provider.reset();
            Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
          },
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.text_snippet_rounded), text: 'Extracted Text'),
            Tab(icon: Icon(Icons.code_rounded), text: 'LaTeX Code'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Extracted Text
          _buildExtractedTextTab(context, wordCount, charCount),
          // Tab 2: LaTeX Code
          _buildLatexTab(context, result.latexCode),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(context, provider),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).pushNamed('/pdfPreview');
        },
        backgroundColor: AppColors.accent,
        icon: const Icon(Icons.picture_as_pdf_rounded, color: Colors.white),
        label: const Text('Preview PDF', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildExtractedTextTab(BuildContext context, int wordCount, int charCount) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats row
          Row(
            children: [
              _buildStatBadge(context, '$wordCount words', Icons.short_text_rounded),
              const SizedBox(width: 8),
              _buildStatBadge(context, '$charCount chars', Icons.text_format_rounded),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.copy_rounded, color: AppColors.accent, size: 20),
                onPressed: _copyText,
                tooltip: 'Copy to clipboard',
              ),
            ],
          ).animate().fade(duration: 300.ms),
          const SizedBox(height: 16),
          // Editable text field
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.darkCard,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.divider),
              ),
              child: TextField(
                controller: _textController,
                maxLines: null,
                expands: true,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      height: 1.6,
                    ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Extracted text will appear here...',
                  hintStyle: TextStyle(color: AppColors.textTertiary),
                ),
                onChanged: (value) => setState(() {}),
              ),
            ).animate().fade(delay: 150.ms, duration: 400.ms),
          ),
        ],
      ),
    );
  }

  Widget _buildLatexTab(BuildContext context, String latexCode) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: CodeBlockView(
        code: latexCode,
        title: 'LaTeX Source',
      ).animate().fade(duration: 400.ms).slideY(begin: 0.02, end: 0, duration: 400.ms),
    );
  }

  Widget _buildStatBadge(BuildContext context, String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.accent, size: 14),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.accent,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, ScanProvider provider) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        children: [
          Expanded(
            child: ActionButton(
              label: 'Regenerate',
              icon: Icons.refresh_rounded,
              isPrimary: false,
              onPressed: () {
                Navigator.of(context).pushReplacementNamed('/processing');
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ActionButton(
              label: 'Download PDF',
              icon: Icons.download_rounded,
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(Icons.download_done_rounded, color: AppColors.success, size: 18),
                        const SizedBox(width: 8),
                        Text('PDF saved to: ${provider.scanResult?.pdfPath ?? "N/A"}'),
                      ],
                    ),
                    duration: const Duration(seconds: 3),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
