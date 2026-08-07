// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'drafts_remove200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const DraftsRemove200ResponseCodeEnum
_$draftsRemove200ResponseCodeEnum_number0 =
    const DraftsRemove200ResponseCodeEnum._('number0');
const DraftsRemove200ResponseCodeEnum
_$draftsRemove200ResponseCodeEnum_unknownDefaultOpenApi =
    const DraftsRemove200ResponseCodeEnum._('unknownDefaultOpenApi');

DraftsRemove200ResponseCodeEnum _$draftsRemove200ResponseCodeEnumValueOf(
  String name,
) {
  switch (name) {
    case 'number0':
      return _$draftsRemove200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$draftsRemove200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$draftsRemove200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<DraftsRemove200ResponseCodeEnum>
_$draftsRemove200ResponseCodeEnumValues =
    BuiltSet<DraftsRemove200ResponseCodeEnum>(
      const <DraftsRemove200ResponseCodeEnum>[
        _$draftsRemove200ResponseCodeEnum_number0,
        _$draftsRemove200ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<DraftsRemove200ResponseCodeEnum>
_$draftsRemove200ResponseCodeEnumSerializer =
    _$DraftsRemove200ResponseCodeEnumSerializer();

class _$DraftsRemove200ResponseCodeEnumSerializer
    implements PrimitiveSerializer<DraftsRemove200ResponseCodeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'number0': 0,
    'unknownDefaultOpenApi': 11184809,
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    0: 'number0',
    11184809: 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[DraftsRemove200ResponseCodeEnum];
  @override
  final String wireName = 'DraftsRemove200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    DraftsRemove200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  DraftsRemove200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => DraftsRemove200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$DraftsRemove200Response extends DraftsRemove200Response {
  @override
  final DeleteDraftResponseDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$DraftsRemove200Response([
    void Function(DraftsRemove200ResponseBuilder)? updates,
  ]) => (DraftsRemove200ResponseBuilder()..update(updates))._build();

  _$DraftsRemove200Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  DraftsRemove200Response rebuild(
    void Function(DraftsRemove200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  DraftsRemove200ResponseBuilder toBuilder() =>
      DraftsRemove200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is DraftsRemove200Response &&
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
    return (newBuiltValueToStringHelper(r'DraftsRemove200Response')
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class DraftsRemove200ResponseBuilder
    implements
        Builder<DraftsRemove200Response, DraftsRemove200ResponseBuilder>,
        ApiSuccessEnvelopeBuilder {
  _$DraftsRemove200Response? _$v;

  DeleteDraftResponseDtoBuilder? _data;
  DeleteDraftResponseDtoBuilder get data =>
      _$this._data ??= DeleteDraftResponseDtoBuilder();
  set data(covariant DeleteDraftResponseDtoBuilder? data) =>
      _$this._data = data;

  ApiSuccessEnvelopeCodeEnum? _code;
  ApiSuccessEnvelopeCodeEnum? get code => _$this._code;
  set code(covariant ApiSuccessEnvelopeCodeEnum? code) => _$this._code = code;

  String? _message;
  String? get message => _$this._message;
  set message(covariant String? message) => _$this._message = message;

  DraftsRemove200ResponseBuilder() {
    DraftsRemove200Response._defaults(this);
  }

  DraftsRemove200ResponseBuilder get _$this {
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
  void replace(covariant DraftsRemove200Response other) {
    _$v = other as _$DraftsRemove200Response;
  }

  @override
  void update(void Function(DraftsRemove200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  DraftsRemove200Response build() => _build();

  _$DraftsRemove200Response _build() {
    _$DraftsRemove200Response _$result;
    try {
      _$result =
          _$v ??
          _$DraftsRemove200Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'DraftsRemove200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'DraftsRemove200Response',
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
          r'DraftsRemove200Response',
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
