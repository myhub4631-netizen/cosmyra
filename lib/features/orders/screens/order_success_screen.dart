import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../config/theme/app_colors.dart';
import '../models/order_model.dart';

class OrderSuccessScreen extends StatelessWidget {
  final OrderModel order;

  const OrderSuccessScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_circle, size: 72, color: AppColors.success),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Order Confirmed!',
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Thank you for ordering with Cosmyra & Vaidyam.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? AppColors.textLightSecondary : AppColors.textDarkSecondary,
                  ),
                ),
                const SizedBox(height: 24),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Order Number', style: TextStyle(fontSize: 12, color: AppColors.textDarkSecondary)),
                            SelectableText(
                              order.orderNumber,
                              style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const Divider(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total Paid', style: TextStyle(fontSize: 12, color: AppColors.textDarkSecondary)),
                            Text('₹${order.totalAmount.toInt()}', style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Payment Mode', style: TextStyle(fontSize: 12, color: AppColors.textDarkSecondary)),
                            Text(order.paymentMethod.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Estimated Delivery', style: TextStyle(fontSize: 12, color: AppColors.textDarkSecondary)),
                            const Text('3-5 Business Days', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.success)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => context.go('/'),
                    child: const Text('Continue Shopping'),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => context.push('/orders'),
                    child: const Text('View My Orders'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
