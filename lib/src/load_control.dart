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

typedef Future<void> LoadCallback();

class LoadControl extends StatefulWidget {
  LoadControl({
    Key key,
    @required this.onLoad,
    this.delegate = const LoadIndicatorDelegate(),
  })  : assert(onLoad != null),
        assert(delegate != null),
        super(key: key);

  final LoadCallback onLoad;
  final LoadIndicatorDelegate delegate;

  @override
  _LoadControlState createState() => _LoadControlState();
}

class _LoadControlState extends State<LoadControl> implements _Loader {
  dynamic failure;
  bool noData = false;
  bool isFailed = false;
  bool noMoreData = false;
  Future<void> loadTask;
  void Function() disposer;
  LoadIndicatorMode loadState;

  @override
  void initState() {
    super.initState();
    loadState = LoadIndicatorMode.noData;
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
      "LoadControl must be integrated with a RefreshTrigger.",
    );
    trigger.loader = this;
    disposer = () {
      if (trigger.loader == this) trigger.loader = null;
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

  bool get isLoading => loadTask != null;

  void failedToLoad(dynamic payload) {
    isFailed = true;
    failure = payload;
  }

  void loadSuccessfully(bool hasData, bool hasMoreData) {
    failure = null;
    isFailed = false;
    updateLoadState(hasData, hasMoreData);
  }

  bool get canLoad =>
      mounted &&
      loadState != null &&
      loadState != LoadIndicatorMode.load &&
      loadState != LoadIndicatorMode.noData &&
      loadState != LoadIndicatorMode.noMoreData;

  void updateLoadState(bool hasData, bool hasMoreData) {
    assert(hasData != null);
    assert(hasMoreData != null);
    noData = !hasData;
    noMoreData = !hasMoreData;
  }

  double get loadTriggerDistance => widget.delegate.loadTriggerDistance;

  void load() {
    if (canLoad) {
      loadTask = widget.onLoad().whenComplete(() {
        loadTask = null;
        if (isFailed) {
          isFailed = false;
          setState(() => loadState = LoadIndicatorMode.error);
          return;
        }
        if (noData) {
          setState(() => loadState = LoadIndicatorMode.noData);
          return;
        }
        if (noMoreData) {
          setState(() => loadState = LoadIndicatorMode.noMoreData);
          return;
        }
        setState(() => loadState = LoadIndicatorMode.idle);
      });
      setState(() => loadState = LoadIndicatorMode.load);
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: load,
      child: widget.delegate._buildIndicator(context, loadState, failure),
    );
  }
}

abstract class _Loader {
  void load();
  bool get canLoad;
  bool get isLoading;
  double get loadTriggerDistance;
  void failedToLoad(dynamic payload);
  void updateLoadState(bool hasData, bool hasMoreData);
  void loadSuccessfully(bool hasData, bool hasMoreData);
}
