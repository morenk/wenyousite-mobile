// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'drafts_find_by_id200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const DraftsFindById200ResponseCodeEnum
_$draftsFindById200ResponseCodeEnum_number0 =
    const DraftsFindById200ResponseCodeEnum._('number0');
const DraftsFindById200ResponseCodeEnum
_$draftsFindById200ResponseCodeEnum_unknownDefaultOpenApi =
    const DraftsFindById200ResponseCodeEnum._('unknownDefaultOpenApi');

DraftsFindById200ResponseCodeEnum _$draftsFindById200ResponseCodeEnumValueOf(
  String name,
) {
  switch (name) {
    case 'number0':
      return _$draftsFindById200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$draftsFindById200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$draftsFindById200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<DraftsFindById200ResponseCodeEnum>
_$draftsFindById200ResponseCodeEnumValues =
    BuiltSet<DraftsFindById200ResponseCodeEnum>(
      const <DraftsFindById200ResponseCodeEnum>[
        _$draftsFindById200ResponseCodeEnum_number0,
        _$draftsFindById200ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<DraftsFindById200ResponseCodeEnum>
_$draftsFindById200ResponseCodeEnumSerializer =
    _$DraftsFindById200ResponseCodeEnumSerializer();

class _$DraftsFindById200ResponseCodeEnumSerializer
    implements PrimitiveSerializer<DraftsFindById200ResponseCodeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'number0': 0,
    'unknownDefaultOpenApi': 11184809,
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    0: 'number0',
    11184809: 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[DraftsFindById200ResponseCodeEnum];
  @override
  final String wireName = 'DraftsFindById200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    DraftsFindById200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  DraftsFindById200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => DraftsFindById200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$DraftsFindById200Response extends DraftsFindById200Response {
  @override
  final DraftResponseDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$DraftsFindById200Response([
    void Function(DraftsFindById200ResponseBuilder)? updates,
  ]) => (DraftsFindById200ResponseBuilder()..update(updates))._build();

  _$DraftsFindById200Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  DraftsFindById200Response rebuild(
    void Function(DraftsFindById200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  DraftsFindById200ResponseBuilder toBuilder() =>
      DraftsFindById200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is DraftsFindById200Response &&
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
    return (newBuiltValueToStringHelper(r'DraftsFindById200Response')
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class DraftsFindById200ResponseBuilder
    implements
        Builder<DraftsFindById200Response, DraftsFindById200ResponseBuilder>,
        ApiSuccessEnvelopeBuilder {
  _$DraftsFindById200Response? _$v;

  DraftResponseDtoBuilder? _data;
  DraftResponseDtoBuilder get data =>
      _$this._data ??= DraftResponseDtoBuilder();
  set data(covariant DraftResponseDtoBuilder? data) => _$this._data = data;

  ApiSuccessEnvelopeCodeEnum? _code;
  ApiSuccessEnvelopeCodeEnum? get code => _$this._code;
  set code(covariant ApiSuccessEnvelopeCodeEnum? code) => _$this._code = code;

  String? _message;
  String? get message => _$this._message;
  set message(covariant String? message) => _$this._message = message;

  DraftsFindById200ResponseBuilder() {
    DraftsFindById200Response._defaults(this);
  }

  DraftsFindById200ResponseBuilder get _$this {
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
  void replace(covariant DraftsFindById200Response other) {
    _$v = other as _$DraftsFindById200Response;
  }

  @override
  void update(void Function(DraftsFindById200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  DraftsFindById200Response build() => _build();

  _$DraftsFindById200Response _build() {
    _$DraftsFindById200Response _$result;
    try {
      _$result =
          _$v ??
          _$DraftsFindById200Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'DraftsFindById200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'DraftsFindById200Response',
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
          r'DraftsFindById200Response',
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
