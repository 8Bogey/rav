// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $SubscribersTableTable extends SubscribersTable
    with TableInfo<$SubscribersTableTable, Subscriber> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SubscribersTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
      'code', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _cabinetMeta =
      const VerificationMeta('cabinet');
  @override
  late final GeneratedColumn<String> cabinet = GeneratedColumn<String>(
      'cabinet', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
      'phone', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<int> status = GeneratedColumn<int>(
      'status', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _startDateMeta =
      const VerificationMeta('startDate');
  @override
  late final GeneratedColumn<DateTime> startDate = GeneratedColumn<DateTime>(
      'start_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _accumulatedDebtMeta =
      const VerificationMeta('accumulatedDebt');
  @override
  late final GeneratedColumn<double> accumulatedDebt = GeneratedColumn<double>(
      'accumulated_debt', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _tagsMeta = const VerificationMeta('tags');
  @override
  late final GeneratedColumn<String> tags = GeneratedColumn<String>(
      'tags', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _lastModifiedMeta =
      const VerificationMeta('lastModified');
  @override
  late final GeneratedColumn<DateTime> lastModified = GeneratedColumn<DateTime>(
      'last_modified', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _lastSyncedAtMeta =
      const VerificationMeta('lastSyncedAt');
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
      'last_synced_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('local_only'));
  static const VerificationMeta _dirtyFlagMeta =
      const VerificationMeta('dirtyFlag');
  @override
  late final GeneratedColumn<bool> dirtyFlag = GeneratedColumn<bool>(
      'dirty_flag', aliasedName, true,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("dirty_flag" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _cloudIdMeta =
      const VerificationMeta('cloudId');
  @override
  late final GeneratedColumn<String> cloudId = GeneratedColumn<String>(
      'cloud_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _deletedLocallyMeta =
      const VerificationMeta('deletedLocally');
  @override
  late final GeneratedColumn<bool> deletedLocally = GeneratedColumn<bool>(
      'deleted_locally', aliasedName, true,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("deleted_locally" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _permissionsMaskMeta =
      const VerificationMeta('permissionsMask');
  @override
  late final GeneratedColumn<String> permissionsMask = GeneratedColumn<String>(
      'permissions_mask', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _ownerIdMeta =
      const VerificationMeta('ownerId');
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
      'owner_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _versionMeta =
      const VerificationMeta('version');
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
      'version', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _isDeletedMeta =
      const VerificationMeta('isDeleted');
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
      'is_deleted', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_deleted" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        code,
        cabinet,
        phone,
        status,
        startDate,
        accumulatedDebt,
        tags,
        notes,
        lastModified,
        lastSyncedAt,
        syncStatus,
        dirtyFlag,
        cloudId,
        deletedLocally,
        permissionsMask,
        ownerId,
        version,
        isDeleted,
        updatedAt,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'subscribers_table';
  @override
  VerificationContext validateIntegrity(Insertable<Subscriber> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('code')) {
      context.handle(
          _codeMeta, code.isAcceptableOrUnknown(data['code']!, _codeMeta));
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('cabinet')) {
      context.handle(_cabinetMeta,
          cabinet.isAcceptableOrUnknown(data['cabinet']!, _cabinetMeta));
    } else if (isInserting) {
      context.missing(_cabinetMeta);
    }
    if (data.containsKey('phone')) {
      context.handle(
          _phoneMeta, phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta));
    } else if (isInserting) {
      context.missing(_phoneMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('start_date')) {
      context.handle(_startDateMeta,
          startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta));
    } else if (isInserting) {
      context.missing(_startDateMeta);
    }
    if (data.containsKey('accumulated_debt')) {
      context.handle(
          _accumulatedDebtMeta,
          accumulatedDebt.isAcceptableOrUnknown(
              data['accumulated_debt']!, _accumulatedDebtMeta));
    }
    if (data.containsKey('tags')) {
      context.handle(
          _tagsMeta, tags.isAcceptableOrUnknown(data['tags']!, _tagsMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('last_modified')) {
      context.handle(
          _lastModifiedMeta,
          lastModified.isAcceptableOrUnknown(
              data['last_modified']!, _lastModifiedMeta));
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
          _lastSyncedAtMeta,
          lastSyncedAt.isAcceptableOrUnknown(
              data['last_synced_at']!, _lastSyncedAtMeta));
    }
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
    }
    if (data.containsKey('dirty_flag')) {
      context.handle(_dirtyFlagMeta,
          dirtyFlag.isAcceptableOrUnknown(data['dirty_flag']!, _dirtyFlagMeta));
    }
    if (data.containsKey('cloud_id')) {
      context.handle(_cloudIdMeta,
          cloudId.isAcceptableOrUnknown(data['cloud_id']!, _cloudIdMeta));
    }
    if (data.containsKey('deleted_locally')) {
      context.handle(
          _deletedLocallyMeta,
          deletedLocally.isAcceptableOrUnknown(
              data['deleted_locally']!, _deletedLocallyMeta));
    }
    if (data.containsKey('permissions_mask')) {
      context.handle(
          _permissionsMaskMeta,
          permissionsMask.isAcceptableOrUnknown(
              data['permissions_mask']!, _permissionsMaskMeta));
    }
    if (data.containsKey('owner_id')) {
      context.handle(_ownerIdMeta,
          ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta));
    }
    if (data.containsKey('version')) {
      context.handle(_versionMeta,
          version.isAcceptableOrUnknown(data['version']!, _versionMeta));
    }
    if (data.containsKey('is_deleted')) {
      context.handle(_isDeletedMeta,
          isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Subscriber map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Subscriber(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      code: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}code'])!,
      cabinet: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}cabinet'])!,
      phone: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}phone'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}status'])!,
      startDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}start_date'])!,
      accumulatedDebt: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}accumulated_debt'])!,
      tags: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tags']),
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      lastModified: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}last_modified']),
      lastSyncedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_synced_at']),
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status']),
      dirtyFlag: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}dirty_flag']),
      cloudId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}cloud_id']),
      deletedLocally: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}deleted_locally']),
      permissionsMask: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}permissions_mask']),
      ownerId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}owner_id']),
      version: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}version'])!,
      isDeleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_deleted'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at']),
    );
  }

  @override
  $SubscribersTableTable createAlias(String alias) {
    return $SubscribersTableTable(attachedDatabase, alias);
  }
}

class Subscriber extends DataClass implements Insertable<Subscriber> {
  final String id;
  final String name;
  final String code;
  final String cabinet;
  final String phone;
  final int status;
  final DateTime startDate;
  final double accumulatedDebt;
  final String? tags;
  final String? notes;
  final DateTime? lastModified;
  final DateTime? lastSyncedAt;
  final String? syncStatus;
  final bool? dirtyFlag;
  final String? cloudId;
  final bool? deletedLocally;
  final String? permissionsMask;
  final String? ownerId;
  final int version;
  final bool isDeleted;
  final DateTime? updatedAt;
  final DateTime? createdAt;
  const Subscriber(
      {required this.id,
      required this.name,
      required this.code,
      required this.cabinet,
      required this.phone,
      required this.status,
      required this.startDate,
      required this.accumulatedDebt,
      this.tags,
      this.notes,
      this.lastModified,
      this.lastSyncedAt,
      this.syncStatus,
      this.dirtyFlag,
      this.cloudId,
      this.deletedLocally,
      this.permissionsMask,
      this.ownerId,
      required this.version,
      required this.isDeleted,
      this.updatedAt,
      this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['code'] = Variable<String>(code);
    map['cabinet'] = Variable<String>(cabinet);
    map['phone'] = Variable<String>(phone);
    map['status'] = Variable<int>(status);
    map['start_date'] = Variable<DateTime>(startDate);
    map['accumulated_debt'] = Variable<double>(accumulatedDebt);
    if (!nullToAbsent || tags != null) {
      map['tags'] = Variable<String>(tags);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || lastModified != null) {
      map['last_modified'] = Variable<DateTime>(lastModified);
    }
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    }
    if (!nullToAbsent || syncStatus != null) {
      map['sync_status'] = Variable<String>(syncStatus);
    }
    if (!nullToAbsent || dirtyFlag != null) {
      map['dirty_flag'] = Variable<bool>(dirtyFlag);
    }
    if (!nullToAbsent || cloudId != null) {
      map['cloud_id'] = Variable<String>(cloudId);
    }
    if (!nullToAbsent || deletedLocally != null) {
      map['deleted_locally'] = Variable<bool>(deletedLocally);
    }
    if (!nullToAbsent || permissionsMask != null) {
      map['permissions_mask'] = Variable<String>(permissionsMask);
    }
    if (!nullToAbsent || ownerId != null) {
      map['owner_id'] = Variable<String>(ownerId);
    }
    map['version'] = Variable<int>(version);
    map['is_deleted'] = Variable<bool>(isDeleted);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<DateTime>(createdAt);
    }
    return map;
  }

  SubscribersTableCompanion toCompanion(bool nullToAbsent) {
    return SubscribersTableCompanion(
      id: Value(id),
      name: Value(name),
      code: Value(code),
      cabinet: Value(cabinet),
      phone: Value(phone),
      status: Value(status),
      startDate: Value(startDate),
      accumulatedDebt: Value(accumulatedDebt),
      tags: tags == null && nullToAbsent ? const Value.absent() : Value(tags),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      lastModified: lastModified == null && nullToAbsent
          ? const Value.absent()
          : Value(lastModified),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
      syncStatus: syncStatus == null && nullToAbsent
          ? const Value.absent()
          : Value(syncStatus),
      dirtyFlag: dirtyFlag == null && nullToAbsent
          ? const Value.absent()
          : Value(dirtyFlag),
      cloudId: cloudId == null && nullToAbsent
          ? const Value.absent()
          : Value(cloudId),
      deletedLocally: deletedLocally == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedLocally),
      permissionsMask: permissionsMask == null && nullToAbsent
          ? const Value.absent()
          : Value(permissionsMask),
      ownerId: ownerId == null && nullToAbsent
          ? const Value.absent()
          : Value(ownerId),
      version: Value(version),
      isDeleted: Value(isDeleted),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
    );
  }

  factory Subscriber.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Subscriber(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      code: serializer.fromJson<String>(json['code']),
      cabinet: serializer.fromJson<String>(json['cabinet']),
      phone: serializer.fromJson<String>(json['phone']),
      status: serializer.fromJson<int>(json['status']),
      startDate: serializer.fromJson<DateTime>(json['startDate']),
      accumulatedDebt: serializer.fromJson<double>(json['accumulatedDebt']),
      tags: serializer.fromJson<String?>(json['tags']),
      notes: serializer.fromJson<String?>(json['notes']),
      lastModified: serializer.fromJson<DateTime?>(json['lastModified']),
      lastSyncedAt: serializer.fromJson<DateTime?>(json['lastSyncedAt']),
      syncStatus: serializer.fromJson<String?>(json['syncStatus']),
      dirtyFlag: serializer.fromJson<bool?>(json['dirtyFlag']),
      cloudId: serializer.fromJson<String?>(json['cloudId']),
      deletedLocally: serializer.fromJson<bool?>(json['deletedLocally']),
      permissionsMask: serializer.fromJson<String?>(json['permissionsMask']),
      ownerId: serializer.fromJson<String?>(json['ownerId']),
      version: serializer.fromJson<int>(json['version']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      createdAt: serializer.fromJson<DateTime?>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'code': serializer.toJson<String>(code),
      'cabinet': serializer.toJson<String>(cabinet),
      'phone': serializer.toJson<String>(phone),
      'status': serializer.toJson<int>(status),
      'startDate': serializer.toJson<DateTime>(startDate),
      'accumulatedDebt': serializer.toJson<double>(accumulatedDebt),
      'tags': serializer.toJson<String?>(tags),
      'notes': serializer.toJson<String?>(notes),
      'lastModified': serializer.toJson<DateTime?>(lastModified),
      'lastSyncedAt': serializer.toJson<DateTime?>(lastSyncedAt),
      'syncStatus': serializer.toJson<String?>(syncStatus),
      'dirtyFlag': serializer.toJson<bool?>(dirtyFlag),
      'cloudId': serializer.toJson<String?>(cloudId),
      'deletedLocally': serializer.toJson<bool?>(deletedLocally),
      'permissionsMask': serializer.toJson<String?>(permissionsMask),
      'ownerId': serializer.toJson<String?>(ownerId),
      'version': serializer.toJson<int>(version),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'createdAt': serializer.toJson<DateTime?>(createdAt),
    };
  }

  Subscriber copyWith(
          {String? id,
          String? name,
          String? code,
          String? cabinet,
          String? phone,
          int? status,
          DateTime? startDate,
          double? accumulatedDebt,
          Value<String?> tags = const Value.absent(),
          Value<String?> notes = const Value.absent(),
          Value<DateTime?> lastModified = const Value.absent(),
          Value<DateTime?> lastSyncedAt = const Value.absent(),
          Value<String?> syncStatus = const Value.absent(),
          Value<bool?> dirtyFlag = const Value.absent(),
          Value<String?> cloudId = const Value.absent(),
          Value<bool?> deletedLocally = const Value.absent(),
          Value<String?> permissionsMask = const Value.absent(),
          Value<String?> ownerId = const Value.absent(),
          int? version,
          bool? isDeleted,
          Value<DateTime?> updatedAt = const Value.absent(),
          Value<DateTime?> createdAt = const Value.absent()}) =>
      Subscriber(
        id: id ?? this.id,
        name: name ?? this.name,
        code: code ?? this.code,
        cabinet: cabinet ?? this.cabinet,
        phone: phone ?? this.phone,
        status: status ?? this.status,
        startDate: startDate ?? this.startDate,
        accumulatedDebt: accumulatedDebt ?? this.accumulatedDebt,
        tags: tags.present ? tags.value : this.tags,
        notes: notes.present ? notes.value : this.notes,
        lastModified:
            lastModified.present ? lastModified.value : this.lastModified,
        lastSyncedAt:
            lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
        syncStatus: syncStatus.present ? syncStatus.value : this.syncStatus,
        dirtyFlag: dirtyFlag.present ? dirtyFlag.value : this.dirtyFlag,
        cloudId: cloudId.present ? cloudId.value : this.cloudId,
        deletedLocally:
            deletedLocally.present ? deletedLocally.value : this.deletedLocally,
        permissionsMask: permissionsMask.present
            ? permissionsMask.value
            : this.permissionsMask,
        ownerId: ownerId.present ? ownerId.value : this.ownerId,
        version: version ?? this.version,
        isDeleted: isDeleted ?? this.isDeleted,
        updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
        createdAt: createdAt.present ? createdAt.value : this.createdAt,
      );
  Subscriber copyWithCompanion(SubscribersTableCompanion data) {
    return Subscriber(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      code: data.code.present ? data.code.value : this.code,
      cabinet: data.cabinet.present ? data.cabinet.value : this.cabinet,
      phone: data.phone.present ? data.phone.value : this.phone,
      status: data.status.present ? data.status.value : this.status,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      accumulatedDebt: data.accumulatedDebt.present
          ? data.accumulatedDebt.value
          : this.accumulatedDebt,
      tags: data.tags.present ? data.tags.value : this.tags,
      notes: data.notes.present ? data.notes.value : this.notes,
      lastModified: data.lastModified.present
          ? data.lastModified.value
          : this.lastModified,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
      dirtyFlag: data.dirtyFlag.present ? data.dirtyFlag.value : this.dirtyFlag,
      cloudId: data.cloudId.present ? data.cloudId.value : this.cloudId,
      deletedLocally: data.deletedLocally.present
          ? data.deletedLocally.value
          : this.deletedLocally,
      permissionsMask: data.permissionsMask.present
          ? data.permissionsMask.value
          : this.permissionsMask,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      version: data.version.present ? data.version.value : this.version,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Subscriber(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('code: $code, ')
          ..write('cabinet: $cabinet, ')
          ..write('phone: $phone, ')
          ..write('status: $status, ')
          ..write('startDate: $startDate, ')
          ..write('accumulatedDebt: $accumulatedDebt, ')
          ..write('tags: $tags, ')
          ..write('notes: $notes, ')
          ..write('lastModified: $lastModified, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('dirtyFlag: $dirtyFlag, ')
          ..write('cloudId: $cloudId, ')
          ..write('deletedLocally: $deletedLocally, ')
          ..write('permissionsMask: $permissionsMask, ')
          ..write('ownerId: $ownerId, ')
          ..write('version: $version, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
        id,
        name,
        code,
        cabinet,
        phone,
        status,
        startDate,
        accumulatedDebt,
        tags,
        notes,
        lastModified,
        lastSyncedAt,
        syncStatus,
        dirtyFlag,
        cloudId,
        deletedLocally,
        permissionsMask,
        ownerId,
        version,
        isDeleted,
        updatedAt,
        createdAt
      ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Subscriber &&
          other.id == this.id &&
          other.name == this.name &&
          other.code == this.code &&
          other.cabinet == this.cabinet &&
          other.phone == this.phone &&
          other.status == this.status &&
          other.startDate == this.startDate &&
          other.accumulatedDebt == this.accumulatedDebt &&
          other.tags == this.tags &&
          other.notes == this.notes &&
          other.lastModified == this.lastModified &&
          other.lastSyncedAt == this.lastSyncedAt &&
          other.syncStatus == this.syncStatus &&
          other.dirtyFlag == this.dirtyFlag &&
          other.cloudId == this.cloudId &&
          other.deletedLocally == this.deletedLocally &&
          other.permissionsMask == this.permissionsMask &&
          other.ownerId == this.ownerId &&
          other.version == this.version &&
          other.isDeleted == this.isDeleted &&
          other.updatedAt == this.updatedAt &&
          other.createdAt == this.createdAt);
}

class SubscribersTableCompanion extends UpdateCompanion<Subscriber> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> code;
  final Value<String> cabinet;
  final Value<String> phone;
  final Value<int> status;
  final Value<DateTime> startDate;
  final Value<double> accumulatedDebt;
  final Value<String?> tags;
  final Value<String?> notes;
  final Value<DateTime?> lastModified;
  final Value<DateTime?> lastSyncedAt;
  final Value<String?> syncStatus;
  final Value<bool?> dirtyFlag;
  final Value<String?> cloudId;
  final Value<bool?> deletedLocally;
  final Value<String?> permissionsMask;
  final Value<String?> ownerId;
  final Value<int> version;
  final Value<bool> isDeleted;
  final Value<DateTime?> updatedAt;
  final Value<DateTime?> createdAt;
  final Value<int> rowid;
  const SubscribersTableCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.code = const Value.absent(),
    this.cabinet = const Value.absent(),
    this.phone = const Value.absent(),
    this.status = const Value.absent(),
    this.startDate = const Value.absent(),
    this.accumulatedDebt = const Value.absent(),
    this.tags = const Value.absent(),
    this.notes = const Value.absent(),
    this.lastModified = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.dirtyFlag = const Value.absent(),
    this.cloudId = const Value.absent(),
    this.deletedLocally = const Value.absent(),
    this.permissionsMask = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.version = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SubscribersTableCompanion.insert({
    required String id,
    required String name,
    required String code,
    required String cabinet,
    required String phone,
    required int status,
    required DateTime startDate,
    this.accumulatedDebt = const Value.absent(),
    this.tags = const Value.absent(),
    this.notes = const Value.absent(),
    this.lastModified = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.dirtyFlag = const Value.absent(),
    this.cloudId = const Value.absent(),
    this.deletedLocally = const Value.absent(),
    this.permissionsMask = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.version = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        code = Value(code),
        cabinet = Value(cabinet),
        phone = Value(phone),
        status = Value(status),
        startDate = Value(startDate);
  static Insertable<Subscriber> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? code,
    Expression<String>? cabinet,
    Expression<String>? phone,
    Expression<int>? status,
    Expression<DateTime>? startDate,
    Expression<double>? accumulatedDebt,
    Expression<String>? tags,
    Expression<String>? notes,
    Expression<DateTime>? lastModified,
    Expression<DateTime>? lastSyncedAt,
    Expression<String>? syncStatus,
    Expression<bool>? dirtyFlag,
    Expression<String>? cloudId,
    Expression<bool>? deletedLocally,
    Expression<String>? permissionsMask,
    Expression<String>? ownerId,
    Expression<int>? version,
    Expression<bool>? isDeleted,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (code != null) 'code': code,
      if (cabinet != null) 'cabinet': cabinet,
      if (phone != null) 'phone': phone,
      if (status != null) 'status': status,
      if (startDate != null) 'start_date': startDate,
      if (accumulatedDebt != null) 'accumulated_debt': accumulatedDebt,
      if (tags != null) 'tags': tags,
      if (notes != null) 'notes': notes,
      if (lastModified != null) 'last_modified': lastModified,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (dirtyFlag != null) 'dirty_flag': dirtyFlag,
      if (cloudId != null) 'cloud_id': cloudId,
      if (deletedLocally != null) 'deleted_locally': deletedLocally,
      if (permissionsMask != null) 'permissions_mask': permissionsMask,
      if (ownerId != null) 'owner_id': ownerId,
      if (version != null) 'version': version,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SubscribersTableCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String>? code,
      Value<String>? cabinet,
      Value<String>? phone,
      Value<int>? status,
      Value<DateTime>? startDate,
      Value<double>? accumulatedDebt,
      Value<String?>? tags,
      Value<String?>? notes,
      Value<DateTime?>? lastModified,
      Value<DateTime?>? lastSyncedAt,
      Value<String?>? syncStatus,
      Value<bool?>? dirtyFlag,
      Value<String?>? cloudId,
      Value<bool?>? deletedLocally,
      Value<String?>? permissionsMask,
      Value<String?>? ownerId,
      Value<int>? version,
      Value<bool>? isDeleted,
      Value<DateTime?>? updatedAt,
      Value<DateTime?>? createdAt,
      Value<int>? rowid}) {
    return SubscribersTableCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      cabinet: cabinet ?? this.cabinet,
      phone: phone ?? this.phone,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      accumulatedDebt: accumulatedDebt ?? this.accumulatedDebt,
      tags: tags ?? this.tags,
      notes: notes ?? this.notes,
      lastModified: lastModified ?? this.lastModified,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      dirtyFlag: dirtyFlag ?? this.dirtyFlag,
      cloudId: cloudId ?? this.cloudId,
      deletedLocally: deletedLocally ?? this.deletedLocally,
      permissionsMask: permissionsMask ?? this.permissionsMask,
      ownerId: ownerId ?? this.ownerId,
      version: version ?? this.version,
      isDeleted: isDeleted ?? this.isDeleted,
      updatedAt: updatedAt ?? this.updatedAt,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (cabinet.present) {
      map['cabinet'] = Variable<String>(cabinet.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (status.present) {
      map['status'] = Variable<int>(status.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<DateTime>(startDate.value);
    }
    if (accumulatedDebt.present) {
      map['accumulated_debt'] = Variable<double>(accumulatedDebt.value);
    }
    if (tags.present) {
      map['tags'] = Variable<String>(tags.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (lastModified.present) {
      map['last_modified'] = Variable<DateTime>(lastModified.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (dirtyFlag.present) {
      map['dirty_flag'] = Variable<bool>(dirtyFlag.value);
    }
    if (cloudId.present) {
      map['cloud_id'] = Variable<String>(cloudId.value);
    }
    if (deletedLocally.present) {
      map['deleted_locally'] = Variable<bool>(deletedLocally.value);
    }
    if (permissionsMask.present) {
      map['permissions_mask'] = Variable<String>(permissionsMask.value);
    }
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SubscribersTableCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('code: $code, ')
          ..write('cabinet: $cabinet, ')
          ..write('phone: $phone, ')
          ..write('status: $status, ')
          ..write('startDate: $startDate, ')
          ..write('accumulatedDebt: $accumulatedDebt, ')
          ..write('tags: $tags, ')
          ..write('notes: $notes, ')
          ..write('lastModified: $lastModified, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('dirtyFlag: $dirtyFlag, ')
          ..write('cloudId: $cloudId, ')
          ..write('deletedLocally: $deletedLocally, ')
          ..write('permissionsMask: $permissionsMask, ')
          ..write('ownerId: $ownerId, ')
          ..write('version: $version, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CabinetsTableTable extends CabinetsTable
    with TableInfo<$CabinetsTableTable, Cabinet> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CabinetsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _letterMeta = const VerificationMeta('letter');
  @override
  late final GeneratedColumn<String> letter = GeneratedColumn<String>(
      'letter', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _totalSubscribersMeta =
      const VerificationMeta('totalSubscribers');
  @override
  late final GeneratedColumn<int> totalSubscribers = GeneratedColumn<int>(
      'total_subscribers', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _currentSubscribersMeta =
      const VerificationMeta('currentSubscribers');
  @override
  late final GeneratedColumn<int> currentSubscribers = GeneratedColumn<int>(
      'current_subscribers', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _collectedAmountMeta =
      const VerificationMeta('collectedAmount');
  @override
  late final GeneratedColumn<double> collectedAmount = GeneratedColumn<double>(
      'collected_amount', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _delayedSubscribersMeta =
      const VerificationMeta('delayedSubscribers');
  @override
  late final GeneratedColumn<int> delayedSubscribers = GeneratedColumn<int>(
      'delayed_subscribers', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _completionDateMeta =
      const VerificationMeta('completionDate');
  @override
  late final GeneratedColumn<DateTime> completionDate =
      GeneratedColumn<DateTime>('completion_date', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _lastModifiedMeta =
      const VerificationMeta('lastModified');
  @override
  late final GeneratedColumn<DateTime> lastModified = GeneratedColumn<DateTime>(
      'last_modified', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _lastSyncedAtMeta =
      const VerificationMeta('lastSyncedAt');
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
      'last_synced_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('local_only'));
  static const VerificationMeta _dirtyFlagMeta =
      const VerificationMeta('dirtyFlag');
  @override
  late final GeneratedColumn<bool> dirtyFlag = GeneratedColumn<bool>(
      'dirty_flag', aliasedName, true,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("dirty_flag" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _cloudIdMeta =
      const VerificationMeta('cloudId');
  @override
  late final GeneratedColumn<String> cloudId = GeneratedColumn<String>(
      'cloud_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _deletedLocallyMeta =
      const VerificationMeta('deletedLocally');
  @override
  late final GeneratedColumn<bool> deletedLocally = GeneratedColumn<bool>(
      'deleted_locally', aliasedName, true,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("deleted_locally" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _permissionsMaskMeta =
      const VerificationMeta('permissionsMask');
  @override
  late final GeneratedColumn<String> permissionsMask = GeneratedColumn<String>(
      'permissions_mask', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _ownerIdMeta =
      const VerificationMeta('ownerId');
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
      'owner_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _versionMeta =
      const VerificationMeta('version');
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
      'version', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _isDeletedMeta =
      const VerificationMeta('isDeleted');
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
      'is_deleted', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_deleted" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        letter,
        totalSubscribers,
        currentSubscribers,
        collectedAmount,
        delayedSubscribers,
        completionDate,
        lastModified,
        lastSyncedAt,
        syncStatus,
        dirtyFlag,
        cloudId,
        deletedLocally,
        permissionsMask,
        ownerId,
        version,
        isDeleted,
        updatedAt,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cabinets_table';
  @override
  VerificationContext validateIntegrity(Insertable<Cabinet> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('letter')) {
      context.handle(_letterMeta,
          letter.isAcceptableOrUnknown(data['letter']!, _letterMeta));
    }
    if (data.containsKey('total_subscribers')) {
      context.handle(
          _totalSubscribersMeta,
          totalSubscribers.isAcceptableOrUnknown(
              data['total_subscribers']!, _totalSubscribersMeta));
    } else if (isInserting) {
      context.missing(_totalSubscribersMeta);
    }
    if (data.containsKey('current_subscribers')) {
      context.handle(
          _currentSubscribersMeta,
          currentSubscribers.isAcceptableOrUnknown(
              data['current_subscribers']!, _currentSubscribersMeta));
    } else if (isInserting) {
      context.missing(_currentSubscribersMeta);
    }
    if (data.containsKey('collected_amount')) {
      context.handle(
          _collectedAmountMeta,
          collectedAmount.isAcceptableOrUnknown(
              data['collected_amount']!, _collectedAmountMeta));
    }
    if (data.containsKey('delayed_subscribers')) {
      context.handle(
          _delayedSubscribersMeta,
          delayedSubscribers.isAcceptableOrUnknown(
              data['delayed_subscribers']!, _delayedSubscribersMeta));
    } else if (isInserting) {
      context.missing(_delayedSubscribersMeta);
    }
    if (data.containsKey('completion_date')) {
      context.handle(
          _completionDateMeta,
          completionDate.isAcceptableOrUnknown(
              data['completion_date']!, _completionDateMeta));
    }
    if (data.containsKey('last_modified')) {
      context.handle(
          _lastModifiedMeta,
          lastModified.isAcceptableOrUnknown(
              data['last_modified']!, _lastModifiedMeta));
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
          _lastSyncedAtMeta,
          lastSyncedAt.isAcceptableOrUnknown(
              data['last_synced_at']!, _lastSyncedAtMeta));
    }
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
    }
    if (data.containsKey('dirty_flag')) {
      context.handle(_dirtyFlagMeta,
          dirtyFlag.isAcceptableOrUnknown(data['dirty_flag']!, _dirtyFlagMeta));
    }
    if (data.containsKey('cloud_id')) {
      context.handle(_cloudIdMeta,
          cloudId.isAcceptableOrUnknown(data['cloud_id']!, _cloudIdMeta));
    }
    if (data.containsKey('deleted_locally')) {
      context.handle(
          _deletedLocallyMeta,
          deletedLocally.isAcceptableOrUnknown(
              data['deleted_locally']!, _deletedLocallyMeta));
    }
    if (data.containsKey('permissions_mask')) {
      context.handle(
          _permissionsMaskMeta,
          permissionsMask.isAcceptableOrUnknown(
              data['permissions_mask']!, _permissionsMaskMeta));
    }
    if (data.containsKey('owner_id')) {
      context.handle(_ownerIdMeta,
          ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta));
    }
    if (data.containsKey('version')) {
      context.handle(_versionMeta,
          version.isAcceptableOrUnknown(data['version']!, _versionMeta));
    }
    if (data.containsKey('is_deleted')) {
      context.handle(_isDeletedMeta,
          isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Cabinet map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Cabinet(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      letter: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}letter'])!,
      totalSubscribers: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}total_subscribers'])!,
      currentSubscribers: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}current_subscribers'])!,
      collectedAmount: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}collected_amount'])!,
      delayedSubscribers: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}delayed_subscribers'])!,
      completionDate: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}completion_date']),
      lastModified: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}last_modified']),
      lastSyncedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_synced_at']),
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status']),
      dirtyFlag: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}dirty_flag']),
      cloudId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}cloud_id']),
      deletedLocally: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}deleted_locally']),
      permissionsMask: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}permissions_mask']),
      ownerId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}owner_id']),
      version: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}version'])!,
      isDeleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_deleted'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at']),
    );
  }

  @override
  $CabinetsTableTable createAlias(String alias) {
    return $CabinetsTableTable(attachedDatabase, alias);
  }
}

class Cabinet extends DataClass implements Insertable<Cabinet> {
  final String id;
  final String name;
  final String letter;
  final int totalSubscribers;
  final int currentSubscribers;
  final double collectedAmount;
  final int delayedSubscribers;
  final DateTime? completionDate;
  final DateTime? lastModified;
  final DateTime? lastSyncedAt;
  final String? syncStatus;
  final bool? dirtyFlag;
  final String? cloudId;
  final bool? deletedLocally;
  final String? permissionsMask;
  final String? ownerId;
  final int version;
  final bool isDeleted;
  final DateTime? updatedAt;
  final DateTime? createdAt;
  const Cabinet(
      {required this.id,
      required this.name,
      required this.letter,
      required this.totalSubscribers,
      required this.currentSubscribers,
      required this.collectedAmount,
      required this.delayedSubscribers,
      this.completionDate,
      this.lastModified,
      this.lastSyncedAt,
      this.syncStatus,
      this.dirtyFlag,
      this.cloudId,
      this.deletedLocally,
      this.permissionsMask,
      this.ownerId,
      required this.version,
      required this.isDeleted,
      this.updatedAt,
      this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['letter'] = Variable<String>(letter);
    map['total_subscribers'] = Variable<int>(totalSubscribers);
    map['current_subscribers'] = Variable<int>(currentSubscribers);
    map['collected_amount'] = Variable<double>(collectedAmount);
    map['delayed_subscribers'] = Variable<int>(delayedSubscribers);
    if (!nullToAbsent || completionDate != null) {
      map['completion_date'] = Variable<DateTime>(completionDate);
    }
    if (!nullToAbsent || lastModified != null) {
      map['last_modified'] = Variable<DateTime>(lastModified);
    }
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    }
    if (!nullToAbsent || syncStatus != null) {
      map['sync_status'] = Variable<String>(syncStatus);
    }
    if (!nullToAbsent || dirtyFlag != null) {
      map['dirty_flag'] = Variable<bool>(dirtyFlag);
    }
    if (!nullToAbsent || cloudId != null) {
      map['cloud_id'] = Variable<String>(cloudId);
    }
    if (!nullToAbsent || deletedLocally != null) {
      map['deleted_locally'] = Variable<bool>(deletedLocally);
    }
    if (!nullToAbsent || permissionsMask != null) {
      map['permissions_mask'] = Variable<String>(permissionsMask);
    }
    if (!nullToAbsent || ownerId != null) {
      map['owner_id'] = Variable<String>(ownerId);
    }
    map['version'] = Variable<int>(version);
    map['is_deleted'] = Variable<bool>(isDeleted);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<DateTime>(createdAt);
    }
    return map;
  }

  CabinetsTableCompanion toCompanion(bool nullToAbsent) {
    return CabinetsTableCompanion(
      id: Value(id),
      name: Value(name),
      letter: Value(letter),
      totalSubscribers: Value(totalSubscribers),
      currentSubscribers: Value(currentSubscribers),
      collectedAmount: Value(collectedAmount),
      delayedSubscribers: Value(delayedSubscribers),
      completionDate: completionDate == null && nullToAbsent
          ? const Value.absent()
          : Value(completionDate),
      lastModified: lastModified == null && nullToAbsent
          ? const Value.absent()
          : Value(lastModified),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
      syncStatus: syncStatus == null && nullToAbsent
          ? const Value.absent()
          : Value(syncStatus),
      dirtyFlag: dirtyFlag == null && nullToAbsent
          ? const Value.absent()
          : Value(dirtyFlag),
      cloudId: cloudId == null && nullToAbsent
          ? const Value.absent()
          : Value(cloudId),
      deletedLocally: deletedLocally == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedLocally),
      permissionsMask: permissionsMask == null && nullToAbsent
          ? const Value.absent()
          : Value(permissionsMask),
      ownerId: ownerId == null && nullToAbsent
          ? const Value.absent()
          : Value(ownerId),
      version: Value(version),
      isDeleted: Value(isDeleted),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
    );
  }

  factory Cabinet.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Cabinet(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      letter: serializer.fromJson<String>(json['letter']),
      totalSubscribers: serializer.fromJson<int>(json['totalSubscribers']),
      currentSubscribers: serializer.fromJson<int>(json['currentSubscribers']),
      collectedAmount: serializer.fromJson<double>(json['collectedAmount']),
      delayedSubscribers: serializer.fromJson<int>(json['delayedSubscribers']),
      completionDate: serializer.fromJson<DateTime?>(json['completionDate']),
      lastModified: serializer.fromJson<DateTime?>(json['lastModified']),
      lastSyncedAt: serializer.fromJson<DateTime?>(json['lastSyncedAt']),
      syncStatus: serializer.fromJson<String?>(json['syncStatus']),
      dirtyFlag: serializer.fromJson<bool?>(json['dirtyFlag']),
      cloudId: serializer.fromJson<String?>(json['cloudId']),
      deletedLocally: serializer.fromJson<bool?>(json['deletedLocally']),
      permissionsMask: serializer.fromJson<String?>(json['permissionsMask']),
      ownerId: serializer.fromJson<String?>(json['ownerId']),
      version: serializer.fromJson<int>(json['version']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      createdAt: serializer.fromJson<DateTime?>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'letter': serializer.toJson<String>(letter),
      'totalSubscribers': serializer.toJson<int>(totalSubscribers),
      'currentSubscribers': serializer.toJson<int>(currentSubscribers),
      'collectedAmount': serializer.toJson<double>(collectedAmount),
      'delayedSubscribers': serializer.toJson<int>(delayedSubscribers),
      'completionDate': serializer.toJson<DateTime?>(completionDate),
      'lastModified': serializer.toJson<DateTime?>(lastModified),
      'lastSyncedAt': serializer.toJson<DateTime?>(lastSyncedAt),
      'syncStatus': serializer.toJson<String?>(syncStatus),
      'dirtyFlag': serializer.toJson<bool?>(dirtyFlag),
      'cloudId': serializer.toJson<String?>(cloudId),
      'deletedLocally': serializer.toJson<bool?>(deletedLocally),
      'permissionsMask': serializer.toJson<String?>(permissionsMask),
      'ownerId': serializer.toJson<String?>(ownerId),
      'version': serializer.toJson<int>(version),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'createdAt': serializer.toJson<DateTime?>(createdAt),
    };
  }

  Cabinet copyWith(
          {String? id,
          String? name,
          String? letter,
          int? totalSubscribers,
          int? currentSubscribers,
          double? collectedAmount,
          int? delayedSubscribers,
          Value<DateTime?> completionDate = const Value.absent(),
          Value<DateTime?> lastModified = const Value.absent(),
          Value<DateTime?> lastSyncedAt = const Value.absent(),
          Value<String?> syncStatus = const Value.absent(),
          Value<bool?> dirtyFlag = const Value.absent(),
          Value<String?> cloudId = const Value.absent(),
          Value<bool?> deletedLocally = const Value.absent(),
          Value<String?> permissionsMask = const Value.absent(),
          Value<String?> ownerId = const Value.absent(),
          int? version,
          bool? isDeleted,
          Value<DateTime?> updatedAt = const Value.absent(),
          Value<DateTime?> createdAt = const Value.absent()}) =>
      Cabinet(
        id: id ?? this.id,
        name: name ?? this.name,
        letter: letter ?? this.letter,
        totalSubscribers: totalSubscribers ?? this.totalSubscribers,
        currentSubscribers: currentSubscribers ?? this.currentSubscribers,
        collectedAmount: collectedAmount ?? this.collectedAmount,
        delayedSubscribers: delayedSubscribers ?? this.delayedSubscribers,
        completionDate:
            completionDate.present ? completionDate.value : this.completionDate,
        lastModified:
            lastModified.present ? lastModified.value : this.lastModified,
        lastSyncedAt:
            lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
        syncStatus: syncStatus.present ? syncStatus.value : this.syncStatus,
        dirtyFlag: dirtyFlag.present ? dirtyFlag.value : this.dirtyFlag,
        cloudId: cloudId.present ? cloudId.value : this.cloudId,
        deletedLocally:
            deletedLocally.present ? deletedLocally.value : this.deletedLocally,
        permissionsMask: permissionsMask.present
            ? permissionsMask.value
            : this.permissionsMask,
        ownerId: ownerId.present ? ownerId.value : this.ownerId,
        version: version ?? this.version,
        isDeleted: isDeleted ?? this.isDeleted,
        updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
        createdAt: createdAt.present ? createdAt.value : this.createdAt,
      );
  Cabinet copyWithCompanion(CabinetsTableCompanion data) {
    return Cabinet(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      letter: data.letter.present ? data.letter.value : this.letter,
      totalSubscribers: data.totalSubscribers.present
          ? data.totalSubscribers.value
          : this.totalSubscribers,
      currentSubscribers: data.currentSubscribers.present
          ? data.currentSubscribers.value
          : this.currentSubscribers,
      collectedAmount: data.collectedAmount.present
          ? data.collectedAmount.value
          : this.collectedAmount,
      delayedSubscribers: data.delayedSubscribers.present
          ? data.delayedSubscribers.value
          : this.delayedSubscribers,
      completionDate: data.completionDate.present
          ? data.completionDate.value
          : this.completionDate,
      lastModified: data.lastModified.present
          ? data.lastModified.value
          : this.lastModified,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
      dirtyFlag: data.dirtyFlag.present ? data.dirtyFlag.value : this.dirtyFlag,
      cloudId: data.cloudId.present ? data.cloudId.value : this.cloudId,
      deletedLocally: data.deletedLocally.present
          ? data.deletedLocally.value
          : this.deletedLocally,
      permissionsMask: data.permissionsMask.present
          ? data.permissionsMask.value
          : this.permissionsMask,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      version: data.version.present ? data.version.value : this.version,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Cabinet(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('letter: $letter, ')
          ..write('totalSubscribers: $totalSubscribers, ')
          ..write('currentSubscribers: $currentSubscribers, ')
          ..write('collectedAmount: $collectedAmount, ')
          ..write('delayedSubscribers: $delayedSubscribers, ')
          ..write('completionDate: $completionDate, ')
          ..write('lastModified: $lastModified, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('dirtyFlag: $dirtyFlag, ')
          ..write('cloudId: $cloudId, ')
          ..write('deletedLocally: $deletedLocally, ')
          ..write('permissionsMask: $permissionsMask, ')
          ..write('ownerId: $ownerId, ')
          ..write('version: $version, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      name,
      letter,
      totalSubscribers,
      currentSubscribers,
      collectedAmount,
      delayedSubscribers,
      completionDate,
      lastModified,
      lastSyncedAt,
      syncStatus,
      dirtyFlag,
      cloudId,
      deletedLocally,
      permissionsMask,
      ownerId,
      version,
      isDeleted,
      updatedAt,
      createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Cabinet &&
          other.id == this.id &&
          other.name == this.name &&
          other.letter == this.letter &&
          other.totalSubscribers == this.totalSubscribers &&
          other.currentSubscribers == this.currentSubscribers &&
          other.collectedAmount == this.collectedAmount &&
          other.delayedSubscribers == this.delayedSubscribers &&
          other.completionDate == this.completionDate &&
          other.lastModified == this.lastModified &&
          other.lastSyncedAt == this.lastSyncedAt &&
          other.syncStatus == this.syncStatus &&
          other.dirtyFlag == this.dirtyFlag &&
          other.cloudId == this.cloudId &&
          other.deletedLocally == this.deletedLocally &&
          other.permissionsMask == this.permissionsMask &&
          other.ownerId == this.ownerId &&
          other.version == this.version &&
          other.isDeleted == this.isDeleted &&
          other.updatedAt == this.updatedAt &&
          other.createdAt == this.createdAt);
}

class CabinetsTableCompanion extends UpdateCompanion<Cabinet> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> letter;
  final Value<int> totalSubscribers;
  final Value<int> currentSubscribers;
  final Value<double> collectedAmount;
  final Value<int> delayedSubscribers;
  final Value<DateTime?> completionDate;
  final Value<DateTime?> lastModified;
  final Value<DateTime?> lastSyncedAt;
  final Value<String?> syncStatus;
  final Value<bool?> dirtyFlag;
  final Value<String?> cloudId;
  final Value<bool?> deletedLocally;
  final Value<String?> permissionsMask;
  final Value<String?> ownerId;
  final Value<int> version;
  final Value<bool> isDeleted;
  final Value<DateTime?> updatedAt;
  final Value<DateTime?> createdAt;
  final Value<int> rowid;
  const CabinetsTableCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.letter = const Value.absent(),
    this.totalSubscribers = const Value.absent(),
    this.currentSubscribers = const Value.absent(),
    this.collectedAmount = const Value.absent(),
    this.delayedSubscribers = const Value.absent(),
    this.completionDate = const Value.absent(),
    this.lastModified = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.dirtyFlag = const Value.absent(),
    this.cloudId = const Value.absent(),
    this.deletedLocally = const Value.absent(),
    this.permissionsMask = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.version = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CabinetsTableCompanion.insert({
    required String id,
    required String name,
    this.letter = const Value.absent(),
    required int totalSubscribers,
    required int currentSubscribers,
    this.collectedAmount = const Value.absent(),
    required int delayedSubscribers,
    this.completionDate = const Value.absent(),
    this.lastModified = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.dirtyFlag = const Value.absent(),
    this.cloudId = const Value.absent(),
    this.deletedLocally = const Value.absent(),
    this.permissionsMask = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.version = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        totalSubscribers = Value(totalSubscribers),
        currentSubscribers = Value(currentSubscribers),
        delayedSubscribers = Value(delayedSubscribers);
  static Insertable<Cabinet> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? letter,
    Expression<int>? totalSubscribers,
    Expression<int>? currentSubscribers,
    Expression<double>? collectedAmount,
    Expression<int>? delayedSubscribers,
    Expression<DateTime>? completionDate,
    Expression<DateTime>? lastModified,
    Expression<DateTime>? lastSyncedAt,
    Expression<String>? syncStatus,
    Expression<bool>? dirtyFlag,
    Expression<String>? cloudId,
    Expression<bool>? deletedLocally,
    Expression<String>? permissionsMask,
    Expression<String>? ownerId,
    Expression<int>? version,
    Expression<bool>? isDeleted,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (letter != null) 'letter': letter,
      if (totalSubscribers != null) 'total_subscribers': totalSubscribers,
      if (currentSubscribers != null) 'current_subscribers': currentSubscribers,
      if (collectedAmount != null) 'collected_amount': collectedAmount,
      if (delayedSubscribers != null) 'delayed_subscribers': delayedSubscribers,
      if (completionDate != null) 'completion_date': completionDate,
      if (lastModified != null) 'last_modified': lastModified,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (dirtyFlag != null) 'dirty_flag': dirtyFlag,
      if (cloudId != null) 'cloud_id': cloudId,
      if (deletedLocally != null) 'deleted_locally': deletedLocally,
      if (permissionsMask != null) 'permissions_mask': permissionsMask,
      if (ownerId != null) 'owner_id': ownerId,
      if (version != null) 'version': version,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CabinetsTableCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String>? letter,
      Value<int>? totalSubscribers,
      Value<int>? currentSubscribers,
      Value<double>? collectedAmount,
      Value<int>? delayedSubscribers,
      Value<DateTime?>? completionDate,
      Value<DateTime?>? lastModified,
      Value<DateTime?>? lastSyncedAt,
      Value<String?>? syncStatus,
      Value<bool?>? dirtyFlag,
      Value<String?>? cloudId,
      Value<bool?>? deletedLocally,
      Value<String?>? permissionsMask,
      Value<String?>? ownerId,
      Value<int>? version,
      Value<bool>? isDeleted,
      Value<DateTime?>? updatedAt,
      Value<DateTime?>? createdAt,
      Value<int>? rowid}) {
    return CabinetsTableCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      letter: letter ?? this.letter,
      totalSubscribers: totalSubscribers ?? this.totalSubscribers,
      currentSubscribers: currentSubscribers ?? this.currentSubscribers,
      collectedAmount: collectedAmount ?? this.collectedAmount,
      delayedSubscribers: delayedSubscribers ?? this.delayedSubscribers,
      completionDate: completionDate ?? this.completionDate,
      lastModified: lastModified ?? this.lastModified,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      dirtyFlag: dirtyFlag ?? this.dirtyFlag,
      cloudId: cloudId ?? this.cloudId,
      deletedLocally: deletedLocally ?? this.deletedLocally,
      permissionsMask: permissionsMask ?? this.permissionsMask,
      ownerId: ownerId ?? this.ownerId,
      version: version ?? this.version,
      isDeleted: isDeleted ?? this.isDeleted,
      updatedAt: updatedAt ?? this.updatedAt,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (letter.present) {
      map['letter'] = Variable<String>(letter.value);
    }
    if (totalSubscribers.present) {
      map['total_subscribers'] = Variable<int>(totalSubscribers.value);
    }
    if (currentSubscribers.present) {
      map['current_subscribers'] = Variable<int>(currentSubscribers.value);
    }
    if (collectedAmount.present) {
      map['collected_amount'] = Variable<double>(collectedAmount.value);
    }
    if (delayedSubscribers.present) {
      map['delayed_subscribers'] = Variable<int>(delayedSubscribers.value);
    }
    if (completionDate.present) {
      map['completion_date'] = Variable<DateTime>(completionDate.value);
    }
    if (lastModified.present) {
      map['last_modified'] = Variable<DateTime>(lastModified.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (dirtyFlag.present) {
      map['dirty_flag'] = Variable<bool>(dirtyFlag.value);
    }
    if (cloudId.present) {
      map['cloud_id'] = Variable<String>(cloudId.value);
    }
    if (deletedLocally.present) {
      map['deleted_locally'] = Variable<bool>(deletedLocally.value);
    }
    if (permissionsMask.present) {
      map['permissions_mask'] = Variable<String>(permissionsMask.value);
    }
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CabinetsTableCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('letter: $letter, ')
          ..write('totalSubscribers: $totalSubscribers, ')
          ..write('currentSubscribers: $currentSubscribers, ')
          ..write('collectedAmount: $collectedAmount, ')
          ..write('delayedSubscribers: $delayedSubscribers, ')
          ..write('completionDate: $completionDate, ')
          ..write('lastModified: $lastModified, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('dirtyFlag: $dirtyFlag, ')
          ..write('cloudId: $cloudId, ')
          ..write('deletedLocally: $deletedLocally, ')
          ..write('permissionsMask: $permissionsMask, ')
          ..write('ownerId: $ownerId, ')
          ..write('version: $version, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PaymentsTableTable extends PaymentsTable
    with TableInfo<$PaymentsTableTable, Payment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PaymentsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _subscriberIdMeta =
      const VerificationMeta('subscriberId');
  @override
  late final GeneratedColumn<String> subscriberId = GeneratedColumn<String>(
      'subscriber_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
      'amount', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _workerMeta = const VerificationMeta('worker');
  @override
  late final GeneratedColumn<String> worker = GeneratedColumn<String>(
      'worker', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
      'date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _cabinetMeta =
      const VerificationMeta('cabinet');
  @override
  late final GeneratedColumn<String> cabinet = GeneratedColumn<String>(
      'cabinet', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _lastModifiedMeta =
      const VerificationMeta('lastModified');
  @override
  late final GeneratedColumn<DateTime> lastModified = GeneratedColumn<DateTime>(
      'last_modified', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _lastSyncedAtMeta =
      const VerificationMeta('lastSyncedAt');
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
      'last_synced_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('local_only'));
  static const VerificationMeta _dirtyFlagMeta =
      const VerificationMeta('dirtyFlag');
  @override
  late final GeneratedColumn<bool> dirtyFlag = GeneratedColumn<bool>(
      'dirty_flag', aliasedName, true,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("dirty_flag" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _cloudIdMeta =
      const VerificationMeta('cloudId');
  @override
  late final GeneratedColumn<String> cloudId = GeneratedColumn<String>(
      'cloud_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _deletedLocallyMeta =
      const VerificationMeta('deletedLocally');
  @override
  late final GeneratedColumn<bool> deletedLocally = GeneratedColumn<bool>(
      'deleted_locally', aliasedName, true,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("deleted_locally" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _permissionsMaskMeta =
      const VerificationMeta('permissionsMask');
  @override
  late final GeneratedColumn<String> permissionsMask = GeneratedColumn<String>(
      'permissions_mask', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _ownerIdMeta =
      const VerificationMeta('ownerId');
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
      'owner_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _versionMeta =
      const VerificationMeta('version');
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
      'version', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _isDeletedMeta =
      const VerificationMeta('isDeleted');
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
      'is_deleted', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_deleted" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        subscriberId,
        amount,
        worker,
        date,
        cabinet,
        lastModified,
        lastSyncedAt,
        syncStatus,
        dirtyFlag,
        cloudId,
        deletedLocally,
        permissionsMask,
        ownerId,
        version,
        isDeleted,
        updatedAt,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'payments_table';
  @override
  VerificationContext validateIntegrity(Insertable<Payment> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('subscriber_id')) {
      context.handle(
          _subscriberIdMeta,
          subscriberId.isAcceptableOrUnknown(
              data['subscriber_id']!, _subscriberIdMeta));
    } else if (isInserting) {
      context.missing(_subscriberIdMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(_amountMeta,
          amount.isAcceptableOrUnknown(data['amount']!, _amountMeta));
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('worker')) {
      context.handle(_workerMeta,
          worker.isAcceptableOrUnknown(data['worker']!, _workerMeta));
    } else if (isInserting) {
      context.missing(_workerMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('cabinet')) {
      context.handle(_cabinetMeta,
          cabinet.isAcceptableOrUnknown(data['cabinet']!, _cabinetMeta));
    } else if (isInserting) {
      context.missing(_cabinetMeta);
    }
    if (data.containsKey('last_modified')) {
      context.handle(
          _lastModifiedMeta,
          lastModified.isAcceptableOrUnknown(
              data['last_modified']!, _lastModifiedMeta));
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
          _lastSyncedAtMeta,
          lastSyncedAt.isAcceptableOrUnknown(
              data['last_synced_at']!, _lastSyncedAtMeta));
    }
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
    }
    if (data.containsKey('dirty_flag')) {
      context.handle(_dirtyFlagMeta,
          dirtyFlag.isAcceptableOrUnknown(data['dirty_flag']!, _dirtyFlagMeta));
    }
    if (data.containsKey('cloud_id')) {
      context.handle(_cloudIdMeta,
          cloudId.isAcceptableOrUnknown(data['cloud_id']!, _cloudIdMeta));
    }
    if (data.containsKey('deleted_locally')) {
      context.handle(
          _deletedLocallyMeta,
          deletedLocally.isAcceptableOrUnknown(
              data['deleted_locally']!, _deletedLocallyMeta));
    }
    if (data.containsKey('permissions_mask')) {
      context.handle(
          _permissionsMaskMeta,
          permissionsMask.isAcceptableOrUnknown(
              data['permissions_mask']!, _permissionsMaskMeta));
    }
    if (data.containsKey('owner_id')) {
      context.handle(_ownerIdMeta,
          ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta));
    }
    if (data.containsKey('version')) {
      context.handle(_versionMeta,
          version.isAcceptableOrUnknown(data['version']!, _versionMeta));
    }
    if (data.containsKey('is_deleted')) {
      context.handle(_isDeletedMeta,
          isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Payment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Payment(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      subscriberId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}subscriber_id'])!,
      amount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}amount'])!,
      worker: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}worker'])!,
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date'])!,
      cabinet: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}cabinet'])!,
      lastModified: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}last_modified']),
      lastSyncedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_synced_at']),
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status']),
      dirtyFlag: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}dirty_flag']),
      cloudId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}cloud_id']),
      deletedLocally: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}deleted_locally']),
      permissionsMask: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}permissions_mask']),
      ownerId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}owner_id']),
      version: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}version'])!,
      isDeleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_deleted'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at']),
    );
  }

  @override
  $PaymentsTableTable createAlias(String alias) {
    return $PaymentsTableTable(attachedDatabase, alias);
  }
}

class Payment extends DataClass implements Insertable<Payment> {
  final String id;
  final String subscriberId;
  final double amount;
  final String worker;
  final DateTime date;
  final String cabinet;
  final DateTime? lastModified;
  final DateTime? lastSyncedAt;
  final String? syncStatus;
  final bool? dirtyFlag;
  final String? cloudId;
  final bool? deletedLocally;
  final String? permissionsMask;
  final String? ownerId;
  final int version;
  final bool isDeleted;
  final DateTime? updatedAt;
  final DateTime? createdAt;
  const Payment(
      {required this.id,
      required this.subscriberId,
      required this.amount,
      required this.worker,
      required this.date,
      required this.cabinet,
      this.lastModified,
      this.lastSyncedAt,
      this.syncStatus,
      this.dirtyFlag,
      this.cloudId,
      this.deletedLocally,
      this.permissionsMask,
      this.ownerId,
      required this.version,
      required this.isDeleted,
      this.updatedAt,
      this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['subscriber_id'] = Variable<String>(subscriberId);
    map['amount'] = Variable<double>(amount);
    map['worker'] = Variable<String>(worker);
    map['date'] = Variable<DateTime>(date);
    map['cabinet'] = Variable<String>(cabinet);
    if (!nullToAbsent || lastModified != null) {
      map['last_modified'] = Variable<DateTime>(lastModified);
    }
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    }
    if (!nullToAbsent || syncStatus != null) {
      map['sync_status'] = Variable<String>(syncStatus);
    }
    if (!nullToAbsent || dirtyFlag != null) {
      map['dirty_flag'] = Variable<bool>(dirtyFlag);
    }
    if (!nullToAbsent || cloudId != null) {
      map['cloud_id'] = Variable<String>(cloudId);
    }
    if (!nullToAbsent || deletedLocally != null) {
      map['deleted_locally'] = Variable<bool>(deletedLocally);
    }
    if (!nullToAbsent || permissionsMask != null) {
      map['permissions_mask'] = Variable<String>(permissionsMask);
    }
    if (!nullToAbsent || ownerId != null) {
      map['owner_id'] = Variable<String>(ownerId);
    }
    map['version'] = Variable<int>(version);
    map['is_deleted'] = Variable<bool>(isDeleted);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<DateTime>(createdAt);
    }
    return map;
  }

  PaymentsTableCompanion toCompanion(bool nullToAbsent) {
    return PaymentsTableCompanion(
      id: Value(id),
      subscriberId: Value(subscriberId),
      amount: Value(amount),
      worker: Value(worker),
      date: Value(date),
      cabinet: Value(cabinet),
      lastModified: lastModified == null && nullToAbsent
          ? const Value.absent()
          : Value(lastModified),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
      syncStatus: syncStatus == null && nullToAbsent
          ? const Value.absent()
          : Value(syncStatus),
      dirtyFlag: dirtyFlag == null && nullToAbsent
          ? const Value.absent()
          : Value(dirtyFlag),
      cloudId: cloudId == null && nullToAbsent
          ? const Value.absent()
          : Value(cloudId),
      deletedLocally: deletedLocally == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedLocally),
      permissionsMask: permissionsMask == null && nullToAbsent
          ? const Value.absent()
          : Value(permissionsMask),
      ownerId: ownerId == null && nullToAbsent
          ? const Value.absent()
          : Value(ownerId),
      version: Value(version),
      isDeleted: Value(isDeleted),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
    );
  }

  factory Payment.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Payment(
      id: serializer.fromJson<String>(json['id']),
      subscriberId: serializer.fromJson<String>(json['subscriberId']),
      amount: serializer.fromJson<double>(json['amount']),
      worker: serializer.fromJson<String>(json['worker']),
      date: serializer.fromJson<DateTime>(json['date']),
      cabinet: serializer.fromJson<String>(json['cabinet']),
      lastModified: serializer.fromJson<DateTime?>(json['lastModified']),
      lastSyncedAt: serializer.fromJson<DateTime?>(json['lastSyncedAt']),
      syncStatus: serializer.fromJson<String?>(json['syncStatus']),
      dirtyFlag: serializer.fromJson<bool?>(json['dirtyFlag']),
      cloudId: serializer.fromJson<String?>(json['cloudId']),
      deletedLocally: serializer.fromJson<bool?>(json['deletedLocally']),
      permissionsMask: serializer.fromJson<String?>(json['permissionsMask']),
      ownerId: serializer.fromJson<String?>(json['ownerId']),
      version: serializer.fromJson<int>(json['version']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      createdAt: serializer.fromJson<DateTime?>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'subscriberId': serializer.toJson<String>(subscriberId),
      'amount': serializer.toJson<double>(amount),
      'worker': serializer.toJson<String>(worker),
      'date': serializer.toJson<DateTime>(date),
      'cabinet': serializer.toJson<String>(cabinet),
      'lastModified': serializer.toJson<DateTime?>(lastModified),
      'lastSyncedAt': serializer.toJson<DateTime?>(lastSyncedAt),
      'syncStatus': serializer.toJson<String?>(syncStatus),
      'dirtyFlag': serializer.toJson<bool?>(dirtyFlag),
      'cloudId': serializer.toJson<String?>(cloudId),
      'deletedLocally': serializer.toJson<bool?>(deletedLocally),
      'permissionsMask': serializer.toJson<String?>(permissionsMask),
      'ownerId': serializer.toJson<String?>(ownerId),
      'version': serializer.toJson<int>(version),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'createdAt': serializer.toJson<DateTime?>(createdAt),
    };
  }

  Payment copyWith(
          {String? id,
          String? subscriberId,
          double? amount,
          String? worker,
          DateTime? date,
          String? cabinet,
          Value<DateTime?> lastModified = const Value.absent(),
          Value<DateTime?> lastSyncedAt = const Value.absent(),
          Value<String?> syncStatus = const Value.absent(),
          Value<bool?> dirtyFlag = const Value.absent(),
          Value<String?> cloudId = const Value.absent(),
          Value<bool?> deletedLocally = const Value.absent(),
          Value<String?> permissionsMask = const Value.absent(),
          Value<String?> ownerId = const Value.absent(),
          int? version,
          bool? isDeleted,
          Value<DateTime?> updatedAt = const Value.absent(),
          Value<DateTime?> createdAt = const Value.absent()}) =>
      Payment(
        id: id ?? this.id,
        subscriberId: subscriberId ?? this.subscriberId,
        amount: amount ?? this.amount,
        worker: worker ?? this.worker,
        date: date ?? this.date,
        cabinet: cabinet ?? this.cabinet,
        lastModified:
            lastModified.present ? lastModified.value : this.lastModified,
        lastSyncedAt:
            lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
        syncStatus: syncStatus.present ? syncStatus.value : this.syncStatus,
        dirtyFlag: dirtyFlag.present ? dirtyFlag.value : this.dirtyFlag,
        cloudId: cloudId.present ? cloudId.value : this.cloudId,
        deletedLocally:
            deletedLocally.present ? deletedLocally.value : this.deletedLocally,
        permissionsMask: permissionsMask.present
            ? permissionsMask.value
            : this.permissionsMask,
        ownerId: ownerId.present ? ownerId.value : this.ownerId,
        version: version ?? this.version,
        isDeleted: isDeleted ?? this.isDeleted,
        updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
        createdAt: createdAt.present ? createdAt.value : this.createdAt,
      );
  Payment copyWithCompanion(PaymentsTableCompanion data) {
    return Payment(
      id: data.id.present ? data.id.value : this.id,
      subscriberId: data.subscriberId.present
          ? data.subscriberId.value
          : this.subscriberId,
      amount: data.amount.present ? data.amount.value : this.amount,
      worker: data.worker.present ? data.worker.value : this.worker,
      date: data.date.present ? data.date.value : this.date,
      cabinet: data.cabinet.present ? data.cabinet.value : this.cabinet,
      lastModified: data.lastModified.present
          ? data.lastModified.value
          : this.lastModified,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
      dirtyFlag: data.dirtyFlag.present ? data.dirtyFlag.value : this.dirtyFlag,
      cloudId: data.cloudId.present ? data.cloudId.value : this.cloudId,
      deletedLocally: data.deletedLocally.present
          ? data.deletedLocally.value
          : this.deletedLocally,
      permissionsMask: data.permissionsMask.present
          ? data.permissionsMask.value
          : this.permissionsMask,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      version: data.version.present ? data.version.value : this.version,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Payment(')
          ..write('id: $id, ')
          ..write('subscriberId: $subscriberId, ')
          ..write('amount: $amount, ')
          ..write('worker: $worker, ')
          ..write('date: $date, ')
          ..write('cabinet: $cabinet, ')
          ..write('lastModified: $lastModified, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('dirtyFlag: $dirtyFlag, ')
          ..write('cloudId: $cloudId, ')
          ..write('deletedLocally: $deletedLocally, ')
          ..write('permissionsMask: $permissionsMask, ')
          ..write('ownerId: $ownerId, ')
          ..write('version: $version, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      subscriberId,
      amount,
      worker,
      date,
      cabinet,
      lastModified,
      lastSyncedAt,
      syncStatus,
      dirtyFlag,
      cloudId,
      deletedLocally,
      permissionsMask,
      ownerId,
      version,
      isDeleted,
      updatedAt,
      createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Payment &&
          other.id == this.id &&
          other.subscriberId == this.subscriberId &&
          other.amount == this.amount &&
          other.worker == this.worker &&
          other.date == this.date &&
          other.cabinet == this.cabinet &&
          other.lastModified == this.lastModified &&
          other.lastSyncedAt == this.lastSyncedAt &&
          other.syncStatus == this.syncStatus &&
          other.dirtyFlag == this.dirtyFlag &&
          other.cloudId == this.cloudId &&
          other.deletedLocally == this.deletedLocally &&
          other.permissionsMask == this.permissionsMask &&
          other.ownerId == this.ownerId &&
          other.version == this.version &&
          other.isDeleted == this.isDeleted &&
          other.updatedAt == this.updatedAt &&
          other.createdAt == this.createdAt);
}

class PaymentsTableCompanion extends UpdateCompanion<Payment> {
  final Value<String> id;
  final Value<String> subscriberId;
  final Value<double> amount;
  final Value<String> worker;
  final Value<DateTime> date;
  final Value<String> cabinet;
  final Value<DateTime?> lastModified;
  final Value<DateTime?> lastSyncedAt;
  final Value<String?> syncStatus;
  final Value<bool?> dirtyFlag;
  final Value<String?> cloudId;
  final Value<bool?> deletedLocally;
  final Value<String?> permissionsMask;
  final Value<String?> ownerId;
  final Value<int> version;
  final Value<bool> isDeleted;
  final Value<DateTime?> updatedAt;
  final Value<DateTime?> createdAt;
  final Value<int> rowid;
  const PaymentsTableCompanion({
    this.id = const Value.absent(),
    this.subscriberId = const Value.absent(),
    this.amount = const Value.absent(),
    this.worker = const Value.absent(),
    this.date = const Value.absent(),
    this.cabinet = const Value.absent(),
    this.lastModified = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.dirtyFlag = const Value.absent(),
    this.cloudId = const Value.absent(),
    this.deletedLocally = const Value.absent(),
    this.permissionsMask = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.version = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PaymentsTableCompanion.insert({
    required String id,
    required String subscriberId,
    required double amount,
    required String worker,
    required DateTime date,
    required String cabinet,
    this.lastModified = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.dirtyFlag = const Value.absent(),
    this.cloudId = const Value.absent(),
    this.deletedLocally = const Value.absent(),
    this.permissionsMask = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.version = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        subscriberId = Value(subscriberId),
        amount = Value(amount),
        worker = Value(worker),
        date = Value(date),
        cabinet = Value(cabinet);
  static Insertable<Payment> custom({
    Expression<String>? id,
    Expression<String>? subscriberId,
    Expression<double>? amount,
    Expression<String>? worker,
    Expression<DateTime>? date,
    Expression<String>? cabinet,
    Expression<DateTime>? lastModified,
    Expression<DateTime>? lastSyncedAt,
    Expression<String>? syncStatus,
    Expression<bool>? dirtyFlag,
    Expression<String>? cloudId,
    Expression<bool>? deletedLocally,
    Expression<String>? permissionsMask,
    Expression<String>? ownerId,
    Expression<int>? version,
    Expression<bool>? isDeleted,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (subscriberId != null) 'subscriber_id': subscriberId,
      if (amount != null) 'amount': amount,
      if (worker != null) 'worker': worker,
      if (date != null) 'date': date,
      if (cabinet != null) 'cabinet': cabinet,
      if (lastModified != null) 'last_modified': lastModified,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (dirtyFlag != null) 'dirty_flag': dirtyFlag,
      if (cloudId != null) 'cloud_id': cloudId,
      if (deletedLocally != null) 'deleted_locally': deletedLocally,
      if (permissionsMask != null) 'permissions_mask': permissionsMask,
      if (ownerId != null) 'owner_id': ownerId,
      if (version != null) 'version': version,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PaymentsTableCompanion copyWith(
      {Value<String>? id,
      Value<String>? subscriberId,
      Value<double>? amount,
      Value<String>? worker,
      Value<DateTime>? date,
      Value<String>? cabinet,
      Value<DateTime?>? lastModified,
      Value<DateTime?>? lastSyncedAt,
      Value<String?>? syncStatus,
      Value<bool?>? dirtyFlag,
      Value<String?>? cloudId,
      Value<bool?>? deletedLocally,
      Value<String?>? permissionsMask,
      Value<String?>? ownerId,
      Value<int>? version,
      Value<bool>? isDeleted,
      Value<DateTime?>? updatedAt,
      Value<DateTime?>? createdAt,
      Value<int>? rowid}) {
    return PaymentsTableCompanion(
      id: id ?? this.id,
      subscriberId: subscriberId ?? this.subscriberId,
      amount: amount ?? this.amount,
      worker: worker ?? this.worker,
      date: date ?? this.date,
      cabinet: cabinet ?? this.cabinet,
      lastModified: lastModified ?? this.lastModified,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      dirtyFlag: dirtyFlag ?? this.dirtyFlag,
      cloudId: cloudId ?? this.cloudId,
      deletedLocally: deletedLocally ?? this.deletedLocally,
      permissionsMask: permissionsMask ?? this.permissionsMask,
      ownerId: ownerId ?? this.ownerId,
      version: version ?? this.version,
      isDeleted: isDeleted ?? this.isDeleted,
      updatedAt: updatedAt ?? this.updatedAt,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (subscriberId.present) {
      map['subscriber_id'] = Variable<String>(subscriberId.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (worker.present) {
      map['worker'] = Variable<String>(worker.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (cabinet.present) {
      map['cabinet'] = Variable<String>(cabinet.value);
    }
    if (lastModified.present) {
      map['last_modified'] = Variable<DateTime>(lastModified.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (dirtyFlag.present) {
      map['dirty_flag'] = Variable<bool>(dirtyFlag.value);
    }
    if (cloudId.present) {
      map['cloud_id'] = Variable<String>(cloudId.value);
    }
    if (deletedLocally.present) {
      map['deleted_locally'] = Variable<bool>(deletedLocally.value);
    }
    if (permissionsMask.present) {
      map['permissions_mask'] = Variable<String>(permissionsMask.value);
    }
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PaymentsTableCompanion(')
          ..write('id: $id, ')
          ..write('subscriberId: $subscriberId, ')
          ..write('amount: $amount, ')
          ..write('worker: $worker, ')
          ..write('date: $date, ')
          ..write('cabinet: $cabinet, ')
          ..write('lastModified: $lastModified, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('dirtyFlag: $dirtyFlag, ')
          ..write('cloudId: $cloudId, ')
          ..write('deletedLocally: $deletedLocally, ')
          ..write('permissionsMask: $permissionsMask, ')
          ..write('ownerId: $ownerId, ')
          ..write('version: $version, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WorkersTableTable extends WorkersTable
    with TableInfo<$WorkersTableTable, Worker> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkersTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
      'phone', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _permissionsMeta =
      const VerificationMeta('permissions');
  @override
  late final GeneratedColumn<String> permissions = GeneratedColumn<String>(
      'permissions', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _todayCollectedMeta =
      const VerificationMeta('todayCollected');
  @override
  late final GeneratedColumn<double> todayCollected = GeneratedColumn<double>(
      'today_collected', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _monthTotalMeta =
      const VerificationMeta('monthTotal');
  @override
  late final GeneratedColumn<double> monthTotal = GeneratedColumn<double>(
      'month_total', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _lastModifiedMeta =
      const VerificationMeta('lastModified');
  @override
  late final GeneratedColumn<DateTime> lastModified = GeneratedColumn<DateTime>(
      'last_modified', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _lastSyncedAtMeta =
      const VerificationMeta('lastSyncedAt');
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
      'last_synced_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('local_only'));
  static const VerificationMeta _dirtyFlagMeta =
      const VerificationMeta('dirtyFlag');
  @override
  late final GeneratedColumn<bool> dirtyFlag = GeneratedColumn<bool>(
      'dirty_flag', aliasedName, true,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("dirty_flag" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _cloudIdMeta =
      const VerificationMeta('cloudId');
  @override
  late final GeneratedColumn<String> cloudId = GeneratedColumn<String>(
      'cloud_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _deletedLocallyMeta =
      const VerificationMeta('deletedLocally');
  @override
  late final GeneratedColumn<bool> deletedLocally = GeneratedColumn<bool>(
      'deleted_locally', aliasedName, true,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("deleted_locally" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _permissionsMaskMeta =
      const VerificationMeta('permissionsMask');
  @override
  late final GeneratedColumn<String> permissionsMask = GeneratedColumn<String>(
      'permissions_mask', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _ownerIdMeta =
      const VerificationMeta('ownerId');
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
      'owner_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _versionMeta =
      const VerificationMeta('version');
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
      'version', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _isDeletedMeta =
      const VerificationMeta('isDeleted');
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
      'is_deleted', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_deleted" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        phone,
        permissions,
        todayCollected,
        monthTotal,
        lastModified,
        lastSyncedAt,
        syncStatus,
        dirtyFlag,
        cloudId,
        deletedLocally,
        permissionsMask,
        ownerId,
        version,
        isDeleted,
        updatedAt,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'workers_table';
  @override
  VerificationContext validateIntegrity(Insertable<Worker> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('phone')) {
      context.handle(
          _phoneMeta, phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta));
    } else if (isInserting) {
      context.missing(_phoneMeta);
    }
    if (data.containsKey('permissions')) {
      context.handle(
          _permissionsMeta,
          permissions.isAcceptableOrUnknown(
              data['permissions']!, _permissionsMeta));
    } else if (isInserting) {
      context.missing(_permissionsMeta);
    }
    if (data.containsKey('today_collected')) {
      context.handle(
          _todayCollectedMeta,
          todayCollected.isAcceptableOrUnknown(
              data['today_collected']!, _todayCollectedMeta));
    }
    if (data.containsKey('month_total')) {
      context.handle(
          _monthTotalMeta,
          monthTotal.isAcceptableOrUnknown(
              data['month_total']!, _monthTotalMeta));
    }
    if (data.containsKey('last_modified')) {
      context.handle(
          _lastModifiedMeta,
          lastModified.isAcceptableOrUnknown(
              data['last_modified']!, _lastModifiedMeta));
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
          _lastSyncedAtMeta,
          lastSyncedAt.isAcceptableOrUnknown(
              data['last_synced_at']!, _lastSyncedAtMeta));
    }
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
    }
    if (data.containsKey('dirty_flag')) {
      context.handle(_dirtyFlagMeta,
          dirtyFlag.isAcceptableOrUnknown(data['dirty_flag']!, _dirtyFlagMeta));
    }
    if (data.containsKey('cloud_id')) {
      context.handle(_cloudIdMeta,
          cloudId.isAcceptableOrUnknown(data['cloud_id']!, _cloudIdMeta));
    }
    if (data.containsKey('deleted_locally')) {
      context.handle(
          _deletedLocallyMeta,
          deletedLocally.isAcceptableOrUnknown(
              data['deleted_locally']!, _deletedLocallyMeta));
    }
    if (data.containsKey('permissions_mask')) {
      context.handle(
          _permissionsMaskMeta,
          permissionsMask.isAcceptableOrUnknown(
              data['permissions_mask']!, _permissionsMaskMeta));
    }
    if (data.containsKey('owner_id')) {
      context.handle(_ownerIdMeta,
          ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta));
    }
    if (data.containsKey('version')) {
      context.handle(_versionMeta,
          version.isAcceptableOrUnknown(data['version']!, _versionMeta));
    }
    if (data.containsKey('is_deleted')) {
      context.handle(_isDeletedMeta,
          isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Worker map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Worker(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      phone: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}phone'])!,
      permissions: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}permissions'])!,
      todayCollected: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}today_collected'])!,
      monthTotal: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}month_total'])!,
      lastModified: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}last_modified']),
      lastSyncedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_synced_at']),
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status']),
      dirtyFlag: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}dirty_flag']),
      cloudId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}cloud_id']),
      deletedLocally: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}deleted_locally']),
      permissionsMask: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}permissions_mask']),
      ownerId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}owner_id']),
      version: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}version'])!,
      isDeleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_deleted'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at']),
    );
  }

  @override
  $WorkersTableTable createAlias(String alias) {
    return $WorkersTableTable(attachedDatabase, alias);
  }
}

class Worker extends DataClass implements Insertable<Worker> {
  final String id;
  final String name;
  final String phone;
  final String permissions;
  final double todayCollected;
  final double monthTotal;
  final DateTime? lastModified;
  final DateTime? lastSyncedAt;
  final String? syncStatus;
  final bool? dirtyFlag;
  final String? cloudId;
  final bool? deletedLocally;
  final String? permissionsMask;
  final String? ownerId;
  final int version;
  final bool isDeleted;
  final DateTime? updatedAt;
  final DateTime? createdAt;
  const Worker(
      {required this.id,
      required this.name,
      required this.phone,
      required this.permissions,
      required this.todayCollected,
      required this.monthTotal,
      this.lastModified,
      this.lastSyncedAt,
      this.syncStatus,
      this.dirtyFlag,
      this.cloudId,
      this.deletedLocally,
      this.permissionsMask,
      this.ownerId,
      required this.version,
      required this.isDeleted,
      this.updatedAt,
      this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['phone'] = Variable<String>(phone);
    map['permissions'] = Variable<String>(permissions);
    map['today_collected'] = Variable<double>(todayCollected);
    map['month_total'] = Variable<double>(monthTotal);
    if (!nullToAbsent || lastModified != null) {
      map['last_modified'] = Variable<DateTime>(lastModified);
    }
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    }
    if (!nullToAbsent || syncStatus != null) {
      map['sync_status'] = Variable<String>(syncStatus);
    }
    if (!nullToAbsent || dirtyFlag != null) {
      map['dirty_flag'] = Variable<bool>(dirtyFlag);
    }
    if (!nullToAbsent || cloudId != null) {
      map['cloud_id'] = Variable<String>(cloudId);
    }
    if (!nullToAbsent || deletedLocally != null) {
      map['deleted_locally'] = Variable<bool>(deletedLocally);
    }
    if (!nullToAbsent || permissionsMask != null) {
      map['permissions_mask'] = Variable<String>(permissionsMask);
    }
    if (!nullToAbsent || ownerId != null) {
      map['owner_id'] = Variable<String>(ownerId);
    }
    map['version'] = Variable<int>(version);
    map['is_deleted'] = Variable<bool>(isDeleted);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<DateTime>(createdAt);
    }
    return map;
  }

  WorkersTableCompanion toCompanion(bool nullToAbsent) {
    return WorkersTableCompanion(
      id: Value(id),
      name: Value(name),
      phone: Value(phone),
      permissions: Value(permissions),
      todayCollected: Value(todayCollected),
      monthTotal: Value(monthTotal),
      lastModified: lastModified == null && nullToAbsent
          ? const Value.absent()
          : Value(lastModified),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
      syncStatus: syncStatus == null && nullToAbsent
          ? const Value.absent()
          : Value(syncStatus),
      dirtyFlag: dirtyFlag == null && nullToAbsent
          ? const Value.absent()
          : Value(dirtyFlag),
      cloudId: cloudId == null && nullToAbsent
          ? const Value.absent()
          : Value(cloudId),
      deletedLocally: deletedLocally == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedLocally),
      permissionsMask: permissionsMask == null && nullToAbsent
          ? const Value.absent()
          : Value(permissionsMask),
      ownerId: ownerId == null && nullToAbsent
          ? const Value.absent()
          : Value(ownerId),
      version: Value(version),
      isDeleted: Value(isDeleted),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
    );
  }

  factory Worker.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Worker(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      phone: serializer.fromJson<String>(json['phone']),
      permissions: serializer.fromJson<String>(json['permissions']),
      todayCollected: serializer.fromJson<double>(json['todayCollected']),
      monthTotal: serializer.fromJson<double>(json['monthTotal']),
      lastModified: serializer.fromJson<DateTime?>(json['lastModified']),
      lastSyncedAt: serializer.fromJson<DateTime?>(json['lastSyncedAt']),
      syncStatus: serializer.fromJson<String?>(json['syncStatus']),
      dirtyFlag: serializer.fromJson<bool?>(json['dirtyFlag']),
      cloudId: serializer.fromJson<String?>(json['cloudId']),
      deletedLocally: serializer.fromJson<bool?>(json['deletedLocally']),
      permissionsMask: serializer.fromJson<String?>(json['permissionsMask']),
      ownerId: serializer.fromJson<String?>(json['ownerId']),
      version: serializer.fromJson<int>(json['version']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      createdAt: serializer.fromJson<DateTime?>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'phone': serializer.toJson<String>(phone),
      'permissions': serializer.toJson<String>(permissions),
      'todayCollected': serializer.toJson<double>(todayCollected),
      'monthTotal': serializer.toJson<double>(monthTotal),
      'lastModified': serializer.toJson<DateTime?>(lastModified),
      'lastSyncedAt': serializer.toJson<DateTime?>(lastSyncedAt),
      'syncStatus': serializer.toJson<String?>(syncStatus),
      'dirtyFlag': serializer.toJson<bool?>(dirtyFlag),
      'cloudId': serializer.toJson<String?>(cloudId),
      'deletedLocally': serializer.toJson<bool?>(deletedLocally),
      'permissionsMask': serializer.toJson<String?>(permissionsMask),
      'ownerId': serializer.toJson<String?>(ownerId),
      'version': serializer.toJson<int>(version),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'createdAt': serializer.toJson<DateTime?>(createdAt),
    };
  }

  Worker copyWith(
          {String? id,
          String? name,
          String? phone,
          String? permissions,
          double? todayCollected,
          double? monthTotal,
          Value<DateTime?> lastModified = const Value.absent(),
          Value<DateTime?> lastSyncedAt = const Value.absent(),
          Value<String?> syncStatus = const Value.absent(),
          Value<bool?> dirtyFlag = const Value.absent(),
          Value<String?> cloudId = const Value.absent(),
          Value<bool?> deletedLocally = const Value.absent(),
          Value<String?> permissionsMask = const Value.absent(),
          Value<String?> ownerId = const Value.absent(),
          int? version,
          bool? isDeleted,
          Value<DateTime?> updatedAt = const Value.absent(),
          Value<DateTime?> createdAt = const Value.absent()}) =>
      Worker(
        id: id ?? this.id,
        name: name ?? this.name,
        phone: phone ?? this.phone,
        permissions: permissions ?? this.permissions,
        todayCollected: todayCollected ?? this.todayCollected,
        monthTotal: monthTotal ?? this.monthTotal,
        lastModified:
            lastModified.present ? lastModified.value : this.lastModified,
        lastSyncedAt:
            lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
        syncStatus: syncStatus.present ? syncStatus.value : this.syncStatus,
        dirtyFlag: dirtyFlag.present ? dirtyFlag.value : this.dirtyFlag,
        cloudId: cloudId.present ? cloudId.value : this.cloudId,
        deletedLocally:
            deletedLocally.present ? deletedLocally.value : this.deletedLocally,
        permissionsMask: permissionsMask.present
            ? permissionsMask.value
            : this.permissionsMask,
        ownerId: ownerId.present ? ownerId.value : this.ownerId,
        version: version ?? this.version,
        isDeleted: isDeleted ?? this.isDeleted,
        updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
        createdAt: createdAt.present ? createdAt.value : this.createdAt,
      );
  Worker copyWithCompanion(WorkersTableCompanion data) {
    return Worker(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      phone: data.phone.present ? data.phone.value : this.phone,
      permissions:
          data.permissions.present ? data.permissions.value : this.permissions,
      todayCollected: data.todayCollected.present
          ? data.todayCollected.value
          : this.todayCollected,
      monthTotal:
          data.monthTotal.present ? data.monthTotal.value : this.monthTotal,
      lastModified: data.lastModified.present
          ? data.lastModified.value
          : this.lastModified,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
      dirtyFlag: data.dirtyFlag.present ? data.dirtyFlag.value : this.dirtyFlag,
      cloudId: data.cloudId.present ? data.cloudId.value : this.cloudId,
      deletedLocally: data.deletedLocally.present
          ? data.deletedLocally.value
          : this.deletedLocally,
      permissionsMask: data.permissionsMask.present
          ? data.permissionsMask.value
          : this.permissionsMask,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      version: data.version.present ? data.version.value : this.version,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Worker(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('phone: $phone, ')
          ..write('permissions: $permissions, ')
          ..write('todayCollected: $todayCollected, ')
          ..write('monthTotal: $monthTotal, ')
          ..write('lastModified: $lastModified, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('dirtyFlag: $dirtyFlag, ')
          ..write('cloudId: $cloudId, ')
          ..write('deletedLocally: $deletedLocally, ')
          ..write('permissionsMask: $permissionsMask, ')
          ..write('ownerId: $ownerId, ')
          ..write('version: $version, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      name,
      phone,
      permissions,
      todayCollected,
      monthTotal,
      lastModified,
      lastSyncedAt,
      syncStatus,
      dirtyFlag,
      cloudId,
      deletedLocally,
      permissionsMask,
      ownerId,
      version,
      isDeleted,
      updatedAt,
      createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Worker &&
          other.id == this.id &&
          other.name == this.name &&
          other.phone == this.phone &&
          other.permissions == this.permissions &&
          other.todayCollected == this.todayCollected &&
          other.monthTotal == this.monthTotal &&
          other.lastModified == this.lastModified &&
          other.lastSyncedAt == this.lastSyncedAt &&
          other.syncStatus == this.syncStatus &&
          other.dirtyFlag == this.dirtyFlag &&
          other.cloudId == this.cloudId &&
          other.deletedLocally == this.deletedLocally &&
          other.permissionsMask == this.permissionsMask &&
          other.ownerId == this.ownerId &&
          other.version == this.version &&
          other.isDeleted == this.isDeleted &&
          other.updatedAt == this.updatedAt &&
          other.createdAt == this.createdAt);
}

class WorkersTableCompanion extends UpdateCompanion<Worker> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> phone;
  final Value<String> permissions;
  final Value<double> todayCollected;
  final Value<double> monthTotal;
  final Value<DateTime?> lastModified;
  final Value<DateTime?> lastSyncedAt;
  final Value<String?> syncStatus;
  final Value<bool?> dirtyFlag;
  final Value<String?> cloudId;
  final Value<bool?> deletedLocally;
  final Value<String?> permissionsMask;
  final Value<String?> ownerId;
  final Value<int> version;
  final Value<bool> isDeleted;
  final Value<DateTime?> updatedAt;
  final Value<DateTime?> createdAt;
  final Value<int> rowid;
  const WorkersTableCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.phone = const Value.absent(),
    this.permissions = const Value.absent(),
    this.todayCollected = const Value.absent(),
    this.monthTotal = const Value.absent(),
    this.lastModified = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.dirtyFlag = const Value.absent(),
    this.cloudId = const Value.absent(),
    this.deletedLocally = const Value.absent(),
    this.permissionsMask = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.version = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WorkersTableCompanion.insert({
    required String id,
    required String name,
    required String phone,
    required String permissions,
    this.todayCollected = const Value.absent(),
    this.monthTotal = const Value.absent(),
    this.lastModified = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.dirtyFlag = const Value.absent(),
    this.cloudId = const Value.absent(),
    this.deletedLocally = const Value.absent(),
    this.permissionsMask = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.version = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        phone = Value(phone),
        permissions = Value(permissions);
  static Insertable<Worker> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? phone,
    Expression<String>? permissions,
    Expression<double>? todayCollected,
    Expression<double>? monthTotal,
    Expression<DateTime>? lastModified,
    Expression<DateTime>? lastSyncedAt,
    Expression<String>? syncStatus,
    Expression<bool>? dirtyFlag,
    Expression<String>? cloudId,
    Expression<bool>? deletedLocally,
    Expression<String>? permissionsMask,
    Expression<String>? ownerId,
    Expression<int>? version,
    Expression<bool>? isDeleted,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (phone != null) 'phone': phone,
      if (permissions != null) 'permissions': permissions,
      if (todayCollected != null) 'today_collected': todayCollected,
      if (monthTotal != null) 'month_total': monthTotal,
      if (lastModified != null) 'last_modified': lastModified,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (dirtyFlag != null) 'dirty_flag': dirtyFlag,
      if (cloudId != null) 'cloud_id': cloudId,
      if (deletedLocally != null) 'deleted_locally': deletedLocally,
      if (permissionsMask != null) 'permissions_mask': permissionsMask,
      if (ownerId != null) 'owner_id': ownerId,
      if (version != null) 'version': version,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WorkersTableCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String>? phone,
      Value<String>? permissions,
      Value<double>? todayCollected,
      Value<double>? monthTotal,
      Value<DateTime?>? lastModified,
      Value<DateTime?>? lastSyncedAt,
      Value<String?>? syncStatus,
      Value<bool?>? dirtyFlag,
      Value<String?>? cloudId,
      Value<bool?>? deletedLocally,
      Value<String?>? permissionsMask,
      Value<String?>? ownerId,
      Value<int>? version,
      Value<bool>? isDeleted,
      Value<DateTime?>? updatedAt,
      Value<DateTime?>? createdAt,
      Value<int>? rowid}) {
    return WorkersTableCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      permissions: permissions ?? this.permissions,
      todayCollected: todayCollected ?? this.todayCollected,
      monthTotal: monthTotal ?? this.monthTotal,
      lastModified: lastModified ?? this.lastModified,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      dirtyFlag: dirtyFlag ?? this.dirtyFlag,
      cloudId: cloudId ?? this.cloudId,
      deletedLocally: deletedLocally ?? this.deletedLocally,
      permissionsMask: permissionsMask ?? this.permissionsMask,
      ownerId: ownerId ?? this.ownerId,
      version: version ?? this.version,
      isDeleted: isDeleted ?? this.isDeleted,
      updatedAt: updatedAt ?? this.updatedAt,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (permissions.present) {
      map['permissions'] = Variable<String>(permissions.value);
    }
    if (todayCollected.present) {
      map['today_collected'] = Variable<double>(todayCollected.value);
    }
    if (monthTotal.present) {
      map['month_total'] = Variable<double>(monthTotal.value);
    }
    if (lastModified.present) {
      map['last_modified'] = Variable<DateTime>(lastModified.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (dirtyFlag.present) {
      map['dirty_flag'] = Variable<bool>(dirtyFlag.value);
    }
    if (cloudId.present) {
      map['cloud_id'] = Variable<String>(cloudId.value);
    }
    if (deletedLocally.present) {
      map['deleted_locally'] = Variable<bool>(deletedLocally.value);
    }
    if (permissionsMask.present) {
      map['permissions_mask'] = Variable<String>(permissionsMask.value);
    }
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkersTableCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('phone: $phone, ')
          ..write('permissions: $permissions, ')
          ..write('todayCollected: $todayCollected, ')
          ..write('monthTotal: $monthTotal, ')
          ..write('lastModified: $lastModified, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('dirtyFlag: $dirtyFlag, ')
          ..write('cloudId: $cloudId, ')
          ..write('deletedLocally: $deletedLocally, ')
          ..write('permissionsMask: $permissionsMask, ')
          ..write('ownerId: $ownerId, ')
          ..write('version: $version, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AuditLogTableTable extends AuditLogTable
    with TableInfo<$AuditLogTableTable, AuditLogEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AuditLogTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _userMeta = const VerificationMeta('user');
  @override
  late final GeneratedColumn<String> user = GeneratedColumn<String>(
      'user', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _actionMeta = const VerificationMeta('action');
  @override
  late final GeneratedColumn<String> action = GeneratedColumn<String>(
      'action', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _targetMeta = const VerificationMeta('target');
  @override
  late final GeneratedColumn<String> target = GeneratedColumn<String>(
      'target', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _detailsMeta =
      const VerificationMeta('details');
  @override
  late final GeneratedColumn<String> details = GeneratedColumn<String>(
      'details', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _timestampMeta =
      const VerificationMeta('timestamp');
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
      'timestamp', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _lastModifiedMeta =
      const VerificationMeta('lastModified');
  @override
  late final GeneratedColumn<DateTime> lastModified = GeneratedColumn<DateTime>(
      'last_modified', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _lastSyncedAtMeta =
      const VerificationMeta('lastSyncedAt');
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
      'last_synced_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('local_only'));
  static const VerificationMeta _dirtyFlagMeta =
      const VerificationMeta('dirtyFlag');
  @override
  late final GeneratedColumn<bool> dirtyFlag = GeneratedColumn<bool>(
      'dirty_flag', aliasedName, true,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("dirty_flag" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _cloudIdMeta =
      const VerificationMeta('cloudId');
  @override
  late final GeneratedColumn<String> cloudId = GeneratedColumn<String>(
      'cloud_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _deletedLocallyMeta =
      const VerificationMeta('deletedLocally');
  @override
  late final GeneratedColumn<bool> deletedLocally = GeneratedColumn<bool>(
      'deleted_locally', aliasedName, true,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("deleted_locally" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _permissionsMaskMeta =
      const VerificationMeta('permissionsMask');
  @override
  late final GeneratedColumn<String> permissionsMask = GeneratedColumn<String>(
      'permissions_mask', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _ownerIdMeta =
      const VerificationMeta('ownerId');
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
      'owner_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _versionMeta =
      const VerificationMeta('version');
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
      'version', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _isDeletedMeta =
      const VerificationMeta('isDeleted');
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
      'is_deleted', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_deleted" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        user,
        action,
        target,
        details,
        type,
        timestamp,
        lastModified,
        lastSyncedAt,
        syncStatus,
        dirtyFlag,
        cloudId,
        deletedLocally,
        permissionsMask,
        ownerId,
        version,
        isDeleted,
        updatedAt,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'audit_log_table';
  @override
  VerificationContext validateIntegrity(Insertable<AuditLogEntry> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user')) {
      context.handle(
          _userMeta, user.isAcceptableOrUnknown(data['user']!, _userMeta));
    } else if (isInserting) {
      context.missing(_userMeta);
    }
    if (data.containsKey('action')) {
      context.handle(_actionMeta,
          action.isAcceptableOrUnknown(data['action']!, _actionMeta));
    } else if (isInserting) {
      context.missing(_actionMeta);
    }
    if (data.containsKey('target')) {
      context.handle(_targetMeta,
          target.isAcceptableOrUnknown(data['target']!, _targetMeta));
    } else if (isInserting) {
      context.missing(_targetMeta);
    }
    if (data.containsKey('details')) {
      context.handle(_detailsMeta,
          details.isAcceptableOrUnknown(data['details']!, _detailsMeta));
    } else if (isInserting) {
      context.missing(_detailsMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('timestamp')) {
      context.handle(_timestampMeta,
          timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta));
    }
    if (data.containsKey('last_modified')) {
      context.handle(
          _lastModifiedMeta,
          lastModified.isAcceptableOrUnknown(
              data['last_modified']!, _lastModifiedMeta));
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
          _lastSyncedAtMeta,
          lastSyncedAt.isAcceptableOrUnknown(
              data['last_synced_at']!, _lastSyncedAtMeta));
    }
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
    }
    if (data.containsKey('dirty_flag')) {
      context.handle(_dirtyFlagMeta,
          dirtyFlag.isAcceptableOrUnknown(data['dirty_flag']!, _dirtyFlagMeta));
    }
    if (data.containsKey('cloud_id')) {
      context.handle(_cloudIdMeta,
          cloudId.isAcceptableOrUnknown(data['cloud_id']!, _cloudIdMeta));
    }
    if (data.containsKey('deleted_locally')) {
      context.handle(
          _deletedLocallyMeta,
          deletedLocally.isAcceptableOrUnknown(
              data['deleted_locally']!, _deletedLocallyMeta));
    }
    if (data.containsKey('permissions_mask')) {
      context.handle(
          _permissionsMaskMeta,
          permissionsMask.isAcceptableOrUnknown(
              data['permissions_mask']!, _permissionsMaskMeta));
    }
    if (data.containsKey('owner_id')) {
      context.handle(_ownerIdMeta,
          ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta));
    }
    if (data.containsKey('version')) {
      context.handle(_versionMeta,
          version.isAcceptableOrUnknown(data['version']!, _versionMeta));
    }
    if (data.containsKey('is_deleted')) {
      context.handle(_isDeletedMeta,
          isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AuditLogEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AuditLogEntry(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      user: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user'])!,
      action: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}action'])!,
      target: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}target'])!,
      details: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}details'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      timestamp: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}timestamp'])!,
      lastModified: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}last_modified']),
      lastSyncedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_synced_at']),
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status']),
      dirtyFlag: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}dirty_flag']),
      cloudId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}cloud_id']),
      deletedLocally: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}deleted_locally']),
      permissionsMask: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}permissions_mask']),
      ownerId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}owner_id']),
      version: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}version'])!,
      isDeleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_deleted'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at']),
    );
  }

  @override
  $AuditLogTableTable createAlias(String alias) {
    return $AuditLogTableTable(attachedDatabase, alias);
  }
}

class AuditLogEntry extends DataClass implements Insertable<AuditLogEntry> {
  final String id;
  final String user;
  final String action;
  final String target;
  final String details;
  final String type;
  final DateTime timestamp;
  final DateTime? lastModified;
  final DateTime? lastSyncedAt;
  final String? syncStatus;
  final bool? dirtyFlag;
  final String? cloudId;
  final bool? deletedLocally;
  final String? permissionsMask;
  final String? ownerId;
  final int version;
  final bool isDeleted;
  final DateTime? updatedAt;
  final DateTime? createdAt;
  const AuditLogEntry(
      {required this.id,
      required this.user,
      required this.action,
      required this.target,
      required this.details,
      required this.type,
      required this.timestamp,
      this.lastModified,
      this.lastSyncedAt,
      this.syncStatus,
      this.dirtyFlag,
      this.cloudId,
      this.deletedLocally,
      this.permissionsMask,
      this.ownerId,
      required this.version,
      required this.isDeleted,
      this.updatedAt,
      this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user'] = Variable<String>(user);
    map['action'] = Variable<String>(action);
    map['target'] = Variable<String>(target);
    map['details'] = Variable<String>(details);
    map['type'] = Variable<String>(type);
    map['timestamp'] = Variable<DateTime>(timestamp);
    if (!nullToAbsent || lastModified != null) {
      map['last_modified'] = Variable<DateTime>(lastModified);
    }
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    }
    if (!nullToAbsent || syncStatus != null) {
      map['sync_status'] = Variable<String>(syncStatus);
    }
    if (!nullToAbsent || dirtyFlag != null) {
      map['dirty_flag'] = Variable<bool>(dirtyFlag);
    }
    if (!nullToAbsent || cloudId != null) {
      map['cloud_id'] = Variable<String>(cloudId);
    }
    if (!nullToAbsent || deletedLocally != null) {
      map['deleted_locally'] = Variable<bool>(deletedLocally);
    }
    if (!nullToAbsent || permissionsMask != null) {
      map['permissions_mask'] = Variable<String>(permissionsMask);
    }
    if (!nullToAbsent || ownerId != null) {
      map['owner_id'] = Variable<String>(ownerId);
    }
    map['version'] = Variable<int>(version);
    map['is_deleted'] = Variable<bool>(isDeleted);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<DateTime>(createdAt);
    }
    return map;
  }

  AuditLogTableCompanion toCompanion(bool nullToAbsent) {
    return AuditLogTableCompanion(
      id: Value(id),
      user: Value(user),
      action: Value(action),
      target: Value(target),
      details: Value(details),
      type: Value(type),
      timestamp: Value(timestamp),
      lastModified: lastModified == null && nullToAbsent
          ? const Value.absent()
          : Value(lastModified),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
      syncStatus: syncStatus == null && nullToAbsent
          ? const Value.absent()
          : Value(syncStatus),
      dirtyFlag: dirtyFlag == null && nullToAbsent
          ? const Value.absent()
          : Value(dirtyFlag),
      cloudId: cloudId == null && nullToAbsent
          ? const Value.absent()
          : Value(cloudId),
      deletedLocally: deletedLocally == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedLocally),
      permissionsMask: permissionsMask == null && nullToAbsent
          ? const Value.absent()
          : Value(permissionsMask),
      ownerId: ownerId == null && nullToAbsent
          ? const Value.absent()
          : Value(ownerId),
      version: Value(version),
      isDeleted: Value(isDeleted),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
    );
  }

  factory AuditLogEntry.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AuditLogEntry(
      id: serializer.fromJson<String>(json['id']),
      user: serializer.fromJson<String>(json['user']),
      action: serializer.fromJson<String>(json['action']),
      target: serializer.fromJson<String>(json['target']),
      details: serializer.fromJson<String>(json['details']),
      type: serializer.fromJson<String>(json['type']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
      lastModified: serializer.fromJson<DateTime?>(json['lastModified']),
      lastSyncedAt: serializer.fromJson<DateTime?>(json['lastSyncedAt']),
      syncStatus: serializer.fromJson<String?>(json['syncStatus']),
      dirtyFlag: serializer.fromJson<bool?>(json['dirtyFlag']),
      cloudId: serializer.fromJson<String?>(json['cloudId']),
      deletedLocally: serializer.fromJson<bool?>(json['deletedLocally']),
      permissionsMask: serializer.fromJson<String?>(json['permissionsMask']),
      ownerId: serializer.fromJson<String?>(json['ownerId']),
      version: serializer.fromJson<int>(json['version']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      createdAt: serializer.fromJson<DateTime?>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'user': serializer.toJson<String>(user),
      'action': serializer.toJson<String>(action),
      'target': serializer.toJson<String>(target),
      'details': serializer.toJson<String>(details),
      'type': serializer.toJson<String>(type),
      'timestamp': serializer.toJson<DateTime>(timestamp),
      'lastModified': serializer.toJson<DateTime?>(lastModified),
      'lastSyncedAt': serializer.toJson<DateTime?>(lastSyncedAt),
      'syncStatus': serializer.toJson<String?>(syncStatus),
      'dirtyFlag': serializer.toJson<bool?>(dirtyFlag),
      'cloudId': serializer.toJson<String?>(cloudId),
      'deletedLocally': serializer.toJson<bool?>(deletedLocally),
      'permissionsMask': serializer.toJson<String?>(permissionsMask),
      'ownerId': serializer.toJson<String?>(ownerId),
      'version': serializer.toJson<int>(version),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'createdAt': serializer.toJson<DateTime?>(createdAt),
    };
  }

  AuditLogEntry copyWith(
          {String? id,
          String? user,
          String? action,
          String? target,
          String? details,
          String? type,
          DateTime? timestamp,
          Value<DateTime?> lastModified = const Value.absent(),
          Value<DateTime?> lastSyncedAt = const Value.absent(),
          Value<String?> syncStatus = const Value.absent(),
          Value<bool?> dirtyFlag = const Value.absent(),
          Value<String?> cloudId = const Value.absent(),
          Value<bool?> deletedLocally = const Value.absent(),
          Value<String?> permissionsMask = const Value.absent(),
          Value<String?> ownerId = const Value.absent(),
          int? version,
          bool? isDeleted,
          Value<DateTime?> updatedAt = const Value.absent(),
          Value<DateTime?> createdAt = const Value.absent()}) =>
      AuditLogEntry(
        id: id ?? this.id,
        user: user ?? this.user,
        action: action ?? this.action,
        target: target ?? this.target,
        details: details ?? this.details,
        type: type ?? this.type,
        timestamp: timestamp ?? this.timestamp,
        lastModified:
            lastModified.present ? lastModified.value : this.lastModified,
        lastSyncedAt:
            lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
        syncStatus: syncStatus.present ? syncStatus.value : this.syncStatus,
        dirtyFlag: dirtyFlag.present ? dirtyFlag.value : this.dirtyFlag,
        cloudId: cloudId.present ? cloudId.value : this.cloudId,
        deletedLocally:
            deletedLocally.present ? deletedLocally.value : this.deletedLocally,
        permissionsMask: permissionsMask.present
            ? permissionsMask.value
            : this.permissionsMask,
        ownerId: ownerId.present ? ownerId.value : this.ownerId,
        version: version ?? this.version,
        isDeleted: isDeleted ?? this.isDeleted,
        updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
        createdAt: createdAt.present ? createdAt.value : this.createdAt,
      );
  AuditLogEntry copyWithCompanion(AuditLogTableCompanion data) {
    return AuditLogEntry(
      id: data.id.present ? data.id.value : this.id,
      user: data.user.present ? data.user.value : this.user,
      action: data.action.present ? data.action.value : this.action,
      target: data.target.present ? data.target.value : this.target,
      details: data.details.present ? data.details.value : this.details,
      type: data.type.present ? data.type.value : this.type,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      lastModified: data.lastModified.present
          ? data.lastModified.value
          : this.lastModified,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
      dirtyFlag: data.dirtyFlag.present ? data.dirtyFlag.value : this.dirtyFlag,
      cloudId: data.cloudId.present ? data.cloudId.value : this.cloudId,
      deletedLocally: data.deletedLocally.present
          ? data.deletedLocally.value
          : this.deletedLocally,
      permissionsMask: data.permissionsMask.present
          ? data.permissionsMask.value
          : this.permissionsMask,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      version: data.version.present ? data.version.value : this.version,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AuditLogEntry(')
          ..write('id: $id, ')
          ..write('user: $user, ')
          ..write('action: $action, ')
          ..write('target: $target, ')
          ..write('details: $details, ')
          ..write('type: $type, ')
          ..write('timestamp: $timestamp, ')
          ..write('lastModified: $lastModified, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('dirtyFlag: $dirtyFlag, ')
          ..write('cloudId: $cloudId, ')
          ..write('deletedLocally: $deletedLocally, ')
          ..write('permissionsMask: $permissionsMask, ')
          ..write('ownerId: $ownerId, ')
          ..write('version: $version, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      user,
      action,
      target,
      details,
      type,
      timestamp,
      lastModified,
      lastSyncedAt,
      syncStatus,
      dirtyFlag,
      cloudId,
      deletedLocally,
      permissionsMask,
      ownerId,
      version,
      isDeleted,
      updatedAt,
      createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AuditLogEntry &&
          other.id == this.id &&
          other.user == this.user &&
          other.action == this.action &&
          other.target == this.target &&
          other.details == this.details &&
          other.type == this.type &&
          other.timestamp == this.timestamp &&
          other.lastModified == this.lastModified &&
          other.lastSyncedAt == this.lastSyncedAt &&
          other.syncStatus == this.syncStatus &&
          other.dirtyFlag == this.dirtyFlag &&
          other.cloudId == this.cloudId &&
          other.deletedLocally == this.deletedLocally &&
          other.permissionsMask == this.permissionsMask &&
          other.ownerId == this.ownerId &&
          other.version == this.version &&
          other.isDeleted == this.isDeleted &&
          other.updatedAt == this.updatedAt &&
          other.createdAt == this.createdAt);
}

class AuditLogTableCompanion extends UpdateCompanion<AuditLogEntry> {
  final Value<String> id;
  final Value<String> user;
  final Value<String> action;
  final Value<String> target;
  final Value<String> details;
  final Value<String> type;
  final Value<DateTime> timestamp;
  final Value<DateTime?> lastModified;
  final Value<DateTime?> lastSyncedAt;
  final Value<String?> syncStatus;
  final Value<bool?> dirtyFlag;
  final Value<String?> cloudId;
  final Value<bool?> deletedLocally;
  final Value<String?> permissionsMask;
  final Value<String?> ownerId;
  final Value<int> version;
  final Value<bool> isDeleted;
  final Value<DateTime?> updatedAt;
  final Value<DateTime?> createdAt;
  final Value<int> rowid;
  const AuditLogTableCompanion({
    this.id = const Value.absent(),
    this.user = const Value.absent(),
    this.action = const Value.absent(),
    this.target = const Value.absent(),
    this.details = const Value.absent(),
    this.type = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.lastModified = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.dirtyFlag = const Value.absent(),
    this.cloudId = const Value.absent(),
    this.deletedLocally = const Value.absent(),
    this.permissionsMask = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.version = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AuditLogTableCompanion.insert({
    required String id,
    required String user,
    required String action,
    required String target,
    required String details,
    required String type,
    this.timestamp = const Value.absent(),
    this.lastModified = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.dirtyFlag = const Value.absent(),
    this.cloudId = const Value.absent(),
    this.deletedLocally = const Value.absent(),
    this.permissionsMask = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.version = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        user = Value(user),
        action = Value(action),
        target = Value(target),
        details = Value(details),
        type = Value(type);
  static Insertable<AuditLogEntry> custom({
    Expression<String>? id,
    Expression<String>? user,
    Expression<String>? action,
    Expression<String>? target,
    Expression<String>? details,
    Expression<String>? type,
    Expression<DateTime>? timestamp,
    Expression<DateTime>? lastModified,
    Expression<DateTime>? lastSyncedAt,
    Expression<String>? syncStatus,
    Expression<bool>? dirtyFlag,
    Expression<String>? cloudId,
    Expression<bool>? deletedLocally,
    Expression<String>? permissionsMask,
    Expression<String>? ownerId,
    Expression<int>? version,
    Expression<bool>? isDeleted,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (user != null) 'user': user,
      if (action != null) 'action': action,
      if (target != null) 'target': target,
      if (details != null) 'details': details,
      if (type != null) 'type': type,
      if (timestamp != null) 'timestamp': timestamp,
      if (lastModified != null) 'last_modified': lastModified,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (dirtyFlag != null) 'dirty_flag': dirtyFlag,
      if (cloudId != null) 'cloud_id': cloudId,
      if (deletedLocally != null) 'deleted_locally': deletedLocally,
      if (permissionsMask != null) 'permissions_mask': permissionsMask,
      if (ownerId != null) 'owner_id': ownerId,
      if (version != null) 'version': version,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AuditLogTableCompanion copyWith(
      {Value<String>? id,
      Value<String>? user,
      Value<String>? action,
      Value<String>? target,
      Value<String>? details,
      Value<String>? type,
      Value<DateTime>? timestamp,
      Value<DateTime?>? lastModified,
      Value<DateTime?>? lastSyncedAt,
      Value<String?>? syncStatus,
      Value<bool?>? dirtyFlag,
      Value<String?>? cloudId,
      Value<bool?>? deletedLocally,
      Value<String?>? permissionsMask,
      Value<String?>? ownerId,
      Value<int>? version,
      Value<bool>? isDeleted,
      Value<DateTime?>? updatedAt,
      Value<DateTime?>? createdAt,
      Value<int>? rowid}) {
    return AuditLogTableCompanion(
      id: id ?? this.id,
      user: user ?? this.user,
      action: action ?? this.action,
      target: target ?? this.target,
      details: details ?? this.details,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      lastModified: lastModified ?? this.lastModified,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      dirtyFlag: dirtyFlag ?? this.dirtyFlag,
      cloudId: cloudId ?? this.cloudId,
      deletedLocally: deletedLocally ?? this.deletedLocally,
      permissionsMask: permissionsMask ?? this.permissionsMask,
      ownerId: ownerId ?? this.ownerId,
      version: version ?? this.version,
      isDeleted: isDeleted ?? this.isDeleted,
      updatedAt: updatedAt ?? this.updatedAt,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (user.present) {
      map['user'] = Variable<String>(user.value);
    }
    if (action.present) {
      map['action'] = Variable<String>(action.value);
    }
    if (target.present) {
      map['target'] = Variable<String>(target.value);
    }
    if (details.present) {
      map['details'] = Variable<String>(details.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    if (lastModified.present) {
      map['last_modified'] = Variable<DateTime>(lastModified.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (dirtyFlag.present) {
      map['dirty_flag'] = Variable<bool>(dirtyFlag.value);
    }
    if (cloudId.present) {
      map['cloud_id'] = Variable<String>(cloudId.value);
    }
    if (deletedLocally.present) {
      map['deleted_locally'] = Variable<bool>(deletedLocally.value);
    }
    if (permissionsMask.present) {
      map['permissions_mask'] = Variable<String>(permissionsMask.value);
    }
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AuditLogTableCompanion(')
          ..write('id: $id, ')
          ..write('user: $user, ')
          ..write('action: $action, ')
          ..write('target: $target, ')
          ..write('details: $details, ')
          ..write('type: $type, ')
          ..write('timestamp: $timestamp, ')
          ..write('lastModified: $lastModified, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('dirtyFlag: $dirtyFlag, ')
          ..write('cloudId: $cloudId, ')
          ..write('deletedLocally: $deletedLocally, ')
          ..write('permissionsMask: $permissionsMask, ')
          ..write('ownerId: $ownerId, ')
          ..write('version: $version, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WhatsappTemplatesTableTable extends WhatsappTemplatesTable
    with TableInfo<$WhatsappTemplatesTableTable, WhatsappTemplateData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WhatsappTemplatesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _contentMeta =
      const VerificationMeta('content');
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
      'content', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _isActiveMeta =
      const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<int> isActive = GeneratedColumn<int>(
      'is_active', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _lastModifiedMeta =
      const VerificationMeta('lastModified');
  @override
  late final GeneratedColumn<DateTime> lastModified = GeneratedColumn<DateTime>(
      'last_modified', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _lastSyncedAtMeta =
      const VerificationMeta('lastSyncedAt');
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
      'last_synced_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('local_only'));
  static const VerificationMeta _dirtyFlagMeta =
      const VerificationMeta('dirtyFlag');
  @override
  late final GeneratedColumn<bool> dirtyFlag = GeneratedColumn<bool>(
      'dirty_flag', aliasedName, true,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("dirty_flag" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _cloudIdMeta =
      const VerificationMeta('cloudId');
  @override
  late final GeneratedColumn<String> cloudId = GeneratedColumn<String>(
      'cloud_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _deletedLocallyMeta =
      const VerificationMeta('deletedLocally');
  @override
  late final GeneratedColumn<bool> deletedLocally = GeneratedColumn<bool>(
      'deleted_locally', aliasedName, true,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("deleted_locally" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _permissionsMaskMeta =
      const VerificationMeta('permissionsMask');
  @override
  late final GeneratedColumn<String> permissionsMask = GeneratedColumn<String>(
      'permissions_mask', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _ownerIdMeta =
      const VerificationMeta('ownerId');
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
      'owner_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _versionMeta =
      const VerificationMeta('version');
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
      'version', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _isDeletedMeta =
      const VerificationMeta('isDeleted');
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
      'is_deleted', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_deleted" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        title,
        content,
        isActive,
        lastModified,
        lastSyncedAt,
        syncStatus,
        dirtyFlag,
        cloudId,
        deletedLocally,
        permissionsMask,
        ownerId,
        version,
        isDeleted,
        updatedAt,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'whatsapp_templates_table';
  @override
  VerificationContext validateIntegrity(
      Insertable<WhatsappTemplateData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('content')) {
      context.handle(_contentMeta,
          content.isAcceptableOrUnknown(data['content']!, _contentMeta));
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    if (data.containsKey('last_modified')) {
      context.handle(
          _lastModifiedMeta,
          lastModified.isAcceptableOrUnknown(
              data['last_modified']!, _lastModifiedMeta));
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
          _lastSyncedAtMeta,
          lastSyncedAt.isAcceptableOrUnknown(
              data['last_synced_at']!, _lastSyncedAtMeta));
    }
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
    }
    if (data.containsKey('dirty_flag')) {
      context.handle(_dirtyFlagMeta,
          dirtyFlag.isAcceptableOrUnknown(data['dirty_flag']!, _dirtyFlagMeta));
    }
    if (data.containsKey('cloud_id')) {
      context.handle(_cloudIdMeta,
          cloudId.isAcceptableOrUnknown(data['cloud_id']!, _cloudIdMeta));
    }
    if (data.containsKey('deleted_locally')) {
      context.handle(
          _deletedLocallyMeta,
          deletedLocally.isAcceptableOrUnknown(
              data['deleted_locally']!, _deletedLocallyMeta));
    }
    if (data.containsKey('permissions_mask')) {
      context.handle(
          _permissionsMaskMeta,
          permissionsMask.isAcceptableOrUnknown(
              data['permissions_mask']!, _permissionsMaskMeta));
    }
    if (data.containsKey('owner_id')) {
      context.handle(_ownerIdMeta,
          ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta));
    }
    if (data.containsKey('version')) {
      context.handle(_versionMeta,
          version.isAcceptableOrUnknown(data['version']!, _versionMeta));
    }
    if (data.containsKey('is_deleted')) {
      context.handle(_isDeletedMeta,
          isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WhatsappTemplateData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WhatsappTemplateData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      content: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}content'])!,
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}is_active'])!,
      lastModified: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}last_modified']),
      lastSyncedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_synced_at']),
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status']),
      dirtyFlag: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}dirty_flag']),
      cloudId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}cloud_id']),
      deletedLocally: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}deleted_locally']),
      permissionsMask: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}permissions_mask']),
      ownerId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}owner_id']),
      version: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}version'])!,
      isDeleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_deleted'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $WhatsappTemplatesTableTable createAlias(String alias) {
    return $WhatsappTemplatesTableTable(attachedDatabase, alias);
  }
}

class WhatsappTemplateData extends DataClass
    implements Insertable<WhatsappTemplateData> {
  final String id;
  final String title;
  final String content;
  final int isActive;
  final DateTime? lastModified;
  final DateTime? lastSyncedAt;
  final String? syncStatus;
  final bool? dirtyFlag;
  final String? cloudId;
  final bool? deletedLocally;
  final String? permissionsMask;
  final String? ownerId;
  final int version;
  final bool isDeleted;
  final DateTime updatedAt;
  final DateTime createdAt;
  const WhatsappTemplateData(
      {required this.id,
      required this.title,
      required this.content,
      required this.isActive,
      this.lastModified,
      this.lastSyncedAt,
      this.syncStatus,
      this.dirtyFlag,
      this.cloudId,
      this.deletedLocally,
      this.permissionsMask,
      this.ownerId,
      required this.version,
      required this.isDeleted,
      required this.updatedAt,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['content'] = Variable<String>(content);
    map['is_active'] = Variable<int>(isActive);
    if (!nullToAbsent || lastModified != null) {
      map['last_modified'] = Variable<DateTime>(lastModified);
    }
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    }
    if (!nullToAbsent || syncStatus != null) {
      map['sync_status'] = Variable<String>(syncStatus);
    }
    if (!nullToAbsent || dirtyFlag != null) {
      map['dirty_flag'] = Variable<bool>(dirtyFlag);
    }
    if (!nullToAbsent || cloudId != null) {
      map['cloud_id'] = Variable<String>(cloudId);
    }
    if (!nullToAbsent || deletedLocally != null) {
      map['deleted_locally'] = Variable<bool>(deletedLocally);
    }
    if (!nullToAbsent || permissionsMask != null) {
      map['permissions_mask'] = Variable<String>(permissionsMask);
    }
    if (!nullToAbsent || ownerId != null) {
      map['owner_id'] = Variable<String>(ownerId);
    }
    map['version'] = Variable<int>(version);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  WhatsappTemplatesTableCompanion toCompanion(bool nullToAbsent) {
    return WhatsappTemplatesTableCompanion(
      id: Value(id),
      title: Value(title),
      content: Value(content),
      isActive: Value(isActive),
      lastModified: lastModified == null && nullToAbsent
          ? const Value.absent()
          : Value(lastModified),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
      syncStatus: syncStatus == null && nullToAbsent
          ? const Value.absent()
          : Value(syncStatus),
      dirtyFlag: dirtyFlag == null && nullToAbsent
          ? const Value.absent()
          : Value(dirtyFlag),
      cloudId: cloudId == null && nullToAbsent
          ? const Value.absent()
          : Value(cloudId),
      deletedLocally: deletedLocally == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedLocally),
      permissionsMask: permissionsMask == null && nullToAbsent
          ? const Value.absent()
          : Value(permissionsMask),
      ownerId: ownerId == null && nullToAbsent
          ? const Value.absent()
          : Value(ownerId),
      version: Value(version),
      isDeleted: Value(isDeleted),
      updatedAt: Value(updatedAt),
      createdAt: Value(createdAt),
    );
  }

  factory WhatsappTemplateData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WhatsappTemplateData(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      content: serializer.fromJson<String>(json['content']),
      isActive: serializer.fromJson<int>(json['isActive']),
      lastModified: serializer.fromJson<DateTime?>(json['lastModified']),
      lastSyncedAt: serializer.fromJson<DateTime?>(json['lastSyncedAt']),
      syncStatus: serializer.fromJson<String?>(json['syncStatus']),
      dirtyFlag: serializer.fromJson<bool?>(json['dirtyFlag']),
      cloudId: serializer.fromJson<String?>(json['cloudId']),
      deletedLocally: serializer.fromJson<bool?>(json['deletedLocally']),
      permissionsMask: serializer.fromJson<String?>(json['permissionsMask']),
      ownerId: serializer.fromJson<String?>(json['ownerId']),
      version: serializer.fromJson<int>(json['version']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'content': serializer.toJson<String>(content),
      'isActive': serializer.toJson<int>(isActive),
      'lastModified': serializer.toJson<DateTime?>(lastModified),
      'lastSyncedAt': serializer.toJson<DateTime?>(lastSyncedAt),
      'syncStatus': serializer.toJson<String?>(syncStatus),
      'dirtyFlag': serializer.toJson<bool?>(dirtyFlag),
      'cloudId': serializer.toJson<String?>(cloudId),
      'deletedLocally': serializer.toJson<bool?>(deletedLocally),
      'permissionsMask': serializer.toJson<String?>(permissionsMask),
      'ownerId': serializer.toJson<String?>(ownerId),
      'version': serializer.toJson<int>(version),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  WhatsappTemplateData copyWith(
          {String? id,
          String? title,
          String? content,
          int? isActive,
          Value<DateTime?> lastModified = const Value.absent(),
          Value<DateTime?> lastSyncedAt = const Value.absent(),
          Value<String?> syncStatus = const Value.absent(),
          Value<bool?> dirtyFlag = const Value.absent(),
          Value<String?> cloudId = const Value.absent(),
          Value<bool?> deletedLocally = const Value.absent(),
          Value<String?> permissionsMask = const Value.absent(),
          Value<String?> ownerId = const Value.absent(),
          int? version,
          bool? isDeleted,
          DateTime? updatedAt,
          DateTime? createdAt}) =>
      WhatsappTemplateData(
        id: id ?? this.id,
        title: title ?? this.title,
        content: content ?? this.content,
        isActive: isActive ?? this.isActive,
        lastModified:
            lastModified.present ? lastModified.value : this.lastModified,
        lastSyncedAt:
            lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
        syncStatus: syncStatus.present ? syncStatus.value : this.syncStatus,
        dirtyFlag: dirtyFlag.present ? dirtyFlag.value : this.dirtyFlag,
        cloudId: cloudId.present ? cloudId.value : this.cloudId,
        deletedLocally:
            deletedLocally.present ? deletedLocally.value : this.deletedLocally,
        permissionsMask: permissionsMask.present
            ? permissionsMask.value
            : this.permissionsMask,
        ownerId: ownerId.present ? ownerId.value : this.ownerId,
        version: version ?? this.version,
        isDeleted: isDeleted ?? this.isDeleted,
        updatedAt: updatedAt ?? this.updatedAt,
        createdAt: createdAt ?? this.createdAt,
      );
  WhatsappTemplateData copyWithCompanion(WhatsappTemplatesTableCompanion data) {
    return WhatsappTemplateData(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      content: data.content.present ? data.content.value : this.content,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      lastModified: data.lastModified.present
          ? data.lastModified.value
          : this.lastModified,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
      dirtyFlag: data.dirtyFlag.present ? data.dirtyFlag.value : this.dirtyFlag,
      cloudId: data.cloudId.present ? data.cloudId.value : this.cloudId,
      deletedLocally: data.deletedLocally.present
          ? data.deletedLocally.value
          : this.deletedLocally,
      permissionsMask: data.permissionsMask.present
          ? data.permissionsMask.value
          : this.permissionsMask,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      version: data.version.present ? data.version.value : this.version,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WhatsappTemplateData(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('content: $content, ')
          ..write('isActive: $isActive, ')
          ..write('lastModified: $lastModified, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('dirtyFlag: $dirtyFlag, ')
          ..write('cloudId: $cloudId, ')
          ..write('deletedLocally: $deletedLocally, ')
          ..write('permissionsMask: $permissionsMask, ')
          ..write('ownerId: $ownerId, ')
          ..write('version: $version, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      title,
      content,
      isActive,
      lastModified,
      lastSyncedAt,
      syncStatus,
      dirtyFlag,
      cloudId,
      deletedLocally,
      permissionsMask,
      ownerId,
      version,
      isDeleted,
      updatedAt,
      createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WhatsappTemplateData &&
          other.id == this.id &&
          other.title == this.title &&
          other.content == this.content &&
          other.isActive == this.isActive &&
          other.lastModified == this.lastModified &&
          other.lastSyncedAt == this.lastSyncedAt &&
          other.syncStatus == this.syncStatus &&
          other.dirtyFlag == this.dirtyFlag &&
          other.cloudId == this.cloudId &&
          other.deletedLocally == this.deletedLocally &&
          other.permissionsMask == this.permissionsMask &&
          other.ownerId == this.ownerId &&
          other.version == this.version &&
          other.isDeleted == this.isDeleted &&
          other.updatedAt == this.updatedAt &&
          other.createdAt == this.createdAt);
}

class WhatsappTemplatesTableCompanion
    extends UpdateCompanion<WhatsappTemplateData> {
  final Value<String> id;
  final Value<String> title;
  final Value<String> content;
  final Value<int> isActive;
  final Value<DateTime?> lastModified;
  final Value<DateTime?> lastSyncedAt;
  final Value<String?> syncStatus;
  final Value<bool?> dirtyFlag;
  final Value<String?> cloudId;
  final Value<bool?> deletedLocally;
  final Value<String?> permissionsMask;
  final Value<String?> ownerId;
  final Value<int> version;
  final Value<bool> isDeleted;
  final Value<DateTime> updatedAt;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const WhatsappTemplatesTableCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.content = const Value.absent(),
    this.isActive = const Value.absent(),
    this.lastModified = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.dirtyFlag = const Value.absent(),
    this.cloudId = const Value.absent(),
    this.deletedLocally = const Value.absent(),
    this.permissionsMask = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.version = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WhatsappTemplatesTableCompanion.insert({
    required String id,
    required String title,
    required String content,
    this.isActive = const Value.absent(),
    this.lastModified = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.dirtyFlag = const Value.absent(),
    this.cloudId = const Value.absent(),
    this.deletedLocally = const Value.absent(),
    this.permissionsMask = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.version = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        title = Value(title),
        content = Value(content);
  static Insertable<WhatsappTemplateData> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? content,
    Expression<int>? isActive,
    Expression<DateTime>? lastModified,
    Expression<DateTime>? lastSyncedAt,
    Expression<String>? syncStatus,
    Expression<bool>? dirtyFlag,
    Expression<String>? cloudId,
    Expression<bool>? deletedLocally,
    Expression<String>? permissionsMask,
    Expression<String>? ownerId,
    Expression<int>? version,
    Expression<bool>? isDeleted,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (content != null) 'content': content,
      if (isActive != null) 'is_active': isActive,
      if (lastModified != null) 'last_modified': lastModified,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (dirtyFlag != null) 'dirty_flag': dirtyFlag,
      if (cloudId != null) 'cloud_id': cloudId,
      if (deletedLocally != null) 'deleted_locally': deletedLocally,
      if (permissionsMask != null) 'permissions_mask': permissionsMask,
      if (ownerId != null) 'owner_id': ownerId,
      if (version != null) 'version': version,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WhatsappTemplatesTableCompanion copyWith(
      {Value<String>? id,
      Value<String>? title,
      Value<String>? content,
      Value<int>? isActive,
      Value<DateTime?>? lastModified,
      Value<DateTime?>? lastSyncedAt,
      Value<String?>? syncStatus,
      Value<bool?>? dirtyFlag,
      Value<String?>? cloudId,
      Value<bool?>? deletedLocally,
      Value<String?>? permissionsMask,
      Value<String?>? ownerId,
      Value<int>? version,
      Value<bool>? isDeleted,
      Value<DateTime>? updatedAt,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return WhatsappTemplatesTableCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      isActive: isActive ?? this.isActive,
      lastModified: lastModified ?? this.lastModified,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      dirtyFlag: dirtyFlag ?? this.dirtyFlag,
      cloudId: cloudId ?? this.cloudId,
      deletedLocally: deletedLocally ?? this.deletedLocally,
      permissionsMask: permissionsMask ?? this.permissionsMask,
      ownerId: ownerId ?? this.ownerId,
      version: version ?? this.version,
      isDeleted: isDeleted ?? this.isDeleted,
      updatedAt: updatedAt ?? this.updatedAt,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<int>(isActive.value);
    }
    if (lastModified.present) {
      map['last_modified'] = Variable<DateTime>(lastModified.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (dirtyFlag.present) {
      map['dirty_flag'] = Variable<bool>(dirtyFlag.value);
    }
    if (cloudId.present) {
      map['cloud_id'] = Variable<String>(cloudId.value);
    }
    if (deletedLocally.present) {
      map['deleted_locally'] = Variable<bool>(deletedLocally.value);
    }
    if (permissionsMask.present) {
      map['permissions_mask'] = Variable<String>(permissionsMask.value);
    }
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WhatsappTemplatesTableCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('content: $content, ')
          ..write('isActive: $isActive, ')
          ..write('lastModified: $lastModified, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('dirtyFlag: $dirtyFlag, ')
          ..write('cloudId: $cloudId, ')
          ..write('deletedLocally: $deletedLocally, ')
          ..write('permissionsMask: $permissionsMask, ')
          ..write('ownerId: $ownerId, ')
          ..write('version: $version, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GeneratorSettingsTableTable extends GeneratorSettingsTable
    with TableInfo<$GeneratorSettingsTableTable, GeneratorSettingsData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GeneratorSettingsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _phoneNumberMeta =
      const VerificationMeta('phoneNumber');
  @override
  late final GeneratedColumn<String> phoneNumber = GeneratedColumn<String>(
      'phone_number', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _addressMeta =
      const VerificationMeta('address');
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
      'address', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _logoPathMeta =
      const VerificationMeta('logoPath');
  @override
  late final GeneratedColumn<String> logoPath = GeneratedColumn<String>(
      'logo_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _ownerIdMeta =
      const VerificationMeta('ownerId');
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
      'owner_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _versionMeta =
      const VerificationMeta('version');
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
      'version', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _isDeletedMeta =
      const VerificationMeta('isDeleted');
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
      'is_deleted', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_deleted" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        phoneNumber,
        address,
        logoPath,
        ownerId,
        version,
        isDeleted,
        updatedAt,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'generator_settings_table';
  @override
  VerificationContext validateIntegrity(
      Insertable<GeneratorSettingsData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('phone_number')) {
      context.handle(
          _phoneNumberMeta,
          phoneNumber.isAcceptableOrUnknown(
              data['phone_number']!, _phoneNumberMeta));
    } else if (isInserting) {
      context.missing(_phoneNumberMeta);
    }
    if (data.containsKey('address')) {
      context.handle(_addressMeta,
          address.isAcceptableOrUnknown(data['address']!, _addressMeta));
    } else if (isInserting) {
      context.missing(_addressMeta);
    }
    if (data.containsKey('logo_path')) {
      context.handle(_logoPathMeta,
          logoPath.isAcceptableOrUnknown(data['logo_path']!, _logoPathMeta));
    }
    if (data.containsKey('owner_id')) {
      context.handle(_ownerIdMeta,
          ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta));
    }
    if (data.containsKey('version')) {
      context.handle(_versionMeta,
          version.isAcceptableOrUnknown(data['version']!, _versionMeta));
    }
    if (data.containsKey('is_deleted')) {
      context.handle(_isDeletedMeta,
          isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GeneratorSettingsData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GeneratorSettingsData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      phoneNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}phone_number'])!,
      address: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}address'])!,
      logoPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}logo_path']),
      ownerId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}owner_id']),
      version: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}version'])!,
      isDeleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_deleted'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $GeneratorSettingsTableTable createAlias(String alias) {
    return $GeneratorSettingsTableTable(attachedDatabase, alias);
  }
}

class GeneratorSettingsData extends DataClass
    implements Insertable<GeneratorSettingsData> {
  final String id;
  final String name;
  final String phoneNumber;
  final String address;
  final String? logoPath;
  final String? ownerId;
  final int version;
  final bool isDeleted;
  final DateTime updatedAt;
  final DateTime createdAt;
  const GeneratorSettingsData(
      {required this.id,
      required this.name,
      required this.phoneNumber,
      required this.address,
      this.logoPath,
      this.ownerId,
      required this.version,
      required this.isDeleted,
      required this.updatedAt,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['phone_number'] = Variable<String>(phoneNumber);
    map['address'] = Variable<String>(address);
    if (!nullToAbsent || logoPath != null) {
      map['logo_path'] = Variable<String>(logoPath);
    }
    if (!nullToAbsent || ownerId != null) {
      map['owner_id'] = Variable<String>(ownerId);
    }
    map['version'] = Variable<int>(version);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  GeneratorSettingsTableCompanion toCompanion(bool nullToAbsent) {
    return GeneratorSettingsTableCompanion(
      id: Value(id),
      name: Value(name),
      phoneNumber: Value(phoneNumber),
      address: Value(address),
      logoPath: logoPath == null && nullToAbsent
          ? const Value.absent()
          : Value(logoPath),
      ownerId: ownerId == null && nullToAbsent
          ? const Value.absent()
          : Value(ownerId),
      version: Value(version),
      isDeleted: Value(isDeleted),
      updatedAt: Value(updatedAt),
      createdAt: Value(createdAt),
    );
  }

  factory GeneratorSettingsData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GeneratorSettingsData(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      phoneNumber: serializer.fromJson<String>(json['phoneNumber']),
      address: serializer.fromJson<String>(json['address']),
      logoPath: serializer.fromJson<String?>(json['logoPath']),
      ownerId: serializer.fromJson<String?>(json['ownerId']),
      version: serializer.fromJson<int>(json['version']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'phoneNumber': serializer.toJson<String>(phoneNumber),
      'address': serializer.toJson<String>(address),
      'logoPath': serializer.toJson<String?>(logoPath),
      'ownerId': serializer.toJson<String?>(ownerId),
      'version': serializer.toJson<int>(version),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  GeneratorSettingsData copyWith(
          {String? id,
          String? name,
          String? phoneNumber,
          String? address,
          Value<String?> logoPath = const Value.absent(),
          Value<String?> ownerId = const Value.absent(),
          int? version,
          bool? isDeleted,
          DateTime? updatedAt,
          DateTime? createdAt}) =>
      GeneratorSettingsData(
        id: id ?? this.id,
        name: name ?? this.name,
        phoneNumber: phoneNumber ?? this.phoneNumber,
        address: address ?? this.address,
        logoPath: logoPath.present ? logoPath.value : this.logoPath,
        ownerId: ownerId.present ? ownerId.value : this.ownerId,
        version: version ?? this.version,
        isDeleted: isDeleted ?? this.isDeleted,
        updatedAt: updatedAt ?? this.updatedAt,
        createdAt: createdAt ?? this.createdAt,
      );
  GeneratorSettingsData copyWithCompanion(
      GeneratorSettingsTableCompanion data) {
    return GeneratorSettingsData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      phoneNumber:
          data.phoneNumber.present ? data.phoneNumber.value : this.phoneNumber,
      address: data.address.present ? data.address.value : this.address,
      logoPath: data.logoPath.present ? data.logoPath.value : this.logoPath,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      version: data.version.present ? data.version.value : this.version,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GeneratorSettingsData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('phoneNumber: $phoneNumber, ')
          ..write('address: $address, ')
          ..write('logoPath: $logoPath, ')
          ..write('ownerId: $ownerId, ')
          ..write('version: $version, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, phoneNumber, address, logoPath,
      ownerId, version, isDeleted, updatedAt, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GeneratorSettingsData &&
          other.id == this.id &&
          other.name == this.name &&
          other.phoneNumber == this.phoneNumber &&
          other.address == this.address &&
          other.logoPath == this.logoPath &&
          other.ownerId == this.ownerId &&
          other.version == this.version &&
          other.isDeleted == this.isDeleted &&
          other.updatedAt == this.updatedAt &&
          other.createdAt == this.createdAt);
}

class GeneratorSettingsTableCompanion
    extends UpdateCompanion<GeneratorSettingsData> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> phoneNumber;
  final Value<String> address;
  final Value<String?> logoPath;
  final Value<String?> ownerId;
  final Value<int> version;
  final Value<bool> isDeleted;
  final Value<DateTime> updatedAt;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const GeneratorSettingsTableCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.phoneNumber = const Value.absent(),
    this.address = const Value.absent(),
    this.logoPath = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.version = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GeneratorSettingsTableCompanion.insert({
    required String id,
    required String name,
    required String phoneNumber,
    required String address,
    this.logoPath = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.version = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        phoneNumber = Value(phoneNumber),
        address = Value(address);
  static Insertable<GeneratorSettingsData> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? phoneNumber,
    Expression<String>? address,
    Expression<String>? logoPath,
    Expression<String>? ownerId,
    Expression<int>? version,
    Expression<bool>? isDeleted,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (phoneNumber != null) 'phone_number': phoneNumber,
      if (address != null) 'address': address,
      if (logoPath != null) 'logo_path': logoPath,
      if (ownerId != null) 'owner_id': ownerId,
      if (version != null) 'version': version,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GeneratorSettingsTableCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String>? phoneNumber,
      Value<String>? address,
      Value<String?>? logoPath,
      Value<String?>? ownerId,
      Value<int>? version,
      Value<bool>? isDeleted,
      Value<DateTime>? updatedAt,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return GeneratorSettingsTableCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      logoPath: logoPath ?? this.logoPath,
      ownerId: ownerId ?? this.ownerId,
      version: version ?? this.version,
      isDeleted: isDeleted ?? this.isDeleted,
      updatedAt: updatedAt ?? this.updatedAt,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (phoneNumber.present) {
      map['phone_number'] = Variable<String>(phoneNumber.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (logoPath.present) {
      map['logo_path'] = Variable<String>(logoPath.value);
    }
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GeneratorSettingsTableCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('phoneNumber: $phoneNumber, ')
          ..write('address: $address, ')
          ..write('logoPath: $logoPath, ')
          ..write('ownerId: $ownerId, ')
          ..write('version: $version, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OutboxTableTable extends OutboxTable
    with TableInfo<$OutboxTableTable, OutboxEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OutboxTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _targetTableMeta =
      const VerificationMeta('targetTable');
  @override
  late final GeneratedColumn<String> targetTable = GeneratedColumn<String>(
      'target_table', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _operationTypeMeta =
      const VerificationMeta('operationType');
  @override
  late final GeneratedColumn<String> operationType = GeneratedColumn<String>(
      'operation_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _documentIdMeta =
      const VerificationMeta('documentId');
  @override
  late final GeneratedColumn<String> documentId = GeneratedColumn<String>(
      'document_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _payloadMeta =
      const VerificationMeta('payload');
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
      'payload', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  static const VerificationMeta _retryCountMeta =
      const VerificationMeta('retryCount');
  @override
  late final GeneratedColumn<int> retryCount = GeneratedColumn<int>(
      'retry_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _lastErrorMeta =
      const VerificationMeta('lastError');
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
      'last_error', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _syncedAtMeta =
      const VerificationMeta('syncedAt');
  @override
  late final GeneratedColumn<DateTime> syncedAt = GeneratedColumn<DateTime>(
      'synced_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        targetTable,
        operationType,
        documentId,
        payload,
        status,
        retryCount,
        lastError,
        createdAt,
        syncedAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'outbox_table';
  @override
  VerificationContext validateIntegrity(Insertable<OutboxEntry> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('target_table')) {
      context.handle(
          _targetTableMeta,
          targetTable.isAcceptableOrUnknown(
              data['target_table']!, _targetTableMeta));
    } else if (isInserting) {
      context.missing(_targetTableMeta);
    }
    if (data.containsKey('operation_type')) {
      context.handle(
          _operationTypeMeta,
          operationType.isAcceptableOrUnknown(
              data['operation_type']!, _operationTypeMeta));
    } else if (isInserting) {
      context.missing(_operationTypeMeta);
    }
    if (data.containsKey('document_id')) {
      context.handle(
          _documentIdMeta,
          documentId.isAcceptableOrUnknown(
              data['document_id']!, _documentIdMeta));
    } else if (isInserting) {
      context.missing(_documentIdMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(_payloadMeta,
          payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta));
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('retry_count')) {
      context.handle(
          _retryCountMeta,
          retryCount.isAcceptableOrUnknown(
              data['retry_count']!, _retryCountMeta));
    }
    if (data.containsKey('last_error')) {
      context.handle(_lastErrorMeta,
          lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('synced_at')) {
      context.handle(_syncedAtMeta,
          syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  OutboxEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OutboxEntry(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      targetTable: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}target_table'])!,
      operationType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}operation_type'])!,
      documentId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}document_id'])!,
      payload: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payload'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      retryCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}retry_count'])!,
      lastError: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}last_error']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      syncedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}synced_at']),
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at']),
    );
  }

  @override
  $OutboxTableTable createAlias(String alias) {
    return $OutboxTableTable(attachedDatabase, alias);
  }
}

class OutboxEntry extends DataClass implements Insertable<OutboxEntry> {
  final String id;
  final String targetTable;
  final String operationType;
  final String documentId;
  final String payload;
  final String status;
  final int retryCount;
  final String? lastError;
  final DateTime createdAt;
  final DateTime? syncedAt;
  final DateTime? updatedAt;
  const OutboxEntry(
      {required this.id,
      required this.targetTable,
      required this.operationType,
      required this.documentId,
      required this.payload,
      required this.status,
      required this.retryCount,
      this.lastError,
      required this.createdAt,
      this.syncedAt,
      this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['target_table'] = Variable<String>(targetTable);
    map['operation_type'] = Variable<String>(operationType);
    map['document_id'] = Variable<String>(documentId);
    map['payload'] = Variable<String>(payload);
    map['status'] = Variable<String>(status);
    map['retry_count'] = Variable<int>(retryCount);
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || syncedAt != null) {
      map['synced_at'] = Variable<DateTime>(syncedAt);
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    return map;
  }

  OutboxTableCompanion toCompanion(bool nullToAbsent) {
    return OutboxTableCompanion(
      id: Value(id),
      targetTable: Value(targetTable),
      operationType: Value(operationType),
      documentId: Value(documentId),
      payload: Value(payload),
      status: Value(status),
      retryCount: Value(retryCount),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
      createdAt: Value(createdAt),
      syncedAt: syncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(syncedAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory OutboxEntry.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OutboxEntry(
      id: serializer.fromJson<String>(json['id']),
      targetTable: serializer.fromJson<String>(json['targetTable']),
      operationType: serializer.fromJson<String>(json['operationType']),
      documentId: serializer.fromJson<String>(json['documentId']),
      payload: serializer.fromJson<String>(json['payload']),
      status: serializer.fromJson<String>(json['status']),
      retryCount: serializer.fromJson<int>(json['retryCount']),
      lastError: serializer.fromJson<String?>(json['lastError']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      syncedAt: serializer.fromJson<DateTime?>(json['syncedAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'targetTable': serializer.toJson<String>(targetTable),
      'operationType': serializer.toJson<String>(operationType),
      'documentId': serializer.toJson<String>(documentId),
      'payload': serializer.toJson<String>(payload),
      'status': serializer.toJson<String>(status),
      'retryCount': serializer.toJson<int>(retryCount),
      'lastError': serializer.toJson<String?>(lastError),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'syncedAt': serializer.toJson<DateTime?>(syncedAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
    };
  }

  OutboxEntry copyWith(
          {String? id,
          String? targetTable,
          String? operationType,
          String? documentId,
          String? payload,
          String? status,
          int? retryCount,
          Value<String?> lastError = const Value.absent(),
          DateTime? createdAt,
          Value<DateTime?> syncedAt = const Value.absent(),
          Value<DateTime?> updatedAt = const Value.absent()}) =>
      OutboxEntry(
        id: id ?? this.id,
        targetTable: targetTable ?? this.targetTable,
        operationType: operationType ?? this.operationType,
        documentId: documentId ?? this.documentId,
        payload: payload ?? this.payload,
        status: status ?? this.status,
        retryCount: retryCount ?? this.retryCount,
        lastError: lastError.present ? lastError.value : this.lastError,
        createdAt: createdAt ?? this.createdAt,
        syncedAt: syncedAt.present ? syncedAt.value : this.syncedAt,
        updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
      );
  OutboxEntry copyWithCompanion(OutboxTableCompanion data) {
    return OutboxEntry(
      id: data.id.present ? data.id.value : this.id,
      targetTable:
          data.targetTable.present ? data.targetTable.value : this.targetTable,
      operationType: data.operationType.present
          ? data.operationType.value
          : this.operationType,
      documentId:
          data.documentId.present ? data.documentId.value : this.documentId,
      payload: data.payload.present ? data.payload.value : this.payload,
      status: data.status.present ? data.status.value : this.status,
      retryCount:
          data.retryCount.present ? data.retryCount.value : this.retryCount,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OutboxEntry(')
          ..write('id: $id, ')
          ..write('targetTable: $targetTable, ')
          ..write('operationType: $operationType, ')
          ..write('documentId: $documentId, ')
          ..write('payload: $payload, ')
          ..write('status: $status, ')
          ..write('retryCount: $retryCount, ')
          ..write('lastError: $lastError, ')
          ..write('createdAt: $createdAt, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, targetTable, operationType, documentId,
      payload, status, retryCount, lastError, createdAt, syncedAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OutboxEntry &&
          other.id == this.id &&
          other.targetTable == this.targetTable &&
          other.operationType == this.operationType &&
          other.documentId == this.documentId &&
          other.payload == this.payload &&
          other.status == this.status &&
          other.retryCount == this.retryCount &&
          other.lastError == this.lastError &&
          other.createdAt == this.createdAt &&
          other.syncedAt == this.syncedAt &&
          other.updatedAt == this.updatedAt);
}

class OutboxTableCompanion extends UpdateCompanion<OutboxEntry> {
  final Value<String> id;
  final Value<String> targetTable;
  final Value<String> operationType;
  final Value<String> documentId;
  final Value<String> payload;
  final Value<String> status;
  final Value<int> retryCount;
  final Value<String?> lastError;
  final Value<DateTime> createdAt;
  final Value<DateTime?> syncedAt;
  final Value<DateTime?> updatedAt;
  final Value<int> rowid;
  const OutboxTableCompanion({
    this.id = const Value.absent(),
    this.targetTable = const Value.absent(),
    this.operationType = const Value.absent(),
    this.documentId = const Value.absent(),
    this.payload = const Value.absent(),
    this.status = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.lastError = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OutboxTableCompanion.insert({
    required String id,
    required String targetTable,
    required String operationType,
    required String documentId,
    required String payload,
    this.status = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.lastError = const Value.absent(),
    required DateTime createdAt,
    this.syncedAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        targetTable = Value(targetTable),
        operationType = Value(operationType),
        documentId = Value(documentId),
        payload = Value(payload),
        createdAt = Value(createdAt);
  static Insertable<OutboxEntry> custom({
    Expression<String>? id,
    Expression<String>? targetTable,
    Expression<String>? operationType,
    Expression<String>? documentId,
    Expression<String>? payload,
    Expression<String>? status,
    Expression<int>? retryCount,
    Expression<String>? lastError,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? syncedAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (targetTable != null) 'target_table': targetTable,
      if (operationType != null) 'operation_type': operationType,
      if (documentId != null) 'document_id': documentId,
      if (payload != null) 'payload': payload,
      if (status != null) 'status': status,
      if (retryCount != null) 'retry_count': retryCount,
      if (lastError != null) 'last_error': lastError,
      if (createdAt != null) 'created_at': createdAt,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  OutboxTableCompanion copyWith(
      {Value<String>? id,
      Value<String>? targetTable,
      Value<String>? operationType,
      Value<String>? documentId,
      Value<String>? payload,
      Value<String>? status,
      Value<int>? retryCount,
      Value<String?>? lastError,
      Value<DateTime>? createdAt,
      Value<DateTime?>? syncedAt,
      Value<DateTime?>? updatedAt,
      Value<int>? rowid}) {
    return OutboxTableCompanion(
      id: id ?? this.id,
      targetTable: targetTable ?? this.targetTable,
      operationType: operationType ?? this.operationType,
      documentId: documentId ?? this.documentId,
      payload: payload ?? this.payload,
      status: status ?? this.status,
      retryCount: retryCount ?? this.retryCount,
      lastError: lastError ?? this.lastError,
      createdAt: createdAt ?? this.createdAt,
      syncedAt: syncedAt ?? this.syncedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (targetTable.present) {
      map['target_table'] = Variable<String>(targetTable.value);
    }
    if (operationType.present) {
      map['operation_type'] = Variable<String>(operationType.value);
    }
    if (documentId.present) {
      map['document_id'] = Variable<String>(documentId.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (retryCount.present) {
      map['retry_count'] = Variable<int>(retryCount.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<DateTime>(syncedAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OutboxTableCompanion(')
          ..write('id: $id, ')
          ..write('targetTable: $targetTable, ')
          ..write('operationType: $operationType, ')
          ..write('documentId: $documentId, ')
          ..write('payload: $payload, ')
          ..write('status: $status, ')
          ..write('retryCount: $retryCount, ')
          ..write('lastError: $lastError, ')
          ..write('createdAt: $createdAt, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $SubscribersTableTable subscribersTable =
      $SubscribersTableTable(this);
  late final $CabinetsTableTable cabinetsTable = $CabinetsTableTable(this);
  late final $PaymentsTableTable paymentsTable = $PaymentsTableTable(this);
  late final $WorkersTableTable workersTable = $WorkersTableTable(this);
  late final $AuditLogTableTable auditLogTable = $AuditLogTableTable(this);
  late final $WhatsappTemplatesTableTable whatsappTemplatesTable =
      $WhatsappTemplatesTableTable(this);
  late final $GeneratorSettingsTableTable generatorSettingsTable =
      $GeneratorSettingsTableTable(this);
  late final $OutboxTableTable outboxTable = $OutboxTableTable(this);
  late final SubscribersDao subscribersDao =
      SubscribersDao(this as AppDatabase);
  late final CabinetsDao cabinetsDao = CabinetsDao(this as AppDatabase);
  late final PaymentsDao paymentsDao = PaymentsDao(this as AppDatabase);
  late final WorkersDao workersDao = WorkersDao(this as AppDatabase);
  late final AuditLogDao auditLogDao = AuditLogDao(this as AppDatabase);
  late final WhatsappTemplatesDao whatsappTemplatesDao =
      WhatsappTemplatesDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        subscribersTable,
        cabinetsTable,
        paymentsTable,
        workersTable,
        auditLogTable,
        whatsappTemplatesTable,
        generatorSettingsTable,
        outboxTable
      ];
}

typedef $$SubscribersTableTableCreateCompanionBuilder
    = SubscribersTableCompanion Function({
  required String id,
  required String name,
  required String code,
  required String cabinet,
  required String phone,
  required int status,
  required DateTime startDate,
  Value<double> accumulatedDebt,
  Value<String?> tags,
  Value<String?> notes,
  Value<DateTime?> lastModified,
  Value<DateTime?> lastSyncedAt,
  Value<String?> syncStatus,
  Value<bool?> dirtyFlag,
  Value<String?> cloudId,
  Value<bool?> deletedLocally,
  Value<String?> permissionsMask,
  Value<String?> ownerId,
  Value<int> version,
  Value<bool> isDeleted,
  Value<DateTime?> updatedAt,
  Value<DateTime?> createdAt,
  Value<int> rowid,
});
typedef $$SubscribersTableTableUpdateCompanionBuilder
    = SubscribersTableCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String> code,
  Value<String> cabinet,
  Value<String> phone,
  Value<int> status,
  Value<DateTime> startDate,
  Value<double> accumulatedDebt,
  Value<String?> tags,
  Value<String?> notes,
  Value<DateTime?> lastModified,
  Value<DateTime?> lastSyncedAt,
  Value<String?> syncStatus,
  Value<bool?> dirtyFlag,
  Value<String?> cloudId,
  Value<bool?> deletedLocally,
  Value<String?> permissionsMask,
  Value<String?> ownerId,
  Value<int> version,
  Value<bool> isDeleted,
  Value<DateTime?> updatedAt,
  Value<DateTime?> createdAt,
  Value<int> rowid,
});

class $$SubscribersTableTableFilterComposer
    extends Composer<_$AppDatabase, $SubscribersTableTable> {
  $$SubscribersTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get code => $composableBuilder(
      column: $table.code, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get cabinet => $composableBuilder(
      column: $table.cabinet, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get startDate => $composableBuilder(
      column: $table.startDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get accumulatedDebt => $composableBuilder(
      column: $table.accumulatedDebt,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tags => $composableBuilder(
      column: $table.tags, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastModified => $composableBuilder(
      column: $table.lastModified, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get dirtyFlag => $composableBuilder(
      column: $table.dirtyFlag, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get cloudId => $composableBuilder(
      column: $table.cloudId, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get deletedLocally => $composableBuilder(
      column: $table.deletedLocally,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get permissionsMask => $composableBuilder(
      column: $table.permissionsMask,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get ownerId => $composableBuilder(
      column: $table.ownerId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$SubscribersTableTableOrderingComposer
    extends Composer<_$AppDatabase, $SubscribersTableTable> {
  $$SubscribersTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get code => $composableBuilder(
      column: $table.code, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get cabinet => $composableBuilder(
      column: $table.cabinet, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get startDate => $composableBuilder(
      column: $table.startDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get accumulatedDebt => $composableBuilder(
      column: $table.accumulatedDebt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tags => $composableBuilder(
      column: $table.tags, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastModified => $composableBuilder(
      column: $table.lastModified,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get dirtyFlag => $composableBuilder(
      column: $table.dirtyFlag, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get cloudId => $composableBuilder(
      column: $table.cloudId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get deletedLocally => $composableBuilder(
      column: $table.deletedLocally,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get permissionsMask => $composableBuilder(
      column: $table.permissionsMask,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get ownerId => $composableBuilder(
      column: $table.ownerId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$SubscribersTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $SubscribersTableTable> {
  $$SubscribersTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<String> get cabinet =>
      $composableBuilder(column: $table.cabinet, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<int> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<double> get accumulatedDebt => $composableBuilder(
      column: $table.accumulatedDebt, builder: (column) => column);

  GeneratedColumn<String> get tags =>
      $composableBuilder(column: $table.tags, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get lastModified => $composableBuilder(
      column: $table.lastModified, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => column);

  GeneratedColumn<bool> get dirtyFlag =>
      $composableBuilder(column: $table.dirtyFlag, builder: (column) => column);

  GeneratedColumn<String> get cloudId =>
      $composableBuilder(column: $table.cloudId, builder: (column) => column);

  GeneratedColumn<bool> get deletedLocally => $composableBuilder(
      column: $table.deletedLocally, builder: (column) => column);

  GeneratedColumn<String> get permissionsMask => $composableBuilder(
      column: $table.permissionsMask, builder: (column) => column);

  GeneratedColumn<String> get ownerId =>
      $composableBuilder(column: $table.ownerId, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$SubscribersTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SubscribersTableTable,
    Subscriber,
    $$SubscribersTableTableFilterComposer,
    $$SubscribersTableTableOrderingComposer,
    $$SubscribersTableTableAnnotationComposer,
    $$SubscribersTableTableCreateCompanionBuilder,
    $$SubscribersTableTableUpdateCompanionBuilder,
    (
      Subscriber,
      BaseReferences<_$AppDatabase, $SubscribersTableTable, Subscriber>
    ),
    Subscriber,
    PrefetchHooks Function()> {
  $$SubscribersTableTableTableManager(
      _$AppDatabase db, $SubscribersTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SubscribersTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SubscribersTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SubscribersTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> code = const Value.absent(),
            Value<String> cabinet = const Value.absent(),
            Value<String> phone = const Value.absent(),
            Value<int> status = const Value.absent(),
            Value<DateTime> startDate = const Value.absent(),
            Value<double> accumulatedDebt = const Value.absent(),
            Value<String?> tags = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<DateTime?> lastModified = const Value.absent(),
            Value<DateTime?> lastSyncedAt = const Value.absent(),
            Value<String?> syncStatus = const Value.absent(),
            Value<bool?> dirtyFlag = const Value.absent(),
            Value<String?> cloudId = const Value.absent(),
            Value<bool?> deletedLocally = const Value.absent(),
            Value<String?> permissionsMask = const Value.absent(),
            Value<String?> ownerId = const Value.absent(),
            Value<int> version = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<DateTime?> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SubscribersTableCompanion(
            id: id,
            name: name,
            code: code,
            cabinet: cabinet,
            phone: phone,
            status: status,
            startDate: startDate,
            accumulatedDebt: accumulatedDebt,
            tags: tags,
            notes: notes,
            lastModified: lastModified,
            lastSyncedAt: lastSyncedAt,
            syncStatus: syncStatus,
            dirtyFlag: dirtyFlag,
            cloudId: cloudId,
            deletedLocally: deletedLocally,
            permissionsMask: permissionsMask,
            ownerId: ownerId,
            version: version,
            isDeleted: isDeleted,
            updatedAt: updatedAt,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            required String code,
            required String cabinet,
            required String phone,
            required int status,
            required DateTime startDate,
            Value<double> accumulatedDebt = const Value.absent(),
            Value<String?> tags = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<DateTime?> lastModified = const Value.absent(),
            Value<DateTime?> lastSyncedAt = const Value.absent(),
            Value<String?> syncStatus = const Value.absent(),
            Value<bool?> dirtyFlag = const Value.absent(),
            Value<String?> cloudId = const Value.absent(),
            Value<bool?> deletedLocally = const Value.absent(),
            Value<String?> permissionsMask = const Value.absent(),
            Value<String?> ownerId = const Value.absent(),
            Value<int> version = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<DateTime?> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SubscribersTableCompanion.insert(
            id: id,
            name: name,
            code: code,
            cabinet: cabinet,
            phone: phone,
            status: status,
            startDate: startDate,
            accumulatedDebt: accumulatedDebt,
            tags: tags,
            notes: notes,
            lastModified: lastModified,
            lastSyncedAt: lastSyncedAt,
            syncStatus: syncStatus,
            dirtyFlag: dirtyFlag,
            cloudId: cloudId,
            deletedLocally: deletedLocally,
            permissionsMask: permissionsMask,
            ownerId: ownerId,
            version: version,
            isDeleted: isDeleted,
            updatedAt: updatedAt,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SubscribersTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SubscribersTableTable,
    Subscriber,
    $$SubscribersTableTableFilterComposer,
    $$SubscribersTableTableOrderingComposer,
    $$SubscribersTableTableAnnotationComposer,
    $$SubscribersTableTableCreateCompanionBuilder,
    $$SubscribersTableTableUpdateCompanionBuilder,
    (
      Subscriber,
      BaseReferences<_$AppDatabase, $SubscribersTableTable, Subscriber>
    ),
    Subscriber,
    PrefetchHooks Function()>;
typedef $$CabinetsTableTableCreateCompanionBuilder = CabinetsTableCompanion
    Function({
  required String id,
  required String name,
  Value<String> letter,
  required int totalSubscribers,
  required int currentSubscribers,
  Value<double> collectedAmount,
  required int delayedSubscribers,
  Value<DateTime?> completionDate,
  Value<DateTime?> lastModified,
  Value<DateTime?> lastSyncedAt,
  Value<String?> syncStatus,
  Value<bool?> dirtyFlag,
  Value<String?> cloudId,
  Value<bool?> deletedLocally,
  Value<String?> permissionsMask,
  Value<String?> ownerId,
  Value<int> version,
  Value<bool> isDeleted,
  Value<DateTime?> updatedAt,
  Value<DateTime?> createdAt,
  Value<int> rowid,
});
typedef $$CabinetsTableTableUpdateCompanionBuilder = CabinetsTableCompanion
    Function({
  Value<String> id,
  Value<String> name,
  Value<String> letter,
  Value<int> totalSubscribers,
  Value<int> currentSubscribers,
  Value<double> collectedAmount,
  Value<int> delayedSubscribers,
  Value<DateTime?> completionDate,
  Value<DateTime?> lastModified,
  Value<DateTime?> lastSyncedAt,
  Value<String?> syncStatus,
  Value<bool?> dirtyFlag,
  Value<String?> cloudId,
  Value<bool?> deletedLocally,
  Value<String?> permissionsMask,
  Value<String?> ownerId,
  Value<int> version,
  Value<bool> isDeleted,
  Value<DateTime?> updatedAt,
  Value<DateTime?> createdAt,
  Value<int> rowid,
});

class $$CabinetsTableTableFilterComposer
    extends Composer<_$AppDatabase, $CabinetsTableTable> {
  $$CabinetsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get letter => $composableBuilder(
      column: $table.letter, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get totalSubscribers => $composableBuilder(
      column: $table.totalSubscribers,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get currentSubscribers => $composableBuilder(
      column: $table.currentSubscribers,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get collectedAmount => $composableBuilder(
      column: $table.collectedAmount,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get delayedSubscribers => $composableBuilder(
      column: $table.delayedSubscribers,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get completionDate => $composableBuilder(
      column: $table.completionDate,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastModified => $composableBuilder(
      column: $table.lastModified, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get dirtyFlag => $composableBuilder(
      column: $table.dirtyFlag, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get cloudId => $composableBuilder(
      column: $table.cloudId, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get deletedLocally => $composableBuilder(
      column: $table.deletedLocally,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get permissionsMask => $composableBuilder(
      column: $table.permissionsMask,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get ownerId => $composableBuilder(
      column: $table.ownerId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$CabinetsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $CabinetsTableTable> {
  $$CabinetsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get letter => $composableBuilder(
      column: $table.letter, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get totalSubscribers => $composableBuilder(
      column: $table.totalSubscribers,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get currentSubscribers => $composableBuilder(
      column: $table.currentSubscribers,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get collectedAmount => $composableBuilder(
      column: $table.collectedAmount,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get delayedSubscribers => $composableBuilder(
      column: $table.delayedSubscribers,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get completionDate => $composableBuilder(
      column: $table.completionDate,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastModified => $composableBuilder(
      column: $table.lastModified,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get dirtyFlag => $composableBuilder(
      column: $table.dirtyFlag, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get cloudId => $composableBuilder(
      column: $table.cloudId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get deletedLocally => $composableBuilder(
      column: $table.deletedLocally,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get permissionsMask => $composableBuilder(
      column: $table.permissionsMask,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get ownerId => $composableBuilder(
      column: $table.ownerId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$CabinetsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $CabinetsTableTable> {
  $$CabinetsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get letter =>
      $composableBuilder(column: $table.letter, builder: (column) => column);

  GeneratedColumn<int> get totalSubscribers => $composableBuilder(
      column: $table.totalSubscribers, builder: (column) => column);

  GeneratedColumn<int> get currentSubscribers => $composableBuilder(
      column: $table.currentSubscribers, builder: (column) => column);

  GeneratedColumn<double> get collectedAmount => $composableBuilder(
      column: $table.collectedAmount, builder: (column) => column);

  GeneratedColumn<int> get delayedSubscribers => $composableBuilder(
      column: $table.delayedSubscribers, builder: (column) => column);

  GeneratedColumn<DateTime> get completionDate => $composableBuilder(
      column: $table.completionDate, builder: (column) => column);

  GeneratedColumn<DateTime> get lastModified => $composableBuilder(
      column: $table.lastModified, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => column);

  GeneratedColumn<bool> get dirtyFlag =>
      $composableBuilder(column: $table.dirtyFlag, builder: (column) => column);

  GeneratedColumn<String> get cloudId =>
      $composableBuilder(column: $table.cloudId, builder: (column) => column);

  GeneratedColumn<bool> get deletedLocally => $composableBuilder(
      column: $table.deletedLocally, builder: (column) => column);

  GeneratedColumn<String> get permissionsMask => $composableBuilder(
      column: $table.permissionsMask, builder: (column) => column);

  GeneratedColumn<String> get ownerId =>
      $composableBuilder(column: $table.ownerId, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$CabinetsTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CabinetsTableTable,
    Cabinet,
    $$CabinetsTableTableFilterComposer,
    $$CabinetsTableTableOrderingComposer,
    $$CabinetsTableTableAnnotationComposer,
    $$CabinetsTableTableCreateCompanionBuilder,
    $$CabinetsTableTableUpdateCompanionBuilder,
    (Cabinet, BaseReferences<_$AppDatabase, $CabinetsTableTable, Cabinet>),
    Cabinet,
    PrefetchHooks Function()> {
  $$CabinetsTableTableTableManager(_$AppDatabase db, $CabinetsTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CabinetsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CabinetsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CabinetsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> letter = const Value.absent(),
            Value<int> totalSubscribers = const Value.absent(),
            Value<int> currentSubscribers = const Value.absent(),
            Value<double> collectedAmount = const Value.absent(),
            Value<int> delayedSubscribers = const Value.absent(),
            Value<DateTime?> completionDate = const Value.absent(),
            Value<DateTime?> lastModified = const Value.absent(),
            Value<DateTime?> lastSyncedAt = const Value.absent(),
            Value<String?> syncStatus = const Value.absent(),
            Value<bool?> dirtyFlag = const Value.absent(),
            Value<String?> cloudId = const Value.absent(),
            Value<bool?> deletedLocally = const Value.absent(),
            Value<String?> permissionsMask = const Value.absent(),
            Value<String?> ownerId = const Value.absent(),
            Value<int> version = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<DateTime?> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CabinetsTableCompanion(
            id: id,
            name: name,
            letter: letter,
            totalSubscribers: totalSubscribers,
            currentSubscribers: currentSubscribers,
            collectedAmount: collectedAmount,
            delayedSubscribers: delayedSubscribers,
            completionDate: completionDate,
            lastModified: lastModified,
            lastSyncedAt: lastSyncedAt,
            syncStatus: syncStatus,
            dirtyFlag: dirtyFlag,
            cloudId: cloudId,
            deletedLocally: deletedLocally,
            permissionsMask: permissionsMask,
            ownerId: ownerId,
            version: version,
            isDeleted: isDeleted,
            updatedAt: updatedAt,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            Value<String> letter = const Value.absent(),
            required int totalSubscribers,
            required int currentSubscribers,
            Value<double> collectedAmount = const Value.absent(),
            required int delayedSubscribers,
            Value<DateTime?> completionDate = const Value.absent(),
            Value<DateTime?> lastModified = const Value.absent(),
            Value<DateTime?> lastSyncedAt = const Value.absent(),
            Value<String?> syncStatus = const Value.absent(),
            Value<bool?> dirtyFlag = const Value.absent(),
            Value<String?> cloudId = const Value.absent(),
            Value<bool?> deletedLocally = const Value.absent(),
            Value<String?> permissionsMask = const Value.absent(),
            Value<String?> ownerId = const Value.absent(),
            Value<int> version = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<DateTime?> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CabinetsTableCompanion.insert(
            id: id,
            name: name,
            letter: letter,
            totalSubscribers: totalSubscribers,
            currentSubscribers: currentSubscribers,
            collectedAmount: collectedAmount,
            delayedSubscribers: delayedSubscribers,
            completionDate: completionDate,
            lastModified: lastModified,
            lastSyncedAt: lastSyncedAt,
            syncStatus: syncStatus,
            dirtyFlag: dirtyFlag,
            cloudId: cloudId,
            deletedLocally: deletedLocally,
            permissionsMask: permissionsMask,
            ownerId: ownerId,
            version: version,
            isDeleted: isDeleted,
            updatedAt: updatedAt,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CabinetsTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CabinetsTableTable,
    Cabinet,
    $$CabinetsTableTableFilterComposer,
    $$CabinetsTableTableOrderingComposer,
    $$CabinetsTableTableAnnotationComposer,
    $$CabinetsTableTableCreateCompanionBuilder,
    $$CabinetsTableTableUpdateCompanionBuilder,
    (Cabinet, BaseReferences<_$AppDatabase, $CabinetsTableTable, Cabinet>),
    Cabinet,
    PrefetchHooks Function()>;
typedef $$PaymentsTableTableCreateCompanionBuilder = PaymentsTableCompanion
    Function({
  required String id,
  required String subscriberId,
  required double amount,
  required String worker,
  required DateTime date,
  required String cabinet,
  Value<DateTime?> lastModified,
  Value<DateTime?> lastSyncedAt,
  Value<String?> syncStatus,
  Value<bool?> dirtyFlag,
  Value<String?> cloudId,
  Value<bool?> deletedLocally,
  Value<String?> permissionsMask,
  Value<String?> ownerId,
  Value<int> version,
  Value<bool> isDeleted,
  Value<DateTime?> updatedAt,
  Value<DateTime?> createdAt,
  Value<int> rowid,
});
typedef $$PaymentsTableTableUpdateCompanionBuilder = PaymentsTableCompanion
    Function({
  Value<String> id,
  Value<String> subscriberId,
  Value<double> amount,
  Value<String> worker,
  Value<DateTime> date,
  Value<String> cabinet,
  Value<DateTime?> lastModified,
  Value<DateTime?> lastSyncedAt,
  Value<String?> syncStatus,
  Value<bool?> dirtyFlag,
  Value<String?> cloudId,
  Value<bool?> deletedLocally,
  Value<String?> permissionsMask,
  Value<String?> ownerId,
  Value<int> version,
  Value<bool> isDeleted,
  Value<DateTime?> updatedAt,
  Value<DateTime?> createdAt,
  Value<int> rowid,
});

class $$PaymentsTableTableFilterComposer
    extends Composer<_$AppDatabase, $PaymentsTableTable> {
  $$PaymentsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get subscriberId => $composableBuilder(
      column: $table.subscriberId, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get worker => $composableBuilder(
      column: $table.worker, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get cabinet => $composableBuilder(
      column: $table.cabinet, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastModified => $composableBuilder(
      column: $table.lastModified, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get dirtyFlag => $composableBuilder(
      column: $table.dirtyFlag, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get cloudId => $composableBuilder(
      column: $table.cloudId, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get deletedLocally => $composableBuilder(
      column: $table.deletedLocally,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get permissionsMask => $composableBuilder(
      column: $table.permissionsMask,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get ownerId => $composableBuilder(
      column: $table.ownerId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$PaymentsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $PaymentsTableTable> {
  $$PaymentsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get subscriberId => $composableBuilder(
      column: $table.subscriberId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get worker => $composableBuilder(
      column: $table.worker, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get cabinet => $composableBuilder(
      column: $table.cabinet, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastModified => $composableBuilder(
      column: $table.lastModified,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get dirtyFlag => $composableBuilder(
      column: $table.dirtyFlag, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get cloudId => $composableBuilder(
      column: $table.cloudId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get deletedLocally => $composableBuilder(
      column: $table.deletedLocally,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get permissionsMask => $composableBuilder(
      column: $table.permissionsMask,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get ownerId => $composableBuilder(
      column: $table.ownerId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$PaymentsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $PaymentsTableTable> {
  $$PaymentsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get subscriberId => $composableBuilder(
      column: $table.subscriberId, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get worker =>
      $composableBuilder(column: $table.worker, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get cabinet =>
      $composableBuilder(column: $table.cabinet, builder: (column) => column);

  GeneratedColumn<DateTime> get lastModified => $composableBuilder(
      column: $table.lastModified, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => column);

  GeneratedColumn<bool> get dirtyFlag =>
      $composableBuilder(column: $table.dirtyFlag, builder: (column) => column);

  GeneratedColumn<String> get cloudId =>
      $composableBuilder(column: $table.cloudId, builder: (column) => column);

  GeneratedColumn<bool> get deletedLocally => $composableBuilder(
      column: $table.deletedLocally, builder: (column) => column);

  GeneratedColumn<String> get permissionsMask => $composableBuilder(
      column: $table.permissionsMask, builder: (column) => column);

  GeneratedColumn<String> get ownerId =>
      $composableBuilder(column: $table.ownerId, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$PaymentsTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PaymentsTableTable,
    Payment,
    $$PaymentsTableTableFilterComposer,
    $$PaymentsTableTableOrderingComposer,
    $$PaymentsTableTableAnnotationComposer,
    $$PaymentsTableTableCreateCompanionBuilder,
    $$PaymentsTableTableUpdateCompanionBuilder,
    (Payment, BaseReferences<_$AppDatabase, $PaymentsTableTable, Payment>),
    Payment,
    PrefetchHooks Function()> {
  $$PaymentsTableTableTableManager(_$AppDatabase db, $PaymentsTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PaymentsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PaymentsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PaymentsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> subscriberId = const Value.absent(),
            Value<double> amount = const Value.absent(),
            Value<String> worker = const Value.absent(),
            Value<DateTime> date = const Value.absent(),
            Value<String> cabinet = const Value.absent(),
            Value<DateTime?> lastModified = const Value.absent(),
            Value<DateTime?> lastSyncedAt = const Value.absent(),
            Value<String?> syncStatus = const Value.absent(),
            Value<bool?> dirtyFlag = const Value.absent(),
            Value<String?> cloudId = const Value.absent(),
            Value<bool?> deletedLocally = const Value.absent(),
            Value<String?> permissionsMask = const Value.absent(),
            Value<String?> ownerId = const Value.absent(),
            Value<int> version = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<DateTime?> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PaymentsTableCompanion(
            id: id,
            subscriberId: subscriberId,
            amount: amount,
            worker: worker,
            date: date,
            cabinet: cabinet,
            lastModified: lastModified,
            lastSyncedAt: lastSyncedAt,
            syncStatus: syncStatus,
            dirtyFlag: dirtyFlag,
            cloudId: cloudId,
            deletedLocally: deletedLocally,
            permissionsMask: permissionsMask,
            ownerId: ownerId,
            version: version,
            isDeleted: isDeleted,
            updatedAt: updatedAt,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String subscriberId,
            required double amount,
            required String worker,
            required DateTime date,
            required String cabinet,
            Value<DateTime?> lastModified = const Value.absent(),
            Value<DateTime?> lastSyncedAt = const Value.absent(),
            Value<String?> syncStatus = const Value.absent(),
            Value<bool?> dirtyFlag = const Value.absent(),
            Value<String?> cloudId = const Value.absent(),
            Value<bool?> deletedLocally = const Value.absent(),
            Value<String?> permissionsMask = const Value.absent(),
            Value<String?> ownerId = const Value.absent(),
            Value<int> version = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<DateTime?> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PaymentsTableCompanion.insert(
            id: id,
            subscriberId: subscriberId,
            amount: amount,
            worker: worker,
            date: date,
            cabinet: cabinet,
            lastModified: lastModified,
            lastSyncedAt: lastSyncedAt,
            syncStatus: syncStatus,
            dirtyFlag: dirtyFlag,
            cloudId: cloudId,
            deletedLocally: deletedLocally,
            permissionsMask: permissionsMask,
            ownerId: ownerId,
            version: version,
            isDeleted: isDeleted,
            updatedAt: updatedAt,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$PaymentsTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PaymentsTableTable,
    Payment,
    $$PaymentsTableTableFilterComposer,
    $$PaymentsTableTableOrderingComposer,
    $$PaymentsTableTableAnnotationComposer,
    $$PaymentsTableTableCreateCompanionBuilder,
    $$PaymentsTableTableUpdateCompanionBuilder,
    (Payment, BaseReferences<_$AppDatabase, $PaymentsTableTable, Payment>),
    Payment,
    PrefetchHooks Function()>;
typedef $$WorkersTableTableCreateCompanionBuilder = WorkersTableCompanion
    Function({
  required String id,
  required String name,
  required String phone,
  required String permissions,
  Value<double> todayCollected,
  Value<double> monthTotal,
  Value<DateTime?> lastModified,
  Value<DateTime?> lastSyncedAt,
  Value<String?> syncStatus,
  Value<bool?> dirtyFlag,
  Value<String?> cloudId,
  Value<bool?> deletedLocally,
  Value<String?> permissionsMask,
  Value<String?> ownerId,
  Value<int> version,
  Value<bool> isDeleted,
  Value<DateTime?> updatedAt,
  Value<DateTime?> createdAt,
  Value<int> rowid,
});
typedef $$WorkersTableTableUpdateCompanionBuilder = WorkersTableCompanion
    Function({
  Value<String> id,
  Value<String> name,
  Value<String> phone,
  Value<String> permissions,
  Value<double> todayCollected,
  Value<double> monthTotal,
  Value<DateTime?> lastModified,
  Value<DateTime?> lastSyncedAt,
  Value<String?> syncStatus,
  Value<bool?> dirtyFlag,
  Value<String?> cloudId,
  Value<bool?> deletedLocally,
  Value<String?> permissionsMask,
  Value<String?> ownerId,
  Value<int> version,
  Value<bool> isDeleted,
  Value<DateTime?> updatedAt,
  Value<DateTime?> createdAt,
  Value<int> rowid,
});

class $$WorkersTableTableFilterComposer
    extends Composer<_$AppDatabase, $WorkersTableTable> {
  $$WorkersTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get permissions => $composableBuilder(
      column: $table.permissions, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get todayCollected => $composableBuilder(
      column: $table.todayCollected,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get monthTotal => $composableBuilder(
      column: $table.monthTotal, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastModified => $composableBuilder(
      column: $table.lastModified, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get dirtyFlag => $composableBuilder(
      column: $table.dirtyFlag, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get cloudId => $composableBuilder(
      column: $table.cloudId, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get deletedLocally => $composableBuilder(
      column: $table.deletedLocally,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get permissionsMask => $composableBuilder(
      column: $table.permissionsMask,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get ownerId => $composableBuilder(
      column: $table.ownerId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$WorkersTableTableOrderingComposer
    extends Composer<_$AppDatabase, $WorkersTableTable> {
  $$WorkersTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get permissions => $composableBuilder(
      column: $table.permissions, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get todayCollected => $composableBuilder(
      column: $table.todayCollected,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get monthTotal => $composableBuilder(
      column: $table.monthTotal, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastModified => $composableBuilder(
      column: $table.lastModified,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get dirtyFlag => $composableBuilder(
      column: $table.dirtyFlag, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get cloudId => $composableBuilder(
      column: $table.cloudId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get deletedLocally => $composableBuilder(
      column: $table.deletedLocally,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get permissionsMask => $composableBuilder(
      column: $table.permissionsMask,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get ownerId => $composableBuilder(
      column: $table.ownerId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$WorkersTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $WorkersTableTable> {
  $$WorkersTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get permissions => $composableBuilder(
      column: $table.permissions, builder: (column) => column);

  GeneratedColumn<double> get todayCollected => $composableBuilder(
      column: $table.todayCollected, builder: (column) => column);

  GeneratedColumn<double> get monthTotal => $composableBuilder(
      column: $table.monthTotal, builder: (column) => column);

  GeneratedColumn<DateTime> get lastModified => $composableBuilder(
      column: $table.lastModified, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => column);

  GeneratedColumn<bool> get dirtyFlag =>
      $composableBuilder(column: $table.dirtyFlag, builder: (column) => column);

  GeneratedColumn<String> get cloudId =>
      $composableBuilder(column: $table.cloudId, builder: (column) => column);

  GeneratedColumn<bool> get deletedLocally => $composableBuilder(
      column: $table.deletedLocally, builder: (column) => column);

  GeneratedColumn<String> get permissionsMask => $composableBuilder(
      column: $table.permissionsMask, builder: (column) => column);

  GeneratedColumn<String> get ownerId =>
      $composableBuilder(column: $table.ownerId, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$WorkersTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $WorkersTableTable,
    Worker,
    $$WorkersTableTableFilterComposer,
    $$WorkersTableTableOrderingComposer,
    $$WorkersTableTableAnnotationComposer,
    $$WorkersTableTableCreateCompanionBuilder,
    $$WorkersTableTableUpdateCompanionBuilder,
    (Worker, BaseReferences<_$AppDatabase, $WorkersTableTable, Worker>),
    Worker,
    PrefetchHooks Function()> {
  $$WorkersTableTableTableManager(_$AppDatabase db, $WorkersTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorkersTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WorkersTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WorkersTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> phone = const Value.absent(),
            Value<String> permissions = const Value.absent(),
            Value<double> todayCollected = const Value.absent(),
            Value<double> monthTotal = const Value.absent(),
            Value<DateTime?> lastModified = const Value.absent(),
            Value<DateTime?> lastSyncedAt = const Value.absent(),
            Value<String?> syncStatus = const Value.absent(),
            Value<bool?> dirtyFlag = const Value.absent(),
            Value<String?> cloudId = const Value.absent(),
            Value<bool?> deletedLocally = const Value.absent(),
            Value<String?> permissionsMask = const Value.absent(),
            Value<String?> ownerId = const Value.absent(),
            Value<int> version = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<DateTime?> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              WorkersTableCompanion(
            id: id,
            name: name,
            phone: phone,
            permissions: permissions,
            todayCollected: todayCollected,
            monthTotal: monthTotal,
            lastModified: lastModified,
            lastSyncedAt: lastSyncedAt,
            syncStatus: syncStatus,
            dirtyFlag: dirtyFlag,
            cloudId: cloudId,
            deletedLocally: deletedLocally,
            permissionsMask: permissionsMask,
            ownerId: ownerId,
            version: version,
            isDeleted: isDeleted,
            updatedAt: updatedAt,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            required String phone,
            required String permissions,
            Value<double> todayCollected = const Value.absent(),
            Value<double> monthTotal = const Value.absent(),
            Value<DateTime?> lastModified = const Value.absent(),
            Value<DateTime?> lastSyncedAt = const Value.absent(),
            Value<String?> syncStatus = const Value.absent(),
            Value<bool?> dirtyFlag = const Value.absent(),
            Value<String?> cloudId = const Value.absent(),
            Value<bool?> deletedLocally = const Value.absent(),
            Value<String?> permissionsMask = const Value.absent(),
            Value<String?> ownerId = const Value.absent(),
            Value<int> version = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<DateTime?> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              WorkersTableCompanion.insert(
            id: id,
            name: name,
            phone: phone,
            permissions: permissions,
            todayCollected: todayCollected,
            monthTotal: monthTotal,
            lastModified: lastModified,
            lastSyncedAt: lastSyncedAt,
            syncStatus: syncStatus,
            dirtyFlag: dirtyFlag,
            cloudId: cloudId,
            deletedLocally: deletedLocally,
            permissionsMask: permissionsMask,
            ownerId: ownerId,
            version: version,
            isDeleted: isDeleted,
            updatedAt: updatedAt,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$WorkersTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $WorkersTableTable,
    Worker,
    $$WorkersTableTableFilterComposer,
    $$WorkersTableTableOrderingComposer,
    $$WorkersTableTableAnnotationComposer,
    $$WorkersTableTableCreateCompanionBuilder,
    $$WorkersTableTableUpdateCompanionBuilder,
    (Worker, BaseReferences<_$AppDatabase, $WorkersTableTable, Worker>),
    Worker,
    PrefetchHooks Function()>;
typedef $$AuditLogTableTableCreateCompanionBuilder = AuditLogTableCompanion
    Function({
  required String id,
  required String user,
  required String action,
  required String target,
  required String details,
  required String type,
  Value<DateTime> timestamp,
  Value<DateTime?> lastModified,
  Value<DateTime?> lastSyncedAt,
  Value<String?> syncStatus,
  Value<bool?> dirtyFlag,
  Value<String?> cloudId,
  Value<bool?> deletedLocally,
  Value<String?> permissionsMask,
  Value<String?> ownerId,
  Value<int> version,
  Value<bool> isDeleted,
  Value<DateTime?> updatedAt,
  Value<DateTime?> createdAt,
  Value<int> rowid,
});
typedef $$AuditLogTableTableUpdateCompanionBuilder = AuditLogTableCompanion
    Function({
  Value<String> id,
  Value<String> user,
  Value<String> action,
  Value<String> target,
  Value<String> details,
  Value<String> type,
  Value<DateTime> timestamp,
  Value<DateTime?> lastModified,
  Value<DateTime?> lastSyncedAt,
  Value<String?> syncStatus,
  Value<bool?> dirtyFlag,
  Value<String?> cloudId,
  Value<bool?> deletedLocally,
  Value<String?> permissionsMask,
  Value<String?> ownerId,
  Value<int> version,
  Value<bool> isDeleted,
  Value<DateTime?> updatedAt,
  Value<DateTime?> createdAt,
  Value<int> rowid,
});

class $$AuditLogTableTableFilterComposer
    extends Composer<_$AppDatabase, $AuditLogTableTable> {
  $$AuditLogTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get user => $composableBuilder(
      column: $table.user, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get action => $composableBuilder(
      column: $table.action, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get target => $composableBuilder(
      column: $table.target, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get details => $composableBuilder(
      column: $table.details, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
      column: $table.timestamp, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastModified => $composableBuilder(
      column: $table.lastModified, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get dirtyFlag => $composableBuilder(
      column: $table.dirtyFlag, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get cloudId => $composableBuilder(
      column: $table.cloudId, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get deletedLocally => $composableBuilder(
      column: $table.deletedLocally,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get permissionsMask => $composableBuilder(
      column: $table.permissionsMask,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get ownerId => $composableBuilder(
      column: $table.ownerId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$AuditLogTableTableOrderingComposer
    extends Composer<_$AppDatabase, $AuditLogTableTable> {
  $$AuditLogTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get user => $composableBuilder(
      column: $table.user, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get action => $composableBuilder(
      column: $table.action, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get target => $composableBuilder(
      column: $table.target, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get details => $composableBuilder(
      column: $table.details, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
      column: $table.timestamp, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastModified => $composableBuilder(
      column: $table.lastModified,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get dirtyFlag => $composableBuilder(
      column: $table.dirtyFlag, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get cloudId => $composableBuilder(
      column: $table.cloudId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get deletedLocally => $composableBuilder(
      column: $table.deletedLocally,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get permissionsMask => $composableBuilder(
      column: $table.permissionsMask,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get ownerId => $composableBuilder(
      column: $table.ownerId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$AuditLogTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $AuditLogTableTable> {
  $$AuditLogTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get user =>
      $composableBuilder(column: $table.user, builder: (column) => column);

  GeneratedColumn<String> get action =>
      $composableBuilder(column: $table.action, builder: (column) => column);

  GeneratedColumn<String> get target =>
      $composableBuilder(column: $table.target, builder: (column) => column);

  GeneratedColumn<String> get details =>
      $composableBuilder(column: $table.details, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<DateTime> get lastModified => $composableBuilder(
      column: $table.lastModified, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => column);

  GeneratedColumn<bool> get dirtyFlag =>
      $composableBuilder(column: $table.dirtyFlag, builder: (column) => column);

  GeneratedColumn<String> get cloudId =>
      $composableBuilder(column: $table.cloudId, builder: (column) => column);

  GeneratedColumn<bool> get deletedLocally => $composableBuilder(
      column: $table.deletedLocally, builder: (column) => column);

  GeneratedColumn<String> get permissionsMask => $composableBuilder(
      column: $table.permissionsMask, builder: (column) => column);

  GeneratedColumn<String> get ownerId =>
      $composableBuilder(column: $table.ownerId, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$AuditLogTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AuditLogTableTable,
    AuditLogEntry,
    $$AuditLogTableTableFilterComposer,
    $$AuditLogTableTableOrderingComposer,
    $$AuditLogTableTableAnnotationComposer,
    $$AuditLogTableTableCreateCompanionBuilder,
    $$AuditLogTableTableUpdateCompanionBuilder,
    (
      AuditLogEntry,
      BaseReferences<_$AppDatabase, $AuditLogTableTable, AuditLogEntry>
    ),
    AuditLogEntry,
    PrefetchHooks Function()> {
  $$AuditLogTableTableTableManager(_$AppDatabase db, $AuditLogTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AuditLogTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AuditLogTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AuditLogTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> user = const Value.absent(),
            Value<String> action = const Value.absent(),
            Value<String> target = const Value.absent(),
            Value<String> details = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<DateTime> timestamp = const Value.absent(),
            Value<DateTime?> lastModified = const Value.absent(),
            Value<DateTime?> lastSyncedAt = const Value.absent(),
            Value<String?> syncStatus = const Value.absent(),
            Value<bool?> dirtyFlag = const Value.absent(),
            Value<String?> cloudId = const Value.absent(),
            Value<bool?> deletedLocally = const Value.absent(),
            Value<String?> permissionsMask = const Value.absent(),
            Value<String?> ownerId = const Value.absent(),
            Value<int> version = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<DateTime?> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AuditLogTableCompanion(
            id: id,
            user: user,
            action: action,
            target: target,
            details: details,
            type: type,
            timestamp: timestamp,
            lastModified: lastModified,
            lastSyncedAt: lastSyncedAt,
            syncStatus: syncStatus,
            dirtyFlag: dirtyFlag,
            cloudId: cloudId,
            deletedLocally: deletedLocally,
            permissionsMask: permissionsMask,
            ownerId: ownerId,
            version: version,
            isDeleted: isDeleted,
            updatedAt: updatedAt,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String user,
            required String action,
            required String target,
            required String details,
            required String type,
            Value<DateTime> timestamp = const Value.absent(),
            Value<DateTime?> lastModified = const Value.absent(),
            Value<DateTime?> lastSyncedAt = const Value.absent(),
            Value<String?> syncStatus = const Value.absent(),
            Value<bool?> dirtyFlag = const Value.absent(),
            Value<String?> cloudId = const Value.absent(),
            Value<bool?> deletedLocally = const Value.absent(),
            Value<String?> permissionsMask = const Value.absent(),
            Value<String?> ownerId = const Value.absent(),
            Value<int> version = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<DateTime?> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AuditLogTableCompanion.insert(
            id: id,
            user: user,
            action: action,
            target: target,
            details: details,
            type: type,
            timestamp: timestamp,
            lastModified: lastModified,
            lastSyncedAt: lastSyncedAt,
            syncStatus: syncStatus,
            dirtyFlag: dirtyFlag,
            cloudId: cloudId,
            deletedLocally: deletedLocally,
            permissionsMask: permissionsMask,
            ownerId: ownerId,
            version: version,
            isDeleted: isDeleted,
            updatedAt: updatedAt,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$AuditLogTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AuditLogTableTable,
    AuditLogEntry,
    $$AuditLogTableTableFilterComposer,
    $$AuditLogTableTableOrderingComposer,
    $$AuditLogTableTableAnnotationComposer,
    $$AuditLogTableTableCreateCompanionBuilder,
    $$AuditLogTableTableUpdateCompanionBuilder,
    (
      AuditLogEntry,
      BaseReferences<_$AppDatabase, $AuditLogTableTable, AuditLogEntry>
    ),
    AuditLogEntry,
    PrefetchHooks Function()>;
typedef $$WhatsappTemplatesTableTableCreateCompanionBuilder
    = WhatsappTemplatesTableCompanion Function({
  required String id,
  required String title,
  required String content,
  Value<int> isActive,
  Value<DateTime?> lastModified,
  Value<DateTime?> lastSyncedAt,
  Value<String?> syncStatus,
  Value<bool?> dirtyFlag,
  Value<String?> cloudId,
  Value<bool?> deletedLocally,
  Value<String?> permissionsMask,
  Value<String?> ownerId,
  Value<int> version,
  Value<bool> isDeleted,
  Value<DateTime> updatedAt,
  Value<DateTime> createdAt,
  Value<int> rowid,
});
typedef $$WhatsappTemplatesTableTableUpdateCompanionBuilder
    = WhatsappTemplatesTableCompanion Function({
  Value<String> id,
  Value<String> title,
  Value<String> content,
  Value<int> isActive,
  Value<DateTime?> lastModified,
  Value<DateTime?> lastSyncedAt,
  Value<String?> syncStatus,
  Value<bool?> dirtyFlag,
  Value<String?> cloudId,
  Value<bool?> deletedLocally,
  Value<String?> permissionsMask,
  Value<String?> ownerId,
  Value<int> version,
  Value<bool> isDeleted,
  Value<DateTime> updatedAt,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$WhatsappTemplatesTableTableFilterComposer
    extends Composer<_$AppDatabase, $WhatsappTemplatesTableTable> {
  $$WhatsappTemplatesTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get content => $composableBuilder(
      column: $table.content, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastModified => $composableBuilder(
      column: $table.lastModified, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get dirtyFlag => $composableBuilder(
      column: $table.dirtyFlag, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get cloudId => $composableBuilder(
      column: $table.cloudId, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get deletedLocally => $composableBuilder(
      column: $table.deletedLocally,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get permissionsMask => $composableBuilder(
      column: $table.permissionsMask,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get ownerId => $composableBuilder(
      column: $table.ownerId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$WhatsappTemplatesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $WhatsappTemplatesTableTable> {
  $$WhatsappTemplatesTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get content => $composableBuilder(
      column: $table.content, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastModified => $composableBuilder(
      column: $table.lastModified,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get dirtyFlag => $composableBuilder(
      column: $table.dirtyFlag, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get cloudId => $composableBuilder(
      column: $table.cloudId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get deletedLocally => $composableBuilder(
      column: $table.deletedLocally,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get permissionsMask => $composableBuilder(
      column: $table.permissionsMask,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get ownerId => $composableBuilder(
      column: $table.ownerId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$WhatsappTemplatesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $WhatsappTemplatesTableTable> {
  $$WhatsappTemplatesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<int> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get lastModified => $composableBuilder(
      column: $table.lastModified, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => column);

  GeneratedColumn<bool> get dirtyFlag =>
      $composableBuilder(column: $table.dirtyFlag, builder: (column) => column);

  GeneratedColumn<String> get cloudId =>
      $composableBuilder(column: $table.cloudId, builder: (column) => column);

  GeneratedColumn<bool> get deletedLocally => $composableBuilder(
      column: $table.deletedLocally, builder: (column) => column);

  GeneratedColumn<String> get permissionsMask => $composableBuilder(
      column: $table.permissionsMask, builder: (column) => column);

  GeneratedColumn<String> get ownerId =>
      $composableBuilder(column: $table.ownerId, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$WhatsappTemplatesTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $WhatsappTemplatesTableTable,
    WhatsappTemplateData,
    $$WhatsappTemplatesTableTableFilterComposer,
    $$WhatsappTemplatesTableTableOrderingComposer,
    $$WhatsappTemplatesTableTableAnnotationComposer,
    $$WhatsappTemplatesTableTableCreateCompanionBuilder,
    $$WhatsappTemplatesTableTableUpdateCompanionBuilder,
    (
      WhatsappTemplateData,
      BaseReferences<_$AppDatabase, $WhatsappTemplatesTableTable,
          WhatsappTemplateData>
    ),
    WhatsappTemplateData,
    PrefetchHooks Function()> {
  $$WhatsappTemplatesTableTableTableManager(
      _$AppDatabase db, $WhatsappTemplatesTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WhatsappTemplatesTableTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$WhatsappTemplatesTableTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WhatsappTemplatesTableTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String> content = const Value.absent(),
            Value<int> isActive = const Value.absent(),
            Value<DateTime?> lastModified = const Value.absent(),
            Value<DateTime?> lastSyncedAt = const Value.absent(),
            Value<String?> syncStatus = const Value.absent(),
            Value<bool?> dirtyFlag = const Value.absent(),
            Value<String?> cloudId = const Value.absent(),
            Value<bool?> deletedLocally = const Value.absent(),
            Value<String?> permissionsMask = const Value.absent(),
            Value<String?> ownerId = const Value.absent(),
            Value<int> version = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              WhatsappTemplatesTableCompanion(
            id: id,
            title: title,
            content: content,
            isActive: isActive,
            lastModified: lastModified,
            lastSyncedAt: lastSyncedAt,
            syncStatus: syncStatus,
            dirtyFlag: dirtyFlag,
            cloudId: cloudId,
            deletedLocally: deletedLocally,
            permissionsMask: permissionsMask,
            ownerId: ownerId,
            version: version,
            isDeleted: isDeleted,
            updatedAt: updatedAt,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String title,
            required String content,
            Value<int> isActive = const Value.absent(),
            Value<DateTime?> lastModified = const Value.absent(),
            Value<DateTime?> lastSyncedAt = const Value.absent(),
            Value<String?> syncStatus = const Value.absent(),
            Value<bool?> dirtyFlag = const Value.absent(),
            Value<String?> cloudId = const Value.absent(),
            Value<bool?> deletedLocally = const Value.absent(),
            Value<String?> permissionsMask = const Value.absent(),
            Value<String?> ownerId = const Value.absent(),
            Value<int> version = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              WhatsappTemplatesTableCompanion.insert(
            id: id,
            title: title,
            content: content,
            isActive: isActive,
            lastModified: lastModified,
            lastSyncedAt: lastSyncedAt,
            syncStatus: syncStatus,
            dirtyFlag: dirtyFlag,
            cloudId: cloudId,
            deletedLocally: deletedLocally,
            permissionsMask: permissionsMask,
            ownerId: ownerId,
            version: version,
            isDeleted: isDeleted,
            updatedAt: updatedAt,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$WhatsappTemplatesTableTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $WhatsappTemplatesTableTable,
        WhatsappTemplateData,
        $$WhatsappTemplatesTableTableFilterComposer,
        $$WhatsappTemplatesTableTableOrderingComposer,
        $$WhatsappTemplatesTableTableAnnotationComposer,
        $$WhatsappTemplatesTableTableCreateCompanionBuilder,
        $$WhatsappTemplatesTableTableUpdateCompanionBuilder,
        (
          WhatsappTemplateData,
          BaseReferences<_$AppDatabase, $WhatsappTemplatesTableTable,
              WhatsappTemplateData>
        ),
        WhatsappTemplateData,
        PrefetchHooks Function()>;
typedef $$GeneratorSettingsTableTableCreateCompanionBuilder
    = GeneratorSettingsTableCompanion Function({
  required String id,
  required String name,
  required String phoneNumber,
  required String address,
  Value<String?> logoPath,
  Value<String?> ownerId,
  Value<int> version,
  Value<bool> isDeleted,
  Value<DateTime> updatedAt,
  Value<DateTime> createdAt,
  Value<int> rowid,
});
typedef $$GeneratorSettingsTableTableUpdateCompanionBuilder
    = GeneratorSettingsTableCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String> phoneNumber,
  Value<String> address,
  Value<String?> logoPath,
  Value<String?> ownerId,
  Value<int> version,
  Value<bool> isDeleted,
  Value<DateTime> updatedAt,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$GeneratorSettingsTableTableFilterComposer
    extends Composer<_$AppDatabase, $GeneratorSettingsTableTable> {
  $$GeneratorSettingsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get phoneNumber => $composableBuilder(
      column: $table.phoneNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get address => $composableBuilder(
      column: $table.address, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get logoPath => $composableBuilder(
      column: $table.logoPath, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get ownerId => $composableBuilder(
      column: $table.ownerId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$GeneratorSettingsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $GeneratorSettingsTableTable> {
  $$GeneratorSettingsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get phoneNumber => $composableBuilder(
      column: $table.phoneNumber, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get address => $composableBuilder(
      column: $table.address, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get logoPath => $composableBuilder(
      column: $table.logoPath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get ownerId => $composableBuilder(
      column: $table.ownerId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$GeneratorSettingsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $GeneratorSettingsTableTable> {
  $$GeneratorSettingsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get phoneNumber => $composableBuilder(
      column: $table.phoneNumber, builder: (column) => column);

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<String> get logoPath =>
      $composableBuilder(column: $table.logoPath, builder: (column) => column);

  GeneratedColumn<String> get ownerId =>
      $composableBuilder(column: $table.ownerId, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$GeneratorSettingsTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $GeneratorSettingsTableTable,
    GeneratorSettingsData,
    $$GeneratorSettingsTableTableFilterComposer,
    $$GeneratorSettingsTableTableOrderingComposer,
    $$GeneratorSettingsTableTableAnnotationComposer,
    $$GeneratorSettingsTableTableCreateCompanionBuilder,
    $$GeneratorSettingsTableTableUpdateCompanionBuilder,
    (
      GeneratorSettingsData,
      BaseReferences<_$AppDatabase, $GeneratorSettingsTableTable,
          GeneratorSettingsData>
    ),
    GeneratorSettingsData,
    PrefetchHooks Function()> {
  $$GeneratorSettingsTableTableTableManager(
      _$AppDatabase db, $GeneratorSettingsTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GeneratorSettingsTableTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$GeneratorSettingsTableTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GeneratorSettingsTableTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> phoneNumber = const Value.absent(),
            Value<String> address = const Value.absent(),
            Value<String?> logoPath = const Value.absent(),
            Value<String?> ownerId = const Value.absent(),
            Value<int> version = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              GeneratorSettingsTableCompanion(
            id: id,
            name: name,
            phoneNumber: phoneNumber,
            address: address,
            logoPath: logoPath,
            ownerId: ownerId,
            version: version,
            isDeleted: isDeleted,
            updatedAt: updatedAt,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            required String phoneNumber,
            required String address,
            Value<String?> logoPath = const Value.absent(),
            Value<String?> ownerId = const Value.absent(),
            Value<int> version = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              GeneratorSettingsTableCompanion.insert(
            id: id,
            name: name,
            phoneNumber: phoneNumber,
            address: address,
            logoPath: logoPath,
            ownerId: ownerId,
            version: version,
            isDeleted: isDeleted,
            updatedAt: updatedAt,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$GeneratorSettingsTableTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $GeneratorSettingsTableTable,
        GeneratorSettingsData,
        $$GeneratorSettingsTableTableFilterComposer,
        $$GeneratorSettingsTableTableOrderingComposer,
        $$GeneratorSettingsTableTableAnnotationComposer,
        $$GeneratorSettingsTableTableCreateCompanionBuilder,
        $$GeneratorSettingsTableTableUpdateCompanionBuilder,
        (
          GeneratorSettingsData,
          BaseReferences<_$AppDatabase, $GeneratorSettingsTableTable,
              GeneratorSettingsData>
        ),
        GeneratorSettingsData,
        PrefetchHooks Function()>;
typedef $$OutboxTableTableCreateCompanionBuilder = OutboxTableCompanion
    Function({
  required String id,
  required String targetTable,
  required String operationType,
  required String documentId,
  required String payload,
  Value<String> status,
  Value<int> retryCount,
  Value<String?> lastError,
  required DateTime createdAt,
  Value<DateTime?> syncedAt,
  Value<DateTime?> updatedAt,
  Value<int> rowid,
});
typedef $$OutboxTableTableUpdateCompanionBuilder = OutboxTableCompanion
    Function({
  Value<String> id,
  Value<String> targetTable,
  Value<String> operationType,
  Value<String> documentId,
  Value<String> payload,
  Value<String> status,
  Value<int> retryCount,
  Value<String?> lastError,
  Value<DateTime> createdAt,
  Value<DateTime?> syncedAt,
  Value<DateTime?> updatedAt,
  Value<int> rowid,
});

class $$OutboxTableTableFilterComposer
    extends Composer<_$AppDatabase, $OutboxTableTable> {
  $$OutboxTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get targetTable => $composableBuilder(
      column: $table.targetTable, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get operationType => $composableBuilder(
      column: $table.operationType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get documentId => $composableBuilder(
      column: $table.documentId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get payload => $composableBuilder(
      column: $table.payload, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get retryCount => $composableBuilder(
      column: $table.retryCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lastError => $composableBuilder(
      column: $table.lastError, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get syncedAt => $composableBuilder(
      column: $table.syncedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$OutboxTableTableOrderingComposer
    extends Composer<_$AppDatabase, $OutboxTableTable> {
  $$OutboxTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get targetTable => $composableBuilder(
      column: $table.targetTable, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get operationType => $composableBuilder(
      column: $table.operationType,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get documentId => $composableBuilder(
      column: $table.documentId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get payload => $composableBuilder(
      column: $table.payload, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get retryCount => $composableBuilder(
      column: $table.retryCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lastError => $composableBuilder(
      column: $table.lastError, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get syncedAt => $composableBuilder(
      column: $table.syncedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$OutboxTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $OutboxTableTable> {
  $$OutboxTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get targetTable => $composableBuilder(
      column: $table.targetTable, builder: (column) => column);

  GeneratedColumn<String> get operationType => $composableBuilder(
      column: $table.operationType, builder: (column) => column);

  GeneratedColumn<String> get documentId => $composableBuilder(
      column: $table.documentId, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get retryCount => $composableBuilder(
      column: $table.retryCount, builder: (column) => column);

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$OutboxTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $OutboxTableTable,
    OutboxEntry,
    $$OutboxTableTableFilterComposer,
    $$OutboxTableTableOrderingComposer,
    $$OutboxTableTableAnnotationComposer,
    $$OutboxTableTableCreateCompanionBuilder,
    $$OutboxTableTableUpdateCompanionBuilder,
    (
      OutboxEntry,
      BaseReferences<_$AppDatabase, $OutboxTableTable, OutboxEntry>
    ),
    OutboxEntry,
    PrefetchHooks Function()> {
  $$OutboxTableTableTableManager(_$AppDatabase db, $OutboxTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OutboxTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OutboxTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OutboxTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> targetTable = const Value.absent(),
            Value<String> operationType = const Value.absent(),
            Value<String> documentId = const Value.absent(),
            Value<String> payload = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<int> retryCount = const Value.absent(),
            Value<String?> lastError = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime?> syncedAt = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              OutboxTableCompanion(
            id: id,
            targetTable: targetTable,
            operationType: operationType,
            documentId: documentId,
            payload: payload,
            status: status,
            retryCount: retryCount,
            lastError: lastError,
            createdAt: createdAt,
            syncedAt: syncedAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String targetTable,
            required String operationType,
            required String documentId,
            required String payload,
            Value<String> status = const Value.absent(),
            Value<int> retryCount = const Value.absent(),
            Value<String?> lastError = const Value.absent(),
            required DateTime createdAt,
            Value<DateTime?> syncedAt = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              OutboxTableCompanion.insert(
            id: id,
            targetTable: targetTable,
            operationType: operationType,
            documentId: documentId,
            payload: payload,
            status: status,
            retryCount: retryCount,
            lastError: lastError,
            createdAt: createdAt,
            syncedAt: syncedAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$OutboxTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $OutboxTableTable,
    OutboxEntry,
    $$OutboxTableTableFilterComposer,
    $$OutboxTableTableOrderingComposer,
    $$OutboxTableTableAnnotationComposer,
    $$OutboxTableTableCreateCompanionBuilder,
    $$OutboxTableTableUpdateCompanionBuilder,
    (
      OutboxEntry,
      BaseReferences<_$AppDatabase, $OutboxTableTable, OutboxEntry>
    ),
    OutboxEntry,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$SubscribersTableTableTableManager get subscribersTable =>
      $$SubscribersTableTableTableManager(_db, _db.subscribersTable);
  $$CabinetsTableTableTableManager get cabinetsTable =>
      $$CabinetsTableTableTableManager(_db, _db.cabinetsTable);
  $$PaymentsTableTableTableManager get paymentsTable =>
      $$PaymentsTableTableTableManager(_db, _db.paymentsTable);
  $$WorkersTableTableTableManager get workersTable =>
      $$WorkersTableTableTableManager(_db, _db.workersTable);
  $$AuditLogTableTableTableManager get auditLogTable =>
      $$AuditLogTableTableTableManager(_db, _db.auditLogTable);
  $$WhatsappTemplatesTableTableTableManager get whatsappTemplatesTable =>
      $$WhatsappTemplatesTableTableTableManager(
          _db, _db.whatsappTemplatesTable);
  $$GeneratorSettingsTableTableTableManager get generatorSettingsTable =>
      $$GeneratorSettingsTableTableTableManager(
          _db, _db.generatorSettingsTable);
  $$OutboxTableTableTableManager get outboxTable =>
      $$OutboxTableTableTableManager(_db, _db.outboxTable);
}
