import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/center_action_toast.dart';
import '../../admin/controllers/homepage_cms_controller.dart';
import '../../cart/controllers/cart_controller.dart';
import '../models/product_model.dart';
import '../repositories/product_repository.dart';
import '../widgets/product_image_widget.dart';

import '../../navigation/widgets/vaidyam_footer_widget.dart';
import '../../navigation/widgets/vaidyam_header_widget.dart';

class VaidyamHomeScreen extends ConsumerStatefulWidget {
  const VaidyamHomeScreen({super.key});

  @override
  ConsumerState<VaidyamHomeScreen> createState() => _VaidyamHomeScreenState();
}

class _VaidyamHomeScreenState extends ConsumerState<VaidyamHomeScreen> {
  String _selectedSearchCategory = 'All Categories';
  final TextEditingController _searchController = TextEditingController();
  int _activeHeroIndex = 0;
  String _activeTrendingFilter = 'All';

  static const Color _primaryPurple = Color(0xFF4338CA);
  static const Color _lightBg = Color(0xFFF9FAFB);
  static const Color _cardBg = Color(0xFFEEF2FF);
  static const Color _borderGray = Color(0xFFE5E7EB);
  static const Color _textDark = Color(0xFF111827);
  static const Color _textMuted = Color(0xFF6B7280);

  final List<Map<String, String>> _categories = [
    {'title': 'Haircare & Oils', 'icon': '💇', 'asset': 'assets/images/shampoo.jpg'},
    {'title': 'Skincare & Serums', 'icon': '✨', 'asset': 'assets/images/facewash.jpg'},
    {'title': 'Organic Soaps', 'icon': '🧴', 'asset': 'assets/images/soap.jpg'},
    {'title': 'Wellness Oils', 'icon': '🌿', 'asset': 'assets/images/soap.jpg'},
    {'title': 'Radiance Elixirs', 'icon': '🌸', 'asset': 'assets/images/shampoo.jpg'},
    {'title': 'Gift Combos', 'icon': '🎁', 'asset': 'assets/images/soap.jpg'},
    {'title': 'Aloe & Hydration', 'icon': '💧', 'asset': 'assets/images/facewash.jpg'},
    {'title': 'Body Thailams', 'icon': '🍃', 'asset': 'assets/images/soap.jpg'},
  ];

  final List<Map<String, dynamic>> _dealProducts = [
    {
      'id': 'prod-1',
      'name': 'Kumkumadi Radiance Elixir',
      'category': 'Skincare & Serums',
      'price': 1799,
      'originalPrice': 2549,
      'discount': '29% OFF',
      'rating': 4.8,
      'reviews': 12345,
      'image': 'assets/images/facewash.jpg',
    },
    {
      'id': 'prod-2',
      'name': 'Bhringraj Hair Defense Oil',
      'category': 'Haircare & Scalp',
      'price': 1299,
      'originalPrice': 1699,
      'discount': '23% OFF',
      'rating': 4.7,
      'reviews': 8986,
      'image': 'assets/images/shampoo.jpg',
    },
    {
      'id': 'prod-3',
      'name': 'Nalpamaradi Body Thailam',
      'category': 'Body Care & Glow',
      'price': 999,
      'originalPrice': 1399,
      'discount': '28% OFF',
      'rating': 4.9,
      'reviews': 2134,
      'image': 'assets/images/soap.jpg',
    },
    {
      'id': 'prod-4',
      'name': 'Shata Dhauta Ghrita Cream',
      'category': 'Skin Moisturization',
      'price': 1499,
      'originalPrice': 1999,
      'discount': '25% OFF',
      'rating': 4.6,
      'reviews': 2210,
      'image': 'assets/images/facewash.jpg',
    },
    {
      'id': 'prod-5',
      'name': 'Chandan & Rose Face Wash',
      'category': 'Daily Cleanser',
      'price': 699,
      'originalPrice': 949,
      'discount': '26% OFF',
      'rating': 4.8,
      'reviews': 4321,
      'image': 'assets/images/facewash.jpg',
    },
    {
      'id': 'prod-6',
      'name': 'Triphala Hair Shampoo',
      'category': 'Herbal Cleansing',
      'price': 899,
      'originalPrice': 1199,
      'discount': '25% OFF',
      'rating': 4.7,
      'reviews': 1234,
      'image': 'assets/images/shampoo.jpg',
    },
  ];

  final List<Map<String, String>> _topBrands = [
    {'name': 'VAIDYAM', 'tag': 'Organic Botanicals'},
    {'name': 'KOTTAKKAL', 'tag': 'Traditional Ayurveda'},
    {'name': 'FOREST ESSENTIALS', 'tag': 'Luxurious Beauty'},
    {'name': 'KAMA AYURVEDA', 'tag': 'Pure Formulations'},
    {'name': 'BANYAN BOTANICALS', 'tag': 'Herbal Wellness'},
    {'name': 'BIOTIQUE', 'tag': 'Botanical Skincare'},
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _addDealToCart(Map<String, dynamic> deal, {bool isBuyNow = false}) {
    final double itemPrice = (deal['price'] is num)
        ? (deal['price'] as num).toDouble()
        : (double.tryParse(deal['price'].toString().replaceAll('₹', '').replaceAll(',', '')) ?? 499.0);

    final double itemMrp = (deal['originalPrice'] is num)
        ? (deal['originalPrice'] as num).toDouble()
        : (double.tryParse(deal['originalPrice']?.toString().replaceAll('₹', '').replaceAll(',', '') ?? '699') ?? (itemPrice * 1.2));

    final product = ProductModel(
      id: deal['id']?.toString() ?? 'p-${DateTime.now().millisecondsSinceEpoch}',
      brandId: 'brand-vaidyam',
      categoryId: deal['category']?.toString() ?? 'Botanical Care',
      name: deal['name']?.toString() ?? 'Ayurvedic Product',
      slug: deal['id']?.toString() ?? 'p-slug',
      description: 'Organic botanical formulation handcrafted for daily wellness.',
      ingredients: 'Organic Ayurvedic herbs & cold-pressed oils',
      freeFromClaims: const ['Paraben Free', 'Sulfate Free'],
      imageUrls: [deal['image']?.toString() ?? 'assets/images/shampoo.jpg'],
      variants: [
        ProductVariant(
          id: '${deal['id']}-v1',
          productId: deal['id']?.toString() ?? 'p-id',
          sku: '${deal['id']}-SKU',
          sizeLabel: 'Standard Pack',
          price: itemPrice,
          mrp: itemMrp,
          stock: 25,
          isDefault: true,
        ),
      ],
    );

    ref.read(cartProvider.notifier).addItem(product: product, variant: product.defaultVariant);

    if (isBuyNow) {
      context.push('/checkout');
    } else {
      showCenterActionToast(
        context,
        title: 'Added to Shopping Bag! 🛍️',
        message: deal['name'] as String,
        icon: Icons.check_circle_rounded,
        iconColor: const Color(0xFF059669),
        primaryActionLabel: 'VIEW CART',
        onPrimaryAction: () => context.push('/cart'),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartProvider);
    final wishlist = ref.watch(wishlistProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1024;

    return Scaffold(
      backgroundColor: _lightBg,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const VaidyamHeaderWidget(activeTab: 'Home', showValuePropositions: true),

            // 4. Hero Banner Section
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 48.0 : 16.0,
                vertical: 16.0,
              ),
              child: _buildHeroBannerSection(isDesktop),
            ),

            // 5. Shop by Categories
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 48.0 : 16.0,
                vertical: 24.0,
              ),
              child: _buildShopByCategoriesSection(isDesktop),
            ),

            // 6. Feature Trust Banner Bar
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 48.0 : 16.0,
              ),
              child: _buildFeatureTrustBannerBar(isDesktop),
            ),

            // 7. Today's Best Deals
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 48.0 : 16.0,
                vertical: 32.0,
              ),
              child: _buildTodayDealsSection(isDesktop),
            ),

            // 8. 🔥 Trending & Popular Formulations Showcase
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 48.0 : 16.0,
                vertical: 24.0,
              ),
              child: _buildTrendingSection(isDesktop),
            ),

            // 9. 🌱 Fresh Botanical New Arrivals
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 48.0 : 16.0,
                vertical: 24.0,
              ),
              child: _buildNewArrivalsSection(isDesktop),
            ),

            // 10. 👑 Customer Classics & Best Sellers
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 48.0 : 16.0,
                vertical: 24.0,
              ),
              child: _buildBestSellersSection(isDesktop),
            ),

            // 11. 🎁 Curated Routine Combos & Bundles
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 48.0 : 16.0,
                vertical: 24.0,
              ),
              child: _buildComboBundlesSection(isDesktop),
            ),

            // 12. Promo Banners Grid (3 Cards)
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 48.0 : 16.0,
                vertical: 24.0,
              ),
              child: _buildPromoBannersGrid(isDesktop),
            ),

            // 13. Top Brands You Love
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 48.0 : 16.0,
                vertical: 32.0,
              ),
              child: _buildTopBrandsSection(isDesktop),
            ),

            // 14. Bottom Metrics & Impact Bar
            _buildBottomMetricsBar(isDesktop),

            // 15. Full Website Footer
            const VaidyamFooterWidget(),
          ],
        ),
      ),
    );
  }

  // --- 1. TOP ANNOUNCEMENT BAR ---
  Widget _buildTopAnnouncementBar() {
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
                'Free Shipping on orders over ₹999',
                style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const Row(
            children: [
              Icon(Icons.phone_android_outlined, color: Colors.white, size: 16),
              SizedBox(width: 6),
              Text(
                'Download App & Get Extra 10% Off',
                style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          Row(
            children: [
              _topLink('Track Order'),
              const Text('  |  ', style: TextStyle(color: Colors.white70, fontSize: 12)),
              _topLink('Help & Support'),
              const Text('  |  ', style: TextStyle(color: Colors.white70, fontSize: 12)),
              _topLink('Returns'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _topLink(String label) {
    return InkWell(
      onTap: () {},
      child: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w400),
      ),
    );
  }

  // --- 2. MAIN HEADER ---
  Widget _buildMainHeader(int cartCount, int wishlistCount) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
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
                    color: _primaryPurple,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.local_florist, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Vaidyam Botanicals',
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

          // Search Bar
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
                        value: _selectedSearchCategory,
                        icon: const Icon(Icons.keyboard_arrow_down, size: 18, color: _textMuted),
                        style: const TextStyle(fontSize: 13, color: _textDark, fontWeight: FontWeight.w500),
                        onChanged: (val) => setState(() => _selectedSearchCategory = val!),
                        items: ['All Categories', 'Haircare', 'Skincare', 'Soaps', 'Oils', 'Elixirs']
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
                        hintText: 'Search for products, formulations, ingredients...',
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

          // Header Right Icons
          Row(
            children: [
              _headerActionIcon(
                icon: Icons.favorite_border,
                label: 'Wishlist',
                badgeCount: wishlistCount,
                onTap: () => context.push('/wishlist'),
              ),
              const SizedBox(width: 24),
              _headerActionIcon(
                icon: Icons.shopping_bag_outlined,
                label: 'Cart',
                badgeCount: cartCount,
                onTap: () => context.push('/cart'),
              ),
              const SizedBox(width: 24),
              _headerActionIcon(
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

  Widget _headerActionIcon({
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

  // --- 3. NAVIGATION BAR ---
  Widget _buildNavigationBar() {
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
              _navTabItem('Home', isActive: true),
              _navTabItem('Shop', onTap: () => context.push('/explore')),
              _navTabItem('Categories'),
              _navTabItem('Deals'),
              _navTabItem('New Arrivals'),
              _navTabItem('Best Sellers'),
              _navTabItem('Brands'),
              _navTabItem('Blog'),
              _navTabItem('Contact'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _navTabItem(String label, {bool isActive = false, VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: InkWell(
        onTap: onTap ?? () {},
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                color: isActive ? _primaryPurple : _textDark,
              ),
            ),
            if (isActive)
              Container(
                margin: const EdgeInsets.only(top: 4),
                height: 2,
                width: 20,
                color: _primaryPurple,
              ),
          ],
        ),
      ),
    );
  }

  // --- 4. HERO BANNER SECTION ---
  Widget _buildHeroBannerSection(bool isDesktop) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFEEF2FF), Color(0xFFFAF5FF)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderGray),
      ),
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.all(isDesktop ? 40.0 : 20.0),
            child: Row(
              children: [
                // Left Text & Actions
                Expanded(
                  flex: 6,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0E7FF),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'SUMMER SALE',
                          style: TextStyle(
                            color: _primaryPurple,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Big Savings on\nTop Botanical Brands',
                        style: TextStyle(
                          fontSize: isDesktop ? 38 : 24,
                          fontWeight: FontWeight.w900,
                          color: _textDark,
                          height: 1.15,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Get up to 60% OFF on organic skincare, hair defense, wellness & daily rituals.',
                        style: TextStyle(
                          fontSize: isDesktop ? 15 : 13,
                          color: _textMuted,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // CTA Buttons
                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: () => context.push('/explore'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _primaryPurple,
                              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text('Shop Now', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(width: 12),
                          OutlinedButton(
                            onPressed: () => context.push('/explore'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                              side: const BorderSide(color: _primaryPurple),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text('Explore Deals', style: TextStyle(color: _primaryPurple, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // Trust Badges Inside Hero
                      Row(
                        children: [
                          _heroTrustItem(Icons.local_shipping_outlined, 'Free Delivery', 'On orders over ₹999'),
                          const SizedBox(width: 24),
                          _heroTrustItem(Icons.access_time_outlined, '7 Days Returns', 'Easy returns & refunds'),
                          const SizedBox(width: 24),
                          _heroTrustItem(Icons.verified_user_outlined, '100% Secure', 'Safe & secure payments'),
                        ],
                      ),
                    ],
                  ),
                ),

                // Right Image & 60% Badge Showcase
                if (isDesktop)
                  Expanded(
                    flex: 5,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            height: 300,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Image.asset(
                              'assets/images/facewash.jpg',
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(Icons.spa, size: 120, color: _primaryPurple),
                            ),
                          ),
                        ),
                        // Floating 60% Badge
                        Positioned(
                          top: 10,
                          right: 10,
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: const BoxDecoration(
                              color: _primaryPurple,
                              shape: BoxShape.circle,
                            ),
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('UP TO', style: TextStyle(color: Colors.white70, fontSize: 9, fontWeight: FontWeight.bold)),
                                Text('60%', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
                                Text('OFF', style: TextStyle(color: Colors.white70, fontSize: 9, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // Slider Arrows (< and >)
          Positioned(
            left: 12,
            top: 150,
            child: CircleAvatar(
              backgroundColor: Colors.white.withValues(alpha: 0.9),
              radius: 18,
              child: const Icon(Icons.keyboard_arrow_left, color: _textDark, size: 20),
            ),
          ),
          Positioned(
            right: 12,
            top: 150,
            child: CircleAvatar(
              backgroundColor: Colors.white.withValues(alpha: 0.9),
              radius: 18,
              child: const Icon(Icons.keyboard_arrow_right, color: _textDark, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _heroTrustItem(IconData icon, String title, String subtitle) {
    return Row(
      children: [
        Icon(icon, size: 20, color: _primaryPurple),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _textDark)),
            Text(subtitle, style: const TextStyle(fontSize: 10, color: _textMuted)),
          ],
        ),
      ],
    );
  }

  // --- 5. SHOP BY CATEGORIES ---
  Widget _buildShopByCategoriesSection(bool isDesktop) {
    final cmsState = ref.watch(homepageCmsProvider);
    final categorySec = cmsState.sections.firstWhere(
      (s) => s['type'] == 'categories',
      orElse: () => {'isActive': true, 'items': _categories},
    );

    if (categorySec['isActive'] == false) return const SizedBox.shrink();

    final dynamicItems = (categorySec['items'] as List);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              categorySec['title']?.toString() ?? 'Shop by Categories',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: _textDark),
            ),
            InkWell(
              onTap: () => context.push('/explore'),
              child: const Row(
                children: [
                  Text('View All Categories', style: TextStyle(color: _primaryPurple, fontWeight: FontWeight.w600, fontSize: 13)),
                  SizedBox(width: 4),
                  Icon(Icons.arrow_forward, color: _primaryPurple, size: 14),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Horizontal Category Circles Row
        SizedBox(
          height: 125,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: dynamicItems.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final cat = dynamicItems[index] as Map<String, dynamic>;
              final title = cat['title']?.toString() ?? cat['name']?.toString() ?? 'Category';
              final emoji = cat['emoji']?.toString() ?? '';
              final iconData = cat['icon'] is IconData ? (cat['icon'] as IconData) : null;

              return InkWell(
                onTap: () => context.push('/explore'),
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        shape: BoxShape.circle,
                        border: Border.all(color: _borderGray),
                      ),
                      child: Center(
                        child: emoji.isNotEmpty
                            ? Text(emoji, style: const TextStyle(fontSize: 32))
                            : (iconData != null
                                ? Icon(iconData, size: 28, color: _primaryPurple)
                                : Text(
                                    title.isNotEmpty ? title.substring(0, 1).toUpperCase() : '✨',
                                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: _primaryPurple),
                                  )),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: 90,
                      child: Text(
                        title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _textDark),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // --- 6. FEATURE TRUST BANNER BAR ---
  Widget _buildFeatureTrustBannerBar(bool isDesktop) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _borderGray),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _trustFeatureBox(Icons.local_shipping_outlined, 'Free Shipping', 'On orders over ₹999'),
          _trustFeatureBox(Icons.replay_outlined, 'Easy Returns', 'Within 7 days'),
          _trustFeatureBox(Icons.verified_outlined, 'Best Quality', '100% Original Products'),
          _trustFeatureBox(Icons.lock_outline, 'Secure Payments', 'Multiple payment options'),
        ],
      ),
    );
  }

  Widget _trustFeatureBox(IconData icon, String title, String subtitle) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: _borderGray),
          ),
          child: Icon(icon, color: _primaryPurple, size: 20),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: _textDark)),
            Text(subtitle, style: const TextStyle(fontSize: 11, color: _textMuted)),
          ],
        ),
      ],
    );
  }

  // --- 7. TODAY'S BEST DEALS ---
  Widget _buildTodayDealsSection(bool isDesktop) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Today\'s Best Deals',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: _textDark),
            ),
            InkWell(
              onTap: () => context.push('/explore'),
              child: const Row(
                children: [
                  Text('View All Deals', style: TextStyle(color: _primaryPurple, fontWeight: FontWeight.w600, fontSize: 13)),
                  SizedBox(width: 4),
                  Icon(Icons.arrow_forward, color: _primaryPurple, size: 14),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Deals Grid Cards Row
        SizedBox(
          height: 335,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _dealProducts.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final deal = _dealProducts[index];
              return _buildDealProductCard(deal);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDealProductCard(Map<String, dynamic> deal) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _borderGray),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Image & Discount Tag
          Stack(
            children: [
              Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    deal['image'],
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(Icons.spa, size: 48, color: _primaryPurple),
                  ),
                ),
              ),
              Positioned(
                top: 6,
                left: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    deal['discount'],
                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Title & Category
          Text(
            deal['name'],
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: _textDark),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            deal['category'],
            style: const TextStyle(fontSize: 11, color: _textMuted),
          ),
          const SizedBox(height: 8),

          // Price Row
          Row(
            children: [
              Text(
                '₹${deal['price']}',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: _textDark),
              ),
              const SizedBox(width: 6),
              Text(
                '₹${deal['originalPrice']}',
                style: const TextStyle(fontSize: 12, decoration: TextDecoration.lineThrough, color: _textMuted),
              ),
            ],
          ),
          const SizedBox(height: 4),

          // Rating
          Row(
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 12),
              const SizedBox(width: 4),
              Text(
                '${deal['rating']} (${deal['reviews']})',
                style: const TextStyle(fontSize: 11, color: _textMuted),
              ),
            ],
          ),
          const Spacer(),

          // Add to Cart & Buy Now Row
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _addDealToCart(deal, isBuyNow: false),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    side: const BorderSide(color: _primaryPurple),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text('Add to Cart', style: TextStyle(color: _primaryPurple, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _addDealToCart(deal, isBuyNow: true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    elevation: 0,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text('Buy Now', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- 8. PROMO BANNERS GRID ---
  Widget _buildPromoBannersGrid(bool isDesktop) {
    return Row(
      children: [
        Expanded(child: _promoCard('Botanical Hair Fest', '50-80% OFF', Colors.purple.shade50)),
        const SizedBox(width: 16),
        Expanded(child: _promoCard('Skin Makeover', 'Up to 60% OFF', Colors.amber.shade50)),
        const SizedBox(width: 16),
        Expanded(child: _promoCard('Beauty Essentials', 'Up to 40% OFF', Colors.teal.shade50)),
      ],
    );
  }

  Widget _promoCard(String title, String discount, Color bg) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _borderGray),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _textDark)),
          const SizedBox(height: 4),
          Text(discount, style: const TextStyle(fontSize: 13, color: _primaryPurple, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          InkWell(
            onTap: () => context.push('/explore'),
            child: const Row(
              children: [
                Text('Shop Now', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _textDark)),
                SizedBox(width: 4),
                Icon(Icons.arrow_forward, size: 12, color: _textDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- 9. TOP BRANDS YOU LOVE ---
  Widget _buildTopBrandsSection(bool isDesktop) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Top Brands You Love',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: _textDark),
            ),
            InkWell(
              onTap: () => context.push('/explore'),
              child: const Row(
                children: [
                  Text('View All Brands', style: TextStyle(color: _primaryPurple, fontWeight: FontWeight.w600, fontSize: 13)),
                  SizedBox(width: 4),
                  Icon(Icons.arrow_forward, color: _primaryPurple, size: 14),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        SizedBox(
          height: 60,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _topBrands.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final brand = _topBrands[index];
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _borderGray),
                ),
                child: Center(
                  child: Text(
                    brand['name']!,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: _primaryPurple),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // --- 8. 🔥 TRENDING & POPULAR FORMULATIONS SHOWCASE ---
  Widget _buildTrendingSection(bool isDesktop) {
    final trendingFilters = ['All', 'Skincare', 'Haircare', 'Wellness', 'Elixirs'];

    final trendingProducts = _dealProducts.where((p) {
      if (_activeTrendingFilter == 'All') return true;
      return p['category'].toString().toLowerCase().contains(_activeTrendingFilter.toLowerCase());
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Text('🔥', style: TextStyle(fontSize: 20)),
                    SizedBox(width: 8),
                    Text(
                      'Trending & Popular Formulations',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: _textDark),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'Most loved organic Ayurvedic remedies by over 50,000+ customers',
                  style: TextStyle(fontSize: 13, color: _textMuted),
                ),
              ],
            ),

            // Filter Tabs
            if (isDesktop)
              Row(
                children: trendingFilters.map((filter) {
                  final isSelected = _activeTrendingFilter == filter;
                  return Container(
                    margin: const EdgeInsets.only(left: 8),
                    child: ChoiceChip(
                      label: Text(filter),
                      selected: isSelected,
                      selectedColor: _primaryPurple,
                      backgroundColor: Colors.white,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : _textDark,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        fontSize: 13,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(color: isSelected ? _primaryPurple : _borderGray),
                      ),
                      onSelected: (val) {
                        if (val) setState(() => _activeTrendingFilter = filter);
                      },
                    ),
                  );
                }).toList(),
              ),
          ],
        ),

        const SizedBox(height: 20),

        // Product Cards Grid
        LayoutBuilder(
          builder: (context, constraints) {
            final count = isDesktop ? 4 : (constraints.maxWidth > 600 ? 3 : 2);
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: trendingProducts.length.clamp(0, 4),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: count,
                childAspectRatio: isDesktop ? 0.98 : 0.88,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemBuilder: (context, index) {
                final prod = trendingProducts[index];
                return _buildShowcaseProductCard(prod);
              },
            );
          },
        ),
      ],
    );
  }

  // --- 9. 🌱 FRESH BOTANICAL NEW ARRIVALS ---
  Widget _buildNewArrivalsSection(bool isDesktop) {
    final newProducts = _dealProducts.sublist(2, 5);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4), // Soft Mint Green BG
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFDCFCE7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    '🌱 Fresh Botanical New Arrivals',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF166534)),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Recently crafted small-batch Ayurvedic formulations with 100% organic herbs',
                    style: TextStyle(fontSize: 13, color: Color(0xFF15803D)),
                  ),
                ],
              ),
              InkWell(
                onTap: () => context.push('/explore'),
                child: Row(
                  children: const [
                    Text('View All New', style: TextStyle(color: Color(0xFF166534), fontWeight: FontWeight.bold, fontSize: 13)),
                    SizedBox(width: 4),
                    Icon(Icons.arrow_forward_ios, size: 12, color: Color(0xFF166534)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Layout: Left Spotlight Banner + Right Product Cards
          isDesktop
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Spotlight Left Card
                    Expanded(
                      flex: 4,
                      child: Container(
                        height: 380,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFDCFCE7)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFDCFCE7),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text('Small-Batch Fresh', style: TextStyle(color: Color(0xFF15803D), fontSize: 11, fontWeight: FontWeight.bold)),
                            ),
                            Text('Tejasvi Saffron Brightening Polish', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey.shade900)),
                            const Text('Handcrafted with pure Kashmiri saffron, sandalwood dust, and raw turmeric root for radiant glow.', style: TextStyle(fontSize: 12, color: Color(0xFF15803D))),
                            ElevatedButton(
                              onPressed: () => context.push('/explore'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF166534),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: const Text('Discover New Collection', style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Right Cards Grid
                    Expanded(
                      flex: 8,
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: newProducts.length,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 0.96,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemBuilder: (context, idx) => _buildShowcaseProductCard(newProducts[idx]),
                      ),
                    ),
                  ],
                )
              : Column(
                  children: newProducts.map((p) => Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: _buildShowcaseProductCard(p),
                  )).toList(),
                ),
        ],
      ),
    );
  }

  // --- 10. 👑 CUSTOMER CLASSICS & BEST SELLERS ---
  Widget _buildBestSellersSection(bool isDesktop) {
    final bestSellers = [
      {
        'rank': '#1 BEST SELLER',
        'title': 'Bhringraj Hair Defense Oil',
        'badgeColor': const Color(0xFFD97706),
        'ingredients': '🌿 Neem • Bhringraj • Amla',
        'price': '₹1,299',
        'originalPrice': '₹1,699',
        'rating': 4.9,
        'reviewCount': '14,230 Reviews',
        'quote': '"Restored my hair volume within 3 weeks of daily ritual!"',
        'image': 'assets/images/shampoo.jpg',
      },
      {
        'rank': '#2 TOP RATED',
        'title': 'Kumkumadi Radiance Elixir',
        'badgeColor': const Color(0xFF4338CA),
        'ingredients': '🌸 Kashmiri Kesar • Chandan',
        'price': '₹1,799',
        'originalPrice': '₹2,549',
        'rating': 4.9,
        'reviewCount': '12,980 Reviews',
        'quote': '"My skin has never felt this hydrated and glowing naturally."',
        'image': 'assets/images/facewash.jpg',
      },
      {
        'rank': '#3 FAVORITE RITUAL',
        'title': 'Nalpamaradi Body Thailam',
        'badgeColor': const Color(0xFF059669),
        'ingredients': '🍃 Turmeric • Vetiver • Banyan Bark',
        'price': '₹999',
        'originalPrice': '₹1,399',
        'rating': 4.8,
        'reviewCount': '9,840 Reviews',
        'quote': '"The herbal scent and skin brightening effect are unreal."',
        'image': 'assets/images/soap.jpg',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '👑 Hall of Fame Best Sellers',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: _textDark),
                ),
                SizedBox(height: 4),
                Text(
                  'Tried, tested, and loved by hundreds of thousands across India',
                  style: TextStyle(fontSize: 13, color: _textMuted),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 20),

        Row(
          children: bestSellers.map((item) {
            return Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 6),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _borderGray),
                  boxShadow: const [
                    BoxShadow(color: Colors.black45, blurRadius: 4, offset: Offset(0, 2)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: item['badgeColor'] as Color,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        item['rank'] as String,
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: Container(
                        height: 120,
                        width: 120,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          image: DecorationImage(
                            image: AssetImage(item['image'] as String),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      item['title'] as String,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: _textDark),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item['ingredients'] as String,
                      style: const TextStyle(fontSize: 11, color: _primaryPurple, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 14),
                        const SizedBox(width: 4),
                        Text('${item['rating']}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 6),
                        Text('(${item['reviewCount']})', style: const TextStyle(fontSize: 11, color: _textMuted)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item['quote'] as String,
                      style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: _textMuted),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item['price'] as String, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _textDark)),
                            Text(item['originalPrice'] as String, style: const TextStyle(fontSize: 11, color: _textMuted, decoration: TextDecoration.lineThrough)),
                          ],
                        ),
                        Row(
                          children: [
                            OutlinedButton(
                              onPressed: () => _addDealToCart({
                                'id': 'bestseller-${item['title']}',
                                'name': item['title'],
                                'price': item['price'],
                                'originalPrice': item['originalPrice'],
                                'category': 'Best Seller',
                                'image': item['image'],
                              }, isBuyNow: false),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: _primaryPurple),
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: const Text('Add to Cart', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: _primaryPurple)),
                            ),
                            const SizedBox(width: 6),
                            ElevatedButton(
                              onPressed: () => _addDealToCart({
                                'id': 'bestseller-${item['title']}',
                                'name': item['title'],
                                'price': item['price'],
                                'originalPrice': item['originalPrice'],
                                'category': 'Best Seller',
                                'image': item['image'],
                              }, isBuyNow: true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _primaryPurple,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                elevation: 0,
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: const Text('Buy Now', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // --- 11. 🎁 CURATED ROUTINE COMBOS & BUNDLES ---
  Widget _buildComboBundlesSection(bool isDesktop) {
    final bundles = [
      {
        'title': 'Scalp & Hair Repair Ritual',
        'items': 'Includes Hair Oil + Shampoo + Herbal Tonic',
        'price': '₹2,499',
        'originalPrice': '₹3,697',
        'save': 'Save ₹1,198 (32% OFF)',
        'image': 'assets/images/shampoo.jpg',
      },
      {
        'title': 'Royal Radiance Glow Kit',
        'items': 'Kumkumadi Oil + Chandan Cleanser + Face Mask',
        'price': '₹2,899',
        'originalPrice': '₹4,297',
        'save': 'Save ₹1,398 (35% OFF)',
        'image': 'assets/images/facewash.jpg',
      },
      {
        'title': 'Daily Stress & Body Glow Trio',
        'items': 'Body Thailam + Ashwagandha Oil + Soap Bar',
        'price': '₹1,899',
        'originalPrice': '₹2,797',
        'save': 'Save ₹898 (32% OFF)',
        'image': 'assets/images/soap.jpg',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '🎁 Curated Routine Combos & Bundles',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: _textDark),
                ),
                SizedBox(height: 4),
                Text(
                  'Complete botanical wellness kits for maximum daily synergy • Save up to 35%',
                  style: TextStyle(fontSize: 13, color: _textMuted),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 20),

        Row(
          children: bundles.map((b) {
            return Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 6),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7), // Soft Warm Gold
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFFDE68A)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFB45309),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        b['save'] as String,
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      b['title'] as String,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF78350F)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      b['items'] as String,
                      style: const TextStyle(fontSize: 11, color: Color(0xFF92400E)),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(b['price'] as String, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF78350F))),
                            Text(b['originalPrice'] as String, style: const TextStyle(fontSize: 12, color: Color(0xFF92400E), decoration: TextDecoration.lineThrough)),
                          ],
                        ),
                        ElevatedButton(
                          onPressed: () => context.push('/cart'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFB45309),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          ),
                          child: const Text('Add Bundle', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // --- REUSABLE SHOWCASE PRODUCT CARD ---
  Widget _buildShowcaseProductCard(Map<String, dynamic> prod) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _borderGray),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
                child: Image.asset(
                  prod['image'] as String,
                  height: 130,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(color: _cardBg, height: 130, child: const Icon(Icons.spa, color: _primaryPurple)),
                ),
              ),
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.red.shade600,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    prod['discount'] as String,
                    style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: CircleAvatar(
                  radius: 14,
                  backgroundColor: Colors.white,
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    icon: const Icon(Icons.favorite_border, size: 14, color: Colors.grey),
                    onPressed: () {
                      ref.read(wishlistProvider.notifier).toggleWishlist(prod['id'] as String);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Added to Wishlist!'), duration: Duration(seconds: 1)),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  prod['name'] as String,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: _textDark),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  prod['category'] as String,
                  style: const TextStyle(fontSize: 10, color: _textMuted),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 12),
                        const SizedBox(width: 2),
                        Text('${prod['rating']}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Text('₹${prod['price']}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: _textDark)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _addDealToCart(prod, isBuyNow: false),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          side: const BorderSide(color: _primaryPurple),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text('Add to Cart', style: TextStyle(color: _primaryPurple, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _addDealToCart(prod, isBuyNow: true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primaryPurple,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                          elevation: 0,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text('Buy Now', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- 10. BOTTOM METRICS & IMPACT BAR ---
  Widget _buildBottomMetricsBar(bool isDesktop) {
    return Container(
      color: _primaryPurple,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _metricItem(Icons.people_outline, '10M+', 'Happy Customers'),
          _metricItem(Icons.inventory_2_outlined, '50K+', 'Products Available'),
          _metricItem(Icons.workspace_premium_outlined, '500+', 'Top Brands'),
          _metricItem(Icons.sentiment_satisfied_alt_outlined, '99.9%', 'Customer Satisfaction'),
        ],
      ),
    );
  }

  Widget _metricItem(IconData icon, String number, String label) {
    return Row(
      children: [
        Icon(icon, color: Colors.white, size: 28),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(number, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
          ],
        ),
      ],
    );
  }
}
