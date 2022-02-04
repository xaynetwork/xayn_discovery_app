import 'package:injectable/injectable.dart';

import 'card_widget_transition.dart';

abstract class CardWidgetTransitionNavActions {
  void onClosePressed();
  void onLongPressed(CardWidgetTransitionArgs args);
}

@lazySingleton
class CardWidgetTransitionManager implements CardWidgetTransitionNavActions {
  final CardWidgetTransitionNavActions _cardWidgetTransitionNavActions;

  CardWidgetTransitionManager(this._cardWidgetTransitionNavActions);
  @override
  void onClosePressed() {
    _cardWidgetTransitionNavActions.onClosePressed();
  }

  @override
  void onLongPressed(CardWidgetTransitionArgs args) {
    _cardWidgetTransitionNavActions.onLongPressed(args);
  }
}
