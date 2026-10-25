// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'font_retry_policy_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const FontRetryPolicyDtoJitterEnum _$fontRetryPolicyDtoJitterEnum_full =
    const FontRetryPolicyDtoJitterEnum._('full');
const FontRetryPolicyDtoJitterEnum
_$fontRetryPolicyDtoJitterEnum_unknownDefaultOpenApi =
    const FontRetryPolicyDtoJitterEnum._('unknownDefaultOpenApi');

FontRetryPolicyDtoJitterEnum _$fontRetryPolicyDtoJitterEnumValueOf(
  String name,
) {
  switch (name) {
    case 'full':
      return _$fontRetryPolicyDtoJitterEnum_full;
    case 'unknownDefaultOpenApi':
      return _$fontRetryPolicyDtoJitterEnum_unknownDefaultOpenApi;
    default:
      return _$fontRetryPolicyDtoJitterEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<FontRetryPolicyDtoJitterEnum>
_$fontRetryPolicyDtoJitterEnumValues =
    BuiltSet<FontRetryPolicyDtoJitterEnum>(const <FontRetryPolicyDtoJitterEnum>[
      _$fontRetryPolicyDtoJitterEnum_full,
      _$fontRetryPolicyDtoJitterEnum_unknownDefaultOpenApi,
    ]);

Serializer<FontRetryPolicyDtoJitterEnum>
_$fontRetryPolicyDtoJitterEnumSerializer =
    _$FontRetryPolicyDtoJitterEnumSerializer();

class _$FontRetryPolicyDtoJitterEnumSerializer
    implements PrimitiveSerializer<FontRetryPolicyDtoJitterEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'full': 'full',
    'unknownDefaultOpenApi': 'unknown_default_open_api',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'full': 'full',
    'unknown_default_open_api': 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[FontRetryPolicyDtoJitterEnum];
  @override
  final String wireName = 'FontRetryPolicyDtoJitterEnum';

  @override
  Object serialize(
    Serializers serializers,
    FontRetryPolicyDtoJitterEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  FontRetryPolicyDtoJitterEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => FontRetryPolicyDtoJitterEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$FontRetryPolicyDto extends FontRetryPolicyDto {
  @override
  final BuiltList<num> delayCeilingsMs;
  @override
  final FontRetryPolicyDtoJitterEnum jitter;
  @override
  final BuiltList<num> retryableHttpStatuses;
  @override
  final bool retryNetworkErrors;
  @override
  final bool retryTimeouts;
  @override
  final bool respectRetryAfter;

  factory _$FontRetryPolicyDto([
    void Function(FontRetryPolicyDtoBuilder)? updates,
  ]) => (FontRetryPolicyDtoBuilder()..update(updates))._build();

  _$FontRetryPolicyDto._({
    required this.delayCeilingsMs,
    required this.jitter,
    required this.retryableHttpStatuses,
    required this.retryNetworkErrors,
    required this.retryTimeouts,
    required this.respectRetryAfter,
  }) : super._();
  @override
  FontRetryPolicyDto rebuild(
    void Function(FontRetryPolicyDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  FontRetryPolicyDtoBuilder toBuilder() =>
      FontRetryPolicyDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is FontRetryPolicyDto &&
        delayCeilingsMs == other.delayCeilingsMs &&
        jitter == other.jitter &&
        retryableHttpStatuses == other.retryableHttpStatuses &&
        retryNetworkErrors == other.retryNetworkErrors &&
        retryTimeouts == other.retryTimeouts &&
        respectRetryAfter == other.respectRetryAfter;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, delayCeilingsMs.hashCode);
    _$hash = $jc(_$hash, jitter.hashCode);
    _$hash = $jc(_$hash, retryableHttpStatuses.hashCode);
    _$hash = $jc(_$hash, retryNetworkErrors.hashCode);
    _$hash = $jc(_$hash, retryTimeouts.hashCode);
    _$hash = $jc(_$hash, respectRetryAfter.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'FontRetryPolicyDto')
          ..add('delayCeilingsMs', delayCeilingsMs)
          ..add('jitter', jitter)
          ..add('retryableHttpStatuses', retryableHttpStatuses)
          ..add('retryNetworkErrors', retryNetworkErrors)
          ..add('retryTimeouts', retryTimeouts)
          ..add('respectRetryAfter', respectRetryAfter))
        .toString();
  }
}

class FontRetryPolicyDtoBuilder
    implements Builder<FontRetryPolicyDto, FontRetryPolicyDtoBuilder> {
  _$FontRetryPolicyDto? _$v;

  ListBuilder<num>? _delayCeilingsMs;
  ListBuilder<num> get delayCeilingsMs =>
      _$this._delayCeilingsMs ??= ListBuilder<num>();
  set delayCeilingsMs(ListBuilder<num>? delayCeilingsMs) =>
      _$this._delayCeilingsMs = delayCeilingsMs;

  FontRetryPolicyDtoJitterEnum? _jitter;
  FontRetryPolicyDtoJitterEnum? get jitter => _$this._jitter;
  set jitter(FontRetryPolicyDtoJitterEnum? jitter) => _$this._jitter = jitter;

  ListBuilder<num>? _retryableHttpStatuses;
  ListBuilder<num> get retryableHttpStatuses =>
      _$this._retryableHttpStatuses ??= ListBuilder<num>();
  set retryableHttpStatuses(ListBuilder<num>? retryableHttpStatuses) =>
      _$this._retryableHttpStatuses = retryableHttpStatuses;

  bool? _retryNetworkErrors;
  bool? get retryNetworkErrors => _$this._retryNetworkErrors;
  set retryNetworkErrors(bool? retryNetworkErrors) =>
      _$this._retryNetworkErrors = retryNetworkErrors;

  bool? _retryTimeouts;
  bool? get retryTimeouts => _$this._retryTimeouts;
  set retryTimeouts(bool? retryTimeouts) =>
      _$this._retryTimeouts = retryTimeouts;

  bool? _respectRetryAfter;
  bool? get respectRetryAfter => _$this._respectRetryAfter;
  set respectRetryAfter(bool? respectRetryAfter) =>
      _$this._respectRetryAfter = respectRetryAfter;

  FontRetryPolicyDtoBuilder() {
    FontRetryPolicyDto._defaults(this);
  }

  FontRetryPolicyDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _delayCeilingsMs = $v.delayCeilingsMs.toBuilder();
      _jitter = $v.jitter;
      _retryableHttpStatuses = $v.retryableHttpStatuses.toBuilder();
      _retryNetworkErrors = $v.retryNetworkErrors;
      _retryTimeouts = $v.retryTimeouts;
      _respectRetryAfter = $v.respectRetryAfter;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(FontRetryPolicyDto other) {
    _$v = other as _$FontRetryPolicyDto;
  }

  @override
  void update(void Function(FontRetryPolicyDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  FontRetryPolicyDto build() => _build();

  _$FontRetryPolicyDto _build() {
    _$FontRetryPolicyDto _$result;
    try {
      _$result =
          _$v ??
          _$FontRetryPolicyDto._(
            delayCeilingsMs: delayCeilingsMs.build(),
            jitter: BuiltValueNullFieldError.checkNotNull(
              jitter,
              r'FontRetryPolicyDto',
              'jitter',
            ),
            retryableHttpStatuses: retryableHttpStatuses.build(),
            retryNetworkErrors: BuiltValueNullFieldError.checkNotNull(
              retryNetworkErrors,
              r'FontRetryPolicyDto',
              'retryNetworkErrors',
            ),
            retryTimeouts: BuiltValueNullFieldError.checkNotNull(
              retryTimeouts,
              r'FontRetryPolicyDto',
              'retryTimeouts',
            ),
            respectRetryAfter: BuiltValueNullFieldError.checkNotNull(
              respectRetryAfter,
              r'FontRetryPolicyDto',
              'respectRetryAfter',
            ),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'delayCeilingsMs';
        delayCeilingsMs.build();

        _$failedField = 'retryableHttpStatuses';
        retryableHttpStatuses.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'FontRetryPolicyDto',
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
