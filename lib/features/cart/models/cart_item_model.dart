import '../../catalog/models/product_model.dart';

/// Cart Item with Subscribe & Save options
class CartItem {
  final ProductModel product;
  final ProductVariant variant;
  final int quantity;
  final bool isSubscription;
  final int? subscriptionFrequencyDays; // e.g. 15, 30, 45, 60 days

  const CartItem({
    required this.product,
    required this.variant,
    this.quantity = 1,
    this.isSubscription = false,
    this.subscriptionFrequencyDays,
  });

  double get unitPrice {
    if (isSubscription) {
      // 10% Subscribe & Save discount
      return (variant.price * 0.90).roundToDouble();
    }
    return variant.price;
  }

  double get totalPrice => unitPrice * quantity;

  CartItem copyWith({
    ProductModel? product,
    ProductVariant? variant,
    int? quantity,
    bool? isSubscription,
    int? subscriptionFrequencyDays,
  }) {
    return CartItem(
      product: product ?? this.product,
      variant: variant ?? this.variant,
      quantity: quantity ?? this.quantity,
      isSubscription: isSubscription ?? this.isSubscription,
      subscriptionFrequencyDays: subscriptionFrequencyDays ?? this.subscriptionFrequencyDays,
    );
  }
}
