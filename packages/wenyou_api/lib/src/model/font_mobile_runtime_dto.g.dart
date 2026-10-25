// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'font_mobile_runtime_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$FontMobileRuntimeDto extends FontMobileRuntimeDto {
  @override
  final FontNetworkWindowDto network;
  @override
  final FontMobileRegistrationDto registration;

  factory _$FontMobileRuntimeDto([
    void Function(FontMobileRuntimeDtoBuilder)? updates,
  ]) => (FontMobileRuntimeDtoBuilder()..update(updates))._build();

  _$FontMobileRuntimeDto._({required this.network, required this.registration})
    : super._();
  @override
  FontMobileRuntimeDto rebuild(
    void Function(FontMobileRuntimeDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  FontMobileRuntimeDtoBuilder toBuilder() =>
      FontMobileRuntimeDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is FontMobileRuntimeDto &&
        network == other.network &&
        registration == other.registration;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, network.hashCode);
    _$hash = $jc(_$hash, registration.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'FontMobileRuntimeDto')
          ..add('network', network)
          ..add('registration', registration))
        .toString();
  }
}

class FontMobileRuntimeDtoBuilder
    implements Builder<FontMobileRuntimeDto, FontMobileRuntimeDtoBuilder> {
  _$FontMobileRuntimeDto? _$v;

  FontNetworkWindowDtoBuilder? _network;
  FontNetworkWindowDtoBuilder get network =>
      _$this._network ??= FontNetworkWindowDtoBuilder();
  set network(FontNetworkWindowDtoBuilder? network) =>
      _$this._network = network;

  FontMobileRegistrationDtoBuilder? _registration;
  FontMobileRegistrationDtoBuilder get registration =>
      _$this._registration ??= FontMobileRegistrationDtoBuilder();
  set registration(FontMobileRegistrationDtoBuilder? registration) =>
      _$this._registration = registration;

  FontMobileRuntimeDtoBuilder() {
    FontMobileRuntimeDto._defaults(this);
  }

  FontMobileRuntimeDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _network = $v.network.toBuilder();
      _registration = $v.registration.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(FontMobileRuntimeDto other) {
    _$v = other as _$FontMobileRuntimeDto;
  }

  @override
  void update(void Function(FontMobileRuntimeDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  FontMobileRuntimeDto build() => _build();

  _$FontMobileRuntimeDto _build() {
    _$FontMobileRuntimeDto _$result;
    try {
      _$result =
          _$v ??
          _$FontMobileRuntimeDto._(
            network: network.build(),
            registration: registration.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'network';
        network.build();
        _$failedField = 'registration';
        registration.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'FontMobileRuntimeDto',
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
