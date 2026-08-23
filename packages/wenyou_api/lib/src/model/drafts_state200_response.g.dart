// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'drafts_state200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const DraftsState200ResponseCodeEnum _$draftsState200ResponseCodeEnum_number0 =
    const DraftsState200ResponseCodeEnum._('number0');
const DraftsState200ResponseCodeEnum
_$draftsState200ResponseCodeEnum_unknownDefaultOpenApi =
    const DraftsState200ResponseCodeEnum._('unknownDefaultOpenApi');

DraftsState200ResponseCodeEnum _$draftsState200ResponseCodeEnumValueOf(
  String name,
) {
  switch (name) {
    case 'number0':
      return _$draftsState200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$draftsState200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$draftsState200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<DraftsState200ResponseCodeEnum>
_$draftsState200ResponseCodeEnumValues =
    BuiltSet<DraftsState200ResponseCodeEnum>(
      const <DraftsState200ResponseCodeEnum>[
        _$draftsState200ResponseCodeEnum_number0,
        _$draftsState200ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<DraftsState200ResponseCodeEnum>
_$draftsState200ResponseCodeEnumSerializer =
    _$DraftsState200ResponseCodeEnumSerializer();

class _$DraftsState200ResponseCodeEnumSerializer
    implements PrimitiveSerializer<DraftsState200ResponseCodeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'number0': 0,
    'unknownDefaultOpenApi': 11184809,
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    0: 'number0',
    11184809: 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[DraftsState200ResponseCodeEnum];
  @override
  final String wireName = 'DraftsState200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    DraftsState200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  DraftsState200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => DraftsState200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$DraftsState200Response extends DraftsState200Response {
  @override
  final DraftStateResponseDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$DraftsState200Response([
    void Function(DraftsState200ResponseBuilder)? updates,
  ]) => (DraftsState200ResponseBuilder()..update(updates))._build();

  _$DraftsState200Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  DraftsState200Response rebuild(
    void Function(DraftsState200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  DraftsState200ResponseBuilder toBuilder() =>
      DraftsState200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is DraftsState200Response &&
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
    return (newBuiltValueToStringHelper(r'DraftsState200Response')
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class DraftsState200ResponseBuilder
    implements
        Builder<DraftsState200Response, DraftsState200ResponseBuilder>,
        ApiSuccessEnvelopeBuilder {
  _$DraftsState200Response? _$v;

  DraftStateResponseDtoBuilder? _data;
  DraftStateResponseDtoBuilder get data =>
      _$this._data ??= DraftStateResponseDtoBuilder();
  set data(covariant DraftStateResponseDtoBuilder? data) => _$this._data = data;

  ApiSuccessEnvelopeCodeEnum? _code;
  ApiSuccessEnvelopeCodeEnum? get code => _$this._code;
  set code(covariant ApiSuccessEnvelopeCodeEnum? code) => _$this._code = code;

  String? _message;
  String? get message => _$this._message;
  set message(covariant String? message) => _$this._message = message;

  DraftsState200ResponseBuilder() {
    DraftsState200Response._defaults(this);
  }

  DraftsState200ResponseBuilder get _$this {
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
  void replace(covariant DraftsState200Response other) {
    _$v = other as _$DraftsState200Response;
  }

  @override
  void update(void Function(DraftsState200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  DraftsState200Response build() => _build();

  _$DraftsState200Response _build() {
    _$DraftsState200Response _$result;
    try {
      _$result =
          _$v ??
          _$DraftsState200Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'DraftsState200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'DraftsState200Response',
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
          r'DraftsState200Response',
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
