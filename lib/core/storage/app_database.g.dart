// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $LocalEditorSnapshotsTable extends LocalEditorSnapshots
    with TableInfo<$LocalEditorSnapshotsTable, LocalEditorSnapshotRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalEditorSnapshotsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contextTypeMeta = const VerificationMeta(
    'contextType',
  );
  @override
  late final GeneratedColumn<String> contextType = GeneratedColumn<String>(
    'context_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contextIdMeta = const VerificationMeta(
    'contextId',
  );
  @override
  late final GeneratedColumn<String> contextId = GeneratedColumn<String>(
    'context_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _metadataJsonMeta = const VerificationMeta(
    'metadataJson',
  );
  @override
  late final GeneratedColumn<String> metadataJson = GeneratedColumn<String>(
    'metadata_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _clientRequestIdMeta = const VerificationMeta(
    'clientRequestId',
  );
  @override
  late final GeneratedColumn<String> clientRequestId = GeneratedColumn<String>(
    'client_request_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    contextType,
    contextId,
    body,
    metadataJson,
    clientRequestId,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_editor_snapshots';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalEditorSnapshotRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('context_type')) {
      context.handle(
        _contextTypeMeta,
        contextType.isAcceptableOrUnknown(
          data['context_type']!,
          _contextTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_contextTypeMeta);
    }
    if (data.containsKey('context_id')) {
      context.handle(
        _contextIdMeta,
        contextId.isAcceptableOrUnknown(data['context_id']!, _contextIdMeta),
      );
    }
    if (data.containsKey('body')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['body']!, _bodyMeta),
      );
    } else if (isInserting) {
      context.missing(_bodyMeta);
    }
    if (data.containsKey('metadata_json')) {
      context.handle(
        _metadataJsonMeta,
        metadataJson.isAcceptableOrUnknown(
          data['metadata_json']!,
          _metadataJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_metadataJsonMeta);
    }
    if (data.containsKey('client_request_id')) {
      context.handle(
        _clientRequestIdMeta,
        clientRequestId.isAcceptableOrUnknown(
          data['client_request_id']!,
          _clientRequestIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_clientRequestIdMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalEditorSnapshotRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalEditorSnapshotRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      contextType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}context_type'],
      )!,
      contextId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}context_id'],
      ),
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body'],
      )!,
      metadataJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}metadata_json'],
      )!,
      clientRequestId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}client_request_id'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $LocalEditorSnapshotsTable createAlias(String alias) {
    return $LocalEditorSnapshotsTable(attachedDatabase, alias);
  }
}

class LocalEditorSnapshotRow extends DataClass
    implements Insertable<LocalEditorSnapshotRow> {
  final String id;
  final String contextType;
  final String? contextId;
  final String body;
  final String metadataJson;
  final String clientRequestId;
  final DateTime updatedAt;
  const LocalEditorSnapshotRow({
    required this.id,
    required this.contextType,
    this.contextId,
    required this.body,
    required this.metadataJson,
    required this.clientRequestId,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['context_type'] = Variable<String>(contextType);
    if (!nullToAbsent || contextId != null) {
      map['context_id'] = Variable<String>(contextId);
    }
    map['body'] = Variable<String>(body);
    map['metadata_json'] = Variable<String>(metadataJson);
    map['client_request_id'] = Variable<String>(clientRequestId);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  LocalEditorSnapshotsCompanion toCompanion(bool nullToAbsent) {
    return LocalEditorSnapshotsCompanion(
      id: Value(id),
      contextType: Value(contextType),
      contextId: contextId == null && nullToAbsent
          ? const Value.absent()
          : Value(contextId),
      body: Value(body),
      metadataJson: Value(metadataJson),
      clientRequestId: Value(clientRequestId),
      updatedAt: Value(updatedAt),
    );
  }

  factory LocalEditorSnapshotRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalEditorSnapshotRow(
      id: serializer.fromJson<String>(json['id']),
      contextType: serializer.fromJson<String>(json['contextType']),
      contextId: serializer.fromJson<String?>(json['contextId']),
      body: serializer.fromJson<String>(json['body']),
      metadataJson: serializer.fromJson<String>(json['metadataJson']),
      clientRequestId: serializer.fromJson<String>(json['clientRequestId']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'contextType': serializer.toJson<String>(contextType),
      'contextId': serializer.toJson<String?>(contextId),
      'body': serializer.toJson<String>(body),
      'metadataJson': serializer.toJson<String>(metadataJson),
      'clientRequestId': serializer.toJson<String>(clientRequestId),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  LocalEditorSnapshotRow copyWith({
    String? id,
    String? contextType,
    Value<String?> contextId = const Value.absent(),
    String? body,
    String? metadataJson,
    String? clientRequestId,
    DateTime? updatedAt,
  }) => LocalEditorSnapshotRow(
    id: id ?? this.id,
    contextType: contextType ?? this.contextType,
    contextId: contextId.present ? contextId.value : this.contextId,
    body: body ?? this.body,
    metadataJson: metadataJson ?? this.metadataJson,
    clientRequestId: clientRequestId ?? this.clientRequestId,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  LocalEditorSnapshotRow copyWithCompanion(LocalEditorSnapshotsCompanion data) {
    return LocalEditorSnapshotRow(
      id: data.id.present ? data.id.value : this.id,
      contextType: data.contextType.present
          ? data.contextType.value
          : this.contextType,
      contextId: data.contextId.present ? data.contextId.value : this.contextId,
      body: data.body.present ? data.body.value : this.body,
      metadataJson: data.metadataJson.present
          ? data.metadataJson.value
          : this.metadataJson,
      clientRequestId: data.clientRequestId.present
          ? data.clientRequestId.value
          : this.clientRequestId,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalEditorSnapshotRow(')
          ..write('id: $id, ')
          ..write('contextType: $contextType, ')
          ..write('contextId: $contextId, ')
          ..write('body: $body, ')
          ..write('metadataJson: $metadataJson, ')
          ..write('clientRequestId: $clientRequestId, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    contextType,
    contextId,
    body,
    metadataJson,
    clientRequestId,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalEditorSnapshotRow &&
          other.id == this.id &&
          other.contextType == this.contextType &&
          other.contextId == this.contextId &&
          other.body == this.body &&
          other.metadataJson == this.metadataJson &&
          other.clientRequestId == this.clientRequestId &&
          other.updatedAt == this.updatedAt);
}

class LocalEditorSnapshotsCompanion
    extends UpdateCompanion<LocalEditorSnapshotRow> {
  final Value<String> id;
  final Value<String> contextType;
  final Value<String?> contextId;
  final Value<String> body;
  final Value<String> metadataJson;
  final Value<String> clientRequestId;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const LocalEditorSnapshotsCompanion({
    this.id = const Value.absent(),
    this.contextType = const Value.absent(),
    this.contextId = const Value.absent(),
    this.body = const Value.absent(),
    this.metadataJson = const Value.absent(),
    this.clientRequestId = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalEditorSnapshotsCompanion.insert({
    required String id,
    required String contextType,
    this.contextId = const Value.absent(),
    required String body,
    required String metadataJson,
    required String clientRequestId,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       contextType = Value(contextType),
       body = Value(body),
       metadataJson = Value(metadataJson),
       clientRequestId = Value(clientRequestId),
       updatedAt = Value(updatedAt);
  static Insertable<LocalEditorSnapshotRow> custom({
    Expression<String>? id,
    Expression<String>? contextType,
    Expression<String>? contextId,
    Expression<String>? body,
    Expression<String>? metadataJson,
    Expression<String>? clientRequestId,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (contextType != null) 'context_type': contextType,
      if (contextId != null) 'context_id': contextId,
      if (body != null) 'body': body,
      if (metadataJson != null) 'metadata_json': metadataJson,
      if (clientRequestId != null) 'client_request_id': clientRequestId,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalEditorSnapshotsCompanion copyWith({
    Value<String>? id,
    Value<String>? contextType,
    Value<String?>? contextId,
    Value<String>? body,
    Value<String>? metadataJson,
    Value<String>? clientRequestId,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return LocalEditorSnapshotsCompanion(
      id: id ?? this.id,
      contextType: contextType ?? this.contextType,
      contextId: contextId ?? this.contextId,
      body: body ?? this.body,
      metadataJson: metadataJson ?? this.metadataJson,
      clientRequestId: clientRequestId ?? this.clientRequestId,
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
    if (contextType.present) {
      map['context_type'] = Variable<String>(contextType.value);
    }
    if (contextId.present) {
      map['context_id'] = Variable<String>(contextId.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (metadataJson.present) {
      map['metadata_json'] = Variable<String>(metadataJson.value);
    }
    if (clientRequestId.present) {
      map['client_request_id'] = Variable<String>(clientRequestId.value);
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
    return (StringBuffer('LocalEditorSnapshotsCompanion(')
          ..write('id: $id, ')
          ..write('contextType: $contextType, ')
          ..write('contextId: $contextId, ')
          ..write('body: $body, ')
          ..write('metadataJson: $metadataJson, ')
          ..write('clientRequestId: $clientRequestId, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PendingCreateOperationsTable extends PendingCreateOperations
    with TableInfo<$PendingCreateOperationsTable, PendingCreateOperationRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PendingCreateOperationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _clientRequestIdMeta = const VerificationMeta(
    'clientRequestId',
  );
  @override
  late final GeneratedColumn<String> clientRequestId = GeneratedColumn<String>(
    'client_request_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _operationTypeMeta = const VerificationMeta(
    'operationType',
  );
  @override
  late final GeneratedColumn<String> operationType = GeneratedColumn<String>(
    'operation_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _normalizedPayloadMeta = const VerificationMeta(
    'normalizedPayload',
  );
  @override
  late final GeneratedColumn<String> normalizedPayload =
      GeneratedColumn<String>(
        'normalized_payload',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _stateMeta = const VerificationMeta('state');
  @override
  late final GeneratedColumn<String> state = GeneratedColumn<String>(
    'state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    clientRequestId,
    operationType,
    normalizedPayload,
    state,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pending_create_operations';
  @override
  VerificationContext validateIntegrity(
    Insertable<PendingCreateOperationRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('client_request_id')) {
      context.handle(
        _clientRequestIdMeta,
        clientRequestId.isAcceptableOrUnknown(
          data['client_request_id']!,
          _clientRequestIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_clientRequestIdMeta);
    }
    if (data.containsKey('operation_type')) {
      context.handle(
        _operationTypeMeta,
        operationType.isAcceptableOrUnknown(
          data['operation_type']!,
          _operationTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_operationTypeMeta);
    }
    if (data.containsKey('normalized_payload')) {
      context.handle(
        _normalizedPayloadMeta,
        normalizedPayload.isAcceptableOrUnknown(
          data['normalized_payload']!,
          _normalizedPayloadMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_normalizedPayloadMeta);
    }
    if (data.containsKey('state')) {
      context.handle(
        _stateMeta,
        state.isAcceptableOrUnknown(data['state']!, _stateMeta),
      );
    } else if (isInserting) {
      context.missing(_stateMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {clientRequestId};
  @override
  PendingCreateOperationRow map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PendingCreateOperationRow(
      clientRequestId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}client_request_id'],
      )!,
      operationType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}operation_type'],
      )!,
      normalizedPayload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}normalized_payload'],
      )!,
      state: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}state'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $PendingCreateOperationsTable createAlias(String alias) {
    return $PendingCreateOperationsTable(attachedDatabase, alias);
  }
}

class PendingCreateOperationRow extends DataClass
    implements Insertable<PendingCreateOperationRow> {
  final String clientRequestId;
  final String operationType;
  final String normalizedPayload;
  final String state;
  final DateTime updatedAt;
  const PendingCreateOperationRow({
    required this.clientRequestId,
    required this.operationType,
    required this.normalizedPayload,
    required this.state,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['client_request_id'] = Variable<String>(clientRequestId);
    map['operation_type'] = Variable<String>(operationType);
    map['normalized_payload'] = Variable<String>(normalizedPayload);
    map['state'] = Variable<String>(state);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  PendingCreateOperationsCompanion toCompanion(bool nullToAbsent) {
    return PendingCreateOperationsCompanion(
      clientRequestId: Value(clientRequestId),
      operationType: Value(operationType),
      normalizedPayload: Value(normalizedPayload),
      state: Value(state),
      updatedAt: Value(updatedAt),
    );
  }

  factory PendingCreateOperationRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PendingCreateOperationRow(
      clientRequestId: serializer.fromJson<String>(json['clientRequestId']),
      operationType: serializer.fromJson<String>(json['operationType']),
      normalizedPayload: serializer.fromJson<String>(json['normalizedPayload']),
      state: serializer.fromJson<String>(json['state']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'clientRequestId': serializer.toJson<String>(clientRequestId),
      'operationType': serializer.toJson<String>(operationType),
      'normalizedPayload': serializer.toJson<String>(normalizedPayload),
      'state': serializer.toJson<String>(state),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  PendingCreateOperationRow copyWith({
    String? clientRequestId,
    String? operationType,
    String? normalizedPayload,
    String? state,
    DateTime? updatedAt,
  }) => PendingCreateOperationRow(
    clientRequestId: clientRequestId ?? this.clientRequestId,
    operationType: operationType ?? this.operationType,
    normalizedPayload: normalizedPayload ?? this.normalizedPayload,
    state: state ?? this.state,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  PendingCreateOperationRow copyWithCompanion(
    PendingCreateOperationsCompanion data,
  ) {
    return PendingCreateOperationRow(
      clientRequestId: data.clientRequestId.present
          ? data.clientRequestId.value
          : this.clientRequestId,
      operationType: data.operationType.present
          ? data.operationType.value
          : this.operationType,
      normalizedPayload: data.normalizedPayload.present
          ? data.normalizedPayload.value
          : this.normalizedPayload,
      state: data.state.present ? data.state.value : this.state,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PendingCreateOperationRow(')
          ..write('clientRequestId: $clientRequestId, ')
          ..write('operationType: $operationType, ')
          ..write('normalizedPayload: $normalizedPayload, ')
          ..write('state: $state, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    clientRequestId,
    operationType,
    normalizedPayload,
    state,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PendingCreateOperationRow &&
          other.clientRequestId == this.clientRequestId &&
          other.operationType == this.operationType &&
          other.normalizedPayload == this.normalizedPayload &&
          other.state == this.state &&
          other.updatedAt == this.updatedAt);
}

class PendingCreateOperationsCompanion
    extends UpdateCompanion<PendingCreateOperationRow> {
  final Value<String> clientRequestId;
  final Value<String> operationType;
  final Value<String> normalizedPayload;
  final Value<String> state;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const PendingCreateOperationsCompanion({
    this.clientRequestId = const Value.absent(),
    this.operationType = const Value.absent(),
    this.normalizedPayload = const Value.absent(),
    this.state = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PendingCreateOperationsCompanion.insert({
    required String clientRequestId,
    required String operationType,
    required String normalizedPayload,
    required String state,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : clientRequestId = Value(clientRequestId),
       operationType = Value(operationType),
       normalizedPayload = Value(normalizedPayload),
       state = Value(state),
       updatedAt = Value(updatedAt);
  static Insertable<PendingCreateOperationRow> custom({
    Expression<String>? clientRequestId,
    Expression<String>? operationType,
    Expression<String>? normalizedPayload,
    Expression<String>? state,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (clientRequestId != null) 'client_request_id': clientRequestId,
      if (operationType != null) 'operation_type': operationType,
      if (normalizedPayload != null) 'normalized_payload': normalizedPayload,
      if (state != null) 'state': state,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PendingCreateOperationsCompanion copyWith({
    Value<String>? clientRequestId,
    Value<String>? operationType,
    Value<String>? normalizedPayload,
    Value<String>? state,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return PendingCreateOperationsCompanion(
      clientRequestId: clientRequestId ?? this.clientRequestId,
      operationType: operationType ?? this.operationType,
      normalizedPayload: normalizedPayload ?? this.normalizedPayload,
      state: state ?? this.state,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (clientRequestId.present) {
      map['client_request_id'] = Variable<String>(clientRequestId.value);
    }
    if (operationType.present) {
      map['operation_type'] = Variable<String>(operationType.value);
    }
    if (normalizedPayload.present) {
      map['normalized_payload'] = Variable<String>(normalizedPayload.value);
    }
    if (state.present) {
      map['state'] = Variable<String>(state.value);
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
    return (StringBuffer('PendingCreateOperationsCompanion(')
          ..write('clientRequestId: $clientRequestId, ')
          ..write('operationType: $operationType, ')
          ..write('normalizedPayload: $normalizedPayload, ')
          ..write('state: $state, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $LocalEditorSnapshotsTable localEditorSnapshots =
      $LocalEditorSnapshotsTable(this);
  late final $PendingCreateOperationsTable pendingCreateOperations =
      $PendingCreateOperationsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    localEditorSnapshots,
    pendingCreateOperations,
  ];
}

typedef $$LocalEditorSnapshotsTableCreateCompanionBuilder =
    LocalEditorSnapshotsCompanion Function({
      required String id,
      required String contextType,
      Value<String?> contextId,
      required String body,
      required String metadataJson,
      required String clientRequestId,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$LocalEditorSnapshotsTableUpdateCompanionBuilder =
    LocalEditorSnapshotsCompanion Function({
      Value<String> id,
      Value<String> contextType,
      Value<String?> contextId,
      Value<String> body,
      Value<String> metadataJson,
      Value<String> clientRequestId,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$LocalEditorSnapshotsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalEditorSnapshotsTable> {
  $$LocalEditorSnapshotsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contextType => $composableBuilder(
    column: $table.contextType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contextId => $composableBuilder(
    column: $table.contextId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get metadataJson => $composableBuilder(
    column: $table.metadataJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get clientRequestId => $composableBuilder(
    column: $table.clientRequestId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalEditorSnapshotsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalEditorSnapshotsTable> {
  $$LocalEditorSnapshotsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contextType => $composableBuilder(
    column: $table.contextType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contextId => $composableBuilder(
    column: $table.contextId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get metadataJson => $composableBuilder(
    column: $table.metadataJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get clientRequestId => $composableBuilder(
    column: $table.clientRequestId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalEditorSnapshotsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalEditorSnapshotsTable> {
  $$LocalEditorSnapshotsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get contextType => $composableBuilder(
    column: $table.contextType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get contextId =>
      $composableBuilder(column: $table.contextId, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<String> get metadataJson => $composableBuilder(
    column: $table.metadataJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get clientRequestId => $composableBuilder(
    column: $table.clientRequestId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$LocalEditorSnapshotsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalEditorSnapshotsTable,
          LocalEditorSnapshotRow,
          $$LocalEditorSnapshotsTableFilterComposer,
          $$LocalEditorSnapshotsTableOrderingComposer,
          $$LocalEditorSnapshotsTableAnnotationComposer,
          $$LocalEditorSnapshotsTableCreateCompanionBuilder,
          $$LocalEditorSnapshotsTableUpdateCompanionBuilder,
          (
            LocalEditorSnapshotRow,
            BaseReferences<
              _$AppDatabase,
              $LocalEditorSnapshotsTable,
              LocalEditorSnapshotRow
            >,
          ),
          LocalEditorSnapshotRow,
          PrefetchHooks Function()
        > {
  $$LocalEditorSnapshotsTableTableManager(
    _$AppDatabase db,
    $LocalEditorSnapshotsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalEditorSnapshotsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalEditorSnapshotsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$LocalEditorSnapshotsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> contextType = const Value.absent(),
                Value<String?> contextId = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<String> metadataJson = const Value.absent(),
                Value<String> clientRequestId = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalEditorSnapshotsCompanion(
                id: id,
                contextType: contextType,
                contextId: contextId,
                body: body,
                metadataJson: metadataJson,
                clientRequestId: clientRequestId,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String contextType,
                Value<String?> contextId = const Value.absent(),
                required String body,
                required String metadataJson,
                required String clientRequestId,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => LocalEditorSnapshotsCompanion.insert(
                id: id,
                contextType: contextType,
                contextId: contextId,
                body: body,
                metadataJson: metadataJson,
                clientRequestId: clientRequestId,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalEditorSnapshotsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalEditorSnapshotsTable,
      LocalEditorSnapshotRow,
      $$LocalEditorSnapshotsTableFilterComposer,
      $$LocalEditorSnapshotsTableOrderingComposer,
      $$LocalEditorSnapshotsTableAnnotationComposer,
      $$LocalEditorSnapshotsTableCreateCompanionBuilder,
      $$LocalEditorSnapshotsTableUpdateCompanionBuilder,
      (
        LocalEditorSnapshotRow,
        BaseReferences<
          _$AppDatabase,
          $LocalEditorSnapshotsTable,
          LocalEditorSnapshotRow
        >,
      ),
      LocalEditorSnapshotRow,
      PrefetchHooks Function()
    >;
typedef $$PendingCreateOperationsTableCreateCompanionBuilder =
    PendingCreateOperationsCompanion Function({
      required String clientRequestId,
      required String operationType,
      required String normalizedPayload,
      required String state,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$PendingCreateOperationsTableUpdateCompanionBuilder =
    PendingCreateOperationsCompanion Function({
      Value<String> clientRequestId,
      Value<String> operationType,
      Value<String> normalizedPayload,
      Value<String> state,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$PendingCreateOperationsTableFilterComposer
    extends Composer<_$AppDatabase, $PendingCreateOperationsTable> {
  $$PendingCreateOperationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get clientRequestId => $composableBuilder(
    column: $table.clientRequestId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get operationType => $composableBuilder(
    column: $table.operationType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get normalizedPayload => $composableBuilder(
    column: $table.normalizedPayload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PendingCreateOperationsTableOrderingComposer
    extends Composer<_$AppDatabase, $PendingCreateOperationsTable> {
  $$PendingCreateOperationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get clientRequestId => $composableBuilder(
    column: $table.clientRequestId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get operationType => $composableBuilder(
    column: $table.operationType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get normalizedPayload => $composableBuilder(
    column: $table.normalizedPayload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PendingCreateOperationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PendingCreateOperationsTable> {
  $$PendingCreateOperationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get clientRequestId => $composableBuilder(
    column: $table.clientRequestId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get operationType => $composableBuilder(
    column: $table.operationType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get normalizedPayload => $composableBuilder(
    column: $table.normalizedPayload,
    builder: (column) => column,
  );

  GeneratedColumn<String> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$PendingCreateOperationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PendingCreateOperationsTable,
          PendingCreateOperationRow,
          $$PendingCreateOperationsTableFilterComposer,
          $$PendingCreateOperationsTableOrderingComposer,
          $$PendingCreateOperationsTableAnnotationComposer,
          $$PendingCreateOperationsTableCreateCompanionBuilder,
          $$PendingCreateOperationsTableUpdateCompanionBuilder,
          (
            PendingCreateOperationRow,
            BaseReferences<
              _$AppDatabase,
              $PendingCreateOperationsTable,
              PendingCreateOperationRow
            >,
          ),
          PendingCreateOperationRow,
          PrefetchHooks Function()
        > {
  $$PendingCreateOperationsTableTableManager(
    _$AppDatabase db,
    $PendingCreateOperationsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PendingCreateOperationsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$PendingCreateOperationsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$PendingCreateOperationsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> clientRequestId = const Value.absent(),
                Value<String> operationType = const Value.absent(),
                Value<String> normalizedPayload = const Value.absent(),
                Value<String> state = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PendingCreateOperationsCompanion(
                clientRequestId: clientRequestId,
                operationType: operationType,
                normalizedPayload: normalizedPayload,
                state: state,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String clientRequestId,
                required String operationType,
                required String normalizedPayload,
                required String state,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => PendingCreateOperationsCompanion.insert(
                clientRequestId: clientRequestId,
                operationType: operationType,
                normalizedPayload: normalizedPayload,
                state: state,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PendingCreateOperationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PendingCreateOperationsTable,
      PendingCreateOperationRow,
      $$PendingCreateOperationsTableFilterComposer,
      $$PendingCreateOperationsTableOrderingComposer,
      $$PendingCreateOperationsTableAnnotationComposer,
      $$PendingCreateOperationsTableCreateCompanionBuilder,
      $$PendingCreateOperationsTableUpdateCompanionBuilder,
      (
        PendingCreateOperationRow,
        BaseReferences<
          _$AppDatabase,
          $PendingCreateOperationsTable,
          PendingCreateOperationRow
        >,
      ),
      PendingCreateOperationRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$LocalEditorSnapshotsTableTableManager get localEditorSnapshots =>
      $$LocalEditorSnapshotsTableTableManager(_db, _db.localEditorSnapshots);
  $$PendingCreateOperationsTableTableManager get pendingCreateOperations =>
      $$PendingCreateOperationsTableTableManager(
        _db,
        _db.pendingCreateOperations,
      );
}
