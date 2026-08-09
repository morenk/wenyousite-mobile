// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'moments_create_comment201_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const MomentsCreateComment201ResponseCodeEnum
_$momentsCreateComment201ResponseCodeEnum_number0 =
    const MomentsCreateComment201ResponseCodeEnum._('number0');
const MomentsCreateComment201ResponseCodeEnum
_$momentsCreateComment201ResponseCodeEnum_unknownDefaultOpenApi =
    const MomentsCreateComment201ResponseCodeEnum._('unknownDefaultOpenApi');

MomentsCreateComment201ResponseCodeEnum
_$momentsCreateComment201ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$momentsCreateComment201ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$momentsCreateComment201ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$momentsCreateComment201ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<MomentsCreateComment201ResponseCodeEnum>
_$momentsCreateComment201ResponseCodeEnumValues =
    BuiltSet<MomentsCreateComment201ResponseCodeEnum>(
      const <MomentsCreateComment201ResponseCodeEnum>[
        _$momentsCreateComment201ResponseCodeEnum_number0,
        _$momentsCreateComment201ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<MomentsCreateComment201ResponseCodeEnum>
_$momentsCreateComment201ResponseCodeEnumSerializer =
    _$MomentsCreateComment201ResponseCodeEnumSerializer();

class _$MomentsCreateComment201ResponseCodeEnumSerializer
    implements PrimitiveSerializer<MomentsCreateComment201ResponseCodeEnum> {
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
    MomentsCreateComment201ResponseCodeEnum,
  ];
  @override
  final String wireName = 'MomentsCreateComment201ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    MomentsCreateComment201ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  MomentsCreateComment201ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => MomentsCreateComment201ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$MomentsCreateComment201Response
    extends MomentsCreateComment201Response {
  @override
  final MomentCommentResponseDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$MomentsCreateComment201Response([
    void Function(MomentsCreateComment201ResponseBuilder)? updates,
  ]) => (MomentsCreateComment201ResponseBuilder()..update(updates))._build();

  _$MomentsCreateComment201Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  MomentsCreateComment201Response rebuild(
    void Function(MomentsCreateComment201ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  MomentsCreateComment201ResponseBuilder toBuilder() =>
      MomentsCreateComment201ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MomentsCreateComment201Response &&
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
    return (newBuiltValueToStringHelper(r'MomentsCreateComment201Response')
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class MomentsCreateComment201ResponseBuilder
    implements
        Builder<
          MomentsCreateComment201Response,
          MomentsCreateComment201ResponseBuilder
        >,
        ApiSuccessEnvelopeBuilder {
  _$MomentsCreateComment201Response? _$v;

  MomentCommentResponseDtoBuilder? _data;
  MomentCommentResponseDtoBuilder get data =>
      _$this._data ??= MomentCommentResponseDtoBuilder();
  set data(covariant MomentCommentResponseDtoBuilder? data) =>
      _$this._data = data;

  ApiSuccessEnvelopeCodeEnum? _code;
  ApiSuccessEnvelopeCodeEnum? get code => _$this._code;
  set code(covariant ApiSuccessEnvelopeCodeEnum? code) => _$this._code = code;

  String? _message;
  String? get message => _$this._message;
  set message(covariant String? message) => _$this._message = message;

  MomentsCreateComment201ResponseBuilder() {
    MomentsCreateComment201Response._defaults(this);
  }

  MomentsCreateComment201ResponseBuilder get _$this {
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
  void replace(covariant MomentsCreateComment201Response other) {
    _$v = other as _$MomentsCreateComment201Response;
  }

  @override
  void update(void Function(MomentsCreateComment201ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  MomentsCreateComment201Response build() => _build();

  _$MomentsCreateComment201Response _build() {
    _$MomentsCreateComment201Response _$result;
    try {
      _$result =
          _$v ??
          _$MomentsCreateComment201Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'MomentsCreateComment201Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'MomentsCreateComment201Response',
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
          r'MomentsCreateComment201Response',
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
