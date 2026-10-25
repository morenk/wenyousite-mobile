// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_text_fonts_withdraw201_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const AdminTextFontsWithdraw201ResponseCodeEnum
_$adminTextFontsWithdraw201ResponseCodeEnum_number0 =
    const AdminTextFontsWithdraw201ResponseCodeEnum._('number0');
const AdminTextFontsWithdraw201ResponseCodeEnum
_$adminTextFontsWithdraw201ResponseCodeEnum_unknownDefaultOpenApi =
    const AdminTextFontsWithdraw201ResponseCodeEnum._('unknownDefaultOpenApi');

AdminTextFontsWithdraw201ResponseCodeEnum
_$adminTextFontsWithdraw201ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$adminTextFontsWithdraw201ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$adminTextFontsWithdraw201ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$adminTextFontsWithdraw201ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<AdminTextFontsWithdraw201ResponseCodeEnum>
_$adminTextFontsWithdraw201ResponseCodeEnumValues =
    BuiltSet<AdminTextFontsWithdraw201ResponseCodeEnum>(
      const <AdminTextFontsWithdraw201ResponseCodeEnum>[
        _$adminTextFontsWithdraw201ResponseCodeEnum_number0,
        _$adminTextFontsWithdraw201ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<AdminTextFontsWithdraw201ResponseCodeEnum>
_$adminTextFontsWithdraw201ResponseCodeEnumSerializer =
    _$AdminTextFontsWithdraw201ResponseCodeEnumSerializer();

class _$AdminTextFontsWithdraw201ResponseCodeEnumSerializer
    implements PrimitiveSerializer<AdminTextFontsWithdraw201ResponseCodeEnum> {
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
    AdminTextFontsWithdraw201ResponseCodeEnum,
  ];
  @override
  final String wireName = 'AdminTextFontsWithdraw201ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    AdminTextFontsWithdraw201ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  AdminTextFontsWithdraw201ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => AdminTextFontsWithdraw201ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$AdminTextFontsWithdraw201Response
    extends AdminTextFontsWithdraw201Response {
  @override
  final FontVersionDescriptorDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$AdminTextFontsWithdraw201Response([
    void Function(AdminTextFontsWithdraw201ResponseBuilder)? updates,
  ]) => (AdminTextFontsWithdraw201ResponseBuilder()..update(updates))._build();

  _$AdminTextFontsWithdraw201Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  AdminTextFontsWithdraw201Response rebuild(
    void Function(AdminTextFontsWithdraw201ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  AdminTextFontsWithdraw201ResponseBuilder toBuilder() =>
      AdminTextFontsWithdraw201ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminTextFontsWithdraw201Response &&
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
    return (newBuiltValueToStringHelper(r'AdminTextFontsWithdraw201Response')
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class AdminTextFontsWithdraw201ResponseBuilder
    implements
        Builder<
          AdminTextFontsWithdraw201Response,
          AdminTextFontsWithdraw201ResponseBuilder
        >,
        ApiSuccessEnvelopeBuilder {
  _$AdminTextFontsWithdraw201Response? _$v;

  FontVersionDescriptorDtoBuilder? _data;
  FontVersionDescriptorDtoBuilder get data =>
      _$this._data ??= FontVersionDescriptorDtoBuilder();
  set data(covariant FontVersionDescriptorDtoBuilder? data) =>
      _$this._data = data;

  ApiSuccessEnvelopeCodeEnum? _code;
  ApiSuccessEnvelopeCodeEnum? get code => _$this._code;
  set code(covariant ApiSuccessEnvelopeCodeEnum? code) => _$this._code = code;

  String? _message;
  String? get message => _$this._message;
  set message(covariant String? message) => _$this._message = message;

  AdminTextFontsWithdraw201ResponseBuilder() {
    AdminTextFontsWithdraw201Response._defaults(this);
  }

  AdminTextFontsWithdraw201ResponseBuilder get _$this {
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
  void replace(covariant AdminTextFontsWithdraw201Response other) {
    _$v = other as _$AdminTextFontsWithdraw201Response;
  }

  @override
  void update(
    void Function(AdminTextFontsWithdraw201ResponseBuilder)? updates,
  ) {
    if (updates != null) updates(this);
  }

  @override
  AdminTextFontsWithdraw201Response build() => _build();

  _$AdminTextFontsWithdraw201Response _build() {
    _$AdminTextFontsWithdraw201Response _$result;
    try {
      _$result =
          _$v ??
          _$AdminTextFontsWithdraw201Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'AdminTextFontsWithdraw201Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'AdminTextFontsWithdraw201Response',
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
          r'AdminTextFontsWithdraw201Response',
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
