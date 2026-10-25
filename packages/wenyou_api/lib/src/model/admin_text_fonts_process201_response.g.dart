// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_text_fonts_process201_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const AdminTextFontsProcess201ResponseCodeEnum
_$adminTextFontsProcess201ResponseCodeEnum_number0 =
    const AdminTextFontsProcess201ResponseCodeEnum._('number0');
const AdminTextFontsProcess201ResponseCodeEnum
_$adminTextFontsProcess201ResponseCodeEnum_unknownDefaultOpenApi =
    const AdminTextFontsProcess201ResponseCodeEnum._('unknownDefaultOpenApi');

AdminTextFontsProcess201ResponseCodeEnum
_$adminTextFontsProcess201ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$adminTextFontsProcess201ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$adminTextFontsProcess201ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$adminTextFontsProcess201ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<AdminTextFontsProcess201ResponseCodeEnum>
_$adminTextFontsProcess201ResponseCodeEnumValues =
    BuiltSet<AdminTextFontsProcess201ResponseCodeEnum>(
      const <AdminTextFontsProcess201ResponseCodeEnum>[
        _$adminTextFontsProcess201ResponseCodeEnum_number0,
        _$adminTextFontsProcess201ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<AdminTextFontsProcess201ResponseCodeEnum>
_$adminTextFontsProcess201ResponseCodeEnumSerializer =
    _$AdminTextFontsProcess201ResponseCodeEnumSerializer();

class _$AdminTextFontsProcess201ResponseCodeEnumSerializer
    implements PrimitiveSerializer<AdminTextFontsProcess201ResponseCodeEnum> {
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
    AdminTextFontsProcess201ResponseCodeEnum,
  ];
  @override
  final String wireName = 'AdminTextFontsProcess201ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    AdminTextFontsProcess201ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  AdminTextFontsProcess201ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => AdminTextFontsProcess201ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$AdminTextFontsProcess201Response
    extends AdminTextFontsProcess201Response {
  @override
  final FontJobDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$AdminTextFontsProcess201Response([
    void Function(AdminTextFontsProcess201ResponseBuilder)? updates,
  ]) => (AdminTextFontsProcess201ResponseBuilder()..update(updates))._build();

  _$AdminTextFontsProcess201Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  AdminTextFontsProcess201Response rebuild(
    void Function(AdminTextFontsProcess201ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  AdminTextFontsProcess201ResponseBuilder toBuilder() =>
      AdminTextFontsProcess201ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminTextFontsProcess201Response &&
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
    return (newBuiltValueToStringHelper(r'AdminTextFontsProcess201Response')
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class AdminTextFontsProcess201ResponseBuilder
    implements
        Builder<
          AdminTextFontsProcess201Response,
          AdminTextFontsProcess201ResponseBuilder
        >,
        ApiSuccessEnvelopeBuilder {
  _$AdminTextFontsProcess201Response? _$v;

  FontJobDtoBuilder? _data;
  FontJobDtoBuilder get data => _$this._data ??= FontJobDtoBuilder();
  set data(covariant FontJobDtoBuilder? data) => _$this._data = data;

  ApiSuccessEnvelopeCodeEnum? _code;
  ApiSuccessEnvelopeCodeEnum? get code => _$this._code;
  set code(covariant ApiSuccessEnvelopeCodeEnum? code) => _$this._code = code;

  String? _message;
  String? get message => _$this._message;
  set message(covariant String? message) => _$this._message = message;

  AdminTextFontsProcess201ResponseBuilder() {
    AdminTextFontsProcess201Response._defaults(this);
  }

  AdminTextFontsProcess201ResponseBuilder get _$this {
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
  void replace(covariant AdminTextFontsProcess201Response other) {
    _$v = other as _$AdminTextFontsProcess201Response;
  }

  @override
  void update(void Function(AdminTextFontsProcess201ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AdminTextFontsProcess201Response build() => _build();

  _$AdminTextFontsProcess201Response _build() {
    _$AdminTextFontsProcess201Response _$result;
    try {
      _$result =
          _$v ??
          _$AdminTextFontsProcess201Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'AdminTextFontsProcess201Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'AdminTextFontsProcess201Response',
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
          r'AdminTextFontsProcess201Response',
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
