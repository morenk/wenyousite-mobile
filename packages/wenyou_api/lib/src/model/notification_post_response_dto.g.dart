// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_post_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$NotificationPostResponseDto extends NotificationPostResponseDto {
  @override
  final String id;
  @override
  final num? floorNumber;
  @override
  final String? parentPostId;
  @override
  final DateTime? deletedAt;

  factory _$NotificationPostResponseDto([
    void Function(NotificationPostResponseDtoBuilder)? updates,
  ]) => (NotificationPostResponseDtoBuilder()..update(updates))._build();

  _$NotificationPostResponseDto._({
    required this.id,
    this.floorNumber,
    this.parentPostId,
    this.deletedAt,
  }) : super._();
  @override
  NotificationPostResponseDto rebuild(
    void Function(NotificationPostResponseDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  NotificationPostResponseDtoBuilder toBuilder() =>
      NotificationPostResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is NotificationPostResponseDto &&
        id == other.id &&
        floorNumber == other.floorNumber &&
        parentPostId == other.parentPostId &&
        deletedAt == other.deletedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, floorNumber.hashCode);
    _$hash = $jc(_$hash, parentPostId.hashCode);
    _$hash = $jc(_$hash, deletedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'NotificationPostResponseDto')
          ..add('id', id)
          ..add('floorNumber', floorNumber)
          ..add('parentPostId', parentPostId)
          ..add('deletedAt', deletedAt))
        .toString();
  }
}

class NotificationPostResponseDtoBuilder
    implements
        Builder<
          NotificationPostResponseDto,
          NotificationPostResponseDtoBuilder
        > {
  _$NotificationPostResponseDto? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  num? _floorNumber;
  num? get floorNumber => _$this._floorNumber;
  set floorNumber(num? floorNumber) => _$this._floorNumber = floorNumber;

  String? _parentPostId;
  String? get parentPostId => _$this._parentPostId;
  set parentPostId(String? parentPostId) => _$this._parentPostId = parentPostId;

  DateTime? _deletedAt;
  DateTime? get deletedAt => _$this._deletedAt;
  set deletedAt(DateTime? deletedAt) => _$this._deletedAt = deletedAt;

  NotificationPostResponseDtoBuilder() {
    NotificationPostResponseDto._defaults(this);
  }

  NotificationPostResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _floorNumber = $v.floorNumber;
      _parentPostId = $v.parentPostId;
      _deletedAt = $v.deletedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(NotificationPostResponseDto other) {
    _$v = other as _$NotificationPostResponseDto;
  }

  @override
  void update(void Function(NotificationPostResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  NotificationPostResponseDto build() => _build();

  _$NotificationPostResponseDto _build() {
    final _$result =
        _$v ??
        _$NotificationPostResponseDto._(
          id: BuiltValueNullFieldError.checkNotNull(
            id,
            r'NotificationPostResponseDto',
            'id',
          ),
          floorNumber: floorNumber,
          parentPostId: parentPostId,
          deletedAt: deletedAt,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
