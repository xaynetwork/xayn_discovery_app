import 'dart:async';

import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/collection/collection.dart';
import 'package:xayn_discovery_app/domain/repository/collections_repository.dart';

class ListenCollectionsUseCase extends UseCase<None, List<Collection>> {
  final CollectionsRepository _collectionsRepository;

  ListenCollectionsUseCase(this._collectionsRepository);
  @override
  Stream<List<Collection>> transaction(None param) =>
      _collectionsRepository.watch().map(
            (_) => _collectionsRepository.getAll(),
          );
}
