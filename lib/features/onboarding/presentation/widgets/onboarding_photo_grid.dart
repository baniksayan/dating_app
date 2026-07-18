import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/extensions/build_context_ext.dart';
import '../../../../core/theme/app_design_system.dart';
import '../../../../core/theme/app_colors.dart';

class OnboardingPhotoGrid extends StatefulWidget {
  final List<String> photos;
  final Function(String) onPhotoAdded;
  final Function(int) onPhotoRemoved;
  final Function(int, int) onPhotosReordered;

  const OnboardingPhotoGrid({
    super.key,
    required this.photos,
    required this.onPhotoAdded,
    required this.onPhotoRemoved,
    required this.onPhotosReordered,
  });

  @override
  State<OnboardingPhotoGrid> createState() => _OnboardingPhotoGridState();
}

class _OnboardingPhotoGridState extends State<OnboardingPhotoGrid> {
  final ImagePicker _picker = ImagePicker();
  
  // Track mock upload progress for slots: key = imagePath, value = progress (0.0 to 1.0)
  final Map<String, double> _uploadProgress = {};
  final Map<String, Timer?> _uploadTimers = {};

  @override
  void dispose() {
    for (var timer in _uploadTimers.values) {
      timer?.cancel();
    }
    super.dispose();
  }

  void _simulateUpload(String path) {
    if (_uploadProgress.containsKey(path)) return;

    _uploadProgress[path] = 0.0;
    
    // Simulate uploading increments
    Timer.periodic(const Duration(milliseconds: 150), (timer) {
      _uploadTimers[path] = timer;
      if (!mounted) {
        timer.cancel();
        return;
      }
      
      setState(() {
        final current = _uploadProgress[path] ?? 0.0;
        if (current >= 1.0) {
          timer.cancel();
          _uploadProgress[path] = 1.0;
          _uploadTimers.remove(path);
        } else {
          _uploadProgress[path] = current + 0.15;
        }
      });
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? file = await _picker.pickImage(
        source: source,
        maxWidth: 1000,
        maxHeight: 1000,
        imageQuality: 85,
      );

      if (file != null) {
        widget.onPhotoAdded(file.path);
        _simulateUpload(file.path);
      }
    } catch (e) {
      // Handle cancelled or failed action gracefully
    }
  }

  void _showImagePickerOptions(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: const Text('Add Profile Photo'),
        message: const Text('Choose a clear photo showing your face.'),
        actions: <CupertinoActionSheetAction>[
          CupertinoActionSheetAction(
            child: const Text('Take Photo'),
            onPressed: () {
              Navigator.pop(context);
              _pickImage(ImageSource.camera);
            },
          ),
          CupertinoActionSheetAction(
            child: const Text('Choose from Gallery'),
            onPressed: () {
              Navigator.pop(context);
              _pickImage(ImageSource.gallery);
            },
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Cancel'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 6, // 6 fixed slots
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.75, // rectangular cards
      ),
      itemBuilder: (context, index) {
        final bool hasImage = widget.photos.length > index;
        final String imagePath = hasImage ? widget.photos[index] : '';
        final double progress = hasImage ? (_uploadProgress[imagePath] ?? 1.0) : 0.0;
        final bool isUploading = hasImage && progress < 1.0;

        return DragTarget<int>(
          onAcceptWithDetails: (details) {
            widget.onPhotosReordered(details.data, index);
          },
          builder: (context, candidateData, rejectedData) {
            return LongPressDraggable<int>(
              data: index,
              feedback: _buildDraggableFeedback(context, index),
              childWhenDragging: Opacity(
                opacity: 0.3,
                child: _buildPhotoSlot(context, index, hasImage, imagePath, progress, isUploading),
              ),
              maxSimultaneousDrags: hasImage ? 1 : 0,
              child: _buildPhotoSlot(context, index, hasImage, imagePath, progress, isUploading),
            );
          },
        );
      },
    );
  }

  // Draggable visual overlay
  Widget _buildDraggableFeedback(BuildContext context, int index) {
    if (index >= widget.photos.length) return const SizedBox.shrink();
    final path = widget.photos[index];
    return Material(
      color: Colors.transparent,
      child: Container(
        width: 100,
        height: 133,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppShadows.cardFloating,
        ),
        clipBehavior: Clip.antiAlias,
        child: Image.file(
          File(path),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildPhotoSlot(
    BuildContext context,
    int index,
    bool hasImage,
    String imagePath,
    double progress,
    bool isUploading,
  ) {
    final bool isMain = index == 0;

    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: hasImage
            ? Border.all(
                color: isMain ? context.colors.primary : context.colors.divider,
                width: isMain ? 2.0 : 1.0,
              )
            : Border.all(
                color: Colors.white12,
                width: 1.0,
                style: BorderStyle.solid,
              ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (hasImage) ...[
            // Photo view
            Image.file(
              File(imagePath),
              fit: BoxFit.cover,
            ),
            
            // Uploading progress overlay
            if (isUploading)
              Container(
                color: Colors.black54,
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(
                        value: progress,
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                        backgroundColor: Colors.white24,
                        strokeWidth: 3.0,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${(progress * 100).toInt()}%',
                      style: context.typography.caption.copyWith(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

            // Main designation or Order Badge
            Positioned(
              top: 6,
              left: 6,
              child: Container(
                decoration: BoxDecoration(
                  color: isMain ? context.colors.primary : Colors.black87,
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                child: Text(
                  isMain ? 'MAIN' : '#${index + 1}',
                  style: context.typography.caption.copyWith(
                    color: isMain ? Colors.black : Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 8.5,
                  ),
                ),
              ),
            ),

            // Delete button
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  widget.onPhotoRemoved(index);
                },
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(4),
                  child: const Icon(
                    CupertinoIcons.xmark,
                    color: Colors.white70,
                    size: 12,
                  ),
                ),
              ),
            ),
          ] else ...[
            // Empty placeholder slot
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                _showImagePickerOptions(context);
              },
              behavior: HitTestBehavior.opaque,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    CupertinoIcons.camera_fill,
                    color: context.colors.textTertiary,
                    size: 24,
                  ),
                  const SizedBox(height: 6),
                  Icon(
                    CupertinoIcons.plus_circle_fill,
                    color: context.colors.accent,
                    size: 16,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
