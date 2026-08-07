// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notifications_find_all200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const NotificationsFindAll200ResponseCodeEnum
_$notificationsFindAll200ResponseCodeEnum_number0 =
    const NotificationsFindAll200ResponseCodeEnum._('number0');
const NotificationsFindAll200ResponseCodeEnum
_$notificationsFindAll200ResponseCodeEnum_unknownDefaultOpenApi =
    const NotificationsFindAll200ResponseCodeEnum._('unknownDefaultOpenApi');

NotificationsFindAll200ResponseCodeEnum
_$notificationsFindAll200ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$notificationsFindAll200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$notificationsFindAll200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$notificationsFindAll200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<NotificationsFindAll200ResponseCodeEnum>
_$notificationsFindAll200ResponseCodeEnumValues =
    BuiltSet<NotificationsFindAll200ResponseCodeEnum>(
      const <NotificationsFindAll200ResponseCodeEnum>[
        _$notificationsFindAll200ResponseCodeEnum_number0,
        _$notificationsFindAll200ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<NotificationsFindAll200ResponseCodeEnum>
_$notificationsFindAll200ResponseCodeEnumSerializer =
    _$NotificationsFindAll200ResponseCodeEnumSerializer();

class _$NotificationsFindAll200ResponseCodeEnumSerializer
    implements PrimitiveSerializer<NotificationsFindAll200ResponseCodeEnum> {
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
    NotificationsFindAll200ResponseCodeEnum,
  ];
  @override
  final String wireName = 'NotificationsFindAll200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    NotificationsFindAll200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  NotificationsFindAll200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => NotificationsFindAll200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$NotificationsFindAll200Response
    extends NotificationsFindAll200Response {
  @override
  final BuiltList<NotificationResponseDto> data;
  @override
  final ApiPaginationMeta meta;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$NotificationsFindAll200Response([
    void Function(NotificationsFindAll200ResponseBuilder)? updates,
  ]) => (NotificationsFindAll200ResponseBuilder()..update(updates))._build();

  _$NotificationsFindAll200Response._({
    required this.data,
    required this.meta,
    required this.code,
    required this.message,
  }) : super._();
  @override
  NotificationsFindAll200Response rebuild(
    void Function(NotificationsFindAll200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  NotificationsFindAll200ResponseBuilder toBuilder() =>
      NotificationsFindAll200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is NotificationsFindAll200Response &&
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
    return (newBuiltValueToStringHelper(r'NotificationsFindAll200Response')
          ..add('data', data)
          ..add('meta', meta)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class NotificationsFindAll200ResponseBuilder
    implements
        Builder<
          NotificationsFindAll200Response,
          NotificationsFindAll200ResponseBuilder
        >,
        ApiPaginatedSuccessEnvelopeBuilder {
  _$NotificationsFindAll200Response? _$v;

  ListBuilder<NotificationResponseDto>? _data;
  ListBuilder<NotificationResponseDto> get data =>
      _$this._data ??= ListBuilder<NotificationResponseDto>();
  set data(covariant ListBuilder<NotificationResponseDto>? data) =>
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

  NotificationsFindAll200ResponseBuilder() {
    NotificationsFindAll200Response._defaults(this);
  }

  NotificationsFindAll200ResponseBuilder get _$this {
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
  void replace(covariant NotificationsFindAll200Response other) {
    _$v = other as _$NotificationsFindAll200Response;
  }

  @override
  void update(void Function(NotificationsFindAll200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  NotificationsFindAll200Response build() => _build();

  _$NotificationsFindAll200Response _build() {
    _$NotificationsFindAll200Response _$result;
    try {
      _$result =
          _$v ??
          _$NotificationsFindAll200Response._(
            data: data.build(),
            meta: meta.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'NotificationsFindAll200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'NotificationsFindAll200Response',
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
          r'NotificationsFindAll200Response',
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
