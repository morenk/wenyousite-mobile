// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dynamic_font_mobile_runtime_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$DynamicFontMobileRuntimeDto extends DynamicFontMobileRuntimeDto {
  @override
  final DynamicFontNetworkDto network;
  @override
  final DynamicFontRegistrationDto registration;

  factory _$DynamicFontMobileRuntimeDto([
    void Function(DynamicFontMobileRuntimeDtoBuilder)? updates,
  ]) => (DynamicFontMobileRuntimeDtoBuilder()..update(updates))._build();

  _$DynamicFontMobileRuntimeDto._({
    required this.network,
    required this.registration,
  }) : super._();
  @override
  DynamicFontMobileRuntimeDto rebuild(
    void Function(DynamicFontMobileRuntimeDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  DynamicFontMobileRuntimeDtoBuilder toBuilder() =>
      DynamicFontMobileRuntimeDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is DynamicFontMobileRuntimeDto &&
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
    return (newBuiltValueToStringHelper(r'DynamicFontMobileRuntimeDto')
          ..add('network', network)
          ..add('registration', registration))
        .toString();
  }
}

class DynamicFontMobileRuntimeDtoBuilder
    implements
        Builder<
          DynamicFontMobileRuntimeDto,
          DynamicFontMobileRuntimeDtoBuilder
        > {
  _$DynamicFontMobileRuntimeDto? _$v;

  DynamicFontNetworkDtoBuilder? _network;
  DynamicFontNetworkDtoBuilder get network =>
      _$this._network ??= DynamicFontNetworkDtoBuilder();
  set network(DynamicFontNetworkDtoBuilder? network) =>
      _$this._network = network;

  DynamicFontRegistrationDtoBuilder? _registration;
  DynamicFontRegistrationDtoBuilder get registration =>
      _$this._registration ??= DynamicFontRegistrationDtoBuilder();
  set registration(DynamicFontRegistrationDtoBuilder? registration) =>
      _$this._registration = registration;

  DynamicFontMobileRuntimeDtoBuilder() {
    DynamicFontMobileRuntimeDto._defaults(this);
  }

  DynamicFontMobileRuntimeDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _network = $v.network.toBuilder();
      _registration = $v.registration.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(DynamicFontMobileRuntimeDto other) {
    _$v = other as _$DynamicFontMobileRuntimeDto;
  }

  @override
  void update(void Function(DynamicFontMobileRuntimeDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  DynamicFontMobileRuntimeDto build() => _build();

  _$DynamicFontMobileRuntimeDto _build() {
    _$DynamicFontMobileRuntimeDto _$result;
    try {
      _$result =
          _$v ??
          _$DynamicFontMobileRuntimeDto._(
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
          r'DynamicFontMobileRuntimeDto',
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
