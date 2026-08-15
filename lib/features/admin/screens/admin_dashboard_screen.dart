import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../orders/models/order_model.dart';
import '../../orders/repositories/order_repository.dart';
import '../widgets/order_status_donut_chart.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedDateRange = 'Aug 15 - Aug 15, 2026';
  String _selectedStatusFilter = 'All Status';
  String _selectedCourierFilter = 'All Couriers';
  String _selectedChannelFilter = 'All Channels';

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
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1100;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── 1. TOP STATS KPI CARDS GRID (6 CARDS ROW) ──
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final cardWidth = width > 1200
                  ? (width - 60) / 6
                  : width > 800
                      ? (width - 24) / 3
                      : (width - 12) / 2;

              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _buildKpiCard(
                    title: 'Total Sales Revenue',
                    value: '₹18,45,120',
                    trend: '↑ 21.7% vs last 30 days',
                    isPositive: true,
                    icon: Icons.currency_rupee,
                    iconBg: const Color(0xFFFEF3C7),
                    iconColor: const Color(0xFFD97706),
                    lineColor: const Color(0xFF10B981),
                    width: cardWidth,
                  ),
                  _buildKpiCard(
                    title: 'Total Orders Placed',
                    value: '1,248',
                    trend: '↑ 18.2% vs last 30 days',
                    isPositive: true,
                    icon: Icons.shopping_bag_outlined,
                    iconBg: const Color(0xFFE0E7FF),
                    iconColor: const Color(0xFF4F46E5),
                    lineColor: const Color(0xFF3B82F6),
                    width: cardWidth,
                  ),
                  _buildKpiCard(
                    title: 'Average Order Value',
                    value: '₹1,479',
                    trend: '↑ 3.6% vs last 30 days',
                    isPositive: true,
                    icon: Icons.trending_up,
                    iconBg: const Color(0xFFFEF3C7),
                    iconColor: const Color(0xFFB45309),
                    lineColor: const Color(0xFFF59E0B),
                    width: cardWidth,
                  ),
                  _buildKpiCard(
                    title: 'Orders Delivered',
                    value: '1,102',
                    trend: '↑ 17.4% vs last 30 days',
                    isPositive: true,
                    icon: Icons.task_alt,
                    iconBg: const Color(0xFFD1FAE5),
                    iconColor: const Color(0xFF059669),
                    lineColor: const Color(0xFF10B981),
                    width: cardWidth,
                  ),
                  _buildKpiCard(
                    title: 'Orders Processing',
                    value: '89',
                    trend: '↓ 5.2% vs last 30 days',
                    isPositive: false,
                    icon: Icons.inventory_2_outlined,
                    iconBg: const Color(0xFFF3E8FF),
                    iconColor: const Color(0xFF9333EA),
                    lineColor: const Color(0xFFA855F7),
                    width: cardWidth,
                  ),
                  _buildKpiCard(
                    title: 'Orders Cancelled',
                    value: '57',
                    trend: '↓ 12.1% vs last 30 days',
                    isPositive: false,
                    icon: Icons.cancel_outlined,
                    iconBg: const Color(0xFFFEE2E2),
                    iconColor: const Color(0xFFDC2626),
                    lineColor: const Color(0xFFEF4444),
                    width: cardWidth,
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 24),

          // ── 2. ORDER FULFILLMENT TITLE & FILTER ROW ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Order Fulfillment & Dispatch (Multi-Courier)',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1E293B),
                ),
              ),
              if (isDesktop)
                Row(
                  children: [
                    _buildFilterDropdown(_selectedDateRange, ['Aug 15 - Aug 15, 2026', 'Last 7 Days', 'Last 30 Days']),
                    const SizedBox(width: 8),
                    _buildFilterDropdown(_selectedStatusFilter, ['All Status', 'Placed', 'Processing', 'Shipped', 'Delivered', 'Cancelled']),
                    const SizedBox(width: 8),
                    _buildFilterDropdown(_selectedCourierFilter, ['All Couriers', 'Shiprocket', 'Delhivery', 'India Post', 'Blue Dart']),
                    const SizedBox(width: 8),
                    _buildFilterDropdown(_selectedChannelFilter, ['All Channels', 'Website', 'App', 'Marketplace']),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.tune, size: 14),
                      label: const Text('Filters', style: TextStyle(fontSize: 12)),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.download_outlined, size: 14),
                      label: const Text('Export', style: TextStyle(fontSize: 12)),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ],
                ),
            ],
          ),

          const SizedBox(height: 16),

          // ── 3. MAIN SECTION SPLIT: LEFT (CHARTS & TABLE) | RIGHT (SIDE CARDS) ──
          isDesktop
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // LEFT COLUMN (Flex 8)
                    Expanded(
                      flex: 8,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _build3ChartsGrid(),
                          const SizedBox(height: 24),
                          _buildRecentOrdersTable(allOrdersAsync),
                        ],
                      ),
                    ),

                    const SizedBox(width: 24),

                    // RIGHT COLUMN (Flex 3)
                    Expanded(
                      flex: 3,
                      child: Column(
                        children: [
                          _buildFulfillmentPerformanceCard(),
                          const SizedBox(height: 20),
                          _buildQuickActionsCard(),
                          const SizedBox(height: 20),
                          _buildAlertsCard(),
                          const SizedBox(height: 20),
                          _buildNeedHelpCard(),
                        ],
                      ),
                    ),
                  ],
                )
              : Column(
                  children: [
                    _build3ChartsGrid(),
                    const SizedBox(height: 20),
                    _buildRecentOrdersTable(allOrdersAsync),
                    const SizedBox(height: 20),
                    _buildFulfillmentPerformanceCard(),
                    const SizedBox(height: 20),
                    _buildQuickActionsCard(),
                    const SizedBox(height: 20),
                    _buildAlertsCard(),
                    const SizedBox(height: 20),
                    _buildNeedHelpCard(),
                  ],
                ),
        ],
      ),
    );
  }

  // ── KPI CARD WIDGET ──
  Widget _buildKpiCard({
    required String title,
    required String value,
    required String trend,
    required bool isPositive,
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required Color lineColor,
    required double width,
  }) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              Text(
                title,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                trend,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isPositive ? const Color(0xFF059669) : const Color(0xFFDC2626),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Sparkline Curve graphic
          SizedBox(
            height: 20,
            width: double.infinity,
            child: CustomPaint(
              painter: _SparklinePainter(lineColor: lineColor),
            ),
          ),
        ],
      ),
    );
  }

  // ── FILTER DROPDOWN ──
  Widget _buildFilterDropdown(String value, List<String> items) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          icon: const Icon(Icons.keyboard_arrow_down, size: 16, color: Color(0xFF64748B)),
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
          onChanged: (val) {},
          items: items.map((i) => DropdownMenuItem(value: i, child: Text(i))).toList(),
        ),
      ),
    );
  }

  // ── 3 CHARTS GRID ROW (Donut, Bars, Couriers) ──
  Widget _build3ChartsGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final itemW = w > 900 ? (w - 24) / 3 : w;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            // 1. Orders by Status (Donut Chart)
            Container(
              width: itemW,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFF1F5F9)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Orders by Status', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 160,
                    child: Row(
                      children: [
                        const SizedBox(
                          width: 120,
                          height: 120,
                          child: OrderStatusDonutChart(),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _legendRow(const Color(0xFF3B82F6), 'Placed', '412 (33.0%)'),
                              const SizedBox(height: 6),
                              _legendRow(const Color(0xFFF59E0B), 'Processing', '214 (17.1%)'),
                              const SizedBox(height: 6),
                              _legendRow(const Color(0xFF10B981), 'Shipped', '356 (28.5%)'),
                              const SizedBox(height: 6),
                              _legendRow(const Color(0xFF8B5CF6), 'Delivered', '210 (16.8%)'),
                              const SizedBox(height: 6),
                              _legendRow(const Color(0xFFEF4444), 'Cancelled', '56 (4.5%)'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // 2. Fulfillment Overview Bars
            Container(
              width: itemW,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFF1F5F9)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Fulfillment Overview', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                  const SizedBox(height: 16),
                  _barProgressRow('Placed', 0.33, const Color(0xFF3B82F6), '33%'),
                  const SizedBox(height: 12),
                  _barProgressRow('Processing', 0.17, const Color(0xFFF59E0B), '17%'),
                  const SizedBox(height: 12),
                  _barProgressRow('Shipped', 0.28, const Color(0xFF10B981), '28%'),
                  const SizedBox(height: 12),
                  _barProgressRow('Delivered', 0.17, const Color(0xFF8B5CF6), '17%'),
                  const SizedBox(height: 12),
                  _barProgressRow('Cancelled', 0.05, const Color(0xFFEF4444), '5%'),
                ],
              ),
            ),

            // 3. Top Couriers List
            Container(
              width: itemW,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFF1F5F9)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text('Top Couriers', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                      Text('By Delivered Orders ˅', style: TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _courierProgressRow('Shiprocket', 0.55, const Color(0xFF4F46E5), '856 (55%)'),
                  const SizedBox(height: 12),
                  _courierProgressRow('Delhivery', 0.26, const Color(0xFF3B82F6), '412 (26%)'),
                  const SizedBox(height: 12),
                  _courierProgressRow('India Post', 0.12, const Color(0xFF10B981), '198 (12%)'),
                  const SizedBox(height: 12),
                  _courierProgressRow('Blue Dart', 0.07, const Color(0xFFF59E0B), '86 (7%)'),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _legendRow(Color color, String label, String value) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Expanded(child: Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF475569)))),
        Text(value, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
      ],
    );
  }

  Widget _barProgressRow(String label, double percent, Color color, String pctText) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF475569))),
            Text(pctText, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percent,
            minHeight: 6,
            backgroundColor: const Color(0xFFF1F5F9),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  Widget _courierProgressRow(String name, double percent, Color color, String text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
            Text(text, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percent,
            minHeight: 6,
            backgroundColor: const Color(0xFFF1F5F9),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  // ── 4. RECENT ORDERS DATA TABLE ──
  Widget _buildRecentOrdersTable(AsyncValue<List<OrderModel>> ordersAsync) {
    final List<OrderModel> orders = ordersAsync.value ?? [];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Table Header Row
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Text('Recent Orders', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEF2FF),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${orders.length} Active',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF4F46E5)),
                      ),
                    ),
                  ],
                ),
                InkWell(
                  onTap: () {},
                  child: const Text(
                    'View All Orders →',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF2563EB)),
                  ),
                ),
              ],
            ),
          ),

          // Orders Table
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
              horizontalMargin: 20,
              columnSpacing: 28,
              columns: const [
                DataColumn(label: Text('Order ID', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF475569)))),
                DataColumn(label: Text('Customer', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF475569)))),
                DataColumn(label: Text('Courier', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF475569)))),
                DataColumn(label: Text('Status', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF475569)))),
                DataColumn(label: Text('Amount', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF475569)))),
                DataColumn(label: Text('Order Date', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF475569)))),
                DataColumn(label: Text('Expected Delivery', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF475569)))),
                DataColumn(label: Text('Actions', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF475569)))),
              ],
              rows: _buildDynamicOrderRows(orders),
            ),
          ),

          // Table Pagination Footer
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Showing 1 to ${orders.length.clamp(0, 10)} of ${orders.length} orders', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                Row(
                  children: [
                    _pageButton('‹', false),
                    const SizedBox(width: 4),
                    _pageButton('1', true),
                    const SizedBox(width: 4),
                    _pageButton('›', false),
                    const SizedBox(width: 16),
                    const Text('Show ', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Row(
                        children: [
                          Text('10', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          SizedBox(width: 4),
                          Icon(Icons.keyboard_arrow_down, size: 14),
                        ],
                      ),
                    ),
                    const Text(' per page', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<DataRow> _buildDynamicOrderRows(List<OrderModel> orders) {
    if (orders.isEmpty) {
      return [
        const DataRow(cells: [
          DataCell(Text('-')),
          DataCell(Text('No orders placed yet')),
          DataCell(Text('-')),
          DataCell(Text('-')),
          DataCell(Text('-')),
          DataCell(Text('-')),
          DataCell(Text('-')),
          DataCell(Text('-')),
        ]),
      ];
    }

    return orders.take(10).map((o) {
      final statusUpper = o.fulfillmentStatus.toUpperCase();
      Color statusBg = const Color(0xFFEEF2FF);
      Color statusColor = const Color(0xFF4F46E5);

      if (statusUpper == 'DELIVERED') {
        statusBg = const Color(0xFFECFDF5);
        statusColor = const Color(0xFF059669);
      } else if (statusUpper == 'SHIPPED') {
        statusBg = const Color(0xFFEFF6FF);
        statusColor = const Color(0xFF2563EB);
      } else if (statusUpper == 'PROCESSING' || statusUpper == 'CONFIRMED') {
        statusBg = const Color(0xFFFFFBEB);
        statusColor = const Color(0xFFD97706);
      } else if (statusUpper == 'CANCELLED') {
        statusBg = const Color(0xFFFEF2F2);
        statusColor = const Color(0xFFDC2626);
      }

      final dateStr = DateFormat('dd MMM yyyy\nhh:mm a').format(o.createdAt);
      final expStr = DateFormat('dd MMM yyyy\nBy 8:00 PM').format(o.createdAt.add(const Duration(days: 2)));

      return DataRow(
        cells: [
          DataCell(Text(o.orderNumber.isNotEmpty ? o.orderNumber : o.id, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF0F172A)))),
          DataCell(
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(o.customerName.isNotEmpty ? o.customerName : 'Customer', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF1E293B))),
                Text(o.customerEmail.isNotEmpty ? o.customerEmail : o.customerPhone, style: const TextStyle(fontSize: 10, color: Color(0xFF64748B))),
              ],
            ),
          ),
          DataCell(
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(o.courierPartner ?? 'Shiprocket', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF1E293B))),
                Text(o.trackingNumber ?? 'AWB: Pending', style: const TextStyle(fontSize: 10, color: Color(0xFF64748B))),
              ],
            ),
          ),
          DataCell(
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                statusUpper,
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: statusColor),
              ),
            ),
          ),
          DataCell(Text('₹${o.totalAmount.toInt()}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A)))),
          DataCell(Text(dateStr, style: const TextStyle(fontSize: 11, color: Color(0xFF475569)))),
          DataCell(Text(expStr, style: const TextStyle(fontSize: 11, color: Color(0xFF475569)))),
          DataCell(
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, size: 16, color: Color(0xFF64748B)),
              onSelected: (val) async {
                await ref.read(orderRepositoryProvider).updateOrderFulfillment(
                  orderId: o.id,
                  status: val,
                );
                ref.invalidate(allAdminOrdersFutureProvider);
                ref.invalidate(userOrdersFutureProvider);
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'confirmed', child: Text('Mark as Confirmed')),
                const PopupMenuItem(value: 'processing', child: Text('Mark as Processing')),
                const PopupMenuItem(value: 'shipped', child: Text('Mark as Shipped')),
                const PopupMenuItem(value: 'delivered', child: Text('Mark as Delivered')),
                const PopupMenuItem(value: 'cancelled', child: Text('Mark as Cancelled')),
              ],
            ),
          ),
        ],
      );
    }).toList();
  }

  Widget _pageButton(String text, bool active) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: active ? const Color(0xFF4F46E5) : Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: active ? const Color(0xFF4F46E5) : const Color(0xFFE2E8F0)),
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            fontSize: 12,
            fontWeight: active ? FontWeight.bold : FontWeight.w500,
            color: active ? Colors.white : const Color(0xFF475569),
          ),
        ),
      ),
    );
  }

  // ── RIGHT COLUMN CARDS ──
  Widget _buildFulfillmentPerformanceCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('Fulfillment Performance', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
              Text('Last 30 Days ˅', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _subStatItem('On-Time Delivery', '92.4%', '↑ 6.3%', true),
              _subStatItem('Return Rate', '2.8%', '↓ 1.2%', true),
              _subStatItem('Avg. Delivery Time', '2.6 Days', '↓ 0.4 Days', true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _subStatItem(String label, String val, String change, bool positive) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Color(0xFF64748B))),
        const SizedBox(height: 4),
        Text(val, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
        const SizedBox(height: 2),
        Text(change, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: positive ? const Color(0xFF059669) : const Color(0xFFDC2626))),
      ],
    );
  }

  Widget _buildQuickActionsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Quick Actions', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
          const SizedBox(height: 14),
          _quickActionLink(Icons.add_circle_outline, 'Create New Order'),
          _quickActionLink(Icons.inventory_outlined, 'Bulk Fulfillment'),
          _quickActionLink(Icons.print_outlined, 'Print Shipping Labels'),
          _quickActionLink(Icons.file_download_outlined, 'Download Invoices'),
          _quickActionLink(Icons.assignment_return_outlined, 'Manage Return Requests'),
        ],
      ),
    );
  }

  Widget _quickActionLink(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: const Color(0xFF475569)),
          const SizedBox(width: 12),
          Expanded(child: Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF334155)))),
          const Icon(Icons.chevron_right, size: 16, color: Color(0xFF94A3B8)),
        ],
      ),
    );
  }

  Widget _buildAlertsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Alerts & Notifications', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
          const SizedBox(height: 14),
          _alertItem(Icons.warning_amber_rounded, const Color(0xFFD97706), '23 orders are delayed', 'Need attention', 'View Orders'),
          const SizedBox(height: 12),
          _alertItem(Icons.info_outline, const Color(0xFF2563EB), 'Inventory low for 12 SKUs', 'Check now', 'View Inventory'),
          const SizedBox(height: 12),
          _alertItem(Icons.check_circle_outline, const Color(0xFF059669), 'All systems operational', 'No issues detected', null),
        ],
      ),
    );
  }

  Widget _alertItem(IconData icon, Color color, String title, String sub, String? action) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
              Text(sub, style: const TextStyle(fontSize: 10, color: Color(0xFF64748B))),
            ],
          ),
        ),
        if (action != null)
          TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(50, 20)),
            child: Text(action, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF2563EB))),
          ),
      ],
    );
  }

  Widget _buildNeedHelpCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(color: Color(0xFFEEF2FF), shape: BoxShape.circle),
            child: const Icon(Icons.headset_mic_outlined, color: Color(0xFF4F46E5), size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Need Help?', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                const SizedBox(height: 2),
                const Text('Contact our support team for assistance.', style: TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                const SizedBox(height: 6),
                InkWell(
                  onTap: () {},
                  child: const Text('Contact Support →', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF4F46E5))),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── CUSTOM SPARKLINE PAINTER ──
class _SparklinePainter extends CustomPainter {
  final Color lineColor;

  _SparklinePainter({required this.lineColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(0, size.height * 0.7);
    path.quadraticBezierTo(size.width * 0.25, size.height * 0.2, size.width * 0.5, size.height * 0.6);
    path.quadraticBezierTo(size.width * 0.75, size.height * 0.9, size.width, size.height * 0.1);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
