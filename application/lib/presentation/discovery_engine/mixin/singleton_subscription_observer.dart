import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/presentation/utils/environment_helper.dart';

/// This mixin pauses/resumes any use cases that are being piped/consumed.
/// - The use cases will pause when nothing is no longer subscribed to the manager
/// - They will resume as soon as the manager receives a fresh subscription
///
/// This effectively "shuts down" the manager while we change screens.
///
/// We want this behaviour, because other screens might update the engine in some way,
/// for example, changing markets in settings, or liking/disliking articles in
/// either feed or search.
///
/// When actually being consumed again, and only then, the subscriptions resume,
/// processing any pending changes, and finally running [computeState].
mixin SingletonSubscriptionObserver<T> on UseCaseBlocHelper<T> {
  /// todo: since managers where not singletons before, we should update our tests
  /// for now, disabling the listeners is sufficient to make them pass.
  @override
  Stream<T> get stream => EnvironmentHelper.kIsInTest
      ? super.stream
      : super.stream.doOnListen(onListen).doOnCancel(onCancel);

  @mustCallSuper
  void onListen() => resumeAllSubscriptions();

  @mustCallSuper
  void onCancel() => pauseAllSubscriptions();
}
