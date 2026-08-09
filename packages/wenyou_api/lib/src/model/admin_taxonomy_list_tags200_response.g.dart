// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_taxonomy_list_tags200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const AdminTaxonomyListTags200ResponseCodeEnum
_$adminTaxonomyListTags200ResponseCodeEnum_number0 =
    const AdminTaxonomyListTags200ResponseCodeEnum._('number0');
const AdminTaxonomyListTags200ResponseCodeEnum
_$adminTaxonomyListTags200ResponseCodeEnum_unknownDefaultOpenApi =
    const AdminTaxonomyListTags200ResponseCodeEnum._('unknownDefaultOpenApi');

AdminTaxonomyListTags200ResponseCodeEnum
_$adminTaxonomyListTags200ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$adminTaxonomyListTags200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$adminTaxonomyListTags200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$adminTaxonomyListTags200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<AdminTaxonomyListTags200ResponseCodeEnum>
_$adminTaxonomyListTags200ResponseCodeEnumValues =
    BuiltSet<AdminTaxonomyListTags200ResponseCodeEnum>(
      const <AdminTaxonomyListTags200ResponseCodeEnum>[
        _$adminTaxonomyListTags200ResponseCodeEnum_number0,
        _$adminTaxonomyListTags200ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<AdminTaxonomyListTags200ResponseCodeEnum>
_$adminTaxonomyListTags200ResponseCodeEnumSerializer =
    _$AdminTaxonomyListTags200ResponseCodeEnumSerializer();

class _$AdminTaxonomyListTags200ResponseCodeEnumSerializer
    implements PrimitiveSerializer<AdminTaxonomyListTags200ResponseCodeEnum> {
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
    AdminTaxonomyListTags200ResponseCodeEnum,
  ];
  @override
  final String wireName = 'AdminTaxonomyListTags200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    AdminTaxonomyListTags200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  AdminTaxonomyListTags200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => AdminTaxonomyListTags200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$AdminTaxonomyListTags200Response
    extends AdminTaxonomyListTags200Response {
  @override
  final BuiltList<TagResponseDto> data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$AdminTaxonomyListTags200Response([
    void Function(AdminTaxonomyListTags200ResponseBuilder)? updates,
  ]) => (AdminTaxonomyListTags200ResponseBuilder()..update(updates))._build();

  _$AdminTaxonomyListTags200Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  AdminTaxonomyListTags200Response rebuild(
    void Function(AdminTaxonomyListTags200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  AdminTaxonomyListTags200ResponseBuilder toBuilder() =>
      AdminTaxonomyListTags200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminTaxonomyListTags200Response &&
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
    return (newBuiltValueToStringHelper(r'AdminTaxonomyListTags200Response')
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class AdminTaxonomyListTags200ResponseBuilder
    implements
        Builder<
          AdminTaxonomyListTags200Response,
          AdminTaxonomyListTags200ResponseBuilder
        >,
        ApiSuccessEnvelopeBuilder {
  _$AdminTaxonomyListTags200Response? _$v;

  ListBuilder<TagResponseDto>? _data;
  ListBuilder<TagResponseDto> get data =>
      _$this._data ??= ListBuilder<TagResponseDto>();
  set data(covariant ListBuilder<TagResponseDto>? data) => _$this._data = data;

  ApiSuccessEnvelopeCodeEnum? _code;
  ApiSuccessEnvelopeCodeEnum? get code => _$this._code;
  set code(covariant ApiSuccessEnvelopeCodeEnum? code) => _$this._code = code;

  String? _message;
  String? get message => _$this._message;
  set message(covariant String? message) => _$this._message = message;

  AdminTaxonomyListTags200ResponseBuilder() {
    AdminTaxonomyListTags200Response._defaults(this);
  }

  AdminTaxonomyListTags200ResponseBuilder get _$this {
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
  void replace(covariant AdminTaxonomyListTags200Response other) {
    _$v = other as _$AdminTaxonomyListTags200Response;
  }

  @override
  void update(void Function(AdminTaxonomyListTags200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AdminTaxonomyListTags200Response build() => _build();

  _$AdminTaxonomyListTags200Response _build() {
    _$AdminTaxonomyListTags200Response _$result;
    try {
      _$result =
          _$v ??
          _$AdminTaxonomyListTags200Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'AdminTaxonomyListTags200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'AdminTaxonomyListTags200Response',
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
          r'AdminTaxonomyListTags200Response',
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
