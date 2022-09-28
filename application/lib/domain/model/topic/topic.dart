import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

@immutable
class Topic extends Equatable {
  final String name;
  final bool isCustom;

  const Topic(
    this.name, {
    this.isCustom = true,
  });

  const Topic.suggested(this.name) : isCustom = false;

  @override
  List<Object?> get props => [
        name,
        isCustom,
      ];

  @override
  String toString() => name;
}
