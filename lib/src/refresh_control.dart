import 'dart:async';
import 'dart:collection';
import 'package:flutter/foundation.dart';

import 'sliver_refresh.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_gestures/flutter_gestures.dart';

part 'refresh_trigger.dart';
part 'refresh_controller.dart';
part 'refresh_indicator_delegate.dart';

enum RefreshIndicatorState {
  drag,
  done,
  armed,
  refresh,
  inactive,
}

typedef void SliverRefreshSuccess([dynamic payload]);
typedef void SliverRefreshFailure([dynamic payload]);
typedef Future<void> SliverRefreshCallback(
    [SliverRefreshSuccess success, SliverRefreshFailure failure]);

class SliverRefreshControl extends StatefulWidget {
  SliverRefreshControl({
    Key key,
    this.controller,
    @required this.onRefresh,
    this.margin = const EdgeInsets.all(0),
    this.delegate = const _RefreshIndicatorDelegate(),
  })  : assert(margin != null),
        assert(delegate != null),
        assert(onRefresh != null),
        assert(delegate.refreshIndicatorExtent != null),
        assert(delegate.refreshIndicatorExtent >= 0.0),
        assert(delegate.refreshTriggerPullDistance != null),
        assert(delegate.refreshTriggerPullDistance >= 0.0),
        assert(delegate.inactiveIndicatorExtent != null),
        assert(delegate.inactiveIndicatorExtent >= 0.0),
        assert(
            delegate.refreshTriggerPullDistance >=
                delegate.refreshIndicatorExtent,
            'The refresh indicator cannot take more space in its final state '
            'than the amount initially created by overscrolling.'),
        super(key: key);

  final EdgeInsetsGeometry margin;
  final RefreshController controller;
  final SliverRefreshCallback onRefresh;
  final RefreshIndicatorDelegate delegate;

  @override
  _SliverRefreshControlState createState() => _SliverRefreshControlState();
}

class _SliverRefreshControlState extends State<SliverRefreshControl> {
  dynamic failure;
  dynamic success;
  bool hasError = false;
  bool dragging = false;
  Future<void> refreshTask;
  RefreshController controller;
  RefreshIndicatorState refreshState;
  double latestIndicatorBoxExtent = 0.0;

  @override
  void initState() {
    super.initState();
    refreshState = RefreshIndicatorState.inactive;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    updateController(widget.controller ?? RefreshTrigger.of(context));
  }

  @override
  void didUpdateWidget(SliverRefreshControl oldWidget) {
    super.didUpdateWidget(oldWidget);
    updateController(widget.controller ?? RefreshTrigger.of(context));
  }

  void updateController(RefreshController newController) {
    if (!identical(controller, newController)) {
      if (controller != null) {
        controller.offDragEnd(onDragEnd);
        controller.offRefresh(startRefresh);
        controller.offDragStart(onDragStart);
        controller.offDragCancel(onDragCancel);
      }
      controller = newController;
      if (controller != null) {
        controller.onDragEnd(onDragEnd);
        controller.onRefresh(startRefresh);
        controller.onDragStart(onDragStart);
        controller.onDragCancel(onDragCancel);
      }
    }
  }

  @override
  void dispose() {
    if (controller != null) {
      controller.offDragEnd(onDragEnd);
      controller.offRefresh(startRefresh);
      controller.offDragStart(onDragStart);
      controller.offDragCancel(onDragCancel);
      controller = null;
    }
    super.dispose();
  }

  void onDragCancel() {
    if (dragging && mounted) {
      dragging = false;
    }
  }

  void onDragStart(DragStartDetails details) {
    if (!dragging && mounted) {
      dragging = true;
    }
  }

  void onDragEnd(DragEndDetails details) {
    if (dragging && mounted) {
      dragging = false;
      if (refreshState == RefreshIndicatorState.armed) {
        startRefresh();
      }
    }
  }

  void refresh() {
    if (widget.onRefresh == null) return;
    refreshTask = widget.onRefresh(([success]) {
      hasError = false;
      success = success;
    }, ([error]) {
      error = error;
      hasError = true;
    });
    refreshTask.whenComplete(() {
      if (mounted) {
        setState(() => refreshTask = null);
        refreshState = transitionNextState();
      }
    });
    setState(() {
      refreshState = RefreshIndicatorState.refresh;
    });
  }

  void startRefresh() {
    if (refreshTask == null) {
      if (SchedulerBinding.instance.schedulerPhase == SchedulerPhase.idle) {
        refresh();
      } else {
        SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
          refresh();
        });
      }
    }
  }

  RefreshIndicatorState transitionNextState() {
    RefreshIndicatorState nextState;
    switch (refreshState) {
      case RefreshIndicatorState.inactive:
        if (latestIndicatorBoxExtent <= 0) {
          return RefreshIndicatorState.inactive;
        } else {
          nextState = RefreshIndicatorState.drag;
        }
        continue drag;
      drag:
      case RefreshIndicatorState.drag:
        if (latestIndicatorBoxExtent <= 0) {
          return RefreshIndicatorState.inactive;
        } else if (latestIndicatorBoxExtent <
            widget.delegate.refreshTriggerPullDistance) {
          return RefreshIndicatorState.drag;
        } else {
          nextState = RefreshIndicatorState.armed;
        }
        continue armed;
      armed:
      case RefreshIndicatorState.armed:
        if (refreshTask != null) {
          nextState = RefreshIndicatorState.refresh;
        } else if (latestIndicatorBoxExtent <
            widget.delegate.refreshTriggerPullDistance) {
          return RefreshIndicatorState.drag;
        } else {
          return RefreshIndicatorState.armed;
        }
        continue refresh;
      refresh:
      case RefreshIndicatorState.refresh:
        if (refreshTask != null) {
          return RefreshIndicatorState.refresh;
        } else {
          nextState = RefreshIndicatorState.done;
          if (SchedulerBinding.instance.schedulerPhase == SchedulerPhase.idle) {
            setState(() => refreshState = RefreshIndicatorState.done);
          } else {
            WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
              setState(() => refreshState = RefreshIndicatorState.done);
            });
          }
        }
        continue done;
      done:
      case RefreshIndicatorState.done:
        if (latestIndicatorBoxExtent > 0.0) {
          return RefreshIndicatorState.done;
        } else {
          failure = null;
          success = null;
          hasError = false;
          refreshTask = null;
          nextState = RefreshIndicatorState.inactive;
        }
        break;
    }

    return nextState;
  }

  @override
  Widget build(BuildContext context) {
    return SliverRefresh(
      margin: widget.margin,
      inactiveIndicatorLayoutExtent: widget.delegate.inactiveIndicatorExtent,
      refreshIndicatorLayoutExtent:
          refreshState == RefreshIndicatorState.refresh
              ? widget.delegate.refreshIndicatorExtent
              : 0.0,
      child: LayoutBuilder(
        builder: (context, constraints) {
          latestIndicatorBoxExtent =
              constraints.maxHeight - widget.delegate.inactiveIndicatorExtent;
          refreshState = transitionNextState();
          return widget.delegate.buildIndicator(
            context: context,
            failure: failure,
            success: success,
            hasError: hasError,
            constraints: constraints,
            refreshState: refreshState,
            pulledExtent: latestIndicatorBoxExtent,
          );
        },
      ),
    );
  }
}
