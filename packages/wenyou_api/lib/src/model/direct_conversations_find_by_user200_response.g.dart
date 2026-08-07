// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'direct_conversations_find_by_user200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const DirectConversationsFindByUser200ResponseCodeEnum
_$directConversationsFindByUser200ResponseCodeEnum_number0 =
    const DirectConversationsFindByUser200ResponseCodeEnum._('number0');
const DirectConversationsFindByUser200ResponseCodeEnum
_$directConversationsFindByUser200ResponseCodeEnum_unknownDefaultOpenApi =
    const DirectConversationsFindByUser200ResponseCodeEnum._(
      'unknownDefaultOpenApi',
    );

DirectConversationsFindByUser200ResponseCodeEnum
_$directConversationsFindByUser200ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$directConversationsFindByUser200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$directConversationsFindByUser200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$directConversationsFindByUser200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<DirectConversationsFindByUser200ResponseCodeEnum>
_$directConversationsFindByUser200ResponseCodeEnumValues =
    BuiltSet<DirectConversationsFindByUser200ResponseCodeEnum>(const <
      DirectConversationsFindByUser200ResponseCodeEnum
    >[
      _$directConversationsFindByUser200ResponseCodeEnum_number0,
      _$directConversationsFindByUser200ResponseCodeEnum_unknownDefaultOpenApi,
    ]);

Serializer<DirectConversationsFindByUser200ResponseCodeEnum>
_$directConversationsFindByUser200ResponseCodeEnumSerializer =
    _$DirectConversationsFindByUser200ResponseCodeEnumSerializer();

class _$DirectConversationsFindByUser200ResponseCodeEnumSerializer
    implements
        PrimitiveSerializer<DirectConversationsFindByUser200ResponseCodeEnum> {
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
    DirectConversationsFindByUser200ResponseCodeEnum,
  ];
  @override
  final String wireName = 'DirectConversationsFindByUser200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    DirectConversationsFindByUser200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  DirectConversationsFindByUser200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => DirectConversationsFindByUser200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$DirectConversationsFindByUser200Response
    extends DirectConversationsFindByUser200Response {
  @override
  final DirectConversationLookupResponseDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$DirectConversationsFindByUser200Response([
    void Function(DirectConversationsFindByUser200ResponseBuilder)? updates,
  ]) => (DirectConversationsFindByUser200ResponseBuilder()..update(updates))
      ._build();

  _$DirectConversationsFindByUser200Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  DirectConversationsFindByUser200Response rebuild(
    void Function(DirectConversationsFindByUser200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  DirectConversationsFindByUser200ResponseBuilder toBuilder() =>
      DirectConversationsFindByUser200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is DirectConversationsFindByUser200Response &&
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
    return (newBuiltValueToStringHelper(
            r'DirectConversationsFindByUser200Response',
          )
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class DirectConversationsFindByUser200ResponseBuilder
    implements
        Builder<
          DirectConversationsFindByUser200Response,
          DirectConversationsFindByUser200ResponseBuilder
        >,
        ApiSuccessEnvelopeBuilder {
  _$DirectConversationsFindByUser200Response? _$v;

  DirectConversationLookupResponseDtoBuilder? _data;
  DirectConversationLookupResponseDtoBuilder get data =>
      _$this._data ??= DirectConversationLookupResponseDtoBuilder();
  set data(covariant DirectConversationLookupResponseDtoBuilder? data) =>
      _$this._data = data;

  ApiSuccessEnvelopeCodeEnum? _code;
  ApiSuccessEnvelopeCodeEnum? get code => _$this._code;
  set code(covariant ApiSuccessEnvelopeCodeEnum? code) => _$this._code = code;

  String? _message;
  String? get message => _$this._message;
  set message(covariant String? message) => _$this._message = message;

  DirectConversationsFindByUser200ResponseBuilder() {
    DirectConversationsFindByUser200Response._defaults(this);
  }

  DirectConversationsFindByUser200ResponseBuilder get _$this {
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
  void replace(covariant DirectConversationsFindByUser200Response other) {
    _$v = other as _$DirectConversationsFindByUser200Response;
  }

  @override
  void update(
    void Function(DirectConversationsFindByUser200ResponseBuilder)? updates,
  ) {
    if (updates != null) updates(this);
  }

  @override
  DirectConversationsFindByUser200Response build() => _build();

  _$DirectConversationsFindByUser200Response _build() {
    _$DirectConversationsFindByUser200Response _$result;
    try {
      _$result =
          _$v ??
          _$DirectConversationsFindByUser200Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'DirectConversationsFindByUser200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'DirectConversationsFindByUser200Response',
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
          r'DirectConversationsFindByUser200Response',
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
