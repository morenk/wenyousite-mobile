// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_content_moderation_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const AdminContentModerationResponseDtoTargetTypeEnum
_$adminContentModerationResponseDtoTargetTypeEnum_THREAD =
    const AdminContentModerationResponseDtoTargetTypeEnum._('THREAD');
const AdminContentModerationResponseDtoTargetTypeEnum
_$adminContentModerationResponseDtoTargetTypeEnum_POST =
    const AdminContentModerationResponseDtoTargetTypeEnum._('POST');
const AdminContentModerationResponseDtoTargetTypeEnum
_$adminContentModerationResponseDtoTargetTypeEnum_MOMENT =
    const AdminContentModerationResponseDtoTargetTypeEnum._('MOMENT');
const AdminContentModerationResponseDtoTargetTypeEnum
_$adminContentModerationResponseDtoTargetTypeEnum_MOMENT_COMMENT =
    const AdminContentModerationResponseDtoTargetTypeEnum._('MOMENT_COMMENT');
const AdminContentModerationResponseDtoTargetTypeEnum
_$adminContentModerationResponseDtoTargetTypeEnum_unknownDefaultOpenApi =
    const AdminContentModerationResponseDtoTargetTypeEnum._(
      'unknownDefaultOpenApi',
    );

AdminContentModerationResponseDtoTargetTypeEnum
_$adminContentModerationResponseDtoTargetTypeEnumValueOf(String name) {
  switch (name) {
    case 'THREAD':
      return _$adminContentModerationResponseDtoTargetTypeEnum_THREAD;
    case 'POST':
      return _$adminContentModerationResponseDtoTargetTypeEnum_POST;
    case 'MOMENT':
      return _$adminContentModerationResponseDtoTargetTypeEnum_MOMENT;
    case 'MOMENT_COMMENT':
      return _$adminContentModerationResponseDtoTargetTypeEnum_MOMENT_COMMENT;
    case 'unknownDefaultOpenApi':
      return _$adminContentModerationResponseDtoTargetTypeEnum_unknownDefaultOpenApi;
    default:
      return _$adminContentModerationResponseDtoTargetTypeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<AdminContentModerationResponseDtoTargetTypeEnum>
_$adminContentModerationResponseDtoTargetTypeEnumValues =
    BuiltSet<AdminContentModerationResponseDtoTargetTypeEnum>(
      const <AdminContentModerationResponseDtoTargetTypeEnum>[
        _$adminContentModerationResponseDtoTargetTypeEnum_THREAD,
        _$adminContentModerationResponseDtoTargetTypeEnum_POST,
        _$adminContentModerationResponseDtoTargetTypeEnum_MOMENT,
        _$adminContentModerationResponseDtoTargetTypeEnum_MOMENT_COMMENT,
        _$adminContentModerationResponseDtoTargetTypeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<AdminContentModerationResponseDtoTargetTypeEnum>
_$adminContentModerationResponseDtoTargetTypeEnumSerializer =
    _$AdminContentModerationResponseDtoTargetTypeEnumSerializer();

class _$AdminContentModerationResponseDtoTargetTypeEnumSerializer
    implements
        PrimitiveSerializer<AdminContentModerationResponseDtoTargetTypeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'THREAD': 'THREAD',
    'POST': 'POST',
    'MOMENT': 'MOMENT',
    'MOMENT_COMMENT': 'MOMENT_COMMENT',
    'unknownDefaultOpenApi': 'unknown_default_open_api',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'THREAD': 'THREAD',
    'POST': 'POST',
    'MOMENT': 'MOMENT',
    'MOMENT_COMMENT': 'MOMENT_COMMENT',
    'unknown_default_open_api': 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[
    AdminContentModerationResponseDtoTargetTypeEnum,
  ];
  @override
  final String wireName = 'AdminContentModerationResponseDtoTargetTypeEnum';

  @override
  Object serialize(
    Serializers serializers,
    AdminContentModerationResponseDtoTargetTypeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  AdminContentModerationResponseDtoTargetTypeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => AdminContentModerationResponseDtoTargetTypeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$AdminContentModerationResponseDto
    extends AdminContentModerationResponseDto {
  @override
  final AdminContentModerationResponseDtoTargetTypeEnum targetType;
  @override
  final String targetId;
  @override
  final bool hidden;
  @override
  final DateTime? deletedAt;

  factory _$AdminContentModerationResponseDto([
    void Function(AdminContentModerationResponseDtoBuilder)? updates,
  ]) => (AdminContentModerationResponseDtoBuilder()..update(updates))._build();

  _$AdminContentModerationResponseDto._({
    required this.targetType,
    required this.targetId,
    required this.hidden,
    this.deletedAt,
  }) : super._();
  @override
  AdminContentModerationResponseDto rebuild(
    void Function(AdminContentModerationResponseDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  AdminContentModerationResponseDtoBuilder toBuilder() =>
      AdminContentModerationResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminContentModerationResponseDto &&
        targetType == other.targetType &&
        targetId == other.targetId &&
        hidden == other.hidden &&
        deletedAt == other.deletedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, targetType.hashCode);
    _$hash = $jc(_$hash, targetId.hashCode);
    _$hash = $jc(_$hash, hidden.hashCode);
    _$hash = $jc(_$hash, deletedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AdminContentModerationResponseDto')
          ..add('targetType', targetType)
          ..add('targetId', targetId)
          ..add('hidden', hidden)
          ..add('deletedAt', deletedAt))
        .toString();
  }
}

class AdminContentModerationResponseDtoBuilder
    implements
        Builder<
          AdminContentModerationResponseDto,
          AdminContentModerationResponseDtoBuilder
        > {
  _$AdminContentModerationResponseDto? _$v;

  AdminContentModerationResponseDtoTargetTypeEnum? _targetType;
  AdminContentModerationResponseDtoTargetTypeEnum? get targetType =>
      _$this._targetType;
  set targetType(AdminContentModerationResponseDtoTargetTypeEnum? targetType) =>
      _$this._targetType = targetType;

  String? _targetId;
  String? get targetId => _$this._targetId;
  set targetId(String? targetId) => _$this._targetId = targetId;

  bool? _hidden;
  bool? get hidden => _$this._hidden;
  set hidden(bool? hidden) => _$this._hidden = hidden;

  DateTime? _deletedAt;
  DateTime? get deletedAt => _$this._deletedAt;
  set deletedAt(DateTime? deletedAt) => _$this._deletedAt = deletedAt;

  AdminContentModerationResponseDtoBuilder() {
    AdminContentModerationResponseDto._defaults(this);
  }

  AdminContentModerationResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _targetType = $v.targetType;
      _targetId = $v.targetId;
      _hidden = $v.hidden;
      _deletedAt = $v.deletedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AdminContentModerationResponseDto other) {
    _$v = other as _$AdminContentModerationResponseDto;
  }

  @override
  void update(
    void Function(AdminContentModerationResponseDtoBuilder)? updates,
  ) {
    if (updates != null) updates(this);
  }

  @override
  AdminContentModerationResponseDto build() => _build();

  _$AdminContentModerationResponseDto _build() {
    final _$result =
        _$v ??
        _$AdminContentModerationResponseDto._(
          targetType: BuiltValueNullFieldError.checkNotNull(
            targetType,
            r'AdminContentModerationResponseDto',
            'targetType',
          ),
          targetId: BuiltValueNullFieldError.checkNotNull(
            targetId,
            r'AdminContentModerationResponseDto',
            'targetId',
          ),
          hidden: BuiltValueNullFieldError.checkNotNull(
            hidden,
            r'AdminContentModerationResponseDto',
            'hidden',
          ),
          deletedAt: deletedAt,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
