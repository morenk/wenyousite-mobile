// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'font_registration_snapshot_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$FontRegistrationSnapshotDto extends FontRegistrationSnapshotDto {
  @override
  final int assetCount;
  @override
  final int totalAssetBytes;
  @override
  final int registrationCount;
  @override
  final int totalRegistrationAssetBytes;

  factory _$FontRegistrationSnapshotDto([
    void Function(FontRegistrationSnapshotDtoBuilder)? updates,
  ]) => (FontRegistrationSnapshotDtoBuilder()..update(updates))._build();

  _$FontRegistrationSnapshotDto._({
    required this.assetCount,
    required this.totalAssetBytes,
    required this.registrationCount,
    required this.totalRegistrationAssetBytes,
  }) : super._();
  @override
  FontRegistrationSnapshotDto rebuild(
    void Function(FontRegistrationSnapshotDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  FontRegistrationSnapshotDtoBuilder toBuilder() =>
      FontRegistrationSnapshotDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is FontRegistrationSnapshotDto &&
        assetCount == other.assetCount &&
        totalAssetBytes == other.totalAssetBytes &&
        registrationCount == other.registrationCount &&
        totalRegistrationAssetBytes == other.totalRegistrationAssetBytes;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, assetCount.hashCode);
    _$hash = $jc(_$hash, totalAssetBytes.hashCode);
    _$hash = $jc(_$hash, registrationCount.hashCode);
    _$hash = $jc(_$hash, totalRegistrationAssetBytes.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'FontRegistrationSnapshotDto')
          ..add('assetCount', assetCount)
          ..add('totalAssetBytes', totalAssetBytes)
          ..add('registrationCount', registrationCount)
          ..add('totalRegistrationAssetBytes', totalRegistrationAssetBytes))
        .toString();
  }
}

class FontRegistrationSnapshotDtoBuilder
    implements
        Builder<
          FontRegistrationSnapshotDto,
          FontRegistrationSnapshotDtoBuilder
        > {
  _$FontRegistrationSnapshotDto? _$v;

  int? _assetCount;
  int? get assetCount => _$this._assetCount;
  set assetCount(int? assetCount) => _$this._assetCount = assetCount;

  int? _totalAssetBytes;
  int? get totalAssetBytes => _$this._totalAssetBytes;
  set totalAssetBytes(int? totalAssetBytes) =>
      _$this._totalAssetBytes = totalAssetBytes;

  int? _registrationCount;
  int? get registrationCount => _$this._registrationCount;
  set registrationCount(int? registrationCount) =>
      _$this._registrationCount = registrationCount;

  int? _totalRegistrationAssetBytes;
  int? get totalRegistrationAssetBytes => _$this._totalRegistrationAssetBytes;
  set totalRegistrationAssetBytes(int? totalRegistrationAssetBytes) =>
      _$this._totalRegistrationAssetBytes = totalRegistrationAssetBytes;

  FontRegistrationSnapshotDtoBuilder() {
    FontRegistrationSnapshotDto._defaults(this);
  }

  FontRegistrationSnapshotDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _assetCount = $v.assetCount;
      _totalAssetBytes = $v.totalAssetBytes;
      _registrationCount = $v.registrationCount;
      _totalRegistrationAssetBytes = $v.totalRegistrationAssetBytes;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(FontRegistrationSnapshotDto other) {
    _$v = other as _$FontRegistrationSnapshotDto;
  }

  @override
  void update(void Function(FontRegistrationSnapshotDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  FontRegistrationSnapshotDto build() => _build();

  _$FontRegistrationSnapshotDto _build() {
    final _$result =
        _$v ??
        _$FontRegistrationSnapshotDto._(
          assetCount: BuiltValueNullFieldError.checkNotNull(
            assetCount,
            r'FontRegistrationSnapshotDto',
            'assetCount',
          ),
          totalAssetBytes: BuiltValueNullFieldError.checkNotNull(
            totalAssetBytes,
            r'FontRegistrationSnapshotDto',
            'totalAssetBytes',
          ),
          registrationCount: BuiltValueNullFieldError.checkNotNull(
            registrationCount,
            r'FontRegistrationSnapshotDto',
            'registrationCount',
          ),
          totalRegistrationAssetBytes: BuiltValueNullFieldError.checkNotNull(
            totalRegistrationAssetBytes,
            r'FontRegistrationSnapshotDto',
            'totalRegistrationAssetBytes',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
