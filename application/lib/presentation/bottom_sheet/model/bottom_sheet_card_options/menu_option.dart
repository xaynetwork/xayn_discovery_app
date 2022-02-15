import 'package:flutter/material.dart';

class MenuOption {
  final String svgIconPath;
  final String text;
  final VoidCallback onPressed;

  MenuOption({
    required this.svgIconPath,
    required this.text,
    required this.onPressed,
  });
}
