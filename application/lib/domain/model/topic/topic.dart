import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

@immutable
class Topic extends Equatable {
  final Key? key;
  final String name;
  final bool isCustom;

  Topic(
    this.name, {
    this.isCustom = true,
  }) : key = Key(name);

  const Topic.suggested(this.key, this.name) : isCustom = false;

  @override
  List<Object?> get props => [
        key,
        isCustom,
      ];

  @override
  String toString() => name;
}
