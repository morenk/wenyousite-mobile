// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'drafts_create201_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const DraftsCreate201ResponseCodeEnum
_$draftsCreate201ResponseCodeEnum_number0 =
    const DraftsCreate201ResponseCodeEnum._('number0');
const DraftsCreate201ResponseCodeEnum
_$draftsCreate201ResponseCodeEnum_unknownDefaultOpenApi =
    const DraftsCreate201ResponseCodeEnum._('unknownDefaultOpenApi');

DraftsCreate201ResponseCodeEnum _$draftsCreate201ResponseCodeEnumValueOf(
  String name,
) {
  switch (name) {
    case 'number0':
      return _$draftsCreate201ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$draftsCreate201ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$draftsCreate201ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<DraftsCreate201ResponseCodeEnum>
_$draftsCreate201ResponseCodeEnumValues =
    BuiltSet<DraftsCreate201ResponseCodeEnum>(
      const <DraftsCreate201ResponseCodeEnum>[
        _$draftsCreate201ResponseCodeEnum_number0,
        _$draftsCreate201ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<DraftsCreate201ResponseCodeEnum>
_$draftsCreate201ResponseCodeEnumSerializer =
    _$DraftsCreate201ResponseCodeEnumSerializer();

class _$DraftsCreate201ResponseCodeEnumSerializer
    implements PrimitiveSerializer<DraftsCreate201ResponseCodeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'number0': 0,
    'unknownDefaultOpenApi': 11184809,
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    0: 'number0',
    11184809: 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[DraftsCreate201ResponseCodeEnum];
  @override
  final String wireName = 'DraftsCreate201ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    DraftsCreate201ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  DraftsCreate201ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => DraftsCreate201ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$DraftsCreate201Response extends DraftsCreate201Response {
  @override
  final DraftResponseDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$DraftsCreate201Response([
    void Function(DraftsCreate201ResponseBuilder)? updates,
  ]) => (DraftsCreate201ResponseBuilder()..update(updates))._build();

  _$DraftsCreate201Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  DraftsCreate201Response rebuild(
    void Function(DraftsCreate201ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  DraftsCreate201ResponseBuilder toBuilder() =>
      DraftsCreate201ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is DraftsCreate201Response &&
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
    return (newBuiltValueToStringHelper(r'DraftsCreate201Response')
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class DraftsCreate201ResponseBuilder
    implements
        Builder<DraftsCreate201Response, DraftsCreate201ResponseBuilder>,
        ApiSuccessEnvelopeBuilder {
  _$DraftsCreate201Response? _$v;

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

  DraftsCreate201ResponseBuilder() {
    DraftsCreate201Response._defaults(this);
  }

  DraftsCreate201ResponseBuilder get _$this {
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
  void replace(covariant DraftsCreate201Response other) {
    _$v = other as _$DraftsCreate201Response;
  }

  @override
  void update(void Function(DraftsCreate201ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  DraftsCreate201Response build() => _build();

  _$DraftsCreate201Response _build() {
    _$DraftsCreate201Response _$result;
    try {
      _$result =
          _$v ??
          _$DraftsCreate201Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'DraftsCreate201Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'DraftsCreate201Response',
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
          r'DraftsCreate201Response',
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
