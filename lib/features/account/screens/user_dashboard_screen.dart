import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../config/theme/app_colors.dart';
import '../../cart/controllers/cart_controller.dart';
import '../../catalog/repositories/product_repository.dart';

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
    {'title': 'Logout', 'icon': Icons.logout, 'route': '/signup'},
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showEditProfileDialog(BuildContext context) {
    final nameCtrl = TextEditingController(text: 'Rohit Sharma');
    final emailCtrl = TextEditingController(text: 'rohit@gmail.com');
    final phoneCtrl = TextEditingController(text: '+91 98765 43210');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Account Profile', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Full Name')),
            const SizedBox(height: 12),
            TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email Address')),
            const SizedBox(height: 12),
            TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'Phone Number')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profile details updated successfully!')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4F46E5), foregroundColor: Colors.white),
            child: const Text('Save Changes'),
          ),
        ],
      ),
    );
  }

  void _showReferralDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
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
                children: const [
                  Expanded(
                    child: Text(
                      'https://vaidyam.in/refer?code=ROHIT250',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF4F46E5)),
                    ),
                  ),
                  Icon(Icons.copy, size: 18, color: Color(0xFF4F46E5)),
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
    final totalCartCount = cartState.totalItemCount;

    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth > 900;

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
                  const Expanded(
                    child: Text(
                      'Free Shipping on orders over ₹499 • 100% Certified Organic Botanicals',
                      style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isWide)
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

            // 2. Main Header Bar (Logo, Category Search, Wishlist/Cart/User Profile)
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: [
                  // Brand Logo
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
                            fontWeight: FontWeight.w900,
                            color: AppColors.forestSageDark,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // Category Search Bar
                  if (isWide)
                    Container(
                      width: 480,
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
                                style: const TextStyle(fontSize: 13, color: Color(0xFF374151), fontWeight: FontWeight.w500),
                                items: ['All Categories', 'Haircare', 'Skincare', 'Wellness']
                                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                                    .toList(),
                                onChanged: (val) => setState(() => _selectedSearchCategory = val ?? 'All Categories'),
                              ),
                            ),
                          ),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              decoration: const InputDecoration(
                                hintText: 'Search for products, brands and more...',
                                hintStyle: TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(horizontal: 12),
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

                      // User Profile Greeting Header Dropdown
                      Row(
                        children: [
                          const CircleAvatar(
                            radius: 18,
                            backgroundColor: Color(0xFFEEF2FF),
                            child: Icon(Icons.person, size: 20, color: Color(0xFF4F46E5)),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Text('Hello, Rohit', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF4F46E5))),
                              Row(
                                children: [
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
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildNavLink('Home', () => context.go('/')),
                          _buildNavLink('Shop', () => context.go('/explore')),
                          _buildNavLink('Categories', () => context.go('/explore')),
                          _buildNavLink('Deals', () => context.go('/explore')),
                          _buildNavLink('New Arrivals', () => context.go('/explore')),
                          _buildNavLink('Best Sellers', () => context.go('/explore')),
                          _buildNavLink('Brands', () => context.go('/explore')),
                          _buildNavLink('Blog', () {}),
                          _buildNavLink('Contact', () {}),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 4. Main Dashboard Body (Responsive Layout)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1350),
                child: isWide
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Left Account Navigation Sidebar (240px)
                          SizedBox(
                            width: 240,
                            child: _buildSidebarNav(context),
                          ),

                          const SizedBox(width: 24),

                          // Right Main Section
                          Expanded(
                            child: _buildMainDashboardContent(context, isWide),
                          ),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSidebarNav(context),
                          const SizedBox(height: 24),
                          _buildMainDashboardContent(context, isWide),
                        ],
                      ),
              ),
            ),

            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  Widget _buildNavLink(String label, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 24),
      child: InkWell(
        onTap: onTap,
        child: Text(
          label,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF374151)),
        ),
      ),
    );
  }

  // Left Sidebar Component
  Widget _buildSidebarNav(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Text(
              'My Account',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
            ),
          ),
          const SizedBox(height: 12),
          ..._sidebarNavItems.map((item) {
            final isSelected = _selectedTab == item['title'];
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: InkWell(
                onTap: () {
                  if (item['route'] != null) {
                    context.go(item['route']);
                  } else {
                    setState(() => _selectedTab = item['title']);
                  }
                },
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFEEF2FF) : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        item['icon'] as IconData,
                        size: 18,
                        color: isSelected ? const Color(0xFF4F46E5) : const Color(0xFF6B7280),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        item['title'] as String,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected ? const Color(0xFF4F46E5) : const Color(0xFF374151),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // Main Dashboard Content Area
  Widget _buildMainDashboardContent(BuildContext context, bool isWide) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Welcome Greeting Header
        Row(
          children: const [
            Text(
              'Welcome back, Rohit! 👋',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF111827)),
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
                  Expanded(child: _buildStatCard('Total Orders', '12', 'View all orders', Icons.shopping_bag_outlined, const Color(0xFFEEF2FF), const Color(0xFF4F46E5), () => context.go('/orders'))),
                  const SizedBox(width: 16),
                  Expanded(child: _buildStatCard('Wishlist Items', '8', 'View wishlist', Icons.favorite_border, const Color(0xFFFEE2E2), const Color(0xFFEF4444), () => context.go('/wishlist'))),
                  const SizedBox(width: 16),
                  Expanded(child: _buildStatCard('Addresses', '3', 'Manage addresses', Icons.location_on_outlined, const Color(0xFFE0E7FF), const Color(0xFF6366F1), () {})),
                  const SizedBox(width: 16),
                  Expanded(child: _buildStatCard('Account Balance', '₹1,250', 'View balance', Icons.account_balance_wallet_outlined, const Color(0xFFFEF3C7), const Color(0xFFD97706), () {})),
                ],
              )
            : Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  SizedBox(width: (MediaQuery.of(context).size.width - 60) / 2, child: _buildStatCard('Total Orders', '12', 'View all orders', Icons.shopping_bag_outlined, const Color(0xFFEEF2FF), const Color(0xFF4F46E5), () => context.go('/orders'))),
                  SizedBox(width: (MediaQuery.of(context).size.width - 60) / 2, child: _buildStatCard('Wishlist Items', '8', 'View wishlist', Icons.favorite_border, const Color(0xFFFEE2E2), const Color(0xFFEF4444), () => context.go('/wishlist'))),
                  SizedBox(width: (MediaQuery.of(context).size.width - 60) / 2, child: _buildStatCard('Addresses', '3', 'Manage addresses', Icons.location_on_outlined, const Color(0xFFE0E7FF), const Color(0xFF6366F1), () {})),
                  SizedBox(width: (MediaQuery.of(context).size.width - 60) / 2, child: _buildStatCard('Account Balance', '₹1,250', 'View balance', Icons.account_balance_wallet_outlined, const Color(0xFFFEF3C7), const Color(0xFFD97706), () {})),
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
                    flex: 3,
                    child: _buildRecentOrdersCard(context),
                  ),

                  const SizedBox(width: 20),

                  // Right: Account Details & Refer Card
                  SizedBox(
                    width: 300,
                    child: Column(
                      children: [
                        _buildAccountDetailsCard(context),
                        const SizedBox(height: 16),
                        _buildReferCard(context),
                      ],
                    ),
                  ),
                ],
              )
            : Column(
                children: [
                  _buildRecentOrdersCard(context),
                  const SizedBox(height: 20),
                  _buildAccountDetailsCard(context),
                  const SizedBox(height: 16),
                  _buildReferCard(context),
                ],
              ),
      ],
    );
  }

  Widget _buildRecentOrdersCard(BuildContext context) {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Orders',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
              ),
              InkWell(
                onTap: () => context.go('/orders'),
                child: const Text(
                  'View All',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF4F46E5)),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Scrollable Orders Table for Small Viewports
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 550),
              child: Column(
                children: [
                  // Orders Table Header
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: const [
                        Expanded(flex: 2, child: Text('Order ID', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF6B7280)))),
                        Expanded(flex: 2, child: Text('Date', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF6B7280)))),
                        Expanded(flex: 2, child: Text('Amount', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF6B7280)))),
                        Expanded(flex: 2, child: Text('Status', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF6B7280)))),
                        Expanded(flex: 2, child: Text('Track', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF6B7280)))),
                      ],
                    ),
                  ),

                  const Divider(height: 1),

                  // Order Rows
                  _buildOrderRow('#ORD12543', 'May 26, 2025', '₹1,799', 'Delivered', const Color(0xFFDCFCE7), const Color(0xFF166534), 'Track Order'),
                  _buildOrderRow('#ORD12542', 'May 26, 2025', '₹2,499', 'Shipped', const Color(0xFFDBEAFE), const Color(0xFF1E40AF), 'Track Order'),
                  _buildOrderRow('#ORD12541', 'May 24, 2025', '₹7,499', 'Processing', const Color(0xFFFEF3C7), const Color(0xFF92400E), 'Track Order'),
                  _buildOrderRow('#ORD12540', 'May 20, 2025', '₹1,299', 'Cancelled', const Color(0xFFFEE2E2), const Color(0xFF991B1B), 'View Details'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountDetailsCard(BuildContext context) {
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
              const CircleAvatar(
                radius: 24,
                backgroundImage: AssetImage('assets/images/shampoo.jpg'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Rohit Sharma', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
                    Text('rohit@gmail.com', style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)), overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: const [
              Icon(Icons.phone_outlined, size: 16, color: Color(0xFF6B7280)),
              SizedBox(width: 8),
              Text('+91 98765 43210', style: TextStyle(fontSize: 12, color: Color(0xFF374151), fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _showEditProfileDialog(context),
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

  Widget _buildReferCard(BuildContext context) {
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
              onPressed: () => _showReferralDialog(context),
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

  Widget _buildStatCard(String label, String value, String actionLabel, IconData icon, Color bgColor, Color iconColor, VoidCallback onTap) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280), fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: onTap,
            child: Text(actionLabel, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: iconColor)),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderRow(String orderId, String date, String amount, String status, Color statusBg, Color statusTextColor, String action) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(orderId, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF111827)))),
          Expanded(flex: 2, child: Text(date, style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)))),
          Expanded(flex: 2, child: Text(amount, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF111827)))),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(6)),
                child: Text(status, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: statusTextColor)),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: InkWell(
              onTap: () {},
              child: Text(action, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF4F46E5))),
            ),
          ),
        ],
      ),
    );
  }
}
