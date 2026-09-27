import 'dart:io';

import 'package:dio/dio.dart';
import 'package:wenyousite_mobile/core/diagnostics/diagnostic_request.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_codec_types.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';

/// 将受控的程序原因映射为机器码，不把异常 message 或嵌入的数据送出。
Map<String, Object?> diagnosticErrorDetails(Object error, ApiFailure? failure) {
  final dio = error is DioException
      ? error
      : failure?.cause is DioException
      ? failure!.cause! as DioException
      : null;
  final cause = dio?.error ?? failure?.cause ?? error;
  final osError = switch (cause) {
    SocketException(:final osError) => osError,
    FileSystemException(:final osError) => osError,
    OSError value => value,
    _ => null,
  };
  return {
    'diagnosticCode': cause is MarkdownCodecException
        ? markdownDiagnosticCode(cause.message)
        : failure?.diagnosticCode,
    if (osError != null && osError.errorCode >= 0)
      'osErrorCode': osError.errorCode,
    if (dio != null) ...{
      'dioType': dio.type.name,
      'httpMethod': dio.requestOptions.method.toUpperCase(),
      'connectTimeoutMs': dio.requestOptions.connectTimeout?.inMilliseconds,
      'sendTimeoutMs': dio.requestOptions.sendTimeout?.inMilliseconds,
      'receiveTimeoutMs': dio.requestOptions.receiveTimeout?.inMilliseconds,
      'apiOperation': diagnosticApiOperation(dio.requestOptions),
      if (dio.requestOptions.extra['diagnosticWatch']
          case final Stopwatch watch)
        'requestElapsedMs': watch.elapsedMilliseconds,
    },
  };
}

String markdownDiagnosticCode(String message) {
  final fixed = _markdownCodes[message];
  if (fixed != null) return 'markdown.$fixed';
  // 含插值的错误只返回固定类别，绝不返回插值内容。
  if (message.startsWith('遇到不支持的富文本属性：')) {
    return 'markdown.unknown_attribute';
  }
  if (message.startsWith('未知 Quill embed：')) return 'markdown.unknown_embed';
  if (message.endsWith(' embed 载荷不是对象')) return 'markdown.embed_payload';
  if (message.contains(' embed 缺少 ')) return 'markdown.embed_field_missing';
  if (message.endsWith(' embed 稳定 ID 不合法')) return 'markdown.embed_id';
  if (message.endsWith(' embed 图片 URL 不安全')) return 'markdown.embed_url';
  if (message.endsWith(' embed 提及标签必须以 @ 开头')) {
    return 'markdown.mention_label';
  }
  if (message.startsWith('这类') && message.endsWith('内容暂时无法编辑')) {
    return 'markdown.embed_unsupported';
  }
  if (message.startsWith('这类') && message.endsWith('内容包含暂不支持的字符')) {
    return 'markdown.embed_characters';
  }
  return 'markdown.unclassified';
}

const _markdownCodes = {
  '字面源码行不能携带其他富文本属性': 'literal_attributes',
  '这段内容暂时无法安全编辑': 'unsafe_content',
  '列表最多支持三级': 'list_depth',
  '同一行不能组合标题、列表和引用': 'block_attributes_conflict',
  '编辑器只支持二级与三级标题': 'heading_level',
  '编辑器列表类型不受支持': 'list_type',
  '只有列表行可以携带缩进': 'indent_without_list',
  '列表缺少上一级条目': 'list_parent_missing',
  '列表层级无法安全保存，请调整列表缩进': 'list_hierarchy',
  '分隔线不能同时作为标题、列表或引用': 'divider_attributes',
  '分隔线必须独占一行': 'divider_line',
  '分隔线后缺少块终止换行': 'divider_terminator',
  '正文无法安全保存，请撤销最近的格式操作': 'document_roundtrip',
  '文档 Delta 只能包含 insert 操作': 'delta_operation',
  '遇到无法识别的 Quill embed': 'embed_shape',
  '扩展节点不能携带富文本属性': 'embed_attributes',
  '正文块结构无法安全保存，请撤销最近的格式操作': 'block_roundtrip',
  'Quill embed 必须只有一个类型键': 'embed_key_count',
  '提及节点 kind 不受支持': 'mention_kind',
  '骰子节点缺少有效 UUID v4': 'dice_id',
  '骰子表达式不合法': 'dice_expression',
  '表情资源 ID 不合法': 'sticker_id',
  '图片 alt 类型不合法': 'image_alt_type',
  '图片 title 类型不合法': 'image_title_type',
  '图片说明包含暂不支持的字符': 'image_caption',
  '站内传送门地址不合法': 'internal_reference',
  '这段列表暂时无法编辑，原文已保留': 'protected_list',
  '行内代码不能与其他行内格式组合': 'inline_code_attributes',
  '这个链接暂时无法安全编辑': 'unsafe_link',
  '当前正文块不能使用对齐格式': 'block_alignment',
  '包含普通图片的段落不能使用对齐格式': 'inline_image_alignment',
  '同一段落的多行文本必须使用相同对齐方式': 'paragraph_alignment_conflict',
  '编辑器只支持左、中、右对齐': 'alignment_value',
  '列表最多支持三级，请先建立上一级条目': 'list_depth_parent',
  '列表结构无法安全保存，请调整列表缩进': 'list_structure',
  '列表内容无法安全保存，请调整列表缩进': 'list_content',
  '正文段落无法安全保存': 'paragraph_boundary',
  '引用段落无法安全保存': 'quote_boundary',
  '链接地址不受支持，请修改后再保存。': 'link_scheme',
};
