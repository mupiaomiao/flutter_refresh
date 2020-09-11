import 'dart:math';
import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';

class SliverRefresh extends SingleChildRenderObjectWidget {
  const SliverRefresh({
    Key key,
    Widget child,
    this.refreshIndicatorLayoutExtent,
    this.inactiveIndicatorLayoutExtent,
    this.margin = const EdgeInsets.all(0),
  })  : assert(inactiveIndicatorLayoutExtent != null),
        assert(inactiveIndicatorLayoutExtent >= 0),
        assert(refreshIndicatorLayoutExtent != null),
        assert(refreshIndicatorLayoutExtent >= 0.0),
        assert(margin != null),
        super(key: key, child: child);

  final EdgeInsetsGeometry margin;
  final double refreshIndicatorLayoutExtent;
  final double inactiveIndicatorLayoutExtent;

  @override
  _RenderSliverRefresh createRenderObject(BuildContext context) {
    return _RenderSliverRefresh(
      margin: margin.resolve(TextDirection.ltr),
      refreshIndicatorLayoutExtent: refreshIndicatorLayoutExtent,
      inactiveIndicatorLayoutExtent: inactiveIndicatorLayoutExtent,
    );
  }

  @override
  void updateRenderObject(
      BuildContext context, covariant _RenderSliverRefresh renderObject) {
    renderObject
      ..margin = margin.resolve(TextDirection.ltr)
      ..refreshIndicatorLayoutExtent = refreshIndicatorLayoutExtent
      ..inactiveIndicatorLayoutExtent = inactiveIndicatorLayoutExtent;
  }
}

class _RenderSliverRefresh extends RenderSliver
    with RenderObjectWithChildMixin<RenderBox> {
  _RenderSliverRefresh({
    RenderBox child,
    @required EdgeInsets margin,
    @required double refreshIndicatorLayoutExtent,
    @required double inactiveIndicatorLayoutExtent,
  })  : assert(inactiveIndicatorLayoutExtent != null),
        assert(inactiveIndicatorLayoutExtent >= 0.0),
        assert(refreshIndicatorLayoutExtent != null),
        assert(refreshIndicatorLayoutExtent >= 0.0),
        assert(margin != null),
        layoutExtentOffsetCompensation =
            margin.vertical + inactiveIndicatorLayoutExtent,
        _inactiveIndicatorLayoutExtent = inactiveIndicatorLayoutExtent,
        _refreshIndicatorLayoutExtent = refreshIndicatorLayoutExtent,
        _margin = margin {
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
    layoutExtentOffsetCompensation = margin.vertical + value;
    markNeedsLayout();
  }

  EdgeInsets _margin;
  EdgeInsets get margin => _margin;
  set margin(EdgeInsets value) {
    assert(value != null);
    if (value == _margin) return;
    _margin = value;
    layoutExtentOffsetCompensation =
        value.vertical + inactiveIndicatorLayoutExtent;
    markNeedsLayout();
  }

  double layoutExtentOffsetCompensation = 0.0;

  @override
  void performLayout() {
    final SliverConstraints constraints = this.constraints;
    assert(constraints.axisDirection == AxisDirection.down);
    assert(constraints.growthDirection == GrowthDirection.forward);

    final double layoutExtent = margin.vertical +
        refreshIndicatorLayoutExtent +
        inactiveIndicatorLayoutExtent;
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
        maxExtent: layoutExtent - margin.vertical + overscrolledExtent,
        crossAxisExtent: constraints.crossAxisExtent - margin.horizontal,
      ),
      parentUsesSize: true,
    );
    geometry = SliverGeometry(
      scrollExtent: layoutExtent,
      paintOrigin: -overscrolledExtent - constraints.scrollOffset + margin.top,
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
      print(
          'offset: ${constraints.scrollOffset}, overlap: ${constraints.overlap}, height: ${child.size.height}');
      paintContext.paintChild(
          child, offset.translate(margin.left, constraints.scrollOffset));
    }
  }

  @override
  void applyPaintTransform(RenderObject child, Matrix4 transform) {}
}
