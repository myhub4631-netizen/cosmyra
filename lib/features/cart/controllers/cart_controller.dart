import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../catalog/models/product_model.dart';
import '../../coupons/controllers/coupon_controller.dart';
import '../models/cart_item_model.dart';

final cartProvider = StateNotifierProvider<CartNotifier, CartState>((ref) {
  return CartNotifier();
});

class CartState {
  final List<CartItem> items;
  final String? appliedCouponCode;
  final double couponDiscountPercent;
  final double fixedDiscountAmount;

  const CartState({
    this.items = const [],
    this.appliedCouponCode,
    this.couponDiscountPercent = 0.0,
    this.fixedDiscountAmount = 0.0,
  });

  int get totalItemCount => items.fold(0, (sum, item) => sum + item.quantity);

  double get subtotal => items.fold(0.0, (sum, item) => sum + item.totalPrice);

  double get couponDiscount {
    if (fixedDiscountAmount > 0) {
      return fixedDiscountAmount > subtotal ? subtotal : fixedDiscountAmount;
    }
    return (subtotal * (couponDiscountPercent / 100.0)).roundToDouble();
  }

  double get shippingFee => (subtotal - couponDiscount) >= 399.0 || items.isEmpty ? 0.0 : 49.0;

  double get finalTotal => (subtotal - couponDiscount + shippingFee).clamp(0.0, double.infinity);

  CartState copyWith({
    List<CartItem>? items,
    String? appliedCouponCode,
    double? couponDiscountPercent,
    double? fixedDiscountAmount,
    bool clearCoupon = false,
  }) {
    return CartState(
      items: items ?? this.items,
      appliedCouponCode: clearCoupon ? null : (appliedCouponCode ?? this.appliedCouponCode),
      couponDiscountPercent: clearCoupon ? 0.0 : (couponDiscountPercent ?? this.couponDiscountPercent),
      fixedDiscountAmount: clearCoupon ? 0.0 : (fixedDiscountAmount ?? this.fixedDiscountAmount),
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

  bool applyCouponModel(CouponModel coupon) {
    if (state.subtotal < coupon.minSpend) return false;

    if (coupon.discountType == 'percentage') {
      state = state.copyWith(
        appliedCouponCode: coupon.code,
        couponDiscountPercent: coupon.discountValue,
        fixedDiscountAmount: 0.0,
      );
    } else {
      state = state.copyWith(
        appliedCouponCode: coupon.code,
        couponDiscountPercent: 0.0,
        fixedDiscountAmount: coupon.discountValue,
      );
    }
    return true;
  }

  bool applyCoupon(String code, {List<CouponModel>? availableCoupons}) {
    final cleanCode = code.trim().toUpperCase();
    if (cleanCode.isEmpty) return false;

    if (availableCoupons != null && availableCoupons.isNotEmpty) {
      final matchedList = availableCoupons.where((c) => c.code.trim().toUpperCase() == cleanCode).toList();
      if (matchedList.isNotEmpty) {
        final coupon = matchedList.first;
        if (!coupon.isActive) return false;
        return applyCouponModel(coupon);
      }
    }
    return false;
  }

  void removeCoupon() {
    state = state.copyWith(clearCoupon: true);
  }

  void syncWithCoupons(List<CouponModel> coupons) {
    if (state.appliedCouponCode == null || state.appliedCouponCode!.isEmpty) return;
    final code = state.appliedCouponCode!.trim().toUpperCase();
    final matchedList = coupons.where((c) => c.code.trim().toUpperCase() == code).toList();

    if (matchedList.isEmpty) {
      state = state.copyWith(clearCoupon: true);
      return;
    }
    final matched = matchedList.first;

    if (!matched.isActive || state.subtotal < matched.minSpend) {
      state = state.copyWith(clearCoupon: true);
    } else {
      if (matched.discountType == 'percentage') {
        if (state.couponDiscountPercent != matched.discountValue || state.fixedDiscountAmount != 0.0) {
          state = state.copyWith(
            couponDiscountPercent: matched.discountValue,
            fixedDiscountAmount: 0.0,
          );
        }
      } else {
        if (state.fixedDiscountAmount != matched.discountValue || state.couponDiscountPercent != 0.0) {
          state = state.copyWith(
            couponDiscountPercent: 0.0,
            fixedDiscountAmount: matched.discountValue,
          );
        }
      }
    }
  }

  void refreshProductData(ProductModel updatedProduct) {
    if (state.items.isEmpty) return;
    final updatedList = state.items.map((item) {
      if (item.product.id == updatedProduct.id) {
        return item.copyWith(product: updatedProduct);
      }
      return item;
    }).toList();
    state = state.copyWith(items: updatedList);
  }

  void clearCart() {
    state = const CartState();
  }
}
