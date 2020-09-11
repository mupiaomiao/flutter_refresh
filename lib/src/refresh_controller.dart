part of "refresh_control.dart";

class RefreshController {
  void startRefresh() {
    assert(_disposed == false);
    for (final callback in _startRefreshes) {
      try {
        callback();
      } catch (e) {}
    }
  }

  void dispose() {
    if (_disposed == false) {
      _disposed = true;
      _dragEnds.clear();
      _dragDowns.clear();
      _dragStarts.clear();
      _dragCancels.clear();
      _dragUpdates.clear();
      _startRefreshes.clear();
    }
  }

  @protected
  void onRefresh(void Function() listener) {
    assert(_disposed == false);
    if (listener != null) {
      _startRefreshes.add(listener);
    }
  }

  @protected
  void offRefresh(void Function() listener) {
    assert(_disposed == false);
    if (listener != null) {
      _startRefreshes.remove(listener);
    }
  }

  @protected
  void dragCancel() {
    assert(_disposed == false);
    for (final callback in _dragCancels) {
      try {
        callback();
      } catch (e) {}
    }
  }

  @protected
  void onDragCancel(void Function() listener) {
    assert(_disposed == false);
    if (listener != null) {
      _dragCancels.add(listener);
    }
  }

  @protected
  void offDragCancel(void Function() listener) {
    assert(_disposed == false);
    if (listener != null) {
      _dragCancels.remove(listener);
    }
  }

  @protected
  void dragEnd(DragEndDetails details) {
    assert(_disposed == false);
    for (final callback in _dragEnds) {
      try {
        callback(details);
      } catch (e) {}
    }
  }

  @protected
  void onDragEnd(void Function(DragEndDetails details) listener) {
    assert(_disposed == false);
    if (listener != null) {
      _dragEnds.add(listener);
    }
  }

  @protected
  void offDragEnd(void Function(DragEndDetails details) listener) {
    assert(_disposed == false);
    if (listener != null) {
      _dragEnds.remove(listener);
    }
  }

  @protected
  void dragDown(DragDownDetails details) {
    assert(_disposed == false);
    for (final callback in _dragDowns) {
      try {
        callback(details);
      } catch (e) {}
    }
  }

  @protected
  void onDragDown(void Function(DragDownDetails details) listener) {
    assert(_disposed == false);
    if (listener != null) {
      _dragDowns.add(listener);
    }
  }

  @protected
  void offDragDown(void Function(DragDownDetails details) listener) {
    assert(_disposed == false);
    if (listener != null) {
      _dragDowns.remove(listener);
    }
  }

  @protected
  void dragStart(DragStartDetails details) {
    assert(_disposed == false);
    for (final callback in _dragStarts) {
      try {
        callback(details);
      } catch (e) {}
    }
  }

  @protected
  void onDragStart(void Function(DragStartDetails details) listener) {
    assert(_disposed == false);
    if (listener != null) {
      _dragStarts.add(listener);
    }
  }

  @protected
  void offDragStart(void Function(DragStartDetails details) listener) {
    assert(_disposed == false);
    if (listener != null) {
      _dragStarts.remove(listener);
    }
  }

  @protected
  void dragUpdate(DragUpdateDetails details) {
    assert(_disposed == false);
    for (final callback in _dragUpdates) {
      try {
        callback(details);
      } catch (e) {}
    }
  }

  @protected
  void onDragUpdate(void Function(DragUpdateDetails details) listener) {
    assert(_disposed == false);
    if (listener != null) {
      _dragUpdates.add(listener);
    }
  }

  @protected
  void offDragUpdate(void Function(DragUpdateDetails details) listener) {
    assert(_disposed == false);
    if (listener != null) {
      _dragUpdates.remove(listener);
    }
  }

  bool _disposed = false;
  final _dragCancels = HashSet<void Function()>();
  final _startRefreshes = HashSet<void Function()>();
  final _dragEnds = HashSet<void Function(DragEndDetails details)>();
  final _dragDowns = HashSet<void Function(DragDownDetails details)>();
  final _dragStarts = HashSet<void Function(DragStartDetails details)>();
  final _dragUpdates = HashSet<void Function(DragUpdateDetails details)>();
}
