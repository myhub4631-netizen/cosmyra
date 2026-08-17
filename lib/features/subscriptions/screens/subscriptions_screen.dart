import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../config/theme/app_colors.dart';
import '../../catalog/repositories/product_repository.dart';

class SubscriptionsScreen extends ConsumerStatefulWidget {
  const SubscriptionsScreen({super.key});

  @override
  ConsumerState<SubscriptionsScreen> createState() => _SubscriptionsScreenState();
}

class _SubscriptionsScreenState extends ConsumerState<SubscriptionsScreen> {
  // Sample active subscription state
  final List<Map<String, dynamic>> _activeSubscriptions = [
    {
      'id': 'sub-1',
      'productName': 'Vaidyam Anti-Dandruff Herbal Shampoo (200 ml)',
      'frequencyDays': 30,
      'discount': '10% OFF',
      'price': 359,
      'status': 'Active',
      'nextDate': DateTime.now().add(const Duration(days: 18)),
      'paymentMode': 'Cash on Delivery',
      'image': 'assets/images/shampoo.jpg',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productsFutureProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Subscribe & Save Club'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Benefits Banner
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppColors.luxurySageGradient,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: AppColors.goldAccent,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.autorenew, color: AppColors.forestSageDark, size: 18),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Cosmyra Auto-Refill Club',
                        style: TextStyle(
                          color: AppColors.goldAccentLight,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Save 10% on Every Single Order.',
                    style: TextStyle(
                      fontFamily: 'serif',
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Enjoy hassle-free automatic doorstep deliveries on your own schedule (15, 30, 45, 60 days). Pause, change dates, or cancel anytime with zero cancellation fees.',
                    style: TextStyle(color: Color(0xFFD3E0D8), fontSize: 12, height: 1.4),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 2. Active Subscriptions Section
            const Text(
              'My Active Subscriptions',
              style: TextStyle(fontFamily: 'serif', fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            if (_activeSubscriptions.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.charcoalCard : AppColors.creamCard,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: isDark ? AppColors.charcoalBorder : AppColors.creamBorder),
                ),
                child: const Center(
                  child: Text('No active subscriptions. Choose Subscribe & Save on any product page to save 10%!'),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _activeSubscriptions.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final sub = _activeSubscriptions[index];
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.asset(
                                  sub['image'] as String,
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      sub['productName'] as String,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Text(
                                          '₹${sub['price']}/delivery',
                                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: AppColors.success.withOpacity(0.15),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            sub['discount'] as String,
                                            style: const TextStyle(color: AppColors.success, fontSize: 10, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Next Refill: ${DateFormat('dd MMM yyyy').format(sub['nextDate'] as DateTime)}',
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.forestSage),
                              ),
                              Text(
                                'Every ${sub['frequencyDays']} Days',
                                style: TextStyle(fontSize: 12, color: isDark ? AppColors.textLightSecondary : AppColors.textDarkSecondary),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 8)),
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Subscription paused for 30 days.')),
                                    );
                                  },
                                  child: const Text('Pause Delivery', style: TextStyle(fontSize: 11)),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 8)),
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Order dispatched early!')),
                                    );
                                  },
                                  child: const Text('Ship Now', style: TextStyle(fontSize: 11)),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

            const SizedBox(height: 28),

            // 3. Recommended Refill SKUs
            const Text(
              'Popular Products to Subscribe & Save',
              style: TextStyle(fontFamily: 'serif', fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            productsAsync.when(
              data: (products) => ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: products.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final p = products[index];
                  final v = p.defaultVariant;
                  final subPrice = (v.price * 0.90).roundToDouble();

                  return Card(
                    child: ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Image.asset(
                          p.imageUrls.isNotEmpty ? p.imageUrls.first : 'assets/images/shampoo.jpg',
                          width: 45,
                          height: 45,
                          fit: BoxFit.cover,
                        ),
                      ),
                      title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5)),
                      subtitle: Text('Refill Price: ₹${subPrice.toInt()} (-10%)', style: const TextStyle(color: AppColors.success, fontSize: 11, fontWeight: FontWeight.bold)),
                      trailing: ElevatedButton(
                        style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6)),
                        onPressed: () => context.push('/product/${p.id}', extra: p),
                        child: const Text('Subscribe', style: TextStyle(fontSize: 11)),
                      ),
                    ),
                  );
                },
              ),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
