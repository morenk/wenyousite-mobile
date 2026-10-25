// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'font_order_item_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$FontOrderItemDto extends FontOrderItemDto {
  @override
  final String familyId;
  @override
  final int expectedFamilyRevision;

  factory _$FontOrderItemDto([
    void Function(FontOrderItemDtoBuilder)? updates,
  ]) => (FontOrderItemDtoBuilder()..update(updates))._build();

  _$FontOrderItemDto._({
    required this.familyId,
    required this.expectedFamilyRevision,
  }) : super._();
  @override
  FontOrderItemDto rebuild(void Function(FontOrderItemDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  FontOrderItemDtoBuilder toBuilder() =>
      FontOrderItemDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is FontOrderItemDto &&
        familyId == other.familyId &&
        expectedFamilyRevision == other.expectedFamilyRevision;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, familyId.hashCode);
    _$hash = $jc(_$hash, expectedFamilyRevision.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'FontOrderItemDto')
          ..add('familyId', familyId)
          ..add('expectedFamilyRevision', expectedFamilyRevision))
        .toString();
  }
}

class FontOrderItemDtoBuilder
    implements Builder<FontOrderItemDto, FontOrderItemDtoBuilder> {
  _$FontOrderItemDto? _$v;

  String? _familyId;
  String? get familyId => _$this._familyId;
  set familyId(String? familyId) => _$this._familyId = familyId;

  int? _expectedFamilyRevision;
  int? get expectedFamilyRevision => _$this._expectedFamilyRevision;
  set expectedFamilyRevision(int? expectedFamilyRevision) =>
      _$this._expectedFamilyRevision = expectedFamilyRevision;

  FontOrderItemDtoBuilder() {
    FontOrderItemDto._defaults(this);
  }

  FontOrderItemDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _familyId = $v.familyId;
      _expectedFamilyRevision = $v.expectedFamilyRevision;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(FontOrderItemDto other) {
    _$v = other as _$FontOrderItemDto;
  }

  @override
  void update(void Function(FontOrderItemDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  FontOrderItemDto build() => _build();

  _$FontOrderItemDto _build() {
    final _$result =
        _$v ??
        _$FontOrderItemDto._(
          familyId: BuiltValueNullFieldError.checkNotNull(
            familyId,
            r'FontOrderItemDto',
            'familyId',
          ),
          expectedFamilyRevision: BuiltValueNullFieldError.checkNotNull(
            expectedFamilyRevision,
            r'FontOrderItemDto',
            'expectedFamilyRevision',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
