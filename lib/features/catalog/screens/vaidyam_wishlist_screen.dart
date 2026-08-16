import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/center_action_toast.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../cart/controllers/cart_controller.dart';
import '../models/product_model.dart';
import '../repositories/product_repository.dart';
import '../widgets/product_image_widget.dart';

import '../../navigation/widgets/vaidyam_footer_widget.dart';
import '../../navigation/widgets/vaidyam_header_widget.dart';
import '../../navigation/widgets/vaidyam_mobile_bottom_nav_bar.dart';
import '../widgets/vaidyam_mobile_wishlist_screen_widget.dart';

class VaidyamWishlistScreen extends ConsumerStatefulWidget {
  const VaidyamWishlistScreen({super.key});

  @override
  ConsumerState<VaidyamWishlistScreen> createState() => _VaidyamWishlistScreenState();
}

class _VaidyamWishlistScreenState extends ConsumerState<VaidyamWishlistScreen> {
  final Set<String> _selectedProductIds = {};
  String _selectedCategoryFilter = 'All Categories';
  final TextEditingController _searchController = TextEditingController();

  static const Color _primaryPurple = Color(0xFF4338CA);
  static const Color _lightBg = Color(0xFFF9FAFB);
  static const Color _activeNavBg = Color(0xFFEEF2FF);
  static const Color _borderGray = Color(0xFFE5E7EB);
  static const Color _textDark = Color(0xFF111827);
  static const Color _textMuted = Color(0xFF6B7280);

  // Fallback demo products matching exact ProductModel & ProductVariant schema
  static final List<ProductModel> _demoWishlistProducts = [];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleSelectProduct(String id) {
    setState(() {
      if (_selectedProductIds.contains(id)) {
        _selectedProductIds.remove(id);
      } else {
        _selectedProductIds.add(id);
      }
    });
  }

  void _addToCartSingle(ProductModel product) {
    final variant = product.defaultVariant;
    ref.read(cartProvider.notifier).addItem(product: product, variant: variant);
    showCenterActionToast(
      context,
      title: 'Added to Shopping Bag! 🛍️',
      message: product.name,
      icon: Icons.shopping_bag_outlined,
      iconColor: const Color(0xFF4F46E5),
      primaryActionLabel: 'VIEW CART',
      onPrimaryAction: () => context.push('/cart'),
    );
  }

  void _oneClickCheckoutSingle(ProductModel product) {
    final variant = product.defaultVariant;
    ref.read(cartProvider.notifier).addItem(product: product, variant: variant);
    context.push('/checkout');
  }

  void _oneClickCheckoutSelected(List<ProductModel> wishlistedProducts) {
    final itemsToCheckout = _selectedProductIds.isEmpty
        ? wishlistedProducts
        : wishlistedProducts.where((p) => _selectedProductIds.contains(p.id)).toList();

    if (itemsToCheckout.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one product to checkout.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    for (final product in itemsToCheckout) {
      final variant = product.defaultVariant;
      ref.read(cartProvider.notifier).addItem(product: product, variant: variant);
    }
    context.push('/checkout');
  }

  @override
  Widget build(BuildContext context) {
    final wishlistIds = ref.watch(wishlistProvider);
    final productsAsync = ref.watch(productsFutureProvider);
    final cartState = ref.watch(cartProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1024;

    if (screenWidth <= 768) {
      final allProducts = productsAsync.value ?? [];
      final wishlistedProducts = allProducts.where((p) => wishlistIds.contains(p.id)).toList();

      return VaidyamMobileWishlistScreenWidget(
        wishlistProducts: wishlistedProducts,
        onRefresh: () => setState(() {}),
      );
    }

    return Scaffold(
      backgroundColor: _lightBg,
      bottomNavigationBar: screenWidth <= 768 ? const VaidyamMobileBottomNavBar(activeTab: 'Wishlist') : null,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const VaidyamHeaderWidget(activeTab: 'Wishlist', showValuePropositions: true),

            // Two Column Layout
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 48.0 : 16.0,
                vertical: 24.0,
              ),
              child: productsAsync.when(
                data: (allProducts) {
                  List<ProductModel> wishlistedProducts = allProducts
                      .where((p) => wishlistIds.contains(p.id))
                      .toList();

                  if (_selectedProductIds.isEmpty && wishlistedProducts.isNotEmpty) {
                    _selectedProductIds.addAll(wishlistedProducts.map((p) => p.id));
                  }

                  return isDesktop
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 260,
                              child: _buildAccountSidebar(),
                            ),
                            const SizedBox(width: 32),
                            Expanded(
                              child: _buildWishlistMainArea(wishlistedProducts),
                            ),
                          ],
                        )
                      : Column(
                          children: [
                            _buildMobileNavigationTabs(),
                            const SizedBox(height: 20),
                            _buildWishlistMainArea(wishlistedProducts),
                          ],
                        );
                },
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(64.0),
                    child: CircularProgressIndicator(color: _primaryPurple),
                  ),
                ),
                error: (_, __) => _buildWishlistMainArea(const []),
              ),
            ),
            const SizedBox(height: 48),
            const VaidyamFooterWidget(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBanner() {
    return Container(
      color: _primaryPurple,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Row(
            children: [
              Icon(Icons.local_shipping_outlined, color: Colors.white, size: 16),
              SizedBox(width: 8),
              Text(
                'Free Shipping on orders over ₹999 • 100% Certified Organic Botanicals',
                style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          Row(
            children: [
              _bannerLink('Track Order'),
              const Text('  |  ', style: TextStyle(color: Colors.white70, fontSize: 12)),
              _bannerLink('Help & Support'),
              const Text('  |  ', style: TextStyle(color: Colors.white70, fontSize: 12)),
              _bannerLink('Returns'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _bannerLink(String label) {
    return InkWell(
      onTap: () {},
      child: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w400),
      ),
    );
  }

  Widget _buildHeaderBar(int cartCount, int wishlistCount) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      child: Row(
        children: [
          InkWell(
            onTap: () => context.go('/'),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _primaryPurple,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.local_florist, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Cosmyra',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: _primaryPurple,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 32),
          Expanded(
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _borderGray),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedCategoryFilter,
                        icon: const Icon(Icons.keyboard_arrow_down, size: 18, color: _textMuted),
                        style: const TextStyle(fontSize: 13, color: _textDark, fontWeight: FontWeight.w500),
                        onChanged: (val) => setState(() => _selectedCategoryFilter = val!),
                        items: ['All Categories', 'Skincare', 'Haircare', 'Body Care', 'Elixirs']
                            .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                            .toList(),
                      ),
                    ),
                  ),
                  const VerticalDivider(width: 1, color: _borderGray),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      style: const TextStyle(fontSize: 13),
                      decoration: const InputDecoration(
                        hintText: 'Search for formulations, botanical ingredients...',
                        hintStyle: TextStyle(color: _textMuted, fontSize: 13),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16),
                      ),
                    ),
                  ),
                  Container(
                    width: 48,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: _primaryPurple,
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(7),
                        bottomRight: Radius.circular(7),
                      ),
                    ),
                    child: const Icon(Icons.search, color: Colors.white, size: 20),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 32),
          Row(
            children: [
              _headerIconAction(
                icon: Icons.favorite_border,
                label: 'Wishlist',
                badgeCount: wishlistCount,
                onTap: () {},
              ),
              const SizedBox(width: 24),
              _headerIconAction(
                icon: Icons.shopping_bag_outlined,
                label: 'Cart',
                badgeCount: cartCount,
                onTap: () => context.push('/cart'),
              ),
              const SizedBox(width: 24),
              _headerIconAction(
                icon: Icons.person_outline,
                label: 'Account',
                badgeCount: 0,
                onTap: () => context.push('/dashboard'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _headerIconAction({
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
                  top: -6,
                  right: -8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: _primaryPurple,
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
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 12, color: _textMuted)),
        ],
      ),
    );
  }

  Widget _buildNavBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: _primaryPurple,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Icon(Icons.menu, color: Colors.white, size: 18),
                SizedBox(width: 8),
                Text(
                  'All Categories',
                  style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                ),
                SizedBox(width: 12),
                Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 18),
              ],
            ),
          ),
          const SizedBox(width: 24),
          Row(
            children: [
              _navLink('Home', onTap: () => context.go('/')),
              _navLink('Shop', onTap: () => context.push('/explore')),
              _navLink('Categories'),
              _navLink('Deals'),
              _navLink('New Arrivals'),
              _navLink('Best Sellers'),
              _navLink('Ayurvedic Brands'),
              _navLink('Botanical Blog'),
              _navLink('Contact'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _navLink(String label, {VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: InkWell(
        onTap: onTap ?? () {},
        child: Text(
          label,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: _textDark),
        ),
      ),
    );
  }

  Widget _buildAccountSidebar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _borderGray),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Text(
              'My Account',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _textDark),
            ),
          ),
          const Divider(height: 1, color: _borderGray),
          _sidebarItem(Icons.grid_view, 'Dashboard', onTap: () => context.go('/dashboard')),
          _sidebarItem(Icons.shopping_bag_outlined, 'My Orders', onTap: () => context.go('/orders')),
          _sidebarItem(Icons.favorite_outline, 'Wishlist', isActive: true),
          _sidebarItem(Icons.location_on_outlined, 'Addresses', onTap: () => context.go('/dashboard?tab=Addresses')),
          _sidebarItem(Icons.payment_outlined, 'Payment Methods', onTap: () => context.go('/dashboard?tab=Payment Methods')),
          _sidebarItem(Icons.confirmation_number_outlined, 'Coupons', onTap: () => context.go('/dashboard?tab=Coupons')),
          _sidebarItem(Icons.notifications_none_outlined, 'Notifications', onTap: () => context.go('/dashboard?tab=Notifications')),
          _sidebarItem(Icons.assignment_return_outlined, 'Returns & Refunds', onTap: () => context.go('/dashboard?tab=Returns & Refunds')),
          _sidebarItem(Icons.help_outline, 'Help & Support', onTap: () => context.go('/dashboard?tab=Help & Support')),
          _sidebarItem(Icons.settings_outlined, 'Account Settings', onTap: () => context.go('/dashboard?tab=Account Settings')),
          const Divider(height: 1, color: _borderGray),
          _sidebarItem(Icons.logout, 'Logout', isLogout: true, onTap: () async {
            await ref.read(authControllerProvider.notifier).signOut();
            if (context.mounted) context.go('/login');
          }),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _sidebarItem(
    IconData icon,
    String label, {
    bool isActive = false,
    bool isLogout = false,
    String? badge,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap ?? () {},
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? _activeNavBg : Colors.transparent,
          border: isActive
              ? const Border(left: BorderSide(color: _primaryPurple, width: 4))
              : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isLogout
                  ? Colors.red
                  : (isActive ? _primaryPurple : _textMuted),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  color: isLogout
                      ? Colors.red
                      : (isActive ? _primaryPurple : _textDark),
                ),
              ),
            ),
            if (badge != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  badge,
                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileNavigationTabs() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _mobileTabPill('Dashboard', onTap: () => context.push('/dashboard')),
          _mobileTabPill('Orders', onTap: () => context.push('/orders')),
          _mobileTabPill('Wishlist', isActive: true),
          _mobileTabPill('Addresses'),
          _mobileTabPill('Settings'),
        ],
      ),
    );
  }

  Widget _mobileTabPill(String label, {bool isActive = false, VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: InkWell(
        onTap: onTap ?? () {},
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isActive ? _primaryPurple : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: isActive ? _primaryPurple : _borderGray),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: isActive ? Colors.white : _textDark,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWishlistMainArea(List<ProductModel> products) {
    final totalCount = products.length;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _borderGray),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'My Wishlist',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: _textDark,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _activeNavBg,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$totalCount items',
                          style: const TextStyle(
                            color: _primaryPurple,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Save your favorite botanical formulations and shop them later.',
                    style: TextStyle(fontSize: 13, color: _textMuted),
                  ),
                ],
              ),
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Wishlist share link copied to clipboard!'),
                          backgroundColor: _primaryPurple,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    icon: const Icon(Icons.share_outlined, size: 16, color: _textDark),
                    label: const Text('Share Wishlist', style: TextStyle(color: _textDark, fontSize: 13)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      side: const BorderSide(color: _borderGray),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    onPressed: () {
                      ref.read(wishlistProvider.notifier).clearWishlist();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Wishlist cleared.'),
                          backgroundColor: Colors.grey,
                        ),
                      );
                    },
                    icon: const Icon(Icons.delete_outline, size: 16, color: _textDark),
                    label: const Text('Clear Wishlist', style: TextStyle(color: _textDark, fontSize: 13)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      side: const BorderSide(color: _borderGray),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          if (products.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 48.0),
                child: Column(
                  children: [
                    const Icon(Icons.favorite_border, size: 64, color: _borderGray),
                    const SizedBox(height: 16),
                    const Text(
                      'Your Wishlist is Empty',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _textDark),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Explore our botanical formulations and save your favorites here.',
                      style: TextStyle(color: _textMuted, fontSize: 13),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => context.push('/explore'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryPurple,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Explore Formulations', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: products.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final product = products[index];
                final isSelected = _selectedProductIds.contains(product.id);

                return _buildWishlistItemCard(product, isSelected);
              },
            ),

          const SizedBox(height: 24),
          const Divider(color: _borderGray),
          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              OutlinedButton.icon(
                onPressed: () => context.push('/explore'),
                icon: const Icon(Icons.arrow_back, size: 16, color: _textDark),
                label: const Text('Continue Shopping', style: TextStyle(color: _textDark, fontSize: 13, fontWeight: FontWeight.w500)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  side: const BorderSide(color: _borderGray),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              Row(
                children: [
                  Text(
                    '${_selectedProductIds.length} Items in wishlist',
                    style: const TextStyle(fontSize: 13, color: _textMuted, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton.icon(
                    onPressed: () => _oneClickCheckoutSelected(products),
                    icon: const Icon(Icons.flash_on, size: 18, color: Colors.white),
                    label: const Text(
                      '1-Click Checkout All',
                      style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryPurple,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWishlistItemCard(ProductModel product, bool isSelected) {
    final variant = product.defaultVariant;
    final discountPercent = variant.discountPercent.toInt();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isSelected ? _primaryPurple.withValues(alpha: 0.3) : _borderGray),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Checkbox(
            value: isSelected,
            activeColor: _primaryPurple,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            onChanged: (_) => _toggleSelectProduct(product.id),
          ),
          const SizedBox(width: 8),

          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _borderGray),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: ProductImageWidget(
                imageUrl: product.imageUrls.isNotEmpty ? product.imageUrls.first : '',
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 16),

          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: _textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${product.categoryId} • ${variant.sizeLabel}',
                  style: const TextStyle(fontSize: 12, color: _textMuted),
                ),
                const SizedBox(height: 6),
                const Row(
                  children: [
                    Icon(Icons.star, color: Colors.amber, size: 14),
                    SizedBox(width: 4),
                    Text(
                      '4.8 (1,245 reviews)',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _textDark),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '₹${variant.price.toInt()}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _textDark,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '₹${variant.mrp.toInt()}',
                      style: const TextStyle(
                        fontSize: 13,
                        decoration: TextDecoration.lineThrough,
                        color: _textMuted,
                      ),
                    ),
                    const SizedBox(width: 6),
                    if (discountPercent > 0)
                      Text(
                        '$discountPercent% OFF',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                const Row(
                  children: [
                    Icon(Icons.circle, color: Color(0xFF16A34A), size: 8),
                    SizedBox(width: 6),
                    Text(
                      'In Stock',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF16A34A),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Row(
            children: [
              OutlinedButton.icon(
                onPressed: () => _addToCartSingle(product),
                icon: const Icon(Icons.shopping_cart_outlined, size: 16, color: _primaryPurple),
                label: const Text(
                  'Add to Cart',
                  style: TextStyle(color: _primaryPurple, fontSize: 13, fontWeight: FontWeight.w600),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  side: const BorderSide(color: _primaryPurple),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton.icon(
                onPressed: () => _oneClickCheckoutSingle(product),
                icon: const Icon(Icons.flash_on, size: 16, color: Colors.white),
                label: const Text(
                  '1-Click Checkout',
                  style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryPurple,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(width: 10),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: _textMuted, size: 20),
                onPressed: () {
                  ref.read(wishlistProvider.notifier).removeFromWishlist(product.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${product.name} removed from wishlist.'),
                      action: SnackBarAction(
                        label: 'UNDO',
                        textColor: Colors.white,
                        onPressed: () {
                          ref.read(wishlistProvider.notifier).toggleWishlist(product.id);
                        },
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
