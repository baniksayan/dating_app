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

    return LayoutBuilder(
      builder: (context, parentConstraints) {
        // Resolve finite width and height based on constraints
        final double resolvedWidth = width ?? 
            (parentConstraints.hasBoundedWidth ? parentConstraints.maxWidth : double.infinity);
        final double resolvedHeight = height ?? 
            (parentConstraints.hasBoundedHeight ? parentConstraints.maxHeight : double.infinity);

        // For the loader shimmer, we need strictly finite dimensions. 
        // If the parent constraints are also infinite, we fallback to a safe baseline size (e.g., 200).
        final double loaderWidth = resolvedWidth.isInfinite ? 200.0 : resolvedWidth;
        final double loaderHeight = resolvedHeight.isInfinite ? 200.0 : resolvedHeight;

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
                  width: loaderWidth,
                  height: loaderHeight,
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
                width: loaderWidth,
                height: loaderHeight,
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
      },
    );
  }
}
