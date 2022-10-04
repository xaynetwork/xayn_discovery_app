import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/model/bottom_sheet_footer/bottom_sheet_footer_button_data.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/model/bottom_sheet_footer/bottom_sheet_footer_data.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/widgets/bottom_sheet_footer.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/feed_settings/topic/manager/topics_manager.dart';
import 'package:xayn_discovery_app/presentation/feed_settings/topic/manager/topics_state.dart';
import 'package:xayn_discovery_app/presentation/feed_settings/topic/widget/added_topic_chip.dart';
import 'package:xayn_discovery_app/presentation/feed_settings/topic/widget/suggested_topic_chip.dart';
import 'package:xayn_discovery_app/presentation/widget/app_scaffold/app_scaffold.dart';
import 'package:xayn_discovery_app/presentation/widget/app_toolbar/app_toolbar_data.dart';

typedef OnTopicPressed = Function(String);

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
            builder: (_, state) => _buildBody(state),
          ),
        ),
      );

  Widget _buildBody(TopicsState state) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _buildTopicsSections(state)),
          _buildInputField(),
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

  List<Widget> addedTopicsSection(Set<String> selectedTopics) {
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

  List<Widget> suggestedTopicsSection(Set<String> suggestedTopics) {
    final suggestedSectionHeader = Text(
      R.strings.suggestedTopicsSubHeader,
      style: R.styles.mBoldStyle,
    );

    return [
      suggestedSectionHeader,
      buildSuggestedTopics(suggestedTopics),
    ];
  }

  Widget buildAddedTopics(Set<String> topics) => Wrap(
        spacing: R.dimen.unit,
        children: topics
            .map(
              (it) => AddedTopicChip(
                topic: it,
                onPressed: manager.onRemoveTopic,
              ),
            )
            .toList(),
      );

  Widget buildSuggestedTopics(Set<String> topics) => Wrap(
        spacing: R.dimen.unit,
        children: topics
            .map(
              (it) => SuggestedTopicChip(
                topic: it,
                onPressed: manager.onAddTopic,
              ),
            )
            .toList(),
      );

  Widget _buildInputField() {
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
      hintText: manager.state.suggestedTopics.join(', '),
      autocorrect: false,
    );
    final actionButtons = BottomSheetFooter(
      onCancelPressed: manager.onDismissTopicsScreen,
      setup: BottomSheetFooterSetup.row(
        buttonData: BottomSheetFooterButton(
          text: R.strings.bottomSheetApply,
          onPressed: () {},
        ),
      ),
    );
    final hintText = Padding(
      padding: EdgeInsets.only(
        top: R.dimen.unit0_5,
      ),
      child: Center(
        child: Text(
          R.strings.addTopicHintText,
          style: R.styles.sStyle,
        ),
      ),
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
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
