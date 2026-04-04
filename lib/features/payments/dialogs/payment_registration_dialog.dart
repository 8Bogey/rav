import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mawlid_al_dhaki/core/database/app_database.dart';
import 'package:mawlid_al_dhaki/core/database/database_provider.dart';
import 'package:mawlid_al_dhaki/core/theme/app_colors.dart';
import 'package:mawlid_al_dhaki/core/theme/app_typography.dart';
import 'package:mawlid_al_dhaki/features/payments/providers/payments_provider.dart';
import 'package:mawlid_al_dhaki/features/workers/providers/workers_provider.dart';
import 'package:mawlid_al_dhaki/features/subscribers/providers/subscribers_provider.dart';
import 'package:mawlid_al_dhaki/core/services/audit_service.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Payment Registration Dialog
class PaymentRegistrationDialog extends ConsumerStatefulWidget {
  final Subscriber? subscriber;
  final Function(Payment)? onPaymentRegistered;

  const PaymentRegistrationDialog({
    super.key,
    this.subscriber,
    this.onPaymentRegistered,
  });

  @override
  ConsumerState<PaymentRegistrationDialog> createState() =>
      _PaymentRegistrationDialogState();
}

class _PaymentRegistrationDialogState
    extends ConsumerState<PaymentRegistrationDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  double _amount = 0;
  String? _selectedWorkerId;
  bool _isLoading = false;
  bool _printReceipt = true;

  // Quick amount options
  final List<Map<String, dynamic>> _quickAmounts = [
    {'label': 'كامل', 'value': null, 'icon': Icons.check_circle},
    {'label': '15,000', 'value': 15000.0, 'icon': null},
    {'label': '10,000', 'value': 10000.0, 'icon': null},
    {'label': '7,500', 'value': 7500.0, 'icon': null},
    {'label': '5,000', 'value': 5000.0, 'icon': null},
  ];

  @override
  void initState() {
    super.initState();
    // Set default amount from subscriber's debt if available
    if (widget.subscriber != null) {
      _amount = widget.subscriber!.accumulatedDebt;
      _amountController.text = _formatAmount(_amount);
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  String _formatAmount(double amount) {
    return amount.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }

  double _parseAmount(String value) {
    return double.tryParse(value.replaceAll(',', '').replaceAll(' ', '')) ?? 0;
  }

  Future<void> _registerPayment() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedWorkerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى اختيار العامل')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final worker = ref.read(workersProvider).workers.firstWhere(
            (w) => w.id == _selectedWorkerId,
            orElse: () =>
                throw StateError('Worker not found: $_selectedWorkerId'),
          );

      // Add payment
      await ref.read(paymentsProvider.notifier).addPayment(
            subscriberId: widget.subscriber!.id,
            amount: _amount,
            worker: worker.name,
            cabinet: widget.subscriber!.cabinet,
            date: DateTime.now(),
          );

      // Log audit
      await ref.read(auditServiceProvider).logPayment(
            '${_formatAmount(_amount)} IQD - ${widget.subscriber!.name}',
          );

      // Update subscriber's debt
      final newDebt = widget.subscriber!.accumulatedDebt - _amount;
      if (newDebt <= 0) {
        // Mark as completed
        final updatedSubscriber = widget.subscriber!.copyWith(
          accumulatedDebt: 0,
          status: 1, // Active
        );
        await ref
            .read(subscribersProvider.notifier)
            .updateSubscriber(updatedSubscriber);
      } else {
        // Update remaining debt
        final updatedSubscriber = widget.subscriber!.copyWith(
          accumulatedDebt: newDebt,
        );
        await ref
            .read(subscribersProvider.notifier)
            .updateSubscriber(updatedSubscriber);
      }

      // Refresh subscribers list
      ref.read(subscribersProvider.notifier).loadSubscribers();

      setState(() => _isLoading = false);

      // Show success
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('تم تسجيل الدفعة بنجاح - ${_formatAmount(_amount)} IQD'),
            backgroundColor: AppColors.statusActive,
          ),
        );
        Navigator.of(context).pop();
      }

      // Print receipt if requested
      if (_printReceipt) {
        // Get worker name from workersState
        final workersState = ref.read(workersProvider);
        final selectedWorker = workersState.workers
            .where((w) => w.id == _selectedWorkerId)
            .firstOrNull;

        await _printPaymentReceipt(
          subscriberName: widget.subscriber?.name ?? 'غير محدد',
          subscriberCode: widget.subscriber?.code ?? '',
          amount: _amount,
          workerName: selectedWorker?.name ?? 'غير محدد',
          cabinetName: widget.subscriber?.cabinet ?? '',
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل تسجيل الدفعة: $e'),
            backgroundColor: AppColors.statusDanger,
          ),
        );
      }
    }
  }

  /// Print payment receipt
  Future<void> _printPaymentReceipt({
    required String subscriberName,
    required String subscriberCode,
    required double amount,
    required String workerName,
    required String cabinetName,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a5,
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            pw.Text(
              'إيصال دفع',
              style: pw.TextStyle(
                fontSize: 24,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Divider(),
            pw.SizedBox(height: 20),
            _buildReceiptRow(
                'التاريخ', DateTime.now().toString().substring(0, 16)),
            _buildReceiptRow('اسم المشترك', subscriberName),
            _buildReceiptRow('كود المشترك', subscriberCode),
            _buildReceiptRow('الكابينة', cabinetName),
            _buildReceiptRow('المبلغ', '${_formatAmount(amount)} IQD'),
            _buildReceiptRow('العامل', workerName),
            pw.SizedBox(height: 20),
            pw.Divider(),
            pw.SizedBox(height: 10),
            pw.Text(
              'شكراً لاستخدامكم نظام Smart_gen',
              style: const pw.TextStyle(fontSize: 10),
            ),
          ],
        ),
      ),
    );

    // Show print dialog
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  pw.Widget _buildReceiptRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: const pw.TextStyle(fontSize: 12)),
          pw.Text(value,
              style:
                  pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final workersState = ref.watch(workersProvider);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: 480,
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
                    'تسجيل دفعة',
                    style: AppTypography.h2.copyWith(
                      color: isDarkMode
                          ? AppColors.darkTextHead
                          : AppColors.textHeading,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(
                      Icons.close,
                      color: isDarkMode
                          ? AppColors.darkTextBody
                          : AppColors.textBody,
                    ),
                  ),
                ],
              ).animate().fadeIn(duration: 200.ms),

              const SizedBox(height: 16),

              // Subscriber info
              if (widget.subscriber != null) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? AppColors.darkBgSurfaceAlt
                        : AppColors.bgSurfaceAlt,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            widget.subscriber!.code.substring(0, 2),
                            style: AppTypography.labelLg.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.subscriber!.name,
                              style: AppTypography.h4.copyWith(
                                color: isDarkMode
                                    ? AppColors.darkTextHead
                                    : AppColors.textHeading,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'الدين المتراكم: ${_formatAmount(widget.subscriber!.accumulatedDebt)} IQD',
                              style: AppTypography.bodyMd.copyWith(
                                color: AppColors.statusDanger,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 300.ms, delay: 100.ms),
                const SizedBox(height: 24),
              ],

              // Amount input
              Text(
                'المبلغ (IQD)',
                style: AppTypography.labelMd.copyWith(
                  color:
                      isDarkMode ? AppColors.darkTextBody : AppColors.textBody,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.right,
                style: AppTypography.h3.copyWith(
                  color: isDarkMode
                      ? AppColors.darkTextHead
                      : AppColors.textHeading,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  _IQDInputFormatter(),
                ],
                decoration: InputDecoration(
                  hintText: '0',
                  suffixText: 'IQD',
                  filled: true,
                  fillColor: isDarkMode
                      ? AppColors.darkBgSurfaceAlt
                      : AppColors.bgSurfaceAlt,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى إدخال المبلغ';
                  }
                  final amount = _parseAmount(value);
                  if (amount <= 0) {
                    return 'المبلغ يجب أن يكون أكبر من صفر';
                  }
                  return null;
                },
                onChanged: (value) {
                  _amount = _parseAmount(value);
                },
              ).animate().fadeIn(duration: 300.ms, delay: 200.ms),

              const SizedBox(height: 16),

              // Quick amount chips
              Text(
                'اختيار سريع',
                style: AppTypography.labelMd.copyWith(
                  color:
                      isDarkMode ? AppColors.darkTextBody : AppColors.textBody,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _quickAmounts.map((qa) {
                  final isSelected = qa['value'] == null
                      ? _amount == widget.subscriber?.accumulatedDebt
                      : _amount == qa['value'];
                  return InkWell(
                    onTap: () {
                      final value = qa['value'] ??
                          widget.subscriber?.accumulatedDebt ??
                          0;
                      setState(() {
                        _amount = value;
                        _amountController.text = _formatAmount(value);
                      });
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.gold
                            : (isDarkMode
                                ? AppColors.darkBgSurfaceAlt
                                : AppColors.bgSurfaceAlt),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color:
                              isSelected ? AppColors.gold : Colors.transparent,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (qa['icon'] != null) ...[
                            Icon(qa['icon'],
                                size: 16, color: AppColors.textOnGold),
                            const SizedBox(width: 4),
                          ],
                          Text(
                            qa['label'],
                            style: AppTypography.labelMd.copyWith(
                              color: isSelected
                                  ? AppColors.textOnGold
                                  : (isDarkMode
                                      ? AppColors.darkTextBody
                                      : AppColors.textBody),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ).animate().fadeIn(duration: 300.ms, delay: 300.ms),

              const SizedBox(height: 24),

              // Worker selection
              Text(
                'العامل',
                style: AppTypography.labelMd.copyWith(
                  color:
                      isDarkMode ? AppColors.darkTextBody : AppColors.textBody,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? AppColors.darkBgSurfaceAlt
                      : AppColors.bgSurfaceAlt,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedWorkerId,
                    isExpanded: true,
                    hint: Text(
                      'اختر العامل',
                      style: AppTypography.bodyMd.copyWith(
                        color: isDarkMode
                            ? AppColors.darkTextMuted
                            : AppColors.textMuted,
                      ),
                    ),
                    items: workersState.workers.map((worker) {
                      return DropdownMenuItem<String>(
                        value: worker.id,
                        child: Text(
                          worker.name,
                          style: AppTypography.bodyMd.copyWith(
                            color: isDarkMode
                                ? AppColors.darkTextHead
                                : AppColors.textHeading,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => _selectedWorkerId = value);
                    },
                  ),
                ),
              ).animate().fadeIn(duration: 300.ms, delay: 400.ms),

              const SizedBox(height: 16),

              // Print receipt checkbox
              Row(
                children: [
                  Checkbox(
                    value: _printReceipt,
                    onChanged: (value) {
                      setState(() => _printReceipt = value ?? true);
                    },
                    activeColor: AppColors.gold,
                  ),
                  Text(
                    'طباعة الإيصال',
                    style: AppTypography.bodyMd.copyWith(
                      color: isDarkMode
                          ? AppColors.darkTextBody
                          : AppColors.textBody,
                    ),
                  ),
                ],
              ).animate().fadeIn(duration: 300.ms, delay: 500.ms),

              const SizedBox(height: 24),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed:
                          _isLoading ? null : () => Navigator.of(context).pop(),
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
                      onPressed: _isLoading ? null : _registerPayment,
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
                                const Icon(Icons.check, size: 18),
                                const SizedBox(width: 8),
                                Text(
                                  'تسجيل الدفعة',
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
    );
  }
}

/// IQD Input Formatter
class _IQDInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Remove non-digits
    final digits = newValue.text.replaceAll(RegExp(r'[^\d]'), '');

    // Format with commas
    final formatted = digits.replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
