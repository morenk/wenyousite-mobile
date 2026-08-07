// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reordered_subthread_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ReorderedSubthreadResponseDto extends ReorderedSubthreadResponseDto {
  @override
  final String id;
  @override
  final String title;
  @override
  final num sortOrder;

  factory _$ReorderedSubthreadResponseDto([
    void Function(ReorderedSubthreadResponseDtoBuilder)? updates,
  ]) => (ReorderedSubthreadResponseDtoBuilder()..update(updates))._build();

  _$ReorderedSubthreadResponseDto._({
    required this.id,
    required this.title,
    required this.sortOrder,
  }) : super._();
  @override
  ReorderedSubthreadResponseDto rebuild(
    void Function(ReorderedSubthreadResponseDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  ReorderedSubthreadResponseDtoBuilder toBuilder() =>
      ReorderedSubthreadResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ReorderedSubthreadResponseDto &&
        id == other.id &&
        title == other.title &&
        sortOrder == other.sortOrder;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, title.hashCode);
    _$hash = $jc(_$hash, sortOrder.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ReorderedSubthreadResponseDto')
          ..add('id', id)
          ..add('title', title)
          ..add('sortOrder', sortOrder))
        .toString();
  }
}

class ReorderedSubthreadResponseDtoBuilder
    implements
        Builder<
          ReorderedSubthreadResponseDto,
          ReorderedSubthreadResponseDtoBuilder
        > {
  _$ReorderedSubthreadResponseDto? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _title;
  String? get title => _$this._title;
  set title(String? title) => _$this._title = title;

  num? _sortOrder;
  num? get sortOrder => _$this._sortOrder;
  set sortOrder(num? sortOrder) => _$this._sortOrder = sortOrder;

  ReorderedSubthreadResponseDtoBuilder() {
    ReorderedSubthreadResponseDto._defaults(this);
  }

  ReorderedSubthreadResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _title = $v.title;
      _sortOrder = $v.sortOrder;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ReorderedSubthreadResponseDto other) {
    _$v = other as _$ReorderedSubthreadResponseDto;
  }

  @override
  void update(void Function(ReorderedSubthreadResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ReorderedSubthreadResponseDto build() => _build();

  _$ReorderedSubthreadResponseDto _build() {
    final _$result =
        _$v ??
        _$ReorderedSubthreadResponseDto._(
          id: BuiltValueNullFieldError.checkNotNull(
            id,
            r'ReorderedSubthreadResponseDto',
            'id',
          ),
          title: BuiltValueNullFieldError.checkNotNull(
            title,
            r'ReorderedSubthreadResponseDto',
            'title',
          ),
          sortOrder: BuiltValueNullFieldError.checkNotNull(
            sortOrder,
            r'ReorderedSubthreadResponseDto',
            'sortOrder',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
