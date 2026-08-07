// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_meta_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ApiMetaResponseDto extends ApiMetaResponseDto {
  @override
  final String contractVersion;
  @override
  final String? buildSha;
  @override
  final num markdownContractVersion;
  @override
  final ApiCapabilitiesResponseDto capabilities;

  factory _$ApiMetaResponseDto([
    void Function(ApiMetaResponseDtoBuilder)? updates,
  ]) => (ApiMetaResponseDtoBuilder()..update(updates))._build();

  _$ApiMetaResponseDto._({
    required this.contractVersion,
    this.buildSha,
    required this.markdownContractVersion,
    required this.capabilities,
  }) : super._();
  @override
  ApiMetaResponseDto rebuild(
    void Function(ApiMetaResponseDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  ApiMetaResponseDtoBuilder toBuilder() =>
      ApiMetaResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ApiMetaResponseDto &&
        contractVersion == other.contractVersion &&
        buildSha == other.buildSha &&
        markdownContractVersion == other.markdownContractVersion &&
        capabilities == other.capabilities;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, contractVersion.hashCode);
    _$hash = $jc(_$hash, buildSha.hashCode);
    _$hash = $jc(_$hash, markdownContractVersion.hashCode);
    _$hash = $jc(_$hash, capabilities.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ApiMetaResponseDto')
          ..add('contractVersion', contractVersion)
          ..add('buildSha', buildSha)
          ..add('markdownContractVersion', markdownContractVersion)
          ..add('capabilities', capabilities))
        .toString();
  }
}

class ApiMetaResponseDtoBuilder
    implements Builder<ApiMetaResponseDto, ApiMetaResponseDtoBuilder> {
  _$ApiMetaResponseDto? _$v;

  String? _contractVersion;
  String? get contractVersion => _$this._contractVersion;
  set contractVersion(String? contractVersion) =>
      _$this._contractVersion = contractVersion;

  String? _buildSha;
  String? get buildSha => _$this._buildSha;
  set buildSha(String? buildSha) => _$this._buildSha = buildSha;

  num? _markdownContractVersion;
  num? get markdownContractVersion => _$this._markdownContractVersion;
  set markdownContractVersion(num? markdownContractVersion) =>
      _$this._markdownContractVersion = markdownContractVersion;

  ApiCapabilitiesResponseDtoBuilder? _capabilities;
  ApiCapabilitiesResponseDtoBuilder get capabilities =>
      _$this._capabilities ??= ApiCapabilitiesResponseDtoBuilder();
  set capabilities(ApiCapabilitiesResponseDtoBuilder? capabilities) =>
      _$this._capabilities = capabilities;

  ApiMetaResponseDtoBuilder() {
    ApiMetaResponseDto._defaults(this);
  }

  ApiMetaResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _contractVersion = $v.contractVersion;
      _buildSha = $v.buildSha;
      _markdownContractVersion = $v.markdownContractVersion;
      _capabilities = $v.capabilities.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ApiMetaResponseDto other) {
    _$v = other as _$ApiMetaResponseDto;
  }

  @override
  void update(void Function(ApiMetaResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ApiMetaResponseDto build() => _build();

  _$ApiMetaResponseDto _build() {
    _$ApiMetaResponseDto _$result;
    try {
      _$result =
          _$v ??
          _$ApiMetaResponseDto._(
            contractVersion: BuiltValueNullFieldError.checkNotNull(
              contractVersion,
              r'ApiMetaResponseDto',
              'contractVersion',
            ),
            buildSha: buildSha,
            markdownContractVersion: BuiltValueNullFieldError.checkNotNull(
              markdownContractVersion,
              r'ApiMetaResponseDto',
              'markdownContractVersion',
            ),
            capabilities: capabilities.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'capabilities';
        capabilities.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'ApiMetaResponseDto',
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
