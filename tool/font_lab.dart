// 独立包site.wenyou.fontlab的离线入口，不导入应用main、会话或业务仓储。
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:wenyousite_mobile/core/text_fonts/text_font_manifest.dart';
import 'text_font_memory_vm.dart';

const _memory = MethodChannel('wenyou.fontlab/memory');
const _sample = '温油站 春风 あいうえお アイウエオ Hello 123 é 😀';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MaterialApp(home: _FontLab()));
}

class _FontLab extends StatefulWidget {
  const _FontLab();
  @override
  State<_FontLab> createState() => _FontLabState();
}

class _FontLabState extends State<_FontLab> {
  String _status = '准备离线测量';
  String? _family;
  List<String> _fallback = [];
  final _registered = <String, String>{};
  final _rows = <Map<String, Object?>>[];
  int _inputBytes = 0;
  String _mode = 'typical';
  String _manifestHash = '';
  int _fontCount = 0;
  final _examples = <String, List<String>>{};
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _run());
  }

  Future<void> _sampleMemory(String stage) async {
    await WidgetsBinding.instance.endOfFrame;
    final vm = await measureFontVmMemory();
    final android = await _memory.invokeMapMethod<String, Object?>('sample');
    _rows.add({
      'stage': stage,
      'pid': pid,
      'rss': ProcessInfo.currentRss,
      'maxRss': ProcessInfo.maxRss,
      'inputBytes': _inputBytes,
      'assets': _registered.length,
      'android': android,
      'vm': vm,
    });
    final output = File('${Directory.systemTemp.path}/font-lab-$_mode.json');
    await output.writeAsString(
      const JsonEncoder.withIndent('  ').convert({
        'package': 'site.wenyou.fontlab',
        'mode': _mode,
        'manifestSha256': _manifestHash,
        'fontCount': _fontCount,
        'engine': '0cd610717bde95fd88343c64f81c11ba4e5c0010',
        'dataScope': 'local bundled official font fixtures; no business API',
        'httpFontRequests': 0,
        'rows': _rows,
      }),
    );
    debugPrint(
      'FONT_LAB stage=$stage assets=${_registered.length} input=$_inputBytes',
    );
  }

  Future<void> _show(TextFontFamily font) async {
    final shards = _mode == 'all'
        ? font.shards
        : font.shards
              .where(
                (s) =>
                    s.id == 'core' ||
                    s.id == 'original' ||
                    _sample.runes.any(s.contains),
              )
              .toList();
    for (final shard in shards) {
      if (_registered.containsKey(shard.asset.hash)) continue;
      final data = (await rootBundle.load(
        'assets/fonts/${shard.asset.path.split('/').last}',
      )).buffer.asUint8List();
      if (!shard.asset.verifies(data)) throw const FormatException('字体SHA校验失败');
      await (FontLoader(
        shard.family,
      )..addFont(Future.value(ByteData.sublistView(data)))).load();
      _registered[shard.asset.hash] = shard.family;
      _inputBytes += data.length;
      // 原生复制后不让Flutter资产缓存长期持有完整输入字节。
      rootBundle.evict('assets/fonts/${shard.asset.path.split('/').last}');
    }
    if (!mounted) return;
    setState(() {
      _status = font.name;
      _family = _registered[shards.first.asset.hash];
      _fallback = [for (final s in shards.skip(1)) _registered[s.asset.hash]!];
    });
    await WidgetsBinding.instance.endOfFrame;
  }

  Future<void> _run() async {
    try {
      _mode = await _memory.invokeMethod<String>('configuration') ?? 'typical';
      final bytes = (await rootBundle.load(
        'assets/manifest.json',
      )).buffer.asUint8List();
      final manifest = TextFontManifest(bytes);
      _manifestHash = sha256.convert(bytes).toString();
      _fontCount = manifest.fonts.length;
      rootBundle.evict('assets/manifest.json');
      if (_mode == 'visual') {
        for (final id in ['liujianmaocao', 'dotgothic16', 'great-vibes']) {
          final font = manifest.fonts[id]!;
          await _show(font);
          _examples[font.name] = [_family!, ..._fallback];
        }
        setState(() => _status = '真实 FontLoader 字体呈现（离线实验）');
        return;
      }
      await _sampleMemory('baseline');
      for (final font in manifest.fonts.values) {
        await _show(font);
        await _sampleMemory('first-${font.id}');
      }
      final firstBytes = _inputBytes;
      for (var cycle = 1; cycle <= 5; cycle++) {
        for (final font in manifest.fonts.values.toList().reversed) {
          await _show(font);
        }
        if (_inputBytes != firstBytes) throw StateError('重复原生注册');
        await _sampleMemory('return-$cycle');
      }
      setState(() {
        _family = null;
        _fallback = [];
        _status = '正在收尾';
      });
      _registered.clear();
      await _sampleMemory('widgets-and-registry-dropped');
      setState(() => _status = '离线测量完成（$_mode）');
      debugPrint('FONT_LAB COMPLETE mode=$_mode pid=$pid');
    } on Object catch (error, stack) {
      debugPrint('FONT_LAB FAILED $error\n$stack');
      if (mounted) setState(() => _status = '实验失败：$error');
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('温油字体离线实验')),
    body: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_status),
          const SizedBox(height: 24),
          if (_examples.isNotEmpty)
            for (final example in _examples.entries) ...[
              Text(example.key),
              Text(
                _sample,
                style: TextStyle(
                  fontFamily: example.value.first,
                  fontFamilyFallback: example.value.skip(1).toList(),
                  fontSize: 24,
                ),
              ),
              const SizedBox(height: 20),
            ],
          if (_examples.isEmpty)
            Text(
              _sample,
              style: TextStyle(
                fontFamily: _family,
                fontFamilyFallback: _fallback,
                fontSize: 24,
              ),
            ),
        ],
      ),
    ),
  );
}
