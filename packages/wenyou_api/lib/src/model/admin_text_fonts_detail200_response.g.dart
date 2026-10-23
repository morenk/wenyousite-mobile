// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_text_fonts_detail200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const AdminTextFontsDetail200ResponseCodeEnum
_$adminTextFontsDetail200ResponseCodeEnum_number0 =
    const AdminTextFontsDetail200ResponseCodeEnum._('number0');
const AdminTextFontsDetail200ResponseCodeEnum
_$adminTextFontsDetail200ResponseCodeEnum_unknownDefaultOpenApi =
    const AdminTextFontsDetail200ResponseCodeEnum._('unknownDefaultOpenApi');

AdminTextFontsDetail200ResponseCodeEnum
_$adminTextFontsDetail200ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$adminTextFontsDetail200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$adminTextFontsDetail200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$adminTextFontsDetail200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<AdminTextFontsDetail200ResponseCodeEnum>
_$adminTextFontsDetail200ResponseCodeEnumValues =
    BuiltSet<AdminTextFontsDetail200ResponseCodeEnum>(
      const <AdminTextFontsDetail200ResponseCodeEnum>[
        _$adminTextFontsDetail200ResponseCodeEnum_number0,
        _$adminTextFontsDetail200ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<AdminTextFontsDetail200ResponseCodeEnum>
_$adminTextFontsDetail200ResponseCodeEnumSerializer =
    _$AdminTextFontsDetail200ResponseCodeEnumSerializer();

class _$AdminTextFontsDetail200ResponseCodeEnumSerializer
    implements PrimitiveSerializer<AdminTextFontsDetail200ResponseCodeEnum> {
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
    AdminTextFontsDetail200ResponseCodeEnum,
  ];
  @override
  final String wireName = 'AdminTextFontsDetail200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    AdminTextFontsDetail200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  AdminTextFontsDetail200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => AdminTextFontsDetail200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$AdminTextFontsDetail200Response
    extends AdminTextFontsDetail200Response {
  @override
  final FontAdminFamilyDetailDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$AdminTextFontsDetail200Response([
    void Function(AdminTextFontsDetail200ResponseBuilder)? updates,
  ]) => (AdminTextFontsDetail200ResponseBuilder()..update(updates))._build();

  _$AdminTextFontsDetail200Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  AdminTextFontsDetail200Response rebuild(
    void Function(AdminTextFontsDetail200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  AdminTextFontsDetail200ResponseBuilder toBuilder() =>
      AdminTextFontsDetail200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminTextFontsDetail200Response &&
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
    return (newBuiltValueToStringHelper(r'AdminTextFontsDetail200Response')
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class AdminTextFontsDetail200ResponseBuilder
    implements
        Builder<
          AdminTextFontsDetail200Response,
          AdminTextFontsDetail200ResponseBuilder
        >,
        ApiSuccessEnvelopeBuilder {
  _$AdminTextFontsDetail200Response? _$v;

  FontAdminFamilyDetailDtoBuilder? _data;
  FontAdminFamilyDetailDtoBuilder get data =>
      _$this._data ??= FontAdminFamilyDetailDtoBuilder();
  set data(covariant FontAdminFamilyDetailDtoBuilder? data) =>
      _$this._data = data;

  ApiSuccessEnvelopeCodeEnum? _code;
  ApiSuccessEnvelopeCodeEnum? get code => _$this._code;
  set code(covariant ApiSuccessEnvelopeCodeEnum? code) => _$this._code = code;

  String? _message;
  String? get message => _$this._message;
  set message(covariant String? message) => _$this._message = message;

  AdminTextFontsDetail200ResponseBuilder() {
    AdminTextFontsDetail200Response._defaults(this);
  }

  AdminTextFontsDetail200ResponseBuilder get _$this {
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
  void replace(covariant AdminTextFontsDetail200Response other) {
    _$v = other as _$AdminTextFontsDetail200Response;
  }

  @override
  void update(void Function(AdminTextFontsDetail200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AdminTextFontsDetail200Response build() => _build();

  _$AdminTextFontsDetail200Response _build() {
    _$AdminTextFontsDetail200Response _$result;
    try {
      _$result =
          _$v ??
          _$AdminTextFontsDetail200Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'AdminTextFontsDetail200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'AdminTextFontsDetail200Response',
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
          r'AdminTextFontsDetail200Response',
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
