import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'order_status_donut_chart.dart';
import 'sales_spline_chart.dart';

class AdminAnalyticsView extends ConsumerWidget {
  const AdminAnalyticsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          const Text(
            'Overview',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
          ),
          const SizedBox(height: 16),

          // 1. Row of 4 KPI Metric Cards
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 900;
              final width = isWide ? (constraints.maxWidth - 48) / 4 : (constraints.maxWidth - 16) / 2;

              return Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  _buildKpiCard(
                    title: 'Total Sales',
                    value: '₹24,58,320',
                    trend: '↑ 12.5% from last month',
                    icon: Icons.shopping_cart_outlined,
                    iconBg: const Color(0xFFEFF6FF),
                    iconColor: const Color(0xFF3B82F6),
                    width: width,
                  ),
                  _buildKpiCard(
                    title: 'Total Orders',
                    value: '12,543',
                    trend: '↑ 8.2% from last month',
                    icon: Icons.shopping_bag_outlined,
                    iconBg: const Color(0xFFFFF7ED),
                    iconColor: const Color(0xFFF97316),
                    width: width,
                  ),
                  _buildKpiCard(
                    title: 'Total Customers',
                    value: '8,945',
                    trend: '↑ 15.2% from last month',
                    icon: Icons.people_outline,
                    iconBg: const Color(0xFFF3E8FF),
                    iconColor: const Color(0xFFA855F7),
                    width: width,
                  ),
                  _buildKpiCard(
                    title: 'Total Products',
                    value: '2,350',
                    trend: '↑ 5.6% from last month',
                    icon: Icons.inventory_2_outlined,
                    iconBg: const Color(0xFFECFDF5),
                    iconColor: const Color(0xFF10B981),
                    width: width,
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 24),

          // 2. Row: Sales Overview (Line Chart) + Order Status (Donut Chart)
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 900;
              return Flex(
                direction: isWide ? Axis.horizontal : Axis.vertical,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sales Overview Card
                  Expanded(
                    flex: isWide ? 65 : 0,
                    child: Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: Color(0xFFF3F4F6)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Sales Overview',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: const Color(0xFFE5E7EB)),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: const [
                                      Text('This Month ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF374151))),
                                      Icon(Icons.keyboard_arrow_down, size: 16, color: Color(0xFF6B7280)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            const SalesSplineChart(),
                          ],
                        ),
                      ),
                    ),
                  ),

                  if (isWide) const SizedBox(width: 20) else const SizedBox(height: 20),

                  // Order Status Donut Chart Card
                  Expanded(
                    flex: isWide ? 35 : 0,
                    child: Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: Color(0xFFF3F4F6)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Order Status',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
                            ),
                            SizedBox(height: 20),
                            OrderStatusDonutChart(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 24),

          // 3. Row: Recent Orders Table + Top Selling Products List
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 900;
              return Flex(
                direction: isWide ? Axis.horizontal : Axis.vertical,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Recent Orders Table Card
                  Expanded(
                    flex: isWide ? 60 : 0,
                    child: Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: Color(0xFFF3F4F6)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Recent Orders',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF3F4F6),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text('View All', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF4F46E5))),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Table
                            Table(
                              columnWidths: const {
                                0: FlexColumnWidth(1.4),
                                1: FlexColumnWidth(1.8),
                                2: FlexColumnWidth(1.2),
                                3: FlexColumnWidth(1.4),
                                4: FlexColumnWidth(1.6),
                              },
                              children: [
                                // Table Header
                                const TableRow(
                                  children: [
                                    Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Text('Order ID', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF6B7280)))),
                                    Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Text('Customer', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF6B7280)))),
                                    Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Text('Amount', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF6B7280)))),
                                    Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Text('Status', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF6B7280)))),
                                    Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Text('Date', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF6B7280)))),
                                  ],
                                ),
                                _buildOrderRow('#ORD12543', 'Rohan Verma', '₹2,540', 'Delivered', '28 May, 2025', const Color(0xFFDCFCE7), const Color(0xFF166534)),
                                _buildOrderRow('#ORD12542', 'Priya Sharma', '₹1,299', 'Processing', '28 May, 2025', const Color(0xFFFEF3C7), const Color(0xFF92400E)),
                                _buildOrderRow('#ORD12541', 'Amit Singh', '₹3,650', 'Shipped', '27 May, 2025', const Color(0xFFDBEAFE), const Color(0xFF1E40AF)),
                                _buildOrderRow('#ORD12540', 'Neha Patel', '₹799', 'Cancelled', '27 May, 2025', const Color(0xFFFEE2E2), const Color(0xFF991B1B)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  if (isWide) const SizedBox(width: 20) else const SizedBox(height: 20),

                  // Top Selling Products Card
                  Expanded(
                    flex: isWide ? 40 : 0,
                    child: Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: Color(0xFFF3F4F6)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Top Selling Products',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF3F4F6),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text('View All', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF4F46E5))),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            _buildProductItem('Vaidyam Anti-Dandruff Herbal Shampoo', '1,245 Sold', '₹2,499', 'assets/images/shampoo.jpg'),
                            const SizedBox(height: 12),
                            _buildProductItem('Vaidyam Kumkumadi Face Cleanser', '1,102 Sold', '₹3,999', 'assets/images/facewash.jpg'),
                            const SizedBox(height: 12),
                            _buildProductItem('Vaidyam Neem & Tulsi Purifying Soap', '987 Sold', '₹2,199', 'assets/images/soap.jpg'),
                            const SizedBox(height: 12),
                            _buildProductItem('Vaidyam Herbal Hair Growth Oil', '876 Sold', '₹1,499', 'assets/images/soap.jpg'),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildKpiCard({
    required String title,
    required String value,
    required String trend,
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required double width,
  }) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF3F4F6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280), fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
                const SizedBox(height: 4),
                Text(trend, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF10B981))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  TableRow _buildOrderRow(
    String orderId,
    String customer,
    String amount,
    String status,
    String date,
    Color statusBg,
    Color statusFg,
  ) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(orderId, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF111827))),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(customer, style: const TextStyle(fontSize: 12, color: Color(0xFF374151))),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(amount, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusBg,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(status, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: statusFg), textAlign: TextAlign.center),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(date, style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
        ),
      ],
    );
  }

  Widget _buildProductItem(String title, String sold, String price, String assetPath) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(8),
            image: DecorationImage(
              image: AssetImage(assetPath),
              fit: BoxFit.cover,
              onError: (_, __) {},
            ),
          ),
          child: const Icon(Icons.shopping_bag_outlined, color: Color(0xFF6B7280), size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF111827)), maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 2),
              Text(sold, style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
            ],
          ),
        ),
        Text(price, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
      ],
    );
  }
}
