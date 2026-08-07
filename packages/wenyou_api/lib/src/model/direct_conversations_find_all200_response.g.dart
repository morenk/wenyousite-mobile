// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'direct_conversations_find_all200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const DirectConversationsFindAll200ResponseCodeEnum
_$directConversationsFindAll200ResponseCodeEnum_number0 =
    const DirectConversationsFindAll200ResponseCodeEnum._('number0');
const DirectConversationsFindAll200ResponseCodeEnum
_$directConversationsFindAll200ResponseCodeEnum_unknownDefaultOpenApi =
    const DirectConversationsFindAll200ResponseCodeEnum._(
      'unknownDefaultOpenApi',
    );

DirectConversationsFindAll200ResponseCodeEnum
_$directConversationsFindAll200ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$directConversationsFindAll200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$directConversationsFindAll200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$directConversationsFindAll200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<DirectConversationsFindAll200ResponseCodeEnum>
_$directConversationsFindAll200ResponseCodeEnumValues =
    BuiltSet<DirectConversationsFindAll200ResponseCodeEnum>(
      const <DirectConversationsFindAll200ResponseCodeEnum>[
        _$directConversationsFindAll200ResponseCodeEnum_number0,
        _$directConversationsFindAll200ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<DirectConversationsFindAll200ResponseCodeEnum>
_$directConversationsFindAll200ResponseCodeEnumSerializer =
    _$DirectConversationsFindAll200ResponseCodeEnumSerializer();

class _$DirectConversationsFindAll200ResponseCodeEnumSerializer
    implements
        PrimitiveSerializer<DirectConversationsFindAll200ResponseCodeEnum> {
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
    DirectConversationsFindAll200ResponseCodeEnum,
  ];
  @override
  final String wireName = 'DirectConversationsFindAll200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    DirectConversationsFindAll200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  DirectConversationsFindAll200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => DirectConversationsFindAll200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$DirectConversationsFindAll200Response
    extends DirectConversationsFindAll200Response {
  @override
  final BuiltList<DirectConversationResponseDto> data;
  @override
  final ApiPaginationMeta meta;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$DirectConversationsFindAll200Response([
    void Function(DirectConversationsFindAll200ResponseBuilder)? updates,
  ]) => (DirectConversationsFindAll200ResponseBuilder()..update(updates))
      ._build();

  _$DirectConversationsFindAll200Response._({
    required this.data,
    required this.meta,
    required this.code,
    required this.message,
  }) : super._();
  @override
  DirectConversationsFindAll200Response rebuild(
    void Function(DirectConversationsFindAll200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  DirectConversationsFindAll200ResponseBuilder toBuilder() =>
      DirectConversationsFindAll200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is DirectConversationsFindAll200Response &&
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
            r'DirectConversationsFindAll200Response',
          )
          ..add('data', data)
          ..add('meta', meta)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class DirectConversationsFindAll200ResponseBuilder
    implements
        Builder<
          DirectConversationsFindAll200Response,
          DirectConversationsFindAll200ResponseBuilder
        >,
        ApiPaginatedSuccessEnvelopeBuilder {
  _$DirectConversationsFindAll200Response? _$v;

  ListBuilder<DirectConversationResponseDto>? _data;
  ListBuilder<DirectConversationResponseDto> get data =>
      _$this._data ??= ListBuilder<DirectConversationResponseDto>();
  set data(covariant ListBuilder<DirectConversationResponseDto>? data) =>
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

  DirectConversationsFindAll200ResponseBuilder() {
    DirectConversationsFindAll200Response._defaults(this);
  }

  DirectConversationsFindAll200ResponseBuilder get _$this {
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
  void replace(covariant DirectConversationsFindAll200Response other) {
    _$v = other as _$DirectConversationsFindAll200Response;
  }

  @override
  void update(
    void Function(DirectConversationsFindAll200ResponseBuilder)? updates,
  ) {
    if (updates != null) updates(this);
  }

  @override
  DirectConversationsFindAll200Response build() => _build();

  _$DirectConversationsFindAll200Response _build() {
    _$DirectConversationsFindAll200Response _$result;
    try {
      _$result =
          _$v ??
          _$DirectConversationsFindAll200Response._(
            data: data.build(),
            meta: meta.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'DirectConversationsFindAll200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'DirectConversationsFindAll200Response',
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
          r'DirectConversationsFindAll200Response',
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
