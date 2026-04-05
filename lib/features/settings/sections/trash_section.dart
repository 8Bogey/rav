import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mawlid_al_dhaki/core/database/app_database.dart';
import 'package:mawlid_al_dhaki/core/database/database_provider.dart';
import 'package:mawlid_al_dhaki/core/services/trash_service.dart';
import 'package:mawlid_al_dhaki/core/theme/app_colors.dart';
import 'package:mawlid_al_dhaki/core/theme/app_typography.dart';

class TrashSection extends ConsumerWidget {
  const TrashSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final database = ref.watch(databaseProvider);
    final trashService = TrashService(database);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'سلة المحذوفات',
              style: AppTypography.h2.copyWith(
                color:
                    isDarkMode ? AppColors.darkTextHead : AppColors.textHeading,
              ),
            ),
            OutlinedButton.icon(
              onPressed: () => _showEmptyTrashConfirm(context, trashService),
              icon:
                  const Icon(Icons.delete_sweep, color: AppColors.statusDanger),
              label: const Text('إفراغ السلة'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.statusDanger,
                side: const BorderSide(color: AppColors.statusDanger),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'العناصر المحذوفة تبقى في السلة لمدة 30 يوماً قبل حذفها نهائياً',
          style: AppTypography.bodySm.copyWith(
            color: isDarkMode ? AppColors.darkTextMuted : AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 24),
        StreamBuilder<List<TrashItem>>(
          stream: trashService.watchTrashItems(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(
                child: Text('خطأ: ${snapshot.error}',
                    style: AppTypography.bodyMd.copyWith(
                      color: AppColors.statusDanger,
                    )),
              );
            }
            final items = snapshot.data ?? [];
            if (items.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.delete_outline,
                        size: 64,
                        color: isDarkMode
                            ? AppColors.darkTextMuted
                            : AppColors.textMuted),
                    const SizedBox(height: 16),
                    Text(
                      'سلة المحذوفات فارغة',
                      style: AppTypography.h3.copyWith(
                        color: isDarkMode
                            ? AppColors.darkTextMuted
                            : AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              );
            }
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final entityData = _parseEntityData(item.entityData);
                final name = entityData['name'] ?? item.entityId;
                final daysLeft = _daysUntilExpiry(item.expiresAt);

                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.statusWarning.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(_getEntityTypeIcon(item.entityType),
                          color: AppColors.statusWarning),
                    ),
                    title: Text(name, style: AppTypography.bodyMd),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('نوع: ${_getEntityTypeName(item.entityType)}'),
                        Text('محذوف منذ: ${_formatDate(item.deletedAt)}'),
                        Text('يُحذف نهائياً بعد: $daysLeft يوم'),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.restore,
                              color: AppColors.statusActive),
                          tooltip: 'استعادة',
                          onPressed: () =>
                              _restoreItem(context, trashService, item.id),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_forever,
                              color: AppColors.statusDanger),
                          tooltip: 'حذف نهائي',
                          onPressed: () => _showPermanentDeleteConfirm(
                              context, trashService, item.id),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Map<String, dynamic> _parseEntityData(String jsonStr) {
    try {
      return Map<String, dynamic>.from(
          (jsonDecode(jsonStr) as Map<String, dynamic>));
    } catch (e) {
      return {};
    }
  }

  IconData _getEntityTypeIcon(String entityType) {
    switch (entityType) {
      case 'subscribers':
        return Icons.person;
      case 'cabinets':
        return Icons.electrical_services;
      case 'payments':
        return Icons.payment;
      case 'workers':
        return Icons.engineering;
      default:
        return Icons.folder;
    }
  }

  String _getEntityTypeName(String entityType) {
    switch (entityType) {
      case 'subscribers':
        return 'مشترك';
      case 'cabinets':
        return 'خزانة';
      case 'payments':
        return 'دفعة';
      case 'workers':
        return 'عامل';
      default:
        return entityType;
    }
  }

  int _daysUntilExpiry(DateTime expiresAt) {
    final now = DateTime.now();
    final diff = expiresAt.difference(now);
    return diff.inDays.clamp(0, 999);
  }

  String _formatDate(DateTime date) {
    return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
  }

  Future<void> _restoreItem(
      BuildContext context, TrashService trashService, String id) async {
    try {
      await trashService.restoreFromTrash(id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم استعادة العنصر بنجاح'),
            backgroundColor: AppColors.statusActive,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل الاستعادة: $e'),
            backgroundColor: AppColors.statusDanger,
          ),
        );
      }
    }
  }

  Future<void> _showPermanentDeleteConfirm(
      BuildContext context, TrashService trashService, String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف النهائي'),
        content: const Text(
            'هل أنت متأكد من حذف هذا العنصر نهائياً؟ لا يمكن التراجع عن هذا الإجراء.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style:
                TextButton.styleFrom(foregroundColor: AppColors.statusDanger),
            child: const Text('حذف نهائي'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      try {
        await trashService.permanentlyDelete(id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم حذف العنصر نهائياً'),
              backgroundColor: AppColors.statusActive,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('فشل الحذف: $e'),
              backgroundColor: AppColors.statusDanger,
            ),
          );
        }
      }
    }
  }

  Future<void> _showEmptyTrashConfirm(
      BuildContext context, TrashService trashService) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد إفراغ السلة'),
        content: const Text(
            'هل أنت متأكد من إفراغ سلة المحذوفات؟ سيتم حذف جميع العناصر نهائياً.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style:
                TextButton.styleFrom(foregroundColor: AppColors.statusDanger),
            child: const Text('إفراغ السلة'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      try {
        await trashService.emptyTrash();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم إفراغ سلة المحذوفات'),
              backgroundColor: AppColors.statusActive,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('فشل إفراغ السلة: $e'),
              backgroundColor: AppColors.statusDanger,
            ),
          );
        }
      }
    }
  }
}
