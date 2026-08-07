// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'direct_conversations_messages200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const DirectConversationsMessages200ResponseCodeEnum
_$directConversationsMessages200ResponseCodeEnum_number0 =
    const DirectConversationsMessages200ResponseCodeEnum._('number0');
const DirectConversationsMessages200ResponseCodeEnum
_$directConversationsMessages200ResponseCodeEnum_unknownDefaultOpenApi =
    const DirectConversationsMessages200ResponseCodeEnum._(
      'unknownDefaultOpenApi',
    );

DirectConversationsMessages200ResponseCodeEnum
_$directConversationsMessages200ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$directConversationsMessages200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$directConversationsMessages200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$directConversationsMessages200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<DirectConversationsMessages200ResponseCodeEnum>
_$directConversationsMessages200ResponseCodeEnumValues =
    BuiltSet<DirectConversationsMessages200ResponseCodeEnum>(
      const <DirectConversationsMessages200ResponseCodeEnum>[
        _$directConversationsMessages200ResponseCodeEnum_number0,
        _$directConversationsMessages200ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<DirectConversationsMessages200ResponseCodeEnum>
_$directConversationsMessages200ResponseCodeEnumSerializer =
    _$DirectConversationsMessages200ResponseCodeEnumSerializer();

class _$DirectConversationsMessages200ResponseCodeEnumSerializer
    implements
        PrimitiveSerializer<DirectConversationsMessages200ResponseCodeEnum> {
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
    DirectConversationsMessages200ResponseCodeEnum,
  ];
  @override
  final String wireName = 'DirectConversationsMessages200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    DirectConversationsMessages200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  DirectConversationsMessages200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => DirectConversationsMessages200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$DirectConversationsMessages200Response
    extends DirectConversationsMessages200Response {
  @override
  final BuiltList<DirectMessageResponseDto> data;
  @override
  final ApiPaginationMeta meta;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$DirectConversationsMessages200Response([
    void Function(DirectConversationsMessages200ResponseBuilder)? updates,
  ]) => (DirectConversationsMessages200ResponseBuilder()..update(updates))
      ._build();

  _$DirectConversationsMessages200Response._({
    required this.data,
    required this.meta,
    required this.code,
    required this.message,
  }) : super._();
  @override
  DirectConversationsMessages200Response rebuild(
    void Function(DirectConversationsMessages200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  DirectConversationsMessages200ResponseBuilder toBuilder() =>
      DirectConversationsMessages200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is DirectConversationsMessages200Response &&
        data == other.data &&
        meta == other.meta &&
        code == other.code &&
        message == other.message;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, data.hashCode);
    _$hash = $jc(_$hash, meta.hashCode);
    _$hash = $jc(_$hash, code.hashCode);
    _$hash = $jc(_$hash, message.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'DirectConversationsMessages200Response',
          )
          ..add('data', data)
          ..add('meta', meta)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class DirectConversationsMessages200ResponseBuilder
    implements
        Builder<
          DirectConversationsMessages200Response,
          DirectConversationsMessages200ResponseBuilder
        >,
        ApiPaginatedSuccessEnvelopeBuilder {
  _$DirectConversationsMessages200Response? _$v;

  ListBuilder<DirectMessageResponseDto>? _data;
  ListBuilder<DirectMessageResponseDto> get data =>
      _$this._data ??= ListBuilder<DirectMessageResponseDto>();
  set data(covariant ListBuilder<DirectMessageResponseDto>? data) =>
      _$this._data = data;

  ApiPaginationMetaBuilder? _meta;
  ApiPaginationMetaBuilder get meta =>
      _$this._meta ??= ApiPaginationMetaBuilder();
  set meta(covariant ApiPaginationMetaBuilder? meta) => _$this._meta = meta;

  ApiSuccessEnvelopeCodeEnum? _code;
  ApiSuccessEnvelopeCodeEnum? get code => _$this._code;
  set code(covariant ApiSuccessEnvelopeCodeEnum? code) => _$this._code = code;

  String? _message;
  String? get message => _$this._message;
  set message(covariant String? message) => _$this._message = message;

  DirectConversationsMessages200ResponseBuilder() {
    DirectConversationsMessages200Response._defaults(this);
  }

  DirectConversationsMessages200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _meta = $v.meta.toBuilder();
      _code = $v.code;
      _message = $v.message;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(covariant DirectConversationsMessages200Response other) {
    _$v = other as _$DirectConversationsMessages200Response;
  }

  @override
  void update(
    void Function(DirectConversationsMessages200ResponseBuilder)? updates,
  ) {
    if (updates != null) updates(this);
  }

  @override
  DirectConversationsMessages200Response build() => _build();

  _$DirectConversationsMessages200Response _build() {
    _$DirectConversationsMessages200Response _$result;
    try {
      _$result =
          _$v ??
          _$DirectConversationsMessages200Response._(
            data: data.build(),
            meta: meta.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'DirectConversationsMessages200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'DirectConversationsMessages200Response',
              'message',
            ),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
        _$failedField = 'meta';
        meta.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'DirectConversationsMessages200Response',
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
