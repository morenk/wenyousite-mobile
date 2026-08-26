// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'moments_bookmark_folders200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const MomentsBookmarkFolders200ResponseCodeEnum
_$momentsBookmarkFolders200ResponseCodeEnum_number0 =
    const MomentsBookmarkFolders200ResponseCodeEnum._('number0');
const MomentsBookmarkFolders200ResponseCodeEnum
_$momentsBookmarkFolders200ResponseCodeEnum_unknownDefaultOpenApi =
    const MomentsBookmarkFolders200ResponseCodeEnum._('unknownDefaultOpenApi');

MomentsBookmarkFolders200ResponseCodeEnum
_$momentsBookmarkFolders200ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$momentsBookmarkFolders200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$momentsBookmarkFolders200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$momentsBookmarkFolders200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<MomentsBookmarkFolders200ResponseCodeEnum>
_$momentsBookmarkFolders200ResponseCodeEnumValues =
    BuiltSet<MomentsBookmarkFolders200ResponseCodeEnum>(
      const <MomentsBookmarkFolders200ResponseCodeEnum>[
        _$momentsBookmarkFolders200ResponseCodeEnum_number0,
        _$momentsBookmarkFolders200ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<MomentsBookmarkFolders200ResponseCodeEnum>
_$momentsBookmarkFolders200ResponseCodeEnumSerializer =
    _$MomentsBookmarkFolders200ResponseCodeEnumSerializer();

class _$MomentsBookmarkFolders200ResponseCodeEnumSerializer
    implements PrimitiveSerializer<MomentsBookmarkFolders200ResponseCodeEnum> {
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
    MomentsBookmarkFolders200ResponseCodeEnum,
  ];
  @override
  final String wireName = 'MomentsBookmarkFolders200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    MomentsBookmarkFolders200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  MomentsBookmarkFolders200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => MomentsBookmarkFolders200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$MomentsBookmarkFolders200Response
    extends MomentsBookmarkFolders200Response {
  @override
  final BuiltList<MomentBookmarkFolderResponseDto> data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$MomentsBookmarkFolders200Response([
    void Function(MomentsBookmarkFolders200ResponseBuilder)? updates,
  ]) => (MomentsBookmarkFolders200ResponseBuilder()..update(updates))._build();

  _$MomentsBookmarkFolders200Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  MomentsBookmarkFolders200Response rebuild(
    void Function(MomentsBookmarkFolders200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  MomentsBookmarkFolders200ResponseBuilder toBuilder() =>
      MomentsBookmarkFolders200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MomentsBookmarkFolders200Response &&
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
    return (newBuiltValueToStringHelper(r'MomentsBookmarkFolders200Response')
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class MomentsBookmarkFolders200ResponseBuilder
    implements
        Builder<
          MomentsBookmarkFolders200Response,
          MomentsBookmarkFolders200ResponseBuilder
        >,
        ApiSuccessEnvelopeBuilder {
  _$MomentsBookmarkFolders200Response? _$v;

  ListBuilder<MomentBookmarkFolderResponseDto>? _data;
  ListBuilder<MomentBookmarkFolderResponseDto> get data =>
      _$this._data ??= ListBuilder<MomentBookmarkFolderResponseDto>();
  set data(covariant ListBuilder<MomentBookmarkFolderResponseDto>? data) =>
      _$this._data = data;

  ApiSuccessEnvelopeCodeEnum? _code;
  ApiSuccessEnvelopeCodeEnum? get code => _$this._code;
  set code(covariant ApiSuccessEnvelopeCodeEnum? code) => _$this._code = code;

  String? _message;
  String? get message => _$this._message;
  set message(covariant String? message) => _$this._message = message;

  MomentsBookmarkFolders200ResponseBuilder() {
    MomentsBookmarkFolders200Response._defaults(this);
  }

  MomentsBookmarkFolders200ResponseBuilder get _$this {
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
  void replace(covariant MomentsBookmarkFolders200Response other) {
    _$v = other as _$MomentsBookmarkFolders200Response;
  }

  @override
  void update(
    void Function(MomentsBookmarkFolders200ResponseBuilder)? updates,
  ) {
    if (updates != null) updates(this);
  }

  @override
  MomentsBookmarkFolders200Response build() => _build();

  _$MomentsBookmarkFolders200Response _build() {
    _$MomentsBookmarkFolders200Response _$result;
    try {
      _$result =
          _$v ??
          _$MomentsBookmarkFolders200Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'MomentsBookmarkFolders200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'MomentsBookmarkFolders200Response',
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
          r'MomentsBookmarkFolders200Response',
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
