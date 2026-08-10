//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'update_site_settings_dto.g.dart';

/// UpdateSiteSettingsDto
///
/// Properties:
/// * [registrationPausedUntil]
/// * [contentWritesPausedUntil]
/// * [maintenanceTitle]
/// * [maintenanceContent]
/// * [maintenanceStartsAt]
/// * [maintenanceEndsAt]
@BuiltValue()
abstract class UpdateSiteSettingsDto implements Built<UpdateSiteSettingsDto, UpdateSiteSettingsDtoBuilder> {
  @BuiltValueField(wireName: r'registrationPausedUntil')
  DateTime? get registrationPausedUntil;

  @BuiltValueField(wireName: r'contentWritesPausedUntil')
  DateTime? get contentWritesPausedUntil;

  @BuiltValueField(wireName: r'maintenanceTitle')
  String? get maintenanceTitle;

  @BuiltValueField(wireName: r'maintenanceContent')
  String? get maintenanceContent;

  @BuiltValueField(wireName: r'maintenanceStartsAt')
  DateTime? get maintenanceStartsAt;

  @BuiltValueField(wireName: r'maintenanceEndsAt')
  DateTime? get maintenanceEndsAt;

  UpdateSiteSettingsDto._();

  factory UpdateSiteSettingsDto([void updates(UpdateSiteSettingsDtoBuilder b)]) = _$UpdateSiteSettingsDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(UpdateSiteSettingsDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<UpdateSiteSettingsDto> get serializer => _$UpdateSiteSettingsDtoSerializer();
}

class _$UpdateSiteSettingsDtoSerializer implements PrimitiveSerializer<UpdateSiteSettingsDto> {
  @override
  final Iterable<Type> types = const [UpdateSiteSettingsDto, _$UpdateSiteSettingsDto];

  @override
  final String wireName = r'UpdateSiteSettingsDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    UpdateSiteSettingsDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.registrationPausedUntil != null) {
      yield r'registrationPausedUntil';
      yield serializers.serialize(
        object.registrationPausedUntil,
        specifiedType: const FullType.nullable(DateTime),
      );
    }
    if (object.contentWritesPausedUntil != null) {
      yield r'contentWritesPausedUntil';
      yield serializers.serialize(
        object.contentWritesPausedUntil,
        specifiedType: const FullType.nullable(DateTime),
      );
    }
    if (object.maintenanceTitle != null) {
      yield r'maintenanceTitle';
      yield serializers.serialize(
        object.maintenanceTitle,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.maintenanceContent != null) {
      yield r'maintenanceContent';
      yield serializers.serialize(
        object.maintenanceContent,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.maintenanceStartsAt != null) {
      yield r'maintenanceStartsAt';
      yield serializers.serialize(
        object.maintenanceStartsAt,
        specifiedType: const FullType.nullable(DateTime),
      );
    }
    if (object.maintenanceEndsAt != null) {
      yield r'maintenanceEndsAt';
      yield serializers.serialize(
        object.maintenanceEndsAt,
        specifiedType: const FullType.nullable(DateTime),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    UpdateSiteSettingsDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required UpdateSiteSettingsDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'registrationPausedUntil':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.registrationPausedUntil = valueDes;
          break;
        case r'contentWritesPausedUntil':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.contentWritesPausedUntil = valueDes;
          break;
        case r'maintenanceTitle':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.maintenanceTitle = valueDes;
          break;
        case r'maintenanceContent':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.maintenanceContent = valueDes;
          break;
        case r'maintenanceStartsAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.maintenanceStartsAt = valueDes;
          break;
        case r'maintenanceEndsAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.maintenanceEndsAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  UpdateSiteSettingsDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = UpdateSiteSettingsDtoBuilder();
    final serializedList = (serialized as Iterable<Object?>).toList();
    final unhandled = <Object?>[];
    _deserializeProperties(
      serializers,
      serialized,
      specifiedType: specifiedType,
      serializedList: serializedList,
      unhandled: unhandled,
      result: result,
    );
    return result.build();
  }
}
