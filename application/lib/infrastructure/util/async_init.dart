import 'dart:async';

import 'package:async/async.dart';
import 'package:flutter/cupertino.dart';
import 'package:xayn_discovery_app/presentation/utils/environment_helper.dart';

/// A helper class to initialize something in [init] that must complete before any
/// [safeRun] operation runs.
mixin AsyncInitMixin {
  static final _operations = <CancelableOperation>[];

  CancelableOperation<bool>? _ongoingInit;

  /// Once [startInitializing] is called [init] needs to complete before
  /// the safeRun()
  @mustCallSuper
  void startInitializing() {
    _ongoingInit = CancelableOperation.fromFuture(init().then((value) => true),
        onCancel: () => false);
    if (EnvironmentHelper.kIsInTest) {
      _operations.add(_ongoingInit!);
    }
  }

  Future<void> init();

  /// Run an operation after the initialization in [init] is done.
  @protected
  @mustCallSuper
  Future<T> safeRun<T>(FutureOr<T> Function() run) async {
    final ongoingInit = _ongoingInit;
    if (ongoingInit != null &&
        !ongoingInit.isCompleted &&
        !ongoingInit.isCanceled) {
      final completed = await ongoingInit.value;
      if (!completed) {
        throw 'Operation was canceled before safeRun could start.';
      }
    }

    if (ongoingInit != null && ongoingInit.isCanceled) {
      throw 'Operation was already canceled but safeRun has been called regardless. Be sure to never cancel any AsyncInitMixin when it is still used.';
    }

    return run();
  }

  /// cancels the ongoing [init] call. Note that the spawned microtask of
  /// [init] can not be canceled (thus the operations in [init] will be called regardless)
  /// but the dangling safeRuns that depend on [init] will be terminated.
  @mustCallSuper
  Future? cancelInit() {
    return _ongoingInit?.cancel();
  }

  @visibleForTesting
  bool get isCancelled => _ongoingInit?.isCanceled == true;

  @visibleForTesting
  static Future cancelAll() {
    final list = _operations.toList();
    _operations.clear();
    return Future.wait(list.map((e) => e.cancel()));
  }
}
