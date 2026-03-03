import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:mawlid_al_dhaki/core/theme/app_colors.dart';
import 'package:mawlid_al_dhaki/core/theme/app_typography.dart';

class Subscriber {
  final String id;
  final String name;
  final String code;
  final String cabinet;
  final int ampere;
  final String phoneNumber;
  final String status;
  final List<Payment> debts;
  final DateTime startDate;
  final List<String> tags;

  Subscriber({
    required this.id,
    required this.name,
    required this.code,
    required this.cabinet,
    required this.ampere,
    required this.phoneNumber,
    required this.status,
    required this.debts,
    required this.startDate,
    required this.tags,
  });
}

class Payment {
  final String id;
  final DateTime date;
  final int amount;
  final String collector;
  final String subscriberId;

  Payment({
    required this.id,
    required this.date,
    required this.amount,
    required this.collector,
    required this.subscriberId,
  });
}

class SubscribersScreen extends StatefulWidget {
  const SubscribersScreen({super.key});

  @override
  State<SubscribersScreen> createState() => _SubscribersScreenState();
}

class _SubscribersScreenState extends State<SubscribersScreen> {
  // Mock data
  late List<Subscriber> _subscribers;
  late List<Subscriber> _filteredSubscribers;
  String _searchQuery = '';
  String _selectedStatus = 'الكل';

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    // Mock subscriber data
    _subscribers = [
      Subscriber(
        id: '1',
        name: 'أحمد علي محمود',
        code: 'A4',
        cabinet: 'A',
        ampere: 5,
        phoneNumber: '07701234567',
        status: 'פעיל',
        debts: [],
        startDate: DateTime(2024, 1, 1),
        tags: ['VIP', 'منتظم'],
      ),
      Subscriber(
        id: '2',
        name: 'محمد حسن سامي',
        code: 'B2',
        cabinet: 'B',
        ampere: 3,
        phoneNumber: '07701234568',
        status: 'موقوف',
        debts: [
          Payment(id: 'p1', date: DateTime(2026, 1, 1), amount: 10000, collector: 'علي', subscriberId: '2'),
          Payment(id: 'p2', date: DateTime(2026, 2, 1), amount: 12000, collector: 'أحمد', subscriberId: '2'),
        ],
        startDate: DateTime(2024, 2, 1),
        tags: ['منتظم'],
      ),
      Subscriber(
        id: '3',
        name: 'خالد رامي فهد',
        code: 'C7',
        cabinet: 'C',
        ampere: 7,
        phoneNumber: '07701234569',
        status: 'مقطوع',
        debts: [
          Payment(id: 'p3', date: DateTime(2025, 11, 1), amount: 8000, collector: 'محمد', subscriberId: '3'),
          Payment(id: 'p4', date: DateTime(2025, 12, 1), amount: 7000, collector: 'علي', subscriberId: '3'),
          Payment(id: 'p5', date: DateTime(2026, 1, 1), amount: 9000, collector: 'أحمد', subscriberId: '3'),
        ],
        startDate: DateTime(2024, 3, 1),
        tags: [],
      ),
      Subscriber(
        id: '4',
        name: 'فهد سامي خالد',
        code: 'D3',
        cabinet: 'D',
        ampere: 10,
        phoneNumber: '07701234570',
        status: 'معلق',
        debts: [],
        startDate: DateTime(2024, 4, 1),
        tags: ['منتظم'],
      ),
      Subscriber(
        id: '5',
        name: 'سامي خالد فهد',
        code: 'E1',
        cabinet: 'E',
        ampere: 15,
        phoneNumber: '07701234571',
        status: 'فعال',
        debts: [],
        startDate: DateTime(2024, 5, 1),
        tags: ['VIP'],
      ),
    ];

    _filteredSubscribers = List.from(_subscribers);
  }

  void _filterSubscribers() {
    setState(() {
      _filteredSubscribers = _subscribers.where((subscriber) {
        final matchesSearch = _searchQuery.isEmpty ||
            subscriber.name.contains(_searchQuery) ||
            subscriber.code.contains(_searchQuery);
        
        final matchesStatus = _selectedStatus == 'الكل' || 
            _selectedStatus == subscriber.status;
        
        return matchesSearch && matchesStatus;
      }).toList();
    });
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'فعال':
      case 'פעיל':
        return AppColors.statusActive;
      case 'موقوف':
        return AppColors.statusWarning;
      case 'مقطوع':
        return AppColors.statusDanger;
      case 'معلق':
        return AppColors.statusInfo;
      default:
        return AppColors.textSecondary;
    }
  }

  Color _getStatusBackgroundColor(String status) {
    switch (status) {
      case 'فعال':
      case 'פעיל':
        return AppColors.statusActiveS;
      case 'موقوف':
        return AppColors.statusWarningS;
      case 'مقطوع':
        return AppColors.statusDangerS;
      case 'معلق':
        return AppColors.statusInfoS;
      default:
        return AppColors.bgSurfaceAlt;
    }
  }

  String _formatCurrency(int amount) {
    final formatter = NumberFormat('#,##0', 'en_US');
    return '${formatter.format(amount)} IQD';
  }

  int _calculateTotalDebt(List<Payment> payments) {
    return payments.fold(0, (sum, payment) => sum + payment.amount);
  }

  Widget _buildStatusBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getStatusBackgroundColor(status),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: _getStatusColor(status),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            status,
            style: AppTypography.labelMd.copyWith(
              color: _getStatusColor(status),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with title and actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'المشتركون',
                  style: AppTypography.h2.copyWith(color: AppColors.textHeading),
                ).animate().fadeIn(duration: 300.ms),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.gold,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.add,
                            color: AppColors.textOnGold,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'إضافة مشترك',
                            style: AppTypography.labelLg.copyWith(
                              color: AppColors.textOnGold,
                            ),
                          ),
                        ],
                      ),
                    ).animate(delay: 100.ms).scaleXY(begin: 0.95, end: 1.0, duration: 400.ms),
                  ],
                ),
              ],
            ).animate().fadeIn(duration: 300.ms),
            const SizedBox(height: 24),

            // Search and filter bar
            Row(
              children: [
                // Status filter tabs
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.bgSurfaceAlt,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      _buildFilterTab('الكل', '(1240)'),
                      _buildFilterTab('نشط', '(1100)'),
                      _buildFilterTab('موقوف', '(89)'),
                      _buildFilterTab('مقطوع', '(34)'),
                      _buildFilterTab('معلق', '(17)'),
                    ],
                  ),
                ).animate(delay: 200.ms).fadeIn(duration: 300.ms),
                
                const SizedBox(width: 16),
                
                // Search bar
                Expanded(
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                      _filterSubscribers();
                    },
                    decoration: InputDecoration(
                      hintText: 'بحث في المشتركين...',
                      prefixIcon: const Icon(Icons.search, size: 20),
                      filled: true,
                      fillColor: AppColors.bgSurfaceAlt,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                  ).animate(delay: 300.ms).fadeIn(duration: 300.ms),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Subscribers data table
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.bgSurface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0A000000),
                      blurRadius: 4,
                      offset: Offset(0, 1),
                    ),
                    BoxShadow(
                      color: Color(0x06000000),
                      blurRadius: 12,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Table header
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.bgSurfaceAlt,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      ),
                      child: Row(
                        children: [
                          Expanded(flex: 1, child: Text('الكود', style: AppTypography.labelMd.copyWith(color: AppColors.textSecondary))),
                          Expanded(flex: 3, child: Text('المشترك', style: AppTypography.labelMd.copyWith(color: AppColors.textSecondary))),
                          Expanded(flex: 1, child: Text('الكابينة', style: AppTypography.labelMd.copyWith(color: AppColors.textSecondary))),
                          Expanded(flex: 2, child: Text('الدين المتراكم', style: AppTypography.labelMd.copyWith(color: AppColors.textSecondary))),
                          Expanded(flex: 1, child: Text('آخر دفعة', style: AppTypography.labelMd.copyWith(color: AppColors.textSecondary))),
                          Expanded(flex: 1, child: Text('الحالة', style: AppTypography.labelMd.copyWith(color: AppColors.textSecondary))),
                        ],
                      ),
                    ).animate(delay: 400.ms).fadeIn(duration: 300.ms),
                    
                    // Table rows
                    Expanded(
                      child: ListView.builder(
                        itemCount: _filteredSubscribers.length,
                        itemBuilder: (context, index) {
                          final subscriber = _filteredSubscribers[index];
                          return Container(
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: AppColors.borderLight,
                                ),
                              ),
                            ),
                            child: InkWell(
                              onTap: () {
                                // Show subscriber details
                              },
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    // Code with colored avatar
                                    Expanded(
                                      flex: 1,
                                      child: Container(
                                        width: 36,
                                        height: 36,
                                        decoration: BoxDecoration(
                                          color: _getCodeColor(subscriber.code),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Center(
                                          child: Text(
                                            subscriber.code,
                                            style: AppTypography.labelMd.copyWith(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    
                                    // Subscriber name
                                    Expanded(
                                      flex: 3,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            subscriber.name,
                                            style: AppTypography.bodyMd.copyWith(
                                              color: AppColors.textHeading,
                                            ),
                                          ),
                                          Text(
                                            subscriber.phoneNumber,
                                            style: AppTypography.bodySm.copyWith(
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    
                                    // Cabinet
                                    Expanded(
                                      flex: 1,
                                      child: Text(
                                        subscriber.cabinet,
                                        style: AppTypography.bodyMd.copyWith(
                                          color: AppColors.textBody,
                                        ),
                                      ),
                                    ),
                                    
                                    // Debt
                                    Expanded(
                                      flex: 2,
                                      child: _calculateTotalDebt(subscriber.debts) > 0
                                          ? Text(
                                              _formatCurrency(_calculateTotalDebt(subscriber.debts)),
                                              style: AppTypography.bodyMd.copyWith(
                                                color: AppColors.statusDanger,
                                              ),
                                            )
                                          : const Text(
                                              'لا يوجد',
                                              style: TextStyle(
                                                color: Colors.green,
                                              ),
                                            ),
                                    ),
                                    
                                    // Last payment
                                    Expanded(
                                      flex: 1,
                                      child: Text(
                                        subscriber.debts.isNotEmpty
                                            ? '${subscriber.debts.last.date.day}/${subscriber.debts.last.date.month}/${subscriber.debts.last.date.year.toString().substring(2)}'
                                            : '-',
                                        style: AppTypography.bodyMd.copyWith(
                                          color: AppColors.textBody,
                                        ),
                                      ),
                                    ),
                                    
                                    // Status
                                    Expanded(
                                      flex: 1,
                                      child: _buildStatusBadge(subscriber.status),
                                    ),
                                  ],
                                ),
                              ).animate(delay: (500 + index * 50).ms).fadeIn(duration: 300.ms),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ).animate(delay: 450.ms).fadeIn(duration: 400.ms),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterTab(String label, String count) {
    final isSelected = _selectedStatus == label || (_selectedStatus == 'الكل' && label == 'الكل');
    return TextButton(
      onPressed: () {
        setState(() {
          _selectedStatus = label == 'الكل' ? 'الكل' : label;
        });
        _filterSubscribers();
      },
      style: TextButton.styleFrom(
        backgroundColor: isSelected ? AppColors.primary : Colors.transparent,
        foregroundColor: isSelected ? Colors.white : AppColors.textSecondary,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      child: Text(
        '$label $count',
        style: AppTypography.labelMd.copyWith(
          color: isSelected ? Colors.white : AppColors.textSecondary,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    );
  }

  Color _getCodeColor(String code) {
    final colors = [
      AppColors.primary,
      const Color(0xFF1E40AF),
      const Color(0xFF7C3AED),
      const Color(0xFFB45309),
      const Color(0xFF0E7490),
      const Color(0xFF065F46),
      const Color(0xFF9D174D),
      const Color(0xFF92400E),
    ];
    
    return colors[code.codeUnits.fold(0, (a, b) => a + b) % colors.length];
  }
}