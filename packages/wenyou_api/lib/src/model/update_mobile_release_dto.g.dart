// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_mobile_release_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$UpdateMobileReleaseDto extends UpdateMobileReleaseDto {
  @override
  final String summary;
  @override
  final BuiltList<String> items;
  @override
  final String? versionName;
  @override
  final num revision;

  factory _$UpdateMobileReleaseDto([
    void Function(UpdateMobileReleaseDtoBuilder)? updates,
  ]) => (UpdateMobileReleaseDtoBuilder()..update(updates))._build();

  _$UpdateMobileReleaseDto._({
    required this.summary,
    required this.items,
    this.versionName,
    required this.revision,
  }) : super._();
  @override
  UpdateMobileReleaseDto rebuild(
    void Function(UpdateMobileReleaseDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  UpdateMobileReleaseDtoBuilder toBuilder() =>
      UpdateMobileReleaseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is UpdateMobileReleaseDto &&
        summary == other.summary &&
        items == other.items &&
        versionName == other.versionName &&
        revision == other.revision;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, summary.hashCode);
    _$hash = $jc(_$hash, items.hashCode);
    _$hash = $jc(_$hash, versionName.hashCode);
    _$hash = $jc(_$hash, revision.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'UpdateMobileReleaseDto')
          ..add('summary', summary)
          ..add('items', items)
          ..add('versionName', versionName)
          ..add('revision', revision))
        .toString();
  }
}

class UpdateMobileReleaseDtoBuilder
    implements Builder<UpdateMobileReleaseDto, UpdateMobileReleaseDtoBuilder> {
  _$UpdateMobileReleaseDto? _$v;

  String? _summary;
  String? get summary => _$this._summary;
  set summary(String? summary) => _$this._summary = summary;

  ListBuilder<String>? _items;
  ListBuilder<String> get items => _$this._items ??= ListBuilder<String>();
  set items(ListBuilder<String>? items) => _$this._items = items;

  String? _versionName;
  String? get versionName => _$this._versionName;
  set versionName(String? versionName) => _$this._versionName = versionName;

  num? _revision;
  num? get revision => _$this._revision;
  set revision(num? revision) => _$this._revision = revision;

  UpdateMobileReleaseDtoBuilder() {
    UpdateMobileReleaseDto._defaults(this);
  }

  UpdateMobileReleaseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _summary = $v.summary;
      _items = $v.items.toBuilder();
      _versionName = $v.versionName;
      _revision = $v.revision;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(UpdateMobileReleaseDto other) {
    _$v = other as _$UpdateMobileReleaseDto;
  }

  @override
  void update(void Function(UpdateMobileReleaseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  UpdateMobileReleaseDto build() => _build();

  _$UpdateMobileReleaseDto _build() {
    _$UpdateMobileReleaseDto _$result;
    try {
      _$result =
          _$v ??
          _$UpdateMobileReleaseDto._(
            summary: BuiltValueNullFieldError.checkNotNull(
              summary,
              r'UpdateMobileReleaseDto',
              'summary',
            ),
            items: items.build(),
            versionName: versionName,
            revision: BuiltValueNullFieldError.checkNotNull(
              revision,
              r'UpdateMobileReleaseDto',
              'revision',
            ),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'items';
        items.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'UpdateMobileReleaseDto',
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
