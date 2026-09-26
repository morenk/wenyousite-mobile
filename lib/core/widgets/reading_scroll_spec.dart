/// 移动端阅读滑块的交互参数，三个阅读详情页共用。
/// 通用颜色、圆角和焦点样式继续取自应用主题。
abstract final class ReadingScrollSpec {
  static const collapsedWidth = 2.0;
  static const collapsedHeight = 24.0;
  static const expandedWidth = 8.0;
  static const expandedHeight = 56.0;
  static const focusOutlineWidth = 24.0;
  static const focusOutlineHeight = 64.0;
  static const minimumTargetWidth = 48.0;
  static const minimumTargetHeight = 64.0;
  static const edgeGap = 8.0;
  static const labelGap = 8.0;

  static const sampleWindowMs = 100;
  static const minimumSampleDurationMs = 40;
  static const minimumSameDirectionDistance = 40.0;
  static const minimumAverageVelocity = 550.0;
  static const minimumViewportVelocityFactor = 0.8;

  static const expandDurationMs = 180;
  static const collapseDurationMs = 240;
  static const appearDurationMs = 180;
  static const fadeDurationMs = 180;
  static const expandedHoldMs = 1000;
  static const collapsedHoldMs = 600;
  static const slowReadHoldMs = 1500;
}
