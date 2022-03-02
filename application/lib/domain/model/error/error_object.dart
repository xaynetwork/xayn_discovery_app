import 'package:freezed_annotation/freezed_annotation.dart';

@immutable
class ErrorObject {
  final Object? errorObject;
  final String? errorString;

  const ErrorObject([
    this.errorObject,
    this.errorString,
  ]);

  @override
  String toString() => errorString ?? errorObject?.toString() ?? '';

  bool get hasError => errorObject != null;
}
