import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

/// Toast notification types
enum ToastType { success, error, warning, info }

/// A toast notification widget
class AppToast {
  static OverlayEntry? _currentToast;

  static void show(
    BuildContext context, {
    required String message,
    ToastType type = ToastType.info,
    Duration duration = const Duration(seconds: 3),
  }) {
    // Remove any existing toast
    _currentToast?.remove();

    final overlay = Overlay.of(context);
    _currentToast = OverlayEntry(
      builder: (context) => _ToastWidget(
        message: message,
        type: type,
        duration: duration,
        onDismiss: () {
          _currentToast?.remove();
          _currentToast = null;
        },
      ),
    );

    overlay.insert(_currentToast!);
  }

  static void success(BuildContext context, String message) {
    show(context, message: message, type: ToastType.success);
  }

  static void error(BuildContext context, String message) {
    show(context, message: message, type: ToastType.error);
  }

  static void warning(BuildContext context, String message) {
    show(context, message: message, type: ToastType.warning);
  }

  static void info(BuildContext context, String message) {
    show(context, message: message, type: ToastType.info);
  }
}

class _ToastWidget extends StatefulWidget {
  final String message;
  final ToastType type;
  final Duration duration;
  final VoidCallback onDismiss;

  const _ToastWidget({
    required this.message,
    required this.type,
    required this.duration,
    required this.onDismiss,
  });

  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _controller.forward();

    Future.delayed(widget.duration, () {
      if (mounted) {
        _controller.reverse().then((_) => widget.onDismiss());
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color get _backgroundColor {
    switch (widget.type) {
      case ToastType.success:
        return AppColors.statusActiveS;
      case ToastType.error:
        return AppColors.statusDangerS;
      case ToastType.warning:
        return AppColors.statusWarningS;
      case ToastType.info:
        return AppColors.statusInfoS;
    }
  }

  Color get _textColor {
    switch (widget.type) {
      case ToastType.success:
        return AppColors.statusActive;
      case ToastType.error:
        return AppColors.statusDanger;
      case ToastType.warning:
        return AppColors.statusWarning;
      case ToastType.info:
        return AppColors.statusInfo;
    }
  }

  IconData get _icon {
    switch (widget.type) {
      case ToastType.success:
        return Icons.check_circle;
      case ToastType.error:
        return Icons.error;
      case ToastType.warning:
        return Icons.warning;
      case ToastType.info:
        return Icons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 16,
      left: 16,
      right: 16,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: _backgroundColor,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(_icon, color: _textColor, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.message,
                      style: AppTypography.bodyMd.copyWith(color: _textColor),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: _textColor, size: 18),
                    onPressed: () {
                      _controller.reverse().then((_) => widget.onDismiss());
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A confirmation dialog
class ConfirmDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final bool isDanger;
  final bool isDarkMode;

  const ConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmText = 'تأكيد',
    this.cancelText = 'إلغاء',
    this.isDanger = false,
    this.isDarkMode = false,
  });

  static Future<bool?> show(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'تأكيد',
    String cancelText = 'إلغاء',
    bool isDanger = false,
    bool isDarkMode = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => ConfirmDialog(
        title: title,
        message: message,
        confirmText: confirmText,
        cancelText: cancelText,
        isDanger: isDanger,
        isDarkMode: isDarkMode,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = isDarkMode ? AppColors.darkBgSurface : AppColors.bgSurface;
    final textColor =
        isDarkMode ? AppColors.darkTextHead : AppColors.textHeading;
    final bodyColor = isDarkMode ? AppColors.darkTextBody : AppColors.textBody;

    return AlertDialog(
      backgroundColor: bgColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Text(
        title,
        style: AppTypography.h3.copyWith(color: textColor),
      ),
      content: Text(
        message,
        style: AppTypography.bodyMd.copyWith(color: bodyColor),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(
            cancelText,
            style: AppTypography.labelLg.copyWith(
              color:
                  isDarkMode ? AppColors.darkTextBody : AppColors.textSecondary,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: ElevatedButton.styleFrom(
            backgroundColor: isDanger ? AppColors.statusDanger : AppColors.gold,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(confirmText, style: AppTypography.labelLg),
        ),
      ],
    );
  }
}

/// An empty state widget with icon and message
class EmptyState extends StatelessWidget {
  final String message;
  final String? title;
  final IconData icon;
  final String? actionText;
  final VoidCallback? onAction;
  final bool isDarkMode;

  const EmptyState({
    super.key,
    required this.message,
    this.title,
    this.icon = Icons.inbox,
    this.actionText,
    this.onAction,
    this.isDarkMode = false,
  });

  @override
  Widget build(BuildContext context) {
    final textColor =
        isDarkMode ? AppColors.darkTextHead : AppColors.textHeading;
    final bodyColor = isDarkMode ? AppColors.darkTextBody : AppColors.textBody;
    final iconColor =
        isDarkMode ? AppColors.darkTextMuted : AppColors.textMuted;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: (isDarkMode
                  ? AppColors.darkBgSurfaceAlt
                  : AppColors.bgSurfaceAlt),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              icon,
              size: 40,
              color: iconColor,
            ),
          ),
          const SizedBox(height: 16),
          if (title != null) ...[
            Text(
              title!,
              style: AppTypography.h3.copyWith(color: textColor),
            ),
            const SizedBox(height: 8),
          ],
          Text(
            message,
            style: AppTypography.bodyMd.copyWith(color: bodyColor),
            textAlign: TextAlign.center,
          ),
          if (actionText != null && onAction != null) ...[
            const SizedBox(height: 24),
            TextButton.icon(
              onPressed: onAction,
              icon: const Icon(Icons.add, size: 18),
              label: Text(
                actionText!,
                style: AppTypography.labelLg.copyWith(color: AppColors.gold),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// A skeleton loading card
class SkeletonCard extends StatelessWidget {
  final double? width;
  final double height;
  final double borderRadius;
  final bool isDarkMode;

  const SkeletonCard({
    super.key,
    this.width,
    this.height = 120,
    this.borderRadius = 16,
    this.isDarkMode = false,
  });

  @override
  Widget build(BuildContext context) {
    final baseColor =
        isDarkMode ? AppColors.darkBgSurfaceAlt : AppColors.bgSurfaceAlt;
    final highlightColor =
        isDarkMode ? AppColors.darkBgSurface : AppColors.bgSurface;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: baseColor,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: ShimmerLoading(
        baseColor: baseColor,
        highlightColor: highlightColor,
        child: Container(
          decoration: BoxDecoration(
            color: baseColor,
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
      ),
    );
  }
}

/// Shimmer loading effect
class ShimmerLoading extends StatefulWidget {
  final Widget child;
  final Color baseColor;
  final Color highlightColor;

  const ShimmerLoading({
    super.key,
    required this.child,
    required this.baseColor,
    required this.highlightColor,
  });

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                widget.baseColor,
                widget.highlightColor,
                widget.baseColor,
              ],
              stops: const [0.0, 0.5, 1.0],
              transform: _SlideGradientTransform(_animation.value),
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcATop,
          child: widget.child,
        );
      },
      child: widget.child,
    );
  }
}

class _SlideGradientTransform extends GradientTransform {
  final double slidePercent;

  const _SlideGradientTransform(this.slidePercent);

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * slidePercent, 0, 0);
  }
}

/// Confetti overlay for celebrations
class ConfettiOverlay extends StatefulWidget {
  final bool isPlaying;
  final Duration duration;
  final Widget child;

  const ConfettiOverlay({
    super.key,
    required this.isPlaying,
    this.duration = const Duration(seconds: 3),
    required this.child,
  });

  @override
  State<ConfettiOverlay> createState() => _ConfettiOverlayState();
}

class _ConfettiOverlayState extends State<ConfettiOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    if (widget.isPlaying) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(ConfettiOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying && !oldWidget.isPlaying) {
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (widget.isPlaying)
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return CustomPaint(
                    painter: _ConfettiPainter(_controller.value),
                    size: Size.infinite,
                  );
                },
              ),
            ),
          ),
      ],
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  final double progress;
  final List<_ConfettiPiece> _pieces = [];

  _ConfettiPainter(this.progress) {
    if (_pieces.isEmpty) {
      final random = DateTime.now().millisecondsSinceEpoch;
      for (int i = 0; i < 50; i++) {
        _pieces.add(_ConfettiPiece(random + i));
      }
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    for (final piece in _pieces) {
      piece.draw(canvas, size, progress);
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) {
    return progress != oldDelegate.progress;
  }
}

class _ConfettiPiece {
  late final double x;
  late final double rotationSpeed;
  late final double fallSpeed;
  late final double size;
  late final Color color;

  _ConfettiPiece(int seed) {
    final random = _SeededRandom(seed);
    x = random.nextDouble();
    rotationSpeed = random.nextDouble() * 2 - 1;
    fallSpeed = 0.5 + random.nextDouble() * 0.5;
    size = 4 + random.nextDouble() * 4;
    color = [
      AppColors.gold,
      AppColors.primary,
      AppColors.statusActive,
      AppColors.statusInfo,
      AppColors.statusWarning,
    ][random.nextInt(5)];
  }

  void draw(Canvas canvas, Size size, double progress) {
    final yPos = progress * size.height * fallSpeed * 1.5;
    final xPos = x * size.width + (progress * 100 * rotationSpeed);
    final rotation = progress * 3.14159 * 4 * rotationSpeed;

    canvas.save();
    canvas.translate(xPos, yPos);
    canvas.rotate(rotation);

    final paint = Paint()..color = color;
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset.zero,
        width: this.size,
        height: this.size * 0.6,
      ),
      paint,
    );

    canvas.restore();
  }
}

class _SeededRandom {
  final int seed;
  int _current;

  _SeededRandom(this.seed) : _current = seed;

  double nextDouble() {
    _current = (_current * 1103515245 + 12345) & 0x7FFFFFFF;
    return _current / 0x7FFFFFFF;
  }

  int nextInt(int max) => (nextDouble() * max).floor();
}
