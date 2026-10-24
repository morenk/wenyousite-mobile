// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_text_fonts_reorder200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const AdminTextFontsReorder200ResponseCodeEnum
_$adminTextFontsReorder200ResponseCodeEnum_number0 =
    const AdminTextFontsReorder200ResponseCodeEnum._('number0');
const AdminTextFontsReorder200ResponseCodeEnum
_$adminTextFontsReorder200ResponseCodeEnum_unknownDefaultOpenApi =
    const AdminTextFontsReorder200ResponseCodeEnum._('unknownDefaultOpenApi');

AdminTextFontsReorder200ResponseCodeEnum
_$adminTextFontsReorder200ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$adminTextFontsReorder200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$adminTextFontsReorder200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$adminTextFontsReorder200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<AdminTextFontsReorder200ResponseCodeEnum>
_$adminTextFontsReorder200ResponseCodeEnumValues =
    BuiltSet<AdminTextFontsReorder200ResponseCodeEnum>(
      const <AdminTextFontsReorder200ResponseCodeEnum>[
        _$adminTextFontsReorder200ResponseCodeEnum_number0,
        _$adminTextFontsReorder200ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<AdminTextFontsReorder200ResponseCodeEnum>
_$adminTextFontsReorder200ResponseCodeEnumSerializer =
    _$AdminTextFontsReorder200ResponseCodeEnumSerializer();

class _$AdminTextFontsReorder200ResponseCodeEnumSerializer
    implements PrimitiveSerializer<AdminTextFontsReorder200ResponseCodeEnum> {
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
    AdminTextFontsReorder200ResponseCodeEnum,
  ];
  @override
  final String wireName = 'AdminTextFontsReorder200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    AdminTextFontsReorder200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  AdminTextFontsReorder200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => AdminTextFontsReorder200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$AdminTextFontsReorder200Response
    extends AdminTextFontsReorder200Response {
  @override
  final FontReorderResultDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$AdminTextFontsReorder200Response([
    void Function(AdminTextFontsReorder200ResponseBuilder)? updates,
  ]) => (AdminTextFontsReorder200ResponseBuilder()..update(updates))._build();

  _$AdminTextFontsReorder200Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  AdminTextFontsReorder200Response rebuild(
    void Function(AdminTextFontsReorder200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  AdminTextFontsReorder200ResponseBuilder toBuilder() =>
      AdminTextFontsReorder200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminTextFontsReorder200Response &&
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
    return (newBuiltValueToStringHelper(r'AdminTextFontsReorder200Response')
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class AdminTextFontsReorder200ResponseBuilder
    implements
        Builder<
          AdminTextFontsReorder200Response,
          AdminTextFontsReorder200ResponseBuilder
        >,
        ApiSuccessEnvelopeBuilder {
  _$AdminTextFontsReorder200Response? _$v;

  FontReorderResultDtoBuilder? _data;
  FontReorderResultDtoBuilder get data =>
      _$this._data ??= FontReorderResultDtoBuilder();
  set data(covariant FontReorderResultDtoBuilder? data) => _$this._data = data;

  ApiSuccessEnvelopeCodeEnum? _code;
  ApiSuccessEnvelopeCodeEnum? get code => _$this._code;
  set code(covariant ApiSuccessEnvelopeCodeEnum? code) => _$this._code = code;

  String? _message;
  String? get message => _$this._message;
  set message(covariant String? message) => _$this._message = message;

  AdminTextFontsReorder200ResponseBuilder() {
    AdminTextFontsReorder200Response._defaults(this);
  }

  AdminTextFontsReorder200ResponseBuilder get _$this {
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
  void replace(covariant AdminTextFontsReorder200Response other) {
    _$v = other as _$AdminTextFontsReorder200Response;
  }

  @override
  void update(void Function(AdminTextFontsReorder200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AdminTextFontsReorder200Response build() => _build();

  _$AdminTextFontsReorder200Response _build() {
    _$AdminTextFontsReorder200Response _$result;
    try {
      _$result =
          _$v ??
          _$AdminTextFontsReorder200Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'AdminTextFontsReorder200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'AdminTextFontsReorder200Response',
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
          r'AdminTextFontsReorder200Response',
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
