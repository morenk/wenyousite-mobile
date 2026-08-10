// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_moderation_appeal_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$CreateModerationAppealDto extends CreateModerationAppealDto {
  @override
  final String decisionId;
  @override
  final String statement;

  factory _$CreateModerationAppealDto([
    void Function(CreateModerationAppealDtoBuilder)? updates,
  ]) => (CreateModerationAppealDtoBuilder()..update(updates))._build();

  _$CreateModerationAppealDto._({
    required this.decisionId,
    required this.statement,
  }) : super._();
  @override
  CreateModerationAppealDto rebuild(
    void Function(CreateModerationAppealDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  CreateModerationAppealDtoBuilder toBuilder() =>
      CreateModerationAppealDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CreateModerationAppealDto &&
        decisionId == other.decisionId &&
        statement == other.statement;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, decisionId.hashCode);
    _$hash = $jc(_$hash, statement.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CreateModerationAppealDto')
          ..add('decisionId', decisionId)
          ..add('statement', statement))
        .toString();
  }
}

class CreateModerationAppealDtoBuilder
    implements
        Builder<CreateModerationAppealDto, CreateModerationAppealDtoBuilder> {
  _$CreateModerationAppealDto? _$v;

  String? _decisionId;
  String? get decisionId => _$this._decisionId;
  set decisionId(String? decisionId) => _$this._decisionId = decisionId;

  String? _statement;
  String? get statement => _$this._statement;
  set statement(String? statement) => _$this._statement = statement;

  CreateModerationAppealDtoBuilder() {
    CreateModerationAppealDto._defaults(this);
  }

  CreateModerationAppealDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _decisionId = $v.decisionId;
      _statement = $v.statement;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CreateModerationAppealDto other) {
    _$v = other as _$CreateModerationAppealDto;
  }

  @override
  void update(void Function(CreateModerationAppealDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CreateModerationAppealDto build() => _build();

  _$CreateModerationAppealDto _build() {
    final _$result =
        _$v ??
        _$CreateModerationAppealDto._(
          decisionId: BuiltValueNullFieldError.checkNotNull(
            decisionId,
            r'CreateModerationAppealDto',
            'decisionId',
          ),
          statement: BuiltValueNullFieldError.checkNotNull(
            statement,
            r'CreateModerationAppealDto',
            'statement',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
