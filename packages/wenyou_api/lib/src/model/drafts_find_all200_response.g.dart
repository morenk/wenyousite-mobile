// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'drafts_find_all200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const DraftsFindAll200ResponseCodeEnum
_$draftsFindAll200ResponseCodeEnum_number0 =
    const DraftsFindAll200ResponseCodeEnum._('number0');
const DraftsFindAll200ResponseCodeEnum
_$draftsFindAll200ResponseCodeEnum_unknownDefaultOpenApi =
    const DraftsFindAll200ResponseCodeEnum._('unknownDefaultOpenApi');

DraftsFindAll200ResponseCodeEnum _$draftsFindAll200ResponseCodeEnumValueOf(
  String name,
) {
  switch (name) {
    case 'number0':
      return _$draftsFindAll200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$draftsFindAll200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$draftsFindAll200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<DraftsFindAll200ResponseCodeEnum>
_$draftsFindAll200ResponseCodeEnumValues =
    BuiltSet<DraftsFindAll200ResponseCodeEnum>(
      const <DraftsFindAll200ResponseCodeEnum>[
        _$draftsFindAll200ResponseCodeEnum_number0,
        _$draftsFindAll200ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<DraftsFindAll200ResponseCodeEnum>
_$draftsFindAll200ResponseCodeEnumSerializer =
    _$DraftsFindAll200ResponseCodeEnumSerializer();

class _$DraftsFindAll200ResponseCodeEnumSerializer
    implements PrimitiveSerializer<DraftsFindAll200ResponseCodeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'number0': 0,
    'unknownDefaultOpenApi': 11184809,
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    0: 'number0',
    11184809: 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[DraftsFindAll200ResponseCodeEnum];
  @override
  final String wireName = 'DraftsFindAll200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    DraftsFindAll200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  DraftsFindAll200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => DraftsFindAll200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$DraftsFindAll200Response extends DraftsFindAll200Response {
  @override
  final BuiltList<DraftResponseDto> data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$DraftsFindAll200Response([
    void Function(DraftsFindAll200ResponseBuilder)? updates,
  ]) => (DraftsFindAll200ResponseBuilder()..update(updates))._build();

  _$DraftsFindAll200Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  DraftsFindAll200Response rebuild(
    void Function(DraftsFindAll200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  DraftsFindAll200ResponseBuilder toBuilder() =>
      DraftsFindAll200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is DraftsFindAll200Response &&
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
    return (newBuiltValueToStringHelper(r'DraftsFindAll200Response')
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class DraftsFindAll200ResponseBuilder
    implements
        Builder<DraftsFindAll200Response, DraftsFindAll200ResponseBuilder>,
        ApiSuccessEnvelopeBuilder {
  _$DraftsFindAll200Response? _$v;

  ListBuilder<DraftResponseDto>? _data;
  ListBuilder<DraftResponseDto> get data =>
      _$this._data ??= ListBuilder<DraftResponseDto>();
  set data(covariant ListBuilder<DraftResponseDto>? data) =>
      _$this._data = data;

  ApiSuccessEnvelopeCodeEnum? _code;
  ApiSuccessEnvelopeCodeEnum? get code => _$this._code;
  set code(covariant ApiSuccessEnvelopeCodeEnum? code) => _$this._code = code;

  String? _message;
  String? get message => _$this._message;
  set message(covariant String? message) => _$this._message = message;

  DraftsFindAll200ResponseBuilder() {
    DraftsFindAll200Response._defaults(this);
  }

  DraftsFindAll200ResponseBuilder get _$this {
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
  void replace(covariant DraftsFindAll200Response other) {
    _$v = other as _$DraftsFindAll200Response;
  }

  @override
  void update(void Function(DraftsFindAll200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  DraftsFindAll200Response build() => _build();

  _$DraftsFindAll200Response _build() {
    _$DraftsFindAll200Response _$result;
    try {
      _$result =
          _$v ??
          _$DraftsFindAll200Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'DraftsFindAll200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'DraftsFindAll200Response',
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
          r'DraftsFindAll200Response',
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
