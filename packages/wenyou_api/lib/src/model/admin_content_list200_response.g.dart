// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_content_list200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const AdminContentList200ResponseCodeEnum
_$adminContentList200ResponseCodeEnum_number0 =
    const AdminContentList200ResponseCodeEnum._('number0');
const AdminContentList200ResponseCodeEnum
_$adminContentList200ResponseCodeEnum_unknownDefaultOpenApi =
    const AdminContentList200ResponseCodeEnum._('unknownDefaultOpenApi');

AdminContentList200ResponseCodeEnum
_$adminContentList200ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$adminContentList200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$adminContentList200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$adminContentList200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<AdminContentList200ResponseCodeEnum>
_$adminContentList200ResponseCodeEnumValues =
    BuiltSet<AdminContentList200ResponseCodeEnum>(
      const <AdminContentList200ResponseCodeEnum>[
        _$adminContentList200ResponseCodeEnum_number0,
        _$adminContentList200ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<AdminContentList200ResponseCodeEnum>
_$adminContentList200ResponseCodeEnumSerializer =
    _$AdminContentList200ResponseCodeEnumSerializer();

class _$AdminContentList200ResponseCodeEnumSerializer
    implements PrimitiveSerializer<AdminContentList200ResponseCodeEnum> {
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
    AdminContentList200ResponseCodeEnum,
  ];
  @override
  final String wireName = 'AdminContentList200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    AdminContentList200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  AdminContentList200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => AdminContentList200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$AdminContentList200Response extends AdminContentList200Response {
  @override
  final BuiltList<AdminContentResponseDto> data;
  @override
  final ApiPaginationMeta meta;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$AdminContentList200Response([
    void Function(AdminContentList200ResponseBuilder)? updates,
  ]) => (AdminContentList200ResponseBuilder()..update(updates))._build();

  _$AdminContentList200Response._({
    required this.data,
    required this.meta,
    required this.code,
    required this.message,
  }) : super._();
  @override
  AdminContentList200Response rebuild(
    void Function(AdminContentList200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  AdminContentList200ResponseBuilder toBuilder() =>
      AdminContentList200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminContentList200Response &&
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
    return (newBuiltValueToStringHelper(r'AdminContentList200Response')
          ..add('data', data)
          ..add('meta', meta)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class AdminContentList200ResponseBuilder
    implements
        Builder<
          AdminContentList200Response,
          AdminContentList200ResponseBuilder
        >,
        ApiPaginatedSuccessEnvelopeBuilder {
  _$AdminContentList200Response? _$v;

  ListBuilder<AdminContentResponseDto>? _data;
  ListBuilder<AdminContentResponseDto> get data =>
      _$this._data ??= ListBuilder<AdminContentResponseDto>();
  set data(covariant ListBuilder<AdminContentResponseDto>? data) =>
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

  AdminContentList200ResponseBuilder() {
    AdminContentList200Response._defaults(this);
  }

  AdminContentList200ResponseBuilder get _$this {
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
  void replace(covariant AdminContentList200Response other) {
    _$v = other as _$AdminContentList200Response;
  }

  @override
  void update(void Function(AdminContentList200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AdminContentList200Response build() => _build();

  _$AdminContentList200Response _build() {
    _$AdminContentList200Response _$result;
    try {
      _$result =
          _$v ??
          _$AdminContentList200Response._(
            data: data.build(),
            meta: meta.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'AdminContentList200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'AdminContentList200Response',
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
          r'AdminContentList200Response',
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
