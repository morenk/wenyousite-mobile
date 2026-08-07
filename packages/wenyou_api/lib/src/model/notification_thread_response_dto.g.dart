// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_thread_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$NotificationThreadResponseDto extends NotificationThreadResponseDto {
  @override
  final String id;
  @override
  final String? title;
  @override
  final DateTime? deletedAt;

  factory _$NotificationThreadResponseDto([
    void Function(NotificationThreadResponseDtoBuilder)? updates,
  ]) => (NotificationThreadResponseDtoBuilder()..update(updates))._build();

  _$NotificationThreadResponseDto._({
    required this.id,
    this.title,
    this.deletedAt,
  }) : super._();
  @override
  NotificationThreadResponseDto rebuild(
    void Function(NotificationThreadResponseDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  NotificationThreadResponseDtoBuilder toBuilder() =>
      NotificationThreadResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is NotificationThreadResponseDto &&
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
    return (newBuiltValueToStringHelper(r'NotificationThreadResponseDto')
          ..add('id', id)
          ..add('title', title)
          ..add('deletedAt', deletedAt))
        .toString();
  }
}

class NotificationThreadResponseDtoBuilder
    implements
        Builder<
          NotificationThreadResponseDto,
          NotificationThreadResponseDtoBuilder
        > {
  _$NotificationThreadResponseDto? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _title;
  String? get title => _$this._title;
  set title(String? title) => _$this._title = title;

  DateTime? _deletedAt;
  DateTime? get deletedAt => _$this._deletedAt;
  set deletedAt(DateTime? deletedAt) => _$this._deletedAt = deletedAt;

  NotificationThreadResponseDtoBuilder() {
    NotificationThreadResponseDto._defaults(this);
  }

  NotificationThreadResponseDtoBuilder get _$this {
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
  void replace(NotificationThreadResponseDto other) {
    _$v = other as _$NotificationThreadResponseDto;
  }

  @override
  void update(void Function(NotificationThreadResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  NotificationThreadResponseDto build() => _build();

  _$NotificationThreadResponseDto _build() {
    final _$result =
        _$v ??
        _$NotificationThreadResponseDto._(
          id: BuiltValueNullFieldError.checkNotNull(
            id,
            r'NotificationThreadResponseDto',
            'id',
          ),
          title: title,
          deletedAt: deletedAt,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
