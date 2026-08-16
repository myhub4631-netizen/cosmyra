import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../cart/controllers/cart_controller.dart';
import '../../catalog/repositories/product_repository.dart';
import '../../admin/controllers/brand_settings_controller.dart';
import '../../catalog/widgets/product_image_widget.dart';

class VaidyamHeaderWidget extends ConsumerStatefulWidget {
  final String activeTab;
  final bool showValuePropositions;

  const VaidyamHeaderWidget({
    super.key,
    this.activeTab = 'Home',
    this.showValuePropositions = true,
  });

  @override
  ConsumerState<VaidyamHeaderWidget> createState() => _VaidyamHeaderWidgetState();
}

class _VaidyamHeaderWidgetState extends ConsumerState<VaidyamHeaderWidget> {
  String _selectedCategory = 'All Categories';
  final TextEditingController _searchController = TextEditingController();

  static const Color _purpleTheme = Color(0xFF3B32B3);
  static const Color _textDark = Color(0xFF1E1B4B);
  static const Color _textMuted = Color(0xFF6B7280);
  static const Color _borderGray = Color(0xFFE5E7EB);
  static const Color _greenAccent = Color(0xFF4ADE80);

  final List<String> _categories = [
    'All Categories',
    'Haircare',
    'Skincare',
    'Soaps',
    'Body Care',
    'Face Serums',
    'Wellness',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _handleSearch() {
    final q = _searchController.text.trim();
    if (q.isNotEmpty) {
      context.go('/explore?query=${Uri.encodeComponent(q)}&category=${Uri.encodeComponent(_selectedCategory)}');
    } else {
      context.go('/explore');
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartProvider);
    final wishlist = ref.watch(wishlistProvider);
    final user = ref.watch(currentUserProvider);
    final auth = ref.watch(authControllerProvider);
    final brandSettings = ref.watch(brandSettingsProvider);

    final int cartCount = cartState.totalItemCount;
    final int wishlistCount = wishlist.length;

    final bool isLoggedIn = auth.isLoggedIn || user != null;
    final String accountLabel = isLoggedIn
        ? (auth.userName ?? user?.userMetadata?['full_name'] ?? 'Account')
        : 'Login';

    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth > 900;

    return Column(
      children: [
        // ── 1. TOP ANNOUNCEMENT BAR ──
        Container(
          width: double.infinity,
          color: _purpleTheme,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left Announcement
              Row(
                children: const [
                  Icon(Icons.local_shipping_outlined, color: Colors.white, size: 15),
                  SizedBox(width: 6),
                  Text(
                    'Free Shipping on orders over ',
                    style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                  Text(
                    '₹999',
                    style: TextStyle(color: _greenAccent, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ],
              ),

              // Center App Promotion (Desktop)
              if (isWide)
                Row(
                  children: const [
                    Icon(Icons.smartphone_outlined, color: Colors.white, size: 15),
                    SizedBox(width: 6),
                    Text(
                      'Download App & Get Extra ',
                      style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                    Text(
                      '10% Off',
                      style: TextStyle(color: _greenAccent, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),

              // Right Navigation Links
              Row(
                children: [
                  _topBarLink('Track Order', () => context.go('/orders')),
                  const Text('  |  ', style: TextStyle(color: Colors.white70, fontSize: 12)),
                  _topBarLink('Help & Support', () => context.go('/dashboard?tab=Help & Support')),
                  const Text('  |  ', style: TextStyle(color: Colors.white70, fontSize: 12)),
                  _topBarLink('Returns', () => context.go('/dashboard?tab=Returns & Refunds')),
                ],
              ),
            ],
          ),
        ),

        // ── 2. MAIN HEADER ROW (Logo, Search, Actions) ──
        Container(
          color: Colors.white,
          padding: EdgeInsets.symmetric(
            horizontal: isWide ? 32.0 : 16.0,
            vertical: 16.0,
          ),
          child: Row(
            children: [
              // Brand Logo
              InkWell(
                onTap: () => context.go('/'),
                child: brandSettings.headerLogoUrl.isNotEmpty
                    ? ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 56, maxWidth: 280),
                        child: ProductImageWidget(
                          imageUrl: brandSettings.headerLogoUrl,
                          height: 56,
                          fit: BoxFit.contain,
                        ),
                      )
                    : Image.asset(
                        'favicon.png',
                        height: 48,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: _purpleTheme,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(Icons.local_florist, color: Colors.white, size: 24),
                        ),
                      ),
              ),

              if (isWide) const SizedBox(width: 36),

              // Search Bar with Category Selector
              if (isWide)
                Expanded(
                  child: Container(
                    height: 46,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: _borderGray),
                    ),
                    child: Row(
                      children: [
                        // Category Dropdown
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedCategory,
                              icon: const Icon(Icons.keyboard_arrow_down, size: 16, color: _textMuted),
                              style: const TextStyle(fontSize: 13, color: _textDark, fontWeight: FontWeight.w600),
                              onChanged: (val) {
                                if (val != null) setState(() => _selectedCategory = val);
                              },
                              items: _categories
                                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                                  .toList(),
                            ),
                          ),
                        ),

                        const VerticalDivider(width: 1, color: _borderGray),

                        // Input Field
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            onSubmitted: (_) => _handleSearch(),
                            style: const TextStyle(fontSize: 13, color: _textDark),
                            decoration: const InputDecoration(
                              hintText: 'Search for products, formulations, ingredients...',
                              hintStyle: TextStyle(color: _textMuted, fontSize: 13),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(horizontal: 16),
                            ),
                          ),
                        ),

                        // Search Button
                        InkWell(
                          onTap: _handleSearch,
                          child: Container(
                            width: 52,
                            height: 46,
                            decoration: const BoxDecoration(
                              color: _purpleTheme,
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(9),
                                bottomRight: Radius.circular(9),
                              ),
                            ),
                            child: const Icon(Icons.search, color: Colors.white, size: 22),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              const Spacer(),

              // Right Action Icons (Wishlist, Cart, Account)
              Row(
                children: [
                  _actionIconButton(
                    icon: Icons.favorite_border,
                    label: 'Wishlist',
                    badgeCount: wishlistCount,
                    onTap: () => context.go('/wishlist'),
                  ),
                  const SizedBox(width: 24),
                  _actionIconButton(
                    icon: Icons.shopping_bag_outlined,
                    label: 'Cart',
                    badgeCount: cartCount,
                    onTap: () => context.go('/cart'),
                  ),
                  const SizedBox(width: 24),
                  _actionIconButton(
                    icon: Icons.person_outline,
                    label: accountLabel.length > 10 ? '${accountLabel.substring(0, 8)}...' : accountLabel,
                    badgeCount: 0,
                    onTap: () {
                      if (isLoggedIn) {
                        context.go('/dashboard');
                      } else {
                        context.go('/login');
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),

        // ── 3. NAVIGATION LINK BAR ──
        Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(color: Color(0xFFF3F4F6)),
              bottom: BorderSide(color: _borderGray),
            ),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: isWide ? 32.0 : 16.0,
            vertical: 8.0,
          ),
          child: Row(
            children: [
              // Shop by Categories Purple Dropdown Button
              PopupMenuButton<String>(
                onSelected: (cat) => context.go('/explore?category=${Uri.encodeComponent(cat)}'),
                itemBuilder: (context) => _categories
                    .where((c) => c != 'All Categories')
                    .map(
                      (cat) => PopupMenuItem(
                        value: cat,
                        child: Row(
                          children: [
                            const Icon(Icons.local_florist, size: 16, color: _purpleTheme),
                            const SizedBox(width: 10),
                            Text(cat, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    )
                    .toList(),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  decoration: BoxDecoration(
                    color: _purpleTheme,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.menu, color: Colors.white, size: 18),
                      SizedBox(width: 10),
                      Text(
                        'Shop by Categories',
                        style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(width: 12),
                      Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 18),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 32),

              // Navigation Links List
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _navTabLink('Home', widget.activeTab == 'Home', () => context.go('/')),
                      _navTabLink('Shop', widget.activeTab == 'Shop', () => context.go('/explore')),
                      _navTabLink('Categories', widget.activeTab == 'Categories', () => context.go('/explore')),
                      _navTabLink('Deals', widget.activeTab == 'Deals', () => context.go('/explore')),
                      _navTabLink('New Arrivals', widget.activeTab == 'New Arrivals', () => context.go('/explore')),
                      _navTabLink('Best Sellers', widget.activeTab == 'Best Sellers', () => context.go('/explore')),
                      _navTabLink('Brands', widget.activeTab == 'Brands', () => context.go('/explore')),
                      _navTabLink('Blog', widget.activeTab == 'Blog', () => context.go('/explore')),
                      _navTabLink('Contact', widget.activeTab == 'Contact', () => context.go('/explore')),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // ── 4. VALUE PROPOSITIONS FEATURE BAR ──
        if (widget.showValuePropositions)
          Container(
            color: Colors.white,
            padding: EdgeInsets.symmetric(
              horizontal: isWide ? 32.0 : 16.0,
              vertical: 16.0,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFF1F5F9)),
              ),
              child: isWide
                  ? Row(
                      children: [
                        Expanded(child: _valuePropItem(Icons.local_shipping_outlined, 'Free Shipping', 'On orders over ₹999')),
                        _valuePropDivider(),
                        Expanded(child: _valuePropItem(Icons.published_with_changes, 'Easy Returns', 'Within 7 days')),
                        _valuePropDivider(),
                        Expanded(child: _valuePropItem(Icons.shield_outlined, 'Secure Payments', '100% safe & secure')),
                        _valuePropDivider(),
                        Expanded(child: _valuePropItem(Icons.workspace_premium_outlined, '100% Authentic', 'Pure Ayurvedic Products')),
                      ],
                    )
                  : Wrap(
                      runSpacing: 16,
                      children: [
                        SizedBox(width: (screenWidth - 80) / 2, child: _valuePropItem(Icons.local_shipping_outlined, 'Free Shipping', 'On orders over ₹999')),
                        SizedBox(width: (screenWidth - 80) / 2, child: _valuePropItem(Icons.published_with_changes, 'Easy Returns', 'Within 7 days')),
                        SizedBox(width: (screenWidth - 80) / 2, child: _valuePropItem(Icons.shield_outlined, 'Secure Payments', '100% safe & secure')),
                        SizedBox(width: (screenWidth - 80) / 2, child: _valuePropItem(Icons.workspace_premium_outlined, '100% Authentic', 'Pure Ayurvedic Products')),
                      ],
                    ),
            ),
          ),
      ],
    );
  }

  Widget _topBarLink(String title, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Text(
        title,
        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w400),
      ),
    );
  }

  Widget _actionIconButton({
    required IconData icon,
    required String label,
    required int badgeCount,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(icon, color: _textDark, size: 24),
              if (badgeCount > 0)
                Positioned(
                  top: -7,
                  right: -9,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: _purpleTheme,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                    child: Text(
                      '$badgeCount',
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _textMuted),
          ),
        ],
      ),
    );
  }

  Widget _navTabLink(String title, bool isActive, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: InkWell(
        onTap: onTap,
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
                color: isActive ? _purpleTheme : _textDark,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              height: 2.5,
              width: isActive ? 24 : 0,
              decoration: BoxDecoration(
                color: isActive ? _purpleTheme : Colors.transparent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _valuePropDivider() {
    return Container(
      height: 36,
      width: 1,
      color: const Color(0xFFE2E8F0),
    );
  }

  Widget _valuePropItem(IconData icon, String title, String subtitle) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: const BoxDecoration(
            color: Color(0xFFEEF2FF),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: _purpleTheme, size: 22),
        ),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: _textDark),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: _textMuted),
            ),
          ],
        ),
      ],
    );
  }
}
