// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dynamic_font_runtime_policy_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const DynamicFontRuntimePolicyDtoPolicyVersionEnum
_$dynamicFontRuntimePolicyDtoPolicyVersionEnum_n3 =
    const DynamicFontRuntimePolicyDtoPolicyVersionEnum._('n3');
const DynamicFontRuntimePolicyDtoPolicyVersionEnum
_$dynamicFontRuntimePolicyDtoPolicyVersionEnum_unknownDefaultOpenApi =
    const DynamicFontRuntimePolicyDtoPolicyVersionEnum._(
      'unknownDefaultOpenApi',
    );

DynamicFontRuntimePolicyDtoPolicyVersionEnum
_$dynamicFontRuntimePolicyDtoPolicyVersionEnumValueOf(String name) {
  switch (name) {
    case 'n3':
      return _$dynamicFontRuntimePolicyDtoPolicyVersionEnum_n3;
    case 'unknownDefaultOpenApi':
      return _$dynamicFontRuntimePolicyDtoPolicyVersionEnum_unknownDefaultOpenApi;
    default:
      return _$dynamicFontRuntimePolicyDtoPolicyVersionEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<DynamicFontRuntimePolicyDtoPolicyVersionEnum>
_$dynamicFontRuntimePolicyDtoPolicyVersionEnumValues =
    BuiltSet<DynamicFontRuntimePolicyDtoPolicyVersionEnum>(
      const <DynamicFontRuntimePolicyDtoPolicyVersionEnum>[
        _$dynamicFontRuntimePolicyDtoPolicyVersionEnum_n3,
        _$dynamicFontRuntimePolicyDtoPolicyVersionEnum_unknownDefaultOpenApi,
      ],
    );

const DynamicFontRuntimePolicyDtoFontVersionEnum
_$dynamicFontRuntimePolicyDtoFontVersionEnum_n2 =
    const DynamicFontRuntimePolicyDtoFontVersionEnum._('n2');
const DynamicFontRuntimePolicyDtoFontVersionEnum
_$dynamicFontRuntimePolicyDtoFontVersionEnum_unknownDefaultOpenApi =
    const DynamicFontRuntimePolicyDtoFontVersionEnum._('unknownDefaultOpenApi');

DynamicFontRuntimePolicyDtoFontVersionEnum
_$dynamicFontRuntimePolicyDtoFontVersionEnumValueOf(String name) {
  switch (name) {
    case 'n2':
      return _$dynamicFontRuntimePolicyDtoFontVersionEnum_n2;
    case 'unknownDefaultOpenApi':
      return _$dynamicFontRuntimePolicyDtoFontVersionEnum_unknownDefaultOpenApi;
    default:
      return _$dynamicFontRuntimePolicyDtoFontVersionEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<DynamicFontRuntimePolicyDtoFontVersionEnum>
_$dynamicFontRuntimePolicyDtoFontVersionEnumValues =
    BuiltSet<DynamicFontRuntimePolicyDtoFontVersionEnum>(
      const <DynamicFontRuntimePolicyDtoFontVersionEnum>[
        _$dynamicFontRuntimePolicyDtoFontVersionEnum_n2,
        _$dynamicFontRuntimePolicyDtoFontVersionEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<DynamicFontRuntimePolicyDtoPolicyVersionEnum>
_$dynamicFontRuntimePolicyDtoPolicyVersionEnumSerializer =
    _$DynamicFontRuntimePolicyDtoPolicyVersionEnumSerializer();
Serializer<DynamicFontRuntimePolicyDtoFontVersionEnum>
_$dynamicFontRuntimePolicyDtoFontVersionEnumSerializer =
    _$DynamicFontRuntimePolicyDtoFontVersionEnumSerializer();

class _$DynamicFontRuntimePolicyDtoPolicyVersionEnumSerializer
    implements
        PrimitiveSerializer<DynamicFontRuntimePolicyDtoPolicyVersionEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'n3': 3,
    'unknownDefaultOpenApi': '11184809',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    3: 'n3',
    '11184809': 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[
    DynamicFontRuntimePolicyDtoPolicyVersionEnum,
  ];
  @override
  final String wireName = 'DynamicFontRuntimePolicyDtoPolicyVersionEnum';

  @override
  Object serialize(
    Serializers serializers,
    DynamicFontRuntimePolicyDtoPolicyVersionEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  DynamicFontRuntimePolicyDtoPolicyVersionEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => DynamicFontRuntimePolicyDtoPolicyVersionEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$DynamicFontRuntimePolicyDtoFontVersionEnumSerializer
    implements PrimitiveSerializer<DynamicFontRuntimePolicyDtoFontVersionEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'n2': 2,
    'unknownDefaultOpenApi': '11184809',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    2: 'n2',
    '11184809': 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[
    DynamicFontRuntimePolicyDtoFontVersionEnum,
  ];
  @override
  final String wireName = 'DynamicFontRuntimePolicyDtoFontVersionEnum';

  @override
  Object serialize(
    Serializers serializers,
    DynamicFontRuntimePolicyDtoFontVersionEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  DynamicFontRuntimePolicyDtoFontVersionEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => DynamicFontRuntimePolicyDtoFontVersionEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$DynamicFontRuntimePolicyDto extends DynamicFontRuntimePolicyDto {
  @override
  final DynamicFontRuntimePolicyDtoPolicyVersionEnum policyVersion;
  @override
  final DynamicFontRuntimePolicyDtoFontVersionEnum fontVersion;
  @override
  final DynamicFontWebRuntimeDto web;
  @override
  final DynamicFontMobileRuntimeDto mobile;
  @override
  final FontRetryPolicyDto retry;
  @override
  final FontMetadataPolicyDto metadata;
  @override
  final int diskCacheBytes;

  factory _$DynamicFontRuntimePolicyDto([
    void Function(DynamicFontRuntimePolicyDtoBuilder)? updates,
  ]) => (DynamicFontRuntimePolicyDtoBuilder()..update(updates))._build();

  _$DynamicFontRuntimePolicyDto._({
    required this.policyVersion,
    required this.fontVersion,
    required this.web,
    required this.mobile,
    required this.retry,
    required this.metadata,
    required this.diskCacheBytes,
  }) : super._();
  @override
  DynamicFontRuntimePolicyDto rebuild(
    void Function(DynamicFontRuntimePolicyDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  DynamicFontRuntimePolicyDtoBuilder toBuilder() =>
      DynamicFontRuntimePolicyDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is DynamicFontRuntimePolicyDto &&
        policyVersion == other.policyVersion &&
        fontVersion == other.fontVersion &&
        web == other.web &&
        mobile == other.mobile &&
        retry == other.retry &&
        metadata == other.metadata &&
        diskCacheBytes == other.diskCacheBytes;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, policyVersion.hashCode);
    _$hash = $jc(_$hash, fontVersion.hashCode);
    _$hash = $jc(_$hash, web.hashCode);
    _$hash = $jc(_$hash, mobile.hashCode);
    _$hash = $jc(_$hash, retry.hashCode);
    _$hash = $jc(_$hash, metadata.hashCode);
    _$hash = $jc(_$hash, diskCacheBytes.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'DynamicFontRuntimePolicyDto')
          ..add('policyVersion', policyVersion)
          ..add('fontVersion', fontVersion)
          ..add('web', web)
          ..add('mobile', mobile)
          ..add('retry', retry)
          ..add('metadata', metadata)
          ..add('diskCacheBytes', diskCacheBytes))
        .toString();
  }
}

class DynamicFontRuntimePolicyDtoBuilder
    implements
        Builder<
          DynamicFontRuntimePolicyDto,
          DynamicFontRuntimePolicyDtoBuilder
        > {
  _$DynamicFontRuntimePolicyDto? _$v;

  DynamicFontRuntimePolicyDtoPolicyVersionEnum? _policyVersion;
  DynamicFontRuntimePolicyDtoPolicyVersionEnum? get policyVersion =>
      _$this._policyVersion;
  set policyVersion(
    DynamicFontRuntimePolicyDtoPolicyVersionEnum? policyVersion,
  ) => _$this._policyVersion = policyVersion;

  DynamicFontRuntimePolicyDtoFontVersionEnum? _fontVersion;
  DynamicFontRuntimePolicyDtoFontVersionEnum? get fontVersion =>
      _$this._fontVersion;
  set fontVersion(DynamicFontRuntimePolicyDtoFontVersionEnum? fontVersion) =>
      _$this._fontVersion = fontVersion;

  DynamicFontWebRuntimeDtoBuilder? _web;
  DynamicFontWebRuntimeDtoBuilder get web =>
      _$this._web ??= DynamicFontWebRuntimeDtoBuilder();
  set web(DynamicFontWebRuntimeDtoBuilder? web) => _$this._web = web;

  DynamicFontMobileRuntimeDtoBuilder? _mobile;
  DynamicFontMobileRuntimeDtoBuilder get mobile =>
      _$this._mobile ??= DynamicFontMobileRuntimeDtoBuilder();
  set mobile(DynamicFontMobileRuntimeDtoBuilder? mobile) =>
      _$this._mobile = mobile;

  FontRetryPolicyDtoBuilder? _retry;
  FontRetryPolicyDtoBuilder get retry =>
      _$this._retry ??= FontRetryPolicyDtoBuilder();
  set retry(FontRetryPolicyDtoBuilder? retry) => _$this._retry = retry;

  FontMetadataPolicyDtoBuilder? _metadata;
  FontMetadataPolicyDtoBuilder get metadata =>
      _$this._metadata ??= FontMetadataPolicyDtoBuilder();
  set metadata(FontMetadataPolicyDtoBuilder? metadata) =>
      _$this._metadata = metadata;

  int? _diskCacheBytes;
  int? get diskCacheBytes => _$this._diskCacheBytes;
  set diskCacheBytes(int? diskCacheBytes) =>
      _$this._diskCacheBytes = diskCacheBytes;

  DynamicFontRuntimePolicyDtoBuilder() {
    DynamicFontRuntimePolicyDto._defaults(this);
  }

  DynamicFontRuntimePolicyDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _policyVersion = $v.policyVersion;
      _fontVersion = $v.fontVersion;
      _web = $v.web.toBuilder();
      _mobile = $v.mobile.toBuilder();
      _retry = $v.retry.toBuilder();
      _metadata = $v.metadata.toBuilder();
      _diskCacheBytes = $v.diskCacheBytes;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(DynamicFontRuntimePolicyDto other) {
    _$v = other as _$DynamicFontRuntimePolicyDto;
  }

  @override
  void update(void Function(DynamicFontRuntimePolicyDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  DynamicFontRuntimePolicyDto build() => _build();

  _$DynamicFontRuntimePolicyDto _build() {
    _$DynamicFontRuntimePolicyDto _$result;
    try {
      _$result =
          _$v ??
          _$DynamicFontRuntimePolicyDto._(
            policyVersion: BuiltValueNullFieldError.checkNotNull(
              policyVersion,
              r'DynamicFontRuntimePolicyDto',
              'policyVersion',
            ),
            fontVersion: BuiltValueNullFieldError.checkNotNull(
              fontVersion,
              r'DynamicFontRuntimePolicyDto',
              'fontVersion',
            ),
            web: web.build(),
            mobile: mobile.build(),
            retry: retry.build(),
            metadata: metadata.build(),
            diskCacheBytes: BuiltValueNullFieldError.checkNotNull(
              diskCacheBytes,
              r'DynamicFontRuntimePolicyDto',
              'diskCacheBytes',
            ),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'web';
        web.build();
        _$failedField = 'mobile';
        mobile.build();
        _$failedField = 'retry';
        retry.build();
        _$failedField = 'metadata';
        metadata.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'DynamicFontRuntimePolicyDto',
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
