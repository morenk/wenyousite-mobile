// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'threads_preview_invite_link200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ThreadsPreviewInviteLink200ResponseCodeEnum
_$threadsPreviewInviteLink200ResponseCodeEnum_number0 =
    const ThreadsPreviewInviteLink200ResponseCodeEnum._('number0');
const ThreadsPreviewInviteLink200ResponseCodeEnum
_$threadsPreviewInviteLink200ResponseCodeEnum_unknownDefaultOpenApi =
    const ThreadsPreviewInviteLink200ResponseCodeEnum._(
      'unknownDefaultOpenApi',
    );

ThreadsPreviewInviteLink200ResponseCodeEnum
_$threadsPreviewInviteLink200ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$threadsPreviewInviteLink200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$threadsPreviewInviteLink200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$threadsPreviewInviteLink200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<ThreadsPreviewInviteLink200ResponseCodeEnum>
_$threadsPreviewInviteLink200ResponseCodeEnumValues =
    BuiltSet<ThreadsPreviewInviteLink200ResponseCodeEnum>(
      const <ThreadsPreviewInviteLink200ResponseCodeEnum>[
        _$threadsPreviewInviteLink200ResponseCodeEnum_number0,
        _$threadsPreviewInviteLink200ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<ThreadsPreviewInviteLink200ResponseCodeEnum>
_$threadsPreviewInviteLink200ResponseCodeEnumSerializer =
    _$ThreadsPreviewInviteLink200ResponseCodeEnumSerializer();

class _$ThreadsPreviewInviteLink200ResponseCodeEnumSerializer
    implements
        PrimitiveSerializer<ThreadsPreviewInviteLink200ResponseCodeEnum> {
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
    ThreadsPreviewInviteLink200ResponseCodeEnum,
  ];
  @override
  final String wireName = 'ThreadsPreviewInviteLink200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    ThreadsPreviewInviteLink200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  ThreadsPreviewInviteLink200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => ThreadsPreviewInviteLink200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$ThreadsPreviewInviteLink200Response
    extends ThreadsPreviewInviteLink200Response {
  @override
  final InvitePreviewResponseDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$ThreadsPreviewInviteLink200Response([
    void Function(ThreadsPreviewInviteLink200ResponseBuilder)? updates,
  ]) =>
      (ThreadsPreviewInviteLink200ResponseBuilder()..update(updates))._build();

  _$ThreadsPreviewInviteLink200Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  ThreadsPreviewInviteLink200Response rebuild(
    void Function(ThreadsPreviewInviteLink200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  ThreadsPreviewInviteLink200ResponseBuilder toBuilder() =>
      ThreadsPreviewInviteLink200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ThreadsPreviewInviteLink200Response &&
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
    return (newBuiltValueToStringHelper(r'ThreadsPreviewInviteLink200Response')
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class ThreadsPreviewInviteLink200ResponseBuilder
    implements
        Builder<
          ThreadsPreviewInviteLink200Response,
          ThreadsPreviewInviteLink200ResponseBuilder
        >,
        ApiSuccessEnvelopeBuilder {
  _$ThreadsPreviewInviteLink200Response? _$v;

  InvitePreviewResponseDtoBuilder? _data;
  InvitePreviewResponseDtoBuilder get data =>
      _$this._data ??= InvitePreviewResponseDtoBuilder();
  set data(covariant InvitePreviewResponseDtoBuilder? data) =>
      _$this._data = data;

  ApiSuccessEnvelopeCodeEnum? _code;
  ApiSuccessEnvelopeCodeEnum? get code => _$this._code;
  set code(covariant ApiSuccessEnvelopeCodeEnum? code) => _$this._code = code;

  String? _message;
  String? get message => _$this._message;
  set message(covariant String? message) => _$this._message = message;

  ThreadsPreviewInviteLink200ResponseBuilder() {
    ThreadsPreviewInviteLink200Response._defaults(this);
  }

  ThreadsPreviewInviteLink200ResponseBuilder get _$this {
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
  void replace(covariant ThreadsPreviewInviteLink200Response other) {
    _$v = other as _$ThreadsPreviewInviteLink200Response;
  }

  @override
  void update(
    void Function(ThreadsPreviewInviteLink200ResponseBuilder)? updates,
  ) {
    if (updates != null) updates(this);
  }

  @override
  ThreadsPreviewInviteLink200Response build() => _build();

  _$ThreadsPreviewInviteLink200Response _build() {
    _$ThreadsPreviewInviteLink200Response _$result;
    try {
      _$result =
          _$v ??
          _$ThreadsPreviewInviteLink200Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'ThreadsPreviewInviteLink200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'ThreadsPreviewInviteLink200Response',
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
          r'ThreadsPreviewInviteLink200Response',
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
