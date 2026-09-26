// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_mobile_releases_confirm201_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const AdminMobileReleasesConfirm201ResponseCodeEnum
_$adminMobileReleasesConfirm201ResponseCodeEnum_number0 =
    const AdminMobileReleasesConfirm201ResponseCodeEnum._('number0');
const AdminMobileReleasesConfirm201ResponseCodeEnum
_$adminMobileReleasesConfirm201ResponseCodeEnum_unknownDefaultOpenApi =
    const AdminMobileReleasesConfirm201ResponseCodeEnum._(
      'unknownDefaultOpenApi',
    );

AdminMobileReleasesConfirm201ResponseCodeEnum
_$adminMobileReleasesConfirm201ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$adminMobileReleasesConfirm201ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$adminMobileReleasesConfirm201ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$adminMobileReleasesConfirm201ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<AdminMobileReleasesConfirm201ResponseCodeEnum>
_$adminMobileReleasesConfirm201ResponseCodeEnumValues =
    BuiltSet<AdminMobileReleasesConfirm201ResponseCodeEnum>(
      const <AdminMobileReleasesConfirm201ResponseCodeEnum>[
        _$adminMobileReleasesConfirm201ResponseCodeEnum_number0,
        _$adminMobileReleasesConfirm201ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<AdminMobileReleasesConfirm201ResponseCodeEnum>
_$adminMobileReleasesConfirm201ResponseCodeEnumSerializer =
    _$AdminMobileReleasesConfirm201ResponseCodeEnumSerializer();

class _$AdminMobileReleasesConfirm201ResponseCodeEnumSerializer
    implements
        PrimitiveSerializer<AdminMobileReleasesConfirm201ResponseCodeEnum> {
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
    AdminMobileReleasesConfirm201ResponseCodeEnum,
  ];
  @override
  final String wireName = 'AdminMobileReleasesConfirm201ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    AdminMobileReleasesConfirm201ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  AdminMobileReleasesConfirm201ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => AdminMobileReleasesConfirm201ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$AdminMobileReleasesConfirm201Response
    extends AdminMobileReleasesConfirm201Response {
  @override
  final AdminMobileReleaseDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$AdminMobileReleasesConfirm201Response([
    void Function(AdminMobileReleasesConfirm201ResponseBuilder)? updates,
  ]) => (AdminMobileReleasesConfirm201ResponseBuilder()..update(updates))
      ._build();

  _$AdminMobileReleasesConfirm201Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  AdminMobileReleasesConfirm201Response rebuild(
    void Function(AdminMobileReleasesConfirm201ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  AdminMobileReleasesConfirm201ResponseBuilder toBuilder() =>
      AdminMobileReleasesConfirm201ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminMobileReleasesConfirm201Response &&
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
            r'AdminMobileReleasesConfirm201Response',
          )
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class AdminMobileReleasesConfirm201ResponseBuilder
    implements
        Builder<
          AdminMobileReleasesConfirm201Response,
          AdminMobileReleasesConfirm201ResponseBuilder
        >,
        ApiSuccessEnvelopeBuilder {
  _$AdminMobileReleasesConfirm201Response? _$v;

  AdminMobileReleaseDtoBuilder? _data;
  AdminMobileReleaseDtoBuilder get data =>
      _$this._data ??= AdminMobileReleaseDtoBuilder();
  set data(covariant AdminMobileReleaseDtoBuilder? data) => _$this._data = data;

  ApiSuccessEnvelopeCodeEnum? _code;
  ApiSuccessEnvelopeCodeEnum? get code => _$this._code;
  set code(covariant ApiSuccessEnvelopeCodeEnum? code) => _$this._code = code;

  String? _message;
  String? get message => _$this._message;
  set message(covariant String? message) => _$this._message = message;

  AdminMobileReleasesConfirm201ResponseBuilder() {
    AdminMobileReleasesConfirm201Response._defaults(this);
  }

  AdminMobileReleasesConfirm201ResponseBuilder get _$this {
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
  void replace(covariant AdminMobileReleasesConfirm201Response other) {
    _$v = other as _$AdminMobileReleasesConfirm201Response;
  }

  @override
  void update(
    void Function(AdminMobileReleasesConfirm201ResponseBuilder)? updates,
  ) {
    if (updates != null) updates(this);
  }

  @override
  AdminMobileReleasesConfirm201Response build() => _build();

  _$AdminMobileReleasesConfirm201Response _build() {
    _$AdminMobileReleasesConfirm201Response _$result;
    try {
      _$result =
          _$v ??
          _$AdminMobileReleasesConfirm201Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'AdminMobileReleasesConfirm201Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'AdminMobileReleasesConfirm201Response',
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
          r'AdminMobileReleasesConfirm201Response',
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
