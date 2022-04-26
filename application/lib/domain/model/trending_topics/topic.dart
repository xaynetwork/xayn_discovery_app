import 'package:equatable/equatable.dart';

/// Hold session information,
/// Currently, this is limited to the detection of the app startup ([feedBatchRequestCount]),
/// feel free to extend this class when needed.
class Topic extends Equatable {
  final String name;
  final String query;
  final Uri image;

  const Topic({
    required this.name,
    required this.image,
    required this.query,
  });

  @override
  List<Object?> get props => [name, image, query];
}
