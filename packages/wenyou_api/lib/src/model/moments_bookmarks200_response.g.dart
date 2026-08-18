// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'moments_bookmarks200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const MomentsBookmarks200ResponseCodeEnum
_$momentsBookmarks200ResponseCodeEnum_number0 =
    const MomentsBookmarks200ResponseCodeEnum._('number0');
const MomentsBookmarks200ResponseCodeEnum
_$momentsBookmarks200ResponseCodeEnum_unknownDefaultOpenApi =
    const MomentsBookmarks200ResponseCodeEnum._('unknownDefaultOpenApi');

MomentsBookmarks200ResponseCodeEnum
_$momentsBookmarks200ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$momentsBookmarks200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$momentsBookmarks200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$momentsBookmarks200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<MomentsBookmarks200ResponseCodeEnum>
_$momentsBookmarks200ResponseCodeEnumValues =
    BuiltSet<MomentsBookmarks200ResponseCodeEnum>(
      const <MomentsBookmarks200ResponseCodeEnum>[
        _$momentsBookmarks200ResponseCodeEnum_number0,
        _$momentsBookmarks200ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<MomentsBookmarks200ResponseCodeEnum>
_$momentsBookmarks200ResponseCodeEnumSerializer =
    _$MomentsBookmarks200ResponseCodeEnumSerializer();

class _$MomentsBookmarks200ResponseCodeEnumSerializer
    implements PrimitiveSerializer<MomentsBookmarks200ResponseCodeEnum> {
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
    MomentsBookmarks200ResponseCodeEnum,
  ];
  @override
  final String wireName = 'MomentsBookmarks200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    MomentsBookmarks200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  MomentsBookmarks200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => MomentsBookmarks200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$MomentsBookmarks200Response extends MomentsBookmarks200Response {
  @override
  final BuiltList<OwnMomentBookmarkResponseDto> data;
  @override
  final ApiPaginationMeta meta;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$MomentsBookmarks200Response([
    void Function(MomentsBookmarks200ResponseBuilder)? updates,
  ]) => (MomentsBookmarks200ResponseBuilder()..update(updates))._build();

  _$MomentsBookmarks200Response._({
    required this.data,
    required this.meta,
    required this.code,
    required this.message,
  }) : super._();
  @override
  MomentsBookmarks200Response rebuild(
    void Function(MomentsBookmarks200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  MomentsBookmarks200ResponseBuilder toBuilder() =>
      MomentsBookmarks200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MomentsBookmarks200Response &&
        data == other.data &&
        meta == other.meta &&
        code == other.code &&
        message == other.message;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, data.hashCode);
    _$hash = $jc(_$hash, meta.hashCode);
    _$hash = $jc(_$hash, code.hashCode);
    _$hash = $jc(_$hash, message.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'MomentsBookmarks200Response')
          ..add('data', data)
          ..add('meta', meta)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class MomentsBookmarks200ResponseBuilder
    implements
        Builder<
          MomentsBookmarks200Response,
          MomentsBookmarks200ResponseBuilder
        >,
        ApiPaginatedSuccessEnvelopeBuilder {
  _$MomentsBookmarks200Response? _$v;

  ListBuilder<OwnMomentBookmarkResponseDto>? _data;
  ListBuilder<OwnMomentBookmarkResponseDto> get data =>
      _$this._data ??= ListBuilder<OwnMomentBookmarkResponseDto>();
  set data(covariant ListBuilder<OwnMomentBookmarkResponseDto>? data) =>
      _$this._data = data;

  ApiPaginationMetaBuilder? _meta;
  ApiPaginationMetaBuilder get meta =>
      _$this._meta ??= ApiPaginationMetaBuilder();
  set meta(covariant ApiPaginationMetaBuilder? meta) => _$this._meta = meta;

  ApiSuccessEnvelopeCodeEnum? _code;
  ApiSuccessEnvelopeCodeEnum? get code => _$this._code;
  set code(covariant ApiSuccessEnvelopeCodeEnum? code) => _$this._code = code;

  String? _message;
  String? get message => _$this._message;
  set message(covariant String? message) => _$this._message = message;

  MomentsBookmarks200ResponseBuilder() {
    MomentsBookmarks200Response._defaults(this);
  }

  MomentsBookmarks200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _meta = $v.meta.toBuilder();
      _code = $v.code;
      _message = $v.message;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(covariant MomentsBookmarks200Response other) {
    _$v = other as _$MomentsBookmarks200Response;
  }

  @override
  void update(void Function(MomentsBookmarks200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  MomentsBookmarks200Response build() => _build();

  _$MomentsBookmarks200Response _build() {
    _$MomentsBookmarks200Response _$result;
    try {
      _$result =
          _$v ??
          _$MomentsBookmarks200Response._(
            data: data.build(),
            meta: meta.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'MomentsBookmarks200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'MomentsBookmarks200Response',
              'message',
            ),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
        _$failedField = 'meta';
        meta.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'MomentsBookmarks200Response',
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
