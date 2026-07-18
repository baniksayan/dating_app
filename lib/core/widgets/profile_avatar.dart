import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../extensions/build_context_ext.dart';
import 'badges.dart';
import 'app_network_image.dart';
import 'skeleton_loader.dart';

class ProfileAvatar extends StatelessWidget {
  final String? imageUrl;
  final String? seed;
  final double radius;
  final bool isVerified;
  final bool isPremium;
  final bool isOnline;
  final Border? border;

  const ProfileAvatar({
    super.key,
    this.imageUrl,
    this.seed,
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

    final String placeholderUrl =
        'https://api.dicebear.com/10.x/lorelei/svg?seed=${Uri.encodeComponent(seed ?? "default")}';

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
                    errorWidget: _buildSvgPlaceholder(placeholderUrl, diameter),
                  )
                : _buildSvgPlaceholder(placeholderUrl, diameter),
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

  Widget _buildSvgPlaceholder(String url, double diameter) {
    if (Platform.environment.containsKey('FLUTTER_TEST')) {
      return Container(
        color: const Color(0xFF222222),
        alignment: Alignment.center,
        child: Icon(
          const IconData(0xe4e2, fontFamily: 'MaterialIcons'),
          color: const Color(0x66FFFFFF),
          size: radius * 0.8,
        ),
      );
    }
    return SvgPicture.network(
      url,
      width: diameter,
      height: diameter,
      fit: BoxFit.cover,
      placeholderBuilder: (BuildContext context) => SkeletonLoader(
        width: diameter,
        height: diameter,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
