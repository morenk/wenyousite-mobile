// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'direct_conversations_find_by_id200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const DirectConversationsFindById200ResponseCodeEnum
_$directConversationsFindById200ResponseCodeEnum_number0 =
    const DirectConversationsFindById200ResponseCodeEnum._('number0');
const DirectConversationsFindById200ResponseCodeEnum
_$directConversationsFindById200ResponseCodeEnum_unknownDefaultOpenApi =
    const DirectConversationsFindById200ResponseCodeEnum._(
      'unknownDefaultOpenApi',
    );

DirectConversationsFindById200ResponseCodeEnum
_$directConversationsFindById200ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$directConversationsFindById200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$directConversationsFindById200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$directConversationsFindById200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<DirectConversationsFindById200ResponseCodeEnum>
_$directConversationsFindById200ResponseCodeEnumValues =
    BuiltSet<DirectConversationsFindById200ResponseCodeEnum>(
      const <DirectConversationsFindById200ResponseCodeEnum>[
        _$directConversationsFindById200ResponseCodeEnum_number0,
        _$directConversationsFindById200ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<DirectConversationsFindById200ResponseCodeEnum>
_$directConversationsFindById200ResponseCodeEnumSerializer =
    _$DirectConversationsFindById200ResponseCodeEnumSerializer();

class _$DirectConversationsFindById200ResponseCodeEnumSerializer
    implements
        PrimitiveSerializer<DirectConversationsFindById200ResponseCodeEnum> {
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
    DirectConversationsFindById200ResponseCodeEnum,
  ];
  @override
  final String wireName = 'DirectConversationsFindById200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    DirectConversationsFindById200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  DirectConversationsFindById200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => DirectConversationsFindById200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$DirectConversationsFindById200Response
    extends DirectConversationsFindById200Response {
  @override
  final DirectConversationResponseDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$DirectConversationsFindById200Response([
    void Function(DirectConversationsFindById200ResponseBuilder)? updates,
  ]) => (DirectConversationsFindById200ResponseBuilder()..update(updates))
      ._build();

  _$DirectConversationsFindById200Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  DirectConversationsFindById200Response rebuild(
    void Function(DirectConversationsFindById200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  DirectConversationsFindById200ResponseBuilder toBuilder() =>
      DirectConversationsFindById200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is DirectConversationsFindById200Response &&
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
            r'DirectConversationsFindById200Response',
          )
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class DirectConversationsFindById200ResponseBuilder
    implements
        Builder<
          DirectConversationsFindById200Response,
          DirectConversationsFindById200ResponseBuilder
        >,
        ApiSuccessEnvelopeBuilder {
  _$DirectConversationsFindById200Response? _$v;

  DirectConversationResponseDtoBuilder? _data;
  DirectConversationResponseDtoBuilder get data =>
      _$this._data ??= DirectConversationResponseDtoBuilder();
  set data(covariant DirectConversationResponseDtoBuilder? data) =>
      _$this._data = data;

  ApiSuccessEnvelopeCodeEnum? _code;
  ApiSuccessEnvelopeCodeEnum? get code => _$this._code;
  set code(covariant ApiSuccessEnvelopeCodeEnum? code) => _$this._code = code;

  String? _message;
  String? get message => _$this._message;
  set message(covariant String? message) => _$this._message = message;

  DirectConversationsFindById200ResponseBuilder() {
    DirectConversationsFindById200Response._defaults(this);
  }

  DirectConversationsFindById200ResponseBuilder get _$this {
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
  void replace(covariant DirectConversationsFindById200Response other) {
    _$v = other as _$DirectConversationsFindById200Response;
  }

  @override
  void update(
    void Function(DirectConversationsFindById200ResponseBuilder)? updates,
  ) {
    if (updates != null) updates(this);
  }

  @override
  DirectConversationsFindById200Response build() => _build();

  _$DirectConversationsFindById200Response _build() {
    _$DirectConversationsFindById200Response _$result;
    try {
      _$result =
          _$v ??
          _$DirectConversationsFindById200Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'DirectConversationsFindById200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'DirectConversationsFindById200Response',
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
          r'DirectConversationsFindById200Response',
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
