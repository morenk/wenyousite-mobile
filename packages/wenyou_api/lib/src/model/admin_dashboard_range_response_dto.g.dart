// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_dashboard_range_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AdminDashboardRangeResponseDto extends AdminDashboardRangeResponseDto {
  @override
  final String from;
  @override
  final String to;
  @override
  final String previousFrom;
  @override
  final String previousTo;
  @override
  final String timezone;

  factory _$AdminDashboardRangeResponseDto([
    void Function(AdminDashboardRangeResponseDtoBuilder)? updates,
  ]) => (AdminDashboardRangeResponseDtoBuilder()..update(updates))._build();

  _$AdminDashboardRangeResponseDto._({
    required this.from,
    required this.to,
    required this.previousFrom,
    required this.previousTo,
    required this.timezone,
  }) : super._();
  @override
  AdminDashboardRangeResponseDto rebuild(
    void Function(AdminDashboardRangeResponseDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  AdminDashboardRangeResponseDtoBuilder toBuilder() =>
      AdminDashboardRangeResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminDashboardRangeResponseDto &&
        from == other.from &&
        to == other.to &&
        previousFrom == other.previousFrom &&
        previousTo == other.previousTo &&
        timezone == other.timezone;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, from.hashCode);
    _$hash = $jc(_$hash, to.hashCode);
    _$hash = $jc(_$hash, previousFrom.hashCode);
    _$hash = $jc(_$hash, previousTo.hashCode);
    _$hash = $jc(_$hash, timezone.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AdminDashboardRangeResponseDto')
          ..add('from', from)
          ..add('to', to)
          ..add('previousFrom', previousFrom)
          ..add('previousTo', previousTo)
          ..add('timezone', timezone))
        .toString();
  }
}

class AdminDashboardRangeResponseDtoBuilder
    implements
        Builder<
          AdminDashboardRangeResponseDto,
          AdminDashboardRangeResponseDtoBuilder
        > {
  _$AdminDashboardRangeResponseDto? _$v;

  String? _from;
  String? get from => _$this._from;
  set from(String? from) => _$this._from = from;

  String? _to;
  String? get to => _$this._to;
  set to(String? to) => _$this._to = to;

  String? _previousFrom;
  String? get previousFrom => _$this._previousFrom;
  set previousFrom(String? previousFrom) => _$this._previousFrom = previousFrom;

  String? _previousTo;
  String? get previousTo => _$this._previousTo;
  set previousTo(String? previousTo) => _$this._previousTo = previousTo;

  String? _timezone;
  String? get timezone => _$this._timezone;
  set timezone(String? timezone) => _$this._timezone = timezone;

  AdminDashboardRangeResponseDtoBuilder() {
    AdminDashboardRangeResponseDto._defaults(this);
  }

  AdminDashboardRangeResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _from = $v.from;
      _to = $v.to;
      _previousFrom = $v.previousFrom;
      _previousTo = $v.previousTo;
      _timezone = $v.timezone;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AdminDashboardRangeResponseDto other) {
    _$v = other as _$AdminDashboardRangeResponseDto;
  }

  @override
  void update(void Function(AdminDashboardRangeResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AdminDashboardRangeResponseDto build() => _build();

  _$AdminDashboardRangeResponseDto _build() {
    final _$result =
        _$v ??
        _$AdminDashboardRangeResponseDto._(
          from: BuiltValueNullFieldError.checkNotNull(
            from,
            r'AdminDashboardRangeResponseDto',
            'from',
          ),
          to: BuiltValueNullFieldError.checkNotNull(
            to,
            r'AdminDashboardRangeResponseDto',
            'to',
          ),
          previousFrom: BuiltValueNullFieldError.checkNotNull(
            previousFrom,
            r'AdminDashboardRangeResponseDto',
            'previousFrom',
          ),
          previousTo: BuiltValueNullFieldError.checkNotNull(
            previousTo,
            r'AdminDashboardRangeResponseDto',
            'previousTo',
          ),
          timezone: BuiltValueNullFieldError.checkNotNull(
            timezone,
            r'AdminDashboardRangeResponseDto',
            'timezone',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
