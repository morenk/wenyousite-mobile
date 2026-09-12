import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/features/users/application/me_profile_controller.dart';

/// Retained navigation branches must re-read progression after asynchronous
/// rewards. TickerMode follows the active branch and covering Navigator routes.
class MeProfileRefreshBoundary extends ConsumerStatefulWidget {
  const MeProfileRefreshBoundary({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<MeProfileRefreshBoundary> createState() =>
      _MeProfileRefreshBoundaryState();
}

class _MeProfileRefreshBoundaryState
    extends ConsumerState<MeProfileRefreshBoundary>
    with WidgetsBindingObserver {
  bool? _active;
  bool _refreshScheduled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final active = TickerMode.valuesOf(context).enabled;
    if (_active == false && active) _scheduleRefresh();
    _active = active;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _active == true) {
      _scheduleRefresh();
    }
  }

  void _scheduleRefresh() {
    if (_refreshScheduled) return;
    _refreshScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshScheduled = false;
      if (!mounted || _active != true) return;
      if (!ref.exists(meProfileControllerProvider)) return;
      final state = ref.read(meProfileControllerProvider);
      // Preserve an in-flight initial read or profile edit.
      if (state.phase == MeProfilePhase.loading || state.isSubmitting) return;
      unawaited(ref.read(meProfileControllerProvider.notifier).refresh());
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
