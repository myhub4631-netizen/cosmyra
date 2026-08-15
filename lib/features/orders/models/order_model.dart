/// Order Item Model
class OrderItemModel {
  final String id;
  final String orderId;
  final String productVariantId;
  final String productName;
  final String variantName;
  final double unitPrice;
  final int quantity;
  final double totalPrice;

  const OrderItemModel({
    required this.id,
    required this.orderId,
    required this.productVariantId,
    required this.productName,
    required this.variantName,
    required this.unitPrice,
    required this.quantity,
    required this.totalPrice,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: json['id'] ?? '',
      orderId: json['order_id'] ?? '',
      productVariantId: json['product_variant_id'] ?? '',
      productName: json['product_name'] ?? '',
      variantName: json['variant_name'] ?? '',
      unitPrice: (json['unit_price_inr'] as num?)?.toDouble() ?? 0.0,
      quantity: json['quantity'] ?? 1,
      totalPrice: (json['total_price_inr'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'product_variant_id': productVariantId,
      'product_name': productName,
      'variant_name': variantName,
      'unit_price_inr': unitPrice,
      'quantity': quantity,
      'total_price_inr': totalPrice,
    };
  }
}

/// Order Model
class OrderModel {
  final String id;
  final String orderNumber;
  final String? userId;
  final bool isGuest;
  final String customerName;
  final String customerEmail;
  final String customerPhone;
  final Map<String, dynamic> shippingAddress;
  final double subtotal;
  final double discount;
  final double shippingFee;
  final double totalAmount;
  final String paymentMethod; // 'razorpay' | 'cod' | 'UPI' | etc.
  final String paymentStatus; // 'pending' | 'captured' | 'failed'
  final String fulfillmentStatus; // 'placed' | 'confirmed' | 'processing' | 'shipped' | 'delivered'
  final String? courierPartner; // 'shiprocket' | 'delhivery' | 'indiapost'
  final String? trackingNumber;
  final String? trackingUrl;
  final DateTime createdAt;
  final List<OrderItemModel> items;

  const OrderModel({
    required this.id,
    required this.orderNumber,
    this.userId,
    required this.isGuest,
    required this.customerName,
    required this.customerEmail,
    required this.customerPhone,
    required this.shippingAddress,
    required this.subtotal,
    required this.discount,
    required this.shippingFee,
    required this.totalAmount,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.fulfillmentStatus,
    this.courierPartner,
    this.trackingNumber,
    this.trackingUrl,
    required this.createdAt,
    this.items = const [],
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json['order_items'];
    List<OrderItemModel> parsedItems = [];
    if (rawItems is List) {
      parsedItems = rawItems.map((i) => OrderItemModel.fromJson(Map<String, dynamic>.from(i as Map))).toList();
    }

    return OrderModel(
      id: json['id'] ?? '',
      orderNumber: json['order_number'] ?? '',
      userId: json['user_id'],
      isGuest: json['is_guest'] ?? false,
      customerName: json['customer_name'] ?? '',
      customerEmail: json['customer_email'] ?? '',
      customerPhone: json['customer_phone'] ?? '',
      shippingAddress: json['shipping_address'] is Map
          ? Map<String, dynamic>.from(json['shipping_address'] as Map)
          : {},
      subtotal: (json['subtotal_inr'] as num?)?.toDouble() ?? 0.0,
      discount: (json['discount_inr'] as num?)?.toDouble() ?? 0.0,
      shippingFee: (json['shipping_fee_inr'] as num?)?.toDouble() ?? 0.0,
      totalAmount: (json['total_amount_inr'] as num?)?.toDouble() ?? 0.0,
      paymentMethod: json['payment_method'] ?? 'cod',
      paymentStatus: json['payment_status'] ?? 'pending',
      fulfillmentStatus: json['fulfillment_status'] ?? 'placed',
      courierPartner: json['courier_partner'],
      trackingNumber: json['tracking_number'],
      trackingUrl: json['tracking_url'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at']) ?? DateTime.now()
          : DateTime.now(),
      items: parsedItems,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
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
      'payment_status': paymentStatus,
      'fulfillment_status': fulfillmentStatus,
      'courier_partner': courierPartner,
      'tracking_number': trackingNumber,
      'tracking_url': trackingUrl,
      'created_at': createdAt.toIso8601String(),
      'order_items': items.map((i) => i.toJson()).toList(),
    };
  }
}
