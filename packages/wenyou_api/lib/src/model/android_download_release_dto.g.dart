// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'android_download_release_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const AndroidDownloadReleaseDtoPlatformEnum
_$androidDownloadReleaseDtoPlatformEnum_android =
    const AndroidDownloadReleaseDtoPlatformEnum._('android');
const AndroidDownloadReleaseDtoPlatformEnum
_$androidDownloadReleaseDtoPlatformEnum_unknownDefaultOpenApi =
    const AndroidDownloadReleaseDtoPlatformEnum._('unknownDefaultOpenApi');

AndroidDownloadReleaseDtoPlatformEnum
_$androidDownloadReleaseDtoPlatformEnumValueOf(String name) {
  switch (name) {
    case 'android':
      return _$androidDownloadReleaseDtoPlatformEnum_android;
    case 'unknownDefaultOpenApi':
      return _$androidDownloadReleaseDtoPlatformEnum_unknownDefaultOpenApi;
    default:
      return _$androidDownloadReleaseDtoPlatformEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<AndroidDownloadReleaseDtoPlatformEnum>
_$androidDownloadReleaseDtoPlatformEnumValues =
    BuiltSet<AndroidDownloadReleaseDtoPlatformEnum>(
      const <AndroidDownloadReleaseDtoPlatformEnum>[
        _$androidDownloadReleaseDtoPlatformEnum_android,
        _$androidDownloadReleaseDtoPlatformEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<AndroidDownloadReleaseDtoPlatformEnum>
_$androidDownloadReleaseDtoPlatformEnumSerializer =
    _$AndroidDownloadReleaseDtoPlatformEnumSerializer();

class _$AndroidDownloadReleaseDtoPlatformEnumSerializer
    implements PrimitiveSerializer<AndroidDownloadReleaseDtoPlatformEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'android': 'android',
    'unknownDefaultOpenApi': 'unknown_default_open_api',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'android': 'android',
    'unknown_default_open_api': 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[
    AndroidDownloadReleaseDtoPlatformEnum,
  ];
  @override
  final String wireName = 'AndroidDownloadReleaseDtoPlatformEnum';

  @override
  Object serialize(
    Serializers serializers,
    AndroidDownloadReleaseDtoPlatformEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  AndroidDownloadReleaseDtoPlatformEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => AndroidDownloadReleaseDtoPlatformEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$AndroidDownloadReleaseDto extends AndroidDownloadReleaseDto {
  @override
  final AndroidDownloadReleaseDtoPlatformEnum platform;
  @override
  final String applicationId;
  @override
  final String versionName;
  @override
  final num buildNumber;
  @override
  final int sizeBytes;
  @override
  final String sha256;
  @override
  final String fileName;
  @override
  final DateTime publishedAt;
  @override
  final String downloadUrl;
  @override
  final String releaseNotesUrl;

  factory _$AndroidDownloadReleaseDto([
    void Function(AndroidDownloadReleaseDtoBuilder)? updates,
  ]) => (AndroidDownloadReleaseDtoBuilder()..update(updates))._build();

  _$AndroidDownloadReleaseDto._({
    required this.platform,
    required this.applicationId,
    required this.versionName,
    required this.buildNumber,
    required this.sizeBytes,
    required this.sha256,
    required this.fileName,
    required this.publishedAt,
    required this.downloadUrl,
    required this.releaseNotesUrl,
  }) : super._();
  @override
  AndroidDownloadReleaseDto rebuild(
    void Function(AndroidDownloadReleaseDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  AndroidDownloadReleaseDtoBuilder toBuilder() =>
      AndroidDownloadReleaseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AndroidDownloadReleaseDto &&
        platform == other.platform &&
        applicationId == other.applicationId &&
        versionName == other.versionName &&
        buildNumber == other.buildNumber &&
        sizeBytes == other.sizeBytes &&
        sha256 == other.sha256 &&
        fileName == other.fileName &&
        publishedAt == other.publishedAt &&
        downloadUrl == other.downloadUrl &&
        releaseNotesUrl == other.releaseNotesUrl;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, platform.hashCode);
    _$hash = $jc(_$hash, applicationId.hashCode);
    _$hash = $jc(_$hash, versionName.hashCode);
    _$hash = $jc(_$hash, buildNumber.hashCode);
    _$hash = $jc(_$hash, sizeBytes.hashCode);
    _$hash = $jc(_$hash, sha256.hashCode);
    _$hash = $jc(_$hash, fileName.hashCode);
    _$hash = $jc(_$hash, publishedAt.hashCode);
    _$hash = $jc(_$hash, downloadUrl.hashCode);
    _$hash = $jc(_$hash, releaseNotesUrl.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AndroidDownloadReleaseDto')
          ..add('platform', platform)
          ..add('applicationId', applicationId)
          ..add('versionName', versionName)
          ..add('buildNumber', buildNumber)
          ..add('sizeBytes', sizeBytes)
          ..add('sha256', sha256)
          ..add('fileName', fileName)
          ..add('publishedAt', publishedAt)
          ..add('downloadUrl', downloadUrl)
          ..add('releaseNotesUrl', releaseNotesUrl))
        .toString();
  }
}

class AndroidDownloadReleaseDtoBuilder
    implements
        Builder<AndroidDownloadReleaseDto, AndroidDownloadReleaseDtoBuilder> {
  _$AndroidDownloadReleaseDto? _$v;

  AndroidDownloadReleaseDtoPlatformEnum? _platform;
  AndroidDownloadReleaseDtoPlatformEnum? get platform => _$this._platform;
  set platform(AndroidDownloadReleaseDtoPlatformEnum? platform) =>
      _$this._platform = platform;

  String? _applicationId;
  String? get applicationId => _$this._applicationId;
  set applicationId(String? applicationId) =>
      _$this._applicationId = applicationId;

  String? _versionName;
  String? get versionName => _$this._versionName;
  set versionName(String? versionName) => _$this._versionName = versionName;

  num? _buildNumber;
  num? get buildNumber => _$this._buildNumber;
  set buildNumber(num? buildNumber) => _$this._buildNumber = buildNumber;

  int? _sizeBytes;
  int? get sizeBytes => _$this._sizeBytes;
  set sizeBytes(int? sizeBytes) => _$this._sizeBytes = sizeBytes;

  String? _sha256;
  String? get sha256 => _$this._sha256;
  set sha256(String? sha256) => _$this._sha256 = sha256;

  String? _fileName;
  String? get fileName => _$this._fileName;
  set fileName(String? fileName) => _$this._fileName = fileName;

  DateTime? _publishedAt;
  DateTime? get publishedAt => _$this._publishedAt;
  set publishedAt(DateTime? publishedAt) => _$this._publishedAt = publishedAt;

  String? _downloadUrl;
  String? get downloadUrl => _$this._downloadUrl;
  set downloadUrl(String? downloadUrl) => _$this._downloadUrl = downloadUrl;

  String? _releaseNotesUrl;
  String? get releaseNotesUrl => _$this._releaseNotesUrl;
  set releaseNotesUrl(String? releaseNotesUrl) =>
      _$this._releaseNotesUrl = releaseNotesUrl;

  AndroidDownloadReleaseDtoBuilder() {
    AndroidDownloadReleaseDto._defaults(this);
  }

  AndroidDownloadReleaseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _platform = $v.platform;
      _applicationId = $v.applicationId;
      _versionName = $v.versionName;
      _buildNumber = $v.buildNumber;
      _sizeBytes = $v.sizeBytes;
      _sha256 = $v.sha256;
      _fileName = $v.fileName;
      _publishedAt = $v.publishedAt;
      _downloadUrl = $v.downloadUrl;
      _releaseNotesUrl = $v.releaseNotesUrl;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AndroidDownloadReleaseDto other) {
    _$v = other as _$AndroidDownloadReleaseDto;
  }

  @override
  void update(void Function(AndroidDownloadReleaseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AndroidDownloadReleaseDto build() => _build();

  _$AndroidDownloadReleaseDto _build() {
    final _$result =
        _$v ??
        _$AndroidDownloadReleaseDto._(
          platform: BuiltValueNullFieldError.checkNotNull(
            platform,
            r'AndroidDownloadReleaseDto',
            'platform',
          ),
          applicationId: BuiltValueNullFieldError.checkNotNull(
            applicationId,
            r'AndroidDownloadReleaseDto',
            'applicationId',
          ),
          versionName: BuiltValueNullFieldError.checkNotNull(
            versionName,
            r'AndroidDownloadReleaseDto',
            'versionName',
          ),
          buildNumber: BuiltValueNullFieldError.checkNotNull(
            buildNumber,
            r'AndroidDownloadReleaseDto',
            'buildNumber',
          ),
          sizeBytes: BuiltValueNullFieldError.checkNotNull(
            sizeBytes,
            r'AndroidDownloadReleaseDto',
            'sizeBytes',
          ),
          sha256: BuiltValueNullFieldError.checkNotNull(
            sha256,
            r'AndroidDownloadReleaseDto',
            'sha256',
          ),
          fileName: BuiltValueNullFieldError.checkNotNull(
            fileName,
            r'AndroidDownloadReleaseDto',
            'fileName',
          ),
          publishedAt: BuiltValueNullFieldError.checkNotNull(
            publishedAt,
            r'AndroidDownloadReleaseDto',
            'publishedAt',
          ),
          downloadUrl: BuiltValueNullFieldError.checkNotNull(
            downloadUrl,
            r'AndroidDownloadReleaseDto',
            'downloadUrl',
          ),
          releaseNotesUrl: BuiltValueNullFieldError.checkNotNull(
            releaseNotesUrl,
            r'AndroidDownloadReleaseDto',
            'releaseNotesUrl',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
