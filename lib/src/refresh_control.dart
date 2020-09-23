import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_gestures/flutter_gestures.dart';

import 'sliver_refresh.dart';

part 'load_control.dart';
part 'refresh_trigger.dart';
part 'refresh_controller.dart';
part 'load_indicator_delegate.dart';
part 'refresh_indicator_delegate.dart';

enum RefreshIndicatorMode {
  drag,
  armed,
  refresh,
  success,
  failure,
  inactive,
}

typedef Future<void> RefreshCallback();

class RefreshControl extends StatefulWidget {
  RefreshControl({
    Key key,
    @required this.onRefresh,
    this.delegate = const RefreshIndicatorDelegate(),
  })  : assert(delegate != null),
        assert(onRefresh != null),
        super(key: key);

  final RefreshCallback onRefresh;
  final RefreshIndicatorDelegate delegate;

  @override
  _RefreshControlState createState() => _RefreshControlState();
}

class _RefreshControlState extends State<RefreshControl> implements _Refresher {
  dynamic failure;
  dynamic success;
  bool isFailed = false;
  bool dragging = false;
  void Function() disposer;
  Future<void> refreshTask;
  Future<void> delayFuture;
  RefreshIndicatorMode refreshState;
  double latestIndicatorBoxExtent = 0.0;

  @override
  void initState() {
    super.initState();
    refreshState = RefreshIndicatorMode.inactive;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (disposer != null) {
      disposer();
      disposer = null;
    }
    final trigger = _RefreshTriggerScope.of(context);
    assert(
      trigger != null,
      "RefreshControl must be integrated with a RefreshTrigger.",
    );
    trigger.refresher = this;
    disposer = () {
      if (trigger.refresher == this) trigger.refresher = null;
    };
  }

  @override
  void setState(VoidCallback fn) {
    if (SchedulerBinding.instance.schedulerPhase == SchedulerPhase.idle) {
      if (mounted) super.setState(fn);
    } else {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        if (mounted) super.setState(fn);
      });
    }
  }

  @override
  void dispose() {
    if (disposer != null) {
      disposer();
      disposer = null;
    }
    super.dispose();
  }

  bool get isRefreshing => refreshTask != null;

  void dragCancel() {
    if (dragging) dragging = false;
  }

  void dragStart(DragStartDetails details) {
    if (!dragging) dragging = true;
  }

  void dragEnd(DragEndDetails details) {
    if (dragging) {
      dragging = false;
      if (refreshState == RefreshIndicatorMode.armed) refresh();
    }
  }

  void refresh() {
    if (refreshTask != null || widget.onRefresh == null) return;
    refreshTask = widget.onRefresh().whenComplete(() {
      final milliseconds = isFailed
          ? widget.delegate.failureDuration
          : widget.delegate.successDuration;
      Future<void> future;
      if (milliseconds > 0) {
        future = Future.delayed(
          Duration(milliseconds: milliseconds),
          () => setState(() => delayFuture = null),
        );
      }
      setState(() {
        refreshTask = null;
        delayFuture = future;
      });
    });
    setState(() => refreshState = RefreshIndicatorMode.refresh);
  }

  void failedToRefresh(dynamic payload) {
    isFailed = true;
    failure = payload;
  }

  void refreshSuccessfully(dynamic payload) {
    isFailed = false;
    success = payload;
  }

  RefreshIndicatorMode transitionNextState() {
    RefreshIndicatorMode nextState;
    switch (refreshState) {
      case RefreshIndicatorMode.inactive:
        if (latestIndicatorBoxExtent <= 0) {
          return RefreshIndicatorMode.inactive;
        } else {
          nextState = RefreshIndicatorMode.drag;
        }
        continue drag;
      drag:
      case RefreshIndicatorMode.drag:
        if (latestIndicatorBoxExtent <= 0) {
          return RefreshIndicatorMode.inactive;
        } else if (latestIndicatorBoxExtent <
            widget.delegate.refreshTriggerPullDistance) {
          return RefreshIndicatorMode.drag;
        } else {
          nextState = RefreshIndicatorMode.armed;
        }
        continue armed;
      armed:
      case RefreshIndicatorMode.armed:
        if (refreshTask != null) {
          nextState = RefreshIndicatorMode.refresh;
        } else if (latestIndicatorBoxExtent <
            widget.delegate.refreshTriggerPullDistance) {
          return RefreshIndicatorMode.drag;
        } else {
          return RefreshIndicatorMode.armed;
        }
        continue refresh;
      refresh:
      case RefreshIndicatorMode.refresh:
        if (refreshTask != null) {
          return RefreshIndicatorMode.refresh;
        }
        if (isFailed) {
          nextState = RefreshIndicatorMode.failure;
          continue failure;
        } else {
          nextState = RefreshIndicatorMode.success;
          continue success;
        }
        break;
      success:
      case RefreshIndicatorMode.success:
        if (delayFuture != null || latestIndicatorBoxExtent > 0.0) {
          return RefreshIndicatorMode.success;
        } else {
          failure = null;
          success = null;
          isFailed = false;
          refreshTask = null;
          nextState = RefreshIndicatorMode.inactive;
        }
        break;
      failure:
      case RefreshIndicatorMode.failure:
        if (delayFuture != null || latestIndicatorBoxExtent > 0.0) {
          return RefreshIndicatorMode.failure;
        } else {
          failure = null;
          success = null;
          isFailed = false;
          refreshTask = null;
          nextState = RefreshIndicatorMode.inactive;
        }
        break;
    }

    return nextState;
  }

  double get refreshIndicatorLayoutExtent {
    if (refreshTask != null) return widget.delegate.refreshIndicatorExtent;
    if (delayFuture != null) {
      if (isFailed) return widget.delegate.failureIndicatorExtent;
      return widget.delegate.successIndicatorExtent;
    }
    return 0.0;
  }

  @override
  Widget build(BuildContext context) {
    return SliverRefresh(
      refreshIndicatorLayoutExtent: refreshIndicatorLayoutExtent,
      child: LayoutBuilder(
        builder: (context, constraints) {
          latestIndicatorBoxExtent = constraints.maxHeight;
          refreshState = transitionNextState();
          return widget.delegate._buildIndicator(
            context: context,
            failure: failure,
            success: success,
            constraints: constraints,
            refreshState: refreshState,
            pulledExtent: latestIndicatorBoxExtent,
          );
        },
      ),
    );
  }
}

abstract class _Refresher {
  void refresh();
  void dragCancel();
  bool get isRefreshing;
  void dragEnd(DragEndDetails details);
  void failedToRefresh(dynamic payload);
  void dragStart(DragStartDetails details);
  void refreshSuccessfully(dynamic payload);
}
