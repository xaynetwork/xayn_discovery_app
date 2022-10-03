import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/error/error_object.dart';
import 'package:xayn_discovery_app/domain/model/topic/topic.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/topic/add_custom_topic_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/topic/topic_use_cases_errors.dart';
import 'package:xayn_discovery_app/presentation/feed_settings/topic/manager/topics_state.dart';
import 'package:xayn_discovery_app/presentation/feed_settings/topic/util/default_suggested_topics.dart';
import 'package:xayn_discovery_app/presentation/feed_settings/topic/util/topic_errors_enum_mapper.dart';
import 'package:xayn_discovery_app/presentation/utils/logger/logger.dart';
import 'package:xayn_discovery_app/presentation/utils/overlay/overlay_data.dart';
import 'package:xayn_discovery_app/presentation/utils/overlay/overlay_manager_mixin.dart';

abstract class TopicsScreenNavActions {
  void onDismissTopicsScreen();

  void onAddTopicButtonClicked();

  void onManageTopicsPressed();
}

@lazySingleton
class TopicsManager extends Cubit<TopicsState>
    with UseCaseBlocHelper<TopicsState>, OverlayManagerMixin<TopicsState>
    implements TopicsScreenNavActions {
  final TopicsScreenNavActions _topicsScreenNavActions;
  final AddCustomTopicUseCase _addCustomTopicUseCase;
  final TopicErrorsEnumMapper _topicErrorsEnumMapper;

  late final UseCaseSink<String, Topic> _addCustomTopicHandler =
      pipe(_addCustomTopicUseCase);

  final _selectedTopics = <Topic>{};
  String _newTopicName = '';
  bool _checkForError = false;
  bool _isEditingMode = false;

  TopicsManager(
    this._topicsScreenNavActions,
    this._addCustomTopicUseCase,
    this._topicErrorsEnumMapper,
  ) : super(
          TopicsState(suggestedTopics: suggestedTopics),
        );

  @override
  void onDismissTopicsScreen() =>
      _topicsScreenNavActions.onDismissTopicsScreen();

  @override
  void onAddTopicButtonClicked() =>
      _topicsScreenNavActions.onAddTopicButtonClicked();

  @override
  void onManageTopicsPressed() =>
      _topicsScreenNavActions.onManageTopicsPressed();

  void onRemoveTopic(Topic topic) {
    scheduleComputeState(
      () => _selectedTopics.remove(topic),
    );
  }

  void onRemoveOrUpdateTopic(Topic topic) {
    scheduleComputeState(
      () {
        _selectedTopics.remove(topic);
        if (topic.isCustom) {
          _newTopicName = topic.name;
          _isEditingMode = true;
        }
      },
    );
  }

  void onAddTopic(Topic topic, [bool showToolTip = false]) {
    scheduleComputeState(
      () => _selectedTopics.add(topic),
    );

    if (showToolTip) {
      showOverlay(
        OverlayData.tooltipTopicAdded(
          onTap: onManageTopicsPressed,
        ),
      );
    }
  }

  void onAddOrRemoveTopic(Topic topic, [bool showToolTip = true]) =>
      isSelected(topic)
          ? onRemoveOrUpdateTopic(topic)
          : onAddTopic(topic, showToolTip);

  void onUpdateTopic(String name) =>
      scheduleComputeState(() => _newTopicName = name);

  bool get canAddTopic {
    final isEmpty = state.newTopicName.isEmpty;
    final doesTopicExist =
        state.selectedTopics.any((it) => it.name == state.newTopicName);
    return !isEmpty && !doesTopicExist;
  }

  void onAddCustomTopic() {
    _checkForError = true;
    _addCustomTopicHandler(state.newTopicName);
  }

  bool isSelected(Topic topic) => state.selectedTopics.contains(topic);

  int get customSelectedTopicsCount =>
      state.selectedTopics.difference(state.suggestedTopics).length;

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
            _newTopicName = '';
          }

          _checkForError = false;

          if (state.isEditingMode) _isEditingMode = false;

          return TopicsState(
            suggestedTopics: suggestedTopics,
            selectedTopics: {..._selectedTopics},
            newTopicName: _newTopicName,
            isEditingMode: _isEditingMode,
          );
        },
      );
}
