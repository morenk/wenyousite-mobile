import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Replaces Android's frame-by-frame IME inset with the animation's final
/// inset, so Flutter layout jumps to its settled keyboard position in one
/// frame. Other platforms keep the engine-provided inset.
class WenyouInstantKeyboardInsets extends StatefulWidget {
  const WenyouInstantKeyboardInsets({required this.child, super.key});

  static const channelName = 'site.wenyou.app/keyboard_insets';

  final Widget child;

  @override
  State<WenyouInstantKeyboardInsets> createState() =>
      _WenyouInstantKeyboardInsetsState();
}

class _WenyouInstantKeyboardInsetsState
    extends State<WenyouInstantKeyboardInsets>
    with WidgetsBindingObserver {
  static const _channel = MethodChannel(
    WenyouInstantKeyboardInsets.channelName,
  );

  double? _targetBottomPhysicalPixels;
  AppLifecycleState _lifecycleState =
      WidgetsBinding.instance.lifecycleState ?? AppLifecycleState.resumed;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _channel.setMethodCallHandler(_handlePlatformCall);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _channel.setMethodCallHandler(null);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _lifecycleState = state;
    if (_targetBottomPhysicalPixels == null) return;
    setState(() => _targetBottomPhysicalPixels = null);
  }

  Future<void> _handlePlatformCall(MethodCall call) async {
    if (call.method != 'keyboardInsetTargetChanged') return;
    final arguments = call.arguments;
    if (arguments is! Map) return;
    if (_lifecycleState != AppLifecycleState.resumed) return;
    final bottom = arguments['bottomPhysicalPixels'];
    if (bottom is! num || !bottom.isFinite || bottom < 0 || !mounted) return;
    final target = bottom.toDouble();
    if (_targetBottomPhysicalPixels == target) return;
    setState(() => _targetBottomPhysicalPixels = target);
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final physicalBottom = _targetBottomPhysicalPixels;
    if (physicalBottom == null) return widget.child;

    final bottom = physicalBottom / View.of(context).devicePixelRatio;
    final currentInsets = media.viewInsets;
    return MediaQuery(
      data: media.copyWith(
        viewInsets: EdgeInsets.fromLTRB(
          currentInsets.left,
          currentInsets.top,
          currentInsets.right,
          bottom,
        ),
      ),
      child: widget.child,
    );
  }
}
