import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../../../core/extensions/build_context_ext.dart';
import '../../../../core/theme/app_design_system.dart';
import '../../../../core/widgets/glass_card.dart';

class OnboardingPhotoTipsModal extends StatelessWidget {
  const OnboardingPhotoTipsModal({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: GlassCard(
        blurAmount: AppBlur.heavy,
        borderRadius: BorderRadius.circular(24),
        backgroundColor: const Color(0xEB131110), // Elevated near black surface
        border: Border.all(
          color: context.colors.divider,
          width: 1.0,
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Photo Tips',
                  style: context.typography.headline.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(
                    CupertinoIcons.clear_circled_solid,
                    color: Colors.white60,
                    size: 24,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            _buildTipRow(
              context,
              icon: CupertinoIcons.sparkles,
              title: 'Choose a clear main photo',
              body: 'Make sure your face is clearly visible, well-lit, and doesn\'t include sunglasses or large groups.',
            ),
            const SizedBox(height: 20),
            
            _buildTipRow(
              context,
              icon: CupertinoIcons.scope,
              title: 'Show off your interests',
              body: 'Include dynamic photos of you traveling, engaging in hobbies, or in your favorite settings to spark conversations.',
            ),
            const SizedBox(height: 20),
            
            _buildTipRow(
              context,
              icon: CupertinoIcons.checkmark_seal,
              title: 'Keep it recent and authentic',
              body: 'Upload recent photos that reflect your current look and genuine smile. Authenticity is extremely attractive.',
            ),
            const SizedBox(height: 32),
            
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  gradient: AppGradients.luxury,
                  borderRadius: context.radius.borderPill,
                ),
                alignment: Alignment.center,
                child: Text(
                  'Understood',
                  style: context.typography.button.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipRow(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String body,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: context.colors.surface,
            border: Border.all(color: context.colors.divider, width: 0.8),
          ),
          alignment: Alignment.center,
          child: Icon(icon, color: context.colors.accent, size: 18),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: context.typography.title.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 14.5,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                body,
                style: context.typography.caption.copyWith(
                  color: context.colors.textSecondary,
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
