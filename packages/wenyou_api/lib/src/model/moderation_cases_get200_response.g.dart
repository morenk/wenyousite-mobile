// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'moderation_cases_get200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ModerationCasesGet200ResponseCodeEnum
_$moderationCasesGet200ResponseCodeEnum_number0 =
    const ModerationCasesGet200ResponseCodeEnum._('number0');
const ModerationCasesGet200ResponseCodeEnum
_$moderationCasesGet200ResponseCodeEnum_unknownDefaultOpenApi =
    const ModerationCasesGet200ResponseCodeEnum._('unknownDefaultOpenApi');

ModerationCasesGet200ResponseCodeEnum
_$moderationCasesGet200ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$moderationCasesGet200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$moderationCasesGet200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$moderationCasesGet200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<ModerationCasesGet200ResponseCodeEnum>
_$moderationCasesGet200ResponseCodeEnumValues =
    BuiltSet<ModerationCasesGet200ResponseCodeEnum>(
      const <ModerationCasesGet200ResponseCodeEnum>[
        _$moderationCasesGet200ResponseCodeEnum_number0,
        _$moderationCasesGet200ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<ModerationCasesGet200ResponseCodeEnum>
_$moderationCasesGet200ResponseCodeEnumSerializer =
    _$ModerationCasesGet200ResponseCodeEnumSerializer();

class _$ModerationCasesGet200ResponseCodeEnumSerializer
    implements PrimitiveSerializer<ModerationCasesGet200ResponseCodeEnum> {
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
    ModerationCasesGet200ResponseCodeEnum,
  ];
  @override
  final String wireName = 'ModerationCasesGet200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    ModerationCasesGet200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  ModerationCasesGet200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => ModerationCasesGet200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$ModerationCasesGet200Response extends ModerationCasesGet200Response {
  @override
  final ModerationCaseResponseDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$ModerationCasesGet200Response([
    void Function(ModerationCasesGet200ResponseBuilder)? updates,
  ]) => (ModerationCasesGet200ResponseBuilder()..update(updates))._build();

  _$ModerationCasesGet200Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  ModerationCasesGet200Response rebuild(
    void Function(ModerationCasesGet200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  ModerationCasesGet200ResponseBuilder toBuilder() =>
      ModerationCasesGet200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ModerationCasesGet200Response &&
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
    return (newBuiltValueToStringHelper(r'ModerationCasesGet200Response')
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class ModerationCasesGet200ResponseBuilder
    implements
        Builder<
          ModerationCasesGet200Response,
          ModerationCasesGet200ResponseBuilder
        >,
        ApiSuccessEnvelopeBuilder {
  _$ModerationCasesGet200Response? _$v;

  ModerationCaseResponseDtoBuilder? _data;
  ModerationCaseResponseDtoBuilder get data =>
      _$this._data ??= ModerationCaseResponseDtoBuilder();
  set data(covariant ModerationCaseResponseDtoBuilder? data) =>
      _$this._data = data;

  ApiSuccessEnvelopeCodeEnum? _code;
  ApiSuccessEnvelopeCodeEnum? get code => _$this._code;
  set code(covariant ApiSuccessEnvelopeCodeEnum? code) => _$this._code = code;

  String? _message;
  String? get message => _$this._message;
  set message(covariant String? message) => _$this._message = message;

  ModerationCasesGet200ResponseBuilder() {
    ModerationCasesGet200Response._defaults(this);
  }

  ModerationCasesGet200ResponseBuilder get _$this {
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
  void replace(covariant ModerationCasesGet200Response other) {
    _$v = other as _$ModerationCasesGet200Response;
  }

  @override
  void update(void Function(ModerationCasesGet200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ModerationCasesGet200Response build() => _build();

  _$ModerationCasesGet200Response _build() {
    _$ModerationCasesGet200Response _$result;
    try {
      _$result =
          _$v ??
          _$ModerationCasesGet200Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'ModerationCasesGet200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'ModerationCasesGet200Response',
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
          r'ModerationCasesGet200Response',
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
