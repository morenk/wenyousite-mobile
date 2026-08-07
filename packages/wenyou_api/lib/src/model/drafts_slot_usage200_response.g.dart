// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'drafts_slot_usage200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const DraftsSlotUsage200ResponseCodeEnum
_$draftsSlotUsage200ResponseCodeEnum_number0 =
    const DraftsSlotUsage200ResponseCodeEnum._('number0');
const DraftsSlotUsage200ResponseCodeEnum
_$draftsSlotUsage200ResponseCodeEnum_unknownDefaultOpenApi =
    const DraftsSlotUsage200ResponseCodeEnum._('unknownDefaultOpenApi');

DraftsSlotUsage200ResponseCodeEnum _$draftsSlotUsage200ResponseCodeEnumValueOf(
  String name,
) {
  switch (name) {
    case 'number0':
      return _$draftsSlotUsage200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$draftsSlotUsage200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$draftsSlotUsage200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<DraftsSlotUsage200ResponseCodeEnum>
_$draftsSlotUsage200ResponseCodeEnumValues =
    BuiltSet<DraftsSlotUsage200ResponseCodeEnum>(
      const <DraftsSlotUsage200ResponseCodeEnum>[
        _$draftsSlotUsage200ResponseCodeEnum_number0,
        _$draftsSlotUsage200ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<DraftsSlotUsage200ResponseCodeEnum>
_$draftsSlotUsage200ResponseCodeEnumSerializer =
    _$DraftsSlotUsage200ResponseCodeEnumSerializer();

class _$DraftsSlotUsage200ResponseCodeEnumSerializer
    implements PrimitiveSerializer<DraftsSlotUsage200ResponseCodeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'number0': 0,
    'unknownDefaultOpenApi': 11184809,
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    0: 'number0',
    11184809: 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[DraftsSlotUsage200ResponseCodeEnum];
  @override
  final String wireName = 'DraftsSlotUsage200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    DraftsSlotUsage200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  DraftsSlotUsage200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => DraftsSlotUsage200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$DraftsSlotUsage200Response extends DraftsSlotUsage200Response {
  @override
  final DraftSlotUsageResponseDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$DraftsSlotUsage200Response([
    void Function(DraftsSlotUsage200ResponseBuilder)? updates,
  ]) => (DraftsSlotUsage200ResponseBuilder()..update(updates))._build();

  _$DraftsSlotUsage200Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  DraftsSlotUsage200Response rebuild(
    void Function(DraftsSlotUsage200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  DraftsSlotUsage200ResponseBuilder toBuilder() =>
      DraftsSlotUsage200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is DraftsSlotUsage200Response &&
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
    return (newBuiltValueToStringHelper(r'DraftsSlotUsage200Response')
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class DraftsSlotUsage200ResponseBuilder
    implements
        Builder<DraftsSlotUsage200Response, DraftsSlotUsage200ResponseBuilder>,
        ApiSuccessEnvelopeBuilder {
  _$DraftsSlotUsage200Response? _$v;

  DraftSlotUsageResponseDtoBuilder? _data;
  DraftSlotUsageResponseDtoBuilder get data =>
      _$this._data ??= DraftSlotUsageResponseDtoBuilder();
  set data(covariant DraftSlotUsageResponseDtoBuilder? data) =>
      _$this._data = data;

  ApiSuccessEnvelopeCodeEnum? _code;
  ApiSuccessEnvelopeCodeEnum? get code => _$this._code;
  set code(covariant ApiSuccessEnvelopeCodeEnum? code) => _$this._code = code;

  String? _message;
  String? get message => _$this._message;
  set message(covariant String? message) => _$this._message = message;

  DraftsSlotUsage200ResponseBuilder() {
    DraftsSlotUsage200Response._defaults(this);
  }

  DraftsSlotUsage200ResponseBuilder get _$this {
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
  void replace(covariant DraftsSlotUsage200Response other) {
    _$v = other as _$DraftsSlotUsage200Response;
  }

  @override
  void update(void Function(DraftsSlotUsage200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  DraftsSlotUsage200Response build() => _build();

  _$DraftsSlotUsage200Response _build() {
    _$DraftsSlotUsage200Response _$result;
    try {
      _$result =
          _$v ??
          _$DraftsSlotUsage200Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'DraftsSlotUsage200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'DraftsSlotUsage200Response',
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
          r'DraftsSlotUsage200Response',
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
