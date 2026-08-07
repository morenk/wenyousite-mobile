// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subthreads_create201_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const SubthreadsCreate201ResponseCodeEnum
_$subthreadsCreate201ResponseCodeEnum_number0 =
    const SubthreadsCreate201ResponseCodeEnum._('number0');
const SubthreadsCreate201ResponseCodeEnum
_$subthreadsCreate201ResponseCodeEnum_unknownDefaultOpenApi =
    const SubthreadsCreate201ResponseCodeEnum._('unknownDefaultOpenApi');

SubthreadsCreate201ResponseCodeEnum
_$subthreadsCreate201ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$subthreadsCreate201ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$subthreadsCreate201ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$subthreadsCreate201ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<SubthreadsCreate201ResponseCodeEnum>
_$subthreadsCreate201ResponseCodeEnumValues =
    BuiltSet<SubthreadsCreate201ResponseCodeEnum>(
      const <SubthreadsCreate201ResponseCodeEnum>[
        _$subthreadsCreate201ResponseCodeEnum_number0,
        _$subthreadsCreate201ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<SubthreadsCreate201ResponseCodeEnum>
_$subthreadsCreate201ResponseCodeEnumSerializer =
    _$SubthreadsCreate201ResponseCodeEnumSerializer();

class _$SubthreadsCreate201ResponseCodeEnumSerializer
    implements PrimitiveSerializer<SubthreadsCreate201ResponseCodeEnum> {
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
    SubthreadsCreate201ResponseCodeEnum,
  ];
  @override
  final String wireName = 'SubthreadsCreate201ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    SubthreadsCreate201ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  SubthreadsCreate201ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => SubthreadsCreate201ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$SubthreadsCreate201Response extends SubthreadsCreate201Response {
  @override
  final SubthreadResponseDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$SubthreadsCreate201Response([
    void Function(SubthreadsCreate201ResponseBuilder)? updates,
  ]) => (SubthreadsCreate201ResponseBuilder()..update(updates))._build();

  _$SubthreadsCreate201Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  SubthreadsCreate201Response rebuild(
    void Function(SubthreadsCreate201ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  SubthreadsCreate201ResponseBuilder toBuilder() =>
      SubthreadsCreate201ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SubthreadsCreate201Response &&
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
    return (newBuiltValueToStringHelper(r'SubthreadsCreate201Response')
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class SubthreadsCreate201ResponseBuilder
    implements
        Builder<
          SubthreadsCreate201Response,
          SubthreadsCreate201ResponseBuilder
        >,
        ApiSuccessEnvelopeBuilder {
  _$SubthreadsCreate201Response? _$v;

  SubthreadResponseDtoBuilder? _data;
  SubthreadResponseDtoBuilder get data =>
      _$this._data ??= SubthreadResponseDtoBuilder();
  set data(covariant SubthreadResponseDtoBuilder? data) => _$this._data = data;

  ApiSuccessEnvelopeCodeEnum? _code;
  ApiSuccessEnvelopeCodeEnum? get code => _$this._code;
  set code(covariant ApiSuccessEnvelopeCodeEnum? code) => _$this._code = code;

  String? _message;
  String? get message => _$this._message;
  set message(covariant String? message) => _$this._message = message;

  SubthreadsCreate201ResponseBuilder() {
    SubthreadsCreate201Response._defaults(this);
  }

  SubthreadsCreate201ResponseBuilder get _$this {
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
  void replace(covariant SubthreadsCreate201Response other) {
    _$v = other as _$SubthreadsCreate201Response;
  }

  @override
  void update(void Function(SubthreadsCreate201ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SubthreadsCreate201Response build() => _build();

  _$SubthreadsCreate201Response _build() {
    _$SubthreadsCreate201Response _$result;
    try {
      _$result =
          _$v ??
          _$SubthreadsCreate201Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'SubthreadsCreate201Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'SubthreadsCreate201Response',
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
          r'SubthreadsCreate201Response',
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
