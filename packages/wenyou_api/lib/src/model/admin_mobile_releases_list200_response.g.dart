// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_mobile_releases_list200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const AdminMobileReleasesList200ResponseCodeEnum
_$adminMobileReleasesList200ResponseCodeEnum_number0 =
    const AdminMobileReleasesList200ResponseCodeEnum._('number0');
const AdminMobileReleasesList200ResponseCodeEnum
_$adminMobileReleasesList200ResponseCodeEnum_unknownDefaultOpenApi =
    const AdminMobileReleasesList200ResponseCodeEnum._('unknownDefaultOpenApi');

AdminMobileReleasesList200ResponseCodeEnum
_$adminMobileReleasesList200ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$adminMobileReleasesList200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$adminMobileReleasesList200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$adminMobileReleasesList200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<AdminMobileReleasesList200ResponseCodeEnum>
_$adminMobileReleasesList200ResponseCodeEnumValues =
    BuiltSet<AdminMobileReleasesList200ResponseCodeEnum>(
      const <AdminMobileReleasesList200ResponseCodeEnum>[
        _$adminMobileReleasesList200ResponseCodeEnum_number0,
        _$adminMobileReleasesList200ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<AdminMobileReleasesList200ResponseCodeEnum>
_$adminMobileReleasesList200ResponseCodeEnumSerializer =
    _$AdminMobileReleasesList200ResponseCodeEnumSerializer();

class _$AdminMobileReleasesList200ResponseCodeEnumSerializer
    implements PrimitiveSerializer<AdminMobileReleasesList200ResponseCodeEnum> {
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
    AdminMobileReleasesList200ResponseCodeEnum,
  ];
  @override
  final String wireName = 'AdminMobileReleasesList200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    AdminMobileReleasesList200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  AdminMobileReleasesList200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => AdminMobileReleasesList200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$AdminMobileReleasesList200Response
    extends AdminMobileReleasesList200Response {
  @override
  final BuiltList<AdminMobileReleaseDto> data;
  @override
  final ApiPaginationMeta meta;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$AdminMobileReleasesList200Response([
    void Function(AdminMobileReleasesList200ResponseBuilder)? updates,
  ]) => (AdminMobileReleasesList200ResponseBuilder()..update(updates))._build();

  _$AdminMobileReleasesList200Response._({
    required this.data,
    required this.meta,
    required this.code,
    required this.message,
  }) : super._();
  @override
  AdminMobileReleasesList200Response rebuild(
    void Function(AdminMobileReleasesList200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  AdminMobileReleasesList200ResponseBuilder toBuilder() =>
      AdminMobileReleasesList200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminMobileReleasesList200Response &&
        data == other.data &&
        meta == other.meta &&
        code == other.code &&
        message == other.message;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, data.hashCode);
    _$hash = $jc(_$hash, meta.hashCode);
    _$hash = $jc(_$hash, code.hashCode);
    _$hash = $jc(_$hash, message.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AdminMobileReleasesList200Response')
          ..add('data', data)
          ..add('meta', meta)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class AdminMobileReleasesList200ResponseBuilder
    implements
        Builder<
          AdminMobileReleasesList200Response,
          AdminMobileReleasesList200ResponseBuilder
        >,
        ApiPaginatedSuccessEnvelopeBuilder {
  _$AdminMobileReleasesList200Response? _$v;

  ListBuilder<AdminMobileReleaseDto>? _data;
  ListBuilder<AdminMobileReleaseDto> get data =>
      _$this._data ??= ListBuilder<AdminMobileReleaseDto>();
  set data(covariant ListBuilder<AdminMobileReleaseDto>? data) =>
      _$this._data = data;

  ApiPaginationMetaBuilder? _meta;
  ApiPaginationMetaBuilder get meta =>
      _$this._meta ??= ApiPaginationMetaBuilder();
  set meta(covariant ApiPaginationMetaBuilder? meta) => _$this._meta = meta;

  ApiSuccessEnvelopeCodeEnum? _code;
  ApiSuccessEnvelopeCodeEnum? get code => _$this._code;
  set code(covariant ApiSuccessEnvelopeCodeEnum? code) => _$this._code = code;

  String? _message;
  String? get message => _$this._message;
  set message(covariant String? message) => _$this._message = message;

  AdminMobileReleasesList200ResponseBuilder() {
    AdminMobileReleasesList200Response._defaults(this);
  }

  AdminMobileReleasesList200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _meta = $v.meta.toBuilder();
      _code = $v.code;
      _message = $v.message;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(covariant AdminMobileReleasesList200Response other) {
    _$v = other as _$AdminMobileReleasesList200Response;
  }

  @override
  void update(
    void Function(AdminMobileReleasesList200ResponseBuilder)? updates,
  ) {
    if (updates != null) updates(this);
  }

  @override
  AdminMobileReleasesList200Response build() => _build();

  _$AdminMobileReleasesList200Response _build() {
    _$AdminMobileReleasesList200Response _$result;
    try {
      _$result =
          _$v ??
          _$AdminMobileReleasesList200Response._(
            data: data.build(),
            meta: meta.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'AdminMobileReleasesList200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'AdminMobileReleasesList200Response',
              'message',
            ),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
        _$failedField = 'meta';
        meta.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'AdminMobileReleasesList200Response',
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
