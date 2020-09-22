part of 'refresh_control.dart';

abstract class RefreshIndicatorDelegate {
  const RefreshIndicatorDelegate();

  double get refreshIndicatorExtent;
  double get inactiveIndicatorExtent;
  double get refreshTriggerPullDistance;

  Widget buildInactiveIndicator(
      BuildContext context, BoxConstraints constraints);
  Widget buildDragIndicator(BuildContext context, double pulledExtent,
      BoxConstraints constraints, double percentageComplete);
  Widget buildArmedIndicator(BuildContext context, double pulledExtent,
      BoxConstraints constraints, double percentageComplete);
  Widget buildRefreshIndicator(
      BuildContext context, BoxConstraints constraints);
  Widget buildSuccessIndicator(BuildContext context, double pulledExtent,
      BoxConstraints constraints, double percentageComplete, dynamic payload);
  Widget buildFailureIndicator(BuildContext context, double pulledExtent,
      BoxConstraints constraints, double percentageComplete, dynamic payload);

  Widget wrapper(
    BuildContext context,
    RefreshIndicatorMode refreshState,
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

  Widget _buildIndicator({
    BuildContext context,
    RefreshIndicatorMode refreshState,
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
      case RefreshIndicatorMode.inactive:
        child = buildInactiveIndicator(context, constraints);
        break;
      case RefreshIndicatorMode.drag:
        child = buildDragIndicator(
            context, pulledExtent, constraints, percentageComplete);
        break;
      case RefreshIndicatorMode.armed:
        child = buildArmedIndicator(
            context, pulledExtent, constraints, percentageComplete);
        break;
      case RefreshIndicatorMode.refresh:
        child = buildRefreshIndicator(context, constraints);
        break;
      case RefreshIndicatorMode.done:
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
    return wrapper(
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

const double kRefreshIndicatorSize = 12.0;
const double kRefreshIndicatorExtent = 30.0;
const double kInactiveIndicatorExtent = 0.0;
const double kActivityIndicatorMargin = 16.0;
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

class DefaultRefreshIndicatorDelegate extends RefreshIndicatorDelegate {
  const DefaultRefreshIndicatorDelegate({
    this.textStyle = kRefreshTextStyle,
    this.successTextStyle = kRefreshSuccessTextStyle,
    this.failureTextStyle = kRefreshFailureTextStyle,
    this.successIconTheme = kRefreshSuccessIconTheme,
    this.failureIconTheme = kRefreshFailureIconTheme,
    this.refreshIndicatorSize = kRefreshIndicatorSize,
    this.refreshIndicatorColor = kRefreshIndicatorColor,
  })  : assert(textStyle != null),
        assert(successTextStyle != null),
        assert(failureTextStyle != null),
        assert(successIconTheme != null),
        assert(failureIconTheme != null),
        assert(refreshIndicatorSize != null),
        assert(refreshIndicatorSize > 0.0),
        assert(refreshIndicatorColor != null);

  final TextStyle textStyle;
  final TextStyle successTextStyle;
  final TextStyle failureTextStyle;
  final double refreshIndicatorSize;
  final Color refreshIndicatorColor;
  final IconThemeData successIconTheme;
  final IconThemeData failureIconTheme;
  final double refreshIndicatorExtent = kRefreshIndicatorExtent;
  final double inactiveIndicatorExtent = kInactiveIndicatorExtent;
  final double refreshTriggerPullDistance = kRefreshTriggerPullDistance;

  @override
  Widget wrapper(
    BuildContext context,
    RefreshIndicatorMode refreshState,
    double pulledExtent,
    BoxConstraints constraints,
    double percentageComplete,
    bool hasError,
    dynamic success,
    dynamic failure,
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
              child: Center(
                child: child,
              ),
              height: refreshIndicatorExtent,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget buildInactiveIndicator(
      BuildContext context, BoxConstraints constraints) {
    return Container();
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
              width: refreshIndicatorSize,
              height: refreshIndicatorSize,
              child: CircularProgressIndicator(
                strokeWidth: 1.5,
                value: percentageComplete * 0.9,
                valueColor:
                    AlwaysStoppedAnimation<Color>(refreshIndicatorColor),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 5),
              child: Text('下拉刷新', style: textStyle),
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
            width: refreshIndicatorSize,
            height: refreshIndicatorSize,
            child: CircularProgressIndicator(
              value: 0.9,
              strokeWidth: 1.5,
              valueColor: AlwaysStoppedAnimation<Color>(refreshIndicatorColor),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 5),
            child: Text('释放刷新', style: textStyle),
          )
        ],
      ),
    );
  }

  @override
  Widget buildRefreshIndicator(
      BuildContext context, BoxConstraints constraints) {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: refreshIndicatorSize,
            height: refreshIndicatorSize,
            child: CircularProgressIndicator(
              strokeWidth: 1.5,
              valueColor: AlwaysStoppedAnimation<Color>(refreshIndicatorColor),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 5),
            child: Text('正在刷新', style: textStyle),
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
          IconTheme(
            data: successIconTheme,
            child: Icon(Icons.check_circle),
          ),
          Padding(
            padding: EdgeInsets.only(left: 5),
            child: Text('刷新成功', style: successTextStyle),
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
          IconTheme(
            data: failureIconTheme,
            child: Icon(Icons.error),
          ),
          Padding(
            padding: EdgeInsets.only(left: 5),
            child: Text('刷新失败', style: failureTextStyle),
          )
        ],
      ),
    );
  }
}
