// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_text_fonts_upload201_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const AdminTextFontsUpload201ResponseCodeEnum
_$adminTextFontsUpload201ResponseCodeEnum_number0 =
    const AdminTextFontsUpload201ResponseCodeEnum._('number0');
const AdminTextFontsUpload201ResponseCodeEnum
_$adminTextFontsUpload201ResponseCodeEnum_unknownDefaultOpenApi =
    const AdminTextFontsUpload201ResponseCodeEnum._('unknownDefaultOpenApi');

AdminTextFontsUpload201ResponseCodeEnum
_$adminTextFontsUpload201ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$adminTextFontsUpload201ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$adminTextFontsUpload201ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$adminTextFontsUpload201ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<AdminTextFontsUpload201ResponseCodeEnum>
_$adminTextFontsUpload201ResponseCodeEnumValues =
    BuiltSet<AdminTextFontsUpload201ResponseCodeEnum>(
      const <AdminTextFontsUpload201ResponseCodeEnum>[
        _$adminTextFontsUpload201ResponseCodeEnum_number0,
        _$adminTextFontsUpload201ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<AdminTextFontsUpload201ResponseCodeEnum>
_$adminTextFontsUpload201ResponseCodeEnumSerializer =
    _$AdminTextFontsUpload201ResponseCodeEnumSerializer();

class _$AdminTextFontsUpload201ResponseCodeEnumSerializer
    implements PrimitiveSerializer<AdminTextFontsUpload201ResponseCodeEnum> {
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
    AdminTextFontsUpload201ResponseCodeEnum,
  ];
  @override
  final String wireName = 'AdminTextFontsUpload201ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    AdminTextFontsUpload201ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  AdminTextFontsUpload201ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => AdminTextFontsUpload201ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$AdminTextFontsUpload201Response
    extends AdminTextFontsUpload201Response {
  @override
  final FontJobDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$AdminTextFontsUpload201Response([
    void Function(AdminTextFontsUpload201ResponseBuilder)? updates,
  ]) => (AdminTextFontsUpload201ResponseBuilder()..update(updates))._build();

  _$AdminTextFontsUpload201Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  AdminTextFontsUpload201Response rebuild(
    void Function(AdminTextFontsUpload201ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  AdminTextFontsUpload201ResponseBuilder toBuilder() =>
      AdminTextFontsUpload201ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminTextFontsUpload201Response &&
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
    return (newBuiltValueToStringHelper(r'AdminTextFontsUpload201Response')
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class AdminTextFontsUpload201ResponseBuilder
    implements
        Builder<
          AdminTextFontsUpload201Response,
          AdminTextFontsUpload201ResponseBuilder
        >,
        ApiSuccessEnvelopeBuilder {
  _$AdminTextFontsUpload201Response? _$v;

  FontJobDtoBuilder? _data;
  FontJobDtoBuilder get data => _$this._data ??= FontJobDtoBuilder();
  set data(covariant FontJobDtoBuilder? data) => _$this._data = data;

  ApiSuccessEnvelopeCodeEnum? _code;
  ApiSuccessEnvelopeCodeEnum? get code => _$this._code;
  set code(covariant ApiSuccessEnvelopeCodeEnum? code) => _$this._code = code;

  String? _message;
  String? get message => _$this._message;
  set message(covariant String? message) => _$this._message = message;

  AdminTextFontsUpload201ResponseBuilder() {
    AdminTextFontsUpload201Response._defaults(this);
  }

  AdminTextFontsUpload201ResponseBuilder get _$this {
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
  void replace(covariant AdminTextFontsUpload201Response other) {
    _$v = other as _$AdminTextFontsUpload201Response;
  }

  @override
  void update(void Function(AdminTextFontsUpload201ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AdminTextFontsUpload201Response build() => _build();

  _$AdminTextFontsUpload201Response _build() {
    _$AdminTextFontsUpload201Response _$result;
    try {
      _$result =
          _$v ??
          _$AdminTextFontsUpload201Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'AdminTextFontsUpload201Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'AdminTextFontsUpload201Response',
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
          r'AdminTextFontsUpload201Response',
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
