import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../auth/controllers/auth_controller.dart';
import '../widgets/admin_catalog_view.dart';
import '../widgets/admin_customers_view.dart';
import '../widgets/admin_footer_cms_view.dart';
import '../widgets/admin_homepage_cms_view.dart';
import '../widgets/admin_orders_view.dart';
import 'admin_dashboard_screen.dart';

import '../widgets/admin_branding_view.dart';
import '../widgets/admin_coupons_view.dart';
import '../widgets/admin_mobile_app_view.dart';

class AdminMasterScreen extends ConsumerStatefulWidget {
  const AdminMasterScreen({super.key});

  @override
  ConsumerState<AdminMasterScreen> createState() => _AdminMasterScreenState();
}

class _AdminMasterScreenState extends ConsumerState<AdminMasterScreen> {
  int _activeViewIndex = 0; // 0: Dashboard, 1: Catalog, 2: Orders, 3: Customers, 4: Marketing, 5: Analytics, 6: Reports, 7: Website (Homepage), 8: Website (Footer), 9: Logo & Branding, 10: Mobile App Panel
  int _mobileAppSubTab = 0;

  // Expanded parent menus
  final Set<String> _expandedParentMenus = {'Website', 'Mobile App', 'COMMERCE'};

  Future<void> _handleAdminLogout(BuildContext context) async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Confirm Admin Logout', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        content: const Text('Are you sure you want to log out from the Cosmyra Admin Console?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFDC2626), foregroundColor: Colors.white),
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(authControllerProvider.notifier).signOut();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Admin logged out successfully.')),
                );
                context.go('/login');
              }
            },
            child: const Text('Logout Admin'),
          ),
        ],
      ),
    );
  }

  void _navigateToView(int index) {
    setState(() {
      _activeViewIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final auth = ref.watch(authControllerProvider);

    final String adminName = auth.userName ?? user?.userMetadata?['full_name'] ?? 'Mahboob Hasan';
    final String adminEmail = auth.userEmail ?? user?.email ?? '1mdollar2027@gmail.com';

    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth > 950;

    final List<Widget> views = [
      AdminDashboardScreen(onNavigateToView: _navigateToView),
      const AdminCatalogView(),
      const AdminOrdersView(),
      const AdminCustomersView(),
      const AdminCouponsView(),
      const Center(child: Text('Analytics View (Coming Soon)', style: TextStyle(fontSize: 16, color: Color(0xFF64748B)))),
      const Center(child: Text('Reports View (Coming Soon)', style: TextStyle(fontSize: 16, color: Color(0xFF64748B)))),
      const AdminHomepageCmsView(),
      const AdminFooterCmsView(),
      const AdminBrandingView(),
      AdminMobileAppView(key: ValueKey('mobile_app_tab_$_mobileAppSubTab'), initialSubTab: _mobileAppSubTab),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      drawer: isWide ? null : Drawer(child: _buildSidebar(isDrawer: true)),

      // ── TOP HEADER BAR ──
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(68),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SafeArea(
            child: Row(
              children: [
                if (!isWide)
                  Builder(
                    builder: (context) => IconButton(
                      icon: const Icon(Icons.menu, color: Color(0xFF334155)),
                      onPressed: () => Scaffold.of(context).openDrawer(),
                    ),
                  ),

                // Top Left Console Title & Subtitle matching Screenshot 1-to-1
                Row(
                  children: [
                    const Text(
                      'Master Admin Dashboard',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Color(0xFFEEF2FF),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.verified_user_rounded, color: Color(0xFF4F46E5), size: 16),
                    ),
                  ],
                ),

                const SizedBox(width: 24),

                // Search Bar in Center Header: 🔍 Search anything... [ ⌘K ]
                if (isWide)
                  Container(
                    width: 360,
                    height: 38,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Icon(Icons.search, size: 16, color: Color(0xFF94A3B8)),
                        ),
                        const Expanded(
                          child: TextField(
                            style: TextStyle(fontSize: 13, color: Color(0xFF0F172A)),
                            decoration: InputDecoration(
                              hintText: 'Search anything...',
                              hintStyle: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(vertical: 8),
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE2E8F0),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text('⌘K', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                        ),
                      ],
                    ),
                  ),

                const Spacer(),

                // Right Actions Group: Notifications Bell (Count 8), Help Icon, Super Admin Profile Pill
                Row(
                  children: [
                    // Bell Notification Icon with red count '8'
                    Stack(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.notifications_none_rounded, color: Color(0xFF475569), size: 22),
                          onPressed: () {},
                        ),
                        Positioned(
                          right: 8,
                          top: 8,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(color: Color(0xFFEF4444), shape: BoxShape.circle),
                            child: const Text('8', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),

                    // Help Support Icon
                    IconButton(
                      icon: const Icon(Icons.help_outline_rounded, color: Color(0xFF475569), size: 22),
                      onPressed: () {},
                    ),

                    const SizedBox(width: 12),

                    // Admin Profile Avatar Pill: Avatar + Name + Super Admin
                    PopupMenuButton<String>(
                      tooltip: 'Account Options',
                      onSelected: (val) async {
                        if (val == 'logout') {
                          await _handleAdminLogout(context);
                        } else if (val == 'site') {
                          context.go('/');
                        }
                      },
                      itemBuilder: (ctx) => [
                        PopupMenuItem(
                          enabled: false,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(adminName, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                              Text(adminEmail, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                            ],
                          ),
                        ),
                        const PopupMenuDivider(),
                        const PopupMenuItem(
                          value: 'site',
                          child: Row(
                            children: [
                              Icon(Icons.storefront, size: 18, color: Color(0xFF4F46E5)),
                              SizedBox(width: 10),
                              Text('View Live Website'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'logout',
                          child: Row(
                            children: [
                              Icon(Icons.logout, size: 18, color: Color(0xFFDC2626)),
                              SizedBox(width: 10),
                              Text('Logout Admin', style: TextStyle(color: Color(0xFFDC2626))),
                            ],
                          ),
                        ),
                      ],
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          children: [
                            const CircleAvatar(
                              radius: 16,
                              backgroundColor: Color(0xFF4F46E5),
                              child: Text('MH', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  adminName,
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                                ),
                                const Text(
                                  'Super Admin',
                                  style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                                ),
                              ],
                            ),
                            const SizedBox(width: 4),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),

      // ── MAIN BODY WITH LEFT SIDEBAR + CONTENT ──
      body: Row(
        children: [
          if (isWide)
            SizedBox(
              width: 250,
              child: _buildSidebar(),
            ),
          Expanded(
            child: views[_activeViewIndex >= views.length ? 0 : _activeViewIndex],
          ),
        ],
      ),
    );
  }

  // ── LEFT SIDEBAR NAVIGATION MATCHING SCREENSHOT 1-TO-1 ──
  Widget _buildSidebar({bool isDrawer = false}) {
    return Container(
      color: Colors.white,
      decoration: const BoxDecoration(
        border: Border(right: BorderSide(color: Color(0xFFF1F5F9))),
      ),
      child: Column(
        children: [
          // Top Brand Header: Vaidyam Botanicals (Logo + Brand Name)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Color(0xFF4F46E5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.local_florist_rounded, color: Colors.white, size: 18),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Vaidyam',
                      style: TextStyle(color: Color(0xFF0F172A), fontSize: 16, fontWeight: FontWeight.w900),
                    ),
                    Text(
                      'Botanicals',
                      style: TextStyle(color: Color(0xFF64748B), fontSize: 11, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 8),

          // Menu Items List matching screenshot 100%
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _navItem('Dashboard', Icons.home_filled, 0),

                const SizedBox(height: 14),
                _groupHeader('PLATFORM'),
                _subNavItem('Overview', 0, () => setState(() => _activeViewIndex = 0)),
                _subNavItem('Analytics', 5, () => setState(() => _activeViewIndex = 5)),
                _subNavItem('Reports', 6, () => setState(() => _activeViewIndex = 6)),

                const SizedBox(height: 14),
                _groupHeader('CONTENT MANAGEMENT ⓘ'),
                _navItem('Website', Icons.language_rounded, 7, hasChildren: true),
                if (_expandedParentMenus.contains('Website')) ...[
                  _subNavItem('Banners', 7, () => setState(() => _activeViewIndex = 7)),
                  _subNavItem('Pages', 7, () => setState(() => _activeViewIndex = 7)),
                  _subNavItem('Collections', 1, () => setState(() => _activeViewIndex = 1)),
                  _subNavItem('Blog', 7, () => setState(() => _activeViewIndex = 7)),
                  _subNavItem('FAQ', 7, () => setState(() => _activeViewIndex = 7)),
                  _subNavItem('Menus', 7, () => setState(() => _activeViewIndex = 7)),
                  _subNavItem('Testimonials', 7, () => setState(() => _activeViewIndex = 7)),
                  _subNavItem('SEO Settings', 9, () => setState(() => _activeViewIndex = 9)),
                ],

                _navItem('Mobile App', Icons.phone_iphone_rounded, 10, hasChildren: true),
                if (_expandedParentMenus.contains('Mobile App')) ...[
                  _subNavItem('App Banners', 10, () => setState(() { _mobileAppSubTab = 0; _activeViewIndex = 10; })),
                  _subNavItem('App Pages', 10, () => setState(() { _mobileAppSubTab = 1; _activeViewIndex = 10; })),
                  _subNavItem('App Categories', 10, () => setState(() { _mobileAppSubTab = 2; _activeViewIndex = 10; })),
                  _subNavItem('App Collections', 10, () => setState(() { _mobileAppSubTab = 3; _activeViewIndex = 10; })),
                  _subNavItem('App Configurations', 10, () => setState(() { _mobileAppSubTab = 4; _activeViewIndex = 10; })),
                  _subNavItem('Bottom Navigation', 10, () => setState(() { _mobileAppSubTab = 5; _activeViewIndex = 10; })),
                ],

                const SizedBox(height: 14),
                _groupHeader('COMMERCE'),
                _navItem('Products', Icons.inventory_2_outlined, 1),
                _navItem('Orders', Icons.shopping_bag_outlined, 2),
                _navItem('Coupons & Offers', Icons.local_offer_outlined, 4),
                _navItem('Reviews', Icons.star_outline_rounded, -1),

                const SizedBox(height: 14),
                _groupHeader('USERS & ROLES'),
                _navItem('Users', Icons.people_outline_rounded, 3),
                _navItem('Roles & Permissions', Icons.security_rounded, -1),

                const SizedBox(height: 14),
                _groupHeader('COMMUNICATION'),
                _navItem('Push Notifications', Icons.notifications_none_rounded, -1),
                _navItem('Email Templates', Icons.email_outlined, -1),

                const SizedBox(height: 14),
                _groupHeader('SETTINGS'),
                _navItem('General Settings', Icons.settings_outlined, 9),
                _navItem('Payment Methods', Icons.payment_rounded, -1),
                _navItem('Shipping Settings', Icons.local_shipping_outlined, -1),

                const SizedBox(height: 20),
              ],
            ),
          ),

          // Bottom Button: View Live Site ↗
          Container(
            padding: const EdgeInsets.all(16),
            child: OutlinedButton.icon(
              onPressed: () => context.go('/'),
              icon: const Icon(Icons.open_in_new_rounded, size: 16, color: Color(0xFF4F46E5)),
              label: const Text(
                'View Live Site',
                style: TextStyle(color: Color(0xFF4F46E5), fontSize: 13, fontWeight: FontWeight.bold),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: const BorderSide(color: Color(0xFFC7D2FE)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                minimumSize: const Size(double.infinity, 44),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _groupHeader(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, top: 4, bottom: 6),
      child: Text(
        text,
        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF94A3B8), letterSpacing: 0.6),
      ),
    );
  }

  Widget _navItem(
    String title,
    IconData icon,
    int index, {
    bool hasChildren = false,
  }) {
    final bool isActive = _activeViewIndex == index;
    final bool isExpanded = _expandedParentMenus.contains(title);

    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFEEF2FF) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        leading: Icon(icon, size: 18, color: isActive ? const Color(0xFF4F46E5) : const Color(0xFF64748B)),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
            color: isActive ? const Color(0xFF4F46E5) : const Color(0xFF334155),
          ),
        ),
        trailing: hasChildren
            ? Icon(
                isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                size: 16,
                color: const Color(0xFF94A3B8),
              )
            : null,
        onTap: () {
          setState(() {
            if (hasChildren) {
              if (isExpanded) {
                _expandedParentMenus.remove(title);
              } else {
                _expandedParentMenus.add(title);
              }
            }
            if (index >= 0) {
              _activeViewIndex = index;
            }
          });
        },
      ),
    );
  }

  Widget _subNavItem(String title, int targetIndex, VoidCallback? onTap) {
    final bool isActive = _activeViewIndex == targetIndex;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.only(left: 36, bottom: 2, right: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFFEEF2FF) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
              color: isActive ? const Color(0xFF4F46E5) : const Color(0xFF64748B),
            ),
          ),
        ),
      ),
    );
  }
}
