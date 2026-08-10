// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'moderation_cases_resolve201_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ModerationCasesResolve201ResponseCodeEnum
_$moderationCasesResolve201ResponseCodeEnum_number0 =
    const ModerationCasesResolve201ResponseCodeEnum._('number0');
const ModerationCasesResolve201ResponseCodeEnum
_$moderationCasesResolve201ResponseCodeEnum_unknownDefaultOpenApi =
    const ModerationCasesResolve201ResponseCodeEnum._('unknownDefaultOpenApi');

ModerationCasesResolve201ResponseCodeEnum
_$moderationCasesResolve201ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$moderationCasesResolve201ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$moderationCasesResolve201ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$moderationCasesResolve201ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<ModerationCasesResolve201ResponseCodeEnum>
_$moderationCasesResolve201ResponseCodeEnumValues =
    BuiltSet<ModerationCasesResolve201ResponseCodeEnum>(
      const <ModerationCasesResolve201ResponseCodeEnum>[
        _$moderationCasesResolve201ResponseCodeEnum_number0,
        _$moderationCasesResolve201ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<ModerationCasesResolve201ResponseCodeEnum>
_$moderationCasesResolve201ResponseCodeEnumSerializer =
    _$ModerationCasesResolve201ResponseCodeEnumSerializer();

class _$ModerationCasesResolve201ResponseCodeEnumSerializer
    implements PrimitiveSerializer<ModerationCasesResolve201ResponseCodeEnum> {
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
    ModerationCasesResolve201ResponseCodeEnum,
  ];
  @override
  final String wireName = 'ModerationCasesResolve201ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    ModerationCasesResolve201ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  ModerationCasesResolve201ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => ModerationCasesResolve201ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$ModerationCasesResolve201Response
    extends ModerationCasesResolve201Response {
  @override
  final ModerationCaseResponseDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$ModerationCasesResolve201Response([
    void Function(ModerationCasesResolve201ResponseBuilder)? updates,
  ]) => (ModerationCasesResolve201ResponseBuilder()..update(updates))._build();

  _$ModerationCasesResolve201Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  ModerationCasesResolve201Response rebuild(
    void Function(ModerationCasesResolve201ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  ModerationCasesResolve201ResponseBuilder toBuilder() =>
      ModerationCasesResolve201ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ModerationCasesResolve201Response &&
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
    return (newBuiltValueToStringHelper(r'ModerationCasesResolve201Response')
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class ModerationCasesResolve201ResponseBuilder
    implements
        Builder<
          ModerationCasesResolve201Response,
          ModerationCasesResolve201ResponseBuilder
        >,
        ApiSuccessEnvelopeBuilder {
  _$ModerationCasesResolve201Response? _$v;

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

  ModerationCasesResolve201ResponseBuilder() {
    ModerationCasesResolve201Response._defaults(this);
  }

  ModerationCasesResolve201ResponseBuilder get _$this {
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
  void replace(covariant ModerationCasesResolve201Response other) {
    _$v = other as _$ModerationCasesResolve201Response;
  }

  @override
  void update(
    void Function(ModerationCasesResolve201ResponseBuilder)? updates,
  ) {
    if (updates != null) updates(this);
  }

  @override
  ModerationCasesResolve201Response build() => _build();

  _$ModerationCasesResolve201Response _build() {
    _$ModerationCasesResolve201Response _$result;
    try {
      _$result =
          _$v ??
          _$ModerationCasesResolve201Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'ModerationCasesResolve201Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'ModerationCasesResolve201Response',
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
          r'ModerationCasesResolve201Response',
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
