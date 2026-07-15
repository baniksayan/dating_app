// ignore_for_file: deprecated_member_use, unnecessary_underscores, prefer_single_quotes
import 'package:flutter/material.dart';

class ZoomableImageViewer extends StatefulWidget {
  final ImageProvider imageProvider;
  final String? heroTag;
  final Color backgroundColor;
  final bool closeOnSingleTap;
  final bool showCloseButton;

  const ZoomableImageViewer({
    super.key,
    required this.imageProvider,
    this.heroTag,
    this.backgroundColor = Colors.black,
    this.closeOnSingleTap = true,
    this.showCloseButton = true,
  });

  @override
  State<ZoomableImageViewer> createState() => _ZoomableImageViewerState();
}

class _ZoomableImageViewerState extends State<ZoomableImageViewer>
    with TickerProviderStateMixin {
  final String className = "Zoomable Image Viewer Screen";

  // ── Constants ──────────────────────────────────────────────
  static const double _minScale = 1.0;
  static const double _maxScale = 5.0;
  static const double _doubleTapScale = 2.5;
  static const double _zoomThreshold = 1.05;

  // ── Controllers ────────────────────────────────────────────
  final TransformationController _transformController =
      TransformationController();
  late final AnimationController _doubleTapAnimController;
  late final AnimationController _closeButtonAnimController;
  late final AnimationController _dismissSnapController;

  // ── State ──────────────────────────────────────────────────
  bool _isZoomed = false;
  bool _isAnimating = false;
  TapDownDetails? _doubleTapDetails;

  // ── Swipe-to-dismiss ───────────────────────────────────────
  int _activePointers = 0;
  Offset? _pointerStartPos;
  double _dismissDragOffset = 0.0;
  double _dismissOpacity = 1.0;
  bool _trackingDismiss = false;
  double _dismissSnapFrom = 0.0;
  double _dismissOpacitySnapFrom = 1.0;

  // ── Animations ─────────────────────────────────────────────
  Animation<Matrix4>? _doubleTapAnimation;

  @override
  void initState() {
    super.initState();

    _doubleTapAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    )
      ..addListener(_onDoubleTapAnimate)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) _isAnimating = false;
      });

    _closeButtonAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      value: 1.0,
    );

    _dismissSnapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    )..addListener(_onDismissSnap);

    _transformController.addListener(_onTransformChanged);
  }

  @override
  void dispose() {
    _doubleTapAnimController.dispose();
    _closeButtonAnimController.dispose();
    _dismissSnapController.dispose();
    _transformController.dispose();
    super.dispose();
  }

  // ── Scale helper ───────────────────────────────────────────

  double get _currentScale => _transformController.value.getMaxScaleOnAxis();

  // ── Transform change → track zoom state & toggle UI ────────

  void _onTransformChanged() {
    final zoomed = _currentScale > _zoomThreshold;
    if (zoomed != _isZoomed) {
      _isZoomed = zoomed;
      if (zoomed) {
        _closeButtonAnimController.reverse();
      } else {
        _closeButtonAnimController.forward();
      }
    }
  }

  // ── Double-tap zoom to focal point ─────────────────────────

  void _handleDoubleTapDown(TapDownDetails details) {
    _doubleTapDetails = details;
  }

  void _handleDoubleTap() {
    if (_isAnimating) return;
    final details = _doubleTapDetails;
    if (details == null) return;

    final Matrix4 current = _transformController.value.clone();
    final double currentScale = _currentScale;
    Matrix4 target;

    if (currentScale > _zoomThreshold) {
      // ── Zoom out to fit ──
      target = Matrix4.identity();
    } else {
      // ── Zoom into the tapped focal point ──
      final Offset focal = details.localPosition;
      const double scale = _doubleTapScale;
      final double dx = -focal.dx * (scale - 1);
      final double dy = -focal.dy * (scale - 1);
      target = Matrix4.identity()
        ..translate(dx, dy)
        ..scale(scale);
      target = _clampTransform(target, scale);
    }

    _isAnimating = true;
    _doubleTapAnimation = Matrix4Tween(begin: current, end: target).animate(
      CurvedAnimation(
        parent: _doubleTapAnimController,
        curve: Curves.easeOutCubic,
      ),
    );
    _doubleTapAnimController.forward(from: 0.0);
  }

  void _onDoubleTapAnimate() {
    if (_doubleTapAnimation != null) {
      _transformController.value = _doubleTapAnimation!.value;
    }
  }

  Matrix4 _clampTransform(Matrix4 matrix, double scale) {
    final size = context.size;
    if (size == null) return matrix;

    final dx = matrix.storage[12];
    final dy = matrix.storage[13];
    final minDx = size.width * (1 - scale);
    final minDy = size.height * (1 - scale);

    return Matrix4.identity()
      ..translate(dx.clamp(minDx, 0.0), dy.clamp(minDy, 0.0))
      ..scale(scale);
  }

  // ── Swipe-to-dismiss (raw pointer tracking) ────────────────

  void _onPointerDown(PointerDownEvent event) {
    _activePointers++;
    if (_activePointers > 1 && _trackingDismiss) {
      _snapDismissBack();
      _pointerStartPos = null;
      return;
    }
    if (!widget.closeOnSingleTap || _isZoomed || _activePointers > 1) return;
    _pointerStartPos = event.position;
    _trackingDismiss = false;
  }

  void _onPointerMove(PointerMoveEvent event) {
    if (_pointerStartPos == null || _isZoomed || _activePointers != 1) return;

    final delta = event.position - _pointerStartPos!;
    if (!_trackingDismiss &&
        delta.dy.abs() > 12 &&
        delta.dy.abs() > delta.dx.abs() * 1.5) {
      _trackingDismiss = true;
    }

    if (_trackingDismiss) {
      setState(() {
        _dismissDragOffset = delta.dy;
        _dismissOpacity =
            (1.0 - (_dismissDragOffset.abs() / 400)).clamp(0.2, 1.0);
      });
    }
  }

  void _onPointerUp(PointerUpEvent event) {
    _activePointers = (_activePointers - 1).clamp(0, 99);
    if (_trackingDismiss) {
      if (_dismissDragOffset.abs() > 120) {
        Navigator.of(context).maybePop();
      } else {
        _snapDismissBack();
      }
    }
    _pointerStartPos = null;
  }

  void _onPointerCancel(PointerCancelEvent event) {
    _activePointers = (_activePointers - 1).clamp(0, 99);
    if (_trackingDismiss) _snapDismissBack();
    _pointerStartPos = null;
  }

  void _snapDismissBack() {
    _dismissSnapFrom = _dismissDragOffset;
    _dismissOpacitySnapFrom = _dismissOpacity;
    _dismissSnapController.forward(from: 0.0);
  }

  void _onDismissSnap() {
    final t = Curves.easeOutCubic.transform(_dismissSnapController.value);
    setState(() {
      _dismissDragOffset = _dismissSnapFrom * (1 - t);
      _dismissOpacity =
          _dismissOpacitySnapFrom + (1.0 - _dismissOpacitySnapFrom) * t;
    });
    if (_dismissSnapController.isCompleted) {
      _trackingDismiss = false;
    }
  }

  // ── Tap ────────────────────────────────────────────────────

  void _handleTap() {
    if (_isAnimating || _trackingDismiss) return;
    if (widget.closeOnSingleTap && !_isZoomed) {
      Navigator.of(context).maybePop();
    }
  }

  // ── Build ──────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.backgroundColor.withValues(
        alpha: widget.backgroundColor.opacity * _dismissOpacity,
      ),
      body: SafeArea(
        child: Listener(
          onPointerDown: _onPointerDown,
          onPointerMove: _onPointerMove,
          onPointerUp: _onPointerUp,
          onPointerCancel: _onPointerCancel,
          child: Stack(
            children: [
              // ── Image with pinch-zoom, pan, double-tap zoom ──
              Positioned.fill(
                child: Transform.translate(
                  offset: Offset(0, _dismissDragOffset),
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onDoubleTapDown: _handleDoubleTapDown,
                    onDoubleTap: _handleDoubleTap,
                    onTap: _handleTap,
                    child: _buildImageView(),
                  ),
                ),
              ),

              // ── Close button (auto-hides when zoomed) ──
              if (widget.showCloseButton) _buildCloseButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageView() {
    Widget imageView = InteractiveViewer(
      transformationController: _transformController,
      minScale: _minScale,
      maxScale: _maxScale,
      panEnabled: true,
      scaleEnabled: true,
      interactionEndFrictionCoefficient: 0.0000135,
      child: SizedBox.expand(
        child: Image(
          image: widget.imageProvider,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.high,
          errorBuilder: (_, __, ___) => const Center(
            child: Icon(Icons.broken_image, color: Colors.white54, size: 64),
          ),
        ),
      ),
    );

    if (widget.heroTag != null) {
      imageView = Hero(tag: widget.heroTag!, child: imageView);
    }

    return imageView;
  }

  Widget _buildCloseButton() {
    return Positioned(
      top: 16,
      left: 16,
      child: FadeTransition(
        opacity: _closeButtonAnimController,
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).maybePop();
          },
          child: Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.6),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.close,
              color: Colors.white,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }
}

Future<void> openZoomableImage(BuildContext context, ImageProvider provider,
    {String? heroTag,
    bool closeOnSingleTap = true,
    bool showCloseButton = true}) async {
  await Navigator.of(context).push(
    PageRouteBuilder(
      opaque: false,
      barrierColor: Colors.transparent,
      pageBuilder: (_, __, ___) => ZoomableImageViewer(
        imageProvider: provider,
        heroTag: heroTag,
        closeOnSingleTap: closeOnSingleTap,
        showCloseButton: showCloseButton,
      ),
      transitionsBuilder: (_, animation, __, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        return FadeTransition(opacity: curved, child: child);
      },
      transitionDuration: const Duration(milliseconds: 300),
      reverseTransitionDuration: const Duration(milliseconds: 250),
    ),
  );
}
