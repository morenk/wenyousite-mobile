// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'moments_create_bookmark_folder201_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const MomentsCreateBookmarkFolder201ResponseCodeEnum
_$momentsCreateBookmarkFolder201ResponseCodeEnum_number0 =
    const MomentsCreateBookmarkFolder201ResponseCodeEnum._('number0');
const MomentsCreateBookmarkFolder201ResponseCodeEnum
_$momentsCreateBookmarkFolder201ResponseCodeEnum_unknownDefaultOpenApi =
    const MomentsCreateBookmarkFolder201ResponseCodeEnum._(
      'unknownDefaultOpenApi',
    );

MomentsCreateBookmarkFolder201ResponseCodeEnum
_$momentsCreateBookmarkFolder201ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$momentsCreateBookmarkFolder201ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$momentsCreateBookmarkFolder201ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$momentsCreateBookmarkFolder201ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<MomentsCreateBookmarkFolder201ResponseCodeEnum>
_$momentsCreateBookmarkFolder201ResponseCodeEnumValues =
    BuiltSet<MomentsCreateBookmarkFolder201ResponseCodeEnum>(
      const <MomentsCreateBookmarkFolder201ResponseCodeEnum>[
        _$momentsCreateBookmarkFolder201ResponseCodeEnum_number0,
        _$momentsCreateBookmarkFolder201ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<MomentsCreateBookmarkFolder201ResponseCodeEnum>
_$momentsCreateBookmarkFolder201ResponseCodeEnumSerializer =
    _$MomentsCreateBookmarkFolder201ResponseCodeEnumSerializer();

class _$MomentsCreateBookmarkFolder201ResponseCodeEnumSerializer
    implements
        PrimitiveSerializer<MomentsCreateBookmarkFolder201ResponseCodeEnum> {
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
    MomentsCreateBookmarkFolder201ResponseCodeEnum,
  ];
  @override
  final String wireName = 'MomentsCreateBookmarkFolder201ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    MomentsCreateBookmarkFolder201ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  MomentsCreateBookmarkFolder201ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => MomentsCreateBookmarkFolder201ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$MomentsCreateBookmarkFolder201Response
    extends MomentsCreateBookmarkFolder201Response {
  @override
  final MomentBookmarkFolderResponseDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$MomentsCreateBookmarkFolder201Response([
    void Function(MomentsCreateBookmarkFolder201ResponseBuilder)? updates,
  ]) => (MomentsCreateBookmarkFolder201ResponseBuilder()..update(updates))
      ._build();

  _$MomentsCreateBookmarkFolder201Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  MomentsCreateBookmarkFolder201Response rebuild(
    void Function(MomentsCreateBookmarkFolder201ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  MomentsCreateBookmarkFolder201ResponseBuilder toBuilder() =>
      MomentsCreateBookmarkFolder201ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MomentsCreateBookmarkFolder201Response &&
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
    return (newBuiltValueToStringHelper(
            r'MomentsCreateBookmarkFolder201Response',
          )
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class MomentsCreateBookmarkFolder201ResponseBuilder
    implements
        Builder<
          MomentsCreateBookmarkFolder201Response,
          MomentsCreateBookmarkFolder201ResponseBuilder
        >,
        ApiSuccessEnvelopeBuilder {
  _$MomentsCreateBookmarkFolder201Response? _$v;

  MomentBookmarkFolderResponseDtoBuilder? _data;
  MomentBookmarkFolderResponseDtoBuilder get data =>
      _$this._data ??= MomentBookmarkFolderResponseDtoBuilder();
  set data(covariant MomentBookmarkFolderResponseDtoBuilder? data) =>
      _$this._data = data;

  ApiSuccessEnvelopeCodeEnum? _code;
  ApiSuccessEnvelopeCodeEnum? get code => _$this._code;
  set code(covariant ApiSuccessEnvelopeCodeEnum? code) => _$this._code = code;

  String? _message;
  String? get message => _$this._message;
  set message(covariant String? message) => _$this._message = message;

  MomentsCreateBookmarkFolder201ResponseBuilder() {
    MomentsCreateBookmarkFolder201Response._defaults(this);
  }

  MomentsCreateBookmarkFolder201ResponseBuilder get _$this {
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
  void replace(covariant MomentsCreateBookmarkFolder201Response other) {
    _$v = other as _$MomentsCreateBookmarkFolder201Response;
  }

  @override
  void update(
    void Function(MomentsCreateBookmarkFolder201ResponseBuilder)? updates,
  ) {
    if (updates != null) updates(this);
  }

  @override
  MomentsCreateBookmarkFolder201Response build() => _build();

  _$MomentsCreateBookmarkFolder201Response _build() {
    _$MomentsCreateBookmarkFolder201Response _$result;
    try {
      _$result =
          _$v ??
          _$MomentsCreateBookmarkFolder201Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'MomentsCreateBookmarkFolder201Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'MomentsCreateBookmarkFolder201Response',
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
          r'MomentsCreateBookmarkFolder201Response',
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
