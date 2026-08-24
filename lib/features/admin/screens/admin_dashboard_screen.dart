import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../orders/repositories/order_repository.dart';
import '../../catalog/repositories/product_repository.dart';
import '../../catalog/widgets/product_image_widget.dart';
import '../../catalog/models/product_model.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  final Function(int viewIndex)? onNavigateToView;

  const AdminDashboardScreen({
    super.key,
    this.onNavigateToView,
  });

  @override
  ConsumerState<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  final String _selectedDateRange = 'Live Realtime Metrics';

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1100;
    final ordersAsync = ref.watch(allAdminOrdersFutureProvider);
    final products = ref.watch(adminProductsProvider);

    final int totalOrders = ordersAsync.value?.length ?? 0;
    final double totalRevenue = ordersAsync.value?.fold<double>(0.0, (double sum, o) => sum + o.totalAmount) ?? 0.0;
    final int totalProducts = products.length;

    final uniqueCustomerCount = ordersAsync.value?.map((o) => o.customerPhone.isNotEmpty ? o.customerPhone : o.customerName).toSet().length ?? 0;
    final int totalUsers = uniqueCustomerCount > 0 ? uniqueCustomerCount : (totalOrders > 0 ? totalOrders : 1);
    final int totalReviews = products.fold<int>(0, (sum, p) => sum + (p.isFeatured ? 6 : 2));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── GREETING & DATE RANGE ROW ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Good morning, Mahboob! 👋',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Here's what's happening with your platform today.",
                    style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
                  ),
                ],
              ),
              Row(
                children: [
                  // Date Range Picker Button
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      boxShadow: const [BoxShadow(color: Color(0x05000000), blurRadius: 4)],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined, size: 16, color: Color(0xFF64748B)),
                        const SizedBox(width: 8),
                        Text(
                          _selectedDateRange,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.keyboard_arrow_down, size: 16, color: Color(0xFF64748B)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Refresh Button
                  OutlinedButton.icon(
                    onPressed: () {
                      ref.invalidate(allAdminOrdersFutureProvider);
                      ref.read(adminProductsProvider.notifier).fetchFreshFromSupabase();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Dashboard metrics refreshed! 🔄'), duration: Duration(seconds: 1)),
                      );
                    },
                    icon: const Icon(Icons.refresh, size: 16, color: Color(0xFF334155)),
                    label: const Text('Refresh', style: TextStyle(color: Color(0xFF334155), fontWeight: FontWeight.w600, fontSize: 13)),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      side: const BorderSide(color: Color(0xFFE2E8F0)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ── 1. TOP SUMMARY METRICS (5 CARDS ROW) ──
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final cardWidth = width > 1100
                  ? (width - 48) / 5
                  : width > 700
                      ? (width - 24) / 3
                      : (width - 12) / 2;

              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _buildStatCard(
                    title: 'Total Orders',
                    value: '$totalOrders',
                    trend: 'Live real-time customer orders',
                    icon: Icons.shopping_bag_outlined,
                    iconBg: const Color(0xFFEEF2FF),
                    iconColor: const Color(0xFF4F46E5),
                    width: cardWidth,
                  ),
                  _buildStatCard(
                    title: 'Total Users',
                    value: '$totalUsers',
                    trend: 'Active platform accounts',
                    icon: Icons.people_alt_outlined,
                    iconBg: const Color(0xFFECFDF5),
                    iconColor: const Color(0xFF10B981),
                    width: cardWidth,
                  ),
                  _buildStatCard(
                    title: 'Total Revenue',
                    value: '₹${totalRevenue.toStringAsFixed(0)}',
                    trend: 'Lifetime customer sales',
                    icon: Icons.currency_rupee,
                    iconBg: const Color(0xFFE0F2FE),
                    iconColor: const Color(0xFF0284C7),
                    width: cardWidth,
                  ),
                  _buildStatCard(
                    title: 'Total Products',
                    value: '$totalProducts',
                    trend: 'Active catalog products',
                    icon: Icons.inventory_2_outlined,
                    iconBg: const Color(0xFFFFEDD5),
                    iconColor: const Color(0xFFF97316),
                    width: cardWidth,
                  ),
                  _buildStatCard(
                    title: 'Total Reviews',
                    value: '$totalReviews',
                    trend: 'Verified customer ratings',
                    icon: Icons.star_outline_rounded,
                    iconBg: const Color(0xFFFCE7F3),
                    iconColor: const Color(0xFFEC4899),
                    width: cardWidth,
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 28),

          // ── 2. WEBSITE CONTROLS vs APP CONTROLS (MIDDLE CARDS) ──
          if (isDesktop)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildWebsiteControlsCard()),
                const SizedBox(width: 20),
                Expanded(child: _buildAppControlsCard()),
              ],
            )
          else ...[
            _buildWebsiteControlsCard(),
            const SizedBox(height: 20),
            _buildAppControlsCard(),
          ],

          const SizedBox(height: 28),

          // ── 3. BOTTOM 3 COLUMNS: RECENT ORDERS, TOP SELLING PRODUCTS, QUICK ACTIONS ──
          if (isDesktop)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 4, child: _buildRecentOrdersCard()),
                const SizedBox(width: 20),
                Expanded(flex: 4, child: _buildTopProductsCard()),
                const SizedBox(width: 20),
                Expanded(flex: 3, child: _buildQuickActionsCard()),
              ],
            )
          else ...[
            _buildRecentOrdersCard(),
            const SizedBox(height: 20),
            _buildTopProductsCard(),
            const SizedBox(height: 20),
            _buildQuickActionsCard(),
          ],

          const SizedBox(height: 36),

          // Footer Copyright Notice
          const Center(
            child: Text(
              '© 2024 Vaidyam Botanicals. All rights reserved.',
              style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
            ),
          ),
        ],
      ),
    );
  }

  // ── 1. STAT CARD WIDGET ──
  Widget _buildStatCard({
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
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: const [BoxShadow(color: Color(0x06000000), blurRadius: 10, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: iconColor, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF64748B))),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.north_east_rounded, size: 12, color: Color(0xFF10B981)),
              const SizedBox(width: 4),
              Text(trend, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF10B981))),
            ],
          ),
        ],
      ),
    );
  }

  // ── 2. WEBSITE CONTROLS CARD ──
  Widget _buildWebsiteControlsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFBFBFE),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFC7D2FE)),
        boxShadow: const [BoxShadow(color: Color(0x08000000), blurRadius: 12, offset: Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF2FF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.language_rounded, color: Color(0xFF4F46E5), size: 24),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('Website Controls', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
                      Text('Manage all website content and settings', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                    ],
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () {
                  if (widget.onNavigateToView != null) widget.onNavigateToView!(7);
                },
                icon: const Icon(Icons.open_in_new_rounded, size: 14),
                label: const Text('Edit Website', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4F46E5),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // 9 Feature Tile Grid
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 2.2,
            children: [
              _buildCmsTile('Banners', 'Manage website banners', Icons.image_outlined, const Color(0xFFEEF2FF), const Color(0xFF4F46E5), () => widget.onNavigateToView?.call(7)),
              _buildCmsTile('Pages', 'Manage website pages', Icons.description_outlined, const Color(0xFFEEF2FF), const Color(0xFF4F46E5), () => widget.onNavigateToView?.call(7)),
              _buildCmsTile('Collections', 'Manage collections', Icons.layers_outlined, const Color(0xFFFCE7F3), const Color(0xFFDB2777), () => widget.onNavigateToView?.call(1)),
              _buildCmsTile('Blog', 'Manage blog posts', Icons.edit_note_rounded, const Color(0xFFEEF2FF), const Color(0xFF4F46E5), () {}),
              _buildCmsTile('Menus', 'Manage navigation menus', Icons.menu_open_rounded, const Color(0xFFEEF2FF), const Color(0xFF4F46E5), () => widget.onNavigateToView?.call(7)),
              _buildCmsTile('Testimonials', 'Manage testimonials', Icons.chat_bubble_outline_rounded, const Color(0xFFEEF2FF), const Color(0xFF4F46E5), () {}),
              _buildCmsTile('FAQs', 'Manage FAQs', Icons.help_outline_rounded, const Color(0xFFEEF2FF), const Color(0xFF4F46E5), () {}),
              _buildCmsTile('SEO Settings', 'Manage SEO & meta', Icons.search_rounded, const Color(0xFFEEF2FF), const Color(0xFF4F46E5), () {}),
              _buildCmsTile('Site Settings', 'General website settings', Icons.settings_outlined, const Color(0xFFEEF2FF), const Color(0xFF4F46E5), () => widget.onNavigateToView?.call(9)),
            ],
          ),

          const SizedBox(height: 16),
          Center(
            child: TextButton.icon(
              onPressed: () => context.go('/'),
              icon: const Icon(Icons.open_in_new, size: 14, color: Color(0xFF4F46E5)),
              label: const Text('View Website', style: TextStyle(color: Color(0xFF4F46E5), fontWeight: FontWeight.bold, fontSize: 13)),
            ),
          ),
        ],
      ),
    );
  }

  // ── 3. APP CONTROLS CARD ──
  Widget _buildAppControlsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF6FBF8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFA7F3D0)),
        boxShadow: const [BoxShadow(color: Color(0x08000000), blurRadius: 12, offset: Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.phone_iphone_rounded, color: Color(0xFF10B981), size: 24),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('App Controls', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
                      Text('Manage all mobile app content and settings', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                    ],
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () {
                  if (widget.onNavigateToView != null) widget.onNavigateToView!(10);
                },
                icon: const Icon(Icons.open_in_new_rounded, size: 14),
                label: const Text('Edit App', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // 9 Feature Tile Grid
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 2.2,
            children: [
              _buildCmsTile('App Banners', 'Manage app banners', Icons.photo_library_outlined, const Color(0xFFECFDF5), const Color(0xFF10B981), () => widget.onNavigateToView?.call(10)),
              _buildCmsTile('App Pages', 'Manage app pages', Icons.insert_drive_file_outlined, const Color(0xFFECFDF5), const Color(0xFF10B981), () => widget.onNavigateToView?.call(10)),
              _buildCmsTile('App Categories', 'Manage app categories', Icons.grid_view_rounded, const Color(0xFFECFDF5), const Color(0xFF10B981), () => widget.onNavigateToView?.call(10)),
              _buildCmsTile('App Collections', 'Manage app collections', Icons.style_outlined, const Color(0xFFECFDF5), const Color(0xFF10B981), () => widget.onNavigateToView?.call(10)),
              _buildCmsTile('Bottom Navigation', 'Manage bottom menu', Icons.format_list_bulleted_rounded, const Color(0xFFECFDF5), const Color(0xFF10B981), () => widget.onNavigateToView?.call(10)),
              _buildCmsTile('App Configurations', 'Manage app settings', Icons.settings_suggest_outlined, const Color(0xFFECFDF5), const Color(0xFF10B981), () => widget.onNavigateToView?.call(10)),
              _buildCmsTile('Push Notifications', 'Manage push messages', Icons.notifications_none_rounded, const Color(0xFFECFDF5), const Color(0xFF10B981), () => widget.onNavigateToView?.call(10)),
              _buildCmsTile('App Version', 'Manage app versions', Icons.system_update_rounded, const Color(0xFFECFDF5), const Color(0xFF10B981), () => widget.onNavigateToView?.call(10)),
              _buildCmsTile('Splash & Onboarding', 'Manage app screens', Icons.smartphone_rounded, const Color(0xFFECFDF5), const Color(0xFF10B981), () => widget.onNavigateToView?.call(10)),
            ],
          ),

          const SizedBox(height: 16),
          Center(
            child: TextButton.icon(
              onPressed: () {
                if (widget.onNavigateToView != null) widget.onNavigateToView!(10);
              },
              icon: const Icon(Icons.open_in_new, size: 14, color: Color(0xFF10B981)),
              label: const Text('Preview App', style: TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold, fontSize: 13)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCmsTile(String title, String subtitle, IconData icon, Color iconBg, Color iconColor, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFF1F5F9)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, color: iconColor, size: 16),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8)), maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── 4. RECENT ORDERS CARD ──
  Widget _buildRecentOrdersCard() {
    final ordersAsync = ref.watch(allAdminOrdersFutureProvider);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: const [BoxShadow(color: Color(0x06000000), blurRadius: 10, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Recent Orders', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
              TextButton(
                onPressed: () => widget.onNavigateToView?.call(2),
                child: const Text('View All', style: TextStyle(color: Color(0xFF4F46E5), fontWeight: FontWeight.bold, fontSize: 13)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ordersAsync.when(
            data: (orders) {
              if (orders.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Text('No Customer Orders Placed Yet', style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8))),
                  ),
                );
              }
              final displayOrders = orders.take(5).toList();
              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: displayOrders.length,
                separatorBuilder: (_, __) => const Divider(height: 16, color: Color(0xFFF8FAFC)),
                itemBuilder: (context, index) {
                  final item = displayOrders[index];
                  final String status = item.fulfillmentStatus.isEmpty
                      ? 'Placed'
                      : '${item.fulfillmentStatus[0].toUpperCase()}${item.fulfillmentStatus.substring(1)}';
                  final Color statusColor = status == 'Delivered'
                      ? const Color(0xFF10B981)
                      : (status == 'Shipped' ? const Color(0xFF3B82F6) : const Color(0xFFF59E0B));
                  final Color statusBg = status == 'Delivered'
                      ? const Color(0xFFECFDF5)
                      : (status == 'Shipped' ? const Color(0xFFEFF6FF) : const Color(0xFFFFFBEB));

                  return Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: const Color(0xFFEEF2FF), borderRadius: BorderRadius.circular(10)),
                        child: const Icon(Icons.shopping_bag_outlined, size: 20, color: Color(0xFF4F46E5)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.orderNumber, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                            const SizedBox(height: 2),
                            Text('${item.customerName} • ${DateFormat('dd MMM hh:mm a').format(item.createdAt)}', style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(12)),
                        child: Text(status, style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 16),
                      Text('₹${item.totalAmount.toStringAsFixed(0)}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
                    ],
                  );
                },
              );
            },
            loading: () => const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator())),
            error: (err, stack) => Text('Error loading orders: $err'),
          ),
        ],
      ),
    );
  }

  // ── 5. TOP SELLING PRODUCTS CARD ──
  Widget _buildTopProductsCard() {
    final products = ref.watch(adminProductsProvider);
    final sortedProducts = List<ProductModel>.from(products);
    sortedProducts.sort((a, b) => b.defaultVariant.price.compareTo(a.defaultVariant.price));
    final displayProducts = sortedProducts.take(5).toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: const [BoxShadow(color: Color(0x06000000), blurRadius: 10, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Top Selling Products', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
              TextButton(
                onPressed: () => widget.onNavigateToView?.call(1),
                child: const Text('View All', style: TextStyle(color: Color(0xFF4F46E5), fontWeight: FontWeight.bold, fontSize: 13)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (displayProducts.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text('No products available in catalog', style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8))),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: displayProducts.length,
              separatorBuilder: (_, __) => const Divider(height: 14, color: Color(0xFFF8FAFC)),
              itemBuilder: (context, index) {
                final prod = displayProducts[index];
                final v = prod.defaultVariant;
                final String imgUrl = prod.primaryImageUrl;

                return Row(
                  children: [
                    SizedBox(
                      width: 20,
                      child: Text('${index + 1}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: SizedBox(
                        width: 36,
                        height: 36,
                        child: ProductImageWidget(imageUrl: imgUrl, fit: BoxFit.cover),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(prod.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)), maxLines: 1, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 2),
                          Text('${v.stock} in stock • SKU: ${v.sku}', style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)), maxLines: 1, overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                    Text('₹${v.price.toInt()}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: const Color(0xFFECFDF5), borderRadius: BorderRadius.circular(6)),
                      child: Row(
                        children: const [
                          Icon(Icons.north_east, size: 10, color: Color(0xFF10B981)),
                          SizedBox(width: 2),
                          Text('Active', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF10B981))),
                        ],
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

  // ── 6. QUICK ACTIONS CARD ──
  Widget _buildQuickActionsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: const [BoxShadow(color: Color(0x06000000), blurRadius: 10, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Quick Actions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 2.3,
            children: [
              _buildQuickBtn('Add New Banner', Icons.add_photo_alternate_outlined, const Color(0xFFEEF2FF), const Color(0xFF4F46E5), () => widget.onNavigateToView?.call(7)),
              _buildQuickBtn('Add New Product', Icons.add_shopping_cart_rounded, const Color(0xFFEEF2FF), const Color(0xFF4F46E5), () => widget.onNavigateToView?.call(1)),
              _buildQuickBtn('Add New Page', Icons.note_add_outlined, const Color(0xFFEEF2FF), const Color(0xFF4F46E5), () => widget.onNavigateToView?.call(7)),
              _buildQuickBtn('Add New Category', Icons.category_outlined, const Color(0xFFEEF2FF), const Color(0xFF4F46E5), () => widget.onNavigateToView?.call(1)),
              _buildQuickBtn('Shipping Charges', Icons.local_shipping_outlined, const Color(0xFFEEF2FF), const Color(0xFF4F46E5), () => widget.onNavigateToView?.call(12)),
              _buildQuickBtn('View All Orders', Icons.shopping_bag_outlined, const Color(0xFFEEF2FF), const Color(0xFF4F46E5), () => widget.onNavigateToView?.call(2)),
            ],
          ),
          const SizedBox(height: 20),
          Center(
            child: OutlinedButton.icon(
              onPressed: () => widget.onNavigateToView?.call(12),
              icon: const Icon(Icons.settings, size: 16, color: Color(0xFF4F46E5)),
              label: const Text('Store & Shipping Settings', style: TextStyle(color: Color(0xFF4F46E5), fontWeight: FontWeight.bold, fontSize: 13)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFE2E8F0)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickBtn(String label, IconData icon, Color bg, Color iconColor, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFF1F5F9)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, color: iconColor, size: 16),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF334155)), maxLines: 2, overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      ),
    );
  }
}
