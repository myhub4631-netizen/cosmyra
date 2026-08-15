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
          decoded.map((item) => OrderModel.fromJson(Map<String, dynamic>.from(item as Map))),
        );
      }
    } catch (_) {}

    if (_localOrders.isEmpty) {
      _seedDefaultDemoOrders();
    }
    _isLoaded = true;
  }

  void _seedDefaultDemoOrders() {
    _localOrders.addAll([
      OrderModel(
        id: 'ord-demo-1',
        orderNumber: 'CSM-2026-928412',
        userId: 'usr-1',
        isGuest: false,
        customerName: 'Aarav Sharma',
        customerEmail: 'aarav.sharma@example.com',
        customerPhone: '+91 98765 43210',
        shippingAddress: {
          'address': '12 Sector 4, Salt Lake',
          'city': 'Kolkata',
          'state': 'West Bengal',
          'pincode': '700091'
        },
        subtotal: 538.0,
        discount: 0.0,
        shippingFee: 0.0,
        totalAmount: 538.0,
        paymentMethod: 'UPI / QR',
        paymentStatus: 'captured',
        fulfillmentStatus: 'delivered',
        courierPartner: 'Shiprocket',
        trackingNumber: 'AWB1234567890',
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
        items: [
          OrderItemModel(
            id: 'itm-1',
            orderId: 'ord-demo-1',
            productVariantId: 'v-1',
            productName: 'Kumkumadi Radiance Elixir',
            variantName: '30ml Serum Bottle',
            unitPrice: 538.0,
            quantity: 1,
            totalPrice: 538.0,
          )
        ],
      ),
      OrderModel(
        id: 'ord-demo-2',
        orderNumber: 'CSM-2026-928411',
        userId: 'usr-2',
        isGuest: false,
        customerName: 'Priya Verma',
        customerEmail: 'priya.verma@example.com',
        customerPhone: '+91 91234 56789',
        shippingAddress: {
          'address': '45 Park Street, Indiranagar',
          'city': 'Bengaluru',
          'state': 'Karnataka',
          'pincode': '560038'
        },
        subtotal: 339.0,
        discount: 0.0,
        shippingFee: 0.0,
        totalAmount: 339.0,
        paymentMethod: 'Credit / Debit Card',
        paymentStatus: 'captured',
        fulfillmentStatus: 'shipped',
        courierPartner: 'Delhivery',
        trackingNumber: 'AWB9876543210',
        createdAt: DateTime.now().subtract(const Duration(hours: 6)),
        items: [
          OrderItemModel(
            id: 'itm-2',
            orderId: 'ord-demo-2',
            productVariantId: 'v-2',
            productName: 'Bhringraj Hair Defense Oil',
            variantName: '200ml Bottle',
            unitPrice: 339.0,
            quantity: 1,
            totalPrice: 339.0,
          )
        ],
      ),
      OrderModel(
        id: 'ord-demo-3',
        orderNumber: 'CSM-2026-928410',
        userId: 'usr-3',
        isGuest: false,
        customerName: 'Rohan Gupta',
        customerEmail: 'rohan.g@example.com',
        customerPhone: '+91 99887 76655',
        shippingAddress: {
          'address': '78 Civil Lines',
          'city': 'Jaipur',
          'state': 'Rajasthan',
          'pincode': '302006'
        },
        subtotal: 1299.0,
        discount: 100.0,
        shippingFee: 0.0,
        totalAmount: 1199.0,
        paymentMethod: 'Cash on Delivery',
        paymentStatus: 'pending',
        fulfillmentStatus: 'confirmed',
        courierPartner: 'Blue Dart',
        trackingNumber: 'AWB5544332211',
        createdAt: DateTime.now().subtract(const Duration(hours: 12)),
        items: [
          OrderItemModel(
            id: 'itm-3',
            orderId: 'ord-demo-3',
            productVariantId: 'v-3',
            productName: 'Nalpamaradi Body Thailam',
            variantName: '100ml Oil Bottle',
            unitPrice: 1299.0,
            quantity: 1,
            totalPrice: 1299.0,
          )
        ],
      ),
    ]);
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
}
