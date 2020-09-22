import 'dart:async';
import 'dart:collection';
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
  done,
  armed,
  refresh,
  inactive,
}

typedef void RefreshSuccess([dynamic payload]);
typedef void RefreshFailure([dynamic payload]);

class RefreshFeedback {
  final RefreshSuccess success;
  final RefreshFailure failure;

  const RefreshFeedback._(
    this.success,
    this.failure,
  )   : assert(success != null),
        assert(failure != null);
}

typedef Future<void> RefreshCallback([RefreshFeedback feedback]);

class RefreshControl extends StatefulWidget {
  RefreshControl({
    Key key,
    this.controller,
    @required this.onRefresh,
    this.delegate = const DefaultRefreshIndicatorDelegate(),
  })  : assert(delegate != null),
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

  final RefreshCallback onRefresh;
  final RefreshController controller;
  final RefreshIndicatorDelegate delegate;

  @override
  _RefreshControlState createState() => _RefreshControlState();
}

class _RefreshControlState extends State<RefreshControl> {
  dynamic failure;
  dynamic success;
  bool hasError = false;
  bool dragging = false;
  RefreshFeedback feedback;
  Future<void> refreshTask;
  RefreshController controller;
  RefreshIndicatorMode refreshState;
  double latestIndicatorBoxExtent = 0.0;

  @override
  void initState() {
    super.initState();
    feedback = RefreshFeedback._(
      ([payload]) {
        hasError = false;
        success = payload;
      },
      ([payload]) {
        hasError = true;
        failure = payload;
      },
    );
    refreshState = RefreshIndicatorMode.inactive;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    updateController(widget.controller ?? RefreshTrigger.of(context));
  }

  @override
  void didUpdateWidget(RefreshControl oldWidget) {
    super.didUpdateWidget(oldWidget);
    updateController(widget.controller ?? RefreshTrigger.of(context));
  }

  void updateController(RefreshController newController) {
    assert(
      newController != null,
      "The 'RefreshControl' must have a 'RefreshController' or be integrated with 'RefreshTrigger'.",
    );
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
    feedback = null;
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
      if (refreshState == RefreshIndicatorMode.armed) {
        startRefresh();
      }
    }
  }

  void refresh() {
    if (widget.onRefresh == null) return;
    refreshTask = widget.onRefresh(feedback).whenComplete(
      () {
        if (mounted) {
          setState(() => refreshTask = null);
          refreshState = transitionNextState();
        }
      },
    );
    if (mounted) {
      setState(() {
        refreshState = RefreshIndicatorMode.refresh;
      });
    }
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
        } else {
          nextState = RefreshIndicatorMode.done;
          if (SchedulerBinding.instance.schedulerPhase == SchedulerPhase.idle) {
            if (mounted) {
              setState(() => refreshState = RefreshIndicatorMode.done);
            }
          } else {
            WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
              if (mounted) {
                setState(() => refreshState = RefreshIndicatorMode.done);
              }
            });
          }
        }
        continue done;
      done:
      case RefreshIndicatorMode.done:
        if (latestIndicatorBoxExtent > 0.0) {
          return RefreshIndicatorMode.done;
        } else {
          failure = null;
          success = null;
          hasError = false;
          refreshTask = null;
          nextState = RefreshIndicatorMode.inactive;
        }
        break;
    }

    return nextState;
  }

  @override
  Widget build(BuildContext context) {
    return SliverRefresh(
      inactiveIndicatorLayoutExtent: widget.delegate.inactiveIndicatorExtent,
      refreshIndicatorLayoutExtent: refreshState == RefreshIndicatorMode.refresh
          ? widget.delegate.refreshIndicatorExtent
          : 0.0,
      child: LayoutBuilder(
        builder: (context, constraints) {
          latestIndicatorBoxExtent =
              constraints.maxHeight - widget.delegate.inactiveIndicatorExtent;
          refreshState = transitionNextState();
          return widget.delegate._buildIndicator(
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
