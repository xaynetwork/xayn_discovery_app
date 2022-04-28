import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:xayn_architecture/xayn_architecture.dart';

mixin SingletonSubscriptionObserver<T> on UseCaseBlocHelper<T> {
  final PublishSubject<bool> _onSubscriptionActivity = PublishSubject<bool>();

  Stream<bool>? _onHasActiveListeners;
  Stream<bool> get onHasActiveListeners => _onHasActiveListeners ??=
      _onSubscriptionActivity.distinct().where((it) => it);

  Stream<bool>? _onHasNoActiveListeners;
  Stream<bool> get onHasNoActiveListeners => _onHasNoActiveListeners ??=
      _onSubscriptionActivity.distinct().where((it) => !it);

  @override
  Stream<T> get stream => super
      .stream
      .doOnListen(() => _onSubscriptionActivity.add(true))
      .doOnCancel(() => _onSubscriptionActivity.add(false));
}
