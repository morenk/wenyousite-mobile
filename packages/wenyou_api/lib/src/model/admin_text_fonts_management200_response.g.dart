// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_text_fonts_management200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const AdminTextFontsManagement200ResponseCodeEnum
_$adminTextFontsManagement200ResponseCodeEnum_number0 =
    const AdminTextFontsManagement200ResponseCodeEnum._('number0');
const AdminTextFontsManagement200ResponseCodeEnum
_$adminTextFontsManagement200ResponseCodeEnum_unknownDefaultOpenApi =
    const AdminTextFontsManagement200ResponseCodeEnum._(
      'unknownDefaultOpenApi',
    );

AdminTextFontsManagement200ResponseCodeEnum
_$adminTextFontsManagement200ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$adminTextFontsManagement200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$adminTextFontsManagement200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$adminTextFontsManagement200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<AdminTextFontsManagement200ResponseCodeEnum>
_$adminTextFontsManagement200ResponseCodeEnumValues =
    BuiltSet<AdminTextFontsManagement200ResponseCodeEnum>(
      const <AdminTextFontsManagement200ResponseCodeEnum>[
        _$adminTextFontsManagement200ResponseCodeEnum_number0,
        _$adminTextFontsManagement200ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<AdminTextFontsManagement200ResponseCodeEnum>
_$adminTextFontsManagement200ResponseCodeEnumSerializer =
    _$AdminTextFontsManagement200ResponseCodeEnumSerializer();

class _$AdminTextFontsManagement200ResponseCodeEnumSerializer
    implements
        PrimitiveSerializer<AdminTextFontsManagement200ResponseCodeEnum> {
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
    AdminTextFontsManagement200ResponseCodeEnum,
  ];
  @override
  final String wireName = 'AdminTextFontsManagement200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    AdminTextFontsManagement200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  AdminTextFontsManagement200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => AdminTextFontsManagement200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$AdminTextFontsManagement200Response
    extends AdminTextFontsManagement200Response {
  @override
  final FontManagementPageDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$AdminTextFontsManagement200Response([
    void Function(AdminTextFontsManagement200ResponseBuilder)? updates,
  ]) =>
      (AdminTextFontsManagement200ResponseBuilder()..update(updates))._build();

  _$AdminTextFontsManagement200Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  AdminTextFontsManagement200Response rebuild(
    void Function(AdminTextFontsManagement200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  AdminTextFontsManagement200ResponseBuilder toBuilder() =>
      AdminTextFontsManagement200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminTextFontsManagement200Response &&
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
    return (newBuiltValueToStringHelper(r'AdminTextFontsManagement200Response')
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class AdminTextFontsManagement200ResponseBuilder
    implements
        Builder<
          AdminTextFontsManagement200Response,
          AdminTextFontsManagement200ResponseBuilder
        >,
        ApiSuccessEnvelopeBuilder {
  _$AdminTextFontsManagement200Response? _$v;

  FontManagementPageDtoBuilder? _data;
  FontManagementPageDtoBuilder get data =>
      _$this._data ??= FontManagementPageDtoBuilder();
  set data(covariant FontManagementPageDtoBuilder? data) => _$this._data = data;

  ApiSuccessEnvelopeCodeEnum? _code;
  ApiSuccessEnvelopeCodeEnum? get code => _$this._code;
  set code(covariant ApiSuccessEnvelopeCodeEnum? code) => _$this._code = code;

  String? _message;
  String? get message => _$this._message;
  set message(covariant String? message) => _$this._message = message;

  AdminTextFontsManagement200ResponseBuilder() {
    AdminTextFontsManagement200Response._defaults(this);
  }

  AdminTextFontsManagement200ResponseBuilder get _$this {
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
  void replace(covariant AdminTextFontsManagement200Response other) {
    _$v = other as _$AdminTextFontsManagement200Response;
  }

  @override
  void update(
    void Function(AdminTextFontsManagement200ResponseBuilder)? updates,
  ) {
    if (updates != null) updates(this);
  }

  @override
  AdminTextFontsManagement200Response build() => _build();

  _$AdminTextFontsManagement200Response _build() {
    _$AdminTextFontsManagement200Response _$result;
    try {
      _$result =
          _$v ??
          _$AdminTextFontsManagement200Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'AdminTextFontsManagement200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'AdminTextFontsManagement200Response',
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
          r'AdminTextFontsManagement200Response',
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
