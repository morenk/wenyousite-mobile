// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'discussion_window_target_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$DiscussionWindowTargetDto extends DiscussionWindowTargetDto {
  @override
  final String id;
  @override
  final num number;

  factory _$DiscussionWindowTargetDto([
    void Function(DiscussionWindowTargetDtoBuilder)? updates,
  ]) => (DiscussionWindowTargetDtoBuilder()..update(updates))._build();

  _$DiscussionWindowTargetDto._({required this.id, required this.number})
    : super._();
  @override
  DiscussionWindowTargetDto rebuild(
    void Function(DiscussionWindowTargetDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  DiscussionWindowTargetDtoBuilder toBuilder() =>
      DiscussionWindowTargetDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is DiscussionWindowTargetDto &&
        id == other.id &&
        number == other.number;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, number.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'DiscussionWindowTargetDto')
          ..add('id', id)
          ..add('number', number))
        .toString();
  }
}

class DiscussionWindowTargetDtoBuilder
    implements
        Builder<DiscussionWindowTargetDto, DiscussionWindowTargetDtoBuilder> {
  _$DiscussionWindowTargetDto? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  num? _number;
  num? get number => _$this._number;
  set number(num? number) => _$this._number = number;

  DiscussionWindowTargetDtoBuilder() {
    DiscussionWindowTargetDto._defaults(this);
  }

  DiscussionWindowTargetDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _number = $v.number;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(DiscussionWindowTargetDto other) {
    _$v = other as _$DiscussionWindowTargetDto;
  }

  @override
  void update(void Function(DiscussionWindowTargetDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  DiscussionWindowTargetDto build() => _build();

  _$DiscussionWindowTargetDto _build() {
    final _$result =
        _$v ??
        _$DiscussionWindowTargetDto._(
          id: BuiltValueNullFieldError.checkNotNull(
            id,
            r'DiscussionWindowTargetDto',
            'id',
          ),
          number: BuiltValueNullFieldError.checkNotNull(
            number,
            r'DiscussionWindowTargetDto',
            'number',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
