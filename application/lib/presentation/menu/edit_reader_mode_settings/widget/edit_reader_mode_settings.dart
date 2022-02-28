import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/domain/model/reader_mode/reader_mode_background_color.dart';
import 'package:xayn_discovery_app/domain/model/reader_mode/reader_mode_font_size.dart';
import 'package:xayn_discovery_app/domain/model/reader_mode/reader_mode_font_style.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/menu/edit_reader_mode_settings/manager/edit_reader_mode_settings_manager.dart';
import 'package:xayn_discovery_app/presentation/menu/edit_reader_mode_settings/manager/edit_reader_mode_settings_state.dart';
import 'package:xayn_discovery_app/presentation/utils/reader_mode_settings_extension.dart';
import 'package:xayn_discovery_app/presentation/widget/selectable_chip.dart';

class EditReaderModeSettingsMenu extends StatefulWidget {
  const EditReaderModeSettingsMenu({Key? key, this.onCloseMenu})
      : super(key: key);
  final VoidCallback? onCloseMenu;

  @override
  _EditReaderModeSettingsMenuState createState() =>
      _EditReaderModeSettingsMenuState();
}

class _EditReaderModeSettingsMenuState
    extends State<EditReaderModeSettingsMenu> {
  final EditReaderModeSettingsManager _editReaderModeSettingsManager = di.get();

  @override
  void dispose() {
    _editReaderModeSettingsManager.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EditReaderModeSettingsManager,
            EditReaderModeSettingsState>(
        bloc: _editReaderModeSettingsManager,
        builder: (_, state) {
          final editFontStyleRow = _buildPaddedRow(
            children: ReaderModeFontStyle.values
                .map(
                  (it) => SelectableChip.svg(
                    svgPath: it.svgPath,
                    isSelected: it == state.readerModeFontStyle,
                    onTap: () =>
                        _editReaderModeSettingsManager.onFontStylePressed(it),
                  ),
                )
                .toList(growable: false),
          );

          final editFontSizeRow = _buildPaddedRow(
            children: ReaderModeFontSize.values
                .map(
                  (it) => SelectableChip.svg(
                    padding: EdgeInsets.symmetric(
                      vertical: R.dimen.unit0_75,
                      horizontal: R.dimen.unit0_5,
                    ),
                    svgPath: it.svgPath,
                    isSelected: it == state.readerModeFontSize,
                    onTap: () =>
                        _editReaderModeSettingsManager.onFontSizePressed(it),
                  ),
                )
                .toList(growable: false),
          );

          final editLightBackgroundColorRow = _buildPaddedRow(
            children: ReaderModeBackgroundLightColor.values
                .map(
                  (it) => SelectableChip.container(
                    color: it.color,
                    isSelected: it == state.readerModeBackgroundColor.type,
                    onTap: () => _editReaderModeSettingsManager
                        .onLightBackgroundColorPressed(it),
                  ),
                )
                .toList(growable: false),
            mainAxisAlignment: MainAxisAlignment.spaceAround,
          );

          final editDarkBackgroundColorRow = _buildPaddedRow(
            children: ReaderModeBackgroundDarkColor.values
                .map(
                  (it) => SelectableChip.container(
                    color: it.color,
                    isSelected: it == state.readerModeBackgroundColor.type,
                    onTap: () => _editReaderModeSettingsManager
                        .onDarkBackgroundColorPressed(it),
                  ),
                )
                .toList(growable: false),
            mainAxisAlignment: MainAxisAlignment.spaceAround,
          );

          return AppMenu(
            children: [
              editFontStyleRow,
              editFontSizeRow,
              R.isDarkMode
                  ? editDarkBackgroundColorRow
                  : editLightBackgroundColorRow,
            ],
            bottom: MediaQuery.of(context).viewInsets.bottom +
                R.dimen.bottomBarDockedHeight +
                R.dimen.unit4_25,
            end: R.dimen.unit2,
            width: R.dimen.unit22,
            onClose: widget.onCloseMenu,
            errorMessage: state.error != null
                ? R.strings.readerModeSettingsErrorChangesNotApplied
                : null,
          );
        });
  }

  Widget _buildPaddedRow({
    required List<Widget> children,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.spaceBetween,
  }) =>
      Padding(
        padding: EdgeInsets.symmetric(horizontal: R.dimen.unit3),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: mainAxisAlignment,
          children: children,
        ),
      );
}
