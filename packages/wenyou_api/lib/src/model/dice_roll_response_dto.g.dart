// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dice_roll_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$DiceRollResponseDto extends DiceRollResponseDto {
  @override
  final String id;
  @override
  final String postId;
  @override
  final String nodeId;
  @override
  final num protocolVersion;
  @override
  final String notation;
  @override
  final num quantity;
  @override
  final num sides;
  @override
  final num modifier;
  @override
  final BuiltList<num> results;
  @override
  final num total;
  @override
  final DateTime createdAt;

  factory _$DiceRollResponseDto([
    void Function(DiceRollResponseDtoBuilder)? updates,
  ]) => (DiceRollResponseDtoBuilder()..update(updates))._build();

  _$DiceRollResponseDto._({
    required this.id,
    required this.postId,
    required this.nodeId,
    required this.protocolVersion,
    required this.notation,
    required this.quantity,
    required this.sides,
    required this.modifier,
    required this.results,
    required this.total,
    required this.createdAt,
  }) : super._();
  @override
  DiceRollResponseDto rebuild(
    void Function(DiceRollResponseDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  DiceRollResponseDtoBuilder toBuilder() =>
      DiceRollResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is DiceRollResponseDto &&
        id == other.id &&
        postId == other.postId &&
        nodeId == other.nodeId &&
        protocolVersion == other.protocolVersion &&
        notation == other.notation &&
        quantity == other.quantity &&
        sides == other.sides &&
        modifier == other.modifier &&
        results == other.results &&
        total == other.total &&
        createdAt == other.createdAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, postId.hashCode);
    _$hash = $jc(_$hash, nodeId.hashCode);
    _$hash = $jc(_$hash, protocolVersion.hashCode);
    _$hash = $jc(_$hash, notation.hashCode);
    _$hash = $jc(_$hash, quantity.hashCode);
    _$hash = $jc(_$hash, sides.hashCode);
    _$hash = $jc(_$hash, modifier.hashCode);
    _$hash = $jc(_$hash, results.hashCode);
    _$hash = $jc(_$hash, total.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'DiceRollResponseDto')
          ..add('id', id)
          ..add('postId', postId)
          ..add('nodeId', nodeId)
          ..add('protocolVersion', protocolVersion)
          ..add('notation', notation)
          ..add('quantity', quantity)
          ..add('sides', sides)
          ..add('modifier', modifier)
          ..add('results', results)
          ..add('total', total)
          ..add('createdAt', createdAt))
        .toString();
  }
}

class DiceRollResponseDtoBuilder
    implements Builder<DiceRollResponseDto, DiceRollResponseDtoBuilder> {
  _$DiceRollResponseDto? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _postId;
  String? get postId => _$this._postId;
  set postId(String? postId) => _$this._postId = postId;

  String? _nodeId;
  String? get nodeId => _$this._nodeId;
  set nodeId(String? nodeId) => _$this._nodeId = nodeId;

  num? _protocolVersion;
  num? get protocolVersion => _$this._protocolVersion;
  set protocolVersion(num? protocolVersion) =>
      _$this._protocolVersion = protocolVersion;

  String? _notation;
  String? get notation => _$this._notation;
  set notation(String? notation) => _$this._notation = notation;

  num? _quantity;
  num? get quantity => _$this._quantity;
  set quantity(num? quantity) => _$this._quantity = quantity;

  num? _sides;
  num? get sides => _$this._sides;
  set sides(num? sides) => _$this._sides = sides;

  num? _modifier;
  num? get modifier => _$this._modifier;
  set modifier(num? modifier) => _$this._modifier = modifier;

  ListBuilder<num>? _results;
  ListBuilder<num> get results => _$this._results ??= ListBuilder<num>();
  set results(ListBuilder<num>? results) => _$this._results = results;

  num? _total;
  num? get total => _$this._total;
  set total(num? total) => _$this._total = total;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  DiceRollResponseDtoBuilder() {
    DiceRollResponseDto._defaults(this);
  }

  DiceRollResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _postId = $v.postId;
      _nodeId = $v.nodeId;
      _protocolVersion = $v.protocolVersion;
      _notation = $v.notation;
      _quantity = $v.quantity;
      _sides = $v.sides;
      _modifier = $v.modifier;
      _results = $v.results.toBuilder();
      _total = $v.total;
      _createdAt = $v.createdAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(DiceRollResponseDto other) {
    _$v = other as _$DiceRollResponseDto;
  }

  @override
  void update(void Function(DiceRollResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  DiceRollResponseDto build() => _build();

  _$DiceRollResponseDto _build() {
    _$DiceRollResponseDto _$result;
    try {
      _$result =
          _$v ??
          _$DiceRollResponseDto._(
            id: BuiltValueNullFieldError.checkNotNull(
              id,
              r'DiceRollResponseDto',
              'id',
            ),
            postId: BuiltValueNullFieldError.checkNotNull(
              postId,
              r'DiceRollResponseDto',
              'postId',
            ),
            nodeId: BuiltValueNullFieldError.checkNotNull(
              nodeId,
              r'DiceRollResponseDto',
              'nodeId',
            ),
            protocolVersion: BuiltValueNullFieldError.checkNotNull(
              protocolVersion,
              r'DiceRollResponseDto',
              'protocolVersion',
            ),
            notation: BuiltValueNullFieldError.checkNotNull(
              notation,
              r'DiceRollResponseDto',
              'notation',
            ),
            quantity: BuiltValueNullFieldError.checkNotNull(
              quantity,
              r'DiceRollResponseDto',
              'quantity',
            ),
            sides: BuiltValueNullFieldError.checkNotNull(
              sides,
              r'DiceRollResponseDto',
              'sides',
            ),
            modifier: BuiltValueNullFieldError.checkNotNull(
              modifier,
              r'DiceRollResponseDto',
              'modifier',
            ),
            results: results.build(),
            total: BuiltValueNullFieldError.checkNotNull(
              total,
              r'DiceRollResponseDto',
              'total',
            ),
            createdAt: BuiltValueNullFieldError.checkNotNull(
              createdAt,
              r'DiceRollResponseDto',
              'createdAt',
            ),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'results';
        results.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'DiceRollResponseDto',
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
