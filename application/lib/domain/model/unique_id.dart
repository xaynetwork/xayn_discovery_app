import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

/// A class for uniquely identifying another object.
class UniqueId extends Equatable {
  /// The value used to identify an object.

  final String value;

  /// Default constructor which initializes the [value] with a random UUID.
  UniqueId() : value = const Uuid().v4();

  /// Creates a [UniqueId] from the passed [uniqueId] used as value.
  const UniqueId.fromTrustedString(String uniqueId) : value = uniqueId;

  @override
  List<Object?> get props => [value];
}
