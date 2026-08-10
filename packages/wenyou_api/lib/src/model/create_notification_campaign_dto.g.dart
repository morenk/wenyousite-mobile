// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_notification_campaign_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const CreateNotificationCampaignDtoDestinationTypeEnum
_$createNotificationCampaignDtoDestinationTypeEnum_THREAD =
    const CreateNotificationCampaignDtoDestinationTypeEnum._('THREAD');
const CreateNotificationCampaignDtoDestinationTypeEnum
_$createNotificationCampaignDtoDestinationTypeEnum_unknownDefaultOpenApi =
    const CreateNotificationCampaignDtoDestinationTypeEnum._(
      'unknownDefaultOpenApi',
    );

CreateNotificationCampaignDtoDestinationTypeEnum
_$createNotificationCampaignDtoDestinationTypeEnumValueOf(String name) {
  switch (name) {
    case 'THREAD':
      return _$createNotificationCampaignDtoDestinationTypeEnum_THREAD;
    case 'unknownDefaultOpenApi':
      return _$createNotificationCampaignDtoDestinationTypeEnum_unknownDefaultOpenApi;
    default:
      return _$createNotificationCampaignDtoDestinationTypeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<CreateNotificationCampaignDtoDestinationTypeEnum>
_$createNotificationCampaignDtoDestinationTypeEnumValues =
    BuiltSet<CreateNotificationCampaignDtoDestinationTypeEnum>(const <
      CreateNotificationCampaignDtoDestinationTypeEnum
    >[
      _$createNotificationCampaignDtoDestinationTypeEnum_THREAD,
      _$createNotificationCampaignDtoDestinationTypeEnum_unknownDefaultOpenApi,
    ]);

Serializer<CreateNotificationCampaignDtoDestinationTypeEnum>
_$createNotificationCampaignDtoDestinationTypeEnumSerializer =
    _$CreateNotificationCampaignDtoDestinationTypeEnumSerializer();

class _$CreateNotificationCampaignDtoDestinationTypeEnumSerializer
    implements
        PrimitiveSerializer<CreateNotificationCampaignDtoDestinationTypeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'THREAD': 'THREAD',
    'unknownDefaultOpenApi': 'unknown_default_open_api',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'THREAD': 'THREAD',
    'unknown_default_open_api': 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[
    CreateNotificationCampaignDtoDestinationTypeEnum,
  ];
  @override
  final String wireName = 'CreateNotificationCampaignDtoDestinationTypeEnum';

  @override
  Object serialize(
    Serializers serializers,
    CreateNotificationCampaignDtoDestinationTypeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  CreateNotificationCampaignDtoDestinationTypeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => CreateNotificationCampaignDtoDestinationTypeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$CreateNotificationCampaignDto extends CreateNotificationCampaignDto {
  @override
  final String title;
  @override
  final String content;
  @override
  final DateTime scheduledAt;
  @override
  final NotificationAudienceDto? audience;
  @override
  final CreateNotificationCampaignDtoDestinationTypeEnum? destinationType;
  @override
  final String? destinationId;

  factory _$CreateNotificationCampaignDto([
    void Function(CreateNotificationCampaignDtoBuilder)? updates,
  ]) => (CreateNotificationCampaignDtoBuilder()..update(updates))._build();

  _$CreateNotificationCampaignDto._({
    required this.title,
    required this.content,
    required this.scheduledAt,
    this.audience,
    this.destinationType,
    this.destinationId,
  }) : super._();
  @override
  CreateNotificationCampaignDto rebuild(
    void Function(CreateNotificationCampaignDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  CreateNotificationCampaignDtoBuilder toBuilder() =>
      CreateNotificationCampaignDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CreateNotificationCampaignDto &&
        title == other.title &&
        content == other.content &&
        scheduledAt == other.scheduledAt &&
        audience == other.audience &&
        destinationType == other.destinationType &&
        destinationId == other.destinationId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, title.hashCode);
    _$hash = $jc(_$hash, content.hashCode);
    _$hash = $jc(_$hash, scheduledAt.hashCode);
    _$hash = $jc(_$hash, audience.hashCode);
    _$hash = $jc(_$hash, destinationType.hashCode);
    _$hash = $jc(_$hash, destinationId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CreateNotificationCampaignDto')
          ..add('title', title)
          ..add('content', content)
          ..add('scheduledAt', scheduledAt)
          ..add('audience', audience)
          ..add('destinationType', destinationType)
          ..add('destinationId', destinationId))
        .toString();
  }
}

class CreateNotificationCampaignDtoBuilder
    implements
        Builder<
          CreateNotificationCampaignDto,
          CreateNotificationCampaignDtoBuilder
        > {
  _$CreateNotificationCampaignDto? _$v;

  String? _title;
  String? get title => _$this._title;
  set title(String? title) => _$this._title = title;

  String? _content;
  String? get content => _$this._content;
  set content(String? content) => _$this._content = content;

  DateTime? _scheduledAt;
  DateTime? get scheduledAt => _$this._scheduledAt;
  set scheduledAt(DateTime? scheduledAt) => _$this._scheduledAt = scheduledAt;

  NotificationAudienceDtoBuilder? _audience;
  NotificationAudienceDtoBuilder get audience =>
      _$this._audience ??= NotificationAudienceDtoBuilder();
  set audience(NotificationAudienceDtoBuilder? audience) =>
      _$this._audience = audience;

  CreateNotificationCampaignDtoDestinationTypeEnum? _destinationType;
  CreateNotificationCampaignDtoDestinationTypeEnum? get destinationType =>
      _$this._destinationType;
  set destinationType(
    CreateNotificationCampaignDtoDestinationTypeEnum? destinationType,
  ) => _$this._destinationType = destinationType;

  String? _destinationId;
  String? get destinationId => _$this._destinationId;
  set destinationId(String? destinationId) =>
      _$this._destinationId = destinationId;

  CreateNotificationCampaignDtoBuilder() {
    CreateNotificationCampaignDto._defaults(this);
  }

  CreateNotificationCampaignDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _title = $v.title;
      _content = $v.content;
      _scheduledAt = $v.scheduledAt;
      _audience = $v.audience?.toBuilder();
      _destinationType = $v.destinationType;
      _destinationId = $v.destinationId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CreateNotificationCampaignDto other) {
    _$v = other as _$CreateNotificationCampaignDto;
  }

  @override
  void update(void Function(CreateNotificationCampaignDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CreateNotificationCampaignDto build() => _build();

  _$CreateNotificationCampaignDto _build() {
    _$CreateNotificationCampaignDto _$result;
    try {
      _$result =
          _$v ??
          _$CreateNotificationCampaignDto._(
            title: BuiltValueNullFieldError.checkNotNull(
              title,
              r'CreateNotificationCampaignDto',
              'title',
            ),
            content: BuiltValueNullFieldError.checkNotNull(
              content,
              r'CreateNotificationCampaignDto',
              'content',
            ),
            scheduledAt: BuiltValueNullFieldError.checkNotNull(
              scheduledAt,
              r'CreateNotificationCampaignDto',
              'scheduledAt',
            ),
            audience: _audience?.build(),
            destinationType: destinationType,
            destinationId: destinationId,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'audience';
        _audience?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'CreateNotificationCampaignDto',
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
