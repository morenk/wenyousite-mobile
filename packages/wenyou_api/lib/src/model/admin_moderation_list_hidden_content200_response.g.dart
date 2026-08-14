// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_moderation_list_hidden_content200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const AdminModerationListHiddenContent200ResponseCodeEnum
_$adminModerationListHiddenContent200ResponseCodeEnum_number0 =
    const AdminModerationListHiddenContent200ResponseCodeEnum._('number0');
const AdminModerationListHiddenContent200ResponseCodeEnum
_$adminModerationListHiddenContent200ResponseCodeEnum_unknownDefaultOpenApi =
    const AdminModerationListHiddenContent200ResponseCodeEnum._(
      'unknownDefaultOpenApi',
    );

AdminModerationListHiddenContent200ResponseCodeEnum
_$adminModerationListHiddenContent200ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$adminModerationListHiddenContent200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$adminModerationListHiddenContent200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$adminModerationListHiddenContent200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<AdminModerationListHiddenContent200ResponseCodeEnum>
_$adminModerationListHiddenContent200ResponseCodeEnumValues =
    BuiltSet<AdminModerationListHiddenContent200ResponseCodeEnum>(const <
      AdminModerationListHiddenContent200ResponseCodeEnum
    >[
      _$adminModerationListHiddenContent200ResponseCodeEnum_number0,
      _$adminModerationListHiddenContent200ResponseCodeEnum_unknownDefaultOpenApi,
    ]);

Serializer<AdminModerationListHiddenContent200ResponseCodeEnum>
_$adminModerationListHiddenContent200ResponseCodeEnumSerializer =
    _$AdminModerationListHiddenContent200ResponseCodeEnumSerializer();

class _$AdminModerationListHiddenContent200ResponseCodeEnumSerializer
    implements
        PrimitiveSerializer<
          AdminModerationListHiddenContent200ResponseCodeEnum
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
    AdminModerationListHiddenContent200ResponseCodeEnum,
  ];
  @override
  final String wireName = 'AdminModerationListHiddenContent200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    AdminModerationListHiddenContent200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  AdminModerationListHiddenContent200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => AdminModerationListHiddenContent200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$AdminModerationListHiddenContent200Response
    extends AdminModerationListHiddenContent200Response {
  @override
  final BuiltList<AdminHiddenContentResponseDto> data;
  @override
  final ApiPaginationMeta meta;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$AdminModerationListHiddenContent200Response([
    void Function(AdminModerationListHiddenContent200ResponseBuilder)? updates,
  ]) => (AdminModerationListHiddenContent200ResponseBuilder()..update(updates))
      ._build();

  _$AdminModerationListHiddenContent200Response._({
    required this.data,
    required this.meta,
    required this.code,
    required this.message,
  }) : super._();
  @override
  AdminModerationListHiddenContent200Response rebuild(
    void Function(AdminModerationListHiddenContent200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  AdminModerationListHiddenContent200ResponseBuilder toBuilder() =>
      AdminModerationListHiddenContent200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminModerationListHiddenContent200Response &&
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
    return (newBuiltValueToStringHelper(
            r'AdminModerationListHiddenContent200Response',
          )
          ..add('data', data)
          ..add('meta', meta)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class AdminModerationListHiddenContent200ResponseBuilder
    implements
        Builder<
          AdminModerationListHiddenContent200Response,
          AdminModerationListHiddenContent200ResponseBuilder
        >,
        ApiPaginatedSuccessEnvelopeBuilder {
  _$AdminModerationListHiddenContent200Response? _$v;

  ListBuilder<AdminHiddenContentResponseDto>? _data;
  ListBuilder<AdminHiddenContentResponseDto> get data =>
      _$this._data ??= ListBuilder<AdminHiddenContentResponseDto>();
  set data(covariant ListBuilder<AdminHiddenContentResponseDto>? data) =>
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

  AdminModerationListHiddenContent200ResponseBuilder() {
    AdminModerationListHiddenContent200Response._defaults(this);
  }

  AdminModerationListHiddenContent200ResponseBuilder get _$this {
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
  void replace(covariant AdminModerationListHiddenContent200Response other) {
    _$v = other as _$AdminModerationListHiddenContent200Response;
  }

  @override
  void update(
    void Function(AdminModerationListHiddenContent200ResponseBuilder)? updates,
  ) {
    if (updates != null) updates(this);
  }

  @override
  AdminModerationListHiddenContent200Response build() => _build();

  _$AdminModerationListHiddenContent200Response _build() {
    _$AdminModerationListHiddenContent200Response _$result;
    try {
      _$result =
          _$v ??
          _$AdminModerationListHiddenContent200Response._(
            data: data.build(),
            meta: meta.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'AdminModerationListHiddenContent200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'AdminModerationListHiddenContent200Response',
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
          r'AdminModerationListHiddenContent200Response',
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
