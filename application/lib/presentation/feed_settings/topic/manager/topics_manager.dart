import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/presentation/feed_settings/topic/manager/topics_state.dart';

const _defaultSelectedTopics = <String>{'Sports', 'Lifestyle', 'Formula 1'};
const _suggestedTopics = <String>{
  'Sports',
  'LifeStyle',
  'Science',
  'Technology',
  'Entertainment',
  'Politics',
  'Health',
  'World',
  'Sustainability',
  'Business',
};

abstract class TopicsScreenNavActions {
  void onDismissTopicsScreen();

  void onAddTopicButtonClicked();
}

@lazySingleton
class TopicsManager extends Cubit<TopicsState>
    with UseCaseBlocHelper<TopicsState>
    implements TopicsScreenNavActions {
  final TopicsScreenNavActions _topicsScreenNavActions;
  final _selectedTopics = Set<String>.from(_defaultSelectedTopics);

  TopicsManager(
    this._topicsScreenNavActions,
  ) : super(
          const TopicsState(
            selectedTopics: _defaultSelectedTopics,
            suggestedTopics: _suggestedTopics,
          ),
        );

  @override
  void onDismissTopicsScreen() =>
      _topicsScreenNavActions.onDismissTopicsScreen();

  @override
  void onAddTopicButtonClicked() =>
      _topicsScreenNavActions.onAddTopicButtonClicked();

  void onRemoveTopic(String topic) {
    scheduleComputeState(
      () => _selectedTopics.remove(topic),
    );
  }

  void onAddTopic(String topic) {
    scheduleComputeState(
      () => _selectedTopics.add(topic),
    );
  }

  @override
  Future<TopicsState?> computeState() async => state.copyWith(
        selectedTopics: {..._selectedTopics},
      );
}
