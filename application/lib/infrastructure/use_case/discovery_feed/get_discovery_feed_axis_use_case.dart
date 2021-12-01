import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/concepts/use_case/none.dart';
import 'package:xayn_architecture/concepts/use_case/use_case_base.dart';
import 'package:xayn_discovery_app/domain/model/discovery_feed_axis.dart';

@singleton
class FakeDiscoveryFeedAxisStorage extends ValueNotifier<DiscoveryFeedAxis> {
  FakeDiscoveryFeedAxisStorage() : super(DiscoveryFeedAxis.vertical);
}

@injectable
class GetDiscoveryFeedAxisUseCase extends UseCase<None, DiscoveryFeedAxis> {
  final FakeDiscoveryFeedAxisStorage _storage;

  GetDiscoveryFeedAxisUseCase(this._storage);

  @override
  Stream<DiscoveryFeedAxis> transaction(None param) async* {
    await Future.delayed(const Duration(milliseconds: 42));
    yield _storage.value;
  }
}
