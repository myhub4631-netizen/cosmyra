import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../catalog/models/product_model.dart';
import '../models/cart_item_model.dart';

final cartProvider = StateNotifierProvider<CartNotifier, CartState>((ref) {
  return CartNotifier();
});

class CartState {
  final List<CartItem> items;
  final String? appliedCouponCode;
  final double couponDiscountPercent;

  const CartState({
    this.items = const [],
    this.appliedCouponCode,
    this.couponDiscountPercent = 0.0,
  });

  int get totalItemCount => items.fold(0, (sum, item) => sum + item.quantity);

  double get subtotal => items.fold(0.0, (sum, item) => sum + item.totalPrice);

  double get couponDiscount => (subtotal * (couponDiscountPercent / 100.0)).roundToDouble();

  double get shippingFee => (subtotal - couponDiscount) >= 499.0 || items.isEmpty ? 0.0 : 49.0;

  double get finalTotal => (subtotal - couponDiscount + shippingFee).clamp(0.0, double.infinity);

  CartState copyWith({
    List<CartItem>? items,
    String? appliedCouponCode,
    double? couponDiscountPercent,
    bool clearCoupon = false,
  }) {
    return CartState(
      items: items ?? this.items,
      appliedCouponCode: clearCoupon ? null : (appliedCouponCode ?? this.appliedCouponCode),
      couponDiscountPercent: clearCoupon ? 0.0 : (couponDiscountPercent ?? this.couponDiscountPercent),
    );
  }
}

class CartNotifier extends StateNotifier<CartState> {
  CartNotifier() : super(const CartState());

  void addItem({
    required ProductModel product,
    required ProductVariant variant,
    int quantity = 1,
    bool isSubscription = false,
    int? subscriptionFrequencyDays,
  }) {
    final existingIndex = state.items.indexWhere(
      (item) => item.variant.id == variant.id && item.isSubscription == isSubscription,
    );

    if (existingIndex != -1) {
      final updatedList = List<CartItem>.from(state.items);
      final current = updatedList[existingIndex];
      updatedList[existingIndex] = current.copyWith(
        quantity: current.quantity + quantity,
      );
      state = state.copyWith(items: updatedList);
    } else {
      state = state.copyWith(
        items: [
          ...state.items,
          CartItem(
            product: product,
            variant: variant,
            quantity: quantity,
            isSubscription: isSubscription,
            subscriptionFrequencyDays: subscriptionFrequencyDays ?? (isSubscription ? 30 : null),
          ),
        ],
      );
    }
  }

  void updateQuantity(int index, int newQuantity) {
    if (newQuantity <= 0) {
      removeItem(index);
      return;
    }
    final updatedList = List<CartItem>.from(state.items);
    updatedList[index] = updatedList[index].copyWith(quantity: newQuantity);
    state = state.copyWith(items: updatedList);
  }

  void removeItem(int index) {
    final updatedList = List<CartItem>.from(state.items);
    updatedList.removeAt(index);
    state = state.copyWith(items: updatedList);
  }

  void toggleSubscription(int index, bool isSubscription, {int frequency = 30}) {
    final updatedList = List<CartItem>.from(state.items);
    final item = updatedList[index];
    updatedList[index] = item.copyWith(
      isSubscription: isSubscription,
      subscriptionFrequencyDays: isSubscription ? frequency : null,
    );
    state = state.copyWith(items: updatedList);
  }

  bool applyCoupon(String code) {
    final cleanCode = code.trim().toUpperCase();
    if (cleanCode == 'COSMYRA10') {
      state = state.copyWith(
        appliedCouponCode: cleanCode,
        couponDiscountPercent: 10.0,
      );
      return true;
    }
    return false;
  }

  void removeCoupon() {
    state = state.copyWith(clearCoupon: true);
  }

  void clearCart() {
    state = const CartState();
  }
}
