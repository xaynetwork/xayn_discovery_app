import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

@immutable
class Country extends Equatable {
  final Key? key;
  final String name;
  final String? language;
  final String svgFlagAssetPath;
  final String countryCode;
  final String langCode;

  const Country({
    required this.name,
    required this.svgFlagAssetPath,
    required this.countryCode,
    required this.langCode,
    this.language,
    this.key,
  });

  @override
  List<Object?> get props => [
        name,
        language,
        svgFlagAssetPath,
        countryCode,
        langCode,
      ];
}
