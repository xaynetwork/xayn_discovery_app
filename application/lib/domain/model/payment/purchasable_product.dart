import 'package:equatable/equatable.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

enum PurchasableProductStatus {
  purchasable,
  purchased,
  purchasePending,
  restored,
  restorePending,
  canceled,
}

typedef PurchasableProductId = String;

@immutable
class PurchasableProduct extends Equatable {
  final PurchasableProductId id;
  final String title;
  final String description;
  final String price;
  final String currency;
  final String? duration;
  final PurchasableProductStatus status;

  const PurchasableProduct({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.currency,
    required this.duration,
    required this.status,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        price,
        currency,
        duration,
        status,
      ];

  PurchasableProduct copyWith(PurchasableProductStatus status) =>
      PurchasableProduct(
        id: id,
        title: title,
        description: description,
        price: price,
        currency: currency,
        duration: duration,
        status: status,
      );

  bool get canBePurchased =>
      status == PurchasableProductStatus.purchasable ||
      status == PurchasableProductStatus.canceled;
}

extension PurchasableProductStatusExtension on PurchasableProductStatus {
  bool get isPurchased => this == PurchasableProductStatus.purchased;
  bool get isRestored => this == PurchasableProductStatus.restored;
}
