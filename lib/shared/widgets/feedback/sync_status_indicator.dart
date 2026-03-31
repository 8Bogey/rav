/**
 * Sync Status Indicator Widget
 * 
 * Displays current sync status with visual indicators.
 * Shows connectivity, pending sync count, and sync progress.
 */

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/sync/network_status_provider.dart';

/// Sync status indicator widget
class SyncStatusIndicator extends ConsumerWidget {
  final bool showLabel;
  final bool compact;
  final VoidCallback? onTap;

  const SyncStatusIndicator({
    super.key,
    this.showLabel = true,
    this.compact = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final networkStatus = ref.watch(networkStatusProvider);
    
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 8 : 12,
          vertical: compact ? 4 : 8,
        ),
        decoration: BoxDecoration(
          color: _getBackgroundColor(networkStatus),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _getBorderColor(networkStatus),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStatusIcon(networkStatus),
            if (showLabel) ...[
              const SizedBox(width: 8),
              _buildStatusText(networkStatus),
            ],
            if (networkStatus.hasPendingSync && !compact) ...[
              const SizedBox(width: 8),
              _buildPendingBadge(networkStatus.pendingOutboxCount),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIcon(NetworkStatus status) {
    switch (status.connectivity) {
      case ConnectivityState.online:
        if (status.syncStatus == SyncStatusState.syncing) {
          return const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.statusActive),
            ),
          );
        }
        return const Icon(
          Icons.cloud_done,
          size: 16,
          color: AppColors.statusActive,
        );
      case ConnectivityState.offline:
        return const Icon(
          Icons.cloud_off,
          size: 16,
          color: AppColors.textMuted,
        );
      case ConnectivityState.unknown:
        return const Icon(
          Icons.cloud_queue,
          size: 16,
          color: AppColors.textMuted,
        );
    }
  }

  Widget _buildStatusText(NetworkStatus status) {
    String text;
    Color color;

    switch (status.connectivity) {
      case ConnectivityState.online:
        switch (status.syncStatus) {
          case SyncStatusState.syncing:
            text = 'جاري المزامنة...';
            color = AppColors.statusInfo;
            break;
          case SyncStatusState.completed:
            text = 'تمت المزامنة';
            color = AppColors.statusActive;
            break;
          case SyncStatusState.error:
            text = 'خطأ في المزامنة';
            color = AppColors.statusDanger;
            break;
          case SyncStatusState.idle:
            if (status.hasPendingSync) {
              text = '${status.pendingOutboxCount} في الانتظار';
              color = AppColors.statusWarning;
            } else {
              text = 'متصل';
              color = AppColors.statusActive;
            }
            break;
        }
        break;
      case ConnectivityState.offline:
        text = 'غير متصل';
        color = AppColors.textMuted;
        break;
      case ConnectivityState.unknown:
        text = 'جاري التحقق...';
        color = AppColors.textMuted;
        break;
    }

    return Text(
      text,
      style: AppTypography.labelMd.copyWith(color: color),
    );
  }

  Widget _buildPendingBadge(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.statusWarning.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        count.toString(),
        style: AppTypography.labelSm.copyWith(
          color: AppColors.statusWarning,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _getBackgroundColor(NetworkStatus status) {
    switch (status.connectivity) {
      case ConnectivityState.online:
        return AppColors.statusActive.withOpacity(0.1);
      case ConnectivityState.offline:
        return AppColors.bgSurfaceAlt;
      case ConnectivityState.unknown:
        return AppColors.bgSurface;
    }
  }

  Color _getBorderColor(NetworkStatus status) {
    switch (status.connectivity) {
      case ConnectivityState.online:
        return AppColors.statusActive.withOpacity(0.3);
      case ConnectivityState.offline:
        return AppColors.borderMid;
      case ConnectivityState.unknown:
        return AppColors.borderMid;
    }
  }
}

/// A larger sync status banner for dashboard or settings
class SyncStatusBanner extends ConsumerWidget {
  final bool showDetailedInfo;

  const SyncStatusBanner({
    super.key,
    this.showDetailedInfo = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final networkStatus = ref.watch(networkStatusProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _getBackgroundColor(networkStatus),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getBorderColor(networkStatus),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildStatusIcon(networkStatus),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatusText(networkStatus),
              ),
              if (networkStatus.isOnline && networkStatus.hasPendingSync)
                TextButton.icon(
                  onPressed: () {
                    ref.read(networkStatusProvider.notifier).forceSyncNow();
                  },
                  icon: const Icon(Icons.sync, size: 18),
                  label: const Text('مزامنة الآن'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.gold,
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
            ],
          ),
          if (showDetailedInfo && networkStatus.lastSyncTime != null) ...[
            const SizedBox(height: 8),
            Text(
              'آخر مزامنة: ${_formatLastSync(networkStatus.lastSyncTime!)}',
              style: AppTypography.bodySm.copyWith(
                color: AppColors.textMuted,
              ),
            ),
          ],
          if (networkStatus.lastError != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.statusDanger.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 16,
                    color: AppColors.statusDanger,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      networkStatus.lastError!,
                      style: AppTypography.bodySm.copyWith(
                        color: AppColors.statusDanger,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusIcon(NetworkStatus status) {
    switch (status.connectivity) {
      case ConnectivityState.online:
        if (status.syncStatus == SyncStatusState.syncing) {
          return const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.statusInfo),
            ),
          );
        }
        return const Icon(
          Icons.cloud_done,
          size: 24,
          color: AppColors.statusActive,
        );
      case ConnectivityState.offline:
        return const Icon(
          Icons.cloud_off,
          size: 24,
          color: AppColors.textMuted,
        );
      case ConnectivityState.unknown:
        return const Icon(
          Icons.cloud_queue,
          size: 24,
          color: AppColors.textMuted,
        );
    }
  }

  Widget _buildStatusText(NetworkStatus status) {
    String text;
    Color color;

    switch (status.connectivity) {
      case ConnectivityState.online:
        switch (status.syncStatus) {
          case SyncStatusState.syncing:
            text = 'جاري المزامنة...';
            color = AppColors.statusInfo;
            break;
          case SyncStatusState.completed:
            text = 'تم المزامنة بنجاح';
            color = AppColors.statusActive;
            break;
          case SyncStatusState.error:
            text = 'فشلت المزامنة';
            color = AppColors.statusDanger;
            break;
          case SyncStatusState.idle:
            if (status.hasPendingSync) {
              text = '${status.pendingOutboxCount} عناصر في انتظار المزامنة';
              color = AppColors.statusWarning;
            } else {
              text = 'جميع البيانات مزامنة';
              color = AppColors.statusActive;
            }
            break;
        }
        break;
      case ConnectivityState.offline:
        text = 'أنت غير متصل بالإنترنت';
        color = AppColors.textMuted;
        break;
      case ConnectivityState.unknown:
        text = 'التحقق من حالة الاتصال...';
        color = AppColors.textMuted;
        break;
    }

    return Text(
      text,
      style: AppTypography.bodyMd.copyWith(
        color: color,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Color _getBackgroundColor(NetworkStatus status) {
    switch (status.connectivity) {
      case ConnectivityState.online:
        return AppColors.statusActive.withOpacity(0.05);
      case ConnectivityState.offline:
        return AppColors.bgSurfaceAlt;
      case ConnectivityState.unknown:
        return AppColors.bgSurface;
    }
  }

  Color _getBorderColor(NetworkStatus status) {
    switch (status.connectivity) {
      case ConnectivityState.online:
        return AppColors.statusActive.withOpacity(0.2);
      case ConnectivityState.offline:
        return AppColors.borderMid;
      case ConnectivityState.unknown:
        return AppColors.borderMid;
    }
  }

  String _formatLastSync(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) {
      return 'الآن';
    } else if (diff.inHours < 1) {
      return 'منذ ${diff.inMinutes} دقيقة';
    } else if (diff.inDays < 1) {
      return 'منذ ${diff.inHours} ساعة';
    } else {
      return 'منذ ${diff.inDays} أيام';
    }
  }
}