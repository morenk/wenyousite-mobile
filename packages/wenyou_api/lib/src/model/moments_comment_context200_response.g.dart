// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'moments_comment_context200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const MomentsCommentContext200ResponseCodeEnum
_$momentsCommentContext200ResponseCodeEnum_number0 =
    const MomentsCommentContext200ResponseCodeEnum._('number0');
const MomentsCommentContext200ResponseCodeEnum
_$momentsCommentContext200ResponseCodeEnum_unknownDefaultOpenApi =
    const MomentsCommentContext200ResponseCodeEnum._('unknownDefaultOpenApi');

MomentsCommentContext200ResponseCodeEnum
_$momentsCommentContext200ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$momentsCommentContext200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$momentsCommentContext200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$momentsCommentContext200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<MomentsCommentContext200ResponseCodeEnum>
_$momentsCommentContext200ResponseCodeEnumValues =
    BuiltSet<MomentsCommentContext200ResponseCodeEnum>(
      const <MomentsCommentContext200ResponseCodeEnum>[
        _$momentsCommentContext200ResponseCodeEnum_number0,
        _$momentsCommentContext200ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<MomentsCommentContext200ResponseCodeEnum>
_$momentsCommentContext200ResponseCodeEnumSerializer =
    _$MomentsCommentContext200ResponseCodeEnumSerializer();

class _$MomentsCommentContext200ResponseCodeEnumSerializer
    implements PrimitiveSerializer<MomentsCommentContext200ResponseCodeEnum> {
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
    MomentsCommentContext200ResponseCodeEnum,
  ];
  @override
  final String wireName = 'MomentsCommentContext200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    MomentsCommentContext200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  MomentsCommentContext200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => MomentsCommentContext200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$MomentsCommentContext200Response
    extends MomentsCommentContext200Response {
  @override
  final MomentCommentContextResponseDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$MomentsCommentContext200Response([
    void Function(MomentsCommentContext200ResponseBuilder)? updates,
  ]) => (MomentsCommentContext200ResponseBuilder()..update(updates))._build();

  _$MomentsCommentContext200Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  MomentsCommentContext200Response rebuild(
    void Function(MomentsCommentContext200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  MomentsCommentContext200ResponseBuilder toBuilder() =>
      MomentsCommentContext200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MomentsCommentContext200Response &&
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
    return (newBuiltValueToStringHelper(r'MomentsCommentContext200Response')
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class MomentsCommentContext200ResponseBuilder
    implements
        Builder<
          MomentsCommentContext200Response,
          MomentsCommentContext200ResponseBuilder
        >,
        ApiSuccessEnvelopeBuilder {
  _$MomentsCommentContext200Response? _$v;

  MomentCommentContextResponseDtoBuilder? _data;
  MomentCommentContextResponseDtoBuilder get data =>
      _$this._data ??= MomentCommentContextResponseDtoBuilder();
  set data(covariant MomentCommentContextResponseDtoBuilder? data) =>
      _$this._data = data;

  ApiSuccessEnvelopeCodeEnum? _code;
  ApiSuccessEnvelopeCodeEnum? get code => _$this._code;
  set code(covariant ApiSuccessEnvelopeCodeEnum? code) => _$this._code = code;

  String? _message;
  String? get message => _$this._message;
  set message(covariant String? message) => _$this._message = message;

  MomentsCommentContext200ResponseBuilder() {
    MomentsCommentContext200Response._defaults(this);
  }

  MomentsCommentContext200ResponseBuilder get _$this {
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
  void replace(covariant MomentsCommentContext200Response other) {
    _$v = other as _$MomentsCommentContext200Response;
  }

  @override
  void update(void Function(MomentsCommentContext200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  MomentsCommentContext200Response build() => _build();

  _$MomentsCommentContext200Response _build() {
    _$MomentsCommentContext200Response _$result;
    try {
      _$result =
          _$v ??
          _$MomentsCommentContext200Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'MomentsCommentContext200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'MomentsCommentContext200Response',
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
          r'MomentsCommentContext200Response',
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
