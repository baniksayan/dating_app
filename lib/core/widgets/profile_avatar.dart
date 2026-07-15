import 'package:flutter/widgets.dart';
import '../extensions/build_context_ext.dart';
import '../theme/app_design_system.dart';
import 'badges.dart';
import 'app_network_image.dart';

class ProfileAvatar extends StatelessWidget {
  final String? imageUrl;
  final double radius;
  final bool isVerified;
  final bool isPremium;
  final bool isOnline;
  final Border? border;

  const ProfileAvatar({
    super.key,
    this.imageUrl,
    this.radius = 36.0,
    this.isVerified = false,
    this.isPremium = false,
    this.isOnline = false,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final double diameter = radius * 2;
    final activeBorder = border ?? Border.all(
      color: isPremium ? context.colors.accent : context.colors.primary,
      width: 2.0,
    );

    return Stack(
      alignment: Alignment.center,
      children: [
        // Avatar Core Container
        Container(
          width: diameter,
          height: diameter,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: activeBorder,
            color: context.colors.card,
          ),
          child: ClipOval(
            child: imageUrl != null && imageUrl!.isNotEmpty
                ? AppNetworkImage(
                    imageUrl: imageUrl!,
                    width: diameter,
                    height: diameter,
                    borderRadius: BorderRadius.circular(radius),
                    errorWidget: Container(
                      color: context.colors.card,
                      alignment: Alignment.center,
                      child: Icon(
                        AppIcons.profile,
                        color: context.colors.textSecondary,
                        size: radius * 0.8,
                      ),
                    ),
                  )
                : Icon(
                    AppIcons.profile,
                    color: context.colors.textSecondary,
                    size: radius * 0.8,
                  ),
          ),
        ),

        // Verified Badge Overlay
        if (isVerified)
          const Positioned(
            right: 0,
            bottom: 0,
            child: VerifiedBadge(size: 20),
          ),

        // Premium Badge Overlay (If verified is not present or placed differently)
        if (isPremium && !isVerified)
          const Positioned(
            right: 0,
            bottom: 0,
            child: PremiumBadge(size: 20),
          ),

        // Online Dot Indicator
        if (isOnline)
          Positioned(
            left: 2,
            top: 2,
            child: Container(
              width: radius * 0.35,
              height: radius * 0.35,
              decoration: BoxDecoration(
                color: context.colors.success,
                shape: BoxShape.circle,
                border: Border.all(
                  color: context.colors.background,
                  width: 1.5,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
