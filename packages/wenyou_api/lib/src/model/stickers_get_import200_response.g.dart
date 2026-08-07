// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stickers_get_import200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const StickersGetImport200ResponseCodeEnum
_$stickersGetImport200ResponseCodeEnum_number0 =
    const StickersGetImport200ResponseCodeEnum._('number0');
const StickersGetImport200ResponseCodeEnum
_$stickersGetImport200ResponseCodeEnum_unknownDefaultOpenApi =
    const StickersGetImport200ResponseCodeEnum._('unknownDefaultOpenApi');

StickersGetImport200ResponseCodeEnum
_$stickersGetImport200ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$stickersGetImport200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$stickersGetImport200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$stickersGetImport200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<StickersGetImport200ResponseCodeEnum>
_$stickersGetImport200ResponseCodeEnumValues =
    BuiltSet<StickersGetImport200ResponseCodeEnum>(
      const <StickersGetImport200ResponseCodeEnum>[
        _$stickersGetImport200ResponseCodeEnum_number0,
        _$stickersGetImport200ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<StickersGetImport200ResponseCodeEnum>
_$stickersGetImport200ResponseCodeEnumSerializer =
    _$StickersGetImport200ResponseCodeEnumSerializer();

class _$StickersGetImport200ResponseCodeEnumSerializer
    implements PrimitiveSerializer<StickersGetImport200ResponseCodeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'number0': 0,
    'unknownDefaultOpenApi': 11184809,
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    0: 'number0',
    11184809: 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[
    StickersGetImport200ResponseCodeEnum,
  ];
  @override
  final String wireName = 'StickersGetImport200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    StickersGetImport200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  StickersGetImport200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => StickersGetImport200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$StickersGetImport200Response extends StickersGetImport200Response {
  @override
  final StickerImportResponseDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$StickersGetImport200Response([
    void Function(StickersGetImport200ResponseBuilder)? updates,
  ]) => (StickersGetImport200ResponseBuilder()..update(updates))._build();

  _$StickersGetImport200Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  StickersGetImport200Response rebuild(
    void Function(StickersGetImport200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  StickersGetImport200ResponseBuilder toBuilder() =>
      StickersGetImport200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is StickersGetImport200Response &&
        data == other.data &&
        code == other.code &&
        message == other.message;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, data.hashCode);
    _$hash = $jc(_$hash, code.hashCode);
    _$hash = $jc(_$hash, message.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'StickersGetImport200Response')
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class StickersGetImport200ResponseBuilder
    implements
        Builder<
          StickersGetImport200Response,
          StickersGetImport200ResponseBuilder
        >,
        ApiSuccessEnvelopeBuilder {
  _$StickersGetImport200Response? _$v;

  StickerImportResponseDtoBuilder? _data;
  StickerImportResponseDtoBuilder get data =>
      _$this._data ??= StickerImportResponseDtoBuilder();
  set data(covariant StickerImportResponseDtoBuilder? data) =>
      _$this._data = data;

  ApiSuccessEnvelopeCodeEnum? _code;
  ApiSuccessEnvelopeCodeEnum? get code => _$this._code;
  set code(covariant ApiSuccessEnvelopeCodeEnum? code) => _$this._code = code;

  String? _message;
  String? get message => _$this._message;
  set message(covariant String? message) => _$this._message = message;

  StickersGetImport200ResponseBuilder() {
    StickersGetImport200Response._defaults(this);
  }

  StickersGetImport200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _code = $v.code;
      _message = $v.message;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(covariant StickersGetImport200Response other) {
    _$v = other as _$StickersGetImport200Response;
  }

  @override
  void update(void Function(StickersGetImport200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  StickersGetImport200Response build() => _build();

  _$StickersGetImport200Response _build() {
    _$StickersGetImport200Response _$result;
    try {
      _$result =
          _$v ??
          _$StickersGetImport200Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'StickersGetImport200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'StickersGetImport200Response',
              'message',
            ),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'StickersGetImport200Response',
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
