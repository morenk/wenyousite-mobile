// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'direct_conversations_unread200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const DirectConversationsUnread200ResponseCodeEnum
_$directConversationsUnread200ResponseCodeEnum_number0 =
    const DirectConversationsUnread200ResponseCodeEnum._('number0');
const DirectConversationsUnread200ResponseCodeEnum
_$directConversationsUnread200ResponseCodeEnum_unknownDefaultOpenApi =
    const DirectConversationsUnread200ResponseCodeEnum._(
      'unknownDefaultOpenApi',
    );

DirectConversationsUnread200ResponseCodeEnum
_$directConversationsUnread200ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$directConversationsUnread200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$directConversationsUnread200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$directConversationsUnread200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<DirectConversationsUnread200ResponseCodeEnum>
_$directConversationsUnread200ResponseCodeEnumValues =
    BuiltSet<DirectConversationsUnread200ResponseCodeEnum>(
      const <DirectConversationsUnread200ResponseCodeEnum>[
        _$directConversationsUnread200ResponseCodeEnum_number0,
        _$directConversationsUnread200ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<DirectConversationsUnread200ResponseCodeEnum>
_$directConversationsUnread200ResponseCodeEnumSerializer =
    _$DirectConversationsUnread200ResponseCodeEnumSerializer();

class _$DirectConversationsUnread200ResponseCodeEnumSerializer
    implements
        PrimitiveSerializer<DirectConversationsUnread200ResponseCodeEnum> {
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
    DirectConversationsUnread200ResponseCodeEnum,
  ];
  @override
  final String wireName = 'DirectConversationsUnread200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    DirectConversationsUnread200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  DirectConversationsUnread200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => DirectConversationsUnread200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$DirectConversationsUnread200Response
    extends DirectConversationsUnread200Response {
  @override
  final DirectUnreadCountResponseDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$DirectConversationsUnread200Response([
    void Function(DirectConversationsUnread200ResponseBuilder)? updates,
  ]) =>
      (DirectConversationsUnread200ResponseBuilder()..update(updates))._build();

  _$DirectConversationsUnread200Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  DirectConversationsUnread200Response rebuild(
    void Function(DirectConversationsUnread200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  DirectConversationsUnread200ResponseBuilder toBuilder() =>
      DirectConversationsUnread200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is DirectConversationsUnread200Response &&
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
    return (newBuiltValueToStringHelper(r'DirectConversationsUnread200Response')
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class DirectConversationsUnread200ResponseBuilder
    implements
        Builder<
          DirectConversationsUnread200Response,
          DirectConversationsUnread200ResponseBuilder
        >,
        ApiSuccessEnvelopeBuilder {
  _$DirectConversationsUnread200Response? _$v;

  DirectUnreadCountResponseDtoBuilder? _data;
  DirectUnreadCountResponseDtoBuilder get data =>
      _$this._data ??= DirectUnreadCountResponseDtoBuilder();
  set data(covariant DirectUnreadCountResponseDtoBuilder? data) =>
      _$this._data = data;

  ApiSuccessEnvelopeCodeEnum? _code;
  ApiSuccessEnvelopeCodeEnum? get code => _$this._code;
  set code(covariant ApiSuccessEnvelopeCodeEnum? code) => _$this._code = code;

  String? _message;
  String? get message => _$this._message;
  set message(covariant String? message) => _$this._message = message;

  DirectConversationsUnread200ResponseBuilder() {
    DirectConversationsUnread200Response._defaults(this);
  }

  DirectConversationsUnread200ResponseBuilder get _$this {
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
  void replace(covariant DirectConversationsUnread200Response other) {
    _$v = other as _$DirectConversationsUnread200Response;
  }

  @override
  void update(
    void Function(DirectConversationsUnread200ResponseBuilder)? updates,
  ) {
    if (updates != null) updates(this);
  }

  @override
  DirectConversationsUnread200Response build() => _build();

  _$DirectConversationsUnread200Response _build() {
    _$DirectConversationsUnread200Response _$result;
    try {
      _$result =
          _$v ??
          _$DirectConversationsUnread200Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'DirectConversationsUnread200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'DirectConversationsUnread200Response',
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
          r'DirectConversationsUnread200Response',
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
