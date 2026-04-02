import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mawlid_al_dhaki/core/database/app_database.dart';
import 'package:mawlid_al_dhaki/core/theme/app_colors.dart';
import 'package:mawlid_al_dhaki/core/theme/app_typography.dart';
import 'package:mawlid_al_dhaki/features/workers/providers/workers_provider.dart';
import 'package:mawlid_al_dhaki/features/collection/collection_screen.dart';

class PaymentRegistrationDialog extends ConsumerStatefulWidget {
  final Subscriber subscriber;
  final VoidCallback? onPaymentRegistered;

  const PaymentRegistrationDialog({
    super.key,
    required this.subscriber,
    this.onPaymentRegistered,
  });

  @override
  ConsumerState<PaymentRegistrationDialog> createState() =>
      _PaymentRegistrationDialogState();
}

class _PaymentRegistrationDialogState
    extends ConsumerState<PaymentRegistrationDialog> {
  final _amountController = TextEditingController();
  final _cabinetController = TextEditingController();
  Worker? _selectedWorker;
  double? _selectedQuickAmount;
  bool _showCustomAmount = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _cabinetController.text = widget.subscriber.cabinet;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _cabinetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final workersState = ref.watch(workersProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        title: Text(
          'تسجيل دفعة جديدة',
          style: AppTypography.h3.copyWith(
            color: isDarkMode ? AppColors.darkTextHead : AppColors.textHeading,
          ),
        ),
        content: SizedBox(
          width: 400,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Subscriber Info
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? AppColors.darkBgSurfaceAlt
                        : AppColors.bgSurfaceAlt,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.subscriber.name,
                        style: AppTypography.bodyLg.copyWith(
                          color: isDarkMode
                              ? AppColors.darkTextHead
                              : AppColors.textHeading,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'رقم الجوزة: ${widget.subscriber.code}',
                        style: AppTypography.bodySm.copyWith(
                          color: isDarkMode
                              ? AppColors.darkTextMuted
                              : AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'الكابينة: ${widget.subscriber.cabinet}',
                        style: AppTypography.bodySm.copyWith(
                          color: isDarkMode
                              ? AppColors.darkTextMuted
                              : AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Amount Input
                Text(
                  'المبلغ المدفوع',
                  style: AppTypography.bodyMd.copyWith(
                    color: isDarkMode
                        ? AppColors.darkTextHead
                        : AppColors.textHeading,
                  ),
                ),
                const SizedBox(height: 8),

                // Quick Amount Buttons
                if (!_showCustomAmount) ...[
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildQuickAmountButton(15000, isDarkMode),
                      _buildQuickAmountButton(30000, isDarkMode),
                      _buildQuickAmountButton(50000, isDarkMode),
                      _buildQuickAmountButton(100000, isDarkMode),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _showCustomAmount = true;
                          });
                        },
                        child: Text(
                          'مبلغ آخر',
                          style: AppTypography.labelLg.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],

                // Custom Amount Input
                if (_showCustomAmount) ...[
                  TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    textDirection: TextDirection.ltr,
                    decoration: InputDecoration(
                      hintText: 'أدخل المبلغ',
                      filled: true,
                      fillColor: isDarkMode
                          ? AppColors.darkBgSurfaceAlt
                          : AppColors.bgSurfaceAlt,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: isDarkMode
                              ? AppColors.darkBorder
                              : AppColors.borderLight,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: isDarkMode
                              ? AppColors.darkBorder
                              : AppColors.borderLight,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _selectedQuickAmount = null;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                ],

                // Worker Selection
                Text(
                  'العامل',
                  style: AppTypography.bodyMd.copyWith(
                    color: isDarkMode
                        ? AppColors.darkTextHead
                        : AppColors.textHeading,
                  ),
                ),
                const SizedBox(height: 8),
                if (workersState.isLoading)
                  const Center(child: CircularProgressIndicator())
                else if (workersState.error != null)
                  Text(
                    'خطأ في تحميل العمال: ${workersState.error}',
                    style: AppTypography.bodySm.copyWith(
                      color: AppColors.statusDanger,
                    ),
                  )
                else
                  DropdownButtonFormField<Worker>(
                    initialValue: _selectedWorker,
                    hint: Text(
                      'اختر العامل',
                      style: AppTypography.bodyMd.copyWith(
                        color: isDarkMode
                            ? AppColors.darkTextBody
                            : AppColors.textBody,
                      ),
                    ),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: isDarkMode
                          ? AppColors.darkBgSurfaceAlt
                          : AppColors.bgSurfaceAlt,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: isDarkMode
                              ? AppColors.darkBorder
                              : AppColors.borderLight,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: isDarkMode
                              ? AppColors.darkBorder
                              : AppColors.borderLight,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    items: workersState.workers.map((worker) {
                      return DropdownMenuItem<Worker>(
                        value: worker,
                        child: Text(worker.name),
                      );
                    }).toList(),
                    onChanged: (Worker? newValue) {
                      setState(() {
                        _selectedWorker = newValue;
                      });
                    },
                  ),
                const SizedBox(height: 16),

                // Cabinet Input
                Text(
                  'الكابينة',
                  style: AppTypography.bodyMd.copyWith(
                    color: isDarkMode
                        ? AppColors.darkTextHead
                        : AppColors.textHeading,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _cabinetController,
                  textDirection: TextDirection.rtl,
                  decoration: InputDecoration(
                    hintText: 'اسم الكابينة',
                    filled: true,
                    fillColor: isDarkMode
                        ? AppColors.darkBgSurfaceAlt
                        : AppColors.bgSurfaceAlt,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: isDarkMode
                            ? AppColors.darkBorder
                            : AppColors.borderLight,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: isDarkMode
                            ? AppColors.darkBorder
                            : AppColors.borderLight,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Print Options
                Text(
                  'خيارات الطباعة',
                  style: AppTypography.bodyMd.copyWith(
                    color: isDarkMode
                        ? AppColors.darkTextHead
                        : AppColors.textHeading,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Checkbox(value: true, onChanged: null),
                    Text(
                      'طباعة إيصال بعد التسجيل',
                      style: AppTypography.bodyMd.copyWith(
                        color: isDarkMode
                            ? AppColors.darkTextBody
                            : AppColors.textBody,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: _isSubmitting
                ? null
                : () {
                    Navigator.of(context).pop();
                  },
            child: Text(
              'إلغاء',
              style: AppTypography.labelLg.copyWith(
                color: isDarkMode ? AppColors.darkTextBody : AppColors.textBody,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: _isSubmitting ? null : _handleSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textOnPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: _isSubmitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.textOnPrimary,
                      ),
                    ),
                  )
                : Text(
                    'تسجيل الدفعة',
                    style: AppTypography.labelLg.copyWith(
                      color: AppColors.textOnPrimary,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAmountButton(double amount, bool isDarkMode) {
    final isSelected = _selectedQuickAmount == amount;
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _selectedQuickAmount = amount;
          _amountController.text = amount.toString();
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected
            ? AppColors.primary
            : (isDarkMode ? AppColors.darkBgSurfaceAlt : AppColors.bgSurfaceAlt),
        foregroundColor: isSelected
            ? AppColors.textOnPrimary
            : (isDarkMode ? AppColors.darkTextBody : AppColors.textBody),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: isSelected ? 2 : 0,
      ),
      child: Text(
        '${amount ~/ 1000} ألف دينار',
        style: AppTypography.labelLg.copyWith(
          color: isSelected
              ? AppColors.textOnPrimary
              : (isDarkMode ? AppColors.darkTextBody : AppColors.textBody),
        ),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    final amountText = _amountController.text.trim();
    if (amountText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'يرجى إدخال المبلغ المدفوع',
            textDirection: TextDirection.rtl,
          ),
          backgroundColor: AppColors.statusDanger,
        ),
      );
      return;
    }

    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'يرجى إدخال مبلغ صحيح',
            textDirection: TextDirection.rtl,
          ),
          backgroundColor: AppColors.statusDanger,
        ),
      );
      return;
    }

    if (_selectedWorker == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'يرجى اختيار العامل',
            textDirection: TextDirection.rtl,
          ),
          backgroundColor: AppColors.statusDanger,
        ),
      );
      return;
    }

    final cabinet = _cabinetController.text.trim();
    if (cabinet.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'يرجى إدخال اسم الكابينة',
            textDirection: TextDirection.rtl,
          ),
          backgroundColor: AppColors.statusDanger,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Register payment through collection notifier
      final collectionNotifier = ref.read(collectionProvider.notifier);
      await collectionNotifier.registerPayment(
        subscriberId: widget.subscriber.id.toString(),
        amount: amount,
        workerName: _selectedWorker!.name,
        cabinetName: cabinet,
      );

      if (mounted) {
        Navigator.of(context).pop();
        widget.onPaymentRegistered?.call();

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'تم تسجيل الدفعة بنجاح',
              textDirection: TextDirection.rtl,
            ),
            backgroundColor: AppColors.statusActive,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'فشل تسجيل الدفعة: $e',
              textDirection: TextDirection.rtl,
            ),
            backgroundColor: AppColors.statusDanger,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}