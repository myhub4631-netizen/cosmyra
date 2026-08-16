import 'dart:convert';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  static const String _storageKey = 'cosmyra_all_orders_v3';
  static final List<OrderModel> _localOrders = [];
  static bool _isLoaded = false;

  Future<void> _ensureLoaded() async {
    if (_isLoaded && _localOrders.isNotEmpty) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonStr = prefs.getString(_storageKey);
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(jsonStr);
        _localOrders.clear();
        _localOrders.addAll(
          decoded
              .map((item) => OrderModel.fromJson(Map<String, dynamic>.from(item as Map)))
              .where((o) => !o.id.startsWith('ord-demo-') && o.customerName != 'Aarav Sharma' && !o.customerEmail.contains('example.com')),
        );
      }
    } catch (_) {}

    _localOrders.removeWhere((o) => o.id.startsWith('ord-demo-') || o.customerName == 'Aarav Sharma' || o.customerEmail.contains('example.com'));
    _isLoaded = true;
  }

  Future<void> _saveOrdersToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = _localOrders.map((o) => o.toJson()).toList();
      await prefs.setString(_storageKey, jsonEncode(jsonList));
    } catch (_) {}
  }

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
    await _ensureLoaded();
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
      'payment_status': paymentMethod.toLowerCase().contains('cod') || paymentMethod == 'Cash on Delivery' ? 'pending' : 'captured',
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
      } catch (_) {}
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
      paymentStatus: paymentMethod.toLowerCase().contains('cod') || paymentMethod == 'Cash on Delivery' ? 'pending' : 'captured',
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
    await _saveOrdersToStorage();
    return placedOrder;
  }

  /// Get orders for current logged-in user
  Future<List<OrderModel>> getUserOrders({String? email}) async {
    await _ensureLoaded();
    final List<OrderModel> remoteOrders = [];

    if (SupabaseConfig.isConfigured && supabase.auth.currentUser != null) {
      try {
        final response = await supabase
            .from('orders')
            .select('*, order_items(*)')
            .eq('user_id', supabase.auth.currentUser!.id)
            .order('created_at', ascending: false);

        if (response.isNotEmpty) {
          remoteOrders.addAll(
            (response as List).map((json) => OrderModel.fromJson(Map<String, dynamic>.from(json as Map))),
          );
        }
      } catch (_) {}
    }

    final Map<String, OrderModel> mergedMap = {};
    for (var o in _localOrders) {
      mergedMap[o.orderNumber] = o;
    }
    for (var o in remoteOrders) {
      mergedMap[o.orderNumber] = o;
    }

    final mergedList = mergedMap.values.toList();
    mergedList.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return mergedList;
  }

  /// Get all orders for Admin Web Dashboard
  Future<List<OrderModel>> getAllOrdersForAdmin() async {
    await _ensureLoaded();
    final List<OrderModel> remoteOrders = [];

    if (SupabaseConfig.isConfigured) {
      try {
        final response = await supabase
            .from('orders')
            .select('*, order_items(*)')
            .order('created_at', ascending: false);

        if (response.isNotEmpty) {
          remoteOrders.addAll(
            (response as List).map((json) => OrderModel.fromJson(Map<String, dynamic>.from(json as Map))),
          );
        }
      } catch (_) {}
    }

    final Map<String, OrderModel> mergedMap = {};
    for (var o in _localOrders) {
      mergedMap[o.orderNumber] = o;
    }
    for (var o in remoteOrders) {
      mergedMap[o.orderNumber] = o;
    }

    final mergedList = mergedMap.values.toList();
    mergedList.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return mergedList;
  }

  /// Update order courier and status (Admin feature)
  Future<bool> updateOrderFulfillment({
    required String orderId,
    required String status,
    String? courier,
    String? trackingNumber,
  }) async {
    await _ensureLoaded();
    if (SupabaseConfig.isConfigured) {
      try {
        await supabase.from('orders').update({
          'fulfillment_status': status,
          'courier_partner': courier,
          'tracking_number': trackingNumber,
        }).eq('id', orderId);
      } catch (_) {}
    }

    final index = _localOrders.indexWhere((o) => o.id == orderId || o.orderNumber == orderId);
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
      await _saveOrdersToStorage();
    }
    return true;
  }

  /// Delete an order (Admin feature)
  Future<bool> deleteOrder(String orderId) async {
    await _ensureLoaded();
    if (SupabaseConfig.isConfigured) {
      try {
        await supabase.from('orders').delete().eq('id', orderId);
      } catch (_) {}
    }

    _localOrders.removeWhere((o) => o.id == orderId || o.orderNumber == orderId);
    await _saveOrdersToStorage();
    return true;
  }

  /// Update full order details (Admin feature)
  Future<bool> updateOrderFullDetails({
    required String orderId,
    String? customerName,
    String? customerEmail,
    String? customerPhone,
    Map<String, dynamic>? shippingAddress,
    String? paymentStatus,
    String? paymentMethod,
    String? fulfillmentStatus,
    String? courierPartner,
    String? trackingNumber,
    double? subtotal,
    double? discount,
    double? shippingFee,
    double? totalAmount,
  }) async {
    await _ensureLoaded();
    final index = _localOrders.indexWhere((o) => o.id == orderId || o.orderNumber == orderId);
    if (index != -1) {
      final current = _localOrders[index];
      final updated = OrderModel(
        id: current.id,
        orderNumber: current.orderNumber,
        userId: current.userId,
        isGuest: current.isGuest,
        customerName: customerName ?? current.customerName,
        customerEmail: customerEmail ?? current.customerEmail,
        customerPhone: customerPhone ?? current.customerPhone,
        shippingAddress: shippingAddress ?? current.shippingAddress,
        subtotal: subtotal ?? current.subtotal,
        discount: discount ?? current.discount,
        shippingFee: shippingFee ?? current.shippingFee,
        totalAmount: totalAmount ?? current.totalAmount,
        paymentMethod: paymentMethod ?? current.paymentMethod,
        paymentStatus: paymentStatus ?? current.paymentStatus,
        fulfillmentStatus: fulfillmentStatus ?? current.fulfillmentStatus,
        courierPartner: courierPartner ?? current.courierPartner,
        trackingNumber: trackingNumber ?? current.trackingNumber,
        trackingUrl: current.trackingUrl,
        createdAt: current.createdAt,
        items: current.items,
      );
      _localOrders[index] = updated;
      await _saveOrdersToStorage();
    }

    if (SupabaseConfig.isConfigured) {
      try {
        final Map<String, dynamic> payload = {};
        if (customerName != null) payload['customer_name'] = customerName;
        if (customerEmail != null) payload['customer_email'] = customerEmail;
        if (customerPhone != null) payload['customer_phone'] = customerPhone;
        if (shippingAddress != null) payload['shipping_address'] = shippingAddress;
        if (paymentStatus != null) payload['payment_status'] = paymentStatus;
        if (paymentMethod != null) payload['payment_method'] = paymentMethod;
        if (fulfillmentStatus != null) payload['fulfillment_status'] = fulfillmentStatus;
        if (courierPartner != null) payload['courier_partner'] = courierPartner;
        if (trackingNumber != null) payload['tracking_number'] = trackingNumber;
        if (totalAmount != null) payload['total_amount_inr'] = totalAmount;

        if (payload.isNotEmpty) {
          await supabase.from('orders').update(payload).eq('id', orderId);
        }
      } catch (_) {}
    }
    return true;
  }
}
