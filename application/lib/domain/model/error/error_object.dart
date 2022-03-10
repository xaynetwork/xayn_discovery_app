import 'package:equatable/equatable.dart';

class ErrorObject extends Equatable {
  final Object? errorObject;
  final String? errorString;

  const ErrorObject([
    this.errorObject,
    this.errorString,
  ]);

  @override
  String toString() => errorString ?? errorObject?.toString() ?? '';

  bool get hasError => errorObject != null;

  @override
  List<Object?> get props => [errorObject, errorString];
}
