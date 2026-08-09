// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'moments_remove200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const MomentsRemove200ResponseCodeEnum
_$momentsRemove200ResponseCodeEnum_number0 =
    const MomentsRemove200ResponseCodeEnum._('number0');
const MomentsRemove200ResponseCodeEnum
_$momentsRemove200ResponseCodeEnum_unknownDefaultOpenApi =
    const MomentsRemove200ResponseCodeEnum._('unknownDefaultOpenApi');

MomentsRemove200ResponseCodeEnum _$momentsRemove200ResponseCodeEnumValueOf(
  String name,
) {
  switch (name) {
    case 'number0':
      return _$momentsRemove200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$momentsRemove200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$momentsRemove200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<MomentsRemove200ResponseCodeEnum>
_$momentsRemove200ResponseCodeEnumValues =
    BuiltSet<MomentsRemove200ResponseCodeEnum>(
      const <MomentsRemove200ResponseCodeEnum>[
        _$momentsRemove200ResponseCodeEnum_number0,
        _$momentsRemove200ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<MomentsRemove200ResponseCodeEnum>
_$momentsRemove200ResponseCodeEnumSerializer =
    _$MomentsRemove200ResponseCodeEnumSerializer();

class _$MomentsRemove200ResponseCodeEnumSerializer
    implements PrimitiveSerializer<MomentsRemove200ResponseCodeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'number0': 0,
    'unknownDefaultOpenApi': 11184809,
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    0: 'number0',
    11184809: 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[MomentsRemove200ResponseCodeEnum];
  @override
  final String wireName = 'MomentsRemove200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    MomentsRemove200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  MomentsRemove200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => MomentsRemove200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$MomentsRemove200Response extends MomentsRemove200Response {
  @override
  final MomentDeleteResponseDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$MomentsRemove200Response([
    void Function(MomentsRemove200ResponseBuilder)? updates,
  ]) => (MomentsRemove200ResponseBuilder()..update(updates))._build();

  _$MomentsRemove200Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  MomentsRemove200Response rebuild(
    void Function(MomentsRemove200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  MomentsRemove200ResponseBuilder toBuilder() =>
      MomentsRemove200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MomentsRemove200Response &&
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
    return (newBuiltValueToStringHelper(r'MomentsRemove200Response')
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class MomentsRemove200ResponseBuilder
    implements
        Builder<MomentsRemove200Response, MomentsRemove200ResponseBuilder>,
        ApiSuccessEnvelopeBuilder {
  _$MomentsRemove200Response? _$v;

  MomentDeleteResponseDtoBuilder? _data;
  MomentDeleteResponseDtoBuilder get data =>
      _$this._data ??= MomentDeleteResponseDtoBuilder();
  set data(covariant MomentDeleteResponseDtoBuilder? data) =>
      _$this._data = data;

  ApiSuccessEnvelopeCodeEnum? _code;
  ApiSuccessEnvelopeCodeEnum? get code => _$this._code;
  set code(covariant ApiSuccessEnvelopeCodeEnum? code) => _$this._code = code;

  String? _message;
  String? get message => _$this._message;
  set message(covariant String? message) => _$this._message = message;

  MomentsRemove200ResponseBuilder() {
    MomentsRemove200Response._defaults(this);
  }

  MomentsRemove200ResponseBuilder get _$this {
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
  void replace(covariant MomentsRemove200Response other) {
    _$v = other as _$MomentsRemove200Response;
  }

  @override
  void update(void Function(MomentsRemove200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  MomentsRemove200Response build() => _build();

  _$MomentsRemove200Response _build() {
    _$MomentsRemove200Response _$result;
    try {
      _$result =
          _$v ??
          _$MomentsRemove200Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'MomentsRemove200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'MomentsRemove200Response',
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
          r'MomentsRemove200Response',
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
