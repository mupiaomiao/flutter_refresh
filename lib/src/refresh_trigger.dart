part of "refresh_control.dart";

class RefreshTrigger extends StatelessWidget {
  final Widget child;
  final _dragEvent = Object();
  final _scrollEvent = Object();
  final RefreshController controller;
  final void Function(ScrollMetrics metrics) onScroll;

  static final _gestureBinding = UIGestureBinding();

  RefreshTrigger({
    Key key,
    this.onScroll,
    @required this.child,
    @required this.controller,
  })  : assert(child != null),
        assert(controller != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return UIGestureDetector(
      onVerticalDragCancel: () {
        $eventBus.emitEvent(_dragEvent);
      },
      onVerticalDragEnd: (details) {
        $eventBus.emitEventWithArg(_dragEvent, details);
      },
      onVerticalDragStart: (details) {
        $eventBus.emitEventWithArg(_dragEvent, details);
      },
      gestureBinding: UIGestureArena.of(context) ?? _gestureBinding,
      child: NotificationListener<ScrollNotification>(
        child: _RefreshTriggerScope(
          child: child,
          dragEvent: _dragEvent,
          scrollEvent: _scrollEvent,
          loadEvent: controller._loadEvent,
          refreshEvent: controller._refreshEvent,
        ),
        onNotification: (notification) {
          final metrics = notification.metrics;
          if (onScroll != null) onScroll(metrics);
          final distance = metrics.maxScrollExtent - metrics.pixels;
          $eventBus.emitEventWithArg(_scrollEvent, distance);
          return false;
        },
      ),
    );
  }
}

class _RefreshTriggerScope extends InheritedWidget {
  _RefreshTriggerScope({
    Key key,
    @required this.child,
    @required this.dragEvent,
    @required this.loadEvent,
    @required this.scrollEvent,
    @required this.refreshEvent,
  })  : assert(child != null),
        assert(dragEvent != null),
        assert(loadEvent != null),
        assert(scrollEvent != null),
        assert(refreshEvent != null),
        super(key: key, child: child);

  final Widget child;
  final Object dragEvent;
  final Object loadEvent;
  final Object scrollEvent;
  final Object refreshEvent;

  static _RefreshTriggerScope of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_RefreshTriggerScope>();
  }

  @override
  bool updateShouldNotify(_RefreshTriggerScope oldWidget) {
    return dragEvent != oldWidget.dragEvent ||
        loadEvent != oldWidget.loadEvent ||
        scrollEvent != oldWidget.scrollEvent ||
        refreshEvent != oldWidget.refreshEvent;
  }
}
