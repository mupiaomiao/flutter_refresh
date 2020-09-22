part of 'refresh_control.dart';

enum LoadIndicatorMode {
  /// 点击加载更多
  idle,

  /// 正在加载...
  load,

  /// 加载失败，点击重新加载
  error,

  /// 暂无数据
  noData,

  /// 没有更多数据了
  noMoreData,
}

class LoadFeedback {
  final void Function() noData;
  final void Function() noMoreData;
  final void Function([dynamic error]) failure;

  const LoadFeedback._({
    @required this.noData,
    @required this.failure,
    @required this.noMoreData,
  })  : assert(noData != null),
        assert(failure != null),
        assert(noMoreData != null);
}

typedef Future<void> LoadCallback([LoadFeedback feedback]);

class LoadControl extends StatefulWidget {
  const LoadControl({
    Key key,
    this.controller,
    @required this.onLoad,
    this.loadTriggerDistance = 20.0,
    this.delegate = const DefaultLoadIndicatorDelegate(),
  })  : assert(onLoad != null),
        assert(delegate != null),
        assert(loadTriggerDistance != null),
        assert(loadTriggerDistance > 0.0),
        super(key: key);

  final LoadCallback onLoad;
  final double loadTriggerDistance;
  final RefreshController controller;
  final LoadIndicatorDelegate delegate;

  @override
  _LoadControlState createState() => _LoadControlState();
}

class _LoadControlState extends State<LoadControl> implements _Loader {
  dynamic error;
  Future<void> loadTask;
  LoadFeedback feedback;
  LoadIndicatorMode loadState;
  RefreshController controller;

  @override
  void initState() {
    super.initState();
    loadState = LoadIndicatorMode.noData;
    feedback = LoadFeedback._(
      noData: () {
        if (mounted) setState(() => loadState = LoadIndicatorMode.noData);
      },
      noMoreData: () {
        if (mounted) setState(() => loadState = LoadIndicatorMode.noMoreData);
      },
      failure: ([error]) {
        if (mounted) {
          setState(() {
            error = error;
            loadState = LoadIndicatorMode.error;
          });
        }
      },
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    updateController(widget.controller ?? RefreshTrigger.of(context));
  }

  @override
  void didUpdateWidget(LoadControl oldWidget) {
    super.didUpdateWidget(oldWidget);
    updateController(widget.controller ?? RefreshTrigger.of(context));
  }

  void updateController(RefreshController newController) {
    assert(
      newController != null,
      "The 'LoadControl' must have a 'RefreshController' or be integrated with 'RefreshTrigger'.",
    );
    if (!identical(controller, newController)) {
      if (controller != null) {
        controller.offLoad(this);
      }
      controller = newController;
      if (controller != null) {
        controller.onLoad(this);
      }
    }
  }

  @override
  void dispose() {
    feedback = null;
    if (controller != null) {
      controller.offLoad(this);
    }
    super.dispose();
  }

  bool get canLoad =>
      mounted &&
      loadState != null &&
      loadState != LoadIndicatorMode.load &&
      loadState != LoadIndicatorMode.noData &&
      loadState != LoadIndicatorMode.noMoreData;

  double get loadTriggerDistance => widget.loadTriggerDistance;

  void load() {
    if (canLoad) {
      loadTask = widget.onLoad(feedback).whenComplete(() {
        loadTask = null;
        if (loadState == LoadIndicatorMode.load && mounted) {
          setState(() => loadState = LoadIndicatorMode.idle);
        }
      });
      setState(() => loadState = LoadIndicatorMode.load);
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: load,
      child: widget.delegate._buildIndicator(context, loadState, error),
    );
  }
}

abstract class _Loader {
  void load();
  bool get canLoad;
  double get loadTriggerDistance;
}
