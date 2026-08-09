// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_taxonomy_update_tag200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const AdminTaxonomyUpdateTag200ResponseCodeEnum
_$adminTaxonomyUpdateTag200ResponseCodeEnum_number0 =
    const AdminTaxonomyUpdateTag200ResponseCodeEnum._('number0');
const AdminTaxonomyUpdateTag200ResponseCodeEnum
_$adminTaxonomyUpdateTag200ResponseCodeEnum_unknownDefaultOpenApi =
    const AdminTaxonomyUpdateTag200ResponseCodeEnum._('unknownDefaultOpenApi');

AdminTaxonomyUpdateTag200ResponseCodeEnum
_$adminTaxonomyUpdateTag200ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$adminTaxonomyUpdateTag200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$adminTaxonomyUpdateTag200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$adminTaxonomyUpdateTag200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<AdminTaxonomyUpdateTag200ResponseCodeEnum>
_$adminTaxonomyUpdateTag200ResponseCodeEnumValues =
    BuiltSet<AdminTaxonomyUpdateTag200ResponseCodeEnum>(
      const <AdminTaxonomyUpdateTag200ResponseCodeEnum>[
        _$adminTaxonomyUpdateTag200ResponseCodeEnum_number0,
        _$adminTaxonomyUpdateTag200ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<AdminTaxonomyUpdateTag200ResponseCodeEnum>
_$adminTaxonomyUpdateTag200ResponseCodeEnumSerializer =
    _$AdminTaxonomyUpdateTag200ResponseCodeEnumSerializer();

class _$AdminTaxonomyUpdateTag200ResponseCodeEnumSerializer
    implements PrimitiveSerializer<AdminTaxonomyUpdateTag200ResponseCodeEnum> {
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
    AdminTaxonomyUpdateTag200ResponseCodeEnum,
  ];
  @override
  final String wireName = 'AdminTaxonomyUpdateTag200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    AdminTaxonomyUpdateTag200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  AdminTaxonomyUpdateTag200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => AdminTaxonomyUpdateTag200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$AdminTaxonomyUpdateTag200Response
    extends AdminTaxonomyUpdateTag200Response {
  @override
  final TagResponseDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$AdminTaxonomyUpdateTag200Response([
    void Function(AdminTaxonomyUpdateTag200ResponseBuilder)? updates,
  ]) => (AdminTaxonomyUpdateTag200ResponseBuilder()..update(updates))._build();

  _$AdminTaxonomyUpdateTag200Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  AdminTaxonomyUpdateTag200Response rebuild(
    void Function(AdminTaxonomyUpdateTag200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  AdminTaxonomyUpdateTag200ResponseBuilder toBuilder() =>
      AdminTaxonomyUpdateTag200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminTaxonomyUpdateTag200Response &&
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
    return (newBuiltValueToStringHelper(r'AdminTaxonomyUpdateTag200Response')
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class AdminTaxonomyUpdateTag200ResponseBuilder
    implements
        Builder<
          AdminTaxonomyUpdateTag200Response,
          AdminTaxonomyUpdateTag200ResponseBuilder
        >,
        ApiSuccessEnvelopeBuilder {
  _$AdminTaxonomyUpdateTag200Response? _$v;

  TagResponseDtoBuilder? _data;
  TagResponseDtoBuilder get data => _$this._data ??= TagResponseDtoBuilder();
  set data(covariant TagResponseDtoBuilder? data) => _$this._data = data;

  ApiSuccessEnvelopeCodeEnum? _code;
  ApiSuccessEnvelopeCodeEnum? get code => _$this._code;
  set code(covariant ApiSuccessEnvelopeCodeEnum? code) => _$this._code = code;

  String? _message;
  String? get message => _$this._message;
  set message(covariant String? message) => _$this._message = message;

  AdminTaxonomyUpdateTag200ResponseBuilder() {
    AdminTaxonomyUpdateTag200Response._defaults(this);
  }

  AdminTaxonomyUpdateTag200ResponseBuilder get _$this {
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
  void replace(covariant AdminTaxonomyUpdateTag200Response other) {
    _$v = other as _$AdminTaxonomyUpdateTag200Response;
  }

  @override
  void update(
    void Function(AdminTaxonomyUpdateTag200ResponseBuilder)? updates,
  ) {
    if (updates != null) updates(this);
  }

  @override
  AdminTaxonomyUpdateTag200Response build() => _build();

  _$AdminTaxonomyUpdateTag200Response _build() {
    _$AdminTaxonomyUpdateTag200Response _$result;
    try {
      _$result =
          _$v ??
          _$AdminTaxonomyUpdateTag200Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'AdminTaxonomyUpdateTag200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'AdminTaxonomyUpdateTag200Response',
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
          r'AdminTaxonomyUpdateTag200Response',
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
