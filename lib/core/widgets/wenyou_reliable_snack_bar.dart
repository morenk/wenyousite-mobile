import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:wenyousite_mobile/core/navigation/wenyou_feedback_visibility.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_snack_bar.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_snack_bar_activity.dart';

class WenyouSnackBarReceipt {
  const WenyouSnackBarReceipt({required this.id, required this.message});
  final Object id;
  final String message;
}

/// The caller owns the receipt until a foreground presentation completes.
class WenyouReliableSnackBar extends StatefulWidget {
  const WenyouReliableSnackBar({
    required this.child,
    required this.receipt,
    required this.onDelivered,
    this.visibility,
    super.key,
  });

  final Widget child;
  final WenyouSnackBarReceipt? receipt;
  final ValueChanged<Object> onDelivered;
  final WenyouFeedbackVisibility? visibility;

  @override
  State<WenyouReliableSnackBar> createState() => _WenyouReliableSnackBarState();
}

class _WenyouReliableSnackBarState extends State<WenyouReliableSnackBar>
    with WidgetsBindingObserver {
  ScaffoldMessengerState? _messenger;
  WenyouSnackBarActivity? _activity;
  ScaffoldFeatureController<SnackBar, SnackBarClosedReason>? _showing;
  Object? _showingId;
  Object? _deliveredId;
  bool _scheduled = false;
  bool _closing = false;
  AppLifecycleState _lifecycle =
      WidgetsBinding.instance.lifecycleState ?? AppLifecycleState.resumed;

  bool get _ready =>
      _lifecycle == AppLifecycleState.resumed &&
      (widget.visibility?.ready ?? true) &&
      !(_activity?.busy ?? false);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    widget.visibility?.addListener(_changed);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (_messenger != messenger) {
      _pause();
      _activity?.removeListener(_changed);
      _messenger = messenger;
      _activity = messenger == null
          ? null
          : WenyouSnackBarActivity.of(messenger);
      _activity?.addListener(_changed);
    }
    _changed();
  }

  @override
  void didUpdateWidget(WenyouReliableSnackBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.visibility != widget.visibility) {
      oldWidget.visibility?.removeListener(_changed);
      widget.visibility?.addListener(_changed);
    }
    _changed();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _lifecycle = state;
    _changed();
  }

  void _changed() {
    if (!_ready &&
        SchedulerBinding.instance.schedulerPhase !=
            SchedulerPhase.persistentCallbacks) {
      _pause();
    }
    if (_scheduled || !mounted) return;
    _scheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scheduled = false;
      if (mounted) _present();
    });
    WidgetsBinding.instance.ensureVisualUpdate();
  }

  bool _hasScaffold() {
    var found = false;
    void visit(Element element) {
      if (found) return;
      if (element.widget is Scaffold &&
          ScaffoldMessenger.maybeOf(element) == _messenger) {
        found = true;
      } else {
        element.visitChildElements(visit);
      }
    }

    context.visitChildElements(visit);
    return found;
  }

  void _present() {
    if (!_ready || _showingId != widget.receipt?.id) _pause();
    final receipt = widget.receipt;
    final messenger = _messenger;
    if (!_ready ||
        _closing ||
        _showing != null ||
        receipt == null ||
        receipt.id == _deliveredId ||
        messenger?.mounted != true ||
        !_hasScaffold()) {
      return;
    }
    final controller = messenger!.showWenyouSnackBar(
      receipt.message,
      pacing: WenyouSnackBarPacing.extended,
      tone: WenyouSnackBarTone.success,
      deferred: true,
    );
    _showing = controller;
    _showingId = receipt.id;
    controller.closed.then((reason) {
      if (!mounted || _showing != controller) return;
      _showing = null;
      _showingId = null;
      if (_ready &&
          widget.receipt?.id == receipt.id &&
          (reason == SnackBarClosedReason.timeout ||
              reason == SnackBarClosedReason.swipe ||
              reason == SnackBarClosedReason.action ||
              reason == SnackBarClosedReason.dismiss)) {
        _deliveredId = receipt.id;
        widget.onDelivered(receipt.id);
      }
      _changed();
    });
  }

  void _pause() {
    final controller = _showing;
    if (controller == null) return;
    _showing = null;
    _showingId = null;
    _closing = true;
    controller.close();
    controller.closed.then((_) {
      _closing = false;
      if (mounted) _changed();
    });
  }

  @override
  void dispose() {
    widget.visibility?.removeListener(_changed);
    _activity?.removeListener(_changed);
    WidgetsBinding.instance.removeObserver(this);
    // Route teardown may already be unmounting the Scaffold. Close after it.
    final controller = _showing;
    final messenger = _messenger;
    _showing = null;
    if (controller != null) {
      var closed = false;
      controller.closed.then((_) => closed = true);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!closed && messenger?.mounted == true) controller.close();
      });
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
