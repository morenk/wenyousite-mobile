// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'text_font_runtime_policy_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const TextFontRuntimePolicyDtoPolicyVersionEnum
_$textFontRuntimePolicyDtoPolicyVersionEnum_n2 =
    const TextFontRuntimePolicyDtoPolicyVersionEnum._('n2');
const TextFontRuntimePolicyDtoPolicyVersionEnum
_$textFontRuntimePolicyDtoPolicyVersionEnum_unknownDefaultOpenApi =
    const TextFontRuntimePolicyDtoPolicyVersionEnum._('unknownDefaultOpenApi');

TextFontRuntimePolicyDtoPolicyVersionEnum
_$textFontRuntimePolicyDtoPolicyVersionEnumValueOf(String name) {
  switch (name) {
    case 'n2':
      return _$textFontRuntimePolicyDtoPolicyVersionEnum_n2;
    case 'unknownDefaultOpenApi':
      return _$textFontRuntimePolicyDtoPolicyVersionEnum_unknownDefaultOpenApi;
    default:
      return _$textFontRuntimePolicyDtoPolicyVersionEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<TextFontRuntimePolicyDtoPolicyVersionEnum>
_$textFontRuntimePolicyDtoPolicyVersionEnumValues =
    BuiltSet<TextFontRuntimePolicyDtoPolicyVersionEnum>(
      const <TextFontRuntimePolicyDtoPolicyVersionEnum>[
        _$textFontRuntimePolicyDtoPolicyVersionEnum_n2,
        _$textFontRuntimePolicyDtoPolicyVersionEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<TextFontRuntimePolicyDtoPolicyVersionEnum>
_$textFontRuntimePolicyDtoPolicyVersionEnumSerializer =
    _$TextFontRuntimePolicyDtoPolicyVersionEnumSerializer();

class _$TextFontRuntimePolicyDtoPolicyVersionEnumSerializer
    implements PrimitiveSerializer<TextFontRuntimePolicyDtoPolicyVersionEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'n2': '2',
    'unknownDefaultOpenApi': '11184809',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    '2': 'n2',
    '11184809': 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[
    TextFontRuntimePolicyDtoPolicyVersionEnum,
  ];
  @override
  final String wireName = 'TextFontRuntimePolicyDtoPolicyVersionEnum';

  @override
  Object serialize(
    Serializers serializers,
    TextFontRuntimePolicyDtoPolicyVersionEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  TextFontRuntimePolicyDtoPolicyVersionEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => TextFontRuntimePolicyDtoPolicyVersionEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$TextFontRuntimePolicyDto extends TextFontRuntimePolicyDto {
  @override
  final TextFontRuntimePolicyDtoPolicyVersionEnum policyVersion;
  @override
  final String manifestSha256;
  @override
  final FontOriginalAssetDto originalAsset;
  @override
  final FontWebRuntimeDto web;
  @override
  final FontMobileRuntimeDto mobile;
  @override
  final FontRetryPolicyDto retry;

  factory _$TextFontRuntimePolicyDto([
    void Function(TextFontRuntimePolicyDtoBuilder)? updates,
  ]) => (TextFontRuntimePolicyDtoBuilder()..update(updates))._build();

  _$TextFontRuntimePolicyDto._({
    required this.policyVersion,
    required this.manifestSha256,
    required this.originalAsset,
    required this.web,
    required this.mobile,
    required this.retry,
  }) : super._();
  @override
  TextFontRuntimePolicyDto rebuild(
    void Function(TextFontRuntimePolicyDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  TextFontRuntimePolicyDtoBuilder toBuilder() =>
      TextFontRuntimePolicyDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TextFontRuntimePolicyDto &&
        policyVersion == other.policyVersion &&
        manifestSha256 == other.manifestSha256 &&
        originalAsset == other.originalAsset &&
        web == other.web &&
        mobile == other.mobile &&
        retry == other.retry;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, policyVersion.hashCode);
    _$hash = $jc(_$hash, manifestSha256.hashCode);
    _$hash = $jc(_$hash, originalAsset.hashCode);
    _$hash = $jc(_$hash, web.hashCode);
    _$hash = $jc(_$hash, mobile.hashCode);
    _$hash = $jc(_$hash, retry.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'TextFontRuntimePolicyDto')
          ..add('policyVersion', policyVersion)
          ..add('manifestSha256', manifestSha256)
          ..add('originalAsset', originalAsset)
          ..add('web', web)
          ..add('mobile', mobile)
          ..add('retry', retry))
        .toString();
  }
}

class TextFontRuntimePolicyDtoBuilder
    implements
        Builder<TextFontRuntimePolicyDto, TextFontRuntimePolicyDtoBuilder> {
  _$TextFontRuntimePolicyDto? _$v;

  TextFontRuntimePolicyDtoPolicyVersionEnum? _policyVersion;
  TextFontRuntimePolicyDtoPolicyVersionEnum? get policyVersion =>
      _$this._policyVersion;
  set policyVersion(TextFontRuntimePolicyDtoPolicyVersionEnum? policyVersion) =>
      _$this._policyVersion = policyVersion;

  String? _manifestSha256;
  String? get manifestSha256 => _$this._manifestSha256;
  set manifestSha256(String? manifestSha256) =>
      _$this._manifestSha256 = manifestSha256;

  FontOriginalAssetDtoBuilder? _originalAsset;
  FontOriginalAssetDtoBuilder get originalAsset =>
      _$this._originalAsset ??= FontOriginalAssetDtoBuilder();
  set originalAsset(FontOriginalAssetDtoBuilder? originalAsset) =>
      _$this._originalAsset = originalAsset;

  FontWebRuntimeDtoBuilder? _web;
  FontWebRuntimeDtoBuilder get web =>
      _$this._web ??= FontWebRuntimeDtoBuilder();
  set web(FontWebRuntimeDtoBuilder? web) => _$this._web = web;

  FontMobileRuntimeDtoBuilder? _mobile;
  FontMobileRuntimeDtoBuilder get mobile =>
      _$this._mobile ??= FontMobileRuntimeDtoBuilder();
  set mobile(FontMobileRuntimeDtoBuilder? mobile) => _$this._mobile = mobile;

  FontRetryPolicyDtoBuilder? _retry;
  FontRetryPolicyDtoBuilder get retry =>
      _$this._retry ??= FontRetryPolicyDtoBuilder();
  set retry(FontRetryPolicyDtoBuilder? retry) => _$this._retry = retry;

  TextFontRuntimePolicyDtoBuilder() {
    TextFontRuntimePolicyDto._defaults(this);
  }

  TextFontRuntimePolicyDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _policyVersion = $v.policyVersion;
      _manifestSha256 = $v.manifestSha256;
      _originalAsset = $v.originalAsset.toBuilder();
      _web = $v.web.toBuilder();
      _mobile = $v.mobile.toBuilder();
      _retry = $v.retry.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TextFontRuntimePolicyDto other) {
    _$v = other as _$TextFontRuntimePolicyDto;
  }

  @override
  void update(void Function(TextFontRuntimePolicyDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TextFontRuntimePolicyDto build() => _build();

  _$TextFontRuntimePolicyDto _build() {
    _$TextFontRuntimePolicyDto _$result;
    try {
      _$result =
          _$v ??
          _$TextFontRuntimePolicyDto._(
            policyVersion: BuiltValueNullFieldError.checkNotNull(
              policyVersion,
              r'TextFontRuntimePolicyDto',
              'policyVersion',
            ),
            manifestSha256: BuiltValueNullFieldError.checkNotNull(
              manifestSha256,
              r'TextFontRuntimePolicyDto',
              'manifestSha256',
            ),
            originalAsset: originalAsset.build(),
            web: web.build(),
            mobile: mobile.build(),
            retry: retry.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'originalAsset';
        originalAsset.build();
        _$failedField = 'web';
        web.build();
        _$failedField = 'mobile';
        mobile.build();
        _$failedField = 'retry';
        retry.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'TextFontRuntimePolicyDto',
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
