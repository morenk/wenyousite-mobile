// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'moments_remove_comment200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const MomentsRemoveComment200ResponseCodeEnum
_$momentsRemoveComment200ResponseCodeEnum_number0 =
    const MomentsRemoveComment200ResponseCodeEnum._('number0');
const MomentsRemoveComment200ResponseCodeEnum
_$momentsRemoveComment200ResponseCodeEnum_unknownDefaultOpenApi =
    const MomentsRemoveComment200ResponseCodeEnum._('unknownDefaultOpenApi');

MomentsRemoveComment200ResponseCodeEnum
_$momentsRemoveComment200ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$momentsRemoveComment200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$momentsRemoveComment200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$momentsRemoveComment200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<MomentsRemoveComment200ResponseCodeEnum>
_$momentsRemoveComment200ResponseCodeEnumValues =
    BuiltSet<MomentsRemoveComment200ResponseCodeEnum>(
      const <MomentsRemoveComment200ResponseCodeEnum>[
        _$momentsRemoveComment200ResponseCodeEnum_number0,
        _$momentsRemoveComment200ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<MomentsRemoveComment200ResponseCodeEnum>
_$momentsRemoveComment200ResponseCodeEnumSerializer =
    _$MomentsRemoveComment200ResponseCodeEnumSerializer();

class _$MomentsRemoveComment200ResponseCodeEnumSerializer
    implements PrimitiveSerializer<MomentsRemoveComment200ResponseCodeEnum> {
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
    MomentsRemoveComment200ResponseCodeEnum,
  ];
  @override
  final String wireName = 'MomentsRemoveComment200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    MomentsRemoveComment200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  MomentsRemoveComment200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => MomentsRemoveComment200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$MomentsRemoveComment200Response
    extends MomentsRemoveComment200Response {
  @override
  final MomentDeleteResponseDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$MomentsRemoveComment200Response([
    void Function(MomentsRemoveComment200ResponseBuilder)? updates,
  ]) => (MomentsRemoveComment200ResponseBuilder()..update(updates))._build();

  _$MomentsRemoveComment200Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  MomentsRemoveComment200Response rebuild(
    void Function(MomentsRemoveComment200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  MomentsRemoveComment200ResponseBuilder toBuilder() =>
      MomentsRemoveComment200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MomentsRemoveComment200Response &&
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
    return (newBuiltValueToStringHelper(r'MomentsRemoveComment200Response')
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class MomentsRemoveComment200ResponseBuilder
    implements
        Builder<
          MomentsRemoveComment200Response,
          MomentsRemoveComment200ResponseBuilder
        >,
        ApiSuccessEnvelopeBuilder {
  _$MomentsRemoveComment200Response? _$v;

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

  MomentsRemoveComment200ResponseBuilder() {
    MomentsRemoveComment200Response._defaults(this);
  }

  MomentsRemoveComment200ResponseBuilder get _$this {
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
  void replace(covariant MomentsRemoveComment200Response other) {
    _$v = other as _$MomentsRemoveComment200Response;
  }

  @override
  void update(void Function(MomentsRemoveComment200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  MomentsRemoveComment200Response build() => _build();

  _$MomentsRemoveComment200Response _build() {
    _$MomentsRemoveComment200Response _$result;
    try {
      _$result =
          _$v ??
          _$MomentsRemoveComment200Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'MomentsRemoveComment200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'MomentsRemoveComment200Response',
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
          r'MomentsRemoveComment200Response',
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
