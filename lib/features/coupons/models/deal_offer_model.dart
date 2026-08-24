class DealOfferModel {
  final String id;
  final String title;
  final String description;
  final String buttonLabel;
  final String dealType; // 'coupons', 'referral', 'bogo', 'ugc', 'custom'
  final String targetRoute;
  final String cardTheme; // 'red', 'green', 'blue', 'purple'
  final bool isActive;
  final String? badgeText;

  const DealOfferModel({
    required this.id,
    required this.title,
    required this.description,
    required this.buttonLabel,
    required this.dealType,
    required this.targetRoute,
    required this.cardTheme,
    this.isActive = true,
    this.badgeText,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'buttonLabel': buttonLabel,
        'dealType': dealType,
        'targetRoute': targetRoute,
        'cardTheme': cardTheme,
        'isActive': isActive,
        'badgeText': badgeText,
      };

  factory DealOfferModel.fromJson(Map<String, dynamic> json) {
    return DealOfferModel(
      id: json['id']?.toString() ?? 'deal-${DateTime.now().millisecondsSinceEpoch}',
      title: json['title']?.toString() ?? 'Special Deal',
      description: json['description']?.toString() ?? 'Explore amazing offers and save more!',
      buttonLabel: json['buttonLabel']?.toString() ?? 'View Offer',
      dealType: json['dealType']?.toString() ?? 'coupons',
      targetRoute: json['targetRoute']?.toString() ?? '/shop',
      cardTheme: json['cardTheme']?.toString() ?? 'red',
      isActive: json['isActive'] ?? true,
      badgeText: json['badgeText']?.toString(),
    );
  }
}
