// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stickers_remove200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const StickersRemove200ResponseCodeEnum
_$stickersRemove200ResponseCodeEnum_number0 =
    const StickersRemove200ResponseCodeEnum._('number0');
const StickersRemove200ResponseCodeEnum
_$stickersRemove200ResponseCodeEnum_unknownDefaultOpenApi =
    const StickersRemove200ResponseCodeEnum._('unknownDefaultOpenApi');

StickersRemove200ResponseCodeEnum _$stickersRemove200ResponseCodeEnumValueOf(
  String name,
) {
  switch (name) {
    case 'number0':
      return _$stickersRemove200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$stickersRemove200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$stickersRemove200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<StickersRemove200ResponseCodeEnum>
_$stickersRemove200ResponseCodeEnumValues =
    BuiltSet<StickersRemove200ResponseCodeEnum>(
      const <StickersRemove200ResponseCodeEnum>[
        _$stickersRemove200ResponseCodeEnum_number0,
        _$stickersRemove200ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<StickersRemove200ResponseCodeEnum>
_$stickersRemove200ResponseCodeEnumSerializer =
    _$StickersRemove200ResponseCodeEnumSerializer();

class _$StickersRemove200ResponseCodeEnumSerializer
    implements PrimitiveSerializer<StickersRemove200ResponseCodeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'number0': 0,
    'unknownDefaultOpenApi': 11184809,
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    0: 'number0',
    11184809: 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[StickersRemove200ResponseCodeEnum];
  @override
  final String wireName = 'StickersRemove200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    StickersRemove200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  StickersRemove200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => StickersRemove200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$StickersRemove200Response extends StickersRemove200Response {
  @override
  final StickerCollectionResponseDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$StickersRemove200Response([
    void Function(StickersRemove200ResponseBuilder)? updates,
  ]) => (StickersRemove200ResponseBuilder()..update(updates))._build();

  _$StickersRemove200Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  StickersRemove200Response rebuild(
    void Function(StickersRemove200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  StickersRemove200ResponseBuilder toBuilder() =>
      StickersRemove200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is StickersRemove200Response &&
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
    return (newBuiltValueToStringHelper(r'StickersRemove200Response')
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class StickersRemove200ResponseBuilder
    implements
        Builder<StickersRemove200Response, StickersRemove200ResponseBuilder>,
        ApiSuccessEnvelopeBuilder {
  _$StickersRemove200Response? _$v;

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

  StickersRemove200ResponseBuilder() {
    StickersRemove200Response._defaults(this);
  }

  StickersRemove200ResponseBuilder get _$this {
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
  void replace(covariant StickersRemove200Response other) {
    _$v = other as _$StickersRemove200Response;
  }

  @override
  void update(void Function(StickersRemove200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  StickersRemove200Response build() => _build();

  _$StickersRemove200Response _build() {
    _$StickersRemove200Response _$result;
    try {
      _$result =
          _$v ??
          _$StickersRemove200Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'StickersRemove200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'StickersRemove200Response',
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
          r'StickersRemove200Response',
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
