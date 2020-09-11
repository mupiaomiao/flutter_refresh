part of 'refresh_control.dart';

abstract class RefreshIndicatorDelegate {
  const RefreshIndicatorDelegate();

  double get refreshIndicatorExtent;
  double get inactiveIndicatorExtent;
  double get refreshTriggerPullDistance;

  Widget buildInactiveIndicator(BuildContext context,
      BoxConstraints constraints, double percentageComplete);
  Widget buildDragIndicator(BuildContext context, double pulledExtent,
      BoxConstraints constraints, double percentageComplete);
  Widget buildArmedIndicator(BuildContext context, double pulledExtent,
      BoxConstraints constraints, double percentageComplete);
  Widget buildRefreshIndicator(BuildContext context, BoxConstraints constraints,
      double percentageComplete);
  Widget buildSuccessIndicator(BuildContext context, double pulledExtent,
      BoxConstraints constraints, double percentageComplete, dynamic payload);
  Widget buildFailureIndicator(BuildContext context, double pulledExtent,
      BoxConstraints constraints, double percentageComplete, dynamic payload);

  Widget build(
    BuildContext context,
    RefreshIndicatorState refreshState,
    double pulledExtent,
    BoxConstraints constraints,
    double percentageComplete,
    bool hasError,
    dynamic success,
    dynamic failure,
    Widget child,
  ) {
    return child;
  }

  @protected
  @nonVirtual
  Widget buildIndicator({
    BuildContext context,
    RefreshIndicatorState refreshState,
    double pulledExtent,
    BoxConstraints constraints,
    double percentageComplete,
    bool hasError,
    dynamic success,
    dynamic failure,
  }) {
    assert(refreshState != null);
    Widget child;
    final percentageComplete = pulledExtent / refreshTriggerPullDistance;
    switch (refreshState) {
      case RefreshIndicatorState.inactive:
        child =
            buildInactiveIndicator(context, constraints, percentageComplete);
        break;
      case RefreshIndicatorState.drag:
        child = buildDragIndicator(
            context, pulledExtent, constraints, percentageComplete);
        break;
      case RefreshIndicatorState.armed:
        child = buildArmedIndicator(
            context, pulledExtent, constraints, percentageComplete);
        break;
      case RefreshIndicatorState.refresh:
        child = buildRefreshIndicator(context, constraints, percentageComplete);
        break;
      case RefreshIndicatorState.done:
        if (hasError) {
          child = buildFailureIndicator(
              context, pulledExtent, constraints, percentageComplete, failure);
        } else {
          child = buildSuccessIndicator(
              context, pulledExtent, constraints, percentageComplete, success);
        }
        break;
      default:
        child = Container();
        break;
    }
    return build(
      context,
      refreshState,
      pulledExtent,
      constraints,
      percentageComplete,
      hasError,
      success,
      failure,
      child,
    );
  }
}

const double kRefreshIndicatorExtent = 30.0;
const double kInactiveIndicatorExtent = 0.0;
const double kActivityIndicatorMargin = 16.0;
const double kRefreshTriggerPullDistance = 60.0;

class _RefreshIndicatorDelegate extends RefreshIndicatorDelegate {
  const _RefreshIndicatorDelegate();

  final double refreshIndicatorExtent = kRefreshIndicatorExtent;
  final double inactiveIndicatorExtent = kInactiveIndicatorExtent;
  final double refreshTriggerPullDistance = kRefreshTriggerPullDistance;

  @override
  Widget build(
    BuildContext context,
    RefreshIndicatorState refreshState,
    double pulledExtent,
    BoxConstraints constraints,
    double percentageComplete,
    bool hasError,
    dynamic success,
    dynamic failure,
    Widget child,
  ) {
    double top = kActivityIndicatorMargin +
        inactiveIndicatorExtent -
        refreshIndicatorExtent;
    if (percentageComplete >= 1 ||
        refreshState == RefreshIndicatorState.done ||
        refreshState == RefreshIndicatorState.refresh) {
      top += refreshIndicatorExtent;
    } else {
      top += percentageComplete * refreshIndicatorExtent;
    }
    return Center(
      child: Stack(
        overflow: Overflow.visible,
        children: <Widget>[
          Positioned(
            top: top,
            left: 0.0,
            right: 0.0,
            child: child,
          ),
        ],
      ),
    );
  }

  @override
  Widget buildInactiveIndicator(BuildContext context,
      BoxConstraints constraints, double percentageComplete) {
    return Container(constraints: constraints);
  }

  @override
  Widget buildDragIndicator(BuildContext context, double pulledExtent,
      BoxConstraints constraints, double percentageComplete) {
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
              width: 12,
              height: 12,
              child: CircularProgressIndicator(
                strokeWidth: 1.5,
                value: percentageComplete * 0.9,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 5),
              child: Text(
                '下拉刷新',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.black87,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget buildArmedIndicator(BuildContext context, double pulledExtent,
      BoxConstraints constraints, double percentageComplete) {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 12,
            height: 12,
            child: CircularProgressIndicator(
              value: 0.9,
              strokeWidth: 1.5,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 5),
            child: Text(
              '释放刷新',
              style: TextStyle(
                fontSize: 12,
                color: Colors.black87,
              ),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget buildRefreshIndicator(BuildContext context, BoxConstraints constraints,
      double percentageComplete) {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 12,
            height: 12,
            child: CircularProgressIndicator(
              strokeWidth: 1.5,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 5),
            child: Text(
              '正在刷新',
              style: TextStyle(
                fontSize: 12,
                color: Colors.black87,
              ),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget buildSuccessIndicator(BuildContext context, double pulledExtent,
      BoxConstraints constraints, double percentageComplete, dynamic payload) {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle,
            size: 15,
            color: Theme.of(context).primaryColor,
          ),
          Padding(
            padding: EdgeInsets.only(left: 5),
            child: Text(
              '刷新成功',
              style: TextStyle(
                fontSize: 12,
                color: Colors.black87,
              ),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget buildFailureIndicator(BuildContext context, double pulledExtent,
      BoxConstraints constraints, double percentageComplete, dynamic payload) {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.error,
            size: 15,
            color: Colors.red,
          ),
          Padding(
            padding: EdgeInsets.only(left: 5),
            child: Text(
              '刷新失败',
              style: TextStyle(
                fontSize: 12,
                color: Colors.black87,
              ),
            ),
          )
        ],
      ),
    );
  }
}
