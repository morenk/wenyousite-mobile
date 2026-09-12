// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'moments_rename_bookmark_folder200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const MomentsRenameBookmarkFolder200ResponseCodeEnum
_$momentsRenameBookmarkFolder200ResponseCodeEnum_number0 =
    const MomentsRenameBookmarkFolder200ResponseCodeEnum._('number0');
const MomentsRenameBookmarkFolder200ResponseCodeEnum
_$momentsRenameBookmarkFolder200ResponseCodeEnum_unknownDefaultOpenApi =
    const MomentsRenameBookmarkFolder200ResponseCodeEnum._(
      'unknownDefaultOpenApi',
    );

MomentsRenameBookmarkFolder200ResponseCodeEnum
_$momentsRenameBookmarkFolder200ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$momentsRenameBookmarkFolder200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$momentsRenameBookmarkFolder200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$momentsRenameBookmarkFolder200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<MomentsRenameBookmarkFolder200ResponseCodeEnum>
_$momentsRenameBookmarkFolder200ResponseCodeEnumValues =
    BuiltSet<MomentsRenameBookmarkFolder200ResponseCodeEnum>(
      const <MomentsRenameBookmarkFolder200ResponseCodeEnum>[
        _$momentsRenameBookmarkFolder200ResponseCodeEnum_number0,
        _$momentsRenameBookmarkFolder200ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<MomentsRenameBookmarkFolder200ResponseCodeEnum>
_$momentsRenameBookmarkFolder200ResponseCodeEnumSerializer =
    _$MomentsRenameBookmarkFolder200ResponseCodeEnumSerializer();

class _$MomentsRenameBookmarkFolder200ResponseCodeEnumSerializer
    implements
        PrimitiveSerializer<MomentsRenameBookmarkFolder200ResponseCodeEnum> {
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
    MomentsRenameBookmarkFolder200ResponseCodeEnum,
  ];
  @override
  final String wireName = 'MomentsRenameBookmarkFolder200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    MomentsRenameBookmarkFolder200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  MomentsRenameBookmarkFolder200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => MomentsRenameBookmarkFolder200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$MomentsRenameBookmarkFolder200Response
    extends MomentsRenameBookmarkFolder200Response {
  @override
  final MomentBookmarkFolderResponseDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$MomentsRenameBookmarkFolder200Response([
    void Function(MomentsRenameBookmarkFolder200ResponseBuilder)? updates,
  ]) => (MomentsRenameBookmarkFolder200ResponseBuilder()..update(updates))
      ._build();

  _$MomentsRenameBookmarkFolder200Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  MomentsRenameBookmarkFolder200Response rebuild(
    void Function(MomentsRenameBookmarkFolder200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  MomentsRenameBookmarkFolder200ResponseBuilder toBuilder() =>
      MomentsRenameBookmarkFolder200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MomentsRenameBookmarkFolder200Response &&
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
    return (newBuiltValueToStringHelper(
            r'MomentsRenameBookmarkFolder200Response',
          )
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class MomentsRenameBookmarkFolder200ResponseBuilder
    implements
        Builder<
          MomentsRenameBookmarkFolder200Response,
          MomentsRenameBookmarkFolder200ResponseBuilder
        >,
        ApiSuccessEnvelopeBuilder {
  _$MomentsRenameBookmarkFolder200Response? _$v;

  MomentBookmarkFolderResponseDtoBuilder? _data;
  MomentBookmarkFolderResponseDtoBuilder get data =>
      _$this._data ??= MomentBookmarkFolderResponseDtoBuilder();
  set data(covariant MomentBookmarkFolderResponseDtoBuilder? data) =>
      _$this._data = data;

  ApiSuccessEnvelopeCodeEnum? _code;
  ApiSuccessEnvelopeCodeEnum? get code => _$this._code;
  set code(covariant ApiSuccessEnvelopeCodeEnum? code) => _$this._code = code;

  String? _message;
  String? get message => _$this._message;
  set message(covariant String? message) => _$this._message = message;

  MomentsRenameBookmarkFolder200ResponseBuilder() {
    MomentsRenameBookmarkFolder200Response._defaults(this);
  }

  MomentsRenameBookmarkFolder200ResponseBuilder get _$this {
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
  void replace(covariant MomentsRenameBookmarkFolder200Response other) {
    _$v = other as _$MomentsRenameBookmarkFolder200Response;
  }

  @override
  void update(
    void Function(MomentsRenameBookmarkFolder200ResponseBuilder)? updates,
  ) {
    if (updates != null) updates(this);
  }

  @override
  MomentsRenameBookmarkFolder200Response build() => _build();

  _$MomentsRenameBookmarkFolder200Response _build() {
    _$MomentsRenameBookmarkFolder200Response _$result;
    try {
      _$result =
          _$v ??
          _$MomentsRenameBookmarkFolder200Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'MomentsRenameBookmarkFolder200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'MomentsRenameBookmarkFolder200Response',
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
          r'MomentsRenameBookmarkFolder200Response',
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
