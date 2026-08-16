import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/center_action_toast.dart';
import '../../cart/controllers/cart_controller.dart';
import '../models/product_model.dart';
import '../repositories/product_repository.dart';
import '../widgets/product_image_widget.dart';
import '../../admin/controllers/mobile_app_settings_controller.dart';
import '../../navigation/widgets/vaidyam_mobile_bottom_nav_bar.dart';
import '../../navigation/widgets/vaidyam_mobile_app_header.dart';
import '../../navigation/widgets/vaidyam_footer_widget.dart';
import '../../../shared/widgets/vaidyam_mobile_ajax_search_bar.dart';

class VaidyamMobileHomeScreenWidget extends ConsumerStatefulWidget {
  final List<Map<String, dynamic>> activeProducts;
  final Function(Map<String, dynamic> deal, {bool isBuyNow}) onAddToCart;

  const VaidyamMobileHomeScreenWidget({
    super.key,
    required this.activeProducts,
    required this.onAddToCart,
  });

  @override
  ConsumerState<VaidyamMobileHomeScreenWidget> createState() => _VaidyamMobileHomeScreenWidgetState();
}

class _VaidyamMobileHomeScreenWidgetState extends ConsumerState<VaidyamMobileHomeScreenWidget> {
  int _selectedCategoryIndex = 0;
  int _activeHeroIndex = 0;
  final TextEditingController _searchController = TextEditingController();

  static const Color _primaryPurple = Color(0xFF4338CA);
  static const Color _lightBg = Color(0xFFF8FAFC);
  static const Color _cardBg = Color(0xFFEEF2FF);
  static const Color _textDark = Color(0xFF0F172A);
  static const Color _textMuted = Color(0xFF64748B);

  final List<Map<String, String>> _categories = [
    {'title': 'All Categories', 'icon': 'grid'},
    {'title': 'Haircare & Oils', 'icon': '💇'},
    {'title': 'Skincare & Serums', 'icon': '✨'},
    {'title': 'Organic Soaps', 'icon': '🧴'},
    {'title': 'Wellness Oils', 'icon': '🌿'},
    {'title': 'Radiance Elixirs', 'icon': '🌸'},
    {'title': 'Gift Combos', 'icon': '🎁'},
  ];

  final List<Map<String, String>> _heroBanners = [
    {
      'tag': 'SUMMER SALE',
      'title': 'Big Savings on\nTop Formulations',
      'subtitle': 'Get up to 60% OFF on hair oils, skincare & wellness.',
      'image': 'assets/images/shampoo.jpg',
    },
    {
      'tag': 'SPECIAL OFFER',
      'title': 'Radiant Skin\nKumkumadi Elixir',
      'subtitle': '100% Organic Saffron & Herbal Serum for Golden Glow.',
      'image': 'assets/images/facewash.jpg',
    },
    {
      'tag': 'NEW ARRIVAL',
      'title': 'Handcrafted\nHerbal Soap Bars',
      'subtitle': 'Nourishing Neem, Aloe Vera & Cold-pressed Oils.',
      'image': 'assets/images/soap.jpg',
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

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartProvider);
    final wishlist = ref.watch(wishlistProvider);
    final mobileSettings = ref.watch(mobileAppSettingsProvider);
    final int cartCount = cartState.totalItemCount;

    return Scaffold(
      backgroundColor: _lightBg,
      bottomNavigationBar: const VaidyamMobileBottomNavBar(activeTab: 'Home'),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 0. Top Announcement Marquee Bar (Managed via Mobile App Panel)
              if (mobileSettings.showAnnouncementBar && mobileSettings.announcementBarText.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  color: const Color(0xFF4338CA),
                  child: Text(
                    mobileSettings.announcementBarText,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),

              // 1. App Header with Hamburger, Admin-managed Logo & Brand Text, Search Bar, Bell & Cart
              const VaidyamMobileAppHeader(),

              const SizedBox(height: 8),

              // 3. Horizontal Category Story Bubbles
              if (mobileSettings.showCategoryGrid) _buildCategoryStoryBubbles(),

              const SizedBox(height: 12),

              // 3.5 Dynamic Live AJAX Search Box (Blue Box Location!)
              const VaidyamMobileAjaxSearchBar(),

              const SizedBox(height: 16),

              // 4. ⭐ 4 Featured Products 2x2 Grid (Right where marked in Red Box!)
              _buildFeaturedProducts2x2Grid(context, wishlist),

              const SizedBox(height: 20),

              // 5. Hero Banner Carousel Slider (Shifted Below 4 Featured Products!)
              _buildHeroBannerSlider(),

              const SizedBox(height: 16),

              // 6. Value Propositions / Trust Badge Strip ("Free Delivery", "7 Days Return", etc.) (Shifted Below Slider!)
              _buildTrustBadgeStrip(),

              const SizedBox(height: 24),

              // 6. Today's Best Deals Header & Cards
              _buildBestDealsSection(wishlist),

              const SizedBox(height: 24),

              // 7. Feature Promo Banners (3 Visual Cards)
              _buildPromoCardsGrid(context),

              const SizedBox(height: 24),

              // 8. Top Brands / Concerns You Love
              _buildTopBrandsSection(),

              const SizedBox(height: 24),

              // 9. Trust Statistics Banner
              _buildTrustStatsBar(),

              const SizedBox(height: 32),

              // 10. App Footer Bar (Matching Screenshot 1-to-1)
              const VaidyamFooterWidget(),
            ],
          ),
        ),
      ),
    );
  }

  // 1. Top Location Header
  Widget _buildTopLocationHeader(BuildContext context, int cartCount) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Delivering Location
          InkWell(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Pincode location set to New Delhi, 110001')),
              );
            },
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: _primaryPurple.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.location_on_rounded, color: _primaryPurple, size: 18),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Delivering to',
                      style: TextStyle(fontSize: 10, color: _textMuted),
                    ),
                    Row(
                      children: const [
                        Text(
                          'New Delhi, 110001',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _textDark),
                        ),
                        SizedBox(width: 2),
                        Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: _textDark),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Action Icons: Bell & Cart
          Row(
            children: [
              // Notification Bell
              Stack(
                clipBehavior: Clip.none,
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_none_rounded, color: _textDark, size: 24),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('No new notifications 🔔')),
                      );
                    },
                  ),
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Color(0xFFEF4444),
                        shape: BoxShape.circle,
                      ),
                      child: const Text(
                        '3',
                        style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),

              // Shopping Cart
              Stack(
                clipBehavior: Clip.none,
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart_outlined, color: _textDark, size: 24),
                    onPressed: () => context.push('/cart'),
                  ),
                  if (cartCount > 0)
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: _primaryPurple,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '$cartCount',
                          style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                        ),
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

  // 2. Main Search Bar Row
  Widget _buildSearchBarRow(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
        children: [
          // Logo Badge
          InkWell(
            onTap: () => context.go('/'),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: _primaryPurple,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: _primaryPurple.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(Icons.local_florist, color: Colors.white, size: 24),
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Search Field
          Expanded(
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: TextField(
                controller: _searchController,
                onSubmitted: (query) {
                  if (query.trim().isNotEmpty) {
                    context.push('/shop?q=${Uri.encodeComponent(query.trim())}');
                  }
                },
                decoration: InputDecoration(
                  hintText: 'Search for products, brands...',
                  hintStyle: const TextStyle(fontSize: 12, color: _textMuted),
                  prefixIcon: const Icon(Icons.search_rounded, color: _textMuted, size: 20),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.camera_alt_outlined, color: _textMuted, size: 20),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Visual Search feature coming soon! 📸')),
                      );
                    },
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Voice Mic Button
          InkWell(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Listening... Say product name 🎙️')),
              );
            },
            child: Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: _primaryPurple,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.mic_rounded, color: Colors.white, size: 22),
            ),
          ),
        ],
      ),
    );
  }

  // 3. Category Story Bubbles
  Widget _buildCategoryStoryBubbles() {
    return SizedBox(
      height: 95,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final cat = _categories[index];
          final bool isSelected = _selectedCategoryIndex == index;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategoryIndex = index;
              });
              if (index == 0) {
                context.push('/shop');
              } else {
                context.push('/shop?cat=${Uri.encodeComponent(cat['title']!)}');
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected ? _primaryPurple.withValues(alpha: 0.1) : Colors.white,
                      border: Border.all(
                        color: isSelected ? _primaryPurple : const Color(0xFFE2E8F0),
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: cat['icon'] == 'grid'
                          ? const Icon(Icons.grid_view_rounded, color: _primaryPurple, size: 26)
                          : Text(
                              cat['icon']!,
                              style: const TextStyle(fontSize: 26),
                            ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    cat['title']!.split(' ').first,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected ? _primaryPurple : _textDark,
                    ),
                  ),
                  if (isSelected)
                    Container(
                      margin: const EdgeInsets.only(top: 2),
                      width: 16,
                      height: 2,
                      decoration: BoxDecoration(
                        color: _primaryPurple,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // 4. Hero Banner Slider
  Widget _buildHeroBannerSlider() {
    final hero = _heroBanners[_activeHeroIndex];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFEEF2FF), Color(0xFFE0E7FF), Color(0xFFF3E8FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  Expanded(
                    flex: 6,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: _primaryPurple.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            hero['tag']!,
                            style: const TextStyle(
                              color: _primaryPurple,
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          hero['title']!,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: _textDark,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          hero['subtitle']!,
                          style: const TextStyle(
                            fontSize: 9.5,
                            color: _textMuted,
                            height: 1.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            ElevatedButton(
                              onPressed: () => context.push('/shop'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _primaryPurple,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                elevation: 2,
                              ),
                              child: const Text('Shop Now', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(width: 8),
                            OutlinedButton(
                              onPressed: () => context.push('/shop'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: _primaryPurple,
                                side: const BorderSide(color: _primaryPurple),
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text('Explore Deals', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Image on right
                  Expanded(
                    flex: 4,
                    child: Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.asset(
                          hero['image']!,
                          height: 120,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(Icons.local_florist, size: 80, color: _primaryPurple),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Pagination Dots
            Positioned(
              bottom: 8,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_heroBanners.length, (index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _activeHeroIndex = index;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: _activeHeroIndex == index ? 16 : 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: _activeHeroIndex == index ? _primaryPurple : _primaryPurple.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 5. Trust Badge Strip
  Widget _buildTrustBadgeStrip() {
    final List<Map<String, String>> badges = [
      {'icon': '🚚', 'title': 'Free Delivery', 'sub': 'Orders over ₹999'},
      {'icon': '🔄', 'title': '7 Days Returns', 'sub': 'Easy refunds'},
      {'icon': '🛡️', 'title': '100% Secure', 'sub': 'Safe payments'},
      {'icon': '👑', 'title': 'Best Quality', 'sub': '100% Original'},
    ];

    return SizedBox(
      height: 52,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: badges.length,
        itemBuilder: (context, index) {
          final item = badges[index];
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                Text(item['icon']!, style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      item['title']!,
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _textDark),
                    ),
                    Text(
                      item['sub']!,
                      style: const TextStyle(fontSize: 9, color: _textMuted),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // 4. ⭐ 4 Featured Products 2x2 Grid Section (Right where marked in Red Box!)
  Widget _buildFeaturedProducts2x2Grid(BuildContext context, Set<String> wishlist) {
    final allProducts = ref.watch(adminProductsProvider);
    final featuredProducts = allProducts.take(4).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
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
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFEF3C7),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.star_rounded, color: Color(0xFFD97706), size: 16),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Featured Products',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: _textDark,
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: () => context.push('/shop'),
                child: Row(
                  children: const [
                    Text(
                      'View All',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _primaryPurple),
                    ),
                    SizedBox(width: 2),
                    Icon(Icons.arrow_forward_rounded, size: 14, color: _primaryPurple),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 2x2 Grid of Product Cards
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: featuredProducts.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 12,
              childAspectRatio: 0.64,
            ),
            itemBuilder: (context, index) {
              final product = featuredProducts[index];
              final variant = product.defaultVariant;
              final bool isWishlisted = wishlist.contains(product.id);
              final String imageUrl = product.imageUrls.isNotEmpty ? product.imageUrls.first : '';
              final double discountPct = variant.mrp > variant.price
                  ? (((variant.mrp - variant.price) / variant.mrp) * 100)
                  : 0;

              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: InkWell(
                  onTap: () => context.push('/product/${product.id}'),
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Product Image
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                            child: SizedBox(
                              height: 125,
                              width: double.infinity,
                              child: ProductImageWidget(
                                imageUrl: imageUrl,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),

                          // Product Info
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Tagline / Category
                                Text(
                                  product.tagline ?? 'AYURVEDA',
                                  style: const TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: _primaryPurple,
                                    letterSpacing: 0.5,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 3),

                                // Product Title
                                Text(
                                  product.name,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: _textDark,
                                    height: 1.2,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 6),

                                // Rating Badge
                                Row(
                                  children: const [
                                    Icon(Icons.star_rounded, color: Color(0xFFF59E0B), size: 13),
                                    SizedBox(width: 3),
                                    Text(
                                      '4.8 (120)',
                                      style: TextStyle(fontSize: 10, color: _textMuted, fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),

                                // Price & Cart Add Button
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '₹${variant.price.toStringAsFixed(0)}',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w900,
                                            color: _primaryPurple,
                                          ),
                                        ),
                                        if (variant.mrp > variant.price)
                                          Text(
                                            '₹${variant.mrp.toStringAsFixed(0)}',
                                            style: const TextStyle(
                                              fontSize: 10,
                                              color: _textMuted,
                                              decoration: TextDecoration.lineThrough,
                                            ),
                                          ),
                                      ],
                                    ),

                                    // Add to Cart Button
                                    InkWell(
                                      onTap: () {
                                        ref.read(cartProvider.notifier).addItem(
                                              product: product,
                                              variant: variant,
                                              quantity: 1,
                                            );
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('✨ ${product.name} added to cart!'),
                                            backgroundColor: const Color(0xFF10B981),
                                            behavior: SnackBarBehavior.floating,
                                            duration: const Duration(seconds: 2),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
                                          ),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Text(
                                          'ADD +',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      // Top-Left Discount Badge
                      if (discountPct > 0)
                        Positioned(
                          top: 8,
                          left: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEF4444),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${discountPct.toStringAsFixed(0)}% OFF',
                              style: const TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),

                      // Top-Right Wishlist Heart Button
                      Positioned(
                        top: 6,
                        right: 6,
                        child: InkWell(
                          onTap: () {
                            ref.read(wishlistProvider.notifier).toggleWishlist(product.id);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(color: Colors.black12, blurRadius: 4),
                              ],
                            ),
                            child: Icon(
                              isWishlisted ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                              color: isWishlisted ? const Color(0xFFEF4444) : _textMuted,
                              size: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // 6. Today's Best Deals Section
  Widget _buildBestDealsSection(Set<String> wishlist) {
    final deals = widget.activeProducts;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Today's Best Deals",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _textDark,
                ),
              ),
              InkWell(
                onTap: () => context.push('/shop'),
                child: Row(
                  children: const [
                    Text(
                      'View All',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _primaryPurple),
                    ),
                    SizedBox(width: 2),
                    Icon(Icons.arrow_forward_rounded, size: 14, color: _primaryPurple),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Horizontal Product List
        SizedBox(
          height: 290,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: deals.length,
            itemBuilder: (context, index) {
              final item = deals[index];
              final String id = item['id'] as String;
              final bool isWishlisted = wishlist.contains(id);

              return Container(
                width: 170,
                margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Product Image
                        InkWell(
                          onTap: () => context.push('/product/$id'),
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                            child: Container(
                              height: 120,
                              width: double.infinity,
                              color: const Color(0xFFF8FAFC),
                              child: ProductImageWidget(
                                imageUrl: item['image'] as String,
                                height: 120,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['name'] as String,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: _textDark,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                item['category'] as String,
                                style: const TextStyle(fontSize: 10, color: _textMuted),
                                maxLines: 1,
                              ),
                              const SizedBox(height: 6),

                              // Price & MRP
                              Row(
                                children: [
                                  Text(
                                    item['price'] as String,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w900,
                                      color: _primaryPurple,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    item['originalPrice'] as String,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: _textMuted,
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),

                              // Rating
                              Row(
                                children: [
                                  const Icon(Icons.star_rounded, color: Color(0xFFF59E0B), size: 14),
                                  const SizedBox(width: 2),
                                  Text(
                                    '${item['rating']}',
                                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: _textDark),
                                  ),
                                  Text(
                                    ' (${item['reviews']})',
                                    style: const TextStyle(fontSize: 9, color: _textMuted),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),

                              // Shop Now Button
                              SizedBox(
                                width: double.infinity,
                                height: 32,
                                child: ElevatedButton(
                                  onPressed: () => widget.onAddToCart(item),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _primaryPurple,
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.zero,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: const Text('Shop Now', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    // Discount Pill (Top Left)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF4444),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          item['discount'] as String,
                          style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),

                    // Wishlist Button (Top Right)
                    Positioned(
                      top: 4,
                      right: 4,
                      child: IconButton(
                        icon: Icon(
                          isWishlisted ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                          color: isWishlisted ? const Color(0xFFEF4444) : _textMuted,
                          size: 18,
                        ),
                        onPressed: () {
                          ref.read(wishlistProvider.notifier).toggleWishlist(id);
                        },
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

  // 7. Promo Cards Grid (3 Visual Banners)
  Widget _buildPromoCardsGrid(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          _buildPromoCard(
            context: context,
            title: 'Ayurvedic Fest',
            subtitle: '50-80% OFF',
            color: const Color(0xFFEDE9FE),
            textColor: const Color(0xFF5B21B6),
            buttonColor: const Color(0xFF7C3AED),
            assetPath: 'assets/images/shampoo.jpg',
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildPromoCard(
                  context: context,
                  title: 'Glow Makeover',
                  subtitle: 'Up to 60% OFF',
                  color: const Color(0xFFFEF3C7),
                  textColor: const Color(0xFF92400E),
                  buttonColor: const Color(0xFFD97706),
                  assetPath: 'assets/images/facewash.jpg',
                  isSmall: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildPromoCard(
                  context: context,
                  title: 'Beauty Essentials',
                  subtitle: 'Up to 40% OFF',
                  color: const Color(0xFFD1FAE5),
                  textColor: const Color(0xFF065F46),
                  buttonColor: const Color(0xFF059669),
                  assetPath: 'assets/images/soap.jpg',
                  isSmall: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPromoCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required Color color,
    required Color textColor,
    required Color buttonColor,
    required String assetPath,
    bool isSmall = false,
  }) {
    return InkWell(
      onTap: () => context.push('/shop'),
      child: Container(
        height: isSmall ? 130 : 110,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: isSmall ? 14 : 16,
                      fontWeight: FontWeight.w900,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: isSmall ? 11 : 12,
                      fontWeight: FontWeight.bold,
                      color: textColor.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        'Shop Now',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: buttonColor),
                      ),
                      const SizedBox(width: 2),
                      Icon(Icons.arrow_forward_rounded, size: 12, color: buttonColor),
                    ],
                  ),
                ],
              ),
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                assetPath,
                width: isSmall ? 50 : 70,
                height: isSmall ? 50 : 70,
                fit: BoxFit.cover,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 8. Top Brands Section
  Widget _buildTopBrandsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Top Brands You Love',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: _textDark,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 48,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: _topBrands.length,
            itemBuilder: (context, index) {
              final brand = _topBrands[index];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Center(
                  child: Text(
                    brand['name']!,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: _textDark,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // 9. Trust Statistics Bar
  Widget _buildTrustStatsBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF3730A3), Color(0xFF4338CA)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem('10M+', 'Happy Customers', Icons.people_alt_rounded),
            _buildStatItem('50K+', 'Products Available', Icons.inventory_2_rounded),
            _buildStatItem('500+', 'Top Brands', Icons.verified_rounded),
            _buildStatItem('99.9%', 'Satisfaction', Icons.sentiment_very_satisfied_rounded),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String val, String label, IconData icon) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white, size: 20),
        const SizedBox(height: 4),
        Text(
          val,
          style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: const TextStyle(color: Color(0xFFC7D2FE), fontSize: 8),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
