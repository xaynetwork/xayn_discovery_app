import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/feed_settings/page/source/manager/sources_manager.dart';
import 'package:xayn_discovery_app/presentation/feed_settings/page/source/manager/sources_state.dart';
import 'package:xayn_discovery_app/presentation/feed_settings/page/source/widget/available_sources_view.dart';
import 'package:xayn_discovery_app/presentation/navigation/widget/nav_bar_items.dart';
import 'package:xayn_discovery_app/presentation/widget/animation_player.dart';
import 'package:xayn_discovery_app/presentation/widget/app_scaffold/app_scaffold.dart';
import 'package:xayn_discovery_app/presentation/widget/app_toolbar/app_toolbar_data.dart';

class AddSourceScreen extends StatefulWidget {
  final SourceType sourceType;

  const AddSourceScreen.excluded({Key? key})
      : sourceType = SourceType.excluded,
        super(key: key);

  const AddSourceScreen.trusted({Key? key})
      : sourceType = SourceType.trusted,
        super(key: key);

  @override
  State<AddSourceScreen> createState() => _AddSourceScreenState();
}

class _AddSourceScreenState extends State<AddSourceScreen>
    with NavBarConfigMixin {
  late final manager = di.get<SourcesManager>();
  late final TextEditingController _textEditingController =
      TextEditingController();

  String get title => widget.sourceType == SourceType.excluded
      ? R.strings.addExcludedSource
      : R.strings.addTrustedSource;

  @override
  NavBarConfig get navBarConfig => NavBarConfig.backBtn(
        const NavBarConfigId('sourcesNavBarConfigId'),
        buildNavBarItemBack(
          onPressed: manager.onDismissSourcesSelection,
        ),
      );

  @override
  void dispose() {
    super.dispose();

    _textEditingController.dispose();
    manager.resetAvailableSourcesList();
  }

  @override
  Widget build(BuildContext context) => AppScaffold(
        resizeToAvoidBottomInset: false,
        appToolbarData: AppToolbarData.titleOnly(
          title: title,
          preferredHeight: R.dimen.unit15,
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: R.dimen.unit3),
          child: Column(
            children: [
              _buildInputField(),
              Expanded(
                child: _buildAvailableSourcesView(),
              ),
            ],
          ),
        ),
      );

  Widget _buildInputField() => AppTextField(
        autofocus: true,
        controller: _textEditingController,
        onChanged: (searchTerm) =>
            manager.getAvailableSourcesList(searchTerm.trim()),
        prefixIcon: Padding(
          padding: EdgeInsets.all(R.dimen.unit),
          child: SvgPicture.asset(
            R.assets.icons.search,
            color: R.colors.icon,
          ),
        ),
        hintText:
            manager.state.sourcesSearchTerm ?? R.strings.addSourcePlaceholder,
        autocorrect: false,
      );

  Widget _buildAvailableSourcesView() =>
      BlocBuilder<SourcesManager, SourcesState>(
        bloc: manager,
        builder: (_, state) => state.availableSources.isEmpty
            ? Column(
                children: [
                  AnimationPlayer.asset(
                      R.linden.assets.lottie.contextual.emptySourcesLookup),
                  if (state.sourcesSearchTerm == null ||
                      state.sourcesSearchTerm!.isEmpty)
                    Text(R.strings.addSourceDescription),
                  if (state.sourcesSearchTerm != null &&
                      state.sourcesSearchTerm!.isNotEmpty) ...[
                    Padding(
                      padding: EdgeInsets.only(bottom: R.dimen.unit1_5),
                      child: Text(
                        R.strings.noSourcesFoundTitle,
                        style: R.styles.mBoldStyle,
                      ),
                    ),
                    Text(R.strings.noSourcesFoundInfo)
                  ],
                ],
              )
            : widget.sourceType == SourceType.excluded
                ? AvailableSourcesView.excludedSources(
                    manager: manager,
                    sources: state.availableSources,
                    onTap: (source) {
                      manager.addSourceToExcludedList(source);
                      manager.onDismissSourcesSelection();
                    },
                  )
                : AvailableSourcesView.trustedSources(
                    manager: manager,
                    sources: state.availableSources,
                    onTap: (source) {
                      manager.addSourceToTrustedList(source);
                      manager.onDismissSourcesSelection();
                    },
                  ),
      );
}
