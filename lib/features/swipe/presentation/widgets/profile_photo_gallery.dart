import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart' show Colors; // Color opacity helpers
import '../../../../core/extensions/build_context_ext.dart';
import '../../../../core/theme/app_design_system.dart';
import '../../../../core/widgets/app_network_image.dart';

class ProfilePhotoGallery extends StatefulWidget {
  final List<String> photos;

  const ProfilePhotoGallery({
    super.key,
    required this.photos,
  });

  @override
  State<ProfilePhotoGallery> createState() => _ProfilePhotoGalleryState();
}

class _ProfilePhotoGalleryState extends State<ProfilePhotoGallery> {
  int _activeIndex = 0;

  void _nextPhoto() {
    if (_activeIndex < widget.photos.length - 1) {
      setState(() {
        _activeIndex++;
      });
    }
  }

  void _prevPhoto() {
    if (_activeIndex > 0) {
      setState(() {
        _activeIndex--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.photos.isEmpty) {
      return Container(
        color: context.colors.card,
        child: Center(
          child: Icon(
            AppIcons.profile,
            color: context.colors.textSecondary,
            size: 48,
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;

        return Stack(
          children: [
            // 1. Full-screen Photo Hero
            Positioned.fill(
              child: AppNetworkImage(
                imageUrl: widget.photos[_activeIndex],
                fit: BoxFit.cover,
              ),
            ),

            // 2. Left / Right Tap Controls
            Positioned.fill(
              child: GestureDetector(
                onTapUp: (details) {
                  final dx = details.localPosition.dx;
                  if (dx < width / 3) {
                    _prevPhoto();
                  } else {
                    _nextPhoto();
                  }
                },
                behavior: HitTestBehavior.opaque,
                child: const SizedBox.expand(),
              ),
            ),

            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 60,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0x99000000), // Semi-transparent black
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // 4. Photo Indicators (Dashes like Instagram Stories)
            if (widget.photos.length > 1)
              Positioned(
                top: 12,
                left: 16,
                right: 16,
                child: Row(
                  children: List.generate(
                    widget.photos.length,
                    (index) => Expanded(
                      child: Container(
                        height: 3,
                        margin: const EdgeInsets.symmetric(horizontal: 2.0),
                        decoration: BoxDecoration(
                          color: index == _activeIndex
                              ? context.colors.primary
                              : Colors.white.withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(1.5),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
