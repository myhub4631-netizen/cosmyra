import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../config/theme/app_colors.dart';
import '../../catalog/repositories/product_repository.dart';
import '../../orders/models/order_model.dart';
import '../../orders/repositories/order_repository.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allOrdersAsync = ref.watch(allAdminOrdersFutureProvider);
    final productsAsync = ref.watch(productsFutureProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.storefront, color: AppColors.goldAccent),
            const SizedBox(width: 8),
            Text(
              'COSMYRA ADMIN CONSOLE',
              style: TextStyle(
                fontFamily: 'serif',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
                color: isDark ? AppColors.goldAccent : AppColors.forestSageDark,
              ),
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: () => context.go('/'),
            icon: const Icon(Icons.store, size: 18),
            label: const Text('Shopper Storefront'),
          ),
          const SizedBox(width: 8),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: isDark ? AppColors.goldAccent : AppColors.forestSage,
          indicatorColor: isDark ? AppColors.goldAccent : AppColors.forestSage,
          tabs: const [
            Tab(icon: Icon(Icons.local_shipping_outlined), text: 'Orders & Fulfillment'),
            Tab(icon: Icon(Icons.inventory_2_outlined), text: 'Inventory & SKUs'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 1. Orders & Fulfillment Tab
          allOrdersAsync.when(
            data: (orders) => _buildOrdersTab(context, orders, isDark),
            loading: () => const Center(child: CircularProgressIndicator(color: AppColors.forestSage)),
            error: (err, _) => Center(child: Text('Error loading orders: $err')),
          ),

          // 2. Inventory & SKUs Tab
          productsAsync.when(
            data: (products) => _buildInventoryTab(context, products, isDark),
            loading: () => const Center(child: CircularProgressIndicator(color: AppColors.forestSage)),
            error: (err, _) => Center(child: Text('Error loading inventory: $err')),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersTab(BuildContext context, List<OrderModel> orders, bool isDark) {
    final totalRevenue = orders.fold(0.0, (sum, o) => sum + o.totalAmount);
    final aov = orders.isNotEmpty ? (totalRevenue / orders.length).roundToDouble() : 0.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // KPI Metric Cards
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 600;
              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _buildKpiCard(
                    'Total Sales Revenue',
                    '₹${totalRevenue.toInt()}',
                    Icons.currency_rupee,
                    AppColors.success,
                    isWide ? (constraints.maxWidth - 24) / 3 : (constraints.maxWidth - 12) / 2,
                  ),
                  _buildKpiCard(
                    'Total Orders Placed',
                    '${orders.length}',
                    Icons.shopping_bag_outlined,
                    AppColors.info,
                    isWide ? (constraints.maxWidth - 24) / 3 : (constraints.maxWidth - 12) / 2,
                  ),
                  _buildKpiCard(
                    'Average Order Value',
                    '₹${aov.toInt()}',
                    Icons.trending_up,
                    AppColors.goldAccent,
                    isWide ? (constraints.maxWidth - 24) / 3 : constraints.maxWidth,
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 24),

          // Orders Management Table
          const Text(
            'Order Fulfillment & Dispatch (Multi-Courier)',
            style: TextStyle(fontFamily: 'serif', fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: orders.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final order = orders[index];
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SelectableText(
                            order.orderNumber,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, fontFamily: 'monospace'),
                          ),
                          Text(
                            '₹${order.totalAmount.toInt()}',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                              color: isDark ? AppColors.goldAccent : AppColors.forestSageDark,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Customer: ${order.customerName} (${order.customerEmail}) • ${order.customerPhone}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Ship to: ${order.shippingAddress['address_line1'] ?? ''}, ${order.shippingAddress['city'] ?? ''}, ${order.shippingAddress['state'] ?? ''} - ${order.shippingAddress['pincode'] ?? ''}',
                        style: TextStyle(fontSize: 11, color: isDark ? AppColors.textLightSecondary : AppColors.textDarkSecondary),
                      ),
                      const Divider(height: 16),

                      // Items summary
                      Text(
                        'Ordered Items: ${order.items.map((i) => "${i.productName} (${i.variantName}) x${i.quantity}").join(", ")}',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                      ),

                      const SizedBox(height: 12),

                      // Fulfillment controls
                      Wrap(
                        spacing: 12,
                        runSpacing: 8,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          // Status dropdown
                          DropdownButton<String>(
                            value: order.fulfillmentStatus,
                            underline: const SizedBox.shrink(),
                            items: ['placed', 'confirmed', 'processing', 'shipped', 'delivered']
                                .map((s) => DropdownMenuItem(
                                      value: s,
                                      child: Text('Status: ${s.toUpperCase()}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                    ))
                                .toList(),
                            onChanged: (newStatus) {
                              if (newStatus != null) {
                                ref.read(orderRepositoryProvider).updateOrderFulfillment(
                                      orderId: order.id,
                                      status: newStatus,
                                    );
                                ref.invalidate(allAdminOrdersFutureProvider);
                              }
                            },
                          ),

                          // Courier selection
                          DropdownButton<String>(
                            value: order.courierPartner ?? 'shiprocket',
                            underline: const SizedBox.shrink(),
                            items: [
                              const DropdownMenuItem(value: 'shiprocket', child: Text('Courier: Shiprocket (Primary)')),
                              const DropdownMenuItem(value: 'delhivery', child: Text('Courier: Delhivery Direct')),
                              const DropdownMenuItem(value: 'indiapost', child: Text('Courier: India Post (Speed Post)')),
                            ],
                            onChanged: (newCourier) {
                              if (newCourier != null) {
                                ref.read(orderRepositoryProvider).updateOrderFulfillment(
                                      orderId: order.id,
                                      status: order.fulfillmentStatus,
                                      courier: newCourier,
                                      trackingNumber: 'TRK-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
                                    );
                                ref.invalidate(allAdminOrdersFutureProvider);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Assigned courier $newCourier for order ${order.orderNumber}')),
                                );
                              }
                            },
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

  Widget _buildInventoryTab(BuildContext context, List<dynamic> products, bool isDark) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: products.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final product = products[index];
        final variant = product.defaultVariant;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.forestSage.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.spa, color: AppColors.forestSage),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'SKU: ${variant.sku} • Size: ${variant.sizeLabel} • Price: ₹${variant.price.toInt()} (MRP: ₹${variant.mrp.toInt()})',
                        style: TextStyle(fontSize: 12, color: isDark ? AppColors.textLightSecondary : AppColors.textDarkSecondary),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Stock Available: ${variant.stock} Units',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.success),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildKpiCard(String title, String value, IconData icon, Color color, double width) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark ? AppColors.charcoalBorder : AppColors.creamBorder,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 11, color: AppColors.textDarkSecondary),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(fontFamily: 'serif', fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
