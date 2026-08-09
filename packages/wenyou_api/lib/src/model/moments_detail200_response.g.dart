// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'moments_detail200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const MomentsDetail200ResponseCodeEnum
_$momentsDetail200ResponseCodeEnum_number0 =
    const MomentsDetail200ResponseCodeEnum._('number0');
const MomentsDetail200ResponseCodeEnum
_$momentsDetail200ResponseCodeEnum_unknownDefaultOpenApi =
    const MomentsDetail200ResponseCodeEnum._('unknownDefaultOpenApi');

MomentsDetail200ResponseCodeEnum _$momentsDetail200ResponseCodeEnumValueOf(
  String name,
) {
  switch (name) {
    case 'number0':
      return _$momentsDetail200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$momentsDetail200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$momentsDetail200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<MomentsDetail200ResponseCodeEnum>
_$momentsDetail200ResponseCodeEnumValues =
    BuiltSet<MomentsDetail200ResponseCodeEnum>(
      const <MomentsDetail200ResponseCodeEnum>[
        _$momentsDetail200ResponseCodeEnum_number0,
        _$momentsDetail200ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<MomentsDetail200ResponseCodeEnum>
_$momentsDetail200ResponseCodeEnumSerializer =
    _$MomentsDetail200ResponseCodeEnumSerializer();

class _$MomentsDetail200ResponseCodeEnumSerializer
    implements PrimitiveSerializer<MomentsDetail200ResponseCodeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'number0': 0,
    'unknownDefaultOpenApi': 11184809,
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    0: 'number0',
    11184809: 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[MomentsDetail200ResponseCodeEnum];
  @override
  final String wireName = 'MomentsDetail200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    MomentsDetail200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  MomentsDetail200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => MomentsDetail200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$MomentsDetail200Response extends MomentsDetail200Response {
  @override
  final MomentDetailResponseDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$MomentsDetail200Response([
    void Function(MomentsDetail200ResponseBuilder)? updates,
  ]) => (MomentsDetail200ResponseBuilder()..update(updates))._build();

  _$MomentsDetail200Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  MomentsDetail200Response rebuild(
    void Function(MomentsDetail200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  MomentsDetail200ResponseBuilder toBuilder() =>
      MomentsDetail200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MomentsDetail200Response &&
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
    return (newBuiltValueToStringHelper(r'MomentsDetail200Response')
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class MomentsDetail200ResponseBuilder
    implements
        Builder<MomentsDetail200Response, MomentsDetail200ResponseBuilder>,
        ApiSuccessEnvelopeBuilder {
  _$MomentsDetail200Response? _$v;

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

  MomentsDetail200ResponseBuilder() {
    MomentsDetail200Response._defaults(this);
  }

  MomentsDetail200ResponseBuilder get _$this {
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
  void replace(covariant MomentsDetail200Response other) {
    _$v = other as _$MomentsDetail200Response;
  }

  @override
  void update(void Function(MomentsDetail200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  MomentsDetail200Response build() => _build();

  _$MomentsDetail200Response _build() {
    _$MomentsDetail200Response _$result;
    try {
      _$result =
          _$v ??
          _$MomentsDetail200Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'MomentsDetail200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'MomentsDetail200Response',
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
          r'MomentsDetail200Response',
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
