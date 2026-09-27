// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_mobile_releases_create201_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const AdminMobileReleasesCreate201ResponseCodeEnum
_$adminMobileReleasesCreate201ResponseCodeEnum_number0 =
    const AdminMobileReleasesCreate201ResponseCodeEnum._('number0');
const AdminMobileReleasesCreate201ResponseCodeEnum
_$adminMobileReleasesCreate201ResponseCodeEnum_unknownDefaultOpenApi =
    const AdminMobileReleasesCreate201ResponseCodeEnum._(
      'unknownDefaultOpenApi',
    );

AdminMobileReleasesCreate201ResponseCodeEnum
_$adminMobileReleasesCreate201ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$adminMobileReleasesCreate201ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$adminMobileReleasesCreate201ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$adminMobileReleasesCreate201ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<AdminMobileReleasesCreate201ResponseCodeEnum>
_$adminMobileReleasesCreate201ResponseCodeEnumValues =
    BuiltSet<AdminMobileReleasesCreate201ResponseCodeEnum>(
      const <AdminMobileReleasesCreate201ResponseCodeEnum>[
        _$adminMobileReleasesCreate201ResponseCodeEnum_number0,
        _$adminMobileReleasesCreate201ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<AdminMobileReleasesCreate201ResponseCodeEnum>
_$adminMobileReleasesCreate201ResponseCodeEnumSerializer =
    _$AdminMobileReleasesCreate201ResponseCodeEnumSerializer();

class _$AdminMobileReleasesCreate201ResponseCodeEnumSerializer
    implements
        PrimitiveSerializer<AdminMobileReleasesCreate201ResponseCodeEnum> {
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
    AdminMobileReleasesCreate201ResponseCodeEnum,
  ];
  @override
  final String wireName = 'AdminMobileReleasesCreate201ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    AdminMobileReleasesCreate201ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  AdminMobileReleasesCreate201ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => AdminMobileReleasesCreate201ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$AdminMobileReleasesCreate201Response
    extends AdminMobileReleasesCreate201Response {
  @override
  final AdminMobileReleaseDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$AdminMobileReleasesCreate201Response([
    void Function(AdminMobileReleasesCreate201ResponseBuilder)? updates,
  ]) =>
      (AdminMobileReleasesCreate201ResponseBuilder()..update(updates))._build();

  _$AdminMobileReleasesCreate201Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  AdminMobileReleasesCreate201Response rebuild(
    void Function(AdminMobileReleasesCreate201ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  AdminMobileReleasesCreate201ResponseBuilder toBuilder() =>
      AdminMobileReleasesCreate201ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminMobileReleasesCreate201Response &&
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
    return (newBuiltValueToStringHelper(r'AdminMobileReleasesCreate201Response')
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class AdminMobileReleasesCreate201ResponseBuilder
    implements
        Builder<
          AdminMobileReleasesCreate201Response,
          AdminMobileReleasesCreate201ResponseBuilder
        >,
        ApiSuccessEnvelopeBuilder {
  _$AdminMobileReleasesCreate201Response? _$v;

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

  AdminMobileReleasesCreate201ResponseBuilder() {
    AdminMobileReleasesCreate201Response._defaults(this);
  }

  AdminMobileReleasesCreate201ResponseBuilder get _$this {
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
  void replace(covariant AdminMobileReleasesCreate201Response other) {
    _$v = other as _$AdminMobileReleasesCreate201Response;
  }

  @override
  void update(
    void Function(AdminMobileReleasesCreate201ResponseBuilder)? updates,
  ) {
    if (updates != null) updates(this);
  }

  @override
  AdminMobileReleasesCreate201Response build() => _build();

  _$AdminMobileReleasesCreate201Response _build() {
    _$AdminMobileReleasesCreate201Response _$result;
    try {
      _$result =
          _$v ??
          _$AdminMobileReleasesCreate201Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'AdminMobileReleasesCreate201Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'AdminMobileReleasesCreate201Response',
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
          r'AdminMobileReleasesCreate201Response',
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
