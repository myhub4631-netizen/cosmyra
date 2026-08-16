import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../cart/controllers/cart_controller.dart';
import '../../catalog/repositories/product_repository.dart';
import '../../navigation/widgets/vaidyam_mobile_bottom_nav_bar.dart';

class VaidyamMobileAccountScreenWidget extends ConsumerWidget {
  final String displayName;
  final String email;
  final String phone;
  final String memberSince;
  final int totalOrders;
  final int wishlistCount;
  final int couponsCount;
  final int rewardPoints;
  final Function(String tabName) onSelectTab;

  const VaidyamMobileAccountScreenWidget({
    super.key,
    required this.displayName,
    required this.email,
    required this.phone,
    required this.memberSince,
    required this.totalOrders,
    required this.wishlistCount,
    required this.couponsCount,
    required this.rewardPoints,
    required this.onSelectTab,
  });

  static const Color _darkGreen = Color(0xFF064E3B);
  static const Color _lightBg = Color(0xFFF8FAFC);
  static const Color _textDark = Color(0xFF0F172A);
  static const Color _textMuted = Color(0xFF64748B);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: _lightBg,
      bottomNavigationBar: const VaidyamMobileBottomNavBar(activeTab: 'Account'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header Bar: My Account + Bell & Settings
              _buildHeaderBar(context),

              const SizedBox(height: 16),

              // 2. User Profile Card
              _buildUserProfileCard(context),

              const SizedBox(height: 16),

              // 3. Rewards & Quick Metrics Banner (Dark Forest Green Card)
              _buildRewardsBanner(context),

              const SizedBox(height: 16),

              // 4. My Orders Quick Status Bar
              _buildMyOrdersCard(context),

              const SizedBox(height: 16),

              // 5. Account Options Navigation List
              _buildAccountNavList(context, ref),

              const SizedBox(height: 16),

              // 6. Upgrade to Cosmyra Premium Card
              _buildPremiumCard(context),

              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
    );
  }

  // 1. Header Bar
  Widget _buildHeaderBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const SizedBox(width: 48), // Balancing title center
        const Text(
          'My Account',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: _textDark,
          ),
        ),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_none_rounded, color: _textDark, size: 22),
              onPressed: () => onSelectTab('Notifications'),
            ),
            IconButton(
              icon: const Icon(Icons.settings_outlined, color: _textDark, size: 22),
              onPressed: () => onSelectTab('Account Settings'),
            ),
          ],
        ),
      ],
    );
  }

  // 2. User Profile Card
  Widget _buildUserProfileCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // User Avatar
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFFDCFCE7),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF86EFAC), width: 2),
            ),
            child: const Center(
              child: Icon(Icons.person_rounded, color: _darkGreen, size: 36),
            ),
          ),
          const SizedBox(width: 14),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        displayName.isNotEmpty ? displayName : 'Mahboob Hasan',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: _textDark,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCFCE7),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.check_circle_rounded, color: Color(0xFF16A34A), size: 10),
                          SizedBox(width: 2),
                          Text('Verified', style: TextStyle(color: Color(0xFF15803D), fontSize: 9, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  phone.isNotEmpty ? phone : '+91 98765 43210',
                  style: const TextStyle(fontSize: 11, color: _textMuted),
                ),
                Text(
                  email.isNotEmpty ? email : 'mahboob.hasan@gmail.com',
                  style: const TextStyle(fontSize: 11, color: _textMuted),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.person_outline_rounded, size: 12, color: _textMuted),
                    const SizedBox(width: 4),
                    Text(
                      'Member since ${memberSince.isNotEmpty ? memberSince : "Aug 2024"}',
                      style: const TextStyle(fontSize: 10, color: _textMuted),
                    ),
                  ],
                ),
              ],
            ),
          ),

          IconButton(
            icon: const Icon(Icons.chevron_right_rounded, color: _textMuted, size: 24),
            onPressed: () => onSelectTab('Account Details'),
          ),
        ],
      ),
    );
  }

  // 3. Rewards & Quick Metrics Banner
  Widget _buildRewardsBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _darkGreen,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _darkGreen.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Rewards Left Section
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.workspace_premium_rounded, color: Color(0xFFFBBF24), size: 14),
                    SizedBox(width: 4),
                    Text(
                      'COSMYRA REWARDS',
                      style: TextStyle(color: Color(0xFFA7F3D0), fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '$rewardPoints',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white),
                ),
                const Text(
                  'Reward Points',
                  style: TextStyle(color: Color(0xFF4ADE80), fontSize: 10, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () => onSelectTab('Coupons'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: _darkGreen,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                  ),
                  child: const Text('View Rewards', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),

          Container(width: 1, height: 80, color: Colors.white24),

          // 3 Metric Columns
          Expanded(
            flex: 6,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMetricCol('Total Orders', '$totalOrders', () => onSelectTab('My Orders')),
                Container(width: 1, height: 50, color: Colors.white12),
                _buildMetricCol('Wishlist', '$wishlistCount', () => context.push('/wishlist')),
                Container(width: 1, height: 50, color: Colors.white12),
                _buildMetricCol('Coupons', '$couponsCount', () => onSelectTab('Coupons')),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCol(String title, String val, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title, style: const TextStyle(color: Color(0xFFA7F3D0), fontSize: 9)),
          const SizedBox(height: 4),
          Text(val, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          const Text('View all', style: TextStyle(color: Colors.white70, fontSize: 8)),
        ],
      ),
    );
  }

  // 4. My Orders Quick Status Bar
  Widget _buildMyOrdersCard(BuildContext context) {
    final List<Map<String, dynamic>> orderStatuses = [
      {'label': 'All Orders', 'count': totalOrders, 'icon': Icons.shopping_bag_outlined, 'color': const Color(0xFF4F46E5)},
      {'label': 'Processing', 'count': 3, 'icon': Icons.inventory_2_outlined, 'color': const Color(0xFFD97706)},
      {'label': 'Shipped', 'count': 7, 'icon': Icons.local_shipping_outlined, 'color': const Color(0xFF2563EB)},
      {'label': 'Delivered', 'count': 12, 'icon': Icons.check_circle_outline_rounded, 'color': const Color(0xFF16A34A)},
      {'label': 'Cancelled', 'count': 2, 'icon': Icons.cancel_outlined, 'color': const Color(0xFFDC2626)},
      {'label': 'Returns', 'count': 1, 'icon': Icons.replay_rounded, 'color': const Color(0xFF7C3AED)},
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('My Orders', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: _textDark)),
              InkWell(
                onTap: () => onSelectTab('My Orders'),
                child: Row(
                  children: const [
                    Text('View All Orders', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _darkGreen)),
                    SizedBox(width: 2),
                    Icon(Icons.chevron_right_rounded, size: 16, color: _darkGreen),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: orderStatuses.map((st) {
              return InkWell(
                onTap: () => onSelectTab('My Orders'),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: (st['color'] as Color).withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(st['icon'] as IconData, color: st['color'] as Color, size: 18),
                    ),
                    const SizedBox(height: 4),
                    Text(st['label'] as String, style: const TextStyle(fontSize: 9, color: _textMuted)),
                    Text('${st['count']}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _textDark)),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // 5. Account Options Navigation List
  Widget _buildAccountNavList(BuildContext context, WidgetRef ref) {
    final List<Map<String, dynamic>> items = [
      {'title': 'My Addresses', 'sub': 'Manage your saved addresses', 'icon': Icons.location_on_outlined, 'tab': 'My Addresses'},
      {'title': 'Payment Methods', 'sub': 'Add or manage payment options', 'icon': Icons.credit_card_outlined, 'tab': 'Payment Methods'},
      {'title': 'My Wishlist', 'sub': 'View and manage your wishlist', 'icon': Icons.favorite_border_rounded, 'tab': 'Wishlist'},
      {'title': 'Coupons & Offers', 'sub': 'View available coupons and offers', 'icon': Icons.local_offer_outlined, 'tab': 'Coupons'},
      {'title': 'Returns & Refunds', 'sub': 'Track returns and refunds', 'icon': Icons.replay_rounded, 'tab': 'Returns & Refunds'},
      {'title': 'Help & Support', 'sub': 'FAQs, contact us and more', 'icon': Icons.headset_mic_outlined, 'tab': 'Help & Support'},
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: items.asMap().entries.map((entry) {
          final idx = entry.key;
          final item = entry.value;
          return Column(
            children: [
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(item['icon'] as IconData, color: _darkGreen, size: 20),
                ),
                title: Text(item['title'] as String, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: _textDark)),
                subtitle: Text(item['sub'] as String, style: const TextStyle(fontSize: 10, color: _textMuted)),
                trailing: const Icon(Icons.chevron_right_rounded, color: _textMuted, size: 20),
                onTap: () {
                  if (item['tab'] == 'Wishlist') {
                    context.push('/wishlist');
                  } else {
                    onSelectTab(item['tab'] as String);
                  }
                },
              ),
              if (idx < items.length - 1)
                const Divider(height: 1, indent: 60, endIndent: 16, color: Color(0xFFF1F5F9)),
            ],
          );
        }).toList(),
      ),
    );
  }

  // 6. Upgrade to Cosmyra Premium Card
  Widget _buildPremiumCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFECFDF5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFA7F3D0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Color(0xFFFEF3C7),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.workspace_premium_rounded, color: Color(0xFFD97706), size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Upgrade to Cosmyra Premium',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: _darkGreen),
                ),
                SizedBox(height: 2),
                Text(
                  'Exclusive offers, early access & free shipping!',
                  style: TextStyle(fontSize: 10, color: Color(0xFF047857)),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cosmyra Premium membership coming soon! 👑')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _darkGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            child: Row(
              children: const [
                Text('Explore Premium', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                SizedBox(width: 2),
                Icon(Icons.chevron_right_rounded, size: 14),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
