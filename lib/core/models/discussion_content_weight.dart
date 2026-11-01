/// 正文保留预算的估算单位，包含 UTF-16 文本及每项媒体的元数据余量。
/// 这不是进程堆大小；图片解码另按展示尺寸控制。
int discussionContentWeight({
  required String text,
  required Iterable<String> labels,
  required int mediaCount,
}) =>
    2 *
        (text.length +
            labels.fold<int>(0, (sum, label) => sum + label.length)) +
    mediaCount * 1024;
