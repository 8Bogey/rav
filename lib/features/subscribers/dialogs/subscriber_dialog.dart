import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:mawlid_al_dhaki/core/database/app_database.dart';
import 'package:mawlid_al_dhaki/core/database/database_provider.dart';
import 'package:mawlid_al_dhaki/core/theme/app_colors.dart';
import 'package:mawlid_al_dhaki/core/theme/app_typography.dart';
import 'package:mawlid_al_dhaki/features/subscribers/providers/subscribers_provider.dart';
import 'package:mawlid_al_dhaki/core/services/audit_service.dart';

/// Add/Edit Subscriber Dialog
class SubscriberDialog extends ConsumerStatefulWidget {
  final Subscriber? subscriber; // null for add, non-null for edit

  const SubscriberDialog({
    super.key,
    this.subscriber,
  });

  @override
  ConsumerState<SubscriberDialog> createState() => _SubscriberDialogState();
}

class _SubscriberDialogState extends ConsumerState<SubscriberDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cabinetController = TextEditingController();
  final _notesController = TextEditingController();

  int _status = 1; // Default: active
  DateTime _startDate = DateTime.now();
  double _accumulatedDebt = 0;
  bool _isLoading = false;

  bool get isEditing => widget.subscriber != null;

  @override
  void initState() {
    super.initState();
    if (widget.subscriber != null) {
      _nameController.text = widget.subscriber!.name;
      _codeController.text = widget.subscriber!.code;
      _phoneController.text = widget.subscriber!.phone;
      _cabinetController.text = widget.subscriber!.cabinet;
      _notesController.text = widget.subscriber!.notes ?? '';
      _status = widget.subscriber!.status;
      _startDate = widget.subscriber!.startDate;
      _accumulatedDebt = widget.subscriber!.accumulatedDebt;
    }

    // Set up listeners for auto-sync between code and cabinet
    _codeController.addListener(_onCodeChanged);
    _cabinetController.addListener(_onCabinetChanged);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _phoneController.dispose();
    _cabinetController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  /// When code (رقم الجوزة) changes, auto-update cabinet based on the letter
  void _onCodeChanged() {
    final code = _codeController.text.trim().toUpperCase();
    if (code.isEmpty) return;

    // Extract the letter (first character that is a letter)
    final letterMatch = RegExp(r'^([A-Za-z]+)').firstMatch(code);
    if (letterMatch != null) {
      final letter = letterMatch.group(1)!.toUpperCase();
      // Only update if different
      if (_cabinetController.text.toUpperCase() != letter) {
        _cabinetController.text = letter;
      }
    }
  }

  /// When cabinet changes, auto-update code prefix to match
  void _onCabinetChanged() {
    final cabinet = _cabinetController.text.trim().toUpperCase();
    final code = _codeController.text.trim();

    if (cabinet.isEmpty) return;

    // If code is empty or doesn't start with the cabinet letter, update it
    if (code.isEmpty) {
      _codeController.text = '$cabinet';
    } else {
      // Check if first character is a letter
      final letterMatch =
          RegExp(r'^([A-Za-z]+)').firstMatch(code.toUpperCase());
      if (letterMatch != null) {
        // Replace the letter prefix with the cabinet letter
        final numberPart = code.substring(letterMatch.group(1)!.length);
        final newCode = '$cabinet$numberPart';
        if (newCode != code) {
          _codeController.text = newCode;
        }
      } else {
        // No letter prefix, prepend cabinet letter
        _codeController.text = '$cabinet$code';
      }
    }
  }

  Future<void> _saveSubscriber() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      if (isEditing) {
        // Update existing subscriber
        final notes = _notesController.text.trim();
        final updatedSubscriber = widget.subscriber!.copyWith(
          name: _nameController.text.trim(),
          code: _codeController.text.trim(),
          phone: _phoneController.text.trim(),
          cabinet: _cabinetController.text.trim(),
          status: _status,
          startDate: _startDate,
          notes: Value(notes.isEmpty ? null : notes),
        );

        await ref
            .read(subscribersProvider.notifier)
            .updateSubscriber(updatedSubscriber);

        // Log audit
        await ref.read(auditServiceProvider).logUpdate(
              'مشترك',
              _nameController.text.trim(),
            );
      } else {
        // Add new subscriber
        await ref.read(subscribersProvider.notifier).addSubscriber(
              name: _nameController.text.trim(),
              code: _codeController.text.trim(),
              phone: _phoneController.text.trim(),
              cabinet: _cabinetController.text.trim(),
              status: _status,
              startDate: _startDate,
              accumulatedDebt: _accumulatedDebt,
              notes: _notesController.text.trim().isEmpty
                  ? null
                  : _notesController.text.trim(),
            );

        // Log audit
        await ref.read(auditServiceProvider).logCreate(
              'مشترك',
              _nameController.text.trim(),
            );
      }

      setState(() => _isLoading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEditing
                ? 'تم تحديث المشترك بنجاح'
                : 'تم إضافة المشترك بنجاح'),
            backgroundColor: AppColors.statusActive,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل حفظ المشترك: $e'),
            backgroundColor: AppColors.statusDanger,
          ),
        );
      }
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              surface: AppColors.bgSurface,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _startDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 560,
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDarkMode ? AppColors.darkBgSurface : AppColors.bgSurface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isEditing ? 'تعديل المشترك' : 'إضافة مشترك جديد',
                      style: AppTypography.h2.copyWith(
                        color: isDarkMode
                            ? AppColors.darkTextHead
                            : AppColors.textHeading,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      icon: Icon(
                        Icons.close,
                        color: isDarkMode
                            ? AppColors.darkTextBody
                            : AppColors.textBody,
                      ),
                    ),
                  ],
                ).animate().fadeIn(duration: 200.ms),

                const SizedBox(height: 24),

                // Form content
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Name field
                        _buildTextField(
                          label: 'اسم المشترك',
                          controller: _nameController,
                          hint: 'أدخل اسم المشترك',
                          icon: Icons.person,
                          isDarkMode: isDarkMode,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'يرجى إدخال اسم المشترك';
                            }
                            return null;
                          },
                        ).animate().fadeIn(duration: 300.ms, delay: 100.ms),

                        const SizedBox(height: 16),

                        // Code and Cabinet row
                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField(
                                label: 'رقم الجوزة',
                                controller: _codeController,
                                hint: 'A1',
                                icon: Icons.qr_code,
                                isDarkMode: isDarkMode,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'يرجى إدخال رقم الجوزة';
                                  }
                                  // Check that the letter matches the cabinet
                                  final code = value.trim().toUpperCase();
                                  final cabinet = _cabinetController.text
                                      .trim()
                                      .toUpperCase();
                                  final letterMatch =
                                      RegExp(r'^([A-Za-z]+)').firstMatch(code);
                                  if (letterMatch != null &&
                                      cabinet.isNotEmpty) {
                                    final codeLetter =
                                        letterMatch.group(1)!.toUpperCase();
                                    if (codeLetter != cabinet) {
                                      return 'حرف الجوزة يجب أن يكون نفس حرف الكابينة ($cabinet)';
                                    }
                                  }
                                  return null;
                                },
                              )
                                  .animate()
                                  .fadeIn(duration: 300.ms, delay: 200.ms),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildTextField(
                                label: 'الكابينة',
                                controller: _cabinetController,
                                hint: 'A',
                                icon: Icons.electrical_services,
                                isDarkMode: isDarkMode,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'يرجى إدخال الكابينة';
                                  }
                                  return null;
                                },
                              )
                                  .animate()
                                  .fadeIn(duration: 300.ms, delay: 250.ms),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Phone field
                        _buildTextField(
                          label: 'رقم الهاتف',
                          controller: _phoneController,
                          hint: '07701234567',
                          icon: Icons.phone,
                          isDarkMode: isDarkMode,
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'يرجى إدخال رقم الهاتف';
                            }
                            return null;
                          },
                        ).animate().fadeIn(duration: 300.ms, delay: 300.ms),

                        const SizedBox(height: 16),

                        // Status dropdown
                        _buildDropdown(
                          label: 'الحالة',
                          value: _status,
                          items: const [
                            DropdownMenuItem(value: 0, child: Text('غير نشط')),
                            DropdownMenuItem(value: 1, child: Text('نشط')),
                            DropdownMenuItem(value: 2, child: Text('موقوف')),
                            DropdownMenuItem(value: 3, child: Text('مقطوع')),
                          ],
                          onChanged: (value) {
                            setState(() => _status = value ?? 1);
                          },
                          isDarkMode: isDarkMode,
                        ).animate().fadeIn(duration: 300.ms, delay: 350.ms),

                        const SizedBox(height: 16),

                        // Start date
                        _buildDatePicker(
                          label: 'تاريخ الاشتراك',
                          date: _startDate,
                          onTap: _selectDate,
                          isDarkMode: isDarkMode,
                        ).animate().fadeIn(duration: 300.ms, delay: 400.ms),

                        if (isEditing) ...[
                          const SizedBox(height: 16),
                          // Accumulated debt (read-only for editing)
                          _buildInfoField(
                            label: 'الدين المتراكم',
                            value: '${_accumulatedDebt.toStringAsFixed(0)} IQD',
                            isDarkMode: isDarkMode,
                          ).animate().fadeIn(duration: 300.ms, delay: 450.ms),
                        ],

                        const SizedBox(height: 16),

                        // Notes field
                        _buildTextField(
                          label: 'ملاحظات',
                          controller: _notesController,
                          hint: 'ملاحظات إضافية...',
                          icon: Icons.note,
                          isDarkMode: isDarkMode,
                          maxLines: 2,
                        ).animate().fadeIn(duration: 300.ms, delay: 500.ms),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isLoading
                            ? null
                            : () => Navigator.of(context).pop(false),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(
                            color: isDarkMode
                                ? AppColors.darkBorder
                                : AppColors.borderLight,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'إلغاء',
                          style: AppTypography.labelLg.copyWith(
                            color: isDarkMode
                                ? AppColors.darkTextBody
                                : AppColors.textBody,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _saveSubscriber,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.gold,
                          foregroundColor: AppColors.textOnGold,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation(
                                      AppColors.textOnGold),
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    isEditing ? Icons.check : Icons.add,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    isEditing
                                        ? 'حفظ التغييرات'
                                        : 'إضافة المشترك',
                                    style: AppTypography.labelLg.copyWith(
                                      color: AppColors.textOnGold,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ],
                ).animate().fadeIn(duration: 300.ms, delay: 600.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required bool isDarkMode,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.labelMd.copyWith(
            color: isDarkMode ? AppColors.darkTextBody : AppColors.textBody,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: AppTypography.bodyMd.copyWith(
            color: isDarkMode ? AppColors.darkTextHead : AppColors.textHeading,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTypography.bodyMd.copyWith(
              color: isDarkMode ? AppColors.darkTextMuted : AppColors.textMuted,
            ),
            prefixIcon: Icon(
              icon,
              size: 20,
              color:
                  isDarkMode ? AppColors.darkTextBody : AppColors.textSecondary,
            ),
            filled: true,
            fillColor: isDarkMode
                ? AppColors.darkBgSurfaceAlt
                : AppColors.bgSurfaceAlt,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required T value,
    required List<DropdownMenuItem<T>> items,
    required void Function(T?) onChanged,
    required bool isDarkMode,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.labelMd.copyWith(
            color: isDarkMode ? AppColors.darkTextBody : AppColors.textBody,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: isDarkMode
                ? AppColors.darkBgSurfaceAlt
                : AppColors.bgSurfaceAlt,
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              isExpanded: true,
              items: items,
              onChanged: onChanged,
              style: AppTypography.bodyMd.copyWith(
                color:
                    isDarkMode ? AppColors.darkTextHead : AppColors.textHeading,
              ),
              icon: Icon(
                Icons.keyboard_arrow_down,
                color: isDarkMode
                    ? AppColors.darkTextBody
                    : AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker({
    required String label,
    required DateTime date,
    required VoidCallback onTap,
    required bool isDarkMode,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.labelMd.copyWith(
            color: isDarkMode ? AppColors.darkTextBody : AppColors.textBody,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isDarkMode
                  ? AppColors.darkBgSurfaceAlt
                  : AppColors.bgSurfaceAlt,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 20,
                  color: isDarkMode
                      ? AppColors.darkTextBody
                      : AppColors.textSecondary,
                ),
                const SizedBox(width: 12),
                Text(
                  '${date.day}/${date.month}/${date.year}',
                  style: AppTypography.bodyMd.copyWith(
                    color: isDarkMode
                        ? AppColors.darkTextHead
                        : AppColors.textHeading,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoField({
    required String label,
    required String value,
    required bool isDarkMode,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.labelMd.copyWith(
            color: isDarkMode ? AppColors.darkTextBody : AppColors.textBody,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isDarkMode
                ? AppColors.darkBgSurfaceAlt
                : AppColors.bgSurfaceAlt,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 20,
                color: isDarkMode
                    ? AppColors.darkTextBody
                    : AppColors.textSecondary,
              ),
              const SizedBox(width: 12),
              Text(
                value,
                style: AppTypography.bodyMd.copyWith(
                  color: AppColors.statusDanger,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
