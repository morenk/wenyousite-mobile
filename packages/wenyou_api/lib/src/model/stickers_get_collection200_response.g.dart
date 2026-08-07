// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stickers_get_collection200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const StickersGetCollection200ResponseCodeEnum
_$stickersGetCollection200ResponseCodeEnum_number0 =
    const StickersGetCollection200ResponseCodeEnum._('number0');
const StickersGetCollection200ResponseCodeEnum
_$stickersGetCollection200ResponseCodeEnum_unknownDefaultOpenApi =
    const StickersGetCollection200ResponseCodeEnum._('unknownDefaultOpenApi');

StickersGetCollection200ResponseCodeEnum
_$stickersGetCollection200ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$stickersGetCollection200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$stickersGetCollection200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$stickersGetCollection200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<StickersGetCollection200ResponseCodeEnum>
_$stickersGetCollection200ResponseCodeEnumValues =
    BuiltSet<StickersGetCollection200ResponseCodeEnum>(
      const <StickersGetCollection200ResponseCodeEnum>[
        _$stickersGetCollection200ResponseCodeEnum_number0,
        _$stickersGetCollection200ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<StickersGetCollection200ResponseCodeEnum>
_$stickersGetCollection200ResponseCodeEnumSerializer =
    _$StickersGetCollection200ResponseCodeEnumSerializer();

class _$StickersGetCollection200ResponseCodeEnumSerializer
    implements PrimitiveSerializer<StickersGetCollection200ResponseCodeEnum> {
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
    StickersGetCollection200ResponseCodeEnum,
  ];
  @override
  final String wireName = 'StickersGetCollection200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    StickersGetCollection200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  StickersGetCollection200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => StickersGetCollection200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$StickersGetCollection200Response
    extends StickersGetCollection200Response {
  @override
  final StickerCollectionResponseDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$StickersGetCollection200Response([
    void Function(StickersGetCollection200ResponseBuilder)? updates,
  ]) => (StickersGetCollection200ResponseBuilder()..update(updates))._build();

  _$StickersGetCollection200Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  StickersGetCollection200Response rebuild(
    void Function(StickersGetCollection200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  StickersGetCollection200ResponseBuilder toBuilder() =>
      StickersGetCollection200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is StickersGetCollection200Response &&
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
    return (newBuiltValueToStringHelper(r'StickersGetCollection200Response')
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class StickersGetCollection200ResponseBuilder
    implements
        Builder<
          StickersGetCollection200Response,
          StickersGetCollection200ResponseBuilder
        >,
        ApiSuccessEnvelopeBuilder {
  _$StickersGetCollection200Response? _$v;

  StickerCollectionResponseDtoBuilder? _data;
  StickerCollectionResponseDtoBuilder get data =>
      _$this._data ??= StickerCollectionResponseDtoBuilder();
  set data(covariant StickerCollectionResponseDtoBuilder? data) =>
      _$this._data = data;

  ApiSuccessEnvelopeCodeEnum? _code;
  ApiSuccessEnvelopeCodeEnum? get code => _$this._code;
  set code(covariant ApiSuccessEnvelopeCodeEnum? code) => _$this._code = code;

  String? _message;
  String? get message => _$this._message;
  set message(covariant String? message) => _$this._message = message;

  StickersGetCollection200ResponseBuilder() {
    StickersGetCollection200Response._defaults(this);
  }

  StickersGetCollection200ResponseBuilder get _$this {
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
  void replace(covariant StickersGetCollection200Response other) {
    _$v = other as _$StickersGetCollection200Response;
  }

  @override
  void update(void Function(StickersGetCollection200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  StickersGetCollection200Response build() => _build();

  _$StickersGetCollection200Response _build() {
    _$StickersGetCollection200Response _$result;
    try {
      _$result =
          _$v ??
          _$StickersGetCollection200Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'StickersGetCollection200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'StickersGetCollection200Response',
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
          r'StickersGetCollection200Response',
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
