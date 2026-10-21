// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'font_job_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const FontJobDtoStatusEnum _$fontJobDtoStatusEnum_draft =
    const FontJobDtoStatusEnum._('draft');
const FontJobDtoStatusEnum _$fontJobDtoStatusEnum_queued =
    const FontJobDtoStatusEnum._('queued');
const FontJobDtoStatusEnum _$fontJobDtoStatusEnum_processing =
    const FontJobDtoStatusEnum._('processing');
const FontJobDtoStatusEnum _$fontJobDtoStatusEnum_ready =
    const FontJobDtoStatusEnum._('ready');
const FontJobDtoStatusEnum _$fontJobDtoStatusEnum_failed =
    const FontJobDtoStatusEnum._('failed');
const FontJobDtoStatusEnum _$fontJobDtoStatusEnum_unknownDefaultOpenApi =
    const FontJobDtoStatusEnum._('unknownDefaultOpenApi');

FontJobDtoStatusEnum _$fontJobDtoStatusEnumValueOf(String name) {
  switch (name) {
    case 'draft':
      return _$fontJobDtoStatusEnum_draft;
    case 'queued':
      return _$fontJobDtoStatusEnum_queued;
    case 'processing':
      return _$fontJobDtoStatusEnum_processing;
    case 'ready':
      return _$fontJobDtoStatusEnum_ready;
    case 'failed':
      return _$fontJobDtoStatusEnum_failed;
    case 'unknownDefaultOpenApi':
      return _$fontJobDtoStatusEnum_unknownDefaultOpenApi;
    default:
      return _$fontJobDtoStatusEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<FontJobDtoStatusEnum> _$fontJobDtoStatusEnumValues =
    BuiltSet<FontJobDtoStatusEnum>(const <FontJobDtoStatusEnum>[
      _$fontJobDtoStatusEnum_draft,
      _$fontJobDtoStatusEnum_queued,
      _$fontJobDtoStatusEnum_processing,
      _$fontJobDtoStatusEnum_ready,
      _$fontJobDtoStatusEnum_failed,
      _$fontJobDtoStatusEnum_unknownDefaultOpenApi,
    ]);

const FontJobDtoFailureCodeEnum _$fontJobDtoFailureCodeEnum_invalidFont =
    const FontJobDtoFailureCodeEnum._('invalidFont');
const FontJobDtoFailureCodeEnum _$fontJobDtoFailureCodeEnum_unsupportedFont =
    const FontJobDtoFailureCodeEnum._('unsupportedFont');
const FontJobDtoFailureCodeEnum _$fontJobDtoFailureCodeEnum_rightsRequired =
    const FontJobDtoFailureCodeEnum._('rightsRequired');
const FontJobDtoFailureCodeEnum _$fontJobDtoFailureCodeEnum_resourceLimit =
    const FontJobDtoFailureCodeEnum._('resourceLimit');
const FontJobDtoFailureCodeEnum _$fontJobDtoFailureCodeEnum_sandboxUnavailable =
    const FontJobDtoFailureCodeEnum._('sandboxUnavailable');
const FontJobDtoFailureCodeEnum _$fontJobDtoFailureCodeEnum_processingFailed =
    const FontJobDtoFailureCodeEnum._('processingFailed');
const FontJobDtoFailureCodeEnum
_$fontJobDtoFailureCodeEnum_unknownDefaultOpenApi =
    const FontJobDtoFailureCodeEnum._('unknownDefaultOpenApi');

FontJobDtoFailureCodeEnum _$fontJobDtoFailureCodeEnumValueOf(String name) {
  switch (name) {
    case 'invalidFont':
      return _$fontJobDtoFailureCodeEnum_invalidFont;
    case 'unsupportedFont':
      return _$fontJobDtoFailureCodeEnum_unsupportedFont;
    case 'rightsRequired':
      return _$fontJobDtoFailureCodeEnum_rightsRequired;
    case 'resourceLimit':
      return _$fontJobDtoFailureCodeEnum_resourceLimit;
    case 'sandboxUnavailable':
      return _$fontJobDtoFailureCodeEnum_sandboxUnavailable;
    case 'processingFailed':
      return _$fontJobDtoFailureCodeEnum_processingFailed;
    case 'unknownDefaultOpenApi':
      return _$fontJobDtoFailureCodeEnum_unknownDefaultOpenApi;
    default:
      return _$fontJobDtoFailureCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<FontJobDtoFailureCodeEnum> _$fontJobDtoFailureCodeEnumValues =
    BuiltSet<FontJobDtoFailureCodeEnum>(const <FontJobDtoFailureCodeEnum>[
      _$fontJobDtoFailureCodeEnum_invalidFont,
      _$fontJobDtoFailureCodeEnum_unsupportedFont,
      _$fontJobDtoFailureCodeEnum_rightsRequired,
      _$fontJobDtoFailureCodeEnum_resourceLimit,
      _$fontJobDtoFailureCodeEnum_sandboxUnavailable,
      _$fontJobDtoFailureCodeEnum_processingFailed,
      _$fontJobDtoFailureCodeEnum_unknownDefaultOpenApi,
    ]);

Serializer<FontJobDtoStatusEnum> _$fontJobDtoStatusEnumSerializer =
    _$FontJobDtoStatusEnumSerializer();
Serializer<FontJobDtoFailureCodeEnum> _$fontJobDtoFailureCodeEnumSerializer =
    _$FontJobDtoFailureCodeEnumSerializer();

class _$FontJobDtoStatusEnumSerializer
    implements PrimitiveSerializer<FontJobDtoStatusEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'draft': 'draft',
    'queued': 'queued',
    'processing': 'processing',
    'ready': 'ready',
    'failed': 'failed',
    'unknownDefaultOpenApi': 'unknown_default_open_api',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'draft': 'draft',
    'queued': 'queued',
    'processing': 'processing',
    'ready': 'ready',
    'failed': 'failed',
    'unknown_default_open_api': 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[FontJobDtoStatusEnum];
  @override
  final String wireName = 'FontJobDtoStatusEnum';

  @override
  Object serialize(
    Serializers serializers,
    FontJobDtoStatusEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  FontJobDtoStatusEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => FontJobDtoStatusEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$FontJobDtoFailureCodeEnumSerializer
    implements PrimitiveSerializer<FontJobDtoFailureCodeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'invalidFont': 'invalid-font',
    'unsupportedFont': 'unsupported-font',
    'rightsRequired': 'rights-required',
    'resourceLimit': 'resource-limit',
    'sandboxUnavailable': 'sandbox-unavailable',
    'processingFailed': 'processing-failed',
    'unknownDefaultOpenApi': 'unknown_default_open_api',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'invalid-font': 'invalidFont',
    'unsupported-font': 'unsupportedFont',
    'rights-required': 'rightsRequired',
    'resource-limit': 'resourceLimit',
    'sandbox-unavailable': 'sandboxUnavailable',
    'processing-failed': 'processingFailed',
    'unknown_default_open_api': 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[FontJobDtoFailureCodeEnum];
  @override
  final String wireName = 'FontJobDtoFailureCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    FontJobDtoFailureCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  FontJobDtoFailureCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => FontJobDtoFailureCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$FontJobDto extends FontJobDto {
  @override
  final String jobId;
  @override
  final String familyId;
  @override
  final FontJobDtoStatusEnum status;
  @override
  final String sourceSha256;
  @override
  final int sourceBytes;
  @override
  final String? versionId;
  @override
  final FontJobDtoFailureCodeEnum? failureCode;

  factory _$FontJobDto([void Function(FontJobDtoBuilder)? updates]) =>
      (FontJobDtoBuilder()..update(updates))._build();

  _$FontJobDto._({
    required this.jobId,
    required this.familyId,
    required this.status,
    required this.sourceSha256,
    required this.sourceBytes,
    this.versionId,
    this.failureCode,
  }) : super._();
  @override
  FontJobDto rebuild(void Function(FontJobDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  FontJobDtoBuilder toBuilder() => FontJobDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is FontJobDto &&
        jobId == other.jobId &&
        familyId == other.familyId &&
        status == other.status &&
        sourceSha256 == other.sourceSha256 &&
        sourceBytes == other.sourceBytes &&
        versionId == other.versionId &&
        failureCode == other.failureCode;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, jobId.hashCode);
    _$hash = $jc(_$hash, familyId.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, sourceSha256.hashCode);
    _$hash = $jc(_$hash, sourceBytes.hashCode);
    _$hash = $jc(_$hash, versionId.hashCode);
    _$hash = $jc(_$hash, failureCode.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'FontJobDto')
          ..add('jobId', jobId)
          ..add('familyId', familyId)
          ..add('status', status)
          ..add('sourceSha256', sourceSha256)
          ..add('sourceBytes', sourceBytes)
          ..add('versionId', versionId)
          ..add('failureCode', failureCode))
        .toString();
  }
}

class FontJobDtoBuilder implements Builder<FontJobDto, FontJobDtoBuilder> {
  _$FontJobDto? _$v;

  String? _jobId;
  String? get jobId => _$this._jobId;
  set jobId(String? jobId) => _$this._jobId = jobId;

  String? _familyId;
  String? get familyId => _$this._familyId;
  set familyId(String? familyId) => _$this._familyId = familyId;

  FontJobDtoStatusEnum? _status;
  FontJobDtoStatusEnum? get status => _$this._status;
  set status(FontJobDtoStatusEnum? status) => _$this._status = status;

  String? _sourceSha256;
  String? get sourceSha256 => _$this._sourceSha256;
  set sourceSha256(String? sourceSha256) => _$this._sourceSha256 = sourceSha256;

  int? _sourceBytes;
  int? get sourceBytes => _$this._sourceBytes;
  set sourceBytes(int? sourceBytes) => _$this._sourceBytes = sourceBytes;

  String? _versionId;
  String? get versionId => _$this._versionId;
  set versionId(String? versionId) => _$this._versionId = versionId;

  FontJobDtoFailureCodeEnum? _failureCode;
  FontJobDtoFailureCodeEnum? get failureCode => _$this._failureCode;
  set failureCode(FontJobDtoFailureCodeEnum? failureCode) =>
      _$this._failureCode = failureCode;

  FontJobDtoBuilder() {
    FontJobDto._defaults(this);
  }

  FontJobDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _jobId = $v.jobId;
      _familyId = $v.familyId;
      _status = $v.status;
      _sourceSha256 = $v.sourceSha256;
      _sourceBytes = $v.sourceBytes;
      _versionId = $v.versionId;
      _failureCode = $v.failureCode;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(FontJobDto other) {
    _$v = other as _$FontJobDto;
  }

  @override
  void update(void Function(FontJobDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  FontJobDto build() => _build();

  _$FontJobDto _build() {
    final _$result =
        _$v ??
        _$FontJobDto._(
          jobId: BuiltValueNullFieldError.checkNotNull(
            jobId,
            r'FontJobDto',
            'jobId',
          ),
          familyId: BuiltValueNullFieldError.checkNotNull(
            familyId,
            r'FontJobDto',
            'familyId',
          ),
          status: BuiltValueNullFieldError.checkNotNull(
            status,
            r'FontJobDto',
            'status',
          ),
          sourceSha256: BuiltValueNullFieldError.checkNotNull(
            sourceSha256,
            r'FontJobDto',
            'sourceSha256',
          ),
          sourceBytes: BuiltValueNullFieldError.checkNotNull(
            sourceBytes,
            r'FontJobDto',
            'sourceBytes',
          ),
          versionId: versionId,
          failureCode: failureCode,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
