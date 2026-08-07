// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'users_search200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const UsersSearch200ResponseCodeEnum _$usersSearch200ResponseCodeEnum_number0 =
    const UsersSearch200ResponseCodeEnum._('number0');
const UsersSearch200ResponseCodeEnum
_$usersSearch200ResponseCodeEnum_unknownDefaultOpenApi =
    const UsersSearch200ResponseCodeEnum._('unknownDefaultOpenApi');

UsersSearch200ResponseCodeEnum _$usersSearch200ResponseCodeEnumValueOf(
  String name,
) {
  switch (name) {
    case 'number0':
      return _$usersSearch200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$usersSearch200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$usersSearch200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<UsersSearch200ResponseCodeEnum>
_$usersSearch200ResponseCodeEnumValues =
    BuiltSet<UsersSearch200ResponseCodeEnum>(
      const <UsersSearch200ResponseCodeEnum>[
        _$usersSearch200ResponseCodeEnum_number0,
        _$usersSearch200ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<UsersSearch200ResponseCodeEnum>
_$usersSearch200ResponseCodeEnumSerializer =
    _$UsersSearch200ResponseCodeEnumSerializer();

class _$UsersSearch200ResponseCodeEnumSerializer
    implements PrimitiveSerializer<UsersSearch200ResponseCodeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'number0': 0,
    'unknownDefaultOpenApi': 11184809,
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    0: 'number0',
    11184809: 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[UsersSearch200ResponseCodeEnum];
  @override
  final String wireName = 'UsersSearch200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    UsersSearch200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  UsersSearch200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => UsersSearch200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$UsersSearch200Response extends UsersSearch200Response {
  @override
  final BuiltList<PostAuthorResponseDto> data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$UsersSearch200Response([
    void Function(UsersSearch200ResponseBuilder)? updates,
  ]) => (UsersSearch200ResponseBuilder()..update(updates))._build();

  _$UsersSearch200Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  UsersSearch200Response rebuild(
    void Function(UsersSearch200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  UsersSearch200ResponseBuilder toBuilder() =>
      UsersSearch200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is UsersSearch200Response &&
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
    return (newBuiltValueToStringHelper(r'UsersSearch200Response')
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class UsersSearch200ResponseBuilder
    implements
        Builder<UsersSearch200Response, UsersSearch200ResponseBuilder>,
        ApiSuccessEnvelopeBuilder {
  _$UsersSearch200Response? _$v;

  ListBuilder<PostAuthorResponseDto>? _data;
  ListBuilder<PostAuthorResponseDto> get data =>
      _$this._data ??= ListBuilder<PostAuthorResponseDto>();
  set data(covariant ListBuilder<PostAuthorResponseDto>? data) =>
      _$this._data = data;

  ApiSuccessEnvelopeCodeEnum? _code;
  ApiSuccessEnvelopeCodeEnum? get code => _$this._code;
  set code(covariant ApiSuccessEnvelopeCodeEnum? code) => _$this._code = code;

  String? _message;
  String? get message => _$this._message;
  set message(covariant String? message) => _$this._message = message;

  UsersSearch200ResponseBuilder() {
    UsersSearch200Response._defaults(this);
  }

  UsersSearch200ResponseBuilder get _$this {
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
  void replace(covariant UsersSearch200Response other) {
    _$v = other as _$UsersSearch200Response;
  }

  @override
  void update(void Function(UsersSearch200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  UsersSearch200Response build() => _build();

  _$UsersSearch200Response _build() {
    _$UsersSearch200Response _$result;
    try {
      _$result =
          _$v ??
          _$UsersSearch200Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'UsersSearch200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'UsersSearch200Response',
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
          r'UsersSearch200Response',
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
