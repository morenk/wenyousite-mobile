// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'moments_update200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const MomentsUpdate200ResponseCodeEnum
_$momentsUpdate200ResponseCodeEnum_number0 =
    const MomentsUpdate200ResponseCodeEnum._('number0');
const MomentsUpdate200ResponseCodeEnum
_$momentsUpdate200ResponseCodeEnum_unknownDefaultOpenApi =
    const MomentsUpdate200ResponseCodeEnum._('unknownDefaultOpenApi');

MomentsUpdate200ResponseCodeEnum _$momentsUpdate200ResponseCodeEnumValueOf(
  String name,
) {
  switch (name) {
    case 'number0':
      return _$momentsUpdate200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$momentsUpdate200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$momentsUpdate200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<MomentsUpdate200ResponseCodeEnum>
_$momentsUpdate200ResponseCodeEnumValues =
    BuiltSet<MomentsUpdate200ResponseCodeEnum>(
      const <MomentsUpdate200ResponseCodeEnum>[
        _$momentsUpdate200ResponseCodeEnum_number0,
        _$momentsUpdate200ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<MomentsUpdate200ResponseCodeEnum>
_$momentsUpdate200ResponseCodeEnumSerializer =
    _$MomentsUpdate200ResponseCodeEnumSerializer();

class _$MomentsUpdate200ResponseCodeEnumSerializer
    implements PrimitiveSerializer<MomentsUpdate200ResponseCodeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'number0': 0,
    'unknownDefaultOpenApi': 11184809,
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    0: 'number0',
    11184809: 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[MomentsUpdate200ResponseCodeEnum];
  @override
  final String wireName = 'MomentsUpdate200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    MomentsUpdate200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  MomentsUpdate200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => MomentsUpdate200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$MomentsUpdate200Response extends MomentsUpdate200Response {
  @override
  final MomentDetailResponseDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$MomentsUpdate200Response([
    void Function(MomentsUpdate200ResponseBuilder)? updates,
  ]) => (MomentsUpdate200ResponseBuilder()..update(updates))._build();

  _$MomentsUpdate200Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  MomentsUpdate200Response rebuild(
    void Function(MomentsUpdate200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  MomentsUpdate200ResponseBuilder toBuilder() =>
      MomentsUpdate200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MomentsUpdate200Response &&
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
    return (newBuiltValueToStringHelper(r'MomentsUpdate200Response')
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class MomentsUpdate200ResponseBuilder
    implements
        Builder<MomentsUpdate200Response, MomentsUpdate200ResponseBuilder>,
        ApiSuccessEnvelopeBuilder {
  _$MomentsUpdate200Response? _$v;

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

  MomentsUpdate200ResponseBuilder() {
    MomentsUpdate200Response._defaults(this);
  }

  MomentsUpdate200ResponseBuilder get _$this {
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
  void replace(covariant MomentsUpdate200Response other) {
    _$v = other as _$MomentsUpdate200Response;
  }

  @override
  void update(void Function(MomentsUpdate200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  MomentsUpdate200Response build() => _build();

  _$MomentsUpdate200Response _build() {
    _$MomentsUpdate200Response _$result;
    try {
      _$result =
          _$v ??
          _$MomentsUpdate200Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'MomentsUpdate200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'MomentsUpdate200Response',
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
          r'MomentsUpdate200Response',
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
