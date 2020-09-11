import 'dart:math';
import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';

class SliverRefresh extends SingleChildRenderObjectWidget {
  const SliverRefresh({
    Key key,
    Widget child,
    this.refreshIndicatorLayoutExtent,
    this.inactiveIndicatorLayoutExtent,
  })  : assert(inactiveIndicatorLayoutExtent != null),
        assert(inactiveIndicatorLayoutExtent >= 0),
        assert(refreshIndicatorLayoutExtent != null),
        assert(refreshIndicatorLayoutExtent >= 0.0),
        super(key: key, child: child);

  final double refreshIndicatorLayoutExtent;
  final double inactiveIndicatorLayoutExtent;

  @override
  _RenderSliverRefresh createRenderObject(BuildContext context) {
    return _RenderSliverRefresh(
      refreshIndicatorLayoutExtent: refreshIndicatorLayoutExtent,
      inactiveIndicatorLayoutExtent: inactiveIndicatorLayoutExtent,
    );
  }

  @override
  void updateRenderObject(
      BuildContext context, covariant _RenderSliverRefresh renderObject) {
    renderObject
      ..refreshIndicatorLayoutExtent = refreshIndicatorLayoutExtent
      ..inactiveIndicatorLayoutExtent = inactiveIndicatorLayoutExtent;
  }
}

class _RenderSliverRefresh extends RenderSliver
    with RenderObjectWithChildMixin<RenderBox> {
  _RenderSliverRefresh({
    RenderBox child,
    @required double refreshIndicatorLayoutExtent,
    @required double inactiveIndicatorLayoutExtent,
  })  : assert(inactiveIndicatorLayoutExtent != null),
        assert(inactiveIndicatorLayoutExtent >= 0.0),
        assert(refreshIndicatorLayoutExtent != null),
        assert(refreshIndicatorLayoutExtent >= 0.0),
        _refreshIndicatorLayoutExtent = refreshIndicatorLayoutExtent,
        layoutExtentOffsetCompensation = inactiveIndicatorLayoutExtent,
        _inactiveIndicatorLayoutExtent = inactiveIndicatorLayoutExtent {
    this.child = child;
  }

  double get refreshIndicatorLayoutExtent => _refreshIndicatorLayoutExtent;
  double _refreshIndicatorLayoutExtent;
  set refreshIndicatorLayoutExtent(double value) {
    assert(value != null);
    assert(value >= 0.0);
    if (value == _refreshIndicatorLayoutExtent) return;
    _refreshIndicatorLayoutExtent = value;
    markNeedsLayout();
  }

  double get inactiveIndicatorLayoutExtent => _inactiveIndicatorLayoutExtent;
  double _inactiveIndicatorLayoutExtent;
  set inactiveIndicatorLayoutExtent(double value) {
    assert(value != null);
    assert(value >= 0.0);
    if (value == _inactiveIndicatorLayoutExtent) return;
    _inactiveIndicatorLayoutExtent = value;
    layoutExtentOffsetCompensation = value;
    markNeedsLayout();
  }

  double layoutExtentOffsetCompensation = 0.0;

  @override
  void performLayout() {
    final SliverConstraints constraints = this.constraints;
    assert(constraints.axisDirection == AxisDirection.down);
    assert(constraints.growthDirection == GrowthDirection.forward);

    final double layoutExtent =
        refreshIndicatorLayoutExtent + inactiveIndicatorLayoutExtent;
    if (layoutExtent != layoutExtentOffsetCompensation) {
      geometry = SliverGeometry(
        scrollOffsetCorrection: layoutExtent - layoutExtentOffsetCompensation,
      );
      layoutExtentOffsetCompensation = layoutExtent;
      return;
    }

    final double overscrolledExtent =
        constraints.overlap < 0.0 ? constraints.overlap.abs() : 0.0;
    child.layout(
      constraints.asBoxConstraints(
        maxExtent: layoutExtent + overscrolledExtent,
        crossAxisExtent: constraints.crossAxisExtent,
      ),
      parentUsesSize: true,
    );
    geometry = SliverGeometry(
      scrollExtent: layoutExtent,
      paintOrigin: -overscrolledExtent - constraints.scrollOffset,
      paintExtent: max(
        0.0,
        max(child.size.height, layoutExtent) - constraints.scrollOffset,
      ),
      maxPaintExtent: max(
        0.0,
        max(child.size.height, layoutExtent) - constraints.scrollOffset,
      ),
      layoutExtent: max(
        0.0,
        layoutExtent - constraints.scrollOffset,
      ),
    );
  }

  void printConstraints() {
    final stringBuffer = StringBuffer();
    stringBuffer.writeln('axisDirection: ${constraints.axisDirection}');
    stringBuffer.writeln('growthDirection: ${constraints.growthDirection}');
    stringBuffer
        .writeln('userScrollDirection: ${constraints.userScrollDirection}');
    stringBuffer.writeln('scrollOffset: ${constraints.scrollOffset}');
    stringBuffer
        .writeln('precedingScrollExtent: ${constraints.precedingScrollExtent}');
    stringBuffer.writeln('overlap: ${constraints.overlap}');
    stringBuffer
        .writeln('remainingPaintExtent: ${constraints.remainingPaintExtent}');
    stringBuffer.writeln('crossAxisExtent: ${constraints.crossAxisExtent}');
    stringBuffer
        .writeln('crossAxisDirection: ${constraints.crossAxisDirection}');
    stringBuffer.writeln(
        'viewportMainAxisExtent: ${constraints.viewportMainAxisExtent}');
    stringBuffer
        .writeln('remainingCacheExtent: ${constraints.remainingCacheExtent}');
    stringBuffer.writeln('cacheOrigin: ${constraints.cacheOrigin}');
    print(stringBuffer.toString());
  }

  @override
  void paint(PaintingContext paintContext, Offset offset) {
    printConstraints();
    print('offset: (${offset.dx}, ${offset.dy})');
    print('\r\n\r\n');
    if (constraints.overlap < 0.0 ||
        constraints.scrollOffset + child.size.height > 0) {
      paintContext.paintChild(child, offset);
    }
  }

  @override
  void applyPaintTransform(RenderObject child, Matrix4 transform) {}
}
