// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_content_detail200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const AdminContentDetail200ResponseCodeEnum
_$adminContentDetail200ResponseCodeEnum_number0 =
    const AdminContentDetail200ResponseCodeEnum._('number0');
const AdminContentDetail200ResponseCodeEnum
_$adminContentDetail200ResponseCodeEnum_unknownDefaultOpenApi =
    const AdminContentDetail200ResponseCodeEnum._('unknownDefaultOpenApi');

AdminContentDetail200ResponseCodeEnum
_$adminContentDetail200ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$adminContentDetail200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$adminContentDetail200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$adminContentDetail200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<AdminContentDetail200ResponseCodeEnum>
_$adminContentDetail200ResponseCodeEnumValues =
    BuiltSet<AdminContentDetail200ResponseCodeEnum>(
      const <AdminContentDetail200ResponseCodeEnum>[
        _$adminContentDetail200ResponseCodeEnum_number0,
        _$adminContentDetail200ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<AdminContentDetail200ResponseCodeEnum>
_$adminContentDetail200ResponseCodeEnumSerializer =
    _$AdminContentDetail200ResponseCodeEnumSerializer();

class _$AdminContentDetail200ResponseCodeEnumSerializer
    implements PrimitiveSerializer<AdminContentDetail200ResponseCodeEnum> {
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
    AdminContentDetail200ResponseCodeEnum,
  ];
  @override
  final String wireName = 'AdminContentDetail200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    AdminContentDetail200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  AdminContentDetail200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => AdminContentDetail200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$AdminContentDetail200Response extends AdminContentDetail200Response {
  @override
  final AdminContentDetailResponseDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$AdminContentDetail200Response([
    void Function(AdminContentDetail200ResponseBuilder)? updates,
  ]) => (AdminContentDetail200ResponseBuilder()..update(updates))._build();

  _$AdminContentDetail200Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  AdminContentDetail200Response rebuild(
    void Function(AdminContentDetail200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  AdminContentDetail200ResponseBuilder toBuilder() =>
      AdminContentDetail200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminContentDetail200Response &&
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
    return (newBuiltValueToStringHelper(r'AdminContentDetail200Response')
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class AdminContentDetail200ResponseBuilder
    implements
        Builder<
          AdminContentDetail200Response,
          AdminContentDetail200ResponseBuilder
        >,
        ApiSuccessEnvelopeBuilder {
  _$AdminContentDetail200Response? _$v;

  AdminContentDetailResponseDtoBuilder? _data;
  AdminContentDetailResponseDtoBuilder get data =>
      _$this._data ??= AdminContentDetailResponseDtoBuilder();
  set data(covariant AdminContentDetailResponseDtoBuilder? data) =>
      _$this._data = data;

  ApiSuccessEnvelopeCodeEnum? _code;
  ApiSuccessEnvelopeCodeEnum? get code => _$this._code;
  set code(covariant ApiSuccessEnvelopeCodeEnum? code) => _$this._code = code;

  String? _message;
  String? get message => _$this._message;
  set message(covariant String? message) => _$this._message = message;

  AdminContentDetail200ResponseBuilder() {
    AdminContentDetail200Response._defaults(this);
  }

  AdminContentDetail200ResponseBuilder get _$this {
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
  void replace(covariant AdminContentDetail200Response other) {
    _$v = other as _$AdminContentDetail200Response;
  }

  @override
  void update(void Function(AdminContentDetail200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AdminContentDetail200Response build() => _build();

  _$AdminContentDetail200Response _build() {
    _$AdminContentDetail200Response _$result;
    try {
      _$result =
          _$v ??
          _$AdminContentDetail200Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'AdminContentDetail200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'AdminContentDetail200Response',
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
          r'AdminContentDetail200Response',
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
