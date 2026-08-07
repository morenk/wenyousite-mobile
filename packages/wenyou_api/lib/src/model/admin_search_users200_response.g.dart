// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_search_users200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const AdminSearchUsers200ResponseCodeEnum
_$adminSearchUsers200ResponseCodeEnum_number0 =
    const AdminSearchUsers200ResponseCodeEnum._('number0');
const AdminSearchUsers200ResponseCodeEnum
_$adminSearchUsers200ResponseCodeEnum_unknownDefaultOpenApi =
    const AdminSearchUsers200ResponseCodeEnum._('unknownDefaultOpenApi');

AdminSearchUsers200ResponseCodeEnum
_$adminSearchUsers200ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$adminSearchUsers200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$adminSearchUsers200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$adminSearchUsers200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<AdminSearchUsers200ResponseCodeEnum>
_$adminSearchUsers200ResponseCodeEnumValues =
    BuiltSet<AdminSearchUsers200ResponseCodeEnum>(
      const <AdminSearchUsers200ResponseCodeEnum>[
        _$adminSearchUsers200ResponseCodeEnum_number0,
        _$adminSearchUsers200ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<AdminSearchUsers200ResponseCodeEnum>
_$adminSearchUsers200ResponseCodeEnumSerializer =
    _$AdminSearchUsers200ResponseCodeEnumSerializer();

class _$AdminSearchUsers200ResponseCodeEnumSerializer
    implements PrimitiveSerializer<AdminSearchUsers200ResponseCodeEnum> {
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
    AdminSearchUsers200ResponseCodeEnum,
  ];
  @override
  final String wireName = 'AdminSearchUsers200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    AdminSearchUsers200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  AdminSearchUsers200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => AdminSearchUsers200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$AdminSearchUsers200Response extends AdminSearchUsers200Response {
  @override
  final AdminUserSearchResponseDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$AdminSearchUsers200Response([
    void Function(AdminSearchUsers200ResponseBuilder)? updates,
  ]) => (AdminSearchUsers200ResponseBuilder()..update(updates))._build();

  _$AdminSearchUsers200Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  AdminSearchUsers200Response rebuild(
    void Function(AdminSearchUsers200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  AdminSearchUsers200ResponseBuilder toBuilder() =>
      AdminSearchUsers200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminSearchUsers200Response &&
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
    return (newBuiltValueToStringHelper(r'AdminSearchUsers200Response')
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class AdminSearchUsers200ResponseBuilder
    implements
        Builder<
          AdminSearchUsers200Response,
          AdminSearchUsers200ResponseBuilder
        >,
        ApiSuccessEnvelopeBuilder {
  _$AdminSearchUsers200Response? _$v;

  AdminUserSearchResponseDtoBuilder? _data;
  AdminUserSearchResponseDtoBuilder get data =>
      _$this._data ??= AdminUserSearchResponseDtoBuilder();
  set data(covariant AdminUserSearchResponseDtoBuilder? data) =>
      _$this._data = data;

  ApiSuccessEnvelopeCodeEnum? _code;
  ApiSuccessEnvelopeCodeEnum? get code => _$this._code;
  set code(covariant ApiSuccessEnvelopeCodeEnum? code) => _$this._code = code;

  String? _message;
  String? get message => _$this._message;
  set message(covariant String? message) => _$this._message = message;

  AdminSearchUsers200ResponseBuilder() {
    AdminSearchUsers200Response._defaults(this);
  }

  AdminSearchUsers200ResponseBuilder get _$this {
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
  void replace(covariant AdminSearchUsers200Response other) {
    _$v = other as _$AdminSearchUsers200Response;
  }

  @override
  void update(void Function(AdminSearchUsers200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AdminSearchUsers200Response build() => _build();

  _$AdminSearchUsers200Response _build() {
    _$AdminSearchUsers200Response _$result;
    try {
      _$result =
          _$v ??
          _$AdminSearchUsers200Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'AdminSearchUsers200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'AdminSearchUsers200Response',
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
          r'AdminSearchUsers200Response',
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
