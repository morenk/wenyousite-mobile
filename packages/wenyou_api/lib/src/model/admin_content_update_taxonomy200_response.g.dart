// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_content_update_taxonomy200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const AdminContentUpdateTaxonomy200ResponseCodeEnum
_$adminContentUpdateTaxonomy200ResponseCodeEnum_number0 =
    const AdminContentUpdateTaxonomy200ResponseCodeEnum._('number0');
const AdminContentUpdateTaxonomy200ResponseCodeEnum
_$adminContentUpdateTaxonomy200ResponseCodeEnum_unknownDefaultOpenApi =
    const AdminContentUpdateTaxonomy200ResponseCodeEnum._(
      'unknownDefaultOpenApi',
    );

AdminContentUpdateTaxonomy200ResponseCodeEnum
_$adminContentUpdateTaxonomy200ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$adminContentUpdateTaxonomy200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$adminContentUpdateTaxonomy200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$adminContentUpdateTaxonomy200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<AdminContentUpdateTaxonomy200ResponseCodeEnum>
_$adminContentUpdateTaxonomy200ResponseCodeEnumValues =
    BuiltSet<AdminContentUpdateTaxonomy200ResponseCodeEnum>(
      const <AdminContentUpdateTaxonomy200ResponseCodeEnum>[
        _$adminContentUpdateTaxonomy200ResponseCodeEnum_number0,
        _$adminContentUpdateTaxonomy200ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<AdminContentUpdateTaxonomy200ResponseCodeEnum>
_$adminContentUpdateTaxonomy200ResponseCodeEnumSerializer =
    _$AdminContentUpdateTaxonomy200ResponseCodeEnumSerializer();

class _$AdminContentUpdateTaxonomy200ResponseCodeEnumSerializer
    implements
        PrimitiveSerializer<AdminContentUpdateTaxonomy200ResponseCodeEnum> {
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
    AdminContentUpdateTaxonomy200ResponseCodeEnum,
  ];
  @override
  final String wireName = 'AdminContentUpdateTaxonomy200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    AdminContentUpdateTaxonomy200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  AdminContentUpdateTaxonomy200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => AdminContentUpdateTaxonomy200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$AdminContentUpdateTaxonomy200Response
    extends AdminContentUpdateTaxonomy200Response {
  @override
  final AdminContentDetailResponseDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$AdminContentUpdateTaxonomy200Response([
    void Function(AdminContentUpdateTaxonomy200ResponseBuilder)? updates,
  ]) => (AdminContentUpdateTaxonomy200ResponseBuilder()..update(updates))
      ._build();

  _$AdminContentUpdateTaxonomy200Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  AdminContentUpdateTaxonomy200Response rebuild(
    void Function(AdminContentUpdateTaxonomy200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  AdminContentUpdateTaxonomy200ResponseBuilder toBuilder() =>
      AdminContentUpdateTaxonomy200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminContentUpdateTaxonomy200Response &&
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
            r'AdminContentUpdateTaxonomy200Response',
          )
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class AdminContentUpdateTaxonomy200ResponseBuilder
    implements
        Builder<
          AdminContentUpdateTaxonomy200Response,
          AdminContentUpdateTaxonomy200ResponseBuilder
        >,
        ApiSuccessEnvelopeBuilder {
  _$AdminContentUpdateTaxonomy200Response? _$v;

  AdminContentDetailResponseDtoBuilder? _data;
  AdminContentDetailResponseDtoBuilder get data =>
      _$this._data ??= AdminContentDetailResponseDtoBuilder();
  set data(covariant AdminContentDetailResponseDtoBuilder? data) =>
      _$this._data = data;

  ApiSuccessEnvelopeCodeEnum? _code;
  ApiSuccessEnvelopeCodeEnum? get code => _$this._code;
  set code(covariant ApiSuccessEnvelopeCodeEnum? code) => _$this._code = code;

  String? _message;
  String? get message => _$this._message;
  set message(covariant String? message) => _$this._message = message;

  AdminContentUpdateTaxonomy200ResponseBuilder() {
    AdminContentUpdateTaxonomy200Response._defaults(this);
  }

  AdminContentUpdateTaxonomy200ResponseBuilder get _$this {
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
  void replace(covariant AdminContentUpdateTaxonomy200Response other) {
    _$v = other as _$AdminContentUpdateTaxonomy200Response;
  }

  @override
  void update(
    void Function(AdminContentUpdateTaxonomy200ResponseBuilder)? updates,
  ) {
    if (updates != null) updates(this);
  }

  @override
  AdminContentUpdateTaxonomy200Response build() => _build();

  _$AdminContentUpdateTaxonomy200Response _build() {
    _$AdminContentUpdateTaxonomy200Response _$result;
    try {
      _$result =
          _$v ??
          _$AdminContentUpdateTaxonomy200Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'AdminContentUpdateTaxonomy200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'AdminContentUpdateTaxonomy200Response',
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
          r'AdminContentUpdateTaxonomy200Response',
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
