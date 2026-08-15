import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/theme/app_colors.dart';

class AdminPromotionsView extends ConsumerStatefulWidget {
  const AdminPromotionsView({super.key});

  @override
  ConsumerState<AdminPromotionsView> createState() => _AdminPromotionsViewState();
}

class _AdminPromotionsViewState extends ConsumerState<AdminPromotionsView> {
  final List<Map<String, dynamic>> _coupons = [
    {
      'code': 'COSMYRA10',
      'discountType': 'Percentage',
      'value': '10%',
      'minOrder': 299,
      'usageLimit': 1000,
      'usedCount': 142,
      'status': 'Active',
      'expiresOn': '2026-12-31',
    },
    {
      'code': 'VAIDYAM20',
      'discountType': 'Percentage',
      'value': '20%',
      'minOrder': 799,
      'usageLimit': 500,
      'usedCount': 88,
      'status': 'Active',
      'expiresOn': '2026-10-15',
    },
    {
      'code': 'WELCOME50',
      'discountType': 'Flat Amount',
      'value': '₹50 OFF',
      'minOrder': 399,
      'usageLimit': 2000,
      'usedCount': 412,
      'status': 'Active',
      'expiresOn': '2026-12-31',
    },
    {
      'code': 'MONSOON30',
      'discountType': 'Percentage',
      'value': '30%',
      'minOrder': 999,
      'usageLimit': 100,
      'usedCount': 100,
      'status': 'Expired',
      'expiresOn': '2026-07-31',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Promotions & Coupon Code Engine',
                    style: TextStyle(
                      fontFamily: 'serif',
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.goldAccent : AppColors.forestSageDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Create discount rules, set min order thresholds, and manage promotional campaigns.',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? AppColors.textLightSecondary : AppColors.textDarkSecondary,
                    ),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () => _showAddCouponDialog(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.forestSage,
                  foregroundColor: AppColors.softWhite,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                icon: const Icon(Icons.shopping_bag_outlined, size: 18),
                label: const Text('Create New Coupon'),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Coupons List
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _coupons.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final c = _coupons[index];
              final isActive = c['status'] == 'Active';

              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.goldAccent.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.local_offer_outlined, color: AppColors.goldAccent),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                SelectableText(
                                  c['code'],
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'monospace'),
                                ),
                                const SizedBox(width: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: isActive ? AppColors.success.withValues(alpha: 0.1) : AppColors.error.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    c['status'].toUpperCase(),
                                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isActive ? AppColors.success : AppColors.error),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Discount: ${c['value']} (${c['discountType']}) • Min Cart Value: ₹${c['minOrder']}',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Redeemed: ${c['usedCount']} / ${c['usageLimit']} times • Expiration: ${c['expiresOn']}',
                              style: TextStyle(fontSize: 11, color: isDark ? AppColors.textLightSecondary : AppColors.textDarkSecondary),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(isActive ? Icons.toggle_on : Icons.toggle_off, color: isActive ? AppColors.success : AppColors.textDarkSecondary, size: 28),
                        onPressed: () {
                          setState(() {
                            c['status'] = isActive ? 'Expired' : 'Active';
                          });
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showAddCouponDialog(BuildContext context) {
    final codeController = TextEditingController(text: 'BOTANICAL25');
    final valController = TextEditingController(text: '25');
    final minOrderController = TextEditingController(text: '499');
    final limitController = TextEditingController(text: '500');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Create Discount Coupon Code', style: TextStyle(fontFamily: 'serif', fontWeight: FontWeight.bold)),
          content: SizedBox(
            width: 450,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: codeController,
                    decoration: const InputDecoration(labelText: 'Coupon Code (UPPERCASE) *', hintText: 'e.g. HERBAL15'),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: valController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Discount Value (% or ₹) *'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: minOrderController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Min Cart Requirement (₹) *'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: limitController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Usage Limit (Total Redemptions) *'),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _coupons.insert(0, {
                    'code': codeController.text.toUpperCase(),
                    'discountType': 'Percentage',
                    'value': '${valController.text}%',
                    'minOrder': int.tryParse(minOrderController.text) ?? 499,
                    'usageLimit': int.tryParse(limitController.text) ?? 500,
                    'usedCount': 0,
                    'status': 'Active',
                    'expiresOn': '2026-12-31',
                  });
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Created coupon ${codeController.text.toUpperCase()}')),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.forestSage, foregroundColor: AppColors.softWhite),
              child: const Text('Publish Coupon'),
            ),
          ],
        );
      },
    );
  }
}
