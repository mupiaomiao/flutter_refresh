part of "refresh_control.dart";

class RefreshController {
  void startRefresh() {
    assert(
      !_disposed,
      "RefreshController has disposed.",
    );
    _delegate?.startRefresh();
  }

  void failedToLoad({dynamic payload}) {
    assert(
      !_disposed,
      "RefreshController has disposed.",
    );
    assert(
      _delegate?.isLoading ?? false,
      "RefreshController.failedToLoad only can be called when the load task did not complete.",
    );
    _delegate?.failedToLoad(payload);
  }

  void loadSuccessfully(bool hasData, bool hasMoreData) {
    assert(
      !_disposed,
      "RefreshController has disposed.",
    );
    assert(
      _delegate?.isLoading ?? false,
      "RefreshController.loadSuccessfully only can be called when the load task did not complete.",
    );
    _delegate?.loadSuccessfully(hasData, hasMoreData);
  }

  void failedToRefresh({dynamic payload}) {
    assert(
      !_disposed,
      "RefreshController has disposed.",
    );
    assert(
      _delegate?.isRefreshing ?? false,
      "RefreshController.failedToRefresh only can be called when the refresh task did not complete.",
    );
    _delegate?.failedToRefresh(payload);
  }

  void refreshSuccessfully(bool hasData, bool hasMoreData, {dynamic payload}) {
    assert(
      !_disposed,
      "RefreshController has disposed.",
    );
    assert(
      _delegate?.isRefreshing ?? false,
      "RefreshController.refreshSuccessfully only can be called when the refresh task did not complete.",
    );
    _delegate?.refreshSuccessfully(hasData, hasMoreData, payload);
  }

  void dispose() {
    assert(
      !_disposed,
      "RefreshController has disposed.",
    );
    _disposed = true;
    _delegate = null;
  }

  bool _disposed = false;
  _RefreshControllerDelegate _delegate;
}

abstract class _RefreshControllerDelegate {
  void startRefresh();
  bool get isLoading;
  bool get isRefreshing;
  void failedToLoad(dynamic payload);
  void loadSuccessfully(bool hasData, bool hasMoreData);
  void failedToRefresh(dynamic payload);
  void refreshSuccessfully(bool hasData, bool hasMoreData, dynamic payload);
}
