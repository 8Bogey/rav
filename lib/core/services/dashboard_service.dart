import 'package:drift/drift.dart';
import 'package:mawlid_al_dhaki/core/database/app_database.dart';
import 'package:mawlid_al_dhaki/core/services/subscribers_service.dart';
import 'package:mawlid_al_dhaki/core/services/cabinets_service.dart';

class DashboardService {
  final AppDatabase database;
  late SubscribersService _subscribersService;
  late CabinetsService _cabinetsService;

  DashboardService(this.database) {
    _subscribersService = SubscribersService(database);
    _cabinetsService = CabinetsService(database);
  }

  // Get total number of subscribers
  Future<int> getTotalSubscribers() async {
    try {
      final subscribers = await _subscribersService.getAllSubscribers();
      return subscribers.length;
    } catch (e) {
      return 0;
    }
  }

  // Get active subscribers (subscribers with no accumulated debt)
  Future<int> getActiveSubscribers() async {
    try {
      final subscribers = await _subscribersService.getAllSubscribers();
      return subscribers.where((s) => s.accumulatedDebt <= 0).length;
    } catch (e) {
      return 0;
    }
  }

  // Get weekly collected amount
  Future<double> getWeeklyCollectedAmount() async {
    try {
      final now = DateTime.now();
      final startOfWeek = now.subtract(Duration(days: now.weekday - 1)); // Monday as start of week
      final startOfDay = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
      
      final payments = await database.select(database.paymentsTable).get();
      
      double total = 0;
      for (var payment in payments) {
        if (payment.date.isAfter(startOfDay) || payment.date.isAtSameMomentAs(startOfDay)) {
          // Check if payment is within the current week
          final paymentDayOfWeek = payment.date.difference(startOfDay).inDays;
          if (paymentDayOfWeek < 7) {
            total += payment.amount;
          }
        }
      }
      return total;
    } catch (e) {
      return 0.0;
    }
  }

  // Get monthly collected amount
  Future<double> getMonthlyCollectedAmount() async {
    try {
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      
      final payments = await database.select(database.paymentsTable).get();
      
      double total = 0;
      for (var payment in payments) {
        if (payment.date.isAfter(startOfMonth) || payment.date.isAtSameMomentAs(startOfMonth)) {
          // Check if payment is within the current month
          if (payment.date.month == now.month && payment.date.year == now.year) {
            total += payment.amount;
          }
        }
      }
      return total;
    } catch (e) {
      return 0.0;
    }
  }

  // Get cabinet completion rate as percentage
  Future<double> getCabinetCompletionRate() async {
    try {
      final totalCabinets = await getTotalCabinets();
      if (totalCabinets == 0) return 0.0;
      
      final completedCabinets = await getCompletedCabinets();
      return (completedCabinets / totalCabinets) * 100;
    } catch (e) {
      return 0.0;
    }
  }

  // Get average worker performance (placeholder - would need actual implementation based on data)
  Future<double> getWorkerPerformance() async {
    // For now return a placeholder value, could be calculated based on actual data
    return 85.0;
  }

  // Get total number of cabinets
  Future<int> getTotalCabinets() async {
    try {
      final cabinets = await _cabinetsService.getAllCabinets();
      return cabinets.length;
    } catch (e) {
      return 0;
    }
  }

  // Get completed cabinets (100% progress)
  Future<int> getCompletedCabinets() async {
    try {
      final cabinets = await _cabinetsService.getAllCabinets();
      int completed = 0;
      for (var cabinet in cabinets) {
        if (cabinet.totalSubscribers > 0 && 
            cabinet.currentSubscribers >= cabinet.totalSubscribers) {
          completed++;
        }
      }
      return completed;
    } catch (e) {
      return 0;
    }
  }

  // Get today's collected amount
  Future<double> getTodayCollectedAmount() async {
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      
      final payments = await database.select(database.paymentsTable).get();
      
      double total = 0;
      for (var payment in payments) {
        if (payment.date.isAfter(startOfDay) || 
            (payment.date.year == startOfDay.year && 
             payment.date.month == startOfDay.month && 
             payment.date.day == startOfDay.day)) {
          total += payment.amount;
        }
      }
      return total;
    } catch (e) {
      return 0.0;
    }
  }

  // Get subscribers who haven't paid (have debt)
  Future<int> getNonPayingSubscribers() async {
    try {
      final subscribers = await _subscribersService.getAllSubscribers();
      return subscribers.where((s) => s.accumulatedDebt > 0).length;
    } catch (e) {
      return 0;
    }
  }

  // Get recent activities from audit log
  Future<List<Map<String, dynamic>>> getRecentActivities() async {
    try {
      final logs = await (database.select(database.auditLogTable)
            ..orderBy([(t) => OrderingTerm.desc(t.timestamp)])
            ..limit(10))
          .get();
      
      return logs.map((log) {
        String color;
        switch (log.type) {
          case 'payment':
            color = 'statusActive';
            break;
          case 'subscriber_added':
            color = 'statusInfo';
            break;
          case 'subscriber_removed':
          case 'service_cut':
            color = 'statusDanger';
            break;
          default:
            color = 'statusInfo';
        }
        
        return {
          'userName': log.user,
          'activity': log.action,
          'userCode': log.target,
          'date': '${log.timestamp.day.toString().padLeft(2, '0')}/${log.timestamp.month.toString().padLeft(2, '0')}/${log.timestamp.year}',
          'color': color,
        };
      }).toList();
    } catch (e) {
      return [];
    }
  }

  // Get payment trends data for the last 7 days
  Future<List<Map<String, dynamic>>> getPaymentTrends() async {
    try {
      final now = DateTime.now();
      final dayNames = ['الأحد', 'الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت'];
      List<Map<String, dynamic>> trends = [];
      
      final allPayments = await database.select(database.paymentsTable).get();
      
      for (int i = 6; i >= 0; i--) {
        final date = now.subtract(Duration(days: i));
        final startOfDay = DateTime(date.year, date.month, date.day);
        final endOfDay = startOfDay.add(const Duration(days: 1));
        
        int count = 0;
        for (var payment in allPayments) {
          if ((payment.date.isAfter(startOfDay) || payment.date.isAtSameMomentAs(startOfDay)) &&
              payment.date.isBefore(endOfDay)) {
            count++;
          }
        }
        
        trends.add({
          'day': dayNames[date.weekday % 7],
          'payments': count,
          'commissions': (count * 0.8).round(),
        });
      }
      
      return trends;
    } catch (e) {
      return [
        {'day': 'الاثنين', 'payments': 0, 'commissions': 0},
        {'day': 'الثلاثاء', 'payments': 0, 'commissions': 0},
        {'day': 'الأربعاء', 'payments': 0, 'commissions': 0},
        {'day': 'الخميس', 'payments': 0, 'commissions': 0},
        {'day': 'الجمعة', 'payments': 0, 'commissions': 0},
        {'day': 'السبت', 'payments': 0, 'commissions': 0},
        {'day': 'الأحد', 'payments': 0, 'commissions': 0},
      ];
    }
  }

  // Get daily collection amounts for bar chart (last 7 days)
  Future<List<Map<String, dynamic>>> getDailyCollections() async {
    try {
      final now = DateTime.now();
      final dayNames = ['الأحد', 'الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت'];
      List<Map<String, dynamic>> dailyData = [];
      
      final allPayments = await database.select(database.paymentsTable).get();
      
      for (int i = 6; i >= 0; i--) {
        final date = now.subtract(Duration(days: i));
        final startOfDay = DateTime(date.year, date.month, date.day);
        final endOfDay = startOfDay.add(const Duration(days: 1));
        
        double totalAmount = 0;
        for (var payment in allPayments) {
          if ((payment.date.isAfter(startOfDay) || payment.date.isAtSameMomentAs(startOfDay)) &&
              payment.date.isBefore(endOfDay)) {
            totalAmount += payment.amount;
          }
        }
        
        dailyData.add({
          'day': dayNames[date.weekday % 7],
          'amount': totalAmount,
        });
      }
      
      return dailyData;
    } catch (e) {
      return [
        {'day': 'الاثنين', 'amount': 0},
        {'day': 'الثلاثاء', 'amount': 0},
        {'day': 'الأربعاء', 'amount': 0},
        {'day': 'الخميس', 'amount': 0},
        {'day': 'الجمعة', 'amount': 0},
        {'day': 'السبت', 'amount': 0},
        {'day': 'الأحد', 'amount': 0},
      ];
    }
  }

  // Get payment status distribution for pie chart
  Future<Map<String, int>> getPaymentStatusDistribution() async {
    try {
      final subscribers = await _subscribersService.getAllSubscribers();
      
      int paid = 0;
      int partial = 0;
      int unpaid = 0;
      
      for (var subscriber in subscribers) {
        if (subscriber.accumulatedDebt <= 0) {
          paid++;
        } else if (subscriber.accumulatedDebt < 50000) {
          partial++;
        } else {
          unpaid++;
        }
      }
      
      return {
        'paid': paid,
        'partial': partial,
        'unpaid': unpaid,
      };
    } catch (e) {
      return {'paid': 0, 'partial': 0, 'unpaid': 0};
    }
  }

  // Get cabinets with progress
  Future<List<Map<String, dynamic>>> getCabinetsWithProgress() async {
    try {
      final cabinets = await _cabinetsService.getAllCabinets();
      
      return cabinets.take(5).map((cabinet) {
        double progress = cabinet.totalSubscribers > 0 
            ? cabinet.currentSubscribers / cabinet.totalSubscribers 
            : 0.0;
        
        return {
          'name': cabinet.name,
          'current': cabinet.currentSubscribers,
          'total': cabinet.totalSubscribers,
          'progress': progress,
        };
      }).toList();
    } catch (e) {
      return [];
    }
  }

  // Get total collected all time
  Future<double> getTotalCollectedAmount() async {
    try {
      final payments = await database.select(database.paymentsTable).get();
      
      double total = 0;
      for (var payment in payments) {
        total += payment.amount;
      }
      return total;
    } catch (e) {
      return 0.0;
    }
  }

  // Get alerts (subscribers with high debt)
  Future<List<Map<String, dynamic>>> getAlerts() async {
    try {
      final subscribers = await _subscribersService.getAllSubscribers();
      
      List<Map<String, dynamic>> alerts = [];
      
      for (var subscriber in subscribers) {
        if (subscriber.accumulatedDebt > 100000) {
          alerts.add({
            'type': 'high_debt',
            'title': 'مديونية عالية',
            'message': '${subscriber.name} owes ${subscriber.accumulatedDebt.toStringAsFixed(0)} IQD',
            'subscriber': subscriber.name,
            'severity': 'danger',
          });
        } else if (subscriber.accumulatedDebt > 50000) {
          alerts.add({
            'type': 'medium_debt',
            'title': 'مديونية متوسطة',
            'message': '${subscriber.name} owes ${subscriber.accumulatedDebt.toStringAsFixed(0)} IQD',
            'subscriber': subscriber.name,
            'severity': 'warning',
          });
        }
      }
      
      return alerts.take(5).toList();
    } catch (e) {
      return [];
    }
  }
}