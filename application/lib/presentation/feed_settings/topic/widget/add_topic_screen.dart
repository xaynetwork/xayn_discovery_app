import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/domain/model/topic/topic.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/model/bottom_sheet_footer/bottom_sheet_footer_button_data.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/model/bottom_sheet_footer/bottom_sheet_footer_data.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/widgets/bottom_sheet_footer.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/feed_settings/topic/manager/topics_manager.dart';
import 'package:xayn_discovery_app/presentation/feed_settings/topic/manager/topics_state.dart';
import 'package:xayn_discovery_app/presentation/feed_settings/topic/widget/topic_chip.dart';
import 'package:xayn_discovery_app/presentation/widget/app_scaffold/app_scaffold.dart';
import 'package:xayn_discovery_app/presentation/widget/app_toolbar/app_toolbar_data.dart';

typedef OnTopicPressed = Function(Topic);

class AddTopicScreen extends StatefulWidget {
  const AddTopicScreen({Key? key}) : super(key: key);

  @override
  State<AddTopicScreen> createState() => _AddTopicScreenState();
}

class _AddTopicScreenState extends State<AddTopicScreen>
    with NavBarConfigMixin {
  late final manager = di.get<TopicsManager>();
  late final TextEditingController _textEditingController =
      TextEditingController();

  @override
  void dispose() {
    super.dispose();

    _textEditingController.dispose();
  }

  @override
  NavBarConfig get navBarConfig => NavBarConfig.hidden();

  @override
  Widget build(BuildContext context) => AppScaffold(
        resizeToAvoidBottomInset: true,
        appToolbarData: AppToolbarData.titleOnly(
          title: R.strings.addTopicScreenTitle,
          preferredHeight: R.dimen.unit12,
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: R.dimen.unit3),
          child: BlocBuilder<TopicsManager, TopicsState>(
            bloc: manager,
            builder: (_, state) {
              if (state.newTopicName.isEmpty) _textEditingController.text = '';
              if (state.isEditingMode) {
                _textEditingController.text = state.newTopicName;
              }
              return _buildBody(state);
            },
          ),
        ),
      );

  Widget _buildBody(TopicsState state) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _buildTopicsSections(state)),
          _buildInputField(state),
        ],
      );

  Widget _buildTopicsSections(TopicsState state) {
    final suggestedTopics = {...state.suggestedTopics}
      ..removeAll(state.selectedTopics);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (state.selectedTopics.isNotEmpty)
            ...addedTopicsSection(state.selectedTopics),
          if (suggestedTopics.isNotEmpty)
            ...suggestedTopicsSection(suggestedTopics),
        ],
      ),
    );
  }

  List<Widget> addedTopicsSection(Set<Topic> selectedTopics) {
    final addedSectionHeader = Text(
      R.strings.addedTopicsSubHeader,
      style: R.styles.mBoldStyle,
    );

    return [
      addedSectionHeader,
      buildAddedTopics(selectedTopics),
      SizedBox(height: R.dimen.unit2_5),
    ];
  }

  List<Widget> suggestedTopicsSection(Set<Topic> suggestedTopics) {
    final suggestedSectionHeader = Text(
      R.strings.suggestedTopicsSubHeader,
      style: R.styles.mBoldStyle,
    );

    return [
      suggestedSectionHeader,
      buildSuggestedTopics(suggestedTopics),
    ];
  }

  Widget buildAddedTopics(Set<Topic> topics) => Wrap(
        spacing: R.dimen.unit,
        children: topics
            .map(
              (it) => TopicChip.selected(
                topic: it,
                onPressed: manager.onRemoveOrUpdateTopic,
                showIcon: true,
              ),
            )
            .toList(),
      );

  Widget buildSuggestedTopics(Set<Topic> topics) => Wrap(
        spacing: R.dimen.unit,
        children: topics
            .map(
              (it) => TopicChip.suggested(
                topic: it,
                onPressed: manager.onAddTopic,
                showIcon: true,
              ),
            )
            .toList(),
      );

  Widget _buildInputField(TopicsState state) {
    final divider = Padding(
      padding: EdgeInsets.only(bottom: R.dimen.unit1_5),
      child: Divider(
        color: R.colors.divider,
        height: 1.0,
      ),
    );
    final bottomSpace = SizedBox(height: R.dimen.unit2_5);
    final textField = AppTextField(
      autofocus: true,
      controller: _textEditingController,
      onChanged: manager.onUpdateTopic,
      onSubmitted: (_) => manager.onAddCustomTopic,
      hintText: manager.state.suggestedTopics.join(', '),
      errorText: state.error.errorMsgIfHasOrNull,
      autocorrect: false,
    );
    final actionButtons = BottomSheetFooter(
      onCancelPressed: manager.onDismissTopicsScreen,
      setup: BottomSheetFooterSetup.row(
        buttonData: BottomSheetFooterButton(
          text: R.strings.bottomSheetApply,
          onPressed: manager.onAddCustomTopic,
          isDisabled: !manager.canAddTopic,
        ),
      ),
    );
    final hintText = Padding(
      padding: EdgeInsetsDirectional.only(
        top: R.dimen.unit0_5,
        start: R.dimen.unit,
      ),
      child: Text(
        R.strings.addTopicHintText,
        style: R.styles.sStyle,
      ),
    );
    return Column(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        divider,
        textField,
        hintText,
        actionButtons,
        bottomSpace,
      ],
    );
  }
}
