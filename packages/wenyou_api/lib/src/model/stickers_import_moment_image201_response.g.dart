// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stickers_import_moment_image201_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const StickersImportMomentImage201ResponseCodeEnum
_$stickersImportMomentImage201ResponseCodeEnum_number0 =
    const StickersImportMomentImage201ResponseCodeEnum._('number0');
const StickersImportMomentImage201ResponseCodeEnum
_$stickersImportMomentImage201ResponseCodeEnum_unknownDefaultOpenApi =
    const StickersImportMomentImage201ResponseCodeEnum._(
      'unknownDefaultOpenApi',
    );

StickersImportMomentImage201ResponseCodeEnum
_$stickersImportMomentImage201ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$stickersImportMomentImage201ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$stickersImportMomentImage201ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$stickersImportMomentImage201ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<StickersImportMomentImage201ResponseCodeEnum>
_$stickersImportMomentImage201ResponseCodeEnumValues =
    BuiltSet<StickersImportMomentImage201ResponseCodeEnum>(
      const <StickersImportMomentImage201ResponseCodeEnum>[
        _$stickersImportMomentImage201ResponseCodeEnum_number0,
        _$stickersImportMomentImage201ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<StickersImportMomentImage201ResponseCodeEnum>
_$stickersImportMomentImage201ResponseCodeEnumSerializer =
    _$StickersImportMomentImage201ResponseCodeEnumSerializer();

class _$StickersImportMomentImage201ResponseCodeEnumSerializer
    implements
        PrimitiveSerializer<StickersImportMomentImage201ResponseCodeEnum> {
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
    StickersImportMomentImage201ResponseCodeEnum,
  ];
  @override
  final String wireName = 'StickersImportMomentImage201ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    StickersImportMomentImage201ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  StickersImportMomentImage201ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => StickersImportMomentImage201ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$StickersImportMomentImage201Response
    extends StickersImportMomentImage201Response {
  @override
  final StickerImportResponseDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$StickersImportMomentImage201Response([
    void Function(StickersImportMomentImage201ResponseBuilder)? updates,
  ]) =>
      (StickersImportMomentImage201ResponseBuilder()..update(updates))._build();

  _$StickersImportMomentImage201Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  StickersImportMomentImage201Response rebuild(
    void Function(StickersImportMomentImage201ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  StickersImportMomentImage201ResponseBuilder toBuilder() =>
      StickersImportMomentImage201ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is StickersImportMomentImage201Response &&
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
    return (newBuiltValueToStringHelper(r'StickersImportMomentImage201Response')
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class StickersImportMomentImage201ResponseBuilder
    implements
        Builder<
          StickersImportMomentImage201Response,
          StickersImportMomentImage201ResponseBuilder
        >,
        ApiSuccessEnvelopeBuilder {
  _$StickersImportMomentImage201Response? _$v;

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

  StickersImportMomentImage201ResponseBuilder() {
    StickersImportMomentImage201Response._defaults(this);
  }

  StickersImportMomentImage201ResponseBuilder get _$this {
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
  void replace(covariant StickersImportMomentImage201Response other) {
    _$v = other as _$StickersImportMomentImage201Response;
  }

  @override
  void update(
    void Function(StickersImportMomentImage201ResponseBuilder)? updates,
  ) {
    if (updates != null) updates(this);
  }

  @override
  StickersImportMomentImage201Response build() => _build();

  _$StickersImportMomentImage201Response _build() {
    _$StickersImportMomentImage201Response _$result;
    try {
      _$result =
          _$v ??
          _$StickersImportMomentImage201Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'StickersImportMomentImage201Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'StickersImportMomentImage201Response',
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
          r'StickersImportMomentImage201Response',
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
