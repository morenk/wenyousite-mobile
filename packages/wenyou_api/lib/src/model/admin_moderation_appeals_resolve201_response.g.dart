// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_moderation_appeals_resolve201_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const AdminModerationAppealsResolve201ResponseCodeEnum
_$adminModerationAppealsResolve201ResponseCodeEnum_number0 =
    const AdminModerationAppealsResolve201ResponseCodeEnum._('number0');
const AdminModerationAppealsResolve201ResponseCodeEnum
_$adminModerationAppealsResolve201ResponseCodeEnum_unknownDefaultOpenApi =
    const AdminModerationAppealsResolve201ResponseCodeEnum._(
      'unknownDefaultOpenApi',
    );

AdminModerationAppealsResolve201ResponseCodeEnum
_$adminModerationAppealsResolve201ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$adminModerationAppealsResolve201ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$adminModerationAppealsResolve201ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$adminModerationAppealsResolve201ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<AdminModerationAppealsResolve201ResponseCodeEnum>
_$adminModerationAppealsResolve201ResponseCodeEnumValues =
    BuiltSet<AdminModerationAppealsResolve201ResponseCodeEnum>(const <
      AdminModerationAppealsResolve201ResponseCodeEnum
    >[
      _$adminModerationAppealsResolve201ResponseCodeEnum_number0,
      _$adminModerationAppealsResolve201ResponseCodeEnum_unknownDefaultOpenApi,
    ]);

Serializer<AdminModerationAppealsResolve201ResponseCodeEnum>
_$adminModerationAppealsResolve201ResponseCodeEnumSerializer =
    _$AdminModerationAppealsResolve201ResponseCodeEnumSerializer();

class _$AdminModerationAppealsResolve201ResponseCodeEnumSerializer
    implements
        PrimitiveSerializer<AdminModerationAppealsResolve201ResponseCodeEnum> {
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
    AdminModerationAppealsResolve201ResponseCodeEnum,
  ];
  @override
  final String wireName = 'AdminModerationAppealsResolve201ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    AdminModerationAppealsResolve201ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  AdminModerationAppealsResolve201ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => AdminModerationAppealsResolve201ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$AdminModerationAppealsResolve201Response
    extends AdminModerationAppealsResolve201Response {
  @override
  final ModerationAppealResponseDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$AdminModerationAppealsResolve201Response([
    void Function(AdminModerationAppealsResolve201ResponseBuilder)? updates,
  ]) => (AdminModerationAppealsResolve201ResponseBuilder()..update(updates))
      ._build();

  _$AdminModerationAppealsResolve201Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  AdminModerationAppealsResolve201Response rebuild(
    void Function(AdminModerationAppealsResolve201ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  AdminModerationAppealsResolve201ResponseBuilder toBuilder() =>
      AdminModerationAppealsResolve201ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminModerationAppealsResolve201Response &&
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
            r'AdminModerationAppealsResolve201Response',
          )
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class AdminModerationAppealsResolve201ResponseBuilder
    implements
        Builder<
          AdminModerationAppealsResolve201Response,
          AdminModerationAppealsResolve201ResponseBuilder
        >,
        ApiSuccessEnvelopeBuilder {
  _$AdminModerationAppealsResolve201Response? _$v;

  ModerationAppealResponseDtoBuilder? _data;
  ModerationAppealResponseDtoBuilder get data =>
      _$this._data ??= ModerationAppealResponseDtoBuilder();
  set data(covariant ModerationAppealResponseDtoBuilder? data) =>
      _$this._data = data;

  ApiSuccessEnvelopeCodeEnum? _code;
  ApiSuccessEnvelopeCodeEnum? get code => _$this._code;
  set code(covariant ApiSuccessEnvelopeCodeEnum? code) => _$this._code = code;

  String? _message;
  String? get message => _$this._message;
  set message(covariant String? message) => _$this._message = message;

  AdminModerationAppealsResolve201ResponseBuilder() {
    AdminModerationAppealsResolve201Response._defaults(this);
  }

  AdminModerationAppealsResolve201ResponseBuilder get _$this {
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
  void replace(covariant AdminModerationAppealsResolve201Response other) {
    _$v = other as _$AdminModerationAppealsResolve201Response;
  }

  @override
  void update(
    void Function(AdminModerationAppealsResolve201ResponseBuilder)? updates,
  ) {
    if (updates != null) updates(this);
  }

  @override
  AdminModerationAppealsResolve201Response build() => _build();

  _$AdminModerationAppealsResolve201Response _build() {
    _$AdminModerationAppealsResolve201Response _$result;
    try {
      _$result =
          _$v ??
          _$AdminModerationAppealsResolve201Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'AdminModerationAppealsResolve201Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'AdminModerationAppealsResolve201Response',
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
          r'AdminModerationAppealsResolve201Response',
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
