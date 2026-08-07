// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'drafts_update200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const DraftsUpdate200ResponseCodeEnum
_$draftsUpdate200ResponseCodeEnum_number0 =
    const DraftsUpdate200ResponseCodeEnum._('number0');
const DraftsUpdate200ResponseCodeEnum
_$draftsUpdate200ResponseCodeEnum_unknownDefaultOpenApi =
    const DraftsUpdate200ResponseCodeEnum._('unknownDefaultOpenApi');

DraftsUpdate200ResponseCodeEnum _$draftsUpdate200ResponseCodeEnumValueOf(
  String name,
) {
  switch (name) {
    case 'number0':
      return _$draftsUpdate200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$draftsUpdate200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$draftsUpdate200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<DraftsUpdate200ResponseCodeEnum>
_$draftsUpdate200ResponseCodeEnumValues =
    BuiltSet<DraftsUpdate200ResponseCodeEnum>(
      const <DraftsUpdate200ResponseCodeEnum>[
        _$draftsUpdate200ResponseCodeEnum_number0,
        _$draftsUpdate200ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<DraftsUpdate200ResponseCodeEnum>
_$draftsUpdate200ResponseCodeEnumSerializer =
    _$DraftsUpdate200ResponseCodeEnumSerializer();

class _$DraftsUpdate200ResponseCodeEnumSerializer
    implements PrimitiveSerializer<DraftsUpdate200ResponseCodeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'number0': 0,
    'unknownDefaultOpenApi': 11184809,
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    0: 'number0',
    11184809: 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[DraftsUpdate200ResponseCodeEnum];
  @override
  final String wireName = 'DraftsUpdate200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    DraftsUpdate200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  DraftsUpdate200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => DraftsUpdate200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$DraftsUpdate200Response extends DraftsUpdate200Response {
  @override
  final DraftResponseDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$DraftsUpdate200Response([
    void Function(DraftsUpdate200ResponseBuilder)? updates,
  ]) => (DraftsUpdate200ResponseBuilder()..update(updates))._build();

  _$DraftsUpdate200Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  DraftsUpdate200Response rebuild(
    void Function(DraftsUpdate200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  DraftsUpdate200ResponseBuilder toBuilder() =>
      DraftsUpdate200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is DraftsUpdate200Response &&
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
    return (newBuiltValueToStringHelper(r'DraftsUpdate200Response')
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class DraftsUpdate200ResponseBuilder
    implements
        Builder<DraftsUpdate200Response, DraftsUpdate200ResponseBuilder>,
        ApiSuccessEnvelopeBuilder {
  _$DraftsUpdate200Response? _$v;

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

  DraftsUpdate200ResponseBuilder() {
    DraftsUpdate200Response._defaults(this);
  }

  DraftsUpdate200ResponseBuilder get _$this {
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
  void replace(covariant DraftsUpdate200Response other) {
    _$v = other as _$DraftsUpdate200Response;
  }

  @override
  void update(void Function(DraftsUpdate200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  DraftsUpdate200Response build() => _build();

  _$DraftsUpdate200Response _build() {
    _$DraftsUpdate200Response _$result;
    try {
      _$result =
          _$v ??
          _$DraftsUpdate200Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'DraftsUpdate200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'DraftsUpdate200Response',
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
          r'DraftsUpdate200Response',
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
