import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class GlowingCard extends StatelessWidget {
  final Widget child;
  final Color glowColor;
  final double glowRadius;
  final double borderRadius;
  final EdgeInsets padding;
  final VoidCallback? onTap;

  const GlowingCard({
    super.key,
    required this.child,
    this.glowColor = AppColors.accent,
    this.glowRadius = 20,
    this.borderRadius = 20,
    this.padding = const EdgeInsets.all(24),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: [
            BoxShadow(
              color: glowColor.withValues(alpha: 0.15),
              blurRadius: glowRadius,
              spreadRadius: 2,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: padding,
              decoration: BoxDecoration(
                color: AppColors.glassBg,
                borderRadius: BorderRadius.circular(borderRadius),
                border: Border.all(
                  color: AppColors.glassBorder,
                  width: 1,
                ),
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
