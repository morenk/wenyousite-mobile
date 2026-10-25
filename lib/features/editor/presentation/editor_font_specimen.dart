import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// 只读取已校验的可见样张；透明边界用于呈现，不修改发布资源。
class EditorFontSpecimen extends StatefulWidget {
  const EditorFontSpecimen({
    required this.bytes,
    required this.color,
    super.key,
  });
  final Uint8List bytes;
  final Color color;

  @override
  State<EditorFontSpecimen> createState() => EditorFontSpecimenState();
}

class EditorFontSpecimenState extends State<EditorFontSpecimen> {
  ui.Image? _image;
  Rect? _bounds;
  int _generation = 0;
  late Future<void> ready;

  @override
  void initState() {
    super.initState();
    ready = _decode();
  }

  @override
  void didUpdateWidget(covariant EditorFontSpecimen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.bytes, widget.bytes)) {
      _image?.dispose();
      _image = null;
      _bounds = null;
      ready = _decode();
    }
  }

  Future<void> _decode() async {
    final generation = ++_generation;
    ui.ImmutableBuffer? buffer;
    ui.ImageDescriptor? descriptor;
    ui.Codec? codec;
    ui.Image? image;
    try {
      if (widget.bytes.length > 2 * 1024 * 1024) return;
      buffer = await ui.ImmutableBuffer.fromUint8List(widget.bytes);
      descriptor = await ui.ImageDescriptor.encoded(buffer);
      // 在像素解码前限制内存；本次发布样张实际为 640 × 160。
      if (descriptor.width > 2048 ||
          descriptor.height > 2048 ||
          descriptor.width * descriptor.height > 1024 * 1024) {
        return;
      }
      codec = await descriptor.instantiateCodec();
      image = (await codec.getNextFrame()).image;
      final rgba = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
      if (!mounted || generation != _generation || rgba == null) return;
      final bounds = editorFontAlphaBounds(
        rgba.buffer.asUint8List(rgba.offsetInBytes, rgba.lengthInBytes),
        image.width,
        image.height,
      );
      if (bounds == null) return;
      setState(() {
        _image = image;
        _bounds = bounds;
      });
      image = null; // 所有权移交给可见行，离屏后释放。
    } on Object {
      // 损坏或全透明样张保留空位，字体名称与选择仍然可用。
    } finally {
      image?.dispose();
      codec?.dispose();
      descriptor?.dispose();
      buffer?.dispose();
    }
  }

  @override
  void dispose() {
    _generation++;
    _image?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => CustomPaint(
    painter: _image == null
        ? null
        : _SpecimenPainter(_image!, _bounds!, widget.color),
    child: const SizedBox.expand(),
  );
}

/// 保留所有非零 alpha 像素及安全边距，不依赖字体或样张文字。
@visibleForTesting
Rect? editorFontAlphaBounds(Uint8List rgba, int width, int height) {
  if (width <= 0 || height <= 0 || rgba.length != width * height * 4) {
    return null;
  }
  var left = width, top = height, right = -1, bottom = -1;
  for (var y = 0; y < height; y++) {
    for (var x = 0; x < width; x++) {
      if (rgba[(y * width + x) * 4 + 3] == 0) continue;
      left = math.min(left, x);
      top = math.min(top, y);
      right = math.max(right, x);
      bottom = math.max(bottom, y);
    }
  }
  if (right < 0) return null;
  return Rect.fromLTRB(
    math.max(0, left - 4).toDouble(),
    math.max(0, top - 4).toDouble(),
    math.min(width, right + 5).toDouble(),
    math.min(height, bottom + 5).toDouble(),
  );
}

class _SpecimenPainter extends CustomPainter {
  _SpecimenPainter(this.image, this.bounds, this.color);
  final ui.Image image;
  final Rect bounds;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final fitted = applyBoxFit(BoxFit.contain, bounds.size, size);
    final destination = Alignment.centerLeft.inscribe(
      fitted.destination,
      Offset.zero & size,
    );
    canvas.drawImageRect(
      image,
      bounds,
      destination,
      Paint()
        ..filterQuality = FilterQuality.medium
        ..colorFilter = ColorFilter.mode(color, BlendMode.srcIn),
    );
  }

  @override
  bool shouldRepaint(_SpecimenPainter oldDelegate) =>
      image != oldDelegate.image ||
      bounds != oldDelegate.bounds ||
      color != oldDelegate.color;
}
