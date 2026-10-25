// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_text_fonts_process_submission201_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const AdminTextFontsProcessSubmission201ResponseCodeEnum
_$adminTextFontsProcessSubmission201ResponseCodeEnum_number0 =
    const AdminTextFontsProcessSubmission201ResponseCodeEnum._('number0');
const AdminTextFontsProcessSubmission201ResponseCodeEnum
_$adminTextFontsProcessSubmission201ResponseCodeEnum_unknownDefaultOpenApi =
    const AdminTextFontsProcessSubmission201ResponseCodeEnum._(
      'unknownDefaultOpenApi',
    );

AdminTextFontsProcessSubmission201ResponseCodeEnum
_$adminTextFontsProcessSubmission201ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$adminTextFontsProcessSubmission201ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$adminTextFontsProcessSubmission201ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$adminTextFontsProcessSubmission201ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<AdminTextFontsProcessSubmission201ResponseCodeEnum>
_$adminTextFontsProcessSubmission201ResponseCodeEnumValues =
    BuiltSet<AdminTextFontsProcessSubmission201ResponseCodeEnum>(const <
      AdminTextFontsProcessSubmission201ResponseCodeEnum
    >[
      _$adminTextFontsProcessSubmission201ResponseCodeEnum_number0,
      _$adminTextFontsProcessSubmission201ResponseCodeEnum_unknownDefaultOpenApi,
    ]);

Serializer<AdminTextFontsProcessSubmission201ResponseCodeEnum>
_$adminTextFontsProcessSubmission201ResponseCodeEnumSerializer =
    _$AdminTextFontsProcessSubmission201ResponseCodeEnumSerializer();

class _$AdminTextFontsProcessSubmission201ResponseCodeEnumSerializer
    implements
        PrimitiveSerializer<
          AdminTextFontsProcessSubmission201ResponseCodeEnum
        > {
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
    AdminTextFontsProcessSubmission201ResponseCodeEnum,
  ];
  @override
  final String wireName = 'AdminTextFontsProcessSubmission201ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    AdminTextFontsProcessSubmission201ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  AdminTextFontsProcessSubmission201ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => AdminTextFontsProcessSubmission201ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$AdminTextFontsProcessSubmission201Response
    extends AdminTextFontsProcessSubmission201Response {
  @override
  final FontJobDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$AdminTextFontsProcessSubmission201Response([
    void Function(AdminTextFontsProcessSubmission201ResponseBuilder)? updates,
  ]) => (AdminTextFontsProcessSubmission201ResponseBuilder()..update(updates))
      ._build();

  _$AdminTextFontsProcessSubmission201Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  AdminTextFontsProcessSubmission201Response rebuild(
    void Function(AdminTextFontsProcessSubmission201ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  AdminTextFontsProcessSubmission201ResponseBuilder toBuilder() =>
      AdminTextFontsProcessSubmission201ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminTextFontsProcessSubmission201Response &&
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
    return (newBuiltValueToStringHelper(
            r'AdminTextFontsProcessSubmission201Response',
          )
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class AdminTextFontsProcessSubmission201ResponseBuilder
    implements
        Builder<
          AdminTextFontsProcessSubmission201Response,
          AdminTextFontsProcessSubmission201ResponseBuilder
        >,
        ApiSuccessEnvelopeBuilder {
  _$AdminTextFontsProcessSubmission201Response? _$v;

  FontJobDtoBuilder? _data;
  FontJobDtoBuilder get data => _$this._data ??= FontJobDtoBuilder();
  set data(covariant FontJobDtoBuilder? data) => _$this._data = data;

  ApiSuccessEnvelopeCodeEnum? _code;
  ApiSuccessEnvelopeCodeEnum? get code => _$this._code;
  set code(covariant ApiSuccessEnvelopeCodeEnum? code) => _$this._code = code;

  String? _message;
  String? get message => _$this._message;
  set message(covariant String? message) => _$this._message = message;

  AdminTextFontsProcessSubmission201ResponseBuilder() {
    AdminTextFontsProcessSubmission201Response._defaults(this);
  }

  AdminTextFontsProcessSubmission201ResponseBuilder get _$this {
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
  void replace(covariant AdminTextFontsProcessSubmission201Response other) {
    _$v = other as _$AdminTextFontsProcessSubmission201Response;
  }

  @override
  void update(
    void Function(AdminTextFontsProcessSubmission201ResponseBuilder)? updates,
  ) {
    if (updates != null) updates(this);
  }

  @override
  AdminTextFontsProcessSubmission201Response build() => _build();

  _$AdminTextFontsProcessSubmission201Response _build() {
    _$AdminTextFontsProcessSubmission201Response _$result;
    try {
      _$result =
          _$v ??
          _$AdminTextFontsProcessSubmission201Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'AdminTextFontsProcessSubmission201Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'AdminTextFontsProcessSubmission201Response',
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
          r'AdminTextFontsProcessSubmission201Response',
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
