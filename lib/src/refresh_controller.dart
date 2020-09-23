part of "refresh_control.dart";

class RefreshController {
  void startRefresh() {
    assert(
      !_disposed,
      "RefreshController has disposed.",
    );
    $eventBus.emitEvent(_refreshEvent);
  }

  void failedToLoad({dynamic payload}) {
    assert(
      !_disposed,
      "RefreshController has disposed.",
    );
    $eventBus.emitEventWithArg(_loadEvent, payload);
  }

  void loadSuccessfully(bool hasData, bool hasMoreData) {
    assert(
      !_disposed,
      "RefreshController has disposed.",
    );
    assert(hasData != null);
    assert(hasMoreData != null);
    $eventBus.emitEventWith2Args(_loadEvent, hasData, hasMoreData);
  }

  void failedToRefresh({dynamic payload}) {
    assert(
      !_disposed,
      "RefreshController has disposed.",
    );
    $eventBus.emitEventWithArg(_refreshEvent, payload);
  }

  void refreshSuccessfully(bool hasData, bool hasMoreData, {dynamic payload}) {
    assert(
      !_disposed,
      "RefreshController has disposed.",
    );
    assert(hasData != null);
    assert(hasMoreData != null);
    $eventBus.emitEventWith3Args(_refreshEvent, hasData, hasMoreData, payload);
  }

  void dispose() {
    assert(
      !_disposed,
      "RefreshController has disposed.",
    );
    _disposed = true;
  }

  bool _disposed = false;
  final Object _loadEvent = Object();
  final Object _refreshEvent = Object();
}
