// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mobile_release_revision_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$MobileReleaseRevisionDto extends MobileReleaseRevisionDto {
  @override
  final num revision;

  factory _$MobileReleaseRevisionDto([
    void Function(MobileReleaseRevisionDtoBuilder)? updates,
  ]) => (MobileReleaseRevisionDtoBuilder()..update(updates))._build();

  _$MobileReleaseRevisionDto._({required this.revision}) : super._();
  @override
  MobileReleaseRevisionDto rebuild(
    void Function(MobileReleaseRevisionDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  MobileReleaseRevisionDtoBuilder toBuilder() =>
      MobileReleaseRevisionDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MobileReleaseRevisionDto && revision == other.revision;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, revision.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
      r'MobileReleaseRevisionDto',
    )..add('revision', revision)).toString();
  }
}

class MobileReleaseRevisionDtoBuilder
    implements
        Builder<MobileReleaseRevisionDto, MobileReleaseRevisionDtoBuilder> {
  _$MobileReleaseRevisionDto? _$v;

  num? _revision;
  num? get revision => _$this._revision;
  set revision(num? revision) => _$this._revision = revision;

  MobileReleaseRevisionDtoBuilder() {
    MobileReleaseRevisionDto._defaults(this);
  }

  MobileReleaseRevisionDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _revision = $v.revision;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(MobileReleaseRevisionDto other) {
    _$v = other as _$MobileReleaseRevisionDto;
  }

  @override
  void update(void Function(MobileReleaseRevisionDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  MobileReleaseRevisionDto build() => _build();

  _$MobileReleaseRevisionDto _build() {
    final _$result =
        _$v ??
        _$MobileReleaseRevisionDto._(
          revision: BuiltValueNullFieldError.checkNotNull(
            revision,
            r'MobileReleaseRevisionDto',
            'revision',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
