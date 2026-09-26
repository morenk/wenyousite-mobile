// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_mobile_releases_update200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const AdminMobileReleasesUpdate200ResponseCodeEnum
_$adminMobileReleasesUpdate200ResponseCodeEnum_number0 =
    const AdminMobileReleasesUpdate200ResponseCodeEnum._('number0');
const AdminMobileReleasesUpdate200ResponseCodeEnum
_$adminMobileReleasesUpdate200ResponseCodeEnum_unknownDefaultOpenApi =
    const AdminMobileReleasesUpdate200ResponseCodeEnum._(
      'unknownDefaultOpenApi',
    );

AdminMobileReleasesUpdate200ResponseCodeEnum
_$adminMobileReleasesUpdate200ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$adminMobileReleasesUpdate200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$adminMobileReleasesUpdate200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$adminMobileReleasesUpdate200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<AdminMobileReleasesUpdate200ResponseCodeEnum>
_$adminMobileReleasesUpdate200ResponseCodeEnumValues =
    BuiltSet<AdminMobileReleasesUpdate200ResponseCodeEnum>(
      const <AdminMobileReleasesUpdate200ResponseCodeEnum>[
        _$adminMobileReleasesUpdate200ResponseCodeEnum_number0,
        _$adminMobileReleasesUpdate200ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<AdminMobileReleasesUpdate200ResponseCodeEnum>
_$adminMobileReleasesUpdate200ResponseCodeEnumSerializer =
    _$AdminMobileReleasesUpdate200ResponseCodeEnumSerializer();

class _$AdminMobileReleasesUpdate200ResponseCodeEnumSerializer
    implements
        PrimitiveSerializer<AdminMobileReleasesUpdate200ResponseCodeEnum> {
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
    AdminMobileReleasesUpdate200ResponseCodeEnum,
  ];
  @override
  final String wireName = 'AdminMobileReleasesUpdate200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    AdminMobileReleasesUpdate200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  AdminMobileReleasesUpdate200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => AdminMobileReleasesUpdate200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$AdminMobileReleasesUpdate200Response
    extends AdminMobileReleasesUpdate200Response {
  @override
  final AdminMobileReleaseDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$AdminMobileReleasesUpdate200Response([
    void Function(AdminMobileReleasesUpdate200ResponseBuilder)? updates,
  ]) =>
      (AdminMobileReleasesUpdate200ResponseBuilder()..update(updates))._build();

  _$AdminMobileReleasesUpdate200Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  AdminMobileReleasesUpdate200Response rebuild(
    void Function(AdminMobileReleasesUpdate200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  AdminMobileReleasesUpdate200ResponseBuilder toBuilder() =>
      AdminMobileReleasesUpdate200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminMobileReleasesUpdate200Response &&
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
    return (newBuiltValueToStringHelper(r'AdminMobileReleasesUpdate200Response')
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class AdminMobileReleasesUpdate200ResponseBuilder
    implements
        Builder<
          AdminMobileReleasesUpdate200Response,
          AdminMobileReleasesUpdate200ResponseBuilder
        >,
        ApiSuccessEnvelopeBuilder {
  _$AdminMobileReleasesUpdate200Response? _$v;

  AdminMobileReleaseDtoBuilder? _data;
  AdminMobileReleaseDtoBuilder get data =>
      _$this._data ??= AdminMobileReleaseDtoBuilder();
  set data(covariant AdminMobileReleaseDtoBuilder? data) => _$this._data = data;

  ApiSuccessEnvelopeCodeEnum? _code;
  ApiSuccessEnvelopeCodeEnum? get code => _$this._code;
  set code(covariant ApiSuccessEnvelopeCodeEnum? code) => _$this._code = code;

  String? _message;
  String? get message => _$this._message;
  set message(covariant String? message) => _$this._message = message;

  AdminMobileReleasesUpdate200ResponseBuilder() {
    AdminMobileReleasesUpdate200Response._defaults(this);
  }

  AdminMobileReleasesUpdate200ResponseBuilder get _$this {
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
  void replace(covariant AdminMobileReleasesUpdate200Response other) {
    _$v = other as _$AdminMobileReleasesUpdate200Response;
  }

  @override
  void update(
    void Function(AdminMobileReleasesUpdate200ResponseBuilder)? updates,
  ) {
    if (updates != null) updates(this);
  }

  @override
  AdminMobileReleasesUpdate200Response build() => _build();

  _$AdminMobileReleasesUpdate200Response _build() {
    _$AdminMobileReleasesUpdate200Response _$result;
    try {
      _$result =
          _$v ??
          _$AdminMobileReleasesUpdate200Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'AdminMobileReleasesUpdate200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'AdminMobileReleasesUpdate200Response',
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
          r'AdminMobileReleasesUpdate200Response',
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
