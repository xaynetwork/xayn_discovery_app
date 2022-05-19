import 'package:xayn_discovery_engine_flutter/discovery_engine.dart';

enum CardType { document, survey }

class Card {
  final CardType type;
  final Document? document;

  Document get requireDocument => document!;

  const Card.document(this.document) : type = CardType.document;

  const Card.other(this.type) : document = null;
}
