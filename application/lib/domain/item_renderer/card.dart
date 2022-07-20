import 'package:equatable/equatable.dart';
import 'package:xayn_discovery_app/domain/model/extensions/document_extension.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_engine_flutter/discovery_engine.dart';

enum CardType { document, survey, ad }

class Card extends Equatable {
  final CardType type;
  final Document? document;
  final UniqueId id;

  Document get requireDocument => document!;

  Card.document(this.document)
      : type = CardType.document,
        id = document!.documentId.uniqueId;

  const Card.other(this.type, this.id) : document = null;

  @override
  List<Object?> get props => [type, document, id];
}
