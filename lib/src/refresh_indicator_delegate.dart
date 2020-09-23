part of 'refresh_control.dart';

typedef Widget InactiveIndicatorBuilder(
  BuildContext context,
  BoxConstraints constraints,
  double pulledExtent,
  RefreshIndicatorDelegate delegate,
);
typedef Widget DragIndicatorBuilder(
  BuildContext context,
  BoxConstraints constraints,
  double pulledExtent,
  RefreshIndicatorDelegate delegate,
);
typedef Widget ArmedIndicatorBuilder(
  BuildContext context,
  BoxConstraints constraints,
  double pulledExtent,
  RefreshIndicatorDelegate delegate,
);
typedef Widget RefreshIndicatorBuilder(
  BuildContext context,
  BoxConstraints constraints,
  double pulledExtent,
  RefreshIndicatorDelegate delegate,
);
typedef Widget SuccessIndicatorBuilder(
  BuildContext context,
  BoxConstraints constraints,
  double pulledExtent,
  RefreshIndicatorDelegate delegate,
  dynamic payload,
);
typedef Widget FailureIndicatorBuilder(
  BuildContext context,
  BoxConstraints constraints,
  double pulledExtent,
  RefreshIndicatorDelegate delegate,
  dynamic payload,
);
typedef Widget RefreshIndicatorWrapper(
  BuildContext context,
  BoxConstraints constraints,
  double pulledExtent,
  RefreshIndicatorMode refreshState,
  RefreshIndicatorDelegate delegate,
  Widget child,
);

const int kSuccessIndicatorDuration = 500;
const int kFailureIndicatorDuration = 1500;
const double kRefreshIndicatorSize = 12.0;
const double kRefreshIndicatorExtent = 30.0;
const double kRefreshTriggerPullDistance = 60.0;
const Color kRefreshIndicatorColor = Colors.white;
const TextStyle kRefreshTextStyle =
    TextStyle(color: Colors.white, fontSize: 12);
const TextStyle kRefreshSuccessTextStyle =
    TextStyle(color: Colors.white, fontSize: 12);
const TextStyle kRefreshFailureTextStyle =
    TextStyle(color: Colors.redAccent, fontSize: 12);
const IconThemeData kRefreshSuccessIconTheme =
    IconThemeData(color: Colors.white, size: 15);
const IconThemeData kRefreshFailureIconTheme =
    IconThemeData(color: Colors.redAccent, size: 15);

class RefreshIndicatorDelegate {
  const RefreshIndicatorDelegate({
    this.dragIndicatorBuilder = _buildDragIndicator,
    this.armedIndicatorBuilder = _buildArmedIndicator,
    this.refreshIndicatorBuilder = _buildRefreshIndicator,
    this.successIndicatorBuilder = _buildSuccessIndicator,
    this.failureIndicatorBuilder = _buildFailureIndicator,
    this.inactiveIndicatorBuilder = _buildInactiveIndicator,
    this.refreshIndicatorWrapper = _refreshIndicatorWrapper,
    this.textStyle = kRefreshTextStyle,
    this.successDuration = kSuccessIndicatorDuration,
    this.failureDuration = kFailureIndicatorDuration,
    this.successTextStyle = kRefreshSuccessTextStyle,
    this.failureTextStyle = kRefreshFailureTextStyle,
    this.successIconTheme = kRefreshSuccessIconTheme,
    this.failureIconTheme = kRefreshFailureIconTheme,
    this.refreshIndicatorSize = kRefreshIndicatorSize,
    this.refreshIndicatorColor = kRefreshIndicatorColor,
    this.refreshIndicatorExtent = kRefreshIndicatorExtent,
    this.refreshTriggerPullDistance = kRefreshTriggerPullDistance,
  })  : assert(dragIndicatorBuilder != null),
        assert(armedIndicatorBuilder != null),
        assert(refreshIndicatorBuilder != null),
        assert(successIndicatorBuilder != null),
        assert(failureIndicatorBuilder != null),
        assert(inactiveIndicatorBuilder != null),
        assert(refreshIndicatorWrapper != null),
        assert(textStyle != null),
        assert(successDuration != null),
        assert(successDuration >= 0),
        assert(failureDuration != null),
        assert(failureDuration >= 0),
        assert(successTextStyle != null),
        assert(failureTextStyle != null),
        assert(successIconTheme != null),
        assert(failureIconTheme != null),
        assert(refreshIndicatorSize != null),
        assert(refreshIndicatorSize > 0.0),
        assert(refreshIndicatorColor != null),
        assert(refreshIndicatorExtent != null),
        assert(refreshIndicatorExtent > 0.0),
        assert(refreshTriggerPullDistance != null),
        assert(refreshTriggerPullDistance >= refreshIndicatorExtent);

  /// 成功提示显示时长，单位：ms
  final int successDuration;

  /// 失败提示显示时长，单位：ms
  final int failureDuration;

  /// 刷新指示器显示高度
  final double refreshIndicatorExtent;

  /// 刷新触发高度
  final double refreshTriggerPullDistance;

  /// 下拉指示器
  final DragIndicatorBuilder dragIndicatorBuilder;

  /// 释放刷新指示器
  final ArmedIndicatorBuilder armedIndicatorBuilder;

  /// 刷新指示器
  final RefreshIndicatorBuilder refreshIndicatorBuilder;

  /// 刷新成功指示器
  final SuccessIndicatorBuilder successIndicatorBuilder;

  /// 刷新失败指示器
  final FailureIndicatorBuilder failureIndicatorBuilder;

  /// 指示器包装器
  final RefreshIndicatorWrapper refreshIndicatorWrapper;

  /// 未激活刷新指示器
  final InactiveIndicatorBuilder inactiveIndicatorBuilder;

  /// Style
  final TextStyle textStyle;
  final TextStyle successTextStyle;
  final TextStyle failureTextStyle;
  final double refreshIndicatorSize;
  final Color refreshIndicatorColor;
  final IconThemeData successIconTheme;
  final IconThemeData failureIconTheme;

  Widget _buildIndicator({
    BuildContext context,
    BoxConstraints constraints,
    double pulledExtent,
    RefreshIndicatorMode refreshState,
    dynamic success,
    dynamic failure,
  }) {
    assert(refreshState != null);
    Widget child;
    switch (refreshState) {
      case RefreshIndicatorMode.drag:
        child = dragIndicatorBuilder(
          context,
          constraints,
          pulledExtent,
          this,
        );
        break;
      case RefreshIndicatorMode.armed:
        child = armedIndicatorBuilder(
          context,
          constraints,
          pulledExtent,
          this,
        );
        break;
      case RefreshIndicatorMode.refresh:
        child = refreshIndicatorBuilder(
          context,
          constraints,
          pulledExtent,
          this,
        );
        break;
      case RefreshIndicatorMode.inactive:
        child = inactiveIndicatorBuilder(
          context,
          constraints,
          pulledExtent,
          this,
        );
        break;
      case RefreshIndicatorMode.success:
        child = successIndicatorBuilder(
          context,
          constraints,
          pulledExtent,
          this,
          success,
        );
        break;
      case RefreshIndicatorMode.failure:
        child = failureIndicatorBuilder(
          context,
          constraints,
          pulledExtent,
          this,
          failure,
        );
        break;
    }
    return refreshIndicatorWrapper(
      context,
      constraints,
      pulledExtent,
      refreshState,
      this,
      child,
    );
  }
}

Widget _refreshIndicatorWrapper(
  BuildContext context,
  BoxConstraints constraints,
  double pulledExtent,
  RefreshIndicatorMode refreshState,
  RefreshIndicatorDelegate delegate,
  Widget child,
) {
  return Container(
    constraints: constraints,
    child: Stack(
      overflow: Overflow.visible,
      children: <Widget>[
        Positioned(
          left: 0.0,
          right: 0.0,
          bottom: 0.0,
          child: Container(
            child: Center(child: child),
            height: delegate.refreshIndicatorExtent,
          ),
        ),
      ],
    ),
  );
}

Widget _buildInactiveIndicator(
  BuildContext context,
  BoxConstraints constraints,
  double pulledExtent,
  RefreshIndicatorDelegate delegate,
) {
  return Container();
}

Widget _buildDragIndicator(
  BuildContext context,
  BoxConstraints constraints,
  double pulledExtent,
  RefreshIndicatorDelegate delegate,
) {
  final percentageComplete = pulledExtent / delegate.refreshTriggerPullDistance;
  const Curve opacityCurve = Interval(0.0, 0.35, curve: Curves.easeInOut);
  return Opacity(
    opacity: opacityCurve.transform(percentageComplete),
    child: Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: delegate.refreshIndicatorSize,
            height: delegate.refreshIndicatorSize,
            child: CircularProgressIndicator(
              strokeWidth: 1.5,
              value: percentageComplete * 0.9,
              valueColor:
                  AlwaysStoppedAnimation<Color>(delegate.refreshIndicatorColor),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 5),
            child: Text('下拉刷新', style: delegate.textStyle),
          )
        ],
      ),
    ),
  );
}

Widget _buildArmedIndicator(
  BuildContext context,
  BoxConstraints constraints,
  double pulledExtent,
  RefreshIndicatorDelegate delegate,
) {
  return Center(
    child: Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: delegate.refreshIndicatorSize,
          height: delegate.refreshIndicatorSize,
          child: CircularProgressIndicator(
            value: 0.9,
            strokeWidth: 1.5,
            valueColor:
                AlwaysStoppedAnimation<Color>(delegate.refreshIndicatorColor),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(left: 5),
          child: Text('释放刷新', style: delegate.textStyle),
        )
      ],
    ),
  );
}

Widget _buildRefreshIndicator(
  BuildContext context,
  BoxConstraints constraints,
  double pulledExtent,
  RefreshIndicatorDelegate delegate,
) {
  return Center(
    child: Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: delegate.refreshIndicatorSize,
          height: delegate.refreshIndicatorSize,
          child: CircularProgressIndicator(
            strokeWidth: 1.5,
            valueColor:
                AlwaysStoppedAnimation<Color>(delegate.refreshIndicatorColor),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(left: 5),
          child: Text('正在刷新', style: delegate.textStyle),
        )
      ],
    ),
  );
}

Widget _buildSuccessIndicator(
  BuildContext context,
  BoxConstraints constraints,
  double pulledExtent,
  RefreshIndicatorDelegate delegate,
  dynamic payload,
) {
  return Center(
    child: Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        IconTheme(
          data: delegate.successIconTheme,
          child: Icon(Icons.check_circle),
        ),
        Padding(
          padding: EdgeInsets.only(left: 5),
          child: Text('刷新成功', style: delegate.successTextStyle),
        )
      ],
    ),
  );
}

Widget _buildFailureIndicator(
  BuildContext context,
  BoxConstraints constraints,
  double pulledExtent,
  RefreshIndicatorDelegate delegate,
  dynamic payload,
) {
  return Center(
    child: Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        IconTheme(
          child: Icon(Icons.error),
          data: delegate.failureIconTheme,
        ),
        Padding(
          padding: EdgeInsets.only(left: 5),
          child: Text('刷新失败', style: delegate.failureTextStyle),
        )
      ],
    ),
  );
}
