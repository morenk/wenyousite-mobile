// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_text_fonts_create201_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const AdminTextFontsCreate201ResponseCodeEnum
_$adminTextFontsCreate201ResponseCodeEnum_number0 =
    const AdminTextFontsCreate201ResponseCodeEnum._('number0');
const AdminTextFontsCreate201ResponseCodeEnum
_$adminTextFontsCreate201ResponseCodeEnum_unknownDefaultOpenApi =
    const AdminTextFontsCreate201ResponseCodeEnum._('unknownDefaultOpenApi');

AdminTextFontsCreate201ResponseCodeEnum
_$adminTextFontsCreate201ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$adminTextFontsCreate201ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$adminTextFontsCreate201ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$adminTextFontsCreate201ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<AdminTextFontsCreate201ResponseCodeEnum>
_$adminTextFontsCreate201ResponseCodeEnumValues =
    BuiltSet<AdminTextFontsCreate201ResponseCodeEnum>(
      const <AdminTextFontsCreate201ResponseCodeEnum>[
        _$adminTextFontsCreate201ResponseCodeEnum_number0,
        _$adminTextFontsCreate201ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<AdminTextFontsCreate201ResponseCodeEnum>
_$adminTextFontsCreate201ResponseCodeEnumSerializer =
    _$AdminTextFontsCreate201ResponseCodeEnumSerializer();

class _$AdminTextFontsCreate201ResponseCodeEnumSerializer
    implements PrimitiveSerializer<AdminTextFontsCreate201ResponseCodeEnum> {
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
    AdminTextFontsCreate201ResponseCodeEnum,
  ];
  @override
  final String wireName = 'AdminTextFontsCreate201ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    AdminTextFontsCreate201ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  AdminTextFontsCreate201ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => AdminTextFontsCreate201ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$AdminTextFontsCreate201Response
    extends AdminTextFontsCreate201Response {
  @override
  final FontFamilyDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$AdminTextFontsCreate201Response([
    void Function(AdminTextFontsCreate201ResponseBuilder)? updates,
  ]) => (AdminTextFontsCreate201ResponseBuilder()..update(updates))._build();

  _$AdminTextFontsCreate201Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  AdminTextFontsCreate201Response rebuild(
    void Function(AdminTextFontsCreate201ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  AdminTextFontsCreate201ResponseBuilder toBuilder() =>
      AdminTextFontsCreate201ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminTextFontsCreate201Response &&
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
    return (newBuiltValueToStringHelper(r'AdminTextFontsCreate201Response')
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class AdminTextFontsCreate201ResponseBuilder
    implements
        Builder<
          AdminTextFontsCreate201Response,
          AdminTextFontsCreate201ResponseBuilder
        >,
        ApiSuccessEnvelopeBuilder {
  _$AdminTextFontsCreate201Response? _$v;

  FontFamilyDtoBuilder? _data;
  FontFamilyDtoBuilder get data => _$this._data ??= FontFamilyDtoBuilder();
  set data(covariant FontFamilyDtoBuilder? data) => _$this._data = data;

  ApiSuccessEnvelopeCodeEnum? _code;
  ApiSuccessEnvelopeCodeEnum? get code => _$this._code;
  set code(covariant ApiSuccessEnvelopeCodeEnum? code) => _$this._code = code;

  String? _message;
  String? get message => _$this._message;
  set message(covariant String? message) => _$this._message = message;

  AdminTextFontsCreate201ResponseBuilder() {
    AdminTextFontsCreate201Response._defaults(this);
  }

  AdminTextFontsCreate201ResponseBuilder get _$this {
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
  void replace(covariant AdminTextFontsCreate201Response other) {
    _$v = other as _$AdminTextFontsCreate201Response;
  }

  @override
  void update(void Function(AdminTextFontsCreate201ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AdminTextFontsCreate201Response build() => _build();

  _$AdminTextFontsCreate201Response _build() {
    _$AdminTextFontsCreate201Response _$result;
    try {
      _$result =
          _$v ??
          _$AdminTextFontsCreate201Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'AdminTextFontsCreate201Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'AdminTextFontsCreate201Response',
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
          r'AdminTextFontsCreate201Response',
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
