//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'process_font_submission_dto.g.dart';

/// ProcessFontSubmissionDto
///
/// Properties:
/// * [requestId] - 一次启动/重试意图的 UUID v4；网络重发复用，用户明确再次重试才生成新值。
@BuiltValue()
abstract class ProcessFontSubmissionDto implements Built<ProcessFontSubmissionDto, ProcessFontSubmissionDtoBuilder> {
  /// 一次启动/重试意图的 UUID v4；网络重发复用，用户明确再次重试才生成新值。
  @BuiltValueField(wireName: r'requestId')
  String get requestId;

  ProcessFontSubmissionDto._();

  factory ProcessFontSubmissionDto([void updates(ProcessFontSubmissionDtoBuilder b)]) = _$ProcessFontSubmissionDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ProcessFontSubmissionDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ProcessFontSubmissionDto> get serializer => _$ProcessFontSubmissionDtoSerializer();
}

class _$ProcessFontSubmissionDtoSerializer implements PrimitiveSerializer<ProcessFontSubmissionDto> {
  @override
  final Iterable<Type> types = const [ProcessFontSubmissionDto, _$ProcessFontSubmissionDto];

  @override
  final String wireName = r'ProcessFontSubmissionDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ProcessFontSubmissionDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'requestId';
    yield serializers.serialize(
      object.requestId,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ProcessFontSubmissionDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ProcessFontSubmissionDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'requestId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.requestId = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ProcessFontSubmissionDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ProcessFontSubmissionDtoBuilder();
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
