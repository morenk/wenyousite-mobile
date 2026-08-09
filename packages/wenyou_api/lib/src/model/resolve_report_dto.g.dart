// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'resolve_report_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ResolveReportDtoOutcomeEnum _$resolveReportDtoOutcomeEnum_RESOLVED =
    const ResolveReportDtoOutcomeEnum._('RESOLVED');
const ResolveReportDtoOutcomeEnum _$resolveReportDtoOutcomeEnum_DISMISSED =
    const ResolveReportDtoOutcomeEnum._('DISMISSED');
const ResolveReportDtoOutcomeEnum
_$resolveReportDtoOutcomeEnum_unknownDefaultOpenApi =
    const ResolveReportDtoOutcomeEnum._('unknownDefaultOpenApi');

ResolveReportDtoOutcomeEnum _$resolveReportDtoOutcomeEnumValueOf(String name) {
  switch (name) {
    case 'RESOLVED':
      return _$resolveReportDtoOutcomeEnum_RESOLVED;
    case 'DISMISSED':
      return _$resolveReportDtoOutcomeEnum_DISMISSED;
    case 'unknownDefaultOpenApi':
      return _$resolveReportDtoOutcomeEnum_unknownDefaultOpenApi;
    default:
      return _$resolveReportDtoOutcomeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<ResolveReportDtoOutcomeEnum>
_$resolveReportDtoOutcomeEnumValues =
    BuiltSet<ResolveReportDtoOutcomeEnum>(const <ResolveReportDtoOutcomeEnum>[
      _$resolveReportDtoOutcomeEnum_RESOLVED,
      _$resolveReportDtoOutcomeEnum_DISMISSED,
      _$resolveReportDtoOutcomeEnum_unknownDefaultOpenApi,
    ]);

const ResolveReportDtoActionEnum _$resolveReportDtoActionEnum_NONE =
    const ResolveReportDtoActionEnum._('NONE');
const ResolveReportDtoActionEnum _$resolveReportDtoActionEnum_HIDE_CONTENT =
    const ResolveReportDtoActionEnum._('HIDE_CONTENT');
const ResolveReportDtoActionEnum _$resolveReportDtoActionEnum_SUSPEND_USER =
    const ResolveReportDtoActionEnum._('SUSPEND_USER');
const ResolveReportDtoActionEnum _$resolveReportDtoActionEnum_BAN_USER =
    const ResolveReportDtoActionEnum._('BAN_USER');
const ResolveReportDtoActionEnum
_$resolveReportDtoActionEnum_unknownDefaultOpenApi =
    const ResolveReportDtoActionEnum._('unknownDefaultOpenApi');

ResolveReportDtoActionEnum _$resolveReportDtoActionEnumValueOf(String name) {
  switch (name) {
    case 'NONE':
      return _$resolveReportDtoActionEnum_NONE;
    case 'HIDE_CONTENT':
      return _$resolveReportDtoActionEnum_HIDE_CONTENT;
    case 'SUSPEND_USER':
      return _$resolveReportDtoActionEnum_SUSPEND_USER;
    case 'BAN_USER':
      return _$resolveReportDtoActionEnum_BAN_USER;
    case 'unknownDefaultOpenApi':
      return _$resolveReportDtoActionEnum_unknownDefaultOpenApi;
    default:
      return _$resolveReportDtoActionEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<ResolveReportDtoActionEnum> _$resolveReportDtoActionEnumValues =
    BuiltSet<ResolveReportDtoActionEnum>(const <ResolveReportDtoActionEnum>[
      _$resolveReportDtoActionEnum_NONE,
      _$resolveReportDtoActionEnum_HIDE_CONTENT,
      _$resolveReportDtoActionEnum_SUSPEND_USER,
      _$resolveReportDtoActionEnum_BAN_USER,
      _$resolveReportDtoActionEnum_unknownDefaultOpenApi,
    ]);

Serializer<ResolveReportDtoOutcomeEnum>
_$resolveReportDtoOutcomeEnumSerializer =
    _$ResolveReportDtoOutcomeEnumSerializer();
Serializer<ResolveReportDtoActionEnum> _$resolveReportDtoActionEnumSerializer =
    _$ResolveReportDtoActionEnumSerializer();

class _$ResolveReportDtoOutcomeEnumSerializer
    implements PrimitiveSerializer<ResolveReportDtoOutcomeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'RESOLVED': 'RESOLVED',
    'DISMISSED': 'DISMISSED',
    'unknownDefaultOpenApi': 'unknown_default_open_api',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'RESOLVED': 'RESOLVED',
    'DISMISSED': 'DISMISSED',
    'unknown_default_open_api': 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[ResolveReportDtoOutcomeEnum];
  @override
  final String wireName = 'ResolveReportDtoOutcomeEnum';

  @override
  Object serialize(
    Serializers serializers,
    ResolveReportDtoOutcomeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  ResolveReportDtoOutcomeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => ResolveReportDtoOutcomeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$ResolveReportDtoActionEnumSerializer
    implements PrimitiveSerializer<ResolveReportDtoActionEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'NONE': 'NONE',
    'HIDE_CONTENT': 'HIDE_CONTENT',
    'SUSPEND_USER': 'SUSPEND_USER',
    'BAN_USER': 'BAN_USER',
    'unknownDefaultOpenApi': 'unknown_default_open_api',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'NONE': 'NONE',
    'HIDE_CONTENT': 'HIDE_CONTENT',
    'SUSPEND_USER': 'SUSPEND_USER',
    'BAN_USER': 'BAN_USER',
    'unknown_default_open_api': 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[ResolveReportDtoActionEnum];
  @override
  final String wireName = 'ResolveReportDtoActionEnum';

  @override
  Object serialize(
    Serializers serializers,
    ResolveReportDtoActionEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  ResolveReportDtoActionEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => ResolveReportDtoActionEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$ResolveReportDto extends ResolveReportDto {
  @override
  final ResolveReportDtoOutcomeEnum outcome;
  @override
  final String note;
  @override
  final ResolveReportDtoActionEnum? action;
  @override
  final DateTime? suspendUntil;

  factory _$ResolveReportDto([
    void Function(ResolveReportDtoBuilder)? updates,
  ]) => (ResolveReportDtoBuilder()..update(updates))._build();

  _$ResolveReportDto._({
    required this.outcome,
    required this.note,
    this.action,
    this.suspendUntil,
  }) : super._();
  @override
  ResolveReportDto rebuild(void Function(ResolveReportDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ResolveReportDtoBuilder toBuilder() =>
      ResolveReportDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ResolveReportDto &&
        outcome == other.outcome &&
        note == other.note &&
        action == other.action &&
        suspendUntil == other.suspendUntil;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, outcome.hashCode);
    _$hash = $jc(_$hash, note.hashCode);
    _$hash = $jc(_$hash, action.hashCode);
    _$hash = $jc(_$hash, suspendUntil.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ResolveReportDto')
          ..add('outcome', outcome)
          ..add('note', note)
          ..add('action', action)
          ..add('suspendUntil', suspendUntil))
        .toString();
  }
}

class ResolveReportDtoBuilder
    implements Builder<ResolveReportDto, ResolveReportDtoBuilder> {
  _$ResolveReportDto? _$v;

  ResolveReportDtoOutcomeEnum? _outcome;
  ResolveReportDtoOutcomeEnum? get outcome => _$this._outcome;
  set outcome(ResolveReportDtoOutcomeEnum? outcome) =>
      _$this._outcome = outcome;

  String? _note;
  String? get note => _$this._note;
  set note(String? note) => _$this._note = note;

  ResolveReportDtoActionEnum? _action;
  ResolveReportDtoActionEnum? get action => _$this._action;
  set action(ResolveReportDtoActionEnum? action) => _$this._action = action;

  DateTime? _suspendUntil;
  DateTime? get suspendUntil => _$this._suspendUntil;
  set suspendUntil(DateTime? suspendUntil) =>
      _$this._suspendUntil = suspendUntil;

  ResolveReportDtoBuilder() {
    ResolveReportDto._defaults(this);
  }

  ResolveReportDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _outcome = $v.outcome;
      _note = $v.note;
      _action = $v.action;
      _suspendUntil = $v.suspendUntil;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ResolveReportDto other) {
    _$v = other as _$ResolveReportDto;
  }

  @override
  void update(void Function(ResolveReportDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ResolveReportDto build() => _build();

  _$ResolveReportDto _build() {
    final _$result =
        _$v ??
        _$ResolveReportDto._(
          outcome: BuiltValueNullFieldError.checkNotNull(
            outcome,
            r'ResolveReportDto',
            'outcome',
          ),
          note: BuiltValueNullFieldError.checkNotNull(
            note,
            r'ResolveReportDto',
            'note',
          ),
          action: action,
          suspendUntil: suspendUntil,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
