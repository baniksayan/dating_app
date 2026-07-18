import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/extensions/build_context_ext.dart';
import '../../../../core/theme/app_design_system.dart';
import '../../../../core/widgets/primary_button.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      body: SafeArea(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(flex: 2),

              // DatingApp Logo/Icon Placeholder with Luxury styling
              Hero(
                tag: 'app_logo',
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppGradients.gold,
                    boxShadow: AppShadows.premium,
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    CupertinoIcons.heart_fill,
                    size: 44,
                    color: Colors.black, // Dark contrast on Gold/Beige gradient
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // App Name (spaced beautifully)
              Text(
                'D A T I N G   A P P',
                style: context.typography.headline.copyWith(
                  letterSpacing: 6.0,
                  fontWeight: FontWeight.w800,
                  color: context.colors.textPrimary,
                  fontSize: 24,
                ),
              ),
              const SizedBox(height: 10),

              // Elegant Tagline
              Text(
                'exceptional connections',
                style: context.typography.caption.copyWith(
                  letterSpacing: 2.0,
                  color: context.colors.textSecondary,
                  fontSize: 13,
                ),
              ),

              const Spacer(flex: 3),

              // Primary Actions Column
              Column(
                children: [
                  PrimaryButton(
                    text: 'Create an account',
                    onTap: () {
                      context.push('/auth/email?signup=true');
                    },
                  ),
                  const SizedBox(height: 14),
                  SecondaryButton(
                    text: 'I already have an account',
                    onTap: () {
                      context.push('/auth/email?signup=false');
                    },
                  ),
                ],
              ),

              const SizedBox(height: 36),

              // Bottom Terms & Privacy Policy links
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 4,
                  runSpacing: 4,
                  children: [
                    Text(
                      'By continuing, you agree to our ',
                      style: context.typography.caption.copyWith(
                        color: context.colors.textTertiary,
                        fontSize: 11,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    GestureDetector(
                      onTap: () => _showDialog(context, 'Terms of Service', 'Placeholder for Terms of Service...'),
                      child: Text(
                        'Terms of Service',
                        style: context.typography.caption.copyWith(
                          color: context.colors.accent,
                          decoration: TextDecoration.underline,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    Text(
                      ' and ',
                      style: context.typography.caption.copyWith(
                        color: context.colors.textTertiary,
                        fontSize: 11,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _showDialog(context, 'Privacy Policy', 'Placeholder for Privacy Policy...'),
                      child: Text(
                        'Privacy Policy',
                        style: context.typography.caption.copyWith(
                          color: context.colors.accent,
                          decoration: TextDecoration.underline,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  void _showDialog(BuildContext context, String title, String content) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: Text(title),
        content: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(content),
        ),
        actions: <CupertinoDialogAction>[
          CupertinoDialogAction(
            isDefaultAction: true,
            child: const Text('Close'),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
