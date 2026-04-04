import 'dart:convert';

class WorkerPermissions {
  final bool canViewSubscribers;
  final bool canEditSubscribers;
  final bool canDeleteSubscribers;
  final bool canViewPayments;
  final bool canRecordPayments;
  final bool canDeletePayments;
  final bool canManageSettings;

  const WorkerPermissions({
    this.canViewSubscribers = false,
    this.canEditSubscribers = false,
    this.canDeleteSubscribers = false,
    this.canViewPayments = false,
    this.canRecordPayments = false,
    this.canDeletePayments = false,
    this.canManageSettings = false,
  });

  factory WorkerPermissions.fromJson(Map<String, dynamic> json) {
    return WorkerPermissions(
      canViewSubscribers: json['canViewSubscribers'] ?? false,
      canEditSubscribers: json['canEditSubscribers'] ?? false,
      canDeleteSubscribers: json['canDeleteSubscribers'] ?? false,
      canViewPayments: json['canViewPayments'] ?? false,
      canRecordPayments: json['canRecordPayments'] ?? false,
      canDeletePayments: json['canDeletePayments'] ?? false,
      canManageSettings: json['canManageSettings'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'canViewSubscribers': canViewSubscribers,
        'canEditSubscribers': canEditSubscribers,
        'canDeleteSubscribers': canDeleteSubscribers,
        'canViewPayments': canViewPayments,
        'canRecordPayments': canRecordPayments,
        'canDeletePayments': canDeletePayments,
        'canManageSettings': canManageSettings,
      };

  factory WorkerPermissions.admin() => const WorkerPermissions(
        canViewSubscribers: true,
        canEditSubscribers: true,
        canDeleteSubscribers: true,
        canViewPayments: true,
        canRecordPayments: true,
        canDeletePayments: true,
        canManageSettings: true,
      );

  factory WorkerPermissions.collector() => const WorkerPermissions(
        canViewSubscribers: true,
        canEditSubscribers: false,
        canDeleteSubscribers: false,
        canViewPayments: true,
        canRecordPayments: true,
        canDeletePayments: false,
        canManageSettings: false,
      );
}
