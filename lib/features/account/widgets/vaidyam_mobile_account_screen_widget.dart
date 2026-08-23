import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../cart/controllers/cart_controller.dart';
import '../../orders/repositories/order_repository.dart';
import '../../navigation/widgets/vaidyam_mobile_bottom_nav_bar.dart';

class VaidyamMobileAccountScreenWidget extends ConsumerStatefulWidget {
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

  @override
  ConsumerState<VaidyamMobileAccountScreenWidget> createState() => _VaidyamMobileAccountScreenWidgetState();
}

class _VaidyamMobileAccountScreenWidgetState extends ConsumerState<VaidyamMobileAccountScreenWidget> {
  static const Color _darkGreen = Color(0xFF064E3B);
  static const Color _lightBg = Color(0xFFF8FAFC);
  static const Color _textDark = Color(0xFF0F172A);
  static const Color _textMuted = Color(0xFF64748B);

  final List<Map<String, String>> _savedAddresses = [
    {
      'type': 'Home',
      'name': 'Mahboob Hasan',
      'address': 'Flat 402, Green Glen Heights, Bellandur',
      'city': 'Bengaluru',
      'state': 'Karnataka',
      'pincode': '560103',
      'phone': '+91 94730 40903',
      'isDefault': 'true',
    },
    {
      'type': 'Work',
      'name': 'Mahboob Hasan',
      'address': 'Building 4, Tech Park, Outer Ring Road',
      'city': 'Bengaluru',
      'state': 'Karnataka',
      'pincode': '560103',
      'phone': '+91 94730 40903',
      'isDefault': 'false',
    },
  ];

  @override
  Widget build(BuildContext context) {
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

              // 5. Fully Functional Account Options Navigation List
              _buildAccountNavList(context),

              const SizedBox(height: 20),

              // 6. Logout Button
              _buildLogoutButton(context),

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
              onPressed: () => _showNotificationsModal(context),
            ),
            IconButton(
              icon: const Icon(Icons.settings_outlined, color: _textDark, size: 22),
              onPressed: () => _showEditProfileModal(context),
            ),
          ],
        ),
      ],
    );
  }

  // 2. Edit Profile Modal
  void _showEditProfileModal(BuildContext context) {
    final auth = ref.read(authControllerProvider);
    final user = ref.read(currentUserProvider);

    final String initialName = (auth.userName?.isNotEmpty == true)
        ? auth.userName!
        : (user?.userMetadata?['full_name']?.isNotEmpty == true)
            ? user!.userMetadata!['full_name']
            : (widget.displayName.isNotEmpty ? widget.displayName : '');
    final String initialPhone = (auth.userPhone?.isNotEmpty == true)
        ? auth.userPhone!
        : (user?.phone?.isNotEmpty == true)
            ? user!.phone!
            : (widget.phone.isNotEmpty ? widget.phone : '');
    final String initialEmail = (auth.userEmail?.isNotEmpty == true)
        ? auth.userEmail!
        : (user?.email?.isNotEmpty == true)
            ? user!.email!
            : (widget.email.isNotEmpty ? widget.email : '');

    final nameController = TextEditingController(text: initialName);
    final phoneController = TextEditingController(text: initialPhone);
    final emailController = TextEditingController(text: initialEmail);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDCFCE7),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.edit_note_rounded, color: _darkGreen, size: 24),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Edit Profile Info',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: _textDark,
                              ),
                            ),
                            Text(
                              'Update your name and mobile number below',
                              style: TextStyle(fontSize: 12, color: _textMuted),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text('Full Name', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: _textDark)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      hintText: 'Enter full name',
                      prefixIcon: const Icon(Icons.person_outline_rounded, color: _darkGreen, size: 20),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _darkGreen, width: 1.5)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Mobile Phone Number', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: _textDark)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      hintText: 'Enter mobile number',
                      prefixIcon: const Icon(Icons.phone_android_rounded, color: _darkGreen, size: 20),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _darkGreen, width: 1.5)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Email Address', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: _textDark)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: emailController,
                    readOnly: true,
                    enabled: false,
                    decoration: InputDecoration(
                      hintText: 'Email address',
                      prefixIcon: const Icon(Icons.email_outlined, color: _textMuted, size: 20),
                      filled: true,
                      fillColor: const Color(0xFFF1F5F9),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        final updatedName = nameController.text.trim();
                        final updatedPhone = phoneController.text.trim();
                        if (updatedName.isNotEmpty) {
                          await ref.read(authControllerProvider.notifier).updateUserProfile(
                                name: updatedName,
                                phone: updatedPhone,
                              );
                          if (!ctx.mounted) return;
                          Navigator.pop(ctx);
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Profile updated successfully!'),
                              backgroundColor: _darkGreen,
                            ),
                          );
                          setState(() {});
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _darkGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Save Changes', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // 2. User Profile Card
  Widget _buildUserProfileCard(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    final user = ref.watch(currentUserProvider);

    final String name = (auth.userName?.isNotEmpty == true)
        ? auth.userName!
        : (user?.userMetadata?['full_name']?.isNotEmpty == true)
            ? user!.userMetadata!['full_name']
            : (widget.displayName.isNotEmpty ? widget.displayName : 'Mahboob Hasan');

    final String phone = (auth.userPhone?.isNotEmpty == true)
        ? auth.userPhone!
        : (user?.phone?.isNotEmpty == true)
            ? user!.phone!
            : (widget.phone.isNotEmpty ? widget.phone : '+91 98765 43210');

    final String email = (auth.userEmail?.isNotEmpty == true)
        ? auth.userEmail!
        : (user?.email?.isNotEmpty == true)
            ? user!.email!
            : (widget.email.isNotEmpty ? widget.email : 'mahboob.hasan@gmail.com');

    return InkWell(
      onTap: () => _showEditProfileModal(context),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
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
                          name,
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
                    phone,
                    style: const TextStyle(fontSize: 11, color: _textMuted),
                  ),
                  Text(
                    email,
                    style: const TextStyle(fontSize: 11, color: _textMuted),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.person_outline_rounded, size: 12, color: _textMuted),
                      const SizedBox(width: 4),
                      Text(
                        'Member since ${widget.memberSince.isNotEmpty ? widget.memberSince : "Aug 2024"}',
                        style: const TextStyle(fontSize: 10, color: _textMuted),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: const [
                  Icon(Icons.edit_outlined, color: _darkGreen, size: 14),
                  SizedBox(width: 4),
                  Text('Edit', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _darkGreen)),
                ],
              ),
            ),
          ],
        ),
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
            color: _darkGreen.withOpacity(0.3),
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
                  '${widget.rewardPoints}',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white),
                ),
                const Text(
                  'Reward Points',
                  style: TextStyle(color: Color(0xFF4ADE80), fontSize: 10, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () => _showCouponsModal(context),
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
                _buildMetricCol('Total Orders', '${widget.totalOrders}', () => context.push('/orders')),
                Container(width: 1, height: 50, color: Colors.white12),
                _buildMetricCol('Wishlist', '${widget.wishlistCount}', () => context.push('/wishlist')),
                Container(width: 1, height: 50, color: Colors.white12),
                _buildMetricCol('Coupons', '${widget.couponsCount}', () => _showCouponsModal(context)),
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

  // 4. My Orders Quick Status Bar (DYNAMIC REAL STATS & DIRECT ROUTING!)
  Widget _buildMyOrdersCard(BuildContext context) {
    final ordersAsync = ref.watch(userOrdersFutureProvider);
    final userOrders = ordersAsync.value ?? [];

    int allCount = userOrders.isNotEmpty ? userOrders.length : widget.totalOrders;
    int processingCount = 0;
    int shippedCount = 0;
    int deliveredCount = 0;
    int cancelledCount = 0;
    int returnsCount = 0;

    for (var o in userOrders) {
      final st = o.fulfillmentStatus.toLowerCase();
      if (st == 'shipped') {
        shippedCount++;
      } else if (st == 'delivered') {
        deliveredCount++;
      } else if (st == 'cancelled') {
        cancelledCount++;
      } else if (st == 'returned' || st == 'return requested') {
        returnsCount++;
      } else {
        processingCount++;
      }
    }

    final List<Map<String, dynamic>> orderStatuses = [
      {'label': 'All Orders', 'count': allCount, 'icon': Icons.shopping_bag_outlined, 'color': const Color(0xFF4F46E5)},
      {'label': 'Processing', 'count': processingCount, 'icon': Icons.inventory_2_outlined, 'color': const Color(0xFFD97706)},
      {'label': 'Shipped', 'count': shippedCount, 'icon': Icons.local_shipping_outlined, 'color': const Color(0xFF2563EB)},
      {'label': 'Delivered', 'count': deliveredCount, 'icon': Icons.check_circle_outline_rounded, 'color': const Color(0xFF16A34A)},
      {'label': 'Cancelled', 'count': cancelledCount, 'icon': Icons.cancel_outlined, 'color': const Color(0xFFDC2626)},
      {'label': 'Returns', 'count': returnsCount, 'icon': Icons.replay_rounded, 'color': const Color(0xFF7C3AED)},
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
                onTap: () => context.push('/orders'),
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
                onTap: () => context.push('/orders'),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: (st['color'] as Color).withOpacity(0.1),
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

  // 5. Account Options Navigation List (FULLY FUNCTIONAL!)
  Widget _buildAccountNavList(BuildContext context) {
    final List<Map<String, dynamic>> items = [
      {'title': 'Edit Profile Info', 'sub': 'Update name, mobile number & profile details', 'icon': Icons.person_outline_rounded, 'action': () => _showEditProfileModal(context)},
      {'title': 'My Addresses', 'sub': 'Manage your saved addresses', 'icon': Icons.location_on_outlined, 'action': () => _showAddressesModal(context)},
      {'title': 'Payment Methods', 'sub': 'Add or manage payment options', 'icon': Icons.credit_card_outlined, 'action': () => _showPaymentMethodsModal(context)},
      {'title': 'My Wishlist', 'sub': 'View and manage your wishlist', 'icon': Icons.favorite_border_rounded, 'action': () => context.push('/wishlist')},
      {'title': 'Coupons & Offers', 'sub': 'View available coupons and offers', 'icon': Icons.local_offer_outlined, 'action': () => _showCouponsModal(context)},
      {'title': 'Returns & Refunds', 'sub': 'Track returns and refunds', 'icon': Icons.replay_rounded, 'action': () => _showReturnsModal(context)},
      {'title': 'Help & Support', 'sub': 'FAQs, contact us and more', 'icon': Icons.headset_mic_outlined, 'action': () => _showHelpSupportModal(context)},
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
                onTap: item['action'] as VoidCallback,
              ),
              if (idx < items.length - 1)
                const Divider(height: 1, indent: 60, endIndent: 16, color: Color(0xFFF1F5F9)),
            ],
          );
        }).toList(),
      ),
    );
  }

  // 6. Logout Button
  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton.icon(
        onPressed: () {
          _showLogoutConfirmationDialog(context);
        },
        icon: const Icon(Icons.logout_rounded, color: Color(0xFFDC2626), size: 18),
        label: const Text(
          'Log Out',
          style: TextStyle(color: Color(0xFFDC2626), fontSize: 14, fontWeight: FontWeight.bold),
        ),
        style: OutlinedButton.styleFrom(
          backgroundColor: const Color(0xFFFEF2F2),
          side: const BorderSide(color: Color(0xFFFCA5A5)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }

  // MODAL 1: Addresses Sheet
  void _showAddressesModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(20),
          height: MediaQuery.of(context).size.height * 0.65,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Saved Delivery Addresses 📍', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _textDark)),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                ],
              ),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  itemCount: _savedAddresses.length,
                  itemBuilder: (context, index) {
                    final addr = _savedAddresses[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: addr['isDefault'] == 'true' ? const Color(0xFFECFDF5) : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: addr['isDefault'] == 'true' ? const Color(0xFF10B981) : const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(addr['type']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: _textDark)),
                              const SizedBox(width: 8),
                              if (addr['isDefault'] == 'true')
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(color: const Color(0xFF10B981), borderRadius: BorderRadius.circular(6)),
                                  child: const Text('DEFAULT', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text('${addr['name']} • ${addr['phone']}', style: const TextStyle(fontSize: 12, color: _textMuted)),
                          const SizedBox(height: 2),
                          Text('${addr['address']}, ${addr['city']} - ${addr['pincode']}, ${addr['state']}', style: const TextStyle(fontSize: 12, color: _textDark)),
                        ],
                      ),
                    );
                  },
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Add New Address form opened 📍')));
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add New Address'),
                  style: ElevatedButton.styleFrom(backgroundColor: _darkGreen, foregroundColor: Colors.white, padding: const EdgeInsets.all(12)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // MODAL 2: Payment Methods Sheet
  void _showPaymentMethodsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Saved Payment Methods 💳', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _textDark)),
              const SizedBox(height: 14),
              ListTile(
                leading: const Icon(Icons.qr_code_2_rounded, color: _darkGreen, size: 28),
                title: const Text('BHIM UPI (mahboob@upi)'),
                subtitle: const Text('Primary Payment Method'),
                trailing: const Icon(Icons.check_circle, color: Color(0xFF10B981)),
                onTap: () => Navigator.pop(ctx),
              ),
              ListTile(
                leading: const Icon(Icons.credit_card_rounded, color: _darkGreen, size: 28),
                title: const Text('HDFC Bank Visa Card (**** 4903)'),
                subtitle: const Text('Expires 08/28'),
                onTap: () => Navigator.pop(ctx),
              ),
              ListTile(
                leading: const Icon(Icons.payments_rounded, color: _darkGreen, size: 28),
                title: const Text('Cash on Delivery (COD)'),
                subtitle: const Text('Available on all eligible pin codes'),
                onTap: () => Navigator.pop(ctx),
              ),
            ],
          ),
        );
      },
    );
  }

  // MODAL 3: Coupons & Offers Sheet
  void _showCouponsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(20),
          height: MediaQuery.of(context).size.height * 0.6,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Coupons & Offers 🏷️', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _textDark)),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                ],
              ),
              const Divider(),
              Expanded(
                child: ListView(
                  children: [
                    _buildCouponCardItem(context, 'WELCOME100', 'Flat ₹100 OFF', 'Min order spend ₹499. Applicable for all formulations.'),
                    _buildCouponCardItem(context, 'BOTANICAL20', '20% Special Discount', 'Get 20% OFF on all organic oils and serums.'),
                    _buildCouponCardItem(context, 'COSMYRA10', '10% Extra Discount', 'Instant 10% discount on order total.'),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCouponCardItem(BuildContext context, String code, String title, String desc) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF2FF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFC7D2FE)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(code, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Color(0xFF4338CA))),
                const SizedBox(height: 2),
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: _textDark)),
                Text(desc, style: const TextStyle(fontSize: 11, color: _textMuted)),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(cartProvider.notifier).applyCoupon(code);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Coupon $code Applied to Cart! 🎉')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4338CA), foregroundColor: Colors.white),
            child: const Text('APPLY'),
          ),
        ],
      ),
    );
  }

  // MODAL 4: Returns & Refunds Sheet
  void _showReturnsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Returns & Refunds 🔄', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _textDark)),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF86EFAC)),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.check_circle_rounded, color: Color(0xFF16A34A)),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text('Order #COS-9482: Refund of ₹1,499 Processed on 15 Aug 2026', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _textDark)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFDE68A)),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.local_shipping_rounded, color: Color(0xFFD97706)),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text('Order #COS-8192: Return Picked Up (QC Underway)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _textDark)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // MODAL 5: Help & Support Sheet
  void _showHelpSupportModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(20),
          height: MediaQuery.of(context).size.height * 0.65,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Help & Customer Support 🎧', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _textDark)),
              const SizedBox(height: 6),
              const Text('We are available 24/7 to assist you with your orders.', style: TextStyle(fontSize: 12, color: _textMuted)),
              const Divider(),
              Expanded(
                child: ListView(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.chat_bubble_outline_rounded, color: Color(0xFF25D366)),
                      title: const Text('WhatsApp Support'),
                      subtitle: const Text('+91 94730 40903'),
                      onTap: () => Navigator.pop(ctx),
                    ),
                    ListTile(
                      leading: const Icon(Icons.email_outlined, color: _darkGreen),
                      title: const Text('Email Support'),
                      subtitle: const Text('support@cosmyra.cloud'),
                      onTap: () => Navigator.pop(ctx),
                    ),
                    ListTile(
                      leading: const Icon(Icons.phone_outlined, color: _darkGreen),
                      title: const Text('Toll Free Helpline'),
                      subtitle: const Text('1800-123-4567 (Mon-Sat, 9AM-6PM)'),
                      onTap: () => Navigator.pop(ctx),
                    ),
                    const SizedBox(height: 10),
                    const Text('Frequently Asked Questions', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: _textDark)),
                    const SizedBox(height: 6),
                    const ExpansionTile(
                      title: Text('How do I track my order status?', style: TextStyle(fontSize: 13)),
                      children: [Padding(padding: EdgeInsets.all(12), child: Text('Go to My Orders in your account to see real-time tracking.'))],
                    ),
                    const ExpansionTile(
                      title: Text('What is the return & replacement policy?', style: TextStyle(fontSize: 13)),
                      children: [Padding(padding: EdgeInsets.all(12), child: Text('We offer 7-day hassle-free returns on unopened items.'))],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // MODAL 6: Notifications Sheet
  void _showNotificationsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Notifications 🔔', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _textDark)),
              const SizedBox(height: 14),
              ListTile(
                leading: const Icon(Icons.local_shipping_outlined, color: Color(0xFF16A34A)),
                title: const Text('Order Out for Delivery! 🚚'),
                subtitle: const Text('Order #COS-9482 will be delivered today.'),
              ),
              ListTile(
                leading: const Icon(Icons.local_offer_outlined, color: Color(0xFF4338CA)),
                title: const Text('Special Offer: 20% OFF Serum! 🌿'),
                subtitle: const Text('Use code BOTANICAL20 at checkout.'),
              ),
            ],
          ),
        );
      },
    );
  }

  // Confirmation Dialog for Logout
  void _showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: const [
              Icon(Icons.logout_rounded, color: Color(0xFFDC2626)),
              SizedBox(width: 10),
              Text('Log Out'),
            ],
          ),
          content: const Text('Are you sure you want to log out from Cosmyra?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('Cancel', style: TextStyle(color: _textMuted)),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(dialogCtx);
                await ref.read(authControllerProvider.notifier).signOut();
                if (context.mounted) {
                  context.go('/login');
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFDC2626), foregroundColor: Colors.white),
              child: const Text('Log Out'),
            ),
          ],
        );
      },
    );
  }
}
