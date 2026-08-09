// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_taxonomy_create_category201_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const AdminTaxonomyCreateCategory201ResponseCodeEnum
_$adminTaxonomyCreateCategory201ResponseCodeEnum_number0 =
    const AdminTaxonomyCreateCategory201ResponseCodeEnum._('number0');
const AdminTaxonomyCreateCategory201ResponseCodeEnum
_$adminTaxonomyCreateCategory201ResponseCodeEnum_unknownDefaultOpenApi =
    const AdminTaxonomyCreateCategory201ResponseCodeEnum._(
      'unknownDefaultOpenApi',
    );

AdminTaxonomyCreateCategory201ResponseCodeEnum
_$adminTaxonomyCreateCategory201ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$adminTaxonomyCreateCategory201ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$adminTaxonomyCreateCategory201ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$adminTaxonomyCreateCategory201ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<AdminTaxonomyCreateCategory201ResponseCodeEnum>
_$adminTaxonomyCreateCategory201ResponseCodeEnumValues =
    BuiltSet<AdminTaxonomyCreateCategory201ResponseCodeEnum>(
      const <AdminTaxonomyCreateCategory201ResponseCodeEnum>[
        _$adminTaxonomyCreateCategory201ResponseCodeEnum_number0,
        _$adminTaxonomyCreateCategory201ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<AdminTaxonomyCreateCategory201ResponseCodeEnum>
_$adminTaxonomyCreateCategory201ResponseCodeEnumSerializer =
    _$AdminTaxonomyCreateCategory201ResponseCodeEnumSerializer();

class _$AdminTaxonomyCreateCategory201ResponseCodeEnumSerializer
    implements
        PrimitiveSerializer<AdminTaxonomyCreateCategory201ResponseCodeEnum> {
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
    AdminTaxonomyCreateCategory201ResponseCodeEnum,
  ];
  @override
  final String wireName = 'AdminTaxonomyCreateCategory201ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    AdminTaxonomyCreateCategory201ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  AdminTaxonomyCreateCategory201ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => AdminTaxonomyCreateCategory201ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$AdminTaxonomyCreateCategory201Response
    extends AdminTaxonomyCreateCategory201Response {
  @override
  final ThreadCategoryResponseDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$AdminTaxonomyCreateCategory201Response([
    void Function(AdminTaxonomyCreateCategory201ResponseBuilder)? updates,
  ]) => (AdminTaxonomyCreateCategory201ResponseBuilder()..update(updates))
      ._build();

  _$AdminTaxonomyCreateCategory201Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  AdminTaxonomyCreateCategory201Response rebuild(
    void Function(AdminTaxonomyCreateCategory201ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  AdminTaxonomyCreateCategory201ResponseBuilder toBuilder() =>
      AdminTaxonomyCreateCategory201ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminTaxonomyCreateCategory201Response &&
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
            r'AdminTaxonomyCreateCategory201Response',
          )
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class AdminTaxonomyCreateCategory201ResponseBuilder
    implements
        Builder<
          AdminTaxonomyCreateCategory201Response,
          AdminTaxonomyCreateCategory201ResponseBuilder
        >,
        ApiSuccessEnvelopeBuilder {
  _$AdminTaxonomyCreateCategory201Response? _$v;

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

  AdminTaxonomyCreateCategory201ResponseBuilder() {
    AdminTaxonomyCreateCategory201Response._defaults(this);
  }

  AdminTaxonomyCreateCategory201ResponseBuilder get _$this {
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
  void replace(covariant AdminTaxonomyCreateCategory201Response other) {
    _$v = other as _$AdminTaxonomyCreateCategory201Response;
  }

  @override
  void update(
    void Function(AdminTaxonomyCreateCategory201ResponseBuilder)? updates,
  ) {
    if (updates != null) updates(this);
  }

  @override
  AdminTaxonomyCreateCategory201Response build() => _build();

  _$AdminTaxonomyCreateCategory201Response _build() {
    _$AdminTaxonomyCreateCategory201Response _$result;
    try {
      _$result =
          _$v ??
          _$AdminTaxonomyCreateCategory201Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'AdminTaxonomyCreateCategory201Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'AdminTaxonomyCreateCategory201Response',
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
          r'AdminTaxonomyCreateCategory201Response',
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
