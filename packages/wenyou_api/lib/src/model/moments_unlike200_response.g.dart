// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'moments_unlike200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const MomentsUnlike200ResponseCodeEnum
_$momentsUnlike200ResponseCodeEnum_number0 =
    const MomentsUnlike200ResponseCodeEnum._('number0');
const MomentsUnlike200ResponseCodeEnum
_$momentsUnlike200ResponseCodeEnum_unknownDefaultOpenApi =
    const MomentsUnlike200ResponseCodeEnum._('unknownDefaultOpenApi');

MomentsUnlike200ResponseCodeEnum _$momentsUnlike200ResponseCodeEnumValueOf(
  String name,
) {
  switch (name) {
    case 'number0':
      return _$momentsUnlike200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$momentsUnlike200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$momentsUnlike200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<MomentsUnlike200ResponseCodeEnum>
_$momentsUnlike200ResponseCodeEnumValues =
    BuiltSet<MomentsUnlike200ResponseCodeEnum>(
      const <MomentsUnlike200ResponseCodeEnum>[
        _$momentsUnlike200ResponseCodeEnum_number0,
        _$momentsUnlike200ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<MomentsUnlike200ResponseCodeEnum>
_$momentsUnlike200ResponseCodeEnumSerializer =
    _$MomentsUnlike200ResponseCodeEnumSerializer();

class _$MomentsUnlike200ResponseCodeEnumSerializer
    implements PrimitiveSerializer<MomentsUnlike200ResponseCodeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'number0': 0,
    'unknownDefaultOpenApi': 11184809,
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    0: 'number0',
    11184809: 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[MomentsUnlike200ResponseCodeEnum];
  @override
  final String wireName = 'MomentsUnlike200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    MomentsUnlike200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  MomentsUnlike200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => MomentsUnlike200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$MomentsUnlike200Response extends MomentsUnlike200Response {
  @override
  final MomentActionResponseDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$MomentsUnlike200Response([
    void Function(MomentsUnlike200ResponseBuilder)? updates,
  ]) => (MomentsUnlike200ResponseBuilder()..update(updates))._build();

  _$MomentsUnlike200Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  MomentsUnlike200Response rebuild(
    void Function(MomentsUnlike200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  MomentsUnlike200ResponseBuilder toBuilder() =>
      MomentsUnlike200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MomentsUnlike200Response &&
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
    return (newBuiltValueToStringHelper(r'MomentsUnlike200Response')
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class MomentsUnlike200ResponseBuilder
    implements
        Builder<MomentsUnlike200Response, MomentsUnlike200ResponseBuilder>,
        ApiSuccessEnvelopeBuilder {
  _$MomentsUnlike200Response? _$v;

  MomentActionResponseDtoBuilder? _data;
  MomentActionResponseDtoBuilder get data =>
      _$this._data ??= MomentActionResponseDtoBuilder();
  set data(covariant MomentActionResponseDtoBuilder? data) =>
      _$this._data = data;

  ApiSuccessEnvelopeCodeEnum? _code;
  ApiSuccessEnvelopeCodeEnum? get code => _$this._code;
  set code(covariant ApiSuccessEnvelopeCodeEnum? code) => _$this._code = code;

  String? _message;
  String? get message => _$this._message;
  set message(covariant String? message) => _$this._message = message;

  MomentsUnlike200ResponseBuilder() {
    MomentsUnlike200Response._defaults(this);
  }

  MomentsUnlike200ResponseBuilder get _$this {
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
  void replace(covariant MomentsUnlike200Response other) {
    _$v = other as _$MomentsUnlike200Response;
  }

  @override
  void update(void Function(MomentsUnlike200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  MomentsUnlike200Response build() => _build();

  _$MomentsUnlike200Response _build() {
    _$MomentsUnlike200Response _$result;
    try {
      _$result =
          _$v ??
          _$MomentsUnlike200Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'MomentsUnlike200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'MomentsUnlike200Response',
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
          r'MomentsUnlike200Response',
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
