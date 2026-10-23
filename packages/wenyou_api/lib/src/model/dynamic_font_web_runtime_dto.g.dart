// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dynamic_font_web_runtime_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$DynamicFontWebRuntimeDto extends DynamicFontWebRuntimeDto {
  @override
  final DynamicFontNetworkDto network;
  @override
  final DynamicFontWebResidencyDto residency;

  factory _$DynamicFontWebRuntimeDto([
    void Function(DynamicFontWebRuntimeDtoBuilder)? updates,
  ]) => (DynamicFontWebRuntimeDtoBuilder()..update(updates))._build();

  _$DynamicFontWebRuntimeDto._({required this.network, required this.residency})
    : super._();
  @override
  DynamicFontWebRuntimeDto rebuild(
    void Function(DynamicFontWebRuntimeDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  DynamicFontWebRuntimeDtoBuilder toBuilder() =>
      DynamicFontWebRuntimeDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is DynamicFontWebRuntimeDto &&
        network == other.network &&
        residency == other.residency;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, network.hashCode);
    _$hash = $jc(_$hash, residency.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'DynamicFontWebRuntimeDto')
          ..add('network', network)
          ..add('residency', residency))
        .toString();
  }
}

class DynamicFontWebRuntimeDtoBuilder
    implements
        Builder<DynamicFontWebRuntimeDto, DynamicFontWebRuntimeDtoBuilder> {
  _$DynamicFontWebRuntimeDto? _$v;

  DynamicFontNetworkDtoBuilder? _network;
  DynamicFontNetworkDtoBuilder get network =>
      _$this._network ??= DynamicFontNetworkDtoBuilder();
  set network(DynamicFontNetworkDtoBuilder? network) =>
      _$this._network = network;

  DynamicFontWebResidencyDtoBuilder? _residency;
  DynamicFontWebResidencyDtoBuilder get residency =>
      _$this._residency ??= DynamicFontWebResidencyDtoBuilder();
  set residency(DynamicFontWebResidencyDtoBuilder? residency) =>
      _$this._residency = residency;

  DynamicFontWebRuntimeDtoBuilder() {
    DynamicFontWebRuntimeDto._defaults(this);
  }

  DynamicFontWebRuntimeDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _network = $v.network.toBuilder();
      _residency = $v.residency.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(DynamicFontWebRuntimeDto other) {
    _$v = other as _$DynamicFontWebRuntimeDto;
  }

  @override
  void update(void Function(DynamicFontWebRuntimeDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  DynamicFontWebRuntimeDto build() => _build();

  _$DynamicFontWebRuntimeDto _build() {
    _$DynamicFontWebRuntimeDto _$result;
    try {
      _$result =
          _$v ??
          _$DynamicFontWebRuntimeDto._(
            network: network.build(),
            residency: residency.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'network';
        network.build();
        _$failedField = 'residency';
        residency.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'DynamicFontWebRuntimeDto',
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
