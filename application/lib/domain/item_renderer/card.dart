import 'package:equatable/equatable.dart';
import 'package:xayn_discovery_app/domain/model/legacy/document.dart';

enum CardType {
  document,
  survey,
  pushNotifications,
}

class Card extends Equatable {
  final CardType type;
  final Document document;

  const Card.document(this.document) : type = CardType.document;

  @override
  List<Object?> get props => [type, document];
}
