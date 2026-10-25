// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_text_fonts_get_job200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const AdminTextFontsGetJob200ResponseCodeEnum
_$adminTextFontsGetJob200ResponseCodeEnum_number0 =
    const AdminTextFontsGetJob200ResponseCodeEnum._('number0');
const AdminTextFontsGetJob200ResponseCodeEnum
_$adminTextFontsGetJob200ResponseCodeEnum_unknownDefaultOpenApi =
    const AdminTextFontsGetJob200ResponseCodeEnum._('unknownDefaultOpenApi');

AdminTextFontsGetJob200ResponseCodeEnum
_$adminTextFontsGetJob200ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$adminTextFontsGetJob200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$adminTextFontsGetJob200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$adminTextFontsGetJob200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<AdminTextFontsGetJob200ResponseCodeEnum>
_$adminTextFontsGetJob200ResponseCodeEnumValues =
    BuiltSet<AdminTextFontsGetJob200ResponseCodeEnum>(
      const <AdminTextFontsGetJob200ResponseCodeEnum>[
        _$adminTextFontsGetJob200ResponseCodeEnum_number0,
        _$adminTextFontsGetJob200ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<AdminTextFontsGetJob200ResponseCodeEnum>
_$adminTextFontsGetJob200ResponseCodeEnumSerializer =
    _$AdminTextFontsGetJob200ResponseCodeEnumSerializer();

class _$AdminTextFontsGetJob200ResponseCodeEnumSerializer
    implements PrimitiveSerializer<AdminTextFontsGetJob200ResponseCodeEnum> {
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
    AdminTextFontsGetJob200ResponseCodeEnum,
  ];
  @override
  final String wireName = 'AdminTextFontsGetJob200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    AdminTextFontsGetJob200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  AdminTextFontsGetJob200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => AdminTextFontsGetJob200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$AdminTextFontsGetJob200Response
    extends AdminTextFontsGetJob200Response {
  @override
  final FontJobDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$AdminTextFontsGetJob200Response([
    void Function(AdminTextFontsGetJob200ResponseBuilder)? updates,
  ]) => (AdminTextFontsGetJob200ResponseBuilder()..update(updates))._build();

  _$AdminTextFontsGetJob200Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  AdminTextFontsGetJob200Response rebuild(
    void Function(AdminTextFontsGetJob200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  AdminTextFontsGetJob200ResponseBuilder toBuilder() =>
      AdminTextFontsGetJob200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminTextFontsGetJob200Response &&
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
    return (newBuiltValueToStringHelper(r'AdminTextFontsGetJob200Response')
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class AdminTextFontsGetJob200ResponseBuilder
    implements
        Builder<
          AdminTextFontsGetJob200Response,
          AdminTextFontsGetJob200ResponseBuilder
        >,
        ApiSuccessEnvelopeBuilder {
  _$AdminTextFontsGetJob200Response? _$v;

  FontJobDtoBuilder? _data;
  FontJobDtoBuilder get data => _$this._data ??= FontJobDtoBuilder();
  set data(covariant FontJobDtoBuilder? data) => _$this._data = data;

  ApiSuccessEnvelopeCodeEnum? _code;
  ApiSuccessEnvelopeCodeEnum? get code => _$this._code;
  set code(covariant ApiSuccessEnvelopeCodeEnum? code) => _$this._code = code;

  String? _message;
  String? get message => _$this._message;
  set message(covariant String? message) => _$this._message = message;

  AdminTextFontsGetJob200ResponseBuilder() {
    AdminTextFontsGetJob200Response._defaults(this);
  }

  AdminTextFontsGetJob200ResponseBuilder get _$this {
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
  void replace(covariant AdminTextFontsGetJob200Response other) {
    _$v = other as _$AdminTextFontsGetJob200Response;
  }

  @override
  void update(void Function(AdminTextFontsGetJob200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AdminTextFontsGetJob200Response build() => _build();

  _$AdminTextFontsGetJob200Response _build() {
    _$AdminTextFontsGetJob200Response _$result;
    try {
      _$result =
          _$v ??
          _$AdminTextFontsGetJob200Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'AdminTextFontsGetJob200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'AdminTextFontsGetJob200Response',
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
          r'AdminTextFontsGetJob200Response',
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
