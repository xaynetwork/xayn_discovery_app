import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xayn_discovery_app/domain/model/reader_mode/reader_mode_background_color.dart';
import 'package:xayn_discovery_app/domain/model/reader_mode/reader_mode_font_size.dart';
import 'package:xayn_discovery_app/domain/model/reader_mode/reader_mode_font_style.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/menu/edit_reader_mode_settings/manager/edit_reader_mode_settings_manager.dart';
import 'package:xayn_discovery_app/presentation/menu/edit_reader_mode_settings/manager/edit_reader_mode_settings_state.dart';
import 'package:xayn_discovery_app/presentation/utils/reader_mode_settings_extension.dart';
import 'package:xayn_discovery_app/presentation/widget/selectable_chip.dart';

const _kDividerThickness = 1.0;

class EditReaderModeSettingsMenu extends StatefulWidget {
  const EditReaderModeSettingsMenu({Key? key}) : super(key: key);

  @override
  _EditReaderModeSettingsMenuState createState() =>
      _EditReaderModeSettingsMenuState();
}

class _EditReaderModeSettingsMenuState
    extends State<EditReaderModeSettingsMenu> {
  late final EditReaderModeSettingsManager _editReaderModeSettingsManager =
      di.get();

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
                .toList(),
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
                .toList(),
          );

          final editBackgroundColorRow = _buildPaddedRow(
              children: ReaderModeBackgroundColor.values
                  .skipWhile((it) => it.isDefault)
                  .map(
                    (it) => SelectableChip.container(
                      color: it.color,
                      borderColor: it.borderColor,
                      isSelected:
                          it == state.readerModeBackgroundColor.mapIfDefault,
                      onTap: () => _editReaderModeSettingsManager
                          .onBackgroundColorPressed(it),
                    ),
                  )
                  .toList());

          final column = Column(
            children: [
              SizedBox(height: R.dimen.unit3),
              editFontStyleRow,
              _buildDivider(),
              editFontSizeRow,
              _buildDivider(),
              editBackgroundColorRow,
              SizedBox(height: R.dimen.unit3),
            ],
          );

          return Material(
            elevation: R.dimen.unit5,
            shadowColor: R.colors.shadowTransparent,
            borderRadius: R.styles.roundBorder,
            clipBehavior: Clip.antiAlias,
            color: R.colors.background,
            child: column,
          );
        });
  }

  Widget _buildDivider() => Divider(
        color: R.colors.menuDividerColor,
        height: R.dimen.unit4,
        thickness: _kDividerThickness,
      );

  Widget _buildPaddedRow({required List<Widget> children}) => Padding(
        padding: EdgeInsets.symmetric(horizontal: R.dimen.unit3),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: children,
        ),
      );
}
