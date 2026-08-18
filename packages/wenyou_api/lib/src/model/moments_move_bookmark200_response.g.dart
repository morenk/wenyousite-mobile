// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'moments_move_bookmark200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const MomentsMoveBookmark200ResponseCodeEnum
_$momentsMoveBookmark200ResponseCodeEnum_number0 =
    const MomentsMoveBookmark200ResponseCodeEnum._('number0');
const MomentsMoveBookmark200ResponseCodeEnum
_$momentsMoveBookmark200ResponseCodeEnum_unknownDefaultOpenApi =
    const MomentsMoveBookmark200ResponseCodeEnum._('unknownDefaultOpenApi');

MomentsMoveBookmark200ResponseCodeEnum
_$momentsMoveBookmark200ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$momentsMoveBookmark200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$momentsMoveBookmark200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$momentsMoveBookmark200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<MomentsMoveBookmark200ResponseCodeEnum>
_$momentsMoveBookmark200ResponseCodeEnumValues =
    BuiltSet<MomentsMoveBookmark200ResponseCodeEnum>(
      const <MomentsMoveBookmark200ResponseCodeEnum>[
        _$momentsMoveBookmark200ResponseCodeEnum_number0,
        _$momentsMoveBookmark200ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<MomentsMoveBookmark200ResponseCodeEnum>
_$momentsMoveBookmark200ResponseCodeEnumSerializer =
    _$MomentsMoveBookmark200ResponseCodeEnumSerializer();

class _$MomentsMoveBookmark200ResponseCodeEnumSerializer
    implements PrimitiveSerializer<MomentsMoveBookmark200ResponseCodeEnum> {
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
    MomentsMoveBookmark200ResponseCodeEnum,
  ];
  @override
  final String wireName = 'MomentsMoveBookmark200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    MomentsMoveBookmark200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  MomentsMoveBookmark200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => MomentsMoveBookmark200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$MomentsMoveBookmark200Response extends MomentsMoveBookmark200Response {
  @override
  final MomentBookmarkPlacementResponseDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$MomentsMoveBookmark200Response([
    void Function(MomentsMoveBookmark200ResponseBuilder)? updates,
  ]) => (MomentsMoveBookmark200ResponseBuilder()..update(updates))._build();

  _$MomentsMoveBookmark200Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  MomentsMoveBookmark200Response rebuild(
    void Function(MomentsMoveBookmark200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  MomentsMoveBookmark200ResponseBuilder toBuilder() =>
      MomentsMoveBookmark200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MomentsMoveBookmark200Response &&
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
    return (newBuiltValueToStringHelper(r'MomentsMoveBookmark200Response')
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class MomentsMoveBookmark200ResponseBuilder
    implements
        Builder<
          MomentsMoveBookmark200Response,
          MomentsMoveBookmark200ResponseBuilder
        >,
        ApiSuccessEnvelopeBuilder {
  _$MomentsMoveBookmark200Response? _$v;

  MomentBookmarkPlacementResponseDtoBuilder? _data;
  MomentBookmarkPlacementResponseDtoBuilder get data =>
      _$this._data ??= MomentBookmarkPlacementResponseDtoBuilder();
  set data(covariant MomentBookmarkPlacementResponseDtoBuilder? data) =>
      _$this._data = data;

  ApiSuccessEnvelopeCodeEnum? _code;
  ApiSuccessEnvelopeCodeEnum? get code => _$this._code;
  set code(covariant ApiSuccessEnvelopeCodeEnum? code) => _$this._code = code;

  String? _message;
  String? get message => _$this._message;
  set message(covariant String? message) => _$this._message = message;

  MomentsMoveBookmark200ResponseBuilder() {
    MomentsMoveBookmark200Response._defaults(this);
  }

  MomentsMoveBookmark200ResponseBuilder get _$this {
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
  void replace(covariant MomentsMoveBookmark200Response other) {
    _$v = other as _$MomentsMoveBookmark200Response;
  }

  @override
  void update(void Function(MomentsMoveBookmark200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  MomentsMoveBookmark200Response build() => _build();

  _$MomentsMoveBookmark200Response _build() {
    _$MomentsMoveBookmark200Response _$result;
    try {
      _$result =
          _$v ??
          _$MomentsMoveBookmark200Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'MomentsMoveBookmark200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'MomentsMoveBookmark200Response',
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
          r'MomentsMoveBookmark200Response',
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
