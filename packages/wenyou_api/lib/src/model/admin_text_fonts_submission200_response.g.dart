// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_text_fonts_submission200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const AdminTextFontsSubmission200ResponseCodeEnum
_$adminTextFontsSubmission200ResponseCodeEnum_number0 =
    const AdminTextFontsSubmission200ResponseCodeEnum._('number0');
const AdminTextFontsSubmission200ResponseCodeEnum
_$adminTextFontsSubmission200ResponseCodeEnum_unknownDefaultOpenApi =
    const AdminTextFontsSubmission200ResponseCodeEnum._(
      'unknownDefaultOpenApi',
    );

AdminTextFontsSubmission200ResponseCodeEnum
_$adminTextFontsSubmission200ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$adminTextFontsSubmission200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$adminTextFontsSubmission200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$adminTextFontsSubmission200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<AdminTextFontsSubmission200ResponseCodeEnum>
_$adminTextFontsSubmission200ResponseCodeEnumValues =
    BuiltSet<AdminTextFontsSubmission200ResponseCodeEnum>(
      const <AdminTextFontsSubmission200ResponseCodeEnum>[
        _$adminTextFontsSubmission200ResponseCodeEnum_number0,
        _$adminTextFontsSubmission200ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<AdminTextFontsSubmission200ResponseCodeEnum>
_$adminTextFontsSubmission200ResponseCodeEnumSerializer =
    _$AdminTextFontsSubmission200ResponseCodeEnumSerializer();

class _$AdminTextFontsSubmission200ResponseCodeEnumSerializer
    implements
        PrimitiveSerializer<AdminTextFontsSubmission200ResponseCodeEnum> {
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
    AdminTextFontsSubmission200ResponseCodeEnum,
  ];
  @override
  final String wireName = 'AdminTextFontsSubmission200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    AdminTextFontsSubmission200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  AdminTextFontsSubmission200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => AdminTextFontsSubmission200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$AdminTextFontsSubmission200Response
    extends AdminTextFontsSubmission200Response {
  @override
  final FontSubmissionDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$AdminTextFontsSubmission200Response([
    void Function(AdminTextFontsSubmission200ResponseBuilder)? updates,
  ]) =>
      (AdminTextFontsSubmission200ResponseBuilder()..update(updates))._build();

  _$AdminTextFontsSubmission200Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  AdminTextFontsSubmission200Response rebuild(
    void Function(AdminTextFontsSubmission200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  AdminTextFontsSubmission200ResponseBuilder toBuilder() =>
      AdminTextFontsSubmission200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminTextFontsSubmission200Response &&
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
    return (newBuiltValueToStringHelper(r'AdminTextFontsSubmission200Response')
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class AdminTextFontsSubmission200ResponseBuilder
    implements
        Builder<
          AdminTextFontsSubmission200Response,
          AdminTextFontsSubmission200ResponseBuilder
        >,
        ApiSuccessEnvelopeBuilder {
  _$AdminTextFontsSubmission200Response? _$v;

  FontSubmissionDtoBuilder? _data;
  FontSubmissionDtoBuilder get data =>
      _$this._data ??= FontSubmissionDtoBuilder();
  set data(covariant FontSubmissionDtoBuilder? data) => _$this._data = data;

  ApiSuccessEnvelopeCodeEnum? _code;
  ApiSuccessEnvelopeCodeEnum? get code => _$this._code;
  set code(covariant ApiSuccessEnvelopeCodeEnum? code) => _$this._code = code;

  String? _message;
  String? get message => _$this._message;
  set message(covariant String? message) => _$this._message = message;

  AdminTextFontsSubmission200ResponseBuilder() {
    AdminTextFontsSubmission200Response._defaults(this);
  }

  AdminTextFontsSubmission200ResponseBuilder get _$this {
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
  void replace(covariant AdminTextFontsSubmission200Response other) {
    _$v = other as _$AdminTextFontsSubmission200Response;
  }

  @override
  void update(
    void Function(AdminTextFontsSubmission200ResponseBuilder)? updates,
  ) {
    if (updates != null) updates(this);
  }

  @override
  AdminTextFontsSubmission200Response build() => _build();

  _$AdminTextFontsSubmission200Response _build() {
    _$AdminTextFontsSubmission200Response _$result;
    try {
      _$result =
          _$v ??
          _$AdminTextFontsSubmission200Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'AdminTextFontsSubmission200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'AdminTextFontsSubmission200Response',
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
          r'AdminTextFontsSubmission200Response',
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
