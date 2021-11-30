import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/concepts/use_case/none.dart';
import 'package:xayn_architecture/concepts/use_case/use_case_base.dart';
import 'package:xayn_discovery_app/domain/model/discovery_feed_scroll_direction.dart';

@injectable
class FakeDiscoveryFeedScrollDirectionStorage
    extends ValueNotifier<DiscoveryFeedScrollDirection> {
  static FakeDiscoveryFeedScrollDirectionStorage? _instance;

  FakeDiscoveryFeedScrollDirectionStorage._()
      : super(DiscoveryFeedScrollDirection.vertical);

  factory FakeDiscoveryFeedScrollDirectionStorage() {
    _instance ??= FakeDiscoveryFeedScrollDirectionStorage._();
    return _instance!;
  }
}

@injectable
class GetDiscoveryFeedScrollDirectionUseCase
    extends UseCase<None, DiscoveryFeedScrollDirection> {
  final FakeDiscoveryFeedScrollDirectionStorage _storage;

  GetDiscoveryFeedScrollDirectionUseCase(this._storage);

  @override
  Stream<DiscoveryFeedScrollDirection> transaction(None param) async* {
    await Future.delayed(const Duration(milliseconds: 42));
    yield _storage.value;
  }
}
