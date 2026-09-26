// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_mobile_releases_detail200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const AdminMobileReleasesDetail200ResponseCodeEnum
_$adminMobileReleasesDetail200ResponseCodeEnum_number0 =
    const AdminMobileReleasesDetail200ResponseCodeEnum._('number0');
const AdminMobileReleasesDetail200ResponseCodeEnum
_$adminMobileReleasesDetail200ResponseCodeEnum_unknownDefaultOpenApi =
    const AdminMobileReleasesDetail200ResponseCodeEnum._(
      'unknownDefaultOpenApi',
    );

AdminMobileReleasesDetail200ResponseCodeEnum
_$adminMobileReleasesDetail200ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$adminMobileReleasesDetail200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$adminMobileReleasesDetail200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$adminMobileReleasesDetail200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<AdminMobileReleasesDetail200ResponseCodeEnum>
_$adminMobileReleasesDetail200ResponseCodeEnumValues =
    BuiltSet<AdminMobileReleasesDetail200ResponseCodeEnum>(
      const <AdminMobileReleasesDetail200ResponseCodeEnum>[
        _$adminMobileReleasesDetail200ResponseCodeEnum_number0,
        _$adminMobileReleasesDetail200ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<AdminMobileReleasesDetail200ResponseCodeEnum>
_$adminMobileReleasesDetail200ResponseCodeEnumSerializer =
    _$AdminMobileReleasesDetail200ResponseCodeEnumSerializer();

class _$AdminMobileReleasesDetail200ResponseCodeEnumSerializer
    implements
        PrimitiveSerializer<AdminMobileReleasesDetail200ResponseCodeEnum> {
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
    AdminMobileReleasesDetail200ResponseCodeEnum,
  ];
  @override
  final String wireName = 'AdminMobileReleasesDetail200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    AdminMobileReleasesDetail200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  AdminMobileReleasesDetail200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => AdminMobileReleasesDetail200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$AdminMobileReleasesDetail200Response
    extends AdminMobileReleasesDetail200Response {
  @override
  final AdminMobileReleaseDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$AdminMobileReleasesDetail200Response([
    void Function(AdminMobileReleasesDetail200ResponseBuilder)? updates,
  ]) =>
      (AdminMobileReleasesDetail200ResponseBuilder()..update(updates))._build();

  _$AdminMobileReleasesDetail200Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  AdminMobileReleasesDetail200Response rebuild(
    void Function(AdminMobileReleasesDetail200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  AdminMobileReleasesDetail200ResponseBuilder toBuilder() =>
      AdminMobileReleasesDetail200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminMobileReleasesDetail200Response &&
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
    return (newBuiltValueToStringHelper(r'AdminMobileReleasesDetail200Response')
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class AdminMobileReleasesDetail200ResponseBuilder
    implements
        Builder<
          AdminMobileReleasesDetail200Response,
          AdminMobileReleasesDetail200ResponseBuilder
        >,
        ApiSuccessEnvelopeBuilder {
  _$AdminMobileReleasesDetail200Response? _$v;

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

  AdminMobileReleasesDetail200ResponseBuilder() {
    AdminMobileReleasesDetail200Response._defaults(this);
  }

  AdminMobileReleasesDetail200ResponseBuilder get _$this {
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
  void replace(covariant AdminMobileReleasesDetail200Response other) {
    _$v = other as _$AdminMobileReleasesDetail200Response;
  }

  @override
  void update(
    void Function(AdminMobileReleasesDetail200ResponseBuilder)? updates,
  ) {
    if (updates != null) updates(this);
  }

  @override
  AdminMobileReleasesDetail200Response build() => _build();

  _$AdminMobileReleasesDetail200Response _build() {
    _$AdminMobileReleasesDetail200Response _$result;
    try {
      _$result =
          _$v ??
          _$AdminMobileReleasesDetail200Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'AdminMobileReleasesDetail200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'AdminMobileReleasesDetail200Response',
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
          r'AdminMobileReleasesDetail200Response',
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
