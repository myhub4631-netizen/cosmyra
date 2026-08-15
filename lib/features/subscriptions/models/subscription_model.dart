/// Subscribe & Save Subscription Model
class SubscriptionModel {
  final String id;
  final String userId;
  final String productVariantId;
  final String? addressId;
  final int frequencyDays; // 15, 30, 45, 60
  final int discountPercentage;
  final String status; // 'active', 'paused', 'cancelled'
  final DateTime nextRenewalDate;
  final String paymentMethod;
  final String? productName;
  final String? variantSize;
  final double? price;

  const SubscriptionModel({
    required this.id,
    required this.userId,
    required this.productVariantId,
    this.addressId,
    required this.frequencyDays,
    required this.discountPercentage,
    required this.status,
    required this.nextRenewalDate,
    required this.paymentMethod,
    this.productName,
    this.variantSize,
    this.price,
  });

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionModel(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      productVariantId: json['product_variant_id'] ?? '',
      addressId: json['address_id'],
      frequencyDays: json['frequency_days'] ?? 30,
      discountPercentage: json['discount_percentage'] ?? 10,
      status: json['status'] ?? 'active',
      nextRenewalDate: json['next_renewal_date'] != null
          ? DateTime.tryParse(json['next_renewal_date']) ?? DateTime.now().add(const Duration(days: 30))
          : DateTime.now().add(const Duration(days: 30)),
      paymentMethod: json['payment_method'] ?? 'cod',
    );
  }
}
