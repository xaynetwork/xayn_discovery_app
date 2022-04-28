import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/domain/model/document_filter/document_filter.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/feed_settings/manager/source_filter_settings_manager.dart';
import 'package:xayn_discovery_app/presentation/feed_settings/manager/source_filter_settings_state.dart';
import 'package:xayn_discovery_app/presentation/widget/app_toolbar/app_toolbar.dart';
import 'package:xayn_discovery_app/presentation/widget/app_toolbar/app_toolbar_data.dart';
import 'package:xayn_discovery_app/presentation/widget/thumbnail_widget.dart';

class SourceFilterSettingsPage extends StatefulWidget {
  const SourceFilterSettingsPage({Key? key}) : super(key: key);

  @override
  State<SourceFilterSettingsPage> createState() =>
      _SourceFilterSettingsPageState();
}

class _SourceFilterSettingsPageState extends State<SourceFilterSettingsPage> {
  late final SourceFilterSettingsManager _manager = di.get();

  @override
  Widget build(BuildContext context) => Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppToolbar(
          appToolbarData: AppToolbarData.titleOnly(
            title: R.strings.feedSettingsScreenTabSources,
          ),
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: R.dimen.unit3),
          child: _buildBody(context),
        ),
      );

  Widget _buildBody(BuildContext context) {
    Widget buildReadyState(SourceFilterSettingsState state) {
      return DocumentFiltersList(
        filters: state.filters,
        onFilterToggled: _manager.onSourceToggled,
      );
    }

    return BlocBuilder<SourceFilterSettingsManager, SourceFilterSettingsState>(
      bloc: _manager,
      builder: (_, state) => buildReadyState(state),
    );
  }

  @override
  void dispose() {
    _manager.applyChanges();
    super.dispose();
  }
}

class DocumentFiltersList extends StatelessWidget {
  final Map<DocumentFilter, bool> filters;
  final OnItemPressed<DocumentFilter> onFilterToggled;

  const DocumentFiltersList({
    required this.filters,
    required this.onFilterToggled,
    Key? key,
  }) : super(key: key);

  Widget get _verticalSpace => SizedBox(height: R.dimen.unit3);

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitle(R.strings.feedSettingsScreenSubtitleDislikedSources),
          _buildHint(),
          _verticalSpace,
          _buildList(filters, context),
        ],
      );

  Widget _buildHint() => Text(
        R.strings.feedSettingsScreenSourceFilterExplanation,
        style: R.styles.mStyle,
      );

  Widget _buildTitle(String title) => Padding(
        padding: EdgeInsets.only(bottom: R.dimen.unit),
        child: Text(
          title,
          style: R.styles.lBoldStyle,
        ),
      );

  Widget _buildList(
    Map<DocumentFilter, bool> map,
    BuildContext context,
  ) {
    final list = map.entries.toList();
    final listView = ListView.builder(
      itemBuilder: (_, index) {
        final item = list[index];
        return _createItem(item.key, isSelected: item.value);
      },
      itemCount: list.length,
      padding: EdgeInsets.only(bottom: R.dimen.navBarHeight * 2),
    );
    return Expanded(
      child: listView,
      flex: 1,
    );
  }

  Widget _createItem(DocumentFilter item, {required bool isSelected}) =>
      _Item<DocumentFilter>(
        item: item,
        isSelected: isSelected,
        onActionPressed: onFilterToggled,
        getTitle: (e) => e.fold((host) => host, (topic) => topic),
        getImage: (e) => e.fold((host) => buildThumbnailFromFaviconHost(host),
            (topic) => Container()),
      );
}

typedef GetText<T> = String Function(T item);
typedef GetImage<T> = Widget Function(T item);
typedef OnItemPressed<T> = Function(T item);

class _Item<T> extends StatelessWidget {
  final T item;
  final bool isSelected;
  final OnItemPressed<T> onActionPressed;
  final GetText<T> getTitle;
  final GetImage<T> getImage;
  final GetText<T>? getSubTitle;

  const _Item({
    Key? key,
    required this.item,
    required this.isSelected,
    required this.onActionPressed,
    required this.getTitle,
    required this.getImage,
    this.getSubTitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final row = Row(
      children: [
        _buildFlag(),
        _buildName(),
        const Spacer(),
        _buildActionIcon(),
      ],
    );
    final decoration = BoxDecoration(
        color: isSelected
            ? R.colors.settingsCardBackground
            : R.colors.pageBackground,
        borderRadius: R.styles.roundBorder,
        border: Border.all(
          width: R.dimen.unit0_25 / 2,
          color: !isSelected ? R.colors.iconDisabled : R.colors.transparent,
        ));
    final container = Material(
      child: Ink(
        height: R.dimen.iconButtonSize,
        decoration: decoration,
        child: InkWell(
          onTap: () => onActionPressed(item),
          child: Padding(
            padding: EdgeInsets.only(left: R.dimen.unit1_5),
            child: row,
          ),
          radius: R.dimen.unit,
        ),
      ),
    );

    return Padding(
      padding: EdgeInsets.only(top: R.dimen.unit),
      child: container,
    );
  }

  Widget _buildName() {
    final title = Text(
      getTitle(item),
      style: R.styles.mBoldStyle,
    );
    final children = <Widget>[
      title,
    ];

    final subTitleText = getSubTitle?.call(item);
    if (subTitleText != null) {
      final subTitle = Text(
        subTitleText,
        style: R.styles.sStyle.copyWith(
          color: R.colors.secondaryText,
        ),
      );
      children.add(subTitle);
    }

    return Padding(
      padding: EdgeInsets.only(left: R.dimen.unit1_5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
        mainAxisSize: MainAxisSize.min,
      ),
    );
  }

  Widget _buildActionIcon() {
    final icon = isSelected ? R.assets.icons.cross : R.assets.icons.plus;
    final btn = SvgPicture.asset(
      icon,
      color: R.colors.icon,
    );
    return SizedBox(
        width: R.dimen.iconButtonSize,
        child: Padding(
          padding: EdgeInsets.all(R.dimen.unit2),
          child: btn,
        ));
  }

  Widget _buildFlag() => ClipRRect(
      borderRadius: BorderRadius.circular(3.0), child: getImage(item));
}
