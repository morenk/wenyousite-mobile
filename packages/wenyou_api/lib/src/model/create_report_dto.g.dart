// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_report_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$CreateReportDto extends CreateReportDto {
  @override
  final String targetType;
  @override
  final String targetId;
  @override
  final String reason;

  factory _$CreateReportDto([void Function(CreateReportDtoBuilder)? updates]) =>
      (CreateReportDtoBuilder()..update(updates))._build();

  _$CreateReportDto._({
    required this.targetType,
    required this.targetId,
    required this.reason,
  }) : super._();
  @override
  CreateReportDto rebuild(void Function(CreateReportDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CreateReportDtoBuilder toBuilder() => CreateReportDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CreateReportDto &&
        targetType == other.targetType &&
        targetId == other.targetId &&
        reason == other.reason;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, targetType.hashCode);
    _$hash = $jc(_$hash, targetId.hashCode);
    _$hash = $jc(_$hash, reason.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CreateReportDto')
          ..add('targetType', targetType)
          ..add('targetId', targetId)
          ..add('reason', reason))
        .toString();
  }
}

class CreateReportDtoBuilder
    implements Builder<CreateReportDto, CreateReportDtoBuilder> {
  _$CreateReportDto? _$v;

  String? _targetType;
  String? get targetType => _$this._targetType;
  set targetType(String? targetType) => _$this._targetType = targetType;

  String? _targetId;
  String? get targetId => _$this._targetId;
  set targetId(String? targetId) => _$this._targetId = targetId;

  String? _reason;
  String? get reason => _$this._reason;
  set reason(String? reason) => _$this._reason = reason;

  CreateReportDtoBuilder() {
    CreateReportDto._defaults(this);
  }

  CreateReportDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _targetType = $v.targetType;
      _targetId = $v.targetId;
      _reason = $v.reason;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CreateReportDto other) {
    _$v = other as _$CreateReportDto;
  }

  @override
  void update(void Function(CreateReportDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CreateReportDto build() => _build();

  _$CreateReportDto _build() {
    final _$result =
        _$v ??
        _$CreateReportDto._(
          targetType: BuiltValueNullFieldError.checkNotNull(
            targetType,
            r'CreateReportDto',
            'targetType',
          ),
          targetId: BuiltValueNullFieldError.checkNotNull(
            targetId,
            r'CreateReportDto',
            'targetId',
          ),
          reason: BuiltValueNullFieldError.checkNotNull(
            reason,
            r'CreateReportDto',
            'reason',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
