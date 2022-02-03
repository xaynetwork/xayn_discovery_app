import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

@immutable
class DocumentProvider extends Equatable {
  final String? name;
  final Uri? favicon;

  const DocumentProvider({
    this.name,
    this.favicon,
  });

  @override
  List<Object?> get props => [name, favicon];
}
