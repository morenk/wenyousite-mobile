// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_taxonomy_update_category200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const AdminTaxonomyUpdateCategory200ResponseCodeEnum
_$adminTaxonomyUpdateCategory200ResponseCodeEnum_number0 =
    const AdminTaxonomyUpdateCategory200ResponseCodeEnum._('number0');
const AdminTaxonomyUpdateCategory200ResponseCodeEnum
_$adminTaxonomyUpdateCategory200ResponseCodeEnum_unknownDefaultOpenApi =
    const AdminTaxonomyUpdateCategory200ResponseCodeEnum._(
      'unknownDefaultOpenApi',
    );

AdminTaxonomyUpdateCategory200ResponseCodeEnum
_$adminTaxonomyUpdateCategory200ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$adminTaxonomyUpdateCategory200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$adminTaxonomyUpdateCategory200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$adminTaxonomyUpdateCategory200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<AdminTaxonomyUpdateCategory200ResponseCodeEnum>
_$adminTaxonomyUpdateCategory200ResponseCodeEnumValues =
    BuiltSet<AdminTaxonomyUpdateCategory200ResponseCodeEnum>(
      const <AdminTaxonomyUpdateCategory200ResponseCodeEnum>[
        _$adminTaxonomyUpdateCategory200ResponseCodeEnum_number0,
        _$adminTaxonomyUpdateCategory200ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<AdminTaxonomyUpdateCategory200ResponseCodeEnum>
_$adminTaxonomyUpdateCategory200ResponseCodeEnumSerializer =
    _$AdminTaxonomyUpdateCategory200ResponseCodeEnumSerializer();

class _$AdminTaxonomyUpdateCategory200ResponseCodeEnumSerializer
    implements
        PrimitiveSerializer<AdminTaxonomyUpdateCategory200ResponseCodeEnum> {
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
    AdminTaxonomyUpdateCategory200ResponseCodeEnum,
  ];
  @override
  final String wireName = 'AdminTaxonomyUpdateCategory200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    AdminTaxonomyUpdateCategory200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  AdminTaxonomyUpdateCategory200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => AdminTaxonomyUpdateCategory200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$AdminTaxonomyUpdateCategory200Response
    extends AdminTaxonomyUpdateCategory200Response {
  @override
  final ThreadCategoryResponseDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$AdminTaxonomyUpdateCategory200Response([
    void Function(AdminTaxonomyUpdateCategory200ResponseBuilder)? updates,
  ]) => (AdminTaxonomyUpdateCategory200ResponseBuilder()..update(updates))
      ._build();

  _$AdminTaxonomyUpdateCategory200Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  AdminTaxonomyUpdateCategory200Response rebuild(
    void Function(AdminTaxonomyUpdateCategory200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  AdminTaxonomyUpdateCategory200ResponseBuilder toBuilder() =>
      AdminTaxonomyUpdateCategory200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminTaxonomyUpdateCategory200Response &&
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
            r'AdminTaxonomyUpdateCategory200Response',
          )
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class AdminTaxonomyUpdateCategory200ResponseBuilder
    implements
        Builder<
          AdminTaxonomyUpdateCategory200Response,
          AdminTaxonomyUpdateCategory200ResponseBuilder
        >,
        ApiSuccessEnvelopeBuilder {
  _$AdminTaxonomyUpdateCategory200Response? _$v;

  ThreadCategoryResponseDtoBuilder? _data;
  ThreadCategoryResponseDtoBuilder get data =>
      _$this._data ??= ThreadCategoryResponseDtoBuilder();
  set data(covariant ThreadCategoryResponseDtoBuilder? data) =>
      _$this._data = data;

  ApiSuccessEnvelopeCodeEnum? _code;
  ApiSuccessEnvelopeCodeEnum? get code => _$this._code;
  set code(covariant ApiSuccessEnvelopeCodeEnum? code) => _$this._code = code;

  String? _message;
  String? get message => _$this._message;
  set message(covariant String? message) => _$this._message = message;

  AdminTaxonomyUpdateCategory200ResponseBuilder() {
    AdminTaxonomyUpdateCategory200Response._defaults(this);
  }

  AdminTaxonomyUpdateCategory200ResponseBuilder get _$this {
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
  void replace(covariant AdminTaxonomyUpdateCategory200Response other) {
    _$v = other as _$AdminTaxonomyUpdateCategory200Response;
  }

  @override
  void update(
    void Function(AdminTaxonomyUpdateCategory200ResponseBuilder)? updates,
  ) {
    if (updates != null) updates(this);
  }

  @override
  AdminTaxonomyUpdateCategory200Response build() => _build();

  _$AdminTaxonomyUpdateCategory200Response _build() {
    _$AdminTaxonomyUpdateCategory200Response _$result;
    try {
      _$result =
          _$v ??
          _$AdminTaxonomyUpdateCategory200Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'AdminTaxonomyUpdateCategory200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'AdminTaxonomyUpdateCategory200Response',
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
          r'AdminTaxonomyUpdateCategory200Response',
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
