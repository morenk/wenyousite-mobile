// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stickers_reorder200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const StickersReorder200ResponseCodeEnum
_$stickersReorder200ResponseCodeEnum_number0 =
    const StickersReorder200ResponseCodeEnum._('number0');
const StickersReorder200ResponseCodeEnum
_$stickersReorder200ResponseCodeEnum_unknownDefaultOpenApi =
    const StickersReorder200ResponseCodeEnum._('unknownDefaultOpenApi');

StickersReorder200ResponseCodeEnum _$stickersReorder200ResponseCodeEnumValueOf(
  String name,
) {
  switch (name) {
    case 'number0':
      return _$stickersReorder200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$stickersReorder200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$stickersReorder200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<StickersReorder200ResponseCodeEnum>
_$stickersReorder200ResponseCodeEnumValues =
    BuiltSet<StickersReorder200ResponseCodeEnum>(
      const <StickersReorder200ResponseCodeEnum>[
        _$stickersReorder200ResponseCodeEnum_number0,
        _$stickersReorder200ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<StickersReorder200ResponseCodeEnum>
_$stickersReorder200ResponseCodeEnumSerializer =
    _$StickersReorder200ResponseCodeEnumSerializer();

class _$StickersReorder200ResponseCodeEnumSerializer
    implements PrimitiveSerializer<StickersReorder200ResponseCodeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'number0': 0,
    'unknownDefaultOpenApi': 11184809,
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    0: 'number0',
    11184809: 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[StickersReorder200ResponseCodeEnum];
  @override
  final String wireName = 'StickersReorder200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    StickersReorder200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  StickersReorder200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => StickersReorder200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$StickersReorder200Response extends StickersReorder200Response {
  @override
  final StickerCollectionResponseDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$StickersReorder200Response([
    void Function(StickersReorder200ResponseBuilder)? updates,
  ]) => (StickersReorder200ResponseBuilder()..update(updates))._build();

  _$StickersReorder200Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  StickersReorder200Response rebuild(
    void Function(StickersReorder200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  StickersReorder200ResponseBuilder toBuilder() =>
      StickersReorder200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is StickersReorder200Response &&
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
    return (newBuiltValueToStringHelper(r'StickersReorder200Response')
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class StickersReorder200ResponseBuilder
    implements
        Builder<StickersReorder200Response, StickersReorder200ResponseBuilder>,
        ApiSuccessEnvelopeBuilder {
  _$StickersReorder200Response? _$v;

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

  StickersReorder200ResponseBuilder() {
    StickersReorder200Response._defaults(this);
  }

  StickersReorder200ResponseBuilder get _$this {
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
  void replace(covariant StickersReorder200Response other) {
    _$v = other as _$StickersReorder200Response;
  }

  @override
  void update(void Function(StickersReorder200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  StickersReorder200Response build() => _build();

  _$StickersReorder200Response _build() {
    _$StickersReorder200Response _$result;
    try {
      _$result =
          _$v ??
          _$StickersReorder200Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'StickersReorder200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'StickersReorder200Response',
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
          r'StickersReorder200Response',
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
