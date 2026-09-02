// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stickers_import_moment_comment_image201_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const StickersImportMomentCommentImage201ResponseCodeEnum
_$stickersImportMomentCommentImage201ResponseCodeEnum_number0 =
    const StickersImportMomentCommentImage201ResponseCodeEnum._('number0');
const StickersImportMomentCommentImage201ResponseCodeEnum
_$stickersImportMomentCommentImage201ResponseCodeEnum_unknownDefaultOpenApi =
    const StickersImportMomentCommentImage201ResponseCodeEnum._(
      'unknownDefaultOpenApi',
    );

StickersImportMomentCommentImage201ResponseCodeEnum
_$stickersImportMomentCommentImage201ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$stickersImportMomentCommentImage201ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$stickersImportMomentCommentImage201ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$stickersImportMomentCommentImage201ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<StickersImportMomentCommentImage201ResponseCodeEnum>
_$stickersImportMomentCommentImage201ResponseCodeEnumValues =
    BuiltSet<StickersImportMomentCommentImage201ResponseCodeEnum>(const <
      StickersImportMomentCommentImage201ResponseCodeEnum
    >[
      _$stickersImportMomentCommentImage201ResponseCodeEnum_number0,
      _$stickersImportMomentCommentImage201ResponseCodeEnum_unknownDefaultOpenApi,
    ]);

Serializer<StickersImportMomentCommentImage201ResponseCodeEnum>
_$stickersImportMomentCommentImage201ResponseCodeEnumSerializer =
    _$StickersImportMomentCommentImage201ResponseCodeEnumSerializer();

class _$StickersImportMomentCommentImage201ResponseCodeEnumSerializer
    implements
        PrimitiveSerializer<
          StickersImportMomentCommentImage201ResponseCodeEnum
        > {
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
    StickersImportMomentCommentImage201ResponseCodeEnum,
  ];
  @override
  final String wireName = 'StickersImportMomentCommentImage201ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    StickersImportMomentCommentImage201ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  StickersImportMomentCommentImage201ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => StickersImportMomentCommentImage201ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$StickersImportMomentCommentImage201Response
    extends StickersImportMomentCommentImage201Response {
  @override
  final StickerImportResponseDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$StickersImportMomentCommentImage201Response([
    void Function(StickersImportMomentCommentImage201ResponseBuilder)? updates,
  ]) => (StickersImportMomentCommentImage201ResponseBuilder()..update(updates))
      ._build();

  _$StickersImportMomentCommentImage201Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  StickersImportMomentCommentImage201Response rebuild(
    void Function(StickersImportMomentCommentImage201ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  StickersImportMomentCommentImage201ResponseBuilder toBuilder() =>
      StickersImportMomentCommentImage201ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is StickersImportMomentCommentImage201Response &&
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
            r'StickersImportMomentCommentImage201Response',
          )
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class StickersImportMomentCommentImage201ResponseBuilder
    implements
        Builder<
          StickersImportMomentCommentImage201Response,
          StickersImportMomentCommentImage201ResponseBuilder
        >,
        ApiSuccessEnvelopeBuilder {
  _$StickersImportMomentCommentImage201Response? _$v;

  StickerImportResponseDtoBuilder? _data;
  StickerImportResponseDtoBuilder get data =>
      _$this._data ??= StickerImportResponseDtoBuilder();
  set data(covariant StickerImportResponseDtoBuilder? data) =>
      _$this._data = data;

  ApiSuccessEnvelopeCodeEnum? _code;
  ApiSuccessEnvelopeCodeEnum? get code => _$this._code;
  set code(covariant ApiSuccessEnvelopeCodeEnum? code) => _$this._code = code;

  String? _message;
  String? get message => _$this._message;
  set message(covariant String? message) => _$this._message = message;

  StickersImportMomentCommentImage201ResponseBuilder() {
    StickersImportMomentCommentImage201Response._defaults(this);
  }

  StickersImportMomentCommentImage201ResponseBuilder get _$this {
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
  void replace(covariant StickersImportMomentCommentImage201Response other) {
    _$v = other as _$StickersImportMomentCommentImage201Response;
  }

  @override
  void update(
    void Function(StickersImportMomentCommentImage201ResponseBuilder)? updates,
  ) {
    if (updates != null) updates(this);
  }

  @override
  StickersImportMomentCommentImage201Response build() => _build();

  _$StickersImportMomentCommentImage201Response _build() {
    _$StickersImportMomentCommentImage201Response _$result;
    try {
      _$result =
          _$v ??
          _$StickersImportMomentCommentImage201Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'StickersImportMomentCommentImage201Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'StickersImportMomentCommentImage201Response',
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
          r'StickersImportMomentCommentImage201Response',
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
