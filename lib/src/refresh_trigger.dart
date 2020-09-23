part of "refresh_control.dart";

class RefreshTrigger extends StatefulWidget {
  final Widget child;
  final RefreshController controller;

  const RefreshTrigger({
    Key key,
    @required this.child,
    @required this.controller,
  })  : assert(child != null),
        assert(controller != null),
        super(key: key);

  @override
  _RefreshTriggerState createState() => _RefreshTriggerState();
}

class _RefreshTriggerState extends State<RefreshTrigger>
    implements _RefreshControllerDelegate {
  void Function() disposer;

  _Loader _loader;
  _Loader get loader => _loader;
  set loader(_Loader value) {
    if (value == _loader) return;
    final oldValue = _loader;
    _loader = value;
    if ((oldValue == null || value == null) && mounted) {
      setState(() {});
    }
  }

  _Refresher _refresher;
  _Refresher get refresher => _refresher;
  set refresher(_Refresher value) {
    if (value == _refresher) return;
    final oldValue = _refresher;
    _refresher = value;
    if ((oldValue == null || value == null) && mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    widget.controller._delegate = this;
    disposer = () {
      if (widget.controller._delegate == this)
        widget.controller._delegate = null;
    };
  }

  @override
  void didUpdateWidget(RefreshTrigger oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      if (disposer != null) {
        disposer();
        disposer = null;
      }
      widget.controller._delegate = this;
      disposer = () {
        if (widget.controller._delegate == this)
          widget.controller._delegate = null;
      };
    }
  }

  @override
  void dispose() {
    loader = null;
    refresher = null;
    if (disposer != null) {
      disposer();
      disposer = null;
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget child = widget.child;
    if (loader != null) {
      child = NotificationListener<ScrollNotification>(
        child: child,
        onNotification: (notification) {
          final metrics = notification.metrics;
          final distance = metrics.maxScrollExtent - metrics.pixels;
          if (distance <= loader.loadTriggerDistance && loader.canLoad)
            loader.load();
          return false;
        },
      );
    }
    if (refresher != null) {
      child = UIGestureDetector(
        child: child,
        onVerticalDragEnd: refresher.dragEnd,
        onVerticalDragStart: refresher.dragStart,
        onVerticalDragCancel: refresher.dragCancel,
      );
    }
    return _RefreshTriggerScope(
      state: this,
      child: child,
    );
  }

  bool get isLoading => loader?.isLoading ?? false;

  bool get isRefreshing => refresher?.isRefreshing ?? false;

  void startRefresh() => refresher?.refresh();

  void failedToLoad(dynamic payload) => loader?.failedToLoad(payload);

  void loadSuccessfully(bool hasData, bool hasMoreData) =>
      loader?.loadSuccessfully(hasData, hasMoreData);

  void failedToRefresh(dynamic payload) => refresher?.failedToRefresh(payload);

  void refreshSuccessfully(bool hasData, bool hasMoreData, dynamic payload) {
    refresher?.refreshSuccessfully(payload);
    loader?.updateLoadState(hasData, hasMoreData);
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

  static _RefreshTriggerState of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_RefreshTriggerScope>()
        ?.state;
  }

  @override
  bool updateShouldNotify(_RefreshTriggerScope oldWidget) {
    return oldWidget.state != state;
  }
}
