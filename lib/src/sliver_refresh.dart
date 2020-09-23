import 'dart:math';
import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';

class SliverRefresh extends SingleChildRenderObjectWidget {
  const SliverRefresh({
    Key key,
    Widget child,
    this.refreshIndicatorLayoutExtent,
  })  : assert(refreshIndicatorLayoutExtent != null),
        assert(refreshIndicatorLayoutExtent >= 0.0),
        super(key: key, child: child);

  final double refreshIndicatorLayoutExtent;

  @override
  _RenderSliverRefresh createRenderObject(BuildContext context) {
    return _RenderSliverRefresh(
      refreshIndicatorLayoutExtent: refreshIndicatorLayoutExtent,
    );
  }

  @override
  void updateRenderObject(
      BuildContext context, covariant _RenderSliverRefresh renderObject) {
    renderObject..refreshIndicatorLayoutExtent = refreshIndicatorLayoutExtent;
  }
}

class _RenderSliverRefresh extends RenderSliver
    with RenderObjectWithChildMixin<RenderBox> {
  _RenderSliverRefresh({
    RenderBox child,
    @required double refreshIndicatorLayoutExtent,
  })  : assert(refreshIndicatorLayoutExtent != null),
        assert(refreshIndicatorLayoutExtent >= 0.0),
        _refreshIndicatorLayoutExtent = refreshIndicatorLayoutExtent {
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

  double layoutExtentOffsetCompensation = 0.0;

  @override
  void performLayout() {
    final SliverConstraints constraints = this.constraints;
    assert(constraints.axisDirection == AxisDirection.down);
    assert(constraints.growthDirection == GrowthDirection.forward);

    final double layoutExtent = refreshIndicatorLayoutExtent;
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

  @override
  void paint(PaintingContext paintContext, Offset offset) {
    if (constraints.overlap < 0.0 ||
        constraints.scrollOffset + child.size.height > 0) {
      paintContext.paintChild(child, offset);
    }
  }

  @override
  void applyPaintTransform(RenderObject child, Matrix4 transform) {}
}
