import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

/// A card displaying a statistic with icon, value, and label
class StatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color? iconColor;
  final Color? backgroundColor;
  final bool isDarkMode;
  final VoidCallback? onTap;

  const StatCard({
    super.key,
    required this.value,
    required this.label,
    required this.icon,
    this.iconColor,
    this.backgroundColor,
    this.isDarkMode = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ??
        (isDarkMode ? AppColors.darkBgSurface : AppColors.bgSurface);
    final fgColor = iconColor ?? AppColors.gold;

    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: fgColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: fgColor,
                  size: 20,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                value,
                style: AppTypography.statLg.copyWith(
                  color: isDarkMode
                      ? AppColors.darkTextHead
                      : AppColors.textHeading,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: AppTypography.bodyMd.copyWith(
                  color: isDarkMode
                      ? AppColors.darkTextBody
                      : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A squircle-shaped avatar with hash-based color for subscribers
class SubscriberAvatar extends StatelessWidget {
  final String name;
  final double size;
  final String? code;

  const SubscriberAvatar({
    super.key,
    required this.name,
    this.size = 48,
    this.code,
  });

  /// Generate a consistent color based on the name hash
  Color get _avatarColor {
    final hash = name.hashCode;
    final colors = [
      AppColors.primary,
      AppColors.gold,
      AppColors.statusActive,
      AppColors.statusInfo,
      AppColors.statusWarning,
      AppColors.statusOrange,
    ];
    return colors[hash.abs() % colors.length];
  }

  /// Get initials from name
  String get _initials {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: _avatarColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(size * 0.25), // Squircle
        border: Border.all(
          color: _avatarColor.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Center(
        child: Text(
          _initials,
          style: AppTypography.labelLg.copyWith(
            color: _avatarColor,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

/// A pill-shaped status badge with indicator dot
class StatusBadge extends StatelessWidget {
  final String label;
  final StatusType type;
  final bool isDarkMode;
  final double dotSize;

  const StatusBadge({
    super.key,
    required this.label,
    required this.type,
    this.isDarkMode = false,
    this.dotSize = 6,
  });

  Color get _backgroundColor {
    switch (type) {
      case StatusType.active:
        return AppColors.statusActiveS;
      case StatusType.warning:
        return AppColors.statusWarningS;
      case StatusType.danger:
        return AppColors.statusDangerS;
      case StatusType.info:
        return AppColors.statusInfoS;
      case StatusType.neutral:
        return isDarkMode ? AppColors.darkBgSurfaceAlt : AppColors.bgSurfaceAlt;
    }
  }

  Color get _textColor {
    switch (type) {
      case StatusType.active:
        return AppColors.statusActive;
      case StatusType.warning:
        return AppColors.statusWarning;
      case StatusType.danger:
        return AppColors.statusDanger;
      case StatusType.info:
        return AppColors.statusInfo;
      case StatusType.neutral:
        return isDarkMode ? AppColors.darkTextBody : AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: dotSize,
            height: dotSize,
            decoration: BoxDecoration(
              color: _textColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTypography.labelMd.copyWith(
              color: _textColor,
            ),
          ),
        ],
      ),
    );
  }
}

enum StatusType { active, warning, danger, info, neutral }

/// Display multi-month debt with breakdown
class DebtDisplay extends StatelessWidget {
  final Map<String, double> monthlyDebts; // Month name -> amount
  final bool isDarkMode;
  final bool showTotal;

  const DebtDisplay({
    super.key,
    required this.monthlyDebts,
    this.isDarkMode = false,
    this.showTotal = true,
  });

  double get totalDebt =>
      monthlyDebts.values.fold(0, (sum, amount) => sum + amount);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showTotal) ...[
          Text(
            '${totalDebt.toStringAsFixed(0)} IQD',
            style: AppTypography.h4.copyWith(
              color: AppColors.statusDanger,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
        ],
        if (monthlyDebts.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: monthlyDebts.entries.map((entry) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.statusDangerS,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${entry.key}: ${entry.value.toStringAsFixed(0)}',
                  style: AppTypography.bodySm.copyWith(
                    color: AppColors.statusDanger,
                  ),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }
}

/// Progress bar for cabinet capacity
class CabinetProgress extends StatelessWidget {
  final int current;
  final int max;
  final String? label;
  final bool isDarkMode;
  final double height;

  const CabinetProgress({
    super.key,
    required this.current,
    required this.max,
    this.label,
    this.isDarkMode = false,
    this.height = 8,
  });

  double get percentage => max > 0 ? current / max : 0;

  Color get _progressColor {
    if (percentage >= 1.0) return AppColors.statusDanger;
    if (percentage >= 0.8) return AppColors.statusWarning;
    return AppColors.statusActive;
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = isDarkMode ? AppColors.darkBorder : AppColors.borderLight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: AppTypography.bodySm.copyWith(
              color:
                  isDarkMode ? AppColors.darkTextBody : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
        ],
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(height / 2),
                child: LinearProgressIndicator(
                  value: percentage.clamp(0.0, 1.0),
                  backgroundColor: bgColor,
                  valueColor: AlwaysStoppedAnimation(_progressColor),
                  minHeight: height,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '$current/$max',
              style: AppTypography.labelMd.copyWith(
                color: isDarkMode
                    ? AppColors.darkTextBody
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Small dot indicating sync status
class SyncStatusDot extends StatelessWidget {
  final SyncStatus status;
  final double size;
  final String? tooltip;

  const SyncStatusDot({
    super.key,
    required this.status,
    this.size = 8,
    this.tooltip,
  });

  Color get _color {
    switch (status) {
      case SyncStatus.synced:
        return AppColors.statusActive;
      case SyncStatus.syncing:
        return AppColors.statusWarning;
      case SyncStatus.offline:
        return AppColors.textMuted;
      case SyncStatus.error:
        return AppColors.statusDanger;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dot = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: _color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: _color.withOpacity(0.4),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
    );

    if (tooltip != null) {
      return Tooltip(
        message: tooltip!,
        child: dot,
      );
    }

    return dot;
  }
}

enum SyncStatus { synced, syncing, offline, error }
