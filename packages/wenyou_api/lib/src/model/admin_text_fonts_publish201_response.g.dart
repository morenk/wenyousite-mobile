// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_text_fonts_publish201_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const AdminTextFontsPublish201ResponseCodeEnum
_$adminTextFontsPublish201ResponseCodeEnum_number0 =
    const AdminTextFontsPublish201ResponseCodeEnum._('number0');
const AdminTextFontsPublish201ResponseCodeEnum
_$adminTextFontsPublish201ResponseCodeEnum_unknownDefaultOpenApi =
    const AdminTextFontsPublish201ResponseCodeEnum._('unknownDefaultOpenApi');

AdminTextFontsPublish201ResponseCodeEnum
_$adminTextFontsPublish201ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$adminTextFontsPublish201ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$adminTextFontsPublish201ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$adminTextFontsPublish201ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<AdminTextFontsPublish201ResponseCodeEnum>
_$adminTextFontsPublish201ResponseCodeEnumValues =
    BuiltSet<AdminTextFontsPublish201ResponseCodeEnum>(
      const <AdminTextFontsPublish201ResponseCodeEnum>[
        _$adminTextFontsPublish201ResponseCodeEnum_number0,
        _$adminTextFontsPublish201ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<AdminTextFontsPublish201ResponseCodeEnum>
_$adminTextFontsPublish201ResponseCodeEnumSerializer =
    _$AdminTextFontsPublish201ResponseCodeEnumSerializer();

class _$AdminTextFontsPublish201ResponseCodeEnumSerializer
    implements PrimitiveSerializer<AdminTextFontsPublish201ResponseCodeEnum> {
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
    AdminTextFontsPublish201ResponseCodeEnum,
  ];
  @override
  final String wireName = 'AdminTextFontsPublish201ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    AdminTextFontsPublish201ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  AdminTextFontsPublish201ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => AdminTextFontsPublish201ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$AdminTextFontsPublish201Response
    extends AdminTextFontsPublish201Response {
  @override
  final FontFamilyDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$AdminTextFontsPublish201Response([
    void Function(AdminTextFontsPublish201ResponseBuilder)? updates,
  ]) => (AdminTextFontsPublish201ResponseBuilder()..update(updates))._build();

  _$AdminTextFontsPublish201Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  AdminTextFontsPublish201Response rebuild(
    void Function(AdminTextFontsPublish201ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  AdminTextFontsPublish201ResponseBuilder toBuilder() =>
      AdminTextFontsPublish201ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminTextFontsPublish201Response &&
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
    return (newBuiltValueToStringHelper(r'AdminTextFontsPublish201Response')
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class AdminTextFontsPublish201ResponseBuilder
    implements
        Builder<
          AdminTextFontsPublish201Response,
          AdminTextFontsPublish201ResponseBuilder
        >,
        ApiSuccessEnvelopeBuilder {
  _$AdminTextFontsPublish201Response? _$v;

  FontFamilyDtoBuilder? _data;
  FontFamilyDtoBuilder get data => _$this._data ??= FontFamilyDtoBuilder();
  set data(covariant FontFamilyDtoBuilder? data) => _$this._data = data;

  ApiSuccessEnvelopeCodeEnum? _code;
  ApiSuccessEnvelopeCodeEnum? get code => _$this._code;
  set code(covariant ApiSuccessEnvelopeCodeEnum? code) => _$this._code = code;

  String? _message;
  String? get message => _$this._message;
  set message(covariant String? message) => _$this._message = message;

  AdminTextFontsPublish201ResponseBuilder() {
    AdminTextFontsPublish201Response._defaults(this);
  }

  AdminTextFontsPublish201ResponseBuilder get _$this {
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
  void replace(covariant AdminTextFontsPublish201Response other) {
    _$v = other as _$AdminTextFontsPublish201Response;
  }

  @override
  void update(void Function(AdminTextFontsPublish201ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AdminTextFontsPublish201Response build() => _build();

  _$AdminTextFontsPublish201Response _build() {
    _$AdminTextFontsPublish201Response _$result;
    try {
      _$result =
          _$v ??
          _$AdminTextFontsPublish201Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'AdminTextFontsPublish201Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'AdminTextFontsPublish201Response',
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
          r'AdminTextFontsPublish201Response',
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
