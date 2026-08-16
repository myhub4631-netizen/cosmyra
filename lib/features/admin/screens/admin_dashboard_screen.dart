import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
  String _selectedDateRange = '16 May - 22 May 2024';

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1100;

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
                      setState(() {});
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
                    value: '12,458',
                    trend: '18.6% vs last 7 days',
                    icon: Icons.shopping_bag_outlined,
                    iconBg: const Color(0xFFEEF2FF),
                    iconColor: const Color(0xFF4F46E5),
                    width: cardWidth,
                  ),
                  _buildStatCard(
                    title: 'Total Users',
                    value: '8,243',
                    trend: '16.3% vs last 7 days',
                    icon: Icons.people_alt_outlined,
                    iconBg: const Color(0xFFECFDF5),
                    iconColor: const Color(0xFF10B981),
                    width: cardWidth,
                  ),
                  _buildStatCard(
                    title: 'Total Revenue',
                    value: '₹18,72,345',
                    trend: '22.5% vs last 7 days',
                    icon: Icons.currency_rupee,
                    iconBg: const Color(0xFFE0F2FE),
                    iconColor: const Color(0xFF0284C7),
                    width: cardWidth,
                  ),
                  _buildStatCard(
                    title: 'Total Products',
                    value: '1,246',
                    trend: '8.2% vs last 7 days',
                    icon: Icons.inventory_2_outlined,
                    iconBg: const Color(0xFFFFEDD5),
                    iconColor: const Color(0xFFF97316),
                    width: cardWidth,
                  ),
                  _buildStatCard(
                    title: 'Total Reviews',
                    value: '2,543',
                    trend: '12.7% vs last 7 days',
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
              _buildCmsTile('Push Notifications', 'Manage push messages', Icons.notifications_none_rounded, const Color(0xFFECFDF5), const Color(0xFF10B981), () {}),
              _buildCmsTile('App Version', 'Manage app versions', Icons.system_update_rounded, const Color(0xFFECFDF5), const Color(0xFF10B981), () {}),
              _buildCmsTile('Splash & Onboarding', 'Manage app screens', Icons.smartphone_rounded, const Color(0xFFECFDF5), const Color(0xFF10B981), () {}),
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
    final recentOrders = [
      {'id': '#ORD12345678', 'date': '20 May 2024, 11:30 AM', 'status': 'Delivered', 'amount': '₹3,798', 'color': const Color(0xFF10B981), 'bg': const Color(0xFFECFDF5), 'icon': Icons.headphones_rounded},
      {'id': '#ORD12345677', 'date': '20 May 2024, 10:15 AM', 'status': 'Shipped', 'amount': '₹2,499', 'color': const Color(0xFF3B82F6), 'bg': const Color(0xFFEFF6FF), 'icon': Icons.watch_rounded},
      {'id': '#ORD12345676', 'date': '19 May 2024, 09:45 AM', 'status': 'Processing', 'amount': '₹7,499', 'color': const Color(0xFFF59E0B), 'bg': const Color(0xFFFFFBEB), 'icon': Icons.nordic_walking_rounded},
      {'id': '#ORD12345675', 'date': '19 May 2024, 08:30 AM', 'status': 'Cancelled', 'amount': '₹1,799', 'color': const Color(0xFFEF4444), 'bg': const Color(0xFFFEF2F2), 'icon': Icons.shopping_bag_rounded},
    ];

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
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: recentOrders.length,
            separatorBuilder: (_, __) => const Divider(height: 16, color: Color(0xFFF8FAFC)),
            itemBuilder: (context, index) {
              final item = recentOrders[index];
              return Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(10)),
                    child: Icon(item['icon'] as IconData, size: 20, color: const Color(0xFF475569)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item['id'] as String, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                        const SizedBox(height: 2),
                        Text(item['date'] as String, style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: item['bg'] as Color, borderRadius: BorderRadius.circular(12)),
                    child: Text(item['status'] as String, style: TextStyle(color: item['color'] as Color, fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 16),
                  Text(item['amount'] as String, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  // ── 5. TOP SELLING PRODUCTS CARD ──
  Widget _buildTopProductsCard() {
    final topProducts = [
      {'rank': '1', 'name': 'Neem Face Wash', 'sales': '1,245 Sales', 'revenue': '₹2,45,890', 'growth': '24.5%', 'icon': Icons.sanitizer_rounded},
      {'rank': '2', 'name': 'Hair Growth Oil', 'sales': '987 Sales', 'revenue': '₹1,98,230', 'growth': '18.7%', 'icon': Icons.local_pharmacy_rounded},
      {'rank': '3', 'name': 'Aloe Vera Gel', 'sales': '876 Sales', 'revenue': '₹1,25,430', 'growth': '12.4%', 'icon': Icons.spa_rounded},
      {'rank': '4', 'name': 'Turmeric Soap', 'sales': '765 Sales', 'revenue': '₹98,765', 'growth': '8.9%', 'icon': Icons.clean_hands_rounded},
      {'rank': '5', 'name': 'Shata Dhauta Cream', 'sales': '612 Sales', 'revenue': '₹86,540', 'growth': '7.6%', 'icon': Icons.face_retouching_natural_rounded},
    ];

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
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: topProducts.length,
            separatorBuilder: (_, __) => const Divider(height: 14, color: Color(0xFFF8FAFC)),
            itemBuilder: (context, index) {
              final item = topProducts[index];
              return Row(
                children: [
                  SizedBox(
                    width: 20,
                    child: Text(item['rank'] as String, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: const Color(0xFFEEF2FF), borderRadius: BorderRadius.circular(8)),
                    child: Icon(item['icon'] as IconData, size: 18, color: const Color(0xFF4F46E5)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item['name'] as String, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                        const SizedBox(height: 2),
                        Text(item['sales'] as String, style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
                      ],
                    ),
                  ),
                  Text(item['revenue'] as String, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                  const SizedBox(width: 12),
                  Row(
                    children: [
                      const Icon(Icons.north_east, size: 10, color: Color(0xFF10B981)),
                      Text(item['growth'] as String, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF10B981))),
                    ],
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
              _buildQuickBtn('Send Notification', Icons.send_rounded, const Color(0xFFEEF2FF), const Color(0xFF4F46E5), () {}),
              _buildQuickBtn('View All Orders', Icons.shopping_bag_outlined, const Color(0xFFEEF2FF), const Color(0xFF4F46E5), () => widget.onNavigateToView?.call(2)),
            ],
          ),
          const SizedBox(height: 20),
          Center(
            child: OutlinedButton.icon(
              onPressed: () => widget.onNavigateToView?.call(9),
              icon: const Icon(Icons.settings, size: 16, color: Color(0xFF4F46E5)),
              label: const Text('System Settings', style: TextStyle(color: Color(0xFF4F46E5), fontWeight: FontWeight.bold, fontSize: 13)),
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
