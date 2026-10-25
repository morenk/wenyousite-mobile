// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dynamic_font_web_residency_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const DynamicFontWebResidencyDtoModeEnum
_$dynamicFontWebResidencyDtoModeEnum_leaseLru =
    const DynamicFontWebResidencyDtoModeEnum._('leaseLru');
const DynamicFontWebResidencyDtoModeEnum
_$dynamicFontWebResidencyDtoModeEnum_unknownDefaultOpenApi =
    const DynamicFontWebResidencyDtoModeEnum._('unknownDefaultOpenApi');

DynamicFontWebResidencyDtoModeEnum _$dynamicFontWebResidencyDtoModeEnumValueOf(
  String name,
) {
  switch (name) {
    case 'leaseLru':
      return _$dynamicFontWebResidencyDtoModeEnum_leaseLru;
    case 'unknownDefaultOpenApi':
      return _$dynamicFontWebResidencyDtoModeEnum_unknownDefaultOpenApi;
    default:
      return _$dynamicFontWebResidencyDtoModeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<DynamicFontWebResidencyDtoModeEnum>
_$dynamicFontWebResidencyDtoModeEnumValues =
    BuiltSet<DynamicFontWebResidencyDtoModeEnum>(
      const <DynamicFontWebResidencyDtoModeEnum>[
        _$dynamicFontWebResidencyDtoModeEnum_leaseLru,
        _$dynamicFontWebResidencyDtoModeEnum_unknownDefaultOpenApi,
      ],
    );

const DynamicFontWebResidencyDtoScopeEnum
_$dynamicFontWebResidencyDtoScopeEnum_document =
    const DynamicFontWebResidencyDtoScopeEnum._('document');
const DynamicFontWebResidencyDtoScopeEnum
_$dynamicFontWebResidencyDtoScopeEnum_unknownDefaultOpenApi =
    const DynamicFontWebResidencyDtoScopeEnum._('unknownDefaultOpenApi');

DynamicFontWebResidencyDtoScopeEnum
_$dynamicFontWebResidencyDtoScopeEnumValueOf(String name) {
  switch (name) {
    case 'document':
      return _$dynamicFontWebResidencyDtoScopeEnum_document;
    case 'unknownDefaultOpenApi':
      return _$dynamicFontWebResidencyDtoScopeEnum_unknownDefaultOpenApi;
    default:
      return _$dynamicFontWebResidencyDtoScopeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<DynamicFontWebResidencyDtoScopeEnum>
_$dynamicFontWebResidencyDtoScopeEnumValues =
    BuiltSet<DynamicFontWebResidencyDtoScopeEnum>(
      const <DynamicFontWebResidencyDtoScopeEnum>[
        _$dynamicFontWebResidencyDtoScopeEnum_document,
        _$dynamicFontWebResidencyDtoScopeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<DynamicFontWebResidencyDtoModeEnum>
_$dynamicFontWebResidencyDtoModeEnumSerializer =
    _$DynamicFontWebResidencyDtoModeEnumSerializer();
Serializer<DynamicFontWebResidencyDtoScopeEnum>
_$dynamicFontWebResidencyDtoScopeEnumSerializer =
    _$DynamicFontWebResidencyDtoScopeEnumSerializer();

class _$DynamicFontWebResidencyDtoModeEnumSerializer
    implements PrimitiveSerializer<DynamicFontWebResidencyDtoModeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'leaseLru': 'lease-lru',
    'unknownDefaultOpenApi': 'unknown_default_open_api',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'lease-lru': 'leaseLru',
    'unknown_default_open_api': 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[DynamicFontWebResidencyDtoModeEnum];
  @override
  final String wireName = 'DynamicFontWebResidencyDtoModeEnum';

  @override
  Object serialize(
    Serializers serializers,
    DynamicFontWebResidencyDtoModeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  DynamicFontWebResidencyDtoModeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => DynamicFontWebResidencyDtoModeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$DynamicFontWebResidencyDtoScopeEnumSerializer
    implements PrimitiveSerializer<DynamicFontWebResidencyDtoScopeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'document': 'document',
    'unknownDefaultOpenApi': 'unknown_default_open_api',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'document': 'document',
    'unknown_default_open_api': 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[
    DynamicFontWebResidencyDtoScopeEnum,
  ];
  @override
  final String wireName = 'DynamicFontWebResidencyDtoScopeEnum';

  @override
  Object serialize(
    Serializers serializers,
    DynamicFontWebResidencyDtoScopeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  DynamicFontWebResidencyDtoScopeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => DynamicFontWebResidencyDtoScopeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$DynamicFontWebResidencyDto extends DynamicFontWebResidencyDto {
  @override
  final DynamicFontWebResidencyDtoModeEnum mode;
  @override
  final DynamicFontWebResidencyDtoScopeEnum scope;
  @override
  final int maxFaces;
  @override
  final int maxSfntBytes;

  factory _$DynamicFontWebResidencyDto([
    void Function(DynamicFontWebResidencyDtoBuilder)? updates,
  ]) => (DynamicFontWebResidencyDtoBuilder()..update(updates))._build();

  _$DynamicFontWebResidencyDto._({
    required this.mode,
    required this.scope,
    required this.maxFaces,
    required this.maxSfntBytes,
  }) : super._();
  @override
  DynamicFontWebResidencyDto rebuild(
    void Function(DynamicFontWebResidencyDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  DynamicFontWebResidencyDtoBuilder toBuilder() =>
      DynamicFontWebResidencyDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is DynamicFontWebResidencyDto &&
        mode == other.mode &&
        scope == other.scope &&
        maxFaces == other.maxFaces &&
        maxSfntBytes == other.maxSfntBytes;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, mode.hashCode);
    _$hash = $jc(_$hash, scope.hashCode);
    _$hash = $jc(_$hash, maxFaces.hashCode);
    _$hash = $jc(_$hash, maxSfntBytes.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'DynamicFontWebResidencyDto')
          ..add('mode', mode)
          ..add('scope', scope)
          ..add('maxFaces', maxFaces)
          ..add('maxSfntBytes', maxSfntBytes))
        .toString();
  }
}

class DynamicFontWebResidencyDtoBuilder
    implements
        Builder<DynamicFontWebResidencyDto, DynamicFontWebResidencyDtoBuilder> {
  _$DynamicFontWebResidencyDto? _$v;

  DynamicFontWebResidencyDtoModeEnum? _mode;
  DynamicFontWebResidencyDtoModeEnum? get mode => _$this._mode;
  set mode(DynamicFontWebResidencyDtoModeEnum? mode) => _$this._mode = mode;

  DynamicFontWebResidencyDtoScopeEnum? _scope;
  DynamicFontWebResidencyDtoScopeEnum? get scope => _$this._scope;
  set scope(DynamicFontWebResidencyDtoScopeEnum? scope) =>
      _$this._scope = scope;

  int? _maxFaces;
  int? get maxFaces => _$this._maxFaces;
  set maxFaces(int? maxFaces) => _$this._maxFaces = maxFaces;

  int? _maxSfntBytes;
  int? get maxSfntBytes => _$this._maxSfntBytes;
  set maxSfntBytes(int? maxSfntBytes) => _$this._maxSfntBytes = maxSfntBytes;

  DynamicFontWebResidencyDtoBuilder() {
    DynamicFontWebResidencyDto._defaults(this);
  }

  DynamicFontWebResidencyDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _mode = $v.mode;
      _scope = $v.scope;
      _maxFaces = $v.maxFaces;
      _maxSfntBytes = $v.maxSfntBytes;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(DynamicFontWebResidencyDto other) {
    _$v = other as _$DynamicFontWebResidencyDto;
  }

  @override
  void update(void Function(DynamicFontWebResidencyDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  DynamicFontWebResidencyDto build() => _build();

  _$DynamicFontWebResidencyDto _build() {
    final _$result =
        _$v ??
        _$DynamicFontWebResidencyDto._(
          mode: BuiltValueNullFieldError.checkNotNull(
            mode,
            r'DynamicFontWebResidencyDto',
            'mode',
          ),
          scope: BuiltValueNullFieldError.checkNotNull(
            scope,
            r'DynamicFontWebResidencyDto',
            'scope',
          ),
          maxFaces: BuiltValueNullFieldError.checkNotNull(
            maxFaces,
            r'DynamicFontWebResidencyDto',
            'maxFaces',
          ),
          maxSfntBytes: BuiltValueNullFieldError.checkNotNull(
            maxSfntBytes,
            r'DynamicFontWebResidencyDto',
            'maxSfntBytes',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
