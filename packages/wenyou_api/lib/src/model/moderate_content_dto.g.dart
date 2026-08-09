// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'moderate_content_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ModerateContentDto extends ModerateContentDto {
  @override
  final String reason;

  factory _$ModerateContentDto([
    void Function(ModerateContentDtoBuilder)? updates,
  ]) => (ModerateContentDtoBuilder()..update(updates))._build();

  _$ModerateContentDto._({required this.reason}) : super._();
  @override
  ModerateContentDto rebuild(
    void Function(ModerateContentDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  ModerateContentDtoBuilder toBuilder() =>
      ModerateContentDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ModerateContentDto && reason == other.reason;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, reason.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
      r'ModerateContentDto',
    )..add('reason', reason)).toString();
  }
}

class ModerateContentDtoBuilder
    implements Builder<ModerateContentDto, ModerateContentDtoBuilder> {
  _$ModerateContentDto? _$v;

  String? _reason;
  String? get reason => _$this._reason;
  set reason(String? reason) => _$this._reason = reason;

  ModerateContentDtoBuilder() {
    ModerateContentDto._defaults(this);
  }

  ModerateContentDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _reason = $v.reason;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ModerateContentDto other) {
    _$v = other as _$ModerateContentDto;
  }

  @override
  void update(void Function(ModerateContentDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ModerateContentDto build() => _build();

  _$ModerateContentDto _build() {
    final _$result =
        _$v ??
        _$ModerateContentDto._(
          reason: BuiltValueNullFieldError.checkNotNull(
            reason,
            r'ModerateContentDto',
            'reason',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
