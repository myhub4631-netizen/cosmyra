import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/supabase_config.dart';
import '../../cart/models/cart_item_model.dart';
import '../models/order_model.dart';

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  return OrderRepository();
});

final userOrdersFutureProvider = FutureProvider<List<OrderModel>>((ref) async {
  return ref.watch(orderRepositoryProvider).getUserOrders();
});

final allAdminOrdersFutureProvider = FutureProvider<List<OrderModel>>((ref) async {
  return ref.watch(orderRepositoryProvider).getAllOrdersForAdmin();
});

class OrderRepository {
  /// Place an order (handles guest or authenticated customer)
  Future<OrderModel> placeOrder({
    String? userId,
    required bool isGuest,
    required String customerName,
    required String customerEmail,
    required String customerPhone,
    required Map<String, dynamic> shippingAddress,
    required List<CartItem> cartItems,
    required double subtotal,
    required double discount,
    required double shippingFee,
    required double totalAmount,
    required String paymentMethod,
  }) async {
    final orderNumber = 'CSM-${DateTime.now().year}-${Random().nextInt(900000) + 100000}';

    final orderData = {
      'order_number': orderNumber,
      'user_id': userId,
      'is_guest': isGuest,
      'customer_name': customerName,
      'customer_email': customerEmail,
      'customer_phone': customerPhone,
      'shipping_address': shippingAddress,
      'subtotal_inr': subtotal,
      'discount_inr': discount,
      'shipping_fee_inr': shippingFee,
      'total_amount_inr': totalAmount,
      'payment_method': paymentMethod,
      'payment_status': paymentMethod == 'cod' ? 'pending' : 'captured',
      'fulfillment_status': 'placed',
    };

    String generatedOrderId = 'ord-${DateTime.now().millisecondsSinceEpoch}';

    if (SupabaseConfig.isConfigured) {
      try {
        final orderRes = await supabase.from('orders').insert(orderData).select().single();
        generatedOrderId = orderRes['id'];

        // Insert Order Items
        final itemsData = cartItems.map((item) => {
              'order_id': generatedOrderId,
              'product_variant_id': item.variant.id,
              'product_name': item.product.name,
              'variant_name': item.variant.sizeLabel,
              'unit_price_inr': item.unitPrice,
              'quantity': item.quantity,
              'total_price_inr': item.totalPrice,
            }).toList();

        await supabase.from('order_items').insert(itemsData);

        // Handle Subscribe & Save records if user is logged in
        if (userId != null) {
          for (final item in cartItems.where((i) => i.isSubscription)) {
            await supabase.from('subscriptions').insert({
              'user_id': userId,
              'product_variant_id': item.variant.id,
              'frequency_days': item.subscriptionFrequencyDays ?? 30,
              'discount_percentage': 10,
              'status': 'active',
              'next_renewal_date': DateTime.now()
                  .add(Duration(days: item.subscriptionFrequencyDays ?? 30))
                  .toIso8601String()
                  .split('T')[0],
              'payment_method': paymentMethod,
            });
          }
        }
      } catch (e) {
        // Log error and continue with local constructed model
      }
    }

    final placedOrder = OrderModel(
      id: generatedOrderId,
      orderNumber: orderNumber,
      userId: userId,
      isGuest: isGuest,
      customerName: customerName,
      customerEmail: customerEmail,
      customerPhone: customerPhone,
      shippingAddress: shippingAddress,
      subtotal: subtotal,
      discount: discount,
      shippingFee: shippingFee,
      totalAmount: totalAmount,
      paymentMethod: paymentMethod,
      paymentStatus: paymentMethod == 'cod' ? 'pending' : 'captured',
      fulfillmentStatus: 'placed',
      createdAt: DateTime.now(),
      items: cartItems
          .map((c) => OrderItemModel(
                id: 'itm-${c.variant.id}',
                orderId: generatedOrderId,
                productVariantId: c.variant.id,
                productName: c.product.name,
                variantName: c.variant.sizeLabel,
                unitPrice: c.unitPrice,
                quantity: c.quantity,
                totalPrice: c.totalPrice,
              ))
          .toList(),
    );

    _localOrders.insert(0, placedOrder);
    return placedOrder;
  }

  /// Get orders for current logged-in user
  Future<List<OrderModel>> getUserOrders() async {
    if (SupabaseConfig.isConfigured && supabase.auth.currentUser != null) {
      try {
        final response = await supabase
            .from('orders')
            .select('*, order_items(*)')
            .eq('user_id', supabase.auth.currentUser!.id)
            .order('created_at', ascending: false);

        if (response.isNotEmpty) {
          return (response as List).map((json) => OrderModel.fromJson(json)).toList();
        }
      } catch (_) {}
    }

    return _localOrders;
  }

  /// Get all orders for Admin Web Dashboard
  Future<List<OrderModel>> getAllOrdersForAdmin() async {
    if (SupabaseConfig.isConfigured) {
      try {
        final response = await supabase
            .from('orders')
            .select('*, order_items(*)')
            .order('created_at', ascending: false);

        if (response.isNotEmpty) {
          return (response as List).map((json) => OrderModel.fromJson(json)).toList();
        }
      } catch (_) {}
    }

    return _localOrders.isEmpty ? _seedAdminOrders : _localOrders;
  }

  /// Update order courier and status (Admin feature)
  Future<bool> updateOrderFulfillment({
    required String orderId,
    required String status,
    String? courier,
    String? trackingNumber,
  }) async {
    if (SupabaseConfig.isConfigured) {
      try {
        await supabase.from('orders').update({
          'fulfillment_status': status,
          'courier_partner': courier,
          'tracking_number': trackingNumber,
        }).eq('id', orderId);
      } catch (_) {}
    }

    final index = _localOrders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      final current = _localOrders[index];
      _localOrders[index] = OrderModel(
        id: current.id,
        orderNumber: current.orderNumber,
        userId: current.userId,
        isGuest: current.isGuest,
        customerName: current.customerName,
        customerEmail: current.customerEmail,
        customerPhone: current.customerPhone,
        shippingAddress: current.shippingAddress,
        subtotal: current.subtotal,
        discount: current.discount,
        shippingFee: current.shippingFee,
        totalAmount: current.totalAmount,
        paymentMethod: current.paymentMethod,
        paymentStatus: current.paymentStatus,
        fulfillmentStatus: status,
        courierPartner: courier ?? current.courierPartner,
        trackingNumber: trackingNumber ?? current.trackingNumber,
        trackingUrl: current.trackingUrl,
        createdAt: current.createdAt,
        items: current.items,
      );
    }
    return true;
  }

  static final List<OrderModel> _localOrders = [];

  static final List<OrderModel> _seedAdminOrders = [
    OrderModel(
      id: 'seed-ord-1',
      orderNumber: 'CSM-2026-928412',
      isGuest: false,
      customerName: 'Aarav Sharma',
      customerEmail: 'aarav.sharma@example.com',
      customerPhone: '+91 9876543210',
      shippingAddress: {
        'address_line1': 'Flat 402, Green Glen Heights, Bellandur',
        'city': 'Bengaluru',
        'state': 'Karnataka',
        'pincode': '560103',
      },
      subtotal: 598.0,
      discount: 59.8,
      shippingFee: 0.0,
      totalAmount: 538.2,
      paymentMethod: 'razorpay',
      paymentStatus: 'captured',
      fulfillmentStatus: 'placed',
      courierPartner: 'shiprocket',
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      items: const [
        OrderItemModel(
          id: 'itm-1',
          orderId: 'seed-ord-1',
          productVariantId: 'var-1-200',
          productName: 'Vaidyam Anti-Dandruff Herbal Shampoo',
          variantName: '200 ml',
          unitPrice: 399.0,
          quantity: 1,
          totalPrice: 399.0,
        ),
        OrderItemModel(
          id: 'itm-2',
          orderId: 'seed-ord-1',
          productVariantId: 'var-2-125',
          productName: 'Vaidyam De-Tan Botanical Handcrafted Soap',
          variantName: '125 g',
          unitPrice: 199.0,
          quantity: 1,
          totalPrice: 199.0,
        ),
      ],
    ),
  ];
}
