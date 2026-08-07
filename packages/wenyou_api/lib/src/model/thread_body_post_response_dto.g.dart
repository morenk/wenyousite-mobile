// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'thread_body_post_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ThreadBodyPostResponseDto extends ThreadBodyPostResponseDto {
  @override
  final String id;
  @override
  final String content;
  @override
  final num version;
  @override
  final BuiltList<DiceRollResponseDto> diceRolls;

  factory _$ThreadBodyPostResponseDto([
    void Function(ThreadBodyPostResponseDtoBuilder)? updates,
  ]) => (ThreadBodyPostResponseDtoBuilder()..update(updates))._build();

  _$ThreadBodyPostResponseDto._({
    required this.id,
    required this.content,
    required this.version,
    required this.diceRolls,
  }) : super._();
  @override
  ThreadBodyPostResponseDto rebuild(
    void Function(ThreadBodyPostResponseDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  ThreadBodyPostResponseDtoBuilder toBuilder() =>
      ThreadBodyPostResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ThreadBodyPostResponseDto &&
        id == other.id &&
        content == other.content &&
        version == other.version &&
        diceRolls == other.diceRolls;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, content.hashCode);
    _$hash = $jc(_$hash, version.hashCode);
    _$hash = $jc(_$hash, diceRolls.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ThreadBodyPostResponseDto')
          ..add('id', id)
          ..add('content', content)
          ..add('version', version)
          ..add('diceRolls', diceRolls))
        .toString();
  }
}

class ThreadBodyPostResponseDtoBuilder
    implements
        Builder<ThreadBodyPostResponseDto, ThreadBodyPostResponseDtoBuilder> {
  _$ThreadBodyPostResponseDto? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _content;
  String? get content => _$this._content;
  set content(String? content) => _$this._content = content;

  num? _version;
  num? get version => _$this._version;
  set version(num? version) => _$this._version = version;

  ListBuilder<DiceRollResponseDto>? _diceRolls;
  ListBuilder<DiceRollResponseDto> get diceRolls =>
      _$this._diceRolls ??= ListBuilder<DiceRollResponseDto>();
  set diceRolls(ListBuilder<DiceRollResponseDto>? diceRolls) =>
      _$this._diceRolls = diceRolls;

  ThreadBodyPostResponseDtoBuilder() {
    ThreadBodyPostResponseDto._defaults(this);
  }

  ThreadBodyPostResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _content = $v.content;
      _version = $v.version;
      _diceRolls = $v.diceRolls.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ThreadBodyPostResponseDto other) {
    _$v = other as _$ThreadBodyPostResponseDto;
  }

  @override
  void update(void Function(ThreadBodyPostResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ThreadBodyPostResponseDto build() => _build();

  _$ThreadBodyPostResponseDto _build() {
    _$ThreadBodyPostResponseDto _$result;
    try {
      _$result =
          _$v ??
          _$ThreadBodyPostResponseDto._(
            id: BuiltValueNullFieldError.checkNotNull(
              id,
              r'ThreadBodyPostResponseDto',
              'id',
            ),
            content: BuiltValueNullFieldError.checkNotNull(
              content,
              r'ThreadBodyPostResponseDto',
              'content',
            ),
            version: BuiltValueNullFieldError.checkNotNull(
              version,
              r'ThreadBodyPostResponseDto',
              'version',
            ),
            diceRolls: diceRolls.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'diceRolls';
        diceRolls.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'ThreadBodyPostResponseDto',
          _$failedField,
          e.toString(),
        );
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
