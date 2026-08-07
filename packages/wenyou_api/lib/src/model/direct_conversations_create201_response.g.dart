// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'direct_conversations_create201_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const DirectConversationsCreate201ResponseCodeEnum
_$directConversationsCreate201ResponseCodeEnum_number0 =
    const DirectConversationsCreate201ResponseCodeEnum._('number0');
const DirectConversationsCreate201ResponseCodeEnum
_$directConversationsCreate201ResponseCodeEnum_unknownDefaultOpenApi =
    const DirectConversationsCreate201ResponseCodeEnum._(
      'unknownDefaultOpenApi',
    );

DirectConversationsCreate201ResponseCodeEnum
_$directConversationsCreate201ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$directConversationsCreate201ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$directConversationsCreate201ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$directConversationsCreate201ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<DirectConversationsCreate201ResponseCodeEnum>
_$directConversationsCreate201ResponseCodeEnumValues =
    BuiltSet<DirectConversationsCreate201ResponseCodeEnum>(
      const <DirectConversationsCreate201ResponseCodeEnum>[
        _$directConversationsCreate201ResponseCodeEnum_number0,
        _$directConversationsCreate201ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<DirectConversationsCreate201ResponseCodeEnum>
_$directConversationsCreate201ResponseCodeEnumSerializer =
    _$DirectConversationsCreate201ResponseCodeEnumSerializer();

class _$DirectConversationsCreate201ResponseCodeEnumSerializer
    implements
        PrimitiveSerializer<DirectConversationsCreate201ResponseCodeEnum> {
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
    DirectConversationsCreate201ResponseCodeEnum,
  ];
  @override
  final String wireName = 'DirectConversationsCreate201ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    DirectConversationsCreate201ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  DirectConversationsCreate201ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => DirectConversationsCreate201ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$DirectConversationsCreate201Response
    extends DirectConversationsCreate201Response {
  @override
  final DirectConversationStartResponseDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$DirectConversationsCreate201Response([
    void Function(DirectConversationsCreate201ResponseBuilder)? updates,
  ]) =>
      (DirectConversationsCreate201ResponseBuilder()..update(updates))._build();

  _$DirectConversationsCreate201Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  DirectConversationsCreate201Response rebuild(
    void Function(DirectConversationsCreate201ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  DirectConversationsCreate201ResponseBuilder toBuilder() =>
      DirectConversationsCreate201ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is DirectConversationsCreate201Response &&
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
    return (newBuiltValueToStringHelper(r'DirectConversationsCreate201Response')
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class DirectConversationsCreate201ResponseBuilder
    implements
        Builder<
          DirectConversationsCreate201Response,
          DirectConversationsCreate201ResponseBuilder
        >,
        ApiSuccessEnvelopeBuilder {
  _$DirectConversationsCreate201Response? _$v;

  DirectConversationStartResponseDtoBuilder? _data;
  DirectConversationStartResponseDtoBuilder get data =>
      _$this._data ??= DirectConversationStartResponseDtoBuilder();
  set data(covariant DirectConversationStartResponseDtoBuilder? data) =>
      _$this._data = data;

  ApiSuccessEnvelopeCodeEnum? _code;
  ApiSuccessEnvelopeCodeEnum? get code => _$this._code;
  set code(covariant ApiSuccessEnvelopeCodeEnum? code) => _$this._code = code;

  String? _message;
  String? get message => _$this._message;
  set message(covariant String? message) => _$this._message = message;

  DirectConversationsCreate201ResponseBuilder() {
    DirectConversationsCreate201Response._defaults(this);
  }

  DirectConversationsCreate201ResponseBuilder get _$this {
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
  void replace(covariant DirectConversationsCreate201Response other) {
    _$v = other as _$DirectConversationsCreate201Response;
  }

  @override
  void update(
    void Function(DirectConversationsCreate201ResponseBuilder)? updates,
  ) {
    if (updates != null) updates(this);
  }

  @override
  DirectConversationsCreate201Response build() => _build();

  _$DirectConversationsCreate201Response _build() {
    _$DirectConversationsCreate201Response _$result;
    try {
      _$result =
          _$v ??
          _$DirectConversationsCreate201Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'DirectConversationsCreate201Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'DirectConversationsCreate201Response',
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
          r'DirectConversationsCreate201Response',
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
