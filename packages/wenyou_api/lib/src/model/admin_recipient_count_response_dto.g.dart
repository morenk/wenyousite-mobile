// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_recipient_count_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AdminRecipientCountResponseDto extends AdminRecipientCountResponseDto {
  @override
  final num recipientCount;
  @override
  final num? estimatedCount;

  factory _$AdminRecipientCountResponseDto([
    void Function(AdminRecipientCountResponseDtoBuilder)? updates,
  ]) => (AdminRecipientCountResponseDtoBuilder()..update(updates))._build();

  _$AdminRecipientCountResponseDto._({
    required this.recipientCount,
    this.estimatedCount,
  }) : super._();
  @override
  AdminRecipientCountResponseDto rebuild(
    void Function(AdminRecipientCountResponseDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  AdminRecipientCountResponseDtoBuilder toBuilder() =>
      AdminRecipientCountResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminRecipientCountResponseDto &&
        recipientCount == other.recipientCount &&
        estimatedCount == other.estimatedCount;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, recipientCount.hashCode);
    _$hash = $jc(_$hash, estimatedCount.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AdminRecipientCountResponseDto')
          ..add('recipientCount', recipientCount)
          ..add('estimatedCount', estimatedCount))
        .toString();
  }
}

class AdminRecipientCountResponseDtoBuilder
    implements
        Builder<
          AdminRecipientCountResponseDto,
          AdminRecipientCountResponseDtoBuilder
        > {
  _$AdminRecipientCountResponseDto? _$v;

  num? _recipientCount;
  num? get recipientCount => _$this._recipientCount;
  set recipientCount(num? recipientCount) =>
      _$this._recipientCount = recipientCount;

  num? _estimatedCount;
  num? get estimatedCount => _$this._estimatedCount;
  set estimatedCount(num? estimatedCount) =>
      _$this._estimatedCount = estimatedCount;

  AdminRecipientCountResponseDtoBuilder() {
    AdminRecipientCountResponseDto._defaults(this);
  }

  AdminRecipientCountResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _recipientCount = $v.recipientCount;
      _estimatedCount = $v.estimatedCount;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AdminRecipientCountResponseDto other) {
    _$v = other as _$AdminRecipientCountResponseDto;
  }

  @override
  void update(void Function(AdminRecipientCountResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AdminRecipientCountResponseDto build() => _build();

  _$AdminRecipientCountResponseDto _build() {
    final _$result =
        _$v ??
        _$AdminRecipientCountResponseDto._(
          recipientCount: BuiltValueNullFieldError.checkNotNull(
            recipientCount,
            r'AdminRecipientCountResponseDto',
            'recipientCount',
          ),
          estimatedCount: estimatedCount,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
