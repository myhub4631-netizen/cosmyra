import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/theme/app_colors.dart';

class AdminSubscriptionsView extends ConsumerStatefulWidget {
  const AdminSubscriptionsView({super.key});

  @override
  ConsumerState<AdminSubscriptionsView> createState() => _AdminSubscriptionsViewState();
}

class _AdminSubscriptionsViewState extends ConsumerState<AdminSubscriptionsView> {
  // Mock subscriptions data list
  final List<Map<String, dynamic>> _subscriptions = [
    {
      'id': 'SUB-9821',
      'customerName': 'Priya Verma',
      'email': 'priya.verma@example.com',
      'productName': 'Vaidyam Anti-Dandruff Herbal Shampoo (200 ml)',
      'frequency': 'Monthly (Every 30 Days)',
      'discountPct': 15,
      'pricePerCycle': 339,
      'nextRefillDate': '2026-08-28',
      'status': 'Active',
      'refillsDelivered': 4,
    },
    {
      'id': 'SUB-9822',
      'customerName': 'Ananya Roy',
      'email': 'ananya.roy@gmail.com',
      'productName': 'Vaidyam Kumkumadi Radiance Face Cleanser (125 g)',
      'frequency': 'Bi-Monthly (Every 60 Days)',
      'discountPct': 15,
      'pricePerCycle': 296,
      'nextRefillDate': '2026-09-10',
      'status': 'Active',
      'refillsDelivered': 2,
    },
    {
      'id': 'SUB-9823',
      'customerName': 'Rahul Sharma',
      'email': 'rahul.s@outlook.com',
      'productName': 'Vaidyam Neem & Tulsi Purifying Body Soap (150 g)',
      'frequency': 'Bi-Weekly (Every 14 Days)',
      'discountPct': 15,
      'pricePerCycle': 169,
      'nextRefillDate': '2026-08-18',
      'status': 'Active',
      'refillsDelivered': 8,
    },
    {
      'id': 'SUB-9824',
      'customerName': 'Meera Kapoor',
      'email': 'meera.k@gmail.com',
      'productName': 'Vaidyam Anti-Dandruff Herbal Shampoo (500 ml)',
      'frequency': 'Monthly (Every 30 Days)',
      'discountPct': 15,
      'pricePerCycle': 679,
      'nextRefillDate': '2026-08-30',
      'status': 'Paused',
      'refillsDelivered': 1,
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
                    'Subscriptions & Auto-Refills (Subscribe & Save)',
                    style: TextStyle(
                      fontFamily: 'serif',
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.goldAccent : AppColors.forestSageDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Manage recurring botanical orders, adjust renewal cycles, and trigger manual refills.',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? AppColors.textLightSecondary : AppColors.textDarkSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Subscriptions KPI Bar
          Row(
            children: [
              _buildStatChip(context, 'Total Active Subscriptions', '14 Plans', Icons.autorenew, AppColors.success),
              const SizedBox(width: 12),
              _buildStatChip(context, 'Monthly Recurring Revenue (MRR)', '₹18,450', Icons.currency_rupee, AppColors.goldAccent),
              const SizedBox(width: 12),
              _buildStatChip(context, 'Average Retention', '4.2 Cycles', Icons.verified_outlined, AppColors.info),
            ],
          ),

          const SizedBox(height: 24),

          // Subscriptions Table
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _subscriptions.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final sub = _subscriptions[index];
              final isActive = sub['status'] == 'Active';

              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                sub['id'],
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, fontFamily: 'monospace'),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isActive ? AppColors.success.withValues(alpha: 0.1) : AppColors.error.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  sub['status'].toUpperCase(),
                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isActive ? AppColors.success : AppColors.error),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '₹${sub['pricePerCycle']} / cycle',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: isDark ? AppColors.goldAccent : AppColors.forestSageDark,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      Text(
                        'Customer: ${sub['customerName']} (${sub['email']})',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Subscribed Item: ${sub['productName']}',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Schedule: ${sub['frequency']} • Discount: ${sub['discountPct']}% OFF • Total Refills Completed: ${sub['refillsDelivered']}',
                        style: TextStyle(fontSize: 11, color: isDark ? AppColors.textLightSecondary : AppColors.textDarkSecondary),
                      ),

                      const Divider(height: 20),

                      // Actions
                      Row(
                        children: [
                          Icon(Icons.calendar_today, size: 14, color: isDark ? AppColors.goldAccent : AppColors.forestSage),
                          const SizedBox(width: 6),
                          Text(
                            'Next Renewal: ${sub['nextRefillDate']}',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                          const Spacer(),

                          // Trigger Immediate Refill
                          ElevatedButton.icon(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Triggered immediate refill order for ${sub['customerName']}')),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.forestSage,
                              foregroundColor: AppColors.softWhite,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                            icon: const Icon(Icons.flash_on, size: 14),
                            label: const Text('Trigger Refill Now', style: TextStyle(fontSize: 11)),
                          ),

                          const SizedBox(width: 8),

                          // Pause / Resume Toggle
                          OutlinedButton(
                            onPressed: () {
                              setState(() {
                                sub['status'] = isActive ? 'Paused' : 'Active';
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('${sub['id']} status changed to ${sub['status']}')),
                              );
                            },
                            child: Text(isActive ? 'Pause Subscription' : 'Resume Subscription', style: const TextStyle(fontSize: 11)),
                          ),
                        ],
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

  Widget _buildStatChip(BuildContext context, String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 10, color: AppColors.textDarkSecondary)),
                Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
