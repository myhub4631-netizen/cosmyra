import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../cart/controllers/cart_controller.dart';
import '../../catalog/repositories/product_repository.dart';
import '../../navigation/widgets/vaidyam_footer_widget.dart';
import '../../orders/repositories/order_repository.dart';

class UserDashboardScreen extends ConsumerStatefulWidget {
  const UserDashboardScreen({super.key});

  @override
  ConsumerState<UserDashboardScreen> createState() => _UserDashboardScreenState();
}

class _UserDashboardScreenState extends ConsumerState<UserDashboardScreen> {
  String _selectedTab = 'Dashboard';
  String _selectedSearchCategory = 'All Categories';
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> _sidebarNavItems = [
    {'title': 'Dashboard', 'icon': Icons.home_outlined, 'route': null},
    {'title': 'My Orders', 'icon': Icons.inventory_2_outlined, 'route': '/orders'},
    {'title': 'My Wishlist', 'icon': Icons.favorite_border, 'route': '/wishlist'},
    {'title': 'My Addresses', 'icon': Icons.location_on_outlined, 'route': null},
    {'title': 'Account Details', 'icon': Icons.person_outline, 'route': null},
    {'title': 'Change Password', 'icon': Icons.lock_outline, 'route': null},
    {'title': 'Payment Methods', 'icon': Icons.credit_card_outlined, 'route': null},
    {'title': 'Notifications', 'icon': Icons.notifications_none_outlined, 'route': null},
    {'title': 'Logout', 'icon': Icons.logout, 'route': null},
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showEditProfileDialog(BuildContext context, String currentName, String currentEmail, String currentPhone) {
    final nameCtrl = TextEditingController(text: currentName);
    final emailCtrl = TextEditingController(text: currentEmail);
    final phoneCtrl = TextEditingController(text: currentPhone);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Edit Account Profile', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Full Name', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: emailCtrl, readOnly: true, decoration: const InputDecoration(labelText: 'Email Address (Account ID)', border: OutlineInputBorder(), fillColor: Color(0xFFF3F4F6), filled: true)),
            const SizedBox(height: 12),
            TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'Phone Number', border: OutlineInputBorder())),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (nameCtrl.text.trim().isNotEmpty) {
                await ref.read(authControllerProvider.notifier).updateUserProfile(
                      name: nameCtrl.text.trim(),
                      phone: phoneCtrl.text.trim(),
                    );
                if (!ctx.mounted) return;
                Navigator.pop(ctx);
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Profile details updated successfully!')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4F46E5), foregroundColor: Colors.white),
            child: const Text('Save Changes'),
          ),
        ],
      ),
    );
  }

  void _showReferralDialog(BuildContext context, String referCode) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Refer & Earn ₹250', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Share your unique referral link with friends. When they place their first order, you both get ₹250 credit!'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'https://cosmyra.cloud/refer?code=$referCode',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF4F46E5)),
                    ),
                  ),
                  const Icon(Icons.copy, size: 18, color: Color(0xFF4F46E5)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Referral link copied to clipboard!')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4F46E5), foregroundColor: Colors.white),
            child: const Text('Copy Link'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartProvider);
    final wishlist = ref.watch(wishlistProvider);
    final ordersAsync = ref.watch(userOrdersFutureProvider);
    final totalCartCount = cartState.totalItemCount;

    final user = ref.watch(currentUserProvider);
    final auth = ref.watch(authControllerProvider);

    final String displayName = auth.userName ??
        user?.userMetadata?['full_name'] ??
        (auth.isGuest ? auth.guestName : null) ??
        (user?.email != null ? user!.email!.split('@').first : 'Valued Customer');

    final String displayEmail = auth.userEmail ??
        user?.email ??
        (auth.isGuest ? auth.guestEmail : null) ??
        'No email registered';

    final String displayPhone = auth.userPhone ??
        user?.phone ??
        (auth.isGuest ? auth.guestPhone : null) ??
        (auth.userPhone?.isNotEmpty == true ? auth.userPhone! : 'No phone provided');

    final String referCode = displayName.replaceAll(' ', '').toUpperCase();
    final String firstFirstName = displayName.split(' ').first;

    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth > 900;

    final int realOrdersCount = ordersAsync.value?.length ?? 0;
    final int wishlistCount = wishlist.length;

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. Top Announcement Bar
            Container(
              width: double.infinity,
              color: const Color(0xFF4F46E5),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Free Shipping on orders over ₹499 • 100% Certified Organic Botanicals',
                    style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                  Row(
                    children: const [
                      Icon(Icons.facebook, color: Colors.white, size: 16),
                      SizedBox(width: 12),
                      Icon(Icons.camera_alt, color: Colors.white, size: 16),
                      SizedBox(width: 12),
                      Icon(Icons.play_circle_fill, color: Colors.white, size: 16),
                    ],
                  ),
                ],
              ),
            ),

            // 2. Main Header Bar (Logo, Category Search, Wishlist/Cart/Account)
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => context.go('/'),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6366F1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.shopping_bag_outlined, color: Colors.white, size: 24),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Vaidyam Botanicals',
                          style: TextStyle(
                            fontFamily: 'serif',
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: isWide ? const Color(0xFF111827) : const Color(0xFF4F46E5),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 32),

                  // Search Bar with Category Dropdown
                  if (isWide)
                    Expanded(
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9FAFB),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: const BoxDecoration(
                                border: Border(right: BorderSide(color: Color(0xFFE5E7EB))),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _selectedSearchCategory,
                                  icon: const Icon(Icons.keyboard_arrow_down, size: 16, color: Color(0xFF6B7280)),
                                  style: const TextStyle(fontSize: 12, color: Color(0xFF374151), fontWeight: FontWeight.w500),
                                  onChanged: (val) => setState(() => _selectedSearchCategory = val!),
                                  items: ['All Categories', 'Haircare', 'Skincare', 'Soaps', 'Wellness']
                                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                                      .toList(),
                                ),
                              ),
                            ),
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                decoration: const InputDecoration(
                                  hintText: 'Search for products, formulations and ritual guides...',
                                  hintStyle: TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () => context.go('/explore'),
                              child: Container(
                                width: 44,
                                height: 44,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF6366F1),
                                  borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(7),
                                    bottomRight: Radius.circular(7),
                                  ),
                                ),
                                child: const Icon(Icons.search, color: Colors.white, size: 20),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  const Spacer(),

                  // Shortcuts (Wishlist, Cart, Profile Avatar Greeting)
                  Row(
                    children: [
                      InkWell(
                        onTap: () => context.go('/wishlist'),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Badge(
                              isLabelVisible: wishlist.isNotEmpty,
                              label: Text('${wishlist.length}'),
                              backgroundColor: const Color(0xFF6366F1),
                              child: const Icon(Icons.favorite_border, size: 22, color: Color(0xFF374151)),
                            ),
                            const SizedBox(height: 2),
                            const Text('Wishlist', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Color(0xFF4B5563))),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),
                      InkWell(
                        onTap: () => context.go('/cart'),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Badge(
                              isLabelVisible: totalCartCount > 0,
                              label: Text('$totalCartCount'),
                              backgroundColor: const Color(0xFF6366F1),
                              child: const Icon(Icons.shopping_cart_outlined, size: 22, color: Color(0xFF374151)),
                            ),
                            const SizedBox(height: 2),
                            const Text('Cart', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Color(0xFF4B5563))),
                          ],
                        ),
                      ),
                      const SizedBox(width: 24),

                      // Dynamic User Profile Greeting Header Dropdown
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: const Color(0xFFEEF2FF),
                            child: Text(
                              displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U',
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF4F46E5)),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('Hello, $firstFirstName', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF4F46E5))),
                              Row(
                                children: const [
                                  Text('My Account', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF374151))),
                                  Icon(Icons.keyboard_arrow_down, size: 14, color: Color(0xFF374151)),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 3. Navigation Bar Links Header
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6366F1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.menu, color: Colors.white, size: 18),
                        SizedBox(width: 8),
                        Text('All Categories', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                        SizedBox(width: 16),
                        Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 18),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),

                  _navLink(context, 'Home', '/'),
                  _navLink(context, 'Shop', '/explore'),
                  _navLink(context, 'Categories', '/explore'),
                  _navLink(context, 'Deals', '/explore'),
                  _navLink(context, 'New Arrivals', '/explore'),
                  _navLink(context, 'Best Sellers', '/explore'),
                  _navLink(context, 'Brands', '/explore'),
                  _navLink(context, 'Blog', '/explore'),
                  _navLink(context, 'Contact', '/explore'),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 4. Main Body: Split View Sidebar Nav & Dashboard
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left Sidebar Navigation Card (Flex 2.5)
                  SizedBox(
                    width: 240,
                    child: _buildSidebarNav(context, displayName, displayEmail),
                  ),
                  const SizedBox(width: 24),

                  // Right Dynamic Dashboard View (Flex 9.5)
                  Expanded(
                    child: _buildDashboardContent(context, displayName, firstFirstName, displayEmail, displayPhone, referCode, isWide, realOrdersCount, wishlistCount),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 48),

            // 5. Storefront Footer
            const VaidyamFooterWidget(),
          ],
        ),
      ),
    );
  }

  Widget _navLink(BuildContext context, String title, String route) {
    return Padding(
      padding: const EdgeInsets.only(right: 20),
      child: InkWell(
        onTap: () => context.go(route),
        child: Text(
          title,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF374151)),
        ),
      ),
    );
  }

  Widget _buildSidebarNav(BuildContext context, String displayName, String displayEmail) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 8)],
      ),
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        children: [
          // Small User Bio Info Header
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: const Color(0xFF4F46E5),
                  child: Text(
                    displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(displayName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF111827)), maxLines: 1, overflow: TextOverflow.ellipsis),
                      Text(displayEmail, style: const TextStyle(fontSize: 10, color: Color(0xFF6B7280)), maxLines: 1, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          const SizedBox(height: 4),

          ..._sidebarNavItems.map((item) {
            final isSelected = _selectedTab == item['title'];
            final isLogout = item['title'] == 'Logout';

            return InkWell(
              onTap: () async {
                if (isLogout) {
                  await ref.read(authControllerProvider.notifier).signOut();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Logged out successfully.')));
                    context.go('/login');
                  }
                } else if (item['route'] != null) {
                  context.go(item['route'] as String);
                } else {
                  setState(() => _selectedTab = item['title'] as String);
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFEEF2FF) : Colors.transparent,
                  border: isSelected
                      ? const Border(left: BorderSide(color: Color(0xFF4F46E5), width: 3))
                      : null,
                ),
                child: Row(
                  children: [
                    Icon(
                      item['icon'] as IconData,
                      size: 18,
                      color: isLogout
                          ? Colors.red
                          : (isSelected ? const Color(0xFF4F46E5) : const Color(0xFF6B7280)),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      item['title'] as String,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isLogout
                            ? Colors.red
                            : (isSelected ? const Color(0xFF4F46E5) : const Color(0xFF374151)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildDashboardContent(
    BuildContext context,
    String displayName,
    String firstFirstName,
    String displayEmail,
    String displayPhone,
    String referCode,
    bool isWide,
    int totalOrdersCount,
    int wishlistCount,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Welcome Greeting Header
        Row(
          children: [
            Text(
              'Welcome back, $firstFirstName! 👋',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF111827)),
            ),
          ],
        ),
        const SizedBox(height: 4),
        const Text(
          "Here's what's happening with your account.",
          style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
        ),

        const SizedBox(height: 24),

        // 4 Key Summary Stat Cards Bar (Responsive Layout)
        isWide
            ? Row(
                children: [
                  Expanded(child: _buildStatCard('Total Orders', '$totalOrdersCount', 'View all orders', Icons.shopping_bag_outlined, const Color(0xFFEEF2FF), const Color(0xFF4F46E5), () => context.go('/orders'))),
                  const SizedBox(width: 16),
                  Expanded(child: _buildStatCard('Wishlist Items', '$wishlistCount', 'View wishlist', Icons.favorite_border, const Color(0xFFFEE2E2), const Color(0xFFEF4444), () => context.go('/wishlist'))),
                  const SizedBox(width: 16),
                  Expanded(child: _buildStatCard('Addresses', '1', 'Manage addresses', Icons.location_on_outlined, const Color(0xFFE0E7FF), const Color(0xFF6366F1), () {})),
                  const SizedBox(width: 16),
                  Expanded(child: _buildStatCard('Account Balance', '₹0', 'View balance', Icons.account_balance_wallet_outlined, const Color(0xFFFEF3C7), const Color(0xFFD97706), () {})),
                ],
              )
            : Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  SizedBox(width: (MediaQuery.of(context).size.width - 60) / 2, child: _buildStatCard('Total Orders', '$totalOrdersCount', 'View all orders', Icons.shopping_bag_outlined, const Color(0xFFEEF2FF), const Color(0xFF4F46E5), () => context.go('/orders'))),
                  SizedBox(width: (MediaQuery.of(context).size.width - 60) / 2, child: _buildStatCard('Wishlist Items', '$wishlistCount', 'View wishlist', Icons.favorite_border, const Color(0xFFFEE2E2), const Color(0xFFEF4444), () => context.go('/wishlist'))),
                  SizedBox(width: (MediaQuery.of(context).size.width - 60) / 2, child: _buildStatCard('Addresses', '1', 'Manage addresses', Icons.location_on_outlined, const Color(0xFFE0E7FF), const Color(0xFF6366F1), () {})),
                  SizedBox(width: (MediaQuery.of(context).size.width - 60) / 2, child: _buildStatCard('Account Balance', '₹0', 'View balance', Icons.account_balance_wallet_outlined, const Color(0xFFFEF3C7), const Color(0xFFD97706), () {})),
                ],
              ),

        const SizedBox(height: 24),

        // Two Column Content Grid (Recent Orders Table + Right Account Details Widgets)
        isWide
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left: Recent Orders Table Card (Expanded)
                  Expanded(
                    flex: 7,
                    child: _buildRecentOrdersCard(context),
                  ),
                  const SizedBox(width: 24),

                  // Right: Account Profile Card + Refer & Earn Widget (Flex 5)
                  Expanded(
                    flex: 5,
                    child: Column(
                      children: [
                        _buildAccountDetailsCard(context, displayName, displayEmail, displayPhone),
                        const SizedBox(height: 20),
                        _buildReferCard(context, referCode),
                      ],
                    ),
                  ),
                ],
              )
            : Column(
                children: [
                  _buildRecentOrdersCard(context),
                  const SizedBox(height: 24),
                  _buildAccountDetailsCard(context, displayName, displayEmail, displayPhone),
                  const SizedBox(height: 20),
                  _buildReferCard(context, referCode),
                ],
              ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, String actionLabel, IconData icon, Color bg, Color color, VoidCallback onTap) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 6)],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280), fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
                const SizedBox(height: 4),
                InkWell(
                  onTap: onTap,
                  child: Text(actionLabel, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentOrdersCard(BuildContext context) {
    final ordersAsync = ref.watch(userOrdersFutureProvider);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Recent Orders', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
              InkWell(
                onTap: () => context.go('/orders'),
                child: const Text('View All', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF4F46E5))),
              ),
            ],
          ),
          const SizedBox(height: 16),

          ordersAsync.when(
            data: (realOrders) {
              if (realOrders.isEmpty) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Column(
                    children: [
                      const Icon(Icons.shopping_bag_outlined, size: 48, color: Color(0xFF9CA3AF)),
                      const SizedBox(height: 12),
                      const Text('No Recent Orders', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
                      const SizedBox(height: 4),
                      const Text('You have not placed any orders yet. Explore our Ayurvedic formulations to start shopping.', style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)), textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () => context.go('/explore'),
                        icon: const Icon(Icons.local_mall_outlined, size: 16),
                        label: const Text('Explore Formulations'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4F46E5),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: realOrders.take(4).length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, idx) {
                  final ord = realOrders[idx];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(ord.orderNumber, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF111827))),
                            Text(DateFormat('MMM dd, yyyy').format(ord.createdAt), style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
                          ],
                        ),
                        const Spacer(),
                        Text('₹${ord.totalAmount.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF111827))),
                        const SizedBox(width: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: const Color(0xFFFEF3C7), borderRadius: BorderRadius.circular(6)),
                          child: Text(ord.fulfillmentStatus, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFD97706))),
                        ),
                        const SizedBox(width: 16),
                        InkWell(
                          onTap: () => context.go('/orders'),
                          child: const Text('Track Order', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF4F46E5))),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
            loading: () => const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator())),
            error: (_, __) => const Text('Unable to load orders', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountDetailsCard(BuildContext context, String displayName, String displayEmail, String displayPhone) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Account Details', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
          const SizedBox(height: 16),
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: const Color(0xFF4F46E5),
                child: Text(
                  displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(displayName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
                    Text(displayEmail, style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)), overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.phone_outlined, size: 16, color: Color(0xFF6B7280)),
              const SizedBox(width: 8),
              Text(displayPhone, style: const TextStyle(fontSize: 12, color: Color(0xFF374151), fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _showEditProfileDialog(context, displayName, displayEmail, displayPhone),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFE5E7EB)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              icon: const Icon(Icons.edit_outlined, size: 16, color: Color(0xFF4F46E5)),
              label: const Text('Edit Profile', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF4F46E5))),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReferCard(BuildContext context, String referCode) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4F46E5), Color(0xFF6366F1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('REFER & EARN', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
              Icon(Icons.card_giftcard, color: Colors.white, size: 20),
            ],
          ),
          const SizedBox(height: 6),
          const Text('Invite your friends and earn', style: TextStyle(color: Color(0xFFE0E7FF), fontSize: 12)),
          const SizedBox(height: 10),
          const Text('₹250', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900)),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _showReferralDialog(context, referCode),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF4F46E5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Invite Now', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
