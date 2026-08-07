// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'direct_conversations_send201_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const DirectConversationsSend201ResponseCodeEnum
_$directConversationsSend201ResponseCodeEnum_number0 =
    const DirectConversationsSend201ResponseCodeEnum._('number0');
const DirectConversationsSend201ResponseCodeEnum
_$directConversationsSend201ResponseCodeEnum_unknownDefaultOpenApi =
    const DirectConversationsSend201ResponseCodeEnum._('unknownDefaultOpenApi');

DirectConversationsSend201ResponseCodeEnum
_$directConversationsSend201ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$directConversationsSend201ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$directConversationsSend201ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$directConversationsSend201ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<DirectConversationsSend201ResponseCodeEnum>
_$directConversationsSend201ResponseCodeEnumValues =
    BuiltSet<DirectConversationsSend201ResponseCodeEnum>(
      const <DirectConversationsSend201ResponseCodeEnum>[
        _$directConversationsSend201ResponseCodeEnum_number0,
        _$directConversationsSend201ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<DirectConversationsSend201ResponseCodeEnum>
_$directConversationsSend201ResponseCodeEnumSerializer =
    _$DirectConversationsSend201ResponseCodeEnumSerializer();

class _$DirectConversationsSend201ResponseCodeEnumSerializer
    implements PrimitiveSerializer<DirectConversationsSend201ResponseCodeEnum> {
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
    DirectConversationsSend201ResponseCodeEnum,
  ];
  @override
  final String wireName = 'DirectConversationsSend201ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    DirectConversationsSend201ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  DirectConversationsSend201ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => DirectConversationsSend201ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$DirectConversationsSend201Response
    extends DirectConversationsSend201Response {
  @override
  final DirectMessageResponseDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$DirectConversationsSend201Response([
    void Function(DirectConversationsSend201ResponseBuilder)? updates,
  ]) => (DirectConversationsSend201ResponseBuilder()..update(updates))._build();

  _$DirectConversationsSend201Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  DirectConversationsSend201Response rebuild(
    void Function(DirectConversationsSend201ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  DirectConversationsSend201ResponseBuilder toBuilder() =>
      DirectConversationsSend201ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is DirectConversationsSend201Response &&
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
    return (newBuiltValueToStringHelper(r'DirectConversationsSend201Response')
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class DirectConversationsSend201ResponseBuilder
    implements
        Builder<
          DirectConversationsSend201Response,
          DirectConversationsSend201ResponseBuilder
        >,
        ApiSuccessEnvelopeBuilder {
  _$DirectConversationsSend201Response? _$v;

  DirectMessageResponseDtoBuilder? _data;
  DirectMessageResponseDtoBuilder get data =>
      _$this._data ??= DirectMessageResponseDtoBuilder();
  set data(covariant DirectMessageResponseDtoBuilder? data) =>
      _$this._data = data;

  ApiSuccessEnvelopeCodeEnum? _code;
  ApiSuccessEnvelopeCodeEnum? get code => _$this._code;
  set code(covariant ApiSuccessEnvelopeCodeEnum? code) => _$this._code = code;

  String? _message;
  String? get message => _$this._message;
  set message(covariant String? message) => _$this._message = message;

  DirectConversationsSend201ResponseBuilder() {
    DirectConversationsSend201Response._defaults(this);
  }

  DirectConversationsSend201ResponseBuilder get _$this {
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
  void replace(covariant DirectConversationsSend201Response other) {
    _$v = other as _$DirectConversationsSend201Response;
  }

  @override
  void update(
    void Function(DirectConversationsSend201ResponseBuilder)? updates,
  ) {
    if (updates != null) updates(this);
  }

  @override
  DirectConversationsSend201Response build() => _build();

  _$DirectConversationsSend201Response _build() {
    _$DirectConversationsSend201Response _$result;
    try {
      _$result =
          _$v ??
          _$DirectConversationsSend201Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'DirectConversationsSend201Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'DirectConversationsSend201Response',
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
          r'DirectConversationsSend201Response',
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
