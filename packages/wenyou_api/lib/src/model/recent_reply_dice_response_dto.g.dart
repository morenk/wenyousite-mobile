// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recent_reply_dice_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$RecentReplyDiceResponseDto extends RecentReplyDiceResponseDto {
  @override
  final String nodeId;
  @override
  final String notation;
  @override
  final num total;

  factory _$RecentReplyDiceResponseDto([
    void Function(RecentReplyDiceResponseDtoBuilder)? updates,
  ]) => (RecentReplyDiceResponseDtoBuilder()..update(updates))._build();

  _$RecentReplyDiceResponseDto._({
    required this.nodeId,
    required this.notation,
    required this.total,
  }) : super._();
  @override
  RecentReplyDiceResponseDto rebuild(
    void Function(RecentReplyDiceResponseDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  RecentReplyDiceResponseDtoBuilder toBuilder() =>
      RecentReplyDiceResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is RecentReplyDiceResponseDto &&
        nodeId == other.nodeId &&
        notation == other.notation &&
        total == other.total;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, nodeId.hashCode);
    _$hash = $jc(_$hash, notation.hashCode);
    _$hash = $jc(_$hash, total.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'RecentReplyDiceResponseDto')
          ..add('nodeId', nodeId)
          ..add('notation', notation)
          ..add('total', total))
        .toString();
  }
}

class RecentReplyDiceResponseDtoBuilder
    implements
        Builder<RecentReplyDiceResponseDto, RecentReplyDiceResponseDtoBuilder> {
  _$RecentReplyDiceResponseDto? _$v;

  String? _nodeId;
  String? get nodeId => _$this._nodeId;
  set nodeId(String? nodeId) => _$this._nodeId = nodeId;

  String? _notation;
  String? get notation => _$this._notation;
  set notation(String? notation) => _$this._notation = notation;

  num? _total;
  num? get total => _$this._total;
  set total(num? total) => _$this._total = total;

  RecentReplyDiceResponseDtoBuilder() {
    RecentReplyDiceResponseDto._defaults(this);
  }

  RecentReplyDiceResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _nodeId = $v.nodeId;
      _notation = $v.notation;
      _total = $v.total;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(RecentReplyDiceResponseDto other) {
    _$v = other as _$RecentReplyDiceResponseDto;
  }

  @override
  void update(void Function(RecentReplyDiceResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  RecentReplyDiceResponseDto build() => _build();

  _$RecentReplyDiceResponseDto _build() {
    final _$result =
        _$v ??
        _$RecentReplyDiceResponseDto._(
          nodeId: BuiltValueNullFieldError.checkNotNull(
            nodeId,
            r'RecentReplyDiceResponseDto',
            'nodeId',
          ),
          notation: BuiltValueNullFieldError.checkNotNull(
            notation,
            r'RecentReplyDiceResponseDto',
            'notation',
          ),
          total: BuiltValueNullFieldError.checkNotNull(
            total,
            r'RecentReplyDiceResponseDto',
            'total',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
