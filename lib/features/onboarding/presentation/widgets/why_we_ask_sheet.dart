import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../../../core/extensions/build_context_ext.dart';

class WhyWeAskSheet extends StatelessWidget {
  final String title;
  final String explanation;

  const WhyWeAskSheet({
    super.key,
    required this.title,
    required this.explanation,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        border: Border(
          top: BorderSide(
            color: context.colors.divider,
            width: 1.0,
          ),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          Row(
            children: [
              Icon(
                CupertinoIcons.info_circle_fill,
                color: context.colors.accent,
                size: 24,
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: context.typography.headline.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            explanation,
            style: context.typography.body.copyWith(
              color: context.colors.textSecondary,
              height: 1.5,
              fontSize: 14.5,
            ),
          ),
          const SizedBox(height: 32),
          
          // Action Button
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: double.infinity,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0x1FBAA090), // Translucent accent tint
                borderRadius: context.radius.borderPill,
                border: Border.all(
                  color: context.colors.accent.withValues(alpha: 0.2),
                  width: 0.8,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                'Got it',
                style: context.typography.button.copyWith(
                  color: context.colors.accent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
