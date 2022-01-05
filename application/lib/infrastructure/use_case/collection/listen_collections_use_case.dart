import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/collection/collection.dart';
import 'package:xayn_discovery_app/domain/repository/collections_repository.dart';

@injectable
class ListenCollectionsUseCase
    extends UseCase<None, ListenCollectionsUseCaseOut> {
  final CollectionsRepository _collectionsRepository;

  ListenCollectionsUseCase(this._collectionsRepository);
  @override
  Stream<ListenCollectionsUseCaseOut> transaction(None param) {
    return _collectionsRepository.watch().map(
          (_) => ListenCollectionsUseCaseOut(_collectionsRepository.getAll()),
        );
  }
}

class ListenCollectionsUseCaseOut extends Equatable {
  final List<Collection> collections;

  const ListenCollectionsUseCaseOut(this.collections);

  @override
  List<Object?> get props => collections;
}
