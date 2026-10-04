// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'floor_window_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$FloorWindowResponseDto extends FloorWindowResponseDto {
  @override
  final num total;
  @override
  final num? maxNumber;
  @override
  final DiscussionWindowTargetDto? target;
  @override
  final String? beforeCursor;
  @override
  final String? afterCursor;
  @override
  final bool hasBefore;
  @override
  final bool hasAfter;
  @override
  final BuiltList<FloorResponseDto> items;
  @override
  final BuiltList<FloorResponseDto> pinnedItems;

  factory _$FloorWindowResponseDto([
    void Function(FloorWindowResponseDtoBuilder)? updates,
  ]) => (FloorWindowResponseDtoBuilder()..update(updates))._build();

  _$FloorWindowResponseDto._({
    required this.total,
    this.maxNumber,
    this.target,
    this.beforeCursor,
    this.afterCursor,
    required this.hasBefore,
    required this.hasAfter,
    required this.items,
    required this.pinnedItems,
  }) : super._();
  @override
  FloorWindowResponseDto rebuild(
    void Function(FloorWindowResponseDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  FloorWindowResponseDtoBuilder toBuilder() =>
      FloorWindowResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is FloorWindowResponseDto &&
        total == other.total &&
        maxNumber == other.maxNumber &&
        target == other.target &&
        beforeCursor == other.beforeCursor &&
        afterCursor == other.afterCursor &&
        hasBefore == other.hasBefore &&
        hasAfter == other.hasAfter &&
        items == other.items &&
        pinnedItems == other.pinnedItems;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, total.hashCode);
    _$hash = $jc(_$hash, maxNumber.hashCode);
    _$hash = $jc(_$hash, target.hashCode);
    _$hash = $jc(_$hash, beforeCursor.hashCode);
    _$hash = $jc(_$hash, afterCursor.hashCode);
    _$hash = $jc(_$hash, hasBefore.hashCode);
    _$hash = $jc(_$hash, hasAfter.hashCode);
    _$hash = $jc(_$hash, items.hashCode);
    _$hash = $jc(_$hash, pinnedItems.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'FloorWindowResponseDto')
          ..add('total', total)
          ..add('maxNumber', maxNumber)
          ..add('target', target)
          ..add('beforeCursor', beforeCursor)
          ..add('afterCursor', afterCursor)
          ..add('hasBefore', hasBefore)
          ..add('hasAfter', hasAfter)
          ..add('items', items)
          ..add('pinnedItems', pinnedItems))
        .toString();
  }
}

class FloorWindowResponseDtoBuilder
    implements Builder<FloorWindowResponseDto, FloorWindowResponseDtoBuilder> {
  _$FloorWindowResponseDto? _$v;

  num? _total;
  num? get total => _$this._total;
  set total(num? total) => _$this._total = total;

  num? _maxNumber;
  num? get maxNumber => _$this._maxNumber;
  set maxNumber(num? maxNumber) => _$this._maxNumber = maxNumber;

  DiscussionWindowTargetDtoBuilder? _target;
  DiscussionWindowTargetDtoBuilder get target =>
      _$this._target ??= DiscussionWindowTargetDtoBuilder();
  set target(DiscussionWindowTargetDtoBuilder? target) =>
      _$this._target = target;

  String? _beforeCursor;
  String? get beforeCursor => _$this._beforeCursor;
  set beforeCursor(String? beforeCursor) => _$this._beforeCursor = beforeCursor;

  String? _afterCursor;
  String? get afterCursor => _$this._afterCursor;
  set afterCursor(String? afterCursor) => _$this._afterCursor = afterCursor;

  bool? _hasBefore;
  bool? get hasBefore => _$this._hasBefore;
  set hasBefore(bool? hasBefore) => _$this._hasBefore = hasBefore;

  bool? _hasAfter;
  bool? get hasAfter => _$this._hasAfter;
  set hasAfter(bool? hasAfter) => _$this._hasAfter = hasAfter;

  ListBuilder<FloorResponseDto>? _items;
  ListBuilder<FloorResponseDto> get items =>
      _$this._items ??= ListBuilder<FloorResponseDto>();
  set items(ListBuilder<FloorResponseDto>? items) => _$this._items = items;

  ListBuilder<FloorResponseDto>? _pinnedItems;
  ListBuilder<FloorResponseDto> get pinnedItems =>
      _$this._pinnedItems ??= ListBuilder<FloorResponseDto>();
  set pinnedItems(ListBuilder<FloorResponseDto>? pinnedItems) =>
      _$this._pinnedItems = pinnedItems;

  FloorWindowResponseDtoBuilder() {
    FloorWindowResponseDto._defaults(this);
  }

  FloorWindowResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _total = $v.total;
      _maxNumber = $v.maxNumber;
      _target = $v.target?.toBuilder();
      _beforeCursor = $v.beforeCursor;
      _afterCursor = $v.afterCursor;
      _hasBefore = $v.hasBefore;
      _hasAfter = $v.hasAfter;
      _items = $v.items.toBuilder();
      _pinnedItems = $v.pinnedItems.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(FloorWindowResponseDto other) {
    _$v = other as _$FloorWindowResponseDto;
  }

  @override
  void update(void Function(FloorWindowResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  FloorWindowResponseDto build() => _build();

  _$FloorWindowResponseDto _build() {
    _$FloorWindowResponseDto _$result;
    try {
      _$result =
          _$v ??
          _$FloorWindowResponseDto._(
            total: BuiltValueNullFieldError.checkNotNull(
              total,
              r'FloorWindowResponseDto',
              'total',
            ),
            maxNumber: maxNumber,
            target: _target?.build(),
            beforeCursor: beforeCursor,
            afterCursor: afterCursor,
            hasBefore: BuiltValueNullFieldError.checkNotNull(
              hasBefore,
              r'FloorWindowResponseDto',
              'hasBefore',
            ),
            hasAfter: BuiltValueNullFieldError.checkNotNull(
              hasAfter,
              r'FloorWindowResponseDto',
              'hasAfter',
            ),
            items: items.build(),
            pinnedItems: pinnedItems.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'target';
        _target?.build();

        _$failedField = 'items';
        items.build();
        _$failedField = 'pinnedItems';
        pinnedItems.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'FloorWindowResponseDto',
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
