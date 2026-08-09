// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mobile_compatibility_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$MobileCompatibilityDto extends MobileCompatibilityDto {
  @override
  final MobilePlatformCompatibilityDto android;
  @override
  final MobilePlatformCompatibilityDto ios;

  factory _$MobileCompatibilityDto([
    void Function(MobileCompatibilityDtoBuilder)? updates,
  ]) => (MobileCompatibilityDtoBuilder()..update(updates))._build();

  _$MobileCompatibilityDto._({required this.android, required this.ios})
    : super._();
  @override
  MobileCompatibilityDto rebuild(
    void Function(MobileCompatibilityDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  MobileCompatibilityDtoBuilder toBuilder() =>
      MobileCompatibilityDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MobileCompatibilityDto &&
        android == other.android &&
        ios == other.ios;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, android.hashCode);
    _$hash = $jc(_$hash, ios.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'MobileCompatibilityDto')
          ..add('android', android)
          ..add('ios', ios))
        .toString();
  }
}

class MobileCompatibilityDtoBuilder
    implements Builder<MobileCompatibilityDto, MobileCompatibilityDtoBuilder> {
  _$MobileCompatibilityDto? _$v;

  MobilePlatformCompatibilityDtoBuilder? _android;
  MobilePlatformCompatibilityDtoBuilder get android =>
      _$this._android ??= MobilePlatformCompatibilityDtoBuilder();
  set android(MobilePlatformCompatibilityDtoBuilder? android) =>
      _$this._android = android;

  MobilePlatformCompatibilityDtoBuilder? _ios;
  MobilePlatformCompatibilityDtoBuilder get ios =>
      _$this._ios ??= MobilePlatformCompatibilityDtoBuilder();
  set ios(MobilePlatformCompatibilityDtoBuilder? ios) => _$this._ios = ios;

  MobileCompatibilityDtoBuilder() {
    MobileCompatibilityDto._defaults(this);
  }

  MobileCompatibilityDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _android = $v.android.toBuilder();
      _ios = $v.ios.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(MobileCompatibilityDto other) {
    _$v = other as _$MobileCompatibilityDto;
  }

  @override
  void update(void Function(MobileCompatibilityDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  MobileCompatibilityDto build() => _build();

  _$MobileCompatibilityDto _build() {
    _$MobileCompatibilityDto _$result;
    try {
      _$result =
          _$v ??
          _$MobileCompatibilityDto._(
            android: android.build(),
            ios: ios.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'android';
        android.build();
        _$failedField = 'ios';
        ios.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'MobileCompatibilityDto',
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
