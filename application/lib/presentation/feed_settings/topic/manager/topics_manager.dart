import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/error/error_object.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/topic/add_custom_topic_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/topic/topic_use_cases_errors.dart';
import 'package:xayn_discovery_app/presentation/feed_settings/topic/manager/topics_state.dart';
import 'package:xayn_discovery_app/presentation/feed_settings/topic/util/topic_errors_enum_mapper.dart';
import 'package:xayn_discovery_app/presentation/utils/logger/logger.dart';

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
  final AddCustomTopicUseCase _addCustomTopicUseCase;
  final TopicErrorsEnumMapper _topicErrorsEnumMapper;

  late final UseCaseSink<String, String> _addCustomTopicHandler =
      pipe(_addCustomTopicUseCase);

  final _selectedTopics = <String>{};
  String _newTopic = '';
  bool _checkForError = false;

  TopicsManager(
    this._topicsScreenNavActions,
    this._addCustomTopicUseCase,
    this._topicErrorsEnumMapper,
  ) : super(
          const TopicsState(
            selectedTopics: {},
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

  void onUpdateTopic(String name) =>
      scheduleComputeState(() => _newTopic = name);

  bool get canAddTopic {
    final isEmpty = state.newTopic.isEmpty;
    final doesTopicExist =
        state.selectedTopics.any((it) => it == state.newTopic);
    return !isEmpty && !doesTopicExist;
  }

  void onAddCustomTopic() {
    _checkForError = true;
    _addCustomTopicHandler(state.newTopic);
  }

  @override
  Future<TopicsState?> computeState() async =>
      fold(_addCustomTopicHandler).foldAll(
        (newCustomTopic, errorReport) {
          if (errorReport.isNotEmpty && _checkForError) {
            _checkForError = false;
            final report = errorReport.of(_addCustomTopicHandler);
            final error = report!.error as TopicUseCaseError;
            logger.e(error);
            final errorMessage = _topicErrorsEnumMapper.mapEnumToString(error);
            return state.copyWith(error: ErrorObject(error, errorMessage));
          } else if (errorReport.isEmpty &&
              _checkForError &&
              newCustomTopic != null) {
            _selectedTopics.add(newCustomTopic);
            _newTopic = '';
          }

          _checkForError = false;

          return TopicsState(
            suggestedTopics: _suggestedTopics,
            selectedTopics: {..._selectedTopics},
            newTopic: _newTopic,
          );
        },
      );
}
