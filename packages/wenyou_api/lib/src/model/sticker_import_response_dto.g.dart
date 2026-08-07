// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sticker_import_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const StickerImportResponseDtoStatusEnum
_$stickerImportResponseDtoStatusEnum_PROCESSING =
    const StickerImportResponseDtoStatusEnum._('PROCESSING');
const StickerImportResponseDtoStatusEnum
_$stickerImportResponseDtoStatusEnum_COMPLETED =
    const StickerImportResponseDtoStatusEnum._('COMPLETED');
const StickerImportResponseDtoStatusEnum
_$stickerImportResponseDtoStatusEnum_FAILED =
    const StickerImportResponseDtoStatusEnum._('FAILED');
const StickerImportResponseDtoStatusEnum
_$stickerImportResponseDtoStatusEnum_unknownDefaultOpenApi =
    const StickerImportResponseDtoStatusEnum._('unknownDefaultOpenApi');

StickerImportResponseDtoStatusEnum _$stickerImportResponseDtoStatusEnumValueOf(
  String name,
) {
  switch (name) {
    case 'PROCESSING':
      return _$stickerImportResponseDtoStatusEnum_PROCESSING;
    case 'COMPLETED':
      return _$stickerImportResponseDtoStatusEnum_COMPLETED;
    case 'FAILED':
      return _$stickerImportResponseDtoStatusEnum_FAILED;
    case 'unknownDefaultOpenApi':
      return _$stickerImportResponseDtoStatusEnum_unknownDefaultOpenApi;
    default:
      return _$stickerImportResponseDtoStatusEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<StickerImportResponseDtoStatusEnum>
_$stickerImportResponseDtoStatusEnumValues =
    BuiltSet<StickerImportResponseDtoStatusEnum>(
      const <StickerImportResponseDtoStatusEnum>[
        _$stickerImportResponseDtoStatusEnum_PROCESSING,
        _$stickerImportResponseDtoStatusEnum_COMPLETED,
        _$stickerImportResponseDtoStatusEnum_FAILED,
        _$stickerImportResponseDtoStatusEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<StickerImportResponseDtoStatusEnum>
_$stickerImportResponseDtoStatusEnumSerializer =
    _$StickerImportResponseDtoStatusEnumSerializer();

class _$StickerImportResponseDtoStatusEnumSerializer
    implements PrimitiveSerializer<StickerImportResponseDtoStatusEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'PROCESSING': 'PROCESSING',
    'COMPLETED': 'COMPLETED',
    'FAILED': 'FAILED',
    'unknownDefaultOpenApi': 'unknown_default_open_api',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'PROCESSING': 'PROCESSING',
    'COMPLETED': 'COMPLETED',
    'FAILED': 'FAILED',
    'unknown_default_open_api': 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[StickerImportResponseDtoStatusEnum];
  @override
  final String wireName = 'StickerImportResponseDtoStatusEnum';

  @override
  Object serialize(
    Serializers serializers,
    StickerImportResponseDtoStatusEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  StickerImportResponseDtoStatusEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => StickerImportResponseDtoStatusEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$StickerImportResponseDto extends StickerImportResponseDto {
  @override
  final String id;
  @override
  final StickerImportResponseDtoStatusEnum status;
  @override
  final UserStickerResponseDto? favorite;
  @override
  final String? failureCode;
  @override
  final String? failureMessage;
  @override
  final bool alreadySaved;

  factory _$StickerImportResponseDto([
    void Function(StickerImportResponseDtoBuilder)? updates,
  ]) => (StickerImportResponseDtoBuilder()..update(updates))._build();

  _$StickerImportResponseDto._({
    required this.id,
    required this.status,
    this.favorite,
    this.failureCode,
    this.failureMessage,
    required this.alreadySaved,
  }) : super._();
  @override
  StickerImportResponseDto rebuild(
    void Function(StickerImportResponseDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  StickerImportResponseDtoBuilder toBuilder() =>
      StickerImportResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is StickerImportResponseDto &&
        id == other.id &&
        status == other.status &&
        favorite == other.favorite &&
        failureCode == other.failureCode &&
        failureMessage == other.failureMessage &&
        alreadySaved == other.alreadySaved;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, favorite.hashCode);
    _$hash = $jc(_$hash, failureCode.hashCode);
    _$hash = $jc(_$hash, failureMessage.hashCode);
    _$hash = $jc(_$hash, alreadySaved.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'StickerImportResponseDto')
          ..add('id', id)
          ..add('status', status)
          ..add('favorite', favorite)
          ..add('failureCode', failureCode)
          ..add('failureMessage', failureMessage)
          ..add('alreadySaved', alreadySaved))
        .toString();
  }
}

class StickerImportResponseDtoBuilder
    implements
        Builder<StickerImportResponseDto, StickerImportResponseDtoBuilder> {
  _$StickerImportResponseDto? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  StickerImportResponseDtoStatusEnum? _status;
  StickerImportResponseDtoStatusEnum? get status => _$this._status;
  set status(StickerImportResponseDtoStatusEnum? status) =>
      _$this._status = status;

  UserStickerResponseDtoBuilder? _favorite;
  UserStickerResponseDtoBuilder get favorite =>
      _$this._favorite ??= UserStickerResponseDtoBuilder();
  set favorite(UserStickerResponseDtoBuilder? favorite) =>
      _$this._favorite = favorite;

  String? _failureCode;
  String? get failureCode => _$this._failureCode;
  set failureCode(String? failureCode) => _$this._failureCode = failureCode;

  String? _failureMessage;
  String? get failureMessage => _$this._failureMessage;
  set failureMessage(String? failureMessage) =>
      _$this._failureMessage = failureMessage;

  bool? _alreadySaved;
  bool? get alreadySaved => _$this._alreadySaved;
  set alreadySaved(bool? alreadySaved) => _$this._alreadySaved = alreadySaved;

  StickerImportResponseDtoBuilder() {
    StickerImportResponseDto._defaults(this);
  }

  StickerImportResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _status = $v.status;
      _favorite = $v.favorite?.toBuilder();
      _failureCode = $v.failureCode;
      _failureMessage = $v.failureMessage;
      _alreadySaved = $v.alreadySaved;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(StickerImportResponseDto other) {
    _$v = other as _$StickerImportResponseDto;
  }

  @override
  void update(void Function(StickerImportResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  StickerImportResponseDto build() => _build();

  _$StickerImportResponseDto _build() {
    _$StickerImportResponseDto _$result;
    try {
      _$result =
          _$v ??
          _$StickerImportResponseDto._(
            id: BuiltValueNullFieldError.checkNotNull(
              id,
              r'StickerImportResponseDto',
              'id',
            ),
            status: BuiltValueNullFieldError.checkNotNull(
              status,
              r'StickerImportResponseDto',
              'status',
            ),
            favorite: _favorite?.build(),
            failureCode: failureCode,
            failureMessage: failureMessage,
            alreadySaved: BuiltValueNullFieldError.checkNotNull(
              alreadySaved,
              r'StickerImportResponseDto',
              'alreadySaved',
            ),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'favorite';
        _favorite?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'StickerImportResponseDto',
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
