part of "refresh_control.dart";

class RefreshTrigger extends StatefulWidget {
  final Widget child;
  final double loadTriggerDistance;
  final RefreshController controller;
  final Future<void> Function() onLoad;

  const RefreshTrigger({
    Key key,
    this.child,
    this.onLoad,
    this.controller,
    this.loadTriggerDistance,
  }) : super(key: key);

  static RefreshController of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<_RefreshTriggerScope>();
    if (scope != null && scope.state != null) return scope.state.controller;
    return null;
  }

  @override
  _RefreshTriggerState createState() => _RefreshTriggerState();
}

class _RefreshTriggerState extends State<RefreshTrigger> {
  Future<void> loadTask;
  void Function() disposer;
  RefreshController controller;

  @override
  void initState() {
    super.initState();
    controller = widget.controller ?? createController();
  }

  @override
  void didUpdateWidget(RefreshTrigger oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(widget.controller, oldWidget.controller)) {
      if (disposer != null) {
        disposer();
        disposer = null;
      }
      controller = widget.controller ?? createController();
    }
  }

  RefreshController createController() {
    assert(disposer == null);
    final controller = RefreshController();
    disposer = controller.dispose;
    return controller;
  }

  @override
  void dispose() {
    if (disposer != null) {
      disposer();
      disposer = null;
    }
    controller = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _RefreshTriggerScope(
      state: this,
      child: UIGestureDetector(
        child: NotificationListener<ScrollNotification>(
          child: widget.child,
          onNotification: (notification) {
            final metrics = notification.metrics;
            if (loadTask == null &&
                widget.onLoad != null &&
                widget.loadTriggerDistance != null &&
                metrics.maxScrollExtent - metrics.pixels <=
                    widget.loadTriggerDistance) {
              loadTask = widget.onLoad()..whenComplete(() => loadTask = null);
            }
            return false;
          },
        ),
        onVerticalDragCancel: () => controller.dragCancel(),
        onVerticalDragEnd: (details) => controller.dragEnd(details),
        onVerticalDragDown: (details) => controller.dragDown(details),
        onVerticalDragStart: (details) => controller.dragStart(details),
        onVerticalDragUpdate: (details) => controller.dragUpdate(details),
      ),
    );
  }
}

class _RefreshTriggerScope extends InheritedWidget {
  _RefreshTriggerScope({
    Key key,
    this.child,
    @required this.state,
  })  : assert(state != null),
        super(key: key, child: child);

  final Widget child;
  final _RefreshTriggerState state;

  @override
  bool updateShouldNotify(_RefreshTriggerScope oldWidget) {
    return true;
  }
}
