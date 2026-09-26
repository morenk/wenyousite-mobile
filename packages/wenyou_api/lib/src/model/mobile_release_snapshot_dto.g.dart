// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mobile_release_snapshot_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$MobileReleaseSnapshotDto extends MobileReleaseSnapshotDto {
  @override
  final String summary;
  @override
  final BuiltList<String> items;
  @override
  final num revision;
  @override
  final DateTime confirmedAt;

  factory _$MobileReleaseSnapshotDto([
    void Function(MobileReleaseSnapshotDtoBuilder)? updates,
  ]) => (MobileReleaseSnapshotDtoBuilder()..update(updates))._build();

  _$MobileReleaseSnapshotDto._({
    required this.summary,
    required this.items,
    required this.revision,
    required this.confirmedAt,
  }) : super._();
  @override
  MobileReleaseSnapshotDto rebuild(
    void Function(MobileReleaseSnapshotDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  MobileReleaseSnapshotDtoBuilder toBuilder() =>
      MobileReleaseSnapshotDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MobileReleaseSnapshotDto &&
        summary == other.summary &&
        items == other.items &&
        revision == other.revision &&
        confirmedAt == other.confirmedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, summary.hashCode);
    _$hash = $jc(_$hash, items.hashCode);
    _$hash = $jc(_$hash, revision.hashCode);
    _$hash = $jc(_$hash, confirmedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'MobileReleaseSnapshotDto')
          ..add('summary', summary)
          ..add('items', items)
          ..add('revision', revision)
          ..add('confirmedAt', confirmedAt))
        .toString();
  }
}

class MobileReleaseSnapshotDtoBuilder
    implements
        Builder<MobileReleaseSnapshotDto, MobileReleaseSnapshotDtoBuilder> {
  _$MobileReleaseSnapshotDto? _$v;

  String? _summary;
  String? get summary => _$this._summary;
  set summary(String? summary) => _$this._summary = summary;

  ListBuilder<String>? _items;
  ListBuilder<String> get items => _$this._items ??= ListBuilder<String>();
  set items(ListBuilder<String>? items) => _$this._items = items;

  num? _revision;
  num? get revision => _$this._revision;
  set revision(num? revision) => _$this._revision = revision;

  DateTime? _confirmedAt;
  DateTime? get confirmedAt => _$this._confirmedAt;
  set confirmedAt(DateTime? confirmedAt) => _$this._confirmedAt = confirmedAt;

  MobileReleaseSnapshotDtoBuilder() {
    MobileReleaseSnapshotDto._defaults(this);
  }

  MobileReleaseSnapshotDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _summary = $v.summary;
      _items = $v.items.toBuilder();
      _revision = $v.revision;
      _confirmedAt = $v.confirmedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(MobileReleaseSnapshotDto other) {
    _$v = other as _$MobileReleaseSnapshotDto;
  }

  @override
  void update(void Function(MobileReleaseSnapshotDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  MobileReleaseSnapshotDto build() => _build();

  _$MobileReleaseSnapshotDto _build() {
    _$MobileReleaseSnapshotDto _$result;
    try {
      _$result =
          _$v ??
          _$MobileReleaseSnapshotDto._(
            summary: BuiltValueNullFieldError.checkNotNull(
              summary,
              r'MobileReleaseSnapshotDto',
              'summary',
            ),
            items: items.build(),
            revision: BuiltValueNullFieldError.checkNotNull(
              revision,
              r'MobileReleaseSnapshotDto',
              'revision',
            ),
            confirmedAt: BuiltValueNullFieldError.checkNotNull(
              confirmedAt,
              r'MobileReleaseSnapshotDto',
              'confirmedAt',
            ),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'items';
        items.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'MobileReleaseSnapshotDto',
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
