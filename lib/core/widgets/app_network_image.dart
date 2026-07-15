import 'package:flutter/widgets.dart';
import '../extensions/build_context_ext.dart';
import '../theme/app_design_system.dart';
import 'skeleton_loader.dart';

class AppNetworkImage extends StatelessWidget {
  final String imageUrl;
  final BoxFit fit;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final Widget? errorWidget;

  const AppNetworkImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.borderRadius,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    final activeRadius = borderRadius ?? context.radius.borderMd;

    return ClipRRect(
      borderRadius: activeRadius,
      child: Image.network(
        imageUrl,
        fit: fit,
        width: width,
        height: height,
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          if (wasSynchronouslyLoaded) return child;
          return AnimatedCrossFade(
            firstChild: child,
            secondChild: SkeletonLoader(
              width: width ?? double.infinity,
              height: height ?? double.infinity,
              borderRadius: activeRadius,
            ),
            crossFadeState: frame == null
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: AppDurations.quick,
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return SkeletonLoader(
            width: width ?? double.infinity,
            height: height ?? double.infinity,
            borderRadius: activeRadius,
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return errorWidget ??
              Container(
                width: width,
                height: height,
                color: context.colors.card,
                alignment: Alignment.center,
                child: Icon(
                  AppIcons.profile,
                  color: context.colors.textSecondary,
                  size: width != null ? width! * 0.4 : 32.0,
                ),
              );
        },
      ),
    );
  }
}
