// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stickers_import_media201_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const StickersImportMedia201ResponseCodeEnum
_$stickersImportMedia201ResponseCodeEnum_number0 =
    const StickersImportMedia201ResponseCodeEnum._('number0');
const StickersImportMedia201ResponseCodeEnum
_$stickersImportMedia201ResponseCodeEnum_unknownDefaultOpenApi =
    const StickersImportMedia201ResponseCodeEnum._('unknownDefaultOpenApi');

StickersImportMedia201ResponseCodeEnum
_$stickersImportMedia201ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$stickersImportMedia201ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$stickersImportMedia201ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$stickersImportMedia201ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<StickersImportMedia201ResponseCodeEnum>
_$stickersImportMedia201ResponseCodeEnumValues =
    BuiltSet<StickersImportMedia201ResponseCodeEnum>(
      const <StickersImportMedia201ResponseCodeEnum>[
        _$stickersImportMedia201ResponseCodeEnum_number0,
        _$stickersImportMedia201ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<StickersImportMedia201ResponseCodeEnum>
_$stickersImportMedia201ResponseCodeEnumSerializer =
    _$StickersImportMedia201ResponseCodeEnumSerializer();

class _$StickersImportMedia201ResponseCodeEnumSerializer
    implements PrimitiveSerializer<StickersImportMedia201ResponseCodeEnum> {
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
    StickersImportMedia201ResponseCodeEnum,
  ];
  @override
  final String wireName = 'StickersImportMedia201ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    StickersImportMedia201ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  StickersImportMedia201ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => StickersImportMedia201ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$StickersImportMedia201Response extends StickersImportMedia201Response {
  @override
  final StickerImportResponseDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$StickersImportMedia201Response([
    void Function(StickersImportMedia201ResponseBuilder)? updates,
  ]) => (StickersImportMedia201ResponseBuilder()..update(updates))._build();

  _$StickersImportMedia201Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  StickersImportMedia201Response rebuild(
    void Function(StickersImportMedia201ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  StickersImportMedia201ResponseBuilder toBuilder() =>
      StickersImportMedia201ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is StickersImportMedia201Response &&
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
    return (newBuiltValueToStringHelper(r'StickersImportMedia201Response')
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class StickersImportMedia201ResponseBuilder
    implements
        Builder<
          StickersImportMedia201Response,
          StickersImportMedia201ResponseBuilder
        >,
        ApiSuccessEnvelopeBuilder {
  _$StickersImportMedia201Response? _$v;

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

  StickersImportMedia201ResponseBuilder() {
    StickersImportMedia201Response._defaults(this);
  }

  StickersImportMedia201ResponseBuilder get _$this {
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
  void replace(covariant StickersImportMedia201Response other) {
    _$v = other as _$StickersImportMedia201Response;
  }

  @override
  void update(void Function(StickersImportMedia201ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  StickersImportMedia201Response build() => _build();

  _$StickersImportMedia201Response _build() {
    _$StickersImportMedia201Response _$result;
    try {
      _$result =
          _$v ??
          _$StickersImportMedia201Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'StickersImportMedia201Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'StickersImportMedia201Response',
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
          r'StickersImportMedia201Response',
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
