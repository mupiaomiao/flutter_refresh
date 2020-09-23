part of 'refresh_control.dart';

typedef Widget IdleIndicatorBuilder(
  BuildContext context,
  LoadIndicatorDelegate delegate,
);
typedef Widget LoadIndicatorBuilder(
  BuildContext context,
  LoadIndicatorDelegate delegate,
);
typedef Widget NoDataIndicatorBuilder(
  BuildContext context,
  LoadIndicatorDelegate delegate,
);
typedef Widget NoMoreDataIndicatorBuilder(
  BuildContext context,
  LoadIndicatorDelegate delegate,
);
typedef Widget ErrorIndicatorBuilder(
  BuildContext context,
  LoadIndicatorDelegate delegate,
  dynamic error,
);
typedef Widget LoadIndicatorWrapper(
  BuildContext context,
  LoadIndicatorMode loadState,
  LoadIndicatorDelegate delegate,
  Widget child,
);

const double kLoadIndicatorSize = 12.0;
const double kLoadTriggerDistance = 50.0;
const Color kLoadIndicatorColor = Colors.white;
const TextStyle kLoadTextStyle = TextStyle(
  fontSize: 12,
  color: Colors.white,
);
const TextStyle kLoadErrorTextStyle = TextStyle(
  fontSize: 12,
  color: Colors.redAccent,
);
const IconThemeData kLoadErrorIconTheme = IconThemeData(
  size: 15,
  color: Colors.redAccent,
);

class LoadIndicatorDelegate {
  const LoadIndicatorDelegate({
    this.textStyle = kLoadTextStyle,
    this.errorTextStyle = kLoadErrorTextStyle,
    this.errorIconTheme = kLoadErrorIconTheme,
    this.loadIndicatorSize = kLoadIndicatorSize,
    this.loadIndicatorColor = kLoadIndicatorColor,
    this.loadTriggerDistance = kLoadTriggerDistance,
    this.loadIndicatorWrapper = _loadIndicatorWrapper,
    this.idleIndicatorBuilder = _buildIdleIndicator,
    this.loadIndicatorBuilder = _buildLoadIndicator,
    this.errorIndicatorBuilder = _buildErrorIndicator,
    this.noDataIndicatorBuilder = _buildNoDataIndicator,
    this.noMoreDataIndicatorBuilder = _buildNoMoreDataIndicator,
  })  : assert(textStyle != null),
        assert(errorTextStyle != null),
        assert(errorIconTheme != null),
        assert(loadIndicatorSize != null),
        assert(loadIndicatorSize > 0.0),
        assert(loadIndicatorColor != null),
        assert(loadTriggerDistance != null),
        assert(loadTriggerDistance > 0.0),
        assert(loadIndicatorWrapper != null),
        assert(idleIndicatorBuilder != null),
        assert(loadIndicatorBuilder != null),
        assert(errorIndicatorBuilder != null),
        assert(noDataIndicatorBuilder != null),
        assert(noMoreDataIndicatorBuilder != null);

  final TextStyle textStyle;
  final double loadIndicatorSize;
  final Color loadIndicatorColor;
  final TextStyle errorTextStyle;
  final double loadTriggerDistance;
  final IconThemeData errorIconTheme;

  final LoadIndicatorWrapper loadIndicatorWrapper;
  final IdleIndicatorBuilder idleIndicatorBuilder;
  final LoadIndicatorBuilder loadIndicatorBuilder;
  final ErrorIndicatorBuilder errorIndicatorBuilder;
  final NoDataIndicatorBuilder noDataIndicatorBuilder;
  final NoMoreDataIndicatorBuilder noMoreDataIndicatorBuilder;

  Widget _buildIndicator(
      BuildContext context, LoadIndicatorMode loadState, dynamic error) {
    assert(loadState != null);
    Widget child;
    switch (loadState) {
      case LoadIndicatorMode.idle:
        child = idleIndicatorBuilder(context, this);
        break;
      case LoadIndicatorMode.load:
        child = loadIndicatorBuilder(context, this);
        break;
      case LoadIndicatorMode.noData:
        child = noDataIndicatorBuilder(context, this);
        break;
      case LoadIndicatorMode.noMoreData:
        child = noMoreDataIndicatorBuilder(context, this);
        break;
      case LoadIndicatorMode.error:
        child = errorIndicatorBuilder(context, this, error);
        break;
    }
    return loadIndicatorWrapper(context, loadState, this, child);
  }
}

Widget _loadIndicatorWrapper(
  BuildContext context,
  LoadIndicatorMode loadState,
  LoadIndicatorDelegate delegate,
  Widget child,
) {
  return Container(
    child: Center(child: child),
    padding: EdgeInsets.symmetric(vertical: 8),
  );
}

Widget _buildIdleIndicator(
  BuildContext context,
  LoadIndicatorDelegate delegate,
) {
  return Text("点击加载更多", style: delegate.textStyle);
}

Widget _buildLoadIndicator(
  BuildContext context,
  LoadIndicatorDelegate delegate,
) {
  return Row(
    mainAxisSize: MainAxisSize.min,
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      SizedBox(
        width: delegate.loadIndicatorSize,
        height: delegate.loadIndicatorSize,
        child: CircularProgressIndicator(
          strokeWidth: 1.5,
          valueColor:
              AlwaysStoppedAnimation<Color>(delegate.loadIndicatorColor),
        ),
      ),
      Padding(
        padding: EdgeInsets.only(left: 5),
        child: Text("正在加载•••", style: delegate.textStyle),
      ),
    ],
  );
}

Widget _buildNoDataIndicator(
  BuildContext context,
  LoadIndicatorDelegate delegate,
) {
  return Text("暂无数据", style: delegate.textStyle);
}

Widget _buildNoMoreDataIndicator(
  BuildContext context,
  LoadIndicatorDelegate delegate,
) {
  return Text("没有更多数据了", style: delegate.textStyle);
}

Widget _buildErrorIndicator(
  BuildContext context,
  LoadIndicatorDelegate delegate,
  dynamic error,
) {
  return Row(
    mainAxisSize: MainAxisSize.min,
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      IconTheme(
        data: delegate.errorIconTheme,
        child: Icon(Icons.error),
      ),
      Padding(
        padding: EdgeInsets.only(left: 5),
        child: Text('加载失败，点击重新加载', style: delegate.errorTextStyle),
      )
    ],
  );
}
