// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_moment_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$NotificationMomentResponseDto extends NotificationMomentResponseDto {
  @override
  final String id;
  @override
  final String title;
  @override
  final DateTime? deletedAt;

  factory _$NotificationMomentResponseDto([
    void Function(NotificationMomentResponseDtoBuilder)? updates,
  ]) => (NotificationMomentResponseDtoBuilder()..update(updates))._build();

  _$NotificationMomentResponseDto._({
    required this.id,
    required this.title,
    this.deletedAt,
  }) : super._();
  @override
  NotificationMomentResponseDto rebuild(
    void Function(NotificationMomentResponseDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  NotificationMomentResponseDtoBuilder toBuilder() =>
      NotificationMomentResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is NotificationMomentResponseDto &&
        id == other.id &&
        title == other.title &&
        deletedAt == other.deletedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, title.hashCode);
    _$hash = $jc(_$hash, deletedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'NotificationMomentResponseDto')
          ..add('id', id)
          ..add('title', title)
          ..add('deletedAt', deletedAt))
        .toString();
  }
}

class NotificationMomentResponseDtoBuilder
    implements
        Builder<
          NotificationMomentResponseDto,
          NotificationMomentResponseDtoBuilder
        > {
  _$NotificationMomentResponseDto? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _title;
  String? get title => _$this._title;
  set title(String? title) => _$this._title = title;

  DateTime? _deletedAt;
  DateTime? get deletedAt => _$this._deletedAt;
  set deletedAt(DateTime? deletedAt) => _$this._deletedAt = deletedAt;

  NotificationMomentResponseDtoBuilder() {
    NotificationMomentResponseDto._defaults(this);
  }

  NotificationMomentResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _title = $v.title;
      _deletedAt = $v.deletedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(NotificationMomentResponseDto other) {
    _$v = other as _$NotificationMomentResponseDto;
  }

  @override
  void update(void Function(NotificationMomentResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  NotificationMomentResponseDto build() => _build();

  _$NotificationMomentResponseDto _build() {
    final _$result =
        _$v ??
        _$NotificationMomentResponseDto._(
          id: BuiltValueNullFieldError.checkNotNull(
            id,
            r'NotificationMomentResponseDto',
            'id',
          ),
          title: BuiltValueNullFieldError.checkNotNull(
            title,
            r'NotificationMomentResponseDto',
            'title',
          ),
          deletedAt: deletedAt,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
