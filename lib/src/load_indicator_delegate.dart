part of 'refresh_control.dart';

abstract class LoadIndicatorDelegate {
  const LoadIndicatorDelegate();

  Widget buildIdleIndicator(BuildContext context);
  Widget buildLoadIndicator(BuildContext context);
  Widget buildNoDataIndicator(BuildContext context);
  Widget buildNoMoreDataIndicator(BuildContext context);
  Widget buildErrorIndicator(BuildContext context, dynamic error);

  Widget wrapper(BuildContext context, LoadIndicatorMode mode, dynamic error,
      Widget child) {
    return child;
  }

  Widget _buildIndicator(
      BuildContext context, LoadIndicatorMode mode, dynamic error) {
    assert(mode != null);
    Widget child;
    switch (mode) {
      case LoadIndicatorMode.load:
        child = buildLoadIndicator(context);
        break;
      case LoadIndicatorMode.noData:
        child = buildNoDataIndicator(context);
        break;
      case LoadIndicatorMode.error:
        child = buildErrorIndicator(context, error);
        break;
      case LoadIndicatorMode.noMoreData:
        child = buildNoMoreDataIndicator(context);
        break;
      default:
        child = buildIdleIndicator(context);
        break;
    }
    return wrapper(context, mode, error, child);
  }
}

const double kLoadIndicatorSize = 12.0;
const Color kLoadIndicatorColor = Colors.white;
const TextStyle kLoadTextStyle = TextStyle(color: Colors.white, fontSize: 12);
const TextStyle kLoadFailureTextStyle =
    TextStyle(color: Colors.redAccent, fontSize: 12);
const IconThemeData kLoadFailureIconTheme =
    IconThemeData(color: Colors.redAccent, size: 15);

class DefaultLoadIndicatorDelegate extends LoadIndicatorDelegate {
  final TextStyle textStyle;
  final double loadIndicatorSize;
  final Color loadIndicatorColor;
  final TextStyle failureTextStyle;
  final IconThemeData failureIconTheme;

  const DefaultLoadIndicatorDelegate({
    this.textStyle = kLoadTextStyle,
    this.loadIndicatorSize = kLoadIndicatorSize,
    this.loadIndicatorColor = kLoadIndicatorColor,
    this.failureTextStyle = kLoadFailureTextStyle,
    this.failureIconTheme = kLoadFailureIconTheme,
  });

  @override
  Widget buildIdleIndicator(BuildContext context) {
    return Text("点击加载更多", style: textStyle);
  }

  @override
  Widget buildLoadIndicator(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: loadIndicatorSize,
          height: loadIndicatorSize,
          child: CircularProgressIndicator(
            strokeWidth: 1.5,
            valueColor: AlwaysStoppedAnimation<Color>(loadIndicatorColor),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(left: 5),
          child: Text("正在加载•••", style: textStyle),
        ),
      ],
    );
  }

  @override
  Widget buildNoDataIndicator(BuildContext context) {
    return Text("暂无数据", style: textStyle);
  }

  @override
  Widget buildNoMoreDataIndicator(BuildContext context) {
    return Text("没有更多数据了", style: textStyle);
  }

  @override
  Widget buildErrorIndicator(BuildContext context, dynamic error) {
    return Row(
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
          child: Text('加载失败，点击重新加载', style: failureTextStyle),
        )
      ],
    );
  }

  @override
  Widget wrapper(BuildContext context, LoadIndicatorMode mode, dynamic error,
      Widget child) {
    return Container(
      child: Center(child: child),
      padding: EdgeInsets.symmetric(vertical: 8),
    );
  }
}
