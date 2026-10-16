//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'update_post_dto.g.dart';

/// UpdatePostDto
///
/// Properties:
/// * [textColorVersion] - 支持文本颜色 v1 无损读写；新端始终发送，包括删除全部颜色。新/原正文含颜色未声明返回 409/40016；新写受 textColorV1WriteEnabled 控制。
/// * [markdownContractVersion] - 声明编辑器支持 Markdown 6 角色提及源的无损读取/编辑。服务端 capabilities.roleMentionsV6Supported 为 true 时新端始终发送，包括删光旧节点；未声明而新/原正文含 v6 返回 409/40014。新节点还须 roleMentionsV6WriteEnabled。
/// * [content] - 新正文；骰子节点随正文移动或删除，新增节点由服务端结算
/// * [version] - 乐观锁版本号（必填，前端需先 fetch 获取当前 version，传入过期版本会返回 409）
@BuiltValue()
abstract class UpdatePostDto implements Built<UpdatePostDto, UpdatePostDtoBuilder> {
  /// 支持文本颜色 v1 无损读写；新端始终发送，包括删除全部颜色。新/原正文含颜色未声明返回 409/40016；新写受 textColorV1WriteEnabled 控制。
  @BuiltValueField(wireName: r'textColorVersion')
  UpdatePostDtoTextColorVersionEnum? get textColorVersion;
  // enum textColorVersionEnum {  1,  };

  /// 声明编辑器支持 Markdown 6 角色提及源的无损读取/编辑。服务端 capabilities.roleMentionsV6Supported 为 true 时新端始终发送，包括删光旧节点；未声明而新/原正文含 v6 返回 409/40014。新节点还须 roleMentionsV6WriteEnabled。
  @BuiltValueField(wireName: r'markdownContractVersion')
  UpdatePostDtoMarkdownContractVersionEnum? get markdownContractVersion;
  // enum markdownContractVersionEnum {  6,  };

  /// 新正文；骰子节点随正文移动或删除，新增节点由服务端结算
  @BuiltValueField(wireName: r'content')
  String get content;

  /// 乐观锁版本号（必填，前端需先 fetch 获取当前 version，传入过期版本会返回 409）
  @BuiltValueField(wireName: r'version')
  num get version;

  UpdatePostDto._();

  factory UpdatePostDto([void updates(UpdatePostDtoBuilder b)]) = _$UpdatePostDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(UpdatePostDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<UpdatePostDto> get serializer => _$UpdatePostDtoSerializer();
}

class _$UpdatePostDtoSerializer implements PrimitiveSerializer<UpdatePostDto> {
  @override
  final Iterable<Type> types = const [UpdatePostDto, _$UpdatePostDto];

  @override
  final String wireName = r'UpdatePostDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    UpdatePostDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.textColorVersion != null) {
      yield r'textColorVersion';
      yield serializers.serialize(
        object.textColorVersion,
        specifiedType: const FullType(UpdatePostDtoTextColorVersionEnum),
      );
    }
    if (object.markdownContractVersion != null) {
      yield r'markdownContractVersion';
      yield serializers.serialize(
        object.markdownContractVersion,
        specifiedType: const FullType(UpdatePostDtoMarkdownContractVersionEnum),
      );
    }
    yield r'content';
    yield serializers.serialize(
      object.content,
      specifiedType: const FullType(String),
    );
    yield r'version';
    yield serializers.serialize(
      object.version,
      specifiedType: const FullType(num),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    UpdatePostDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required UpdatePostDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'textColorVersion':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(UpdatePostDtoTextColorVersionEnum),
          ) as UpdatePostDtoTextColorVersionEnum;
          result.textColorVersion = valueDes;
          break;
        case r'markdownContractVersion':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(UpdatePostDtoMarkdownContractVersionEnum),
          ) as UpdatePostDtoMarkdownContractVersionEnum;
          result.markdownContractVersion = valueDes;
          break;
        case r'content':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.content = valueDes;
          break;
        case r'version':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.version = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  UpdatePostDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = UpdatePostDtoBuilder();
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

class UpdatePostDtoTextColorVersionEnum extends EnumClass {

  /// 支持文本颜色 v1 无损读写；新端始终发送，包括删除全部颜色。新/原正文含颜色未声明返回 409/40016；新写受 textColorV1WriteEnabled 控制。
  @BuiltValueEnumConst(wireNumber: 1)
  static const UpdatePostDtoTextColorVersionEnum number1 = _$updatePostDtoTextColorVersionEnum_number1;
  /// 支持文本颜色 v1 无损读写；新端始终发送，包括删除全部颜色。新/原正文含颜色未声明返回 409/40016；新写受 textColorV1WriteEnabled 控制。
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const UpdatePostDtoTextColorVersionEnum unknownDefaultOpenApi = _$updatePostDtoTextColorVersionEnum_unknownDefaultOpenApi;

  static Serializer<UpdatePostDtoTextColorVersionEnum> get serializer => _$updatePostDtoTextColorVersionEnumSerializer;

  const UpdatePostDtoTextColorVersionEnum._(String name): super(name);

  static BuiltSet<UpdatePostDtoTextColorVersionEnum> get values => _$updatePostDtoTextColorVersionEnumValues;
  static UpdatePostDtoTextColorVersionEnum valueOf(String name) => _$updatePostDtoTextColorVersionEnumValueOf(name);
}

class UpdatePostDtoMarkdownContractVersionEnum extends EnumClass {

  /// 声明编辑器支持 Markdown 6 角色提及源的无损读取/编辑。服务端 capabilities.roleMentionsV6Supported 为 true 时新端始终发送，包括删光旧节点；未声明而新/原正文含 v6 返回 409/40014。新节点还须 roleMentionsV6WriteEnabled。
  @BuiltValueEnumConst(wireNumber: 6)
  static const UpdatePostDtoMarkdownContractVersionEnum number6 = _$updatePostDtoMarkdownContractVersionEnum_number6;
  /// 声明编辑器支持 Markdown 6 角色提及源的无损读取/编辑。服务端 capabilities.roleMentionsV6Supported 为 true 时新端始终发送，包括删光旧节点；未声明而新/原正文含 v6 返回 409/40014。新节点还须 roleMentionsV6WriteEnabled。
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const UpdatePostDtoMarkdownContractVersionEnum unknownDefaultOpenApi = _$updatePostDtoMarkdownContractVersionEnum_unknownDefaultOpenApi;

  static Serializer<UpdatePostDtoMarkdownContractVersionEnum> get serializer => _$updatePostDtoMarkdownContractVersionEnumSerializer;

  const UpdatePostDtoMarkdownContractVersionEnum._(String name): super(name);

  static BuiltSet<UpdatePostDtoMarkdownContractVersionEnum> get values => _$updatePostDtoMarkdownContractVersionEnumValues;
  static UpdatePostDtoMarkdownContractVersionEnum valueOf(String name) => _$updatePostDtoMarkdownContractVersionEnumValueOf(name);
}
