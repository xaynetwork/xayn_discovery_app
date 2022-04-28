import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';
import 'package:xayn_architecture/xayn_architecture.dart';

mixin SingletonSubscriptionObserver<T> on UseCaseBlocHelper<T> {
  @override
  Stream<T> get stream =>
      super.stream.doOnListen(onListen).doOnCancel(onCancel);

  @mustCallSuper
  void onListen() => resumeAllSubscriptions();

  @mustCallSuper
  void onCancel() => pauseAllSubscriptions();
}
