// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'font_web_runtime_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$FontWebRuntimeDto extends FontWebRuntimeDto {
  @override
  final FontNetworkWindowDto network;
  @override
  final FontWebResidencyDto residency;

  factory _$FontWebRuntimeDto([
    void Function(FontWebRuntimeDtoBuilder)? updates,
  ]) => (FontWebRuntimeDtoBuilder()..update(updates))._build();

  _$FontWebRuntimeDto._({required this.network, required this.residency})
    : super._();
  @override
  FontWebRuntimeDto rebuild(void Function(FontWebRuntimeDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  FontWebRuntimeDtoBuilder toBuilder() =>
      FontWebRuntimeDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is FontWebRuntimeDto &&
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
    return (newBuiltValueToStringHelper(r'FontWebRuntimeDto')
          ..add('network', network)
          ..add('residency', residency))
        .toString();
  }
}

class FontWebRuntimeDtoBuilder
    implements Builder<FontWebRuntimeDto, FontWebRuntimeDtoBuilder> {
  _$FontWebRuntimeDto? _$v;

  FontNetworkWindowDtoBuilder? _network;
  FontNetworkWindowDtoBuilder get network =>
      _$this._network ??= FontNetworkWindowDtoBuilder();
  set network(FontNetworkWindowDtoBuilder? network) =>
      _$this._network = network;

  FontWebResidencyDtoBuilder? _residency;
  FontWebResidencyDtoBuilder get residency =>
      _$this._residency ??= FontWebResidencyDtoBuilder();
  set residency(FontWebResidencyDtoBuilder? residency) =>
      _$this._residency = residency;

  FontWebRuntimeDtoBuilder() {
    FontWebRuntimeDto._defaults(this);
  }

  FontWebRuntimeDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _network = $v.network.toBuilder();
      _residency = $v.residency.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(FontWebRuntimeDto other) {
    _$v = other as _$FontWebRuntimeDto;
  }

  @override
  void update(void Function(FontWebRuntimeDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  FontWebRuntimeDto build() => _build();

  _$FontWebRuntimeDto _build() {
    _$FontWebRuntimeDto _$result;
    try {
      _$result =
          _$v ??
          _$FontWebRuntimeDto._(
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
          r'FontWebRuntimeDto',
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
