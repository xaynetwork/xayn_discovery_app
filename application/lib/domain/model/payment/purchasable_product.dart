import 'package:equatable/equatable.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

enum PurchasableProductStatus {
  purchasable,
  purchased,
  pending,
  restored,
  canceled,
}

typedef PurchasableProductId = String;

@immutable
class PurchasableProduct extends Equatable {
  final PurchasableProductId id;
  final String title;
  final String description;
  final String price;
  final PurchasableProductStatus status;

  const PurchasableProduct({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.status,
  });

  @override
  List<Object> get props => [
        id,
        title,
        description,
        price,
        status,
      ];

  PurchasableProduct copyWith(PurchasableProductStatus status) =>
      PurchasableProduct(
        id: id,
        title: title,
        description: description,
        price: price,
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
