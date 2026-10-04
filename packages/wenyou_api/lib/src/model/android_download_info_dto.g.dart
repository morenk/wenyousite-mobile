// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'android_download_info_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const AndroidDownloadInfoDtoStatusEnum
_$androidDownloadInfoDtoStatusEnum_available =
    const AndroidDownloadInfoDtoStatusEnum._('available');
const AndroidDownloadInfoDtoStatusEnum
_$androidDownloadInfoDtoStatusEnum_noRelease =
    const AndroidDownloadInfoDtoStatusEnum._('noRelease');
const AndroidDownloadInfoDtoStatusEnum
_$androidDownloadInfoDtoStatusEnum_withdrawn =
    const AndroidDownloadInfoDtoStatusEnum._('withdrawn');
const AndroidDownloadInfoDtoStatusEnum
_$androidDownloadInfoDtoStatusEnum_paused =
    const AndroidDownloadInfoDtoStatusEnum._('paused');
const AndroidDownloadInfoDtoStatusEnum
_$androidDownloadInfoDtoStatusEnum_unavailable =
    const AndroidDownloadInfoDtoStatusEnum._('unavailable');
const AndroidDownloadInfoDtoStatusEnum
_$androidDownloadInfoDtoStatusEnum_unknownDefaultOpenApi =
    const AndroidDownloadInfoDtoStatusEnum._('unknownDefaultOpenApi');

AndroidDownloadInfoDtoStatusEnum _$androidDownloadInfoDtoStatusEnumValueOf(
  String name,
) {
  switch (name) {
    case 'available':
      return _$androidDownloadInfoDtoStatusEnum_available;
    case 'noRelease':
      return _$androidDownloadInfoDtoStatusEnum_noRelease;
    case 'withdrawn':
      return _$androidDownloadInfoDtoStatusEnum_withdrawn;
    case 'paused':
      return _$androidDownloadInfoDtoStatusEnum_paused;
    case 'unavailable':
      return _$androidDownloadInfoDtoStatusEnum_unavailable;
    case 'unknownDefaultOpenApi':
      return _$androidDownloadInfoDtoStatusEnum_unknownDefaultOpenApi;
    default:
      return _$androidDownloadInfoDtoStatusEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<AndroidDownloadInfoDtoStatusEnum>
_$androidDownloadInfoDtoStatusEnumValues =
    BuiltSet<AndroidDownloadInfoDtoStatusEnum>(
      const <AndroidDownloadInfoDtoStatusEnum>[
        _$androidDownloadInfoDtoStatusEnum_available,
        _$androidDownloadInfoDtoStatusEnum_noRelease,
        _$androidDownloadInfoDtoStatusEnum_withdrawn,
        _$androidDownloadInfoDtoStatusEnum_paused,
        _$androidDownloadInfoDtoStatusEnum_unavailable,
        _$androidDownloadInfoDtoStatusEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<AndroidDownloadInfoDtoStatusEnum>
_$androidDownloadInfoDtoStatusEnumSerializer =
    _$AndroidDownloadInfoDtoStatusEnumSerializer();

class _$AndroidDownloadInfoDtoStatusEnumSerializer
    implements PrimitiveSerializer<AndroidDownloadInfoDtoStatusEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'available': 'available',
    'noRelease': 'no_release',
    'withdrawn': 'withdrawn',
    'paused': 'paused',
    'unavailable': 'unavailable',
    'unknownDefaultOpenApi': 'unknown_default_open_api',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'available': 'available',
    'no_release': 'noRelease',
    'withdrawn': 'withdrawn',
    'paused': 'paused',
    'unavailable': 'unavailable',
    'unknown_default_open_api': 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[AndroidDownloadInfoDtoStatusEnum];
  @override
  final String wireName = 'AndroidDownloadInfoDtoStatusEnum';

  @override
  Object serialize(
    Serializers serializers,
    AndroidDownloadInfoDtoStatusEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  AndroidDownloadInfoDtoStatusEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => AndroidDownloadInfoDtoStatusEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$AndroidDownloadInfoDto extends AndroidDownloadInfoDto {
  @override
  final AndroidDownloadInfoDtoStatusEnum status;
  @override
  final AndroidDownloadReleaseDto? release;
  @override
  final int? retryAfterSeconds;

  factory _$AndroidDownloadInfoDto([
    void Function(AndroidDownloadInfoDtoBuilder)? updates,
  ]) => (AndroidDownloadInfoDtoBuilder()..update(updates))._build();

  _$AndroidDownloadInfoDto._({
    required this.status,
    this.release,
    this.retryAfterSeconds,
  }) : super._();
  @override
  AndroidDownloadInfoDto rebuild(
    void Function(AndroidDownloadInfoDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  AndroidDownloadInfoDtoBuilder toBuilder() =>
      AndroidDownloadInfoDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AndroidDownloadInfoDto &&
        status == other.status &&
        release == other.release &&
        retryAfterSeconds == other.retryAfterSeconds;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, release.hashCode);
    _$hash = $jc(_$hash, retryAfterSeconds.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AndroidDownloadInfoDto')
          ..add('status', status)
          ..add('release', release)
          ..add('retryAfterSeconds', retryAfterSeconds))
        .toString();
  }
}

class AndroidDownloadInfoDtoBuilder
    implements Builder<AndroidDownloadInfoDto, AndroidDownloadInfoDtoBuilder> {
  _$AndroidDownloadInfoDto? _$v;

  AndroidDownloadInfoDtoStatusEnum? _status;
  AndroidDownloadInfoDtoStatusEnum? get status => _$this._status;
  set status(AndroidDownloadInfoDtoStatusEnum? status) =>
      _$this._status = status;

  AndroidDownloadReleaseDtoBuilder? _release;
  AndroidDownloadReleaseDtoBuilder get release =>
      _$this._release ??= AndroidDownloadReleaseDtoBuilder();
  set release(AndroidDownloadReleaseDtoBuilder? release) =>
      _$this._release = release;

  int? _retryAfterSeconds;
  int? get retryAfterSeconds => _$this._retryAfterSeconds;
  set retryAfterSeconds(int? retryAfterSeconds) =>
      _$this._retryAfterSeconds = retryAfterSeconds;

  AndroidDownloadInfoDtoBuilder() {
    AndroidDownloadInfoDto._defaults(this);
  }

  AndroidDownloadInfoDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _status = $v.status;
      _release = $v.release?.toBuilder();
      _retryAfterSeconds = $v.retryAfterSeconds;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AndroidDownloadInfoDto other) {
    _$v = other as _$AndroidDownloadInfoDto;
  }

  @override
  void update(void Function(AndroidDownloadInfoDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AndroidDownloadInfoDto build() => _build();

  _$AndroidDownloadInfoDto _build() {
    _$AndroidDownloadInfoDto _$result;
    try {
      _$result =
          _$v ??
          _$AndroidDownloadInfoDto._(
            status: BuiltValueNullFieldError.checkNotNull(
              status,
              r'AndroidDownloadInfoDto',
              'status',
            ),
            release: _release?.build(),
            retryAfterSeconds: retryAfterSeconds,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'release';
        _release?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'AndroidDownloadInfoDto',
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
