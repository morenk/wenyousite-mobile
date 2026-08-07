// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_preview_recipients201_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const AdminPreviewRecipients201ResponseCodeEnum
_$adminPreviewRecipients201ResponseCodeEnum_number0 =
    const AdminPreviewRecipients201ResponseCodeEnum._('number0');
const AdminPreviewRecipients201ResponseCodeEnum
_$adminPreviewRecipients201ResponseCodeEnum_unknownDefaultOpenApi =
    const AdminPreviewRecipients201ResponseCodeEnum._('unknownDefaultOpenApi');

AdminPreviewRecipients201ResponseCodeEnum
_$adminPreviewRecipients201ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$adminPreviewRecipients201ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$adminPreviewRecipients201ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$adminPreviewRecipients201ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<AdminPreviewRecipients201ResponseCodeEnum>
_$adminPreviewRecipients201ResponseCodeEnumValues =
    BuiltSet<AdminPreviewRecipients201ResponseCodeEnum>(
      const <AdminPreviewRecipients201ResponseCodeEnum>[
        _$adminPreviewRecipients201ResponseCodeEnum_number0,
        _$adminPreviewRecipients201ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<AdminPreviewRecipients201ResponseCodeEnum>
_$adminPreviewRecipients201ResponseCodeEnumSerializer =
    _$AdminPreviewRecipients201ResponseCodeEnumSerializer();

class _$AdminPreviewRecipients201ResponseCodeEnumSerializer
    implements PrimitiveSerializer<AdminPreviewRecipients201ResponseCodeEnum> {
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
    AdminPreviewRecipients201ResponseCodeEnum,
  ];
  @override
  final String wireName = 'AdminPreviewRecipients201ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    AdminPreviewRecipients201ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  AdminPreviewRecipients201ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => AdminPreviewRecipients201ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$AdminPreviewRecipients201Response
    extends AdminPreviewRecipients201Response {
  @override
  final AdminRecipientCountResponseDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$AdminPreviewRecipients201Response([
    void Function(AdminPreviewRecipients201ResponseBuilder)? updates,
  ]) => (AdminPreviewRecipients201ResponseBuilder()..update(updates))._build();

  _$AdminPreviewRecipients201Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  AdminPreviewRecipients201Response rebuild(
    void Function(AdminPreviewRecipients201ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  AdminPreviewRecipients201ResponseBuilder toBuilder() =>
      AdminPreviewRecipients201ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminPreviewRecipients201Response &&
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
    return (newBuiltValueToStringHelper(r'AdminPreviewRecipients201Response')
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class AdminPreviewRecipients201ResponseBuilder
    implements
        Builder<
          AdminPreviewRecipients201Response,
          AdminPreviewRecipients201ResponseBuilder
        >,
        ApiSuccessEnvelopeBuilder {
  _$AdminPreviewRecipients201Response? _$v;

  AdminRecipientCountResponseDtoBuilder? _data;
  AdminRecipientCountResponseDtoBuilder get data =>
      _$this._data ??= AdminRecipientCountResponseDtoBuilder();
  set data(covariant AdminRecipientCountResponseDtoBuilder? data) =>
      _$this._data = data;

  ApiSuccessEnvelopeCodeEnum? _code;
  ApiSuccessEnvelopeCodeEnum? get code => _$this._code;
  set code(covariant ApiSuccessEnvelopeCodeEnum? code) => _$this._code = code;

  String? _message;
  String? get message => _$this._message;
  set message(covariant String? message) => _$this._message = message;

  AdminPreviewRecipients201ResponseBuilder() {
    AdminPreviewRecipients201Response._defaults(this);
  }

  AdminPreviewRecipients201ResponseBuilder get _$this {
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
  void replace(covariant AdminPreviewRecipients201Response other) {
    _$v = other as _$AdminPreviewRecipients201Response;
  }

  @override
  void update(
    void Function(AdminPreviewRecipients201ResponseBuilder)? updates,
  ) {
    if (updates != null) updates(this);
  }

  @override
  AdminPreviewRecipients201Response build() => _build();

  _$AdminPreviewRecipients201Response _build() {
    _$AdminPreviewRecipients201Response _$result;
    try {
      _$result =
          _$v ??
          _$AdminPreviewRecipients201Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'AdminPreviewRecipients201Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'AdminPreviewRecipients201Response',
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
          r'AdminPreviewRecipients201Response',
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
