// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_taxonomy_create_tag201_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const AdminTaxonomyCreateTag201ResponseCodeEnum
_$adminTaxonomyCreateTag201ResponseCodeEnum_number0 =
    const AdminTaxonomyCreateTag201ResponseCodeEnum._('number0');
const AdminTaxonomyCreateTag201ResponseCodeEnum
_$adminTaxonomyCreateTag201ResponseCodeEnum_unknownDefaultOpenApi =
    const AdminTaxonomyCreateTag201ResponseCodeEnum._('unknownDefaultOpenApi');

AdminTaxonomyCreateTag201ResponseCodeEnum
_$adminTaxonomyCreateTag201ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$adminTaxonomyCreateTag201ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$adminTaxonomyCreateTag201ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$adminTaxonomyCreateTag201ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<AdminTaxonomyCreateTag201ResponseCodeEnum>
_$adminTaxonomyCreateTag201ResponseCodeEnumValues =
    BuiltSet<AdminTaxonomyCreateTag201ResponseCodeEnum>(
      const <AdminTaxonomyCreateTag201ResponseCodeEnum>[
        _$adminTaxonomyCreateTag201ResponseCodeEnum_number0,
        _$adminTaxonomyCreateTag201ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<AdminTaxonomyCreateTag201ResponseCodeEnum>
_$adminTaxonomyCreateTag201ResponseCodeEnumSerializer =
    _$AdminTaxonomyCreateTag201ResponseCodeEnumSerializer();

class _$AdminTaxonomyCreateTag201ResponseCodeEnumSerializer
    implements PrimitiveSerializer<AdminTaxonomyCreateTag201ResponseCodeEnum> {
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
    AdminTaxonomyCreateTag201ResponseCodeEnum,
  ];
  @override
  final String wireName = 'AdminTaxonomyCreateTag201ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    AdminTaxonomyCreateTag201ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  AdminTaxonomyCreateTag201ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => AdminTaxonomyCreateTag201ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$AdminTaxonomyCreateTag201Response
    extends AdminTaxonomyCreateTag201Response {
  @override
  final TagResponseDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$AdminTaxonomyCreateTag201Response([
    void Function(AdminTaxonomyCreateTag201ResponseBuilder)? updates,
  ]) => (AdminTaxonomyCreateTag201ResponseBuilder()..update(updates))._build();

  _$AdminTaxonomyCreateTag201Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  AdminTaxonomyCreateTag201Response rebuild(
    void Function(AdminTaxonomyCreateTag201ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  AdminTaxonomyCreateTag201ResponseBuilder toBuilder() =>
      AdminTaxonomyCreateTag201ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminTaxonomyCreateTag201Response &&
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
    return (newBuiltValueToStringHelper(r'AdminTaxonomyCreateTag201Response')
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class AdminTaxonomyCreateTag201ResponseBuilder
    implements
        Builder<
          AdminTaxonomyCreateTag201Response,
          AdminTaxonomyCreateTag201ResponseBuilder
        >,
        ApiSuccessEnvelopeBuilder {
  _$AdminTaxonomyCreateTag201Response? _$v;

  TagResponseDtoBuilder? _data;
  TagResponseDtoBuilder get data => _$this._data ??= TagResponseDtoBuilder();
  set data(covariant TagResponseDtoBuilder? data) => _$this._data = data;

  ApiSuccessEnvelopeCodeEnum? _code;
  ApiSuccessEnvelopeCodeEnum? get code => _$this._code;
  set code(covariant ApiSuccessEnvelopeCodeEnum? code) => _$this._code = code;

  String? _message;
  String? get message => _$this._message;
  set message(covariant String? message) => _$this._message = message;

  AdminTaxonomyCreateTag201ResponseBuilder() {
    AdminTaxonomyCreateTag201Response._defaults(this);
  }

  AdminTaxonomyCreateTag201ResponseBuilder get _$this {
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
  void replace(covariant AdminTaxonomyCreateTag201Response other) {
    _$v = other as _$AdminTaxonomyCreateTag201Response;
  }

  @override
  void update(
    void Function(AdminTaxonomyCreateTag201ResponseBuilder)? updates,
  ) {
    if (updates != null) updates(this);
  }

  @override
  AdminTaxonomyCreateTag201Response build() => _build();

  _$AdminTaxonomyCreateTag201Response _build() {
    _$AdminTaxonomyCreateTag201Response _$result;
    try {
      _$result =
          _$v ??
          _$AdminTaxonomyCreateTag201Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'AdminTaxonomyCreateTag201Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'AdminTaxonomyCreateTag201Response',
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
          r'AdminTaxonomyCreateTag201Response',
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
