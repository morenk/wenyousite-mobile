// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'moments_bookmark201_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const MomentsBookmark201ResponseCodeEnum
_$momentsBookmark201ResponseCodeEnum_number0 =
    const MomentsBookmark201ResponseCodeEnum._('number0');
const MomentsBookmark201ResponseCodeEnum
_$momentsBookmark201ResponseCodeEnum_unknownDefaultOpenApi =
    const MomentsBookmark201ResponseCodeEnum._('unknownDefaultOpenApi');

MomentsBookmark201ResponseCodeEnum _$momentsBookmark201ResponseCodeEnumValueOf(
  String name,
) {
  switch (name) {
    case 'number0':
      return _$momentsBookmark201ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$momentsBookmark201ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$momentsBookmark201ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<MomentsBookmark201ResponseCodeEnum>
_$momentsBookmark201ResponseCodeEnumValues =
    BuiltSet<MomentsBookmark201ResponseCodeEnum>(
      const <MomentsBookmark201ResponseCodeEnum>[
        _$momentsBookmark201ResponseCodeEnum_number0,
        _$momentsBookmark201ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<MomentsBookmark201ResponseCodeEnum>
_$momentsBookmark201ResponseCodeEnumSerializer =
    _$MomentsBookmark201ResponseCodeEnumSerializer();

class _$MomentsBookmark201ResponseCodeEnumSerializer
    implements PrimitiveSerializer<MomentsBookmark201ResponseCodeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'number0': 0,
    'unknownDefaultOpenApi': 11184809,
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    0: 'number0',
    11184809: 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[MomentsBookmark201ResponseCodeEnum];
  @override
  final String wireName = 'MomentsBookmark201ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    MomentsBookmark201ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  MomentsBookmark201ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => MomentsBookmark201ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$MomentsBookmark201Response extends MomentsBookmark201Response {
  @override
  final MomentActionResponseDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$MomentsBookmark201Response([
    void Function(MomentsBookmark201ResponseBuilder)? updates,
  ]) => (MomentsBookmark201ResponseBuilder()..update(updates))._build();

  _$MomentsBookmark201Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  MomentsBookmark201Response rebuild(
    void Function(MomentsBookmark201ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  MomentsBookmark201ResponseBuilder toBuilder() =>
      MomentsBookmark201ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MomentsBookmark201Response &&
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
    return (newBuiltValueToStringHelper(r'MomentsBookmark201Response')
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class MomentsBookmark201ResponseBuilder
    implements
        Builder<MomentsBookmark201Response, MomentsBookmark201ResponseBuilder>,
        ApiSuccessEnvelopeBuilder {
  _$MomentsBookmark201Response? _$v;

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

  MomentsBookmark201ResponseBuilder() {
    MomentsBookmark201Response._defaults(this);
  }

  MomentsBookmark201ResponseBuilder get _$this {
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
  void replace(covariant MomentsBookmark201Response other) {
    _$v = other as _$MomentsBookmark201Response;
  }

  @override
  void update(void Function(MomentsBookmark201ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  MomentsBookmark201Response build() => _build();

  _$MomentsBookmark201Response _build() {
    _$MomentsBookmark201Response _$result;
    try {
      _$result =
          _$v ??
          _$MomentsBookmark201Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'MomentsBookmark201Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'MomentsBookmark201Response',
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
          r'MomentsBookmark201Response',
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
