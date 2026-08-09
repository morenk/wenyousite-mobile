// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'moments_create201_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const MomentsCreate201ResponseCodeEnum
_$momentsCreate201ResponseCodeEnum_number0 =
    const MomentsCreate201ResponseCodeEnum._('number0');
const MomentsCreate201ResponseCodeEnum
_$momentsCreate201ResponseCodeEnum_unknownDefaultOpenApi =
    const MomentsCreate201ResponseCodeEnum._('unknownDefaultOpenApi');

MomentsCreate201ResponseCodeEnum _$momentsCreate201ResponseCodeEnumValueOf(
  String name,
) {
  switch (name) {
    case 'number0':
      return _$momentsCreate201ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$momentsCreate201ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$momentsCreate201ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<MomentsCreate201ResponseCodeEnum>
_$momentsCreate201ResponseCodeEnumValues =
    BuiltSet<MomentsCreate201ResponseCodeEnum>(
      const <MomentsCreate201ResponseCodeEnum>[
        _$momentsCreate201ResponseCodeEnum_number0,
        _$momentsCreate201ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<MomentsCreate201ResponseCodeEnum>
_$momentsCreate201ResponseCodeEnumSerializer =
    _$MomentsCreate201ResponseCodeEnumSerializer();

class _$MomentsCreate201ResponseCodeEnumSerializer
    implements PrimitiveSerializer<MomentsCreate201ResponseCodeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'number0': 0,
    'unknownDefaultOpenApi': 11184809,
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    0: 'number0',
    11184809: 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[MomentsCreate201ResponseCodeEnum];
  @override
  final String wireName = 'MomentsCreate201ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    MomentsCreate201ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  MomentsCreate201ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => MomentsCreate201ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$MomentsCreate201Response extends MomentsCreate201Response {
  @override
  final MomentDetailResponseDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$MomentsCreate201Response([
    void Function(MomentsCreate201ResponseBuilder)? updates,
  ]) => (MomentsCreate201ResponseBuilder()..update(updates))._build();

  _$MomentsCreate201Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  MomentsCreate201Response rebuild(
    void Function(MomentsCreate201ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  MomentsCreate201ResponseBuilder toBuilder() =>
      MomentsCreate201ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MomentsCreate201Response &&
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
    return (newBuiltValueToStringHelper(r'MomentsCreate201Response')
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class MomentsCreate201ResponseBuilder
    implements
        Builder<MomentsCreate201Response, MomentsCreate201ResponseBuilder>,
        ApiSuccessEnvelopeBuilder {
  _$MomentsCreate201Response? _$v;

  MomentDetailResponseDtoBuilder? _data;
  MomentDetailResponseDtoBuilder get data =>
      _$this._data ??= MomentDetailResponseDtoBuilder();
  set data(covariant MomentDetailResponseDtoBuilder? data) =>
      _$this._data = data;

  ApiSuccessEnvelopeCodeEnum? _code;
  ApiSuccessEnvelopeCodeEnum? get code => _$this._code;
  set code(covariant ApiSuccessEnvelopeCodeEnum? code) => _$this._code = code;

  String? _message;
  String? get message => _$this._message;
  set message(covariant String? message) => _$this._message = message;

  MomentsCreate201ResponseBuilder() {
    MomentsCreate201Response._defaults(this);
  }

  MomentsCreate201ResponseBuilder get _$this {
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
  void replace(covariant MomentsCreate201Response other) {
    _$v = other as _$MomentsCreate201Response;
  }

  @override
  void update(void Function(MomentsCreate201ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  MomentsCreate201Response build() => _build();

  _$MomentsCreate201Response _build() {
    _$MomentsCreate201Response _$result;
    try {
      _$result =
          _$v ??
          _$MomentsCreate201Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'MomentsCreate201Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'MomentsCreate201Response',
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
          r'MomentsCreate201Response',
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
