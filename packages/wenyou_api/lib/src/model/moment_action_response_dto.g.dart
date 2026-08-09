// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'moment_action_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$MomentActionResponseDto extends MomentActionResponseDto {
  @override
  final String momentId;
  @override
  final num count;
  @override
  final bool active;

  factory _$MomentActionResponseDto([
    void Function(MomentActionResponseDtoBuilder)? updates,
  ]) => (MomentActionResponseDtoBuilder()..update(updates))._build();

  _$MomentActionResponseDto._({
    required this.momentId,
    required this.count,
    required this.active,
  }) : super._();
  @override
  MomentActionResponseDto rebuild(
    void Function(MomentActionResponseDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  MomentActionResponseDtoBuilder toBuilder() =>
      MomentActionResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MomentActionResponseDto &&
        momentId == other.momentId &&
        count == other.count &&
        active == other.active;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, momentId.hashCode);
    _$hash = $jc(_$hash, count.hashCode);
    _$hash = $jc(_$hash, active.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'MomentActionResponseDto')
          ..add('momentId', momentId)
          ..add('count', count)
          ..add('active', active))
        .toString();
  }
}

class MomentActionResponseDtoBuilder
    implements
        Builder<MomentActionResponseDto, MomentActionResponseDtoBuilder> {
  _$MomentActionResponseDto? _$v;

  String? _momentId;
  String? get momentId => _$this._momentId;
  set momentId(String? momentId) => _$this._momentId = momentId;

  num? _count;
  num? get count => _$this._count;
  set count(num? count) => _$this._count = count;

  bool? _active;
  bool? get active => _$this._active;
  set active(bool? active) => _$this._active = active;

  MomentActionResponseDtoBuilder() {
    MomentActionResponseDto._defaults(this);
  }

  MomentActionResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _momentId = $v.momentId;
      _count = $v.count;
      _active = $v.active;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(MomentActionResponseDto other) {
    _$v = other as _$MomentActionResponseDto;
  }

  @override
  void update(void Function(MomentActionResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  MomentActionResponseDto build() => _build();

  _$MomentActionResponseDto _build() {
    final _$result =
        _$v ??
        _$MomentActionResponseDto._(
          momentId: BuiltValueNullFieldError.checkNotNull(
            momentId,
            r'MomentActionResponseDto',
            'momentId',
          ),
          count: BuiltValueNullFieldError.checkNotNull(
            count,
            r'MomentActionResponseDto',
            'count',
          ),
          active: BuiltValueNullFieldError.checkNotNull(
            active,
            r'MomentActionResponseDto',
            'active',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
