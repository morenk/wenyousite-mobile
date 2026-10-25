// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'font_publish_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$FontPublishDto extends FontPublishDto {
  @override
  final String versionId;
  @override
  final int expectedFamilyRevision;
  @override
  final int expectedCatalogRevision;

  factory _$FontPublishDto([void Function(FontPublishDtoBuilder)? updates]) =>
      (FontPublishDtoBuilder()..update(updates))._build();

  _$FontPublishDto._({
    required this.versionId,
    required this.expectedFamilyRevision,
    required this.expectedCatalogRevision,
  }) : super._();
  @override
  FontPublishDto rebuild(void Function(FontPublishDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  FontPublishDtoBuilder toBuilder() => FontPublishDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is FontPublishDto &&
        versionId == other.versionId &&
        expectedFamilyRevision == other.expectedFamilyRevision &&
        expectedCatalogRevision == other.expectedCatalogRevision;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, versionId.hashCode);
    _$hash = $jc(_$hash, expectedFamilyRevision.hashCode);
    _$hash = $jc(_$hash, expectedCatalogRevision.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'FontPublishDto')
          ..add('versionId', versionId)
          ..add('expectedFamilyRevision', expectedFamilyRevision)
          ..add('expectedCatalogRevision', expectedCatalogRevision))
        .toString();
  }
}

class FontPublishDtoBuilder
    implements Builder<FontPublishDto, FontPublishDtoBuilder> {
  _$FontPublishDto? _$v;

  String? _versionId;
  String? get versionId => _$this._versionId;
  set versionId(String? versionId) => _$this._versionId = versionId;

  int? _expectedFamilyRevision;
  int? get expectedFamilyRevision => _$this._expectedFamilyRevision;
  set expectedFamilyRevision(int? expectedFamilyRevision) =>
      _$this._expectedFamilyRevision = expectedFamilyRevision;

  int? _expectedCatalogRevision;
  int? get expectedCatalogRevision => _$this._expectedCatalogRevision;
  set expectedCatalogRevision(int? expectedCatalogRevision) =>
      _$this._expectedCatalogRevision = expectedCatalogRevision;

  FontPublishDtoBuilder() {
    FontPublishDto._defaults(this);
  }

  FontPublishDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _versionId = $v.versionId;
      _expectedFamilyRevision = $v.expectedFamilyRevision;
      _expectedCatalogRevision = $v.expectedCatalogRevision;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(FontPublishDto other) {
    _$v = other as _$FontPublishDto;
  }

  @override
  void update(void Function(FontPublishDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  FontPublishDto build() => _build();

  _$FontPublishDto _build() {
    final _$result =
        _$v ??
        _$FontPublishDto._(
          versionId: BuiltValueNullFieldError.checkNotNull(
            versionId,
            r'FontPublishDto',
            'versionId',
          ),
          expectedFamilyRevision: BuiltValueNullFieldError.checkNotNull(
            expectedFamilyRevision,
            r'FontPublishDto',
            'expectedFamilyRevision',
          ),
          expectedCatalogRevision: BuiltValueNullFieldError.checkNotNull(
            expectedCatalogRevision,
            r'FontPublishDto',
            'expectedCatalogRevision',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
