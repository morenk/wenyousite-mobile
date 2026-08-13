// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'users_get_user_activity_summary200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const UsersGetUserActivitySummary200ResponseCodeEnum
_$usersGetUserActivitySummary200ResponseCodeEnum_number0 =
    const UsersGetUserActivitySummary200ResponseCodeEnum._('number0');
const UsersGetUserActivitySummary200ResponseCodeEnum
_$usersGetUserActivitySummary200ResponseCodeEnum_unknownDefaultOpenApi =
    const UsersGetUserActivitySummary200ResponseCodeEnum._(
      'unknownDefaultOpenApi',
    );

UsersGetUserActivitySummary200ResponseCodeEnum
_$usersGetUserActivitySummary200ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$usersGetUserActivitySummary200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$usersGetUserActivitySummary200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$usersGetUserActivitySummary200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<UsersGetUserActivitySummary200ResponseCodeEnum>
_$usersGetUserActivitySummary200ResponseCodeEnumValues =
    BuiltSet<UsersGetUserActivitySummary200ResponseCodeEnum>(
      const <UsersGetUserActivitySummary200ResponseCodeEnum>[
        _$usersGetUserActivitySummary200ResponseCodeEnum_number0,
        _$usersGetUserActivitySummary200ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<UsersGetUserActivitySummary200ResponseCodeEnum>
_$usersGetUserActivitySummary200ResponseCodeEnumSerializer =
    _$UsersGetUserActivitySummary200ResponseCodeEnumSerializer();

class _$UsersGetUserActivitySummary200ResponseCodeEnumSerializer
    implements
        PrimitiveSerializer<UsersGetUserActivitySummary200ResponseCodeEnum> {
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
    UsersGetUserActivitySummary200ResponseCodeEnum,
  ];
  @override
  final String wireName = 'UsersGetUserActivitySummary200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    UsersGetUserActivitySummary200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  UsersGetUserActivitySummary200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => UsersGetUserActivitySummary200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$UsersGetUserActivitySummary200Response
    extends UsersGetUserActivitySummary200Response {
  @override
  final UserActivitySummaryResponseDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$UsersGetUserActivitySummary200Response([
    void Function(UsersGetUserActivitySummary200ResponseBuilder)? updates,
  ]) => (UsersGetUserActivitySummary200ResponseBuilder()..update(updates))
      ._build();

  _$UsersGetUserActivitySummary200Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  UsersGetUserActivitySummary200Response rebuild(
    void Function(UsersGetUserActivitySummary200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  UsersGetUserActivitySummary200ResponseBuilder toBuilder() =>
      UsersGetUserActivitySummary200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is UsersGetUserActivitySummary200Response &&
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
            r'UsersGetUserActivitySummary200Response',
          )
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class UsersGetUserActivitySummary200ResponseBuilder
    implements
        Builder<
          UsersGetUserActivitySummary200Response,
          UsersGetUserActivitySummary200ResponseBuilder
        >,
        ApiSuccessEnvelopeBuilder {
  _$UsersGetUserActivitySummary200Response? _$v;

  UserActivitySummaryResponseDtoBuilder? _data;
  UserActivitySummaryResponseDtoBuilder get data =>
      _$this._data ??= UserActivitySummaryResponseDtoBuilder();
  set data(covariant UserActivitySummaryResponseDtoBuilder? data) =>
      _$this._data = data;

  ApiSuccessEnvelopeCodeEnum? _code;
  ApiSuccessEnvelopeCodeEnum? get code => _$this._code;
  set code(covariant ApiSuccessEnvelopeCodeEnum? code) => _$this._code = code;

  String? _message;
  String? get message => _$this._message;
  set message(covariant String? message) => _$this._message = message;

  UsersGetUserActivitySummary200ResponseBuilder() {
    UsersGetUserActivitySummary200Response._defaults(this);
  }

  UsersGetUserActivitySummary200ResponseBuilder get _$this {
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
  void replace(covariant UsersGetUserActivitySummary200Response other) {
    _$v = other as _$UsersGetUserActivitySummary200Response;
  }

  @override
  void update(
    void Function(UsersGetUserActivitySummary200ResponseBuilder)? updates,
  ) {
    if (updates != null) updates(this);
  }

  @override
  UsersGetUserActivitySummary200Response build() => _build();

  _$UsersGetUserActivitySummary200Response _build() {
    _$UsersGetUserActivitySummary200Response _$result;
    try {
      _$result =
          _$v ??
          _$UsersGetUserActivitySummary200Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'UsersGetUserActivitySummary200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'UsersGetUserActivitySummary200Response',
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
          r'UsersGetUserActivitySummary200Response',
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
