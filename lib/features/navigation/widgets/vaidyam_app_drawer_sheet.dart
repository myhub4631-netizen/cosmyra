import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../cart/controllers/cart_controller.dart';

class VaidyamAppDrawerSheet extends ConsumerStatefulWidget {
  const VaidyamAppDrawerSheet({super.key});

  static void show(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'AppDrawer',
      barrierColor: Colors.black.withOpacity(0.54),
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (context, anim1, anim2) => const Align(
        alignment: Alignment.centerLeft,
        child: VaidyamAppDrawerSheet(),
      ),
      transitionBuilder: (context, anim1, anim2, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(-1, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim1, curve: Curves.easeOutCubic)),
          child: child,
        );
      },
    );
  }

  @override
  ConsumerState<VaidyamAppDrawerSheet> createState() => _VaidyamAppDrawerSheetState();
}

class _VaidyamAppDrawerSheetState extends ConsumerState<VaidyamAppDrawerSheet> {
  static const Color _primaryPurple = Color(0xFF4F46E5);
  static const Color _textDark = Color(0xFF0F172A);
  static const Color _textMuted = Color(0xFF64748B);

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    final user = ref.watch(currentUserProvider);
    final cartState = ref.watch(cartProvider);
    final int cartCount = cartState.totalItemCount;

    final String name = (auth.userName != null && auth.userName!.isNotEmpty)
        ? auth.userName!
        : (user?.userMetadata?['full_name'] as String? ?? 'Mahboob Hasan');

    final String email = (auth.userEmail != null && auth.userEmail!.isNotEmpty)
        ? auth.userEmail!
        : (user?.email ?? 'mahboob.hasan@gmail.com');

    // Extract initials
    final parts = name.trim().split(' ');
    final String initials = parts.length >= 2
        ? '${parts[0][0]}${parts[1][0]}'.toUpperCase()
        : (name.isNotEmpty ? name[0].toUpperCase() : 'MH');

    final double screenWidth = MediaQuery.of(context).size.width;
    final double drawerWidth = screenWidth > 600 ? 360 : screenWidth * 0.84;

    return Material(
      color: Colors.transparent,
      child: Container(
        width: drawerWidth,
        height: double.infinity,
        color: Colors.white,
        child: SafeArea(
          child: Column(
            children: [
              // 1. Top Header Bar (COSMYRA Logo + Close Button)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Image.asset(
                          'assets/images/cosmyra_full_logo.png',
                          height: 32,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => Image.asset(
                            'assets/images/cosmyra_logo.png',
                            height: 32,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: _textDark, size: 22),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1, color: Color(0xFFF1F5F9)),

              // Scrollable Menu Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Column(
                    children: [
                      // 2. User Profile Card
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                          context.push('/account');
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 22,
                                backgroundColor: _primaryPurple,
                                child: Text(
                                  initials,
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 15),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Flexible(
                                          child: Text(
                                            name,
                                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: _textDark),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFEEF2FF),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: const [
                                              Icon(Icons.workspace_premium_rounded, size: 10, color: _primaryPurple),
                                              SizedBox(width: 2),
                                              Text(
                                                'Premium Member',
                                                style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: _primaryPurple),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      email,
                                      style: const TextStyle(fontSize: 11, color: _textMuted),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.chevron_right_rounded, color: _textMuted, size: 20),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 14),

                      // 3. Navigation List Items
                      _buildMenuItem(
                        icon: Icons.home_outlined,
                        label: 'Home',
                        isHighlighted: true,
                        onTap: () {
                          Navigator.pop(context);
                          context.go('/');
                        },
                      ),
                      _buildMenuItem(
                        icon: Icons.grid_view_outlined,
                        label: 'Categories',
                        onTap: () {
                          Navigator.pop(context);
                          context.push('/categories');
                        },
                      ),
                      _buildMenuItem(
                        icon: Icons.shopping_bag_outlined,
                        label: 'All Products',
                        onTap: () {
                          Navigator.pop(context);
                          context.push('/shop');
                        },
                      ),
                      _buildMenuItem(
                        icon: Icons.local_offer_outlined,
                        label: 'Deals & Offers',
                        badgeText: 'HOT',
                        badgeColor: const Color(0xFF6366F1),
                        onTap: () {
                          Navigator.pop(context);
                          context.push('/deals');
                        },
                      ),
                      _buildMenuItem(
                        icon: Icons.auto_awesome_outlined,
                        label: 'New Arrivals',
                        onTap: () {
                          Navigator.pop(context);
                          context.push('/shop');
                        },
                      ),
                      _buildMenuItem(
                        icon: Icons.star_outline_rounded,
                        label: 'Best Sellers',
                        onTap: () {
                          Navigator.pop(context);
                          context.push('/shop');
                        },
                      ),
                      _buildMenuItem(
                        icon: Icons.favorite_border_rounded,
                        label: 'Wishlist',
                        onTap: () {
                          Navigator.pop(context);
                          context.push('/wishlist');
                        },
                      ),
                      _buildMenuItem(
                        icon: Icons.shopping_cart_outlined,
                        label: 'Cart',
                        badgeText: '$cartCount',
                        badgeColor: const Color(0xFF6366F1),
                        isCircleBadge: true,
                        onTap: () {
                          Navigator.pop(context);
                          context.push('/cart');
                        },
                      ),
                      _buildMenuItem(
                        icon: Icons.receipt_long_outlined,
                        label: 'Orders',
                        onTap: () {
                          Navigator.pop(context);
                          context.push('/orders');
                        },
                      ),
                      _buildMenuItem(
                        icon: Icons.local_shipping_outlined,
                        label: 'Track Order',
                        onTap: () {
                          Navigator.pop(context);
                          context.push('/orders');
                        },
                      ),
                      _buildMenuItem(
                        icon: Icons.rate_review_outlined,
                        label: 'My Reviews',
                        onTap: () {
                          Navigator.pop(context);
                          context.push('/account');
                        },
                      ),
                      _buildMenuItem(
                        icon: Icons.confirmation_number_outlined,
                        label: 'My Coupons',
                        onTap: () {
                          Navigator.pop(context);
                          context.push('/account');
                        },
                      ),
                      _buildMenuItem(
                        icon: Icons.location_on_outlined,
                        label: 'Saved Addresses',
                        onTap: () {
                          Navigator.pop(context);
                          context.push('/account');
                        },
                      ),
                      _buildMenuItem(
                        icon: Icons.credit_card_outlined,
                        label: 'Payment Methods',
                        onTap: () {
                          Navigator.pop(context);
                          context.push('/account');
                        },
                      ),
                      _buildMenuItem(
                        icon: Icons.notifications_none_rounded,
                        label: 'Notifications',
                        badgeText: '2',
                        badgeColor: const Color(0xFF6366F1),
                        isCircleBadge: true,
                        onTap: () {
                          Navigator.pop(context);
                          context.push('/account');
                        },
                      ),
                      _buildMenuItem(
                        icon: Icons.help_outline_rounded,
                        label: 'Help & Support',
                        onTap: () {
                          Navigator.pop(context);
                          context.push('/account');
                        },
                      ),
                      _buildMenuItem(
                        icon: Icons.phone_outlined,
                        label: 'Contact Us',
                        onTap: () {
                          Navigator.pop(context);
                          context.push('/account');
                        },
                      ),
                      _buildMenuItem(
                        icon: Icons.info_outline_rounded,
                        label: 'About Cosmyra',
                        onTap: () {
                          Navigator.pop(context);
                          context.push('/account');
                        },
                      ),
                      _buildMenuItem(
                        icon: Icons.settings_outlined,
                        label: 'Settings',
                        onTap: () {
                          Navigator.pop(context);
                          context.push('/account');
                        },
                      ),

                      const SizedBox(height: 14),

                      // 4. Upgrade to Premium Banner Card
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3E8FF),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE9D5FF)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.workspace_premium_rounded, color: Color(0xFF7E22CE), size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    'Upgrade to Premium',
                                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Color(0xFF6B21A8)),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    'Get exclusive offers, early access & more!',
                                    style: TextStyle(fontSize: 10, color: Color(0xFF7E22CE)),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right_rounded, color: Color(0xFF7E22CE), size: 20),
                          ],
                        ),
                      ),

                      const SizedBox(height: 14),

                      // 5. Logout / Sign In Action Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            Navigator.pop(context);
                            if (auth.isLoggedIn) {
                              await ref.read(authControllerProvider.notifier).signOut();
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('👋 Logged out successfully')),
                                );
                              }
                            } else {
                              context.push('/login');
                            }
                          },
                          icon: Icon(
                            auth.isLoggedIn ? Icons.logout_rounded : Icons.login_rounded,
                            size: 18,
                            color: const Color(0xFFEF4444),
                          ),
                          label: Text(
                            auth.isLoggedIn ? 'Logout' : 'Sign In',
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFFEF4444)),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFEF2F2),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            elevation: 0,
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isHighlighted = false,
    String? badgeText,
    Color? badgeColor,
    bool isCircleBadge = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: isHighlighted ? const Color(0xFFEEF2FF) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: isHighlighted ? _primaryPurple : _textDark,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isHighlighted ? FontWeight.w900 : FontWeight.w600,
                      color: isHighlighted ? _primaryPurple : _textDark,
                    ),
                  ),
                ),
                if (badgeText != null) ...[
                  Container(
                    padding: isCircleBadge
                        ? const EdgeInsets.all(5)
                        : const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: badgeColor ?? _primaryPurple,
                      shape: isCircleBadge ? BoxShape.circle : BoxShape.rectangle,
                      borderRadius: isCircleBadge ? null : BorderRadius.circular(6),
                    ),
                    child: Text(
                      badgeText,
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Icon(
                  Icons.chevron_right_rounded,
                  size: 18,
                  color: isHighlighted ? _primaryPurple : _textMuted,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
