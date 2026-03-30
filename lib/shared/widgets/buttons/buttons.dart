import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

/// Primary button with gold background (CTA)
class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool enabled;
  final IconData? icon;
  final double? width;
  final double height;
  final bool isDarkMode;

  const PrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.enabled = true,
    this.icon,
    this.width,
    this.height = 48,
    this.isDarkMode = false,
  });

  bool get _isEnabled => enabled && !isLoading && onPressed != null;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: _isEnabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.gold,
          foregroundColor: AppColors.textOnGold,
          disabledBackgroundColor:
              isDarkMode ? AppColors.darkBorder : AppColors.borderLight,
          disabledForegroundColor:
              isDarkMode ? AppColors.darkTextMuted : AppColors.textMuted,
          elevation: _isEnabled ? 2 : 0,
          shadowColor: AppColors.gold.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
        child: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(
                    _isEnabled ? AppColors.textOnGold : AppColors.textMuted,
                  ),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 18),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    text,
                    style: AppTypography.labelLg.copyWith(
                      color: _isEnabled
                          ? AppColors.textOnGold
                          : (isDarkMode
                              ? AppColors.darkTextMuted
                              : AppColors.textMuted),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// Secondary button with outlined border
class SecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool enabled;
  final IconData? icon;
  final double? width;
  final double height;
  final bool isDarkMode;
  final Color? borderColor;
  final Color? textColor;

  const SecondaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.enabled = true,
    this.icon,
    this.width,
    this.height = 48,
    this.isDarkMode = false,
    this.borderColor,
    this.textColor,
  });

  bool get _isEnabled => enabled && !isLoading && onPressed != null;

  Color get _borderColor =>
      borderColor ??
      (isDarkMode ? AppColors.darkBorder : AppColors.borderLight);

  Color get _textColor =>
      textColor ?? (isDarkMode ? AppColors.darkTextBody : AppColors.textBody);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: OutlinedButton(
        onPressed: _isEnabled ? onPressed : null,
        style: OutlinedButton.styleFrom(
          foregroundColor: _textColor,
          disabledForegroundColor:
              isDarkMode ? AppColors.darkTextMuted : AppColors.textMuted,
          side: BorderSide(
            color: _isEnabled
                ? _borderColor
                : (isDarkMode ? AppColors.darkBorder : AppColors.borderLight),
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
        child: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(
                    isDarkMode ? AppColors.darkTextMuted : AppColors.textMuted,
                  ),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 18),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    text,
                    style: AppTypography.labelLg,
                  ),
                ],
              ),
      ),
    );
  }
}

/// Ghost button (text-only, no border)
class GhostButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool enabled;
  final IconData? icon;
  final double? width;
  final double height;
  final bool isDarkMode;
  final Color? textColor;

  const GhostButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.enabled = true,
    this.icon,
    this.width,
    this.height = 48,
    this.isDarkMode = false,
    this.textColor,
  });

  bool get _isEnabled => enabled && !isLoading && onPressed != null;

  Color get _textColor =>
      textColor ?? (isDarkMode ? AppColors.darkTextBody : AppColors.textBody);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: TextButton(
        onPressed: _isEnabled ? onPressed : null,
        style: TextButton.styleFrom(
          foregroundColor: _textColor,
          disabledForegroundColor:
              isDarkMode ? AppColors.darkTextMuted : AppColors.textMuted,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        child: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(
                    isDarkMode ? AppColors.darkTextMuted : AppColors.textMuted,
                  ),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 18),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    text,
                    style: AppTypography.labelLg,
                  ),
                ],
              ),
      ),
    );
  }
}

/// Danger button for destructive actions
class DangerButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool enabled;
  final IconData? icon;
  final double? width;
  final double height;
  final bool isDarkMode;

  const DangerButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.enabled = true,
    this.icon,
    this.width,
    this.height = 48,
    this.isDarkMode = false,
  });

  bool get _isEnabled => enabled && !isLoading && onPressed != null;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: _isEnabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.statusDanger,
          foregroundColor: Colors.white,
          disabledBackgroundColor:
              isDarkMode ? AppColors.darkBorder : AppColors.borderLight,
          disabledForegroundColor:
              isDarkMode ? AppColors.darkTextMuted : AppColors.textMuted,
          elevation: _isEnabled ? 2 : 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
        child: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(
                    _isEnabled ? Colors.white : AppColors.textMuted,
                  ),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 18),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    text,
                    style: AppTypography.labelLg.copyWith(
                      color: _isEnabled
                          ? Colors.white
                          : (isDarkMode
                              ? AppColors.darkTextMuted
                              : AppColors.textMuted),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// Icon button with optional label
class AppIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final Color? backgroundColor;
  final Color? iconColor;
  final double size;
  final double iconSize;
  final bool isDarkMode;
  final String? label;

  const AppIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.tooltip,
    this.backgroundColor,
    this.iconColor,
    this.size = 40,
    this.iconSize = 20,
    this.isDarkMode = false,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ??
        (isDarkMode ? AppColors.darkBgSurface : AppColors.bgSurface);
    final fgColor =
        iconColor ?? (isDarkMode ? AppColors.darkTextBody : AppColors.textBody);

    Widget button = Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(size / 2),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(size / 2),
        child: Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          child: Icon(icon, color: fgColor, size: iconSize),
        ),
      ),
    );

    if (label != null) {
      button = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          button,
          const SizedBox(width: 8),
          Text(
            label!,
            style: AppTypography.labelMd.copyWith(color: fgColor),
          ),
        ],
      );
    }

    if (tooltip != null) {
      return Tooltip(message: tooltip!, child: button);
    }

    return button;
  }
}
