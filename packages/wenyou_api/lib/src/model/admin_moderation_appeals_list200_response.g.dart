// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_moderation_appeals_list200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const AdminModerationAppealsList200ResponseCodeEnum
_$adminModerationAppealsList200ResponseCodeEnum_number0 =
    const AdminModerationAppealsList200ResponseCodeEnum._('number0');
const AdminModerationAppealsList200ResponseCodeEnum
_$adminModerationAppealsList200ResponseCodeEnum_unknownDefaultOpenApi =
    const AdminModerationAppealsList200ResponseCodeEnum._(
      'unknownDefaultOpenApi',
    );

AdminModerationAppealsList200ResponseCodeEnum
_$adminModerationAppealsList200ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$adminModerationAppealsList200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$adminModerationAppealsList200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$adminModerationAppealsList200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<AdminModerationAppealsList200ResponseCodeEnum>
_$adminModerationAppealsList200ResponseCodeEnumValues =
    BuiltSet<AdminModerationAppealsList200ResponseCodeEnum>(
      const <AdminModerationAppealsList200ResponseCodeEnum>[
        _$adminModerationAppealsList200ResponseCodeEnum_number0,
        _$adminModerationAppealsList200ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<AdminModerationAppealsList200ResponseCodeEnum>
_$adminModerationAppealsList200ResponseCodeEnumSerializer =
    _$AdminModerationAppealsList200ResponseCodeEnumSerializer();

class _$AdminModerationAppealsList200ResponseCodeEnumSerializer
    implements
        PrimitiveSerializer<AdminModerationAppealsList200ResponseCodeEnum> {
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
    AdminModerationAppealsList200ResponseCodeEnum,
  ];
  @override
  final String wireName = 'AdminModerationAppealsList200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    AdminModerationAppealsList200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  AdminModerationAppealsList200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => AdminModerationAppealsList200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$AdminModerationAppealsList200Response
    extends AdminModerationAppealsList200Response {
  @override
  final BuiltList<ModerationAppealResponseDto> data;
  @override
  final ApiPaginationMeta meta;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$AdminModerationAppealsList200Response([
    void Function(AdminModerationAppealsList200ResponseBuilder)? updates,
  ]) => (AdminModerationAppealsList200ResponseBuilder()..update(updates))
      ._build();

  _$AdminModerationAppealsList200Response._({
    required this.data,
    required this.meta,
    required this.code,
    required this.message,
  }) : super._();
  @override
  AdminModerationAppealsList200Response rebuild(
    void Function(AdminModerationAppealsList200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  AdminModerationAppealsList200ResponseBuilder toBuilder() =>
      AdminModerationAppealsList200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminModerationAppealsList200Response &&
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
            r'AdminModerationAppealsList200Response',
          )
          ..add('data', data)
          ..add('meta', meta)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class AdminModerationAppealsList200ResponseBuilder
    implements
        Builder<
          AdminModerationAppealsList200Response,
          AdminModerationAppealsList200ResponseBuilder
        >,
        ApiPaginatedSuccessEnvelopeBuilder {
  _$AdminModerationAppealsList200Response? _$v;

  ListBuilder<ModerationAppealResponseDto>? _data;
  ListBuilder<ModerationAppealResponseDto> get data =>
      _$this._data ??= ListBuilder<ModerationAppealResponseDto>();
  set data(covariant ListBuilder<ModerationAppealResponseDto>? data) =>
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

  AdminModerationAppealsList200ResponseBuilder() {
    AdminModerationAppealsList200Response._defaults(this);
  }

  AdminModerationAppealsList200ResponseBuilder get _$this {
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
  void replace(covariant AdminModerationAppealsList200Response other) {
    _$v = other as _$AdminModerationAppealsList200Response;
  }

  @override
  void update(
    void Function(AdminModerationAppealsList200ResponseBuilder)? updates,
  ) {
    if (updates != null) updates(this);
  }

  @override
  AdminModerationAppealsList200Response build() => _build();

  _$AdminModerationAppealsList200Response _build() {
    _$AdminModerationAppealsList200Response _$result;
    try {
      _$result =
          _$v ??
          _$AdminModerationAppealsList200Response._(
            data: data.build(),
            meta: meta.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'AdminModerationAppealsList200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'AdminModerationAppealsList200Response',
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
          r'AdminModerationAppealsList200Response',
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
