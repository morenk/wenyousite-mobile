// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subthreads_reorder200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const SubthreadsReorder200ResponseCodeEnum
_$subthreadsReorder200ResponseCodeEnum_number0 =
    const SubthreadsReorder200ResponseCodeEnum._('number0');
const SubthreadsReorder200ResponseCodeEnum
_$subthreadsReorder200ResponseCodeEnum_unknownDefaultOpenApi =
    const SubthreadsReorder200ResponseCodeEnum._('unknownDefaultOpenApi');

SubthreadsReorder200ResponseCodeEnum
_$subthreadsReorder200ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$subthreadsReorder200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$subthreadsReorder200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$subthreadsReorder200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<SubthreadsReorder200ResponseCodeEnum>
_$subthreadsReorder200ResponseCodeEnumValues =
    BuiltSet<SubthreadsReorder200ResponseCodeEnum>(
      const <SubthreadsReorder200ResponseCodeEnum>[
        _$subthreadsReorder200ResponseCodeEnum_number0,
        _$subthreadsReorder200ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<SubthreadsReorder200ResponseCodeEnum>
_$subthreadsReorder200ResponseCodeEnumSerializer =
    _$SubthreadsReorder200ResponseCodeEnumSerializer();

class _$SubthreadsReorder200ResponseCodeEnumSerializer
    implements PrimitiveSerializer<SubthreadsReorder200ResponseCodeEnum> {
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
    SubthreadsReorder200ResponseCodeEnum,
  ];
  @override
  final String wireName = 'SubthreadsReorder200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    SubthreadsReorder200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  SubthreadsReorder200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => SubthreadsReorder200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$SubthreadsReorder200Response extends SubthreadsReorder200Response {
  @override
  final BuiltList<ReorderedSubthreadResponseDto> data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$SubthreadsReorder200Response([
    void Function(SubthreadsReorder200ResponseBuilder)? updates,
  ]) => (SubthreadsReorder200ResponseBuilder()..update(updates))._build();

  _$SubthreadsReorder200Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  SubthreadsReorder200Response rebuild(
    void Function(SubthreadsReorder200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  SubthreadsReorder200ResponseBuilder toBuilder() =>
      SubthreadsReorder200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SubthreadsReorder200Response &&
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
    return (newBuiltValueToStringHelper(r'SubthreadsReorder200Response')
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class SubthreadsReorder200ResponseBuilder
    implements
        Builder<
          SubthreadsReorder200Response,
          SubthreadsReorder200ResponseBuilder
        >,
        ApiSuccessEnvelopeBuilder {
  _$SubthreadsReorder200Response? _$v;

  ListBuilder<ReorderedSubthreadResponseDto>? _data;
  ListBuilder<ReorderedSubthreadResponseDto> get data =>
      _$this._data ??= ListBuilder<ReorderedSubthreadResponseDto>();
  set data(covariant ListBuilder<ReorderedSubthreadResponseDto>? data) =>
      _$this._data = data;

  ApiSuccessEnvelopeCodeEnum? _code;
  ApiSuccessEnvelopeCodeEnum? get code => _$this._code;
  set code(covariant ApiSuccessEnvelopeCodeEnum? code) => _$this._code = code;

  String? _message;
  String? get message => _$this._message;
  set message(covariant String? message) => _$this._message = message;

  SubthreadsReorder200ResponseBuilder() {
    SubthreadsReorder200Response._defaults(this);
  }

  SubthreadsReorder200ResponseBuilder get _$this {
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
  void replace(covariant SubthreadsReorder200Response other) {
    _$v = other as _$SubthreadsReorder200Response;
  }

  @override
  void update(void Function(SubthreadsReorder200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SubthreadsReorder200Response build() => _build();

  _$SubthreadsReorder200Response _build() {
    _$SubthreadsReorder200Response _$result;
    try {
      _$result =
          _$v ??
          _$SubthreadsReorder200Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'SubthreadsReorder200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'SubthreadsReorder200Response',
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
          r'SubthreadsReorder200Response',
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
