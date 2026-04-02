import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/scan_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ScanProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Appearance section
            _buildSectionHeader(context, 'Appearance'),
            const SizedBox(height: 12),
            _buildSettingTile(
              context: context,
              icon: Icons.dark_mode_rounded,
              title: 'Dark Mode',
              subtitle: provider.isDarkMode ? 'Enabled' : 'Disabled',
              trailing: Switch(
                value: provider.isDarkMode,
                onChanged: (_) => provider.toggleDarkMode(),
                activeThumbColor: AppColors.accent,
              ),
            ).animate().fade(duration: 300.ms),
            const SizedBox(height: 12),

            // Document settings section
            _buildSectionHeader(context, 'Document'),
            const SizedBox(height: 12),
            _buildSettingTile(
              context: context,
              icon: Icons.description_rounded,
              title: 'Default Paper Size',
              subtitle: provider.paperSize,
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.darkCard,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.divider),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: provider.paperSize,
                    isDense: true,
                    dropdownColor: AppColors.darkCard,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textPrimary,
                        ),
                    items: const [
                      DropdownMenuItem(value: 'A4', child: Text('A4')),
                      DropdownMenuItem(value: 'Letter', child: Text('Letter')),
                    ],
                    onChanged: (value) {
                      if (value != null) provider.setPaperSize(value);
                    },
                  ),
                ),
              ),
            ).animate().fade(delay: 100.ms, duration: 300.ms),
            const SizedBox(height: 12),
            _buildSettingTile(
              context: context,
              icon: Icons.person_rounded,
              title: 'Author Name',
              subtitle: provider.authorName.isEmpty ? 'Not set' : provider.authorName,
              trailing: SizedBox(
                width: 140,
                child: TextField(
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textPrimary,
                      ),
                  decoration: InputDecoration(
                    hintText: 'Enter name',
                    hintStyle: TextStyle(color: AppColors.textTertiary, fontSize: 13),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AppColors.divider),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AppColors.divider),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AppColors.accent),
                    ),
                  ),
                  onChanged: provider.setAuthorName,
                ),
              ),
            ).animate().fade(delay: 200.ms, duration: 300.ms),
            const SizedBox(height: 12),

            // Storage section
            _buildSectionHeader(context, 'Storage'),
            const SizedBox(height: 12),
            _buildSettingTile(
              context: context,
              icon: Icons.save_alt_rounded,
              title: 'Save Scans to Gallery',
              subtitle: provider.saveToGallery ? 'Enabled' : 'Disabled',
              trailing: Switch(
                value: provider.saveToGallery,
                onChanged: (_) => provider.toggleSaveToGallery(),
                activeThumbColor: AppColors.accent,
              ),
            ).animate().fade(delay: 300.ms, duration: 300.ms),
            const SizedBox(height: 32),

            // About section
            _buildSectionHeader(context, 'About'),
            const SizedBox(height: 12),
            _buildSettingTile(
              context: context,
              icon: Icons.info_outline_rounded,
              title: 'DocScan AI',
              subtitle: 'Version 1.0.0',
              trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary),
            ).animate().fade(delay: 400.ms, duration: 300.ms),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title.toUpperCase(),
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: AppColors.accent,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.5,
          ),
    );
  }

  Widget _buildSettingTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.accent, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.textTertiary,
                      ),
                ),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}
