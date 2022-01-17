import 'package:flutter/material.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';

///todo: move to xayn_design
class AppTextField extends StatelessWidget {
  const AppTextField({
    Key? key,
    this.controller,
    this.focusNode,
    this.onTap,
    this.onChanged,
    this.onSubmitted,
    this.prefixIcon,
    this.suffixIcon,
    this.hintText,
    this.errorText,
    this.textInputAction,
    this.autofocus = false,
    this.autocorrect = true,
    this.readOnly = false,
    this.enabled = true,
  }) : super(key: key);

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? hintText, errorText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final TextInputAction? textInputAction;
  final bool autofocus;
  final bool autocorrect;
  final bool readOnly;
  final bool enabled;
  final void Function()? onTap;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;

  @override
  Widget build(BuildContext context) {
    final textFieldStyle = R.dimen.isSmallScreen
        ? R.styles.textInputTextSmall
        : R.styles.textInputText;

    final textFieldDecoration = decoration(
      errorText: errorText,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      hintText: hintText,
    );

    final textField = TextField(
      enabled: enabled,
      keyboardAppearance: R.colors.brightness,
      controller: controller,
      focusNode: focusNode,
      autofocus: autofocus,
      autocorrect: autocorrect,
      readOnly: readOnly,
      maxLines: 1,
      style: enabled
          ? textFieldStyle
          : textFieldStyle?.copyWith(color: R.colors.searchInputTextDisabled),
      textInputAction: textInputAction,
      textAlignVertical: TextAlignVertical.center,
      decoration: textFieldDecoration,
      onSubmitted: onSubmitted,
      onTap: onTap,
      onChanged: onChanged,
    );

    return textField;
  }

  static InputDecoration decoration({
    String? errorText,
    Widget? suffixIcon,
    Widget? prefixIcon,
    String? hintText,
    TextStyle? hintTextStyle,
  }) {
    final border = OutlineInputBorder(
      borderRadius: R.styles.roundBorder,
      borderSide: BorderSide(
        width: 0,
        color: R.colors.transparent,
      ),
    );
    const iconMaxWidth = 48.0;
    const iconMaxHeight = 38.0;
    return InputDecoration(
      filled: true,
      fillColor: R.colors.searchInputFill,
      isDense: true,
      contentPadding: EdgeInsets.symmetric(
        horizontal: R.dimen.adaptiveUnit(small: 1, normal: 1.5),
        vertical: R.dimen.adaptiveUnit(small: 1, normal: 1),
      ),
      errorStyle: R.dimen.isSmallScreen
          ? R.styles.textInputErrorSmall
          : R.styles.textInputError,
      hintText: hintText,
      hintStyle: hintTextStyle,
      errorText: errorText,
      errorMaxLines: 2,
      enabledBorder: border,
      focusedBorder: border,
      errorBorder: border,
      focusedErrorBorder: border,
      suffixIconConstraints: const BoxConstraints.expand(
        width: iconMaxWidth,
        height: iconMaxHeight,
      ),
      suffixIcon: suffixIcon,
      prefixIconConstraints: prefixIcon != null
          ? BoxConstraints(
              minWidth: R.dimen.unit1_5,
              minHeight: iconMaxHeight,
              maxWidth: iconMaxWidth,
              maxHeight: iconMaxHeight,
            )
          : null,
      prefixIcon: prefixIcon,
    );
  }
}
