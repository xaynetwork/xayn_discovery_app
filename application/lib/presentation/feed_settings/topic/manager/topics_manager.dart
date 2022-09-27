import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/presentation/feed_settings/topic/manager/topics_state.dart';

abstract class TopicsScreenNavActions {
  void onDismissTopicsScreen();

  void onAddTopic();
}

@lazySingleton
class TopicsManager extends Cubit<TopicsState>
    with UseCaseBlocHelper<TopicsState>
    implements TopicsScreenNavActions {
  final TopicsScreenNavActions _topicsScreenNavActions;

  TopicsManager(
    this._topicsScreenNavActions,
  ) : super(const TopicsState());

  @override
  void onDismissTopicsScreen() =>
      _topicsScreenNavActions.onDismissTopicsScreen();

  @override
  void onAddTopic() => _topicsScreenNavActions.onAddTopic();
}
