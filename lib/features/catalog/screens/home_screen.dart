import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../config/theme/app_colors.dart';
import '../../cart/controllers/cart_controller.dart';
import '../models/product_model.dart';
import '../repositories/product_repository.dart';
import '../widgets/product_image_widget.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  int _activeHeroIndex = 0;

  final List<Map<String, String>> _heroBanners = [
    {
      'tag': '100% AYURVEDIC DERMATOLOGY',
      'title': 'Pure Botanical Care.\nZero Harsh Toxins.',
      'desc': 'Clinically active formulas infused with Neem, Kashmiri Saffron & Green Tea.',
      'cta': 'Shop Best Sellers',
    },
    {
      'tag': 'SUBSCRIBE & SAVE 10%',
      'title': 'Never Run Out of\nYour Daily Ritual.',
      'desc': 'Automatic scheduled refills, 10% off on every order, cancel or pause anytime.',
      'cta': 'Join Subscribe Club',
    },
    {
      'tag': 'CLEAN PROMISE',
      'title': 'Free From 12 Toxins.\nGuaranteed.',
      'desc': 'No sulfates, no parabens, no silicones, 100% vegetarian & cruelty free.',
      'cta': 'Learn More',
    },
  ];

  final List<Map<String, dynamic>> _storyHighlights = [
    {'title': 'Anti-Dandruff', 'icon': Icons.spa, 'color': AppColors.forestSage},
    {'title': 'De-Tan Glow', 'icon': Icons.wb_sunny_outlined, 'color': AppColors.goldAccent},
    {'title': 'Acne Defense', 'icon': Icons.water_drop_outlined, 'color': Color(0xFF2E7D32)},
    {'title': 'Sub Refills', 'icon': Icons.autorenew, 'color': Color(0xFF0288D1)},
    {'title': 'Clean Promise', 'icon': Icons.verified_outlined, 'color': Color(0xFF8E24AA)},
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesFutureProvider);
    final productsAsync = ref.watch(filteredProductsProvider);
    final selectedCat = ref.watch(selectedCategoryProvider);
    final cartState = ref.watch(cartProvider);
    final wishlist = ref.watch(wishlistProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isDark ? AppColors.charcoalCard : AppColors.sageLight,
                shape: BoxShape.circle,
                border: Border.all(color: isDark ? AppColors.goldAccent : AppColors.forestSage, width: 1.2),
              ),
              child: Icon(Icons.spa, size: 18, color: isDark ? AppColors.goldAccent : AppColors.forestSage),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'COSMYRA',
                  style: TextStyle(
                    fontFamily: 'serif',
                    letterSpacing: 3,
                    fontWeight: FontWeight.w900,
                    fontSize: 17,
                    color: isDark ? AppColors.goldAccent : AppColors.forestSage,
                  ),
                ),
                Text(
                  'VAIDYAM BOTANICALS',
                  style: TextStyle(
                    fontSize: 9,
                    letterSpacing: 1.8,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.textLightSecondary : AppColors.textDarkSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.admin_panel_settings_outlined),
            tooltip: 'Admin Web Dashboard',
            onPressed: () => context.push('/admin'),
          ),
          IconButton(
            icon: const Icon(Icons.favorite_border),
            tooltip: 'Wishlist',
            onPressed: () => context.push('/wishlist'),
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_bag_outlined),
                onPressed: () => context.push('/cart'),
              ),
              if (cartState.totalItemCount > 0)
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.goldAccent,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                    child: Text(
                      '${cartState.totalItemCount}',
                      style: const TextStyle(
                        color: AppColors.forestSageDark,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(productsFutureProvider);
          ref.invalidate(categoriesFutureProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.charcoalCard : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isDark ? AppColors.charcoalBorder : AppColors.creamBorder,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) => ref.read(searchQueryProvider.notifier).state = val,
                    decoration: InputDecoration(
                      hintText: 'Search shampoo, soap, face wash...',
                      hintStyle: TextStyle(
                        fontSize: 13,
                        color: isDark ? AppColors.textLightSecondary : AppColors.textDarkSecondary,
                      ),
                      prefixIcon: const Icon(Icons.search, size: 20, color: AppColors.forestSage),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                ref.read(searchQueryProvider.notifier).state = '';
                              },
                            )
                          : const Icon(Icons.tune, size: 18, color: AppColors.goldAccent),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ),

              // 2. Story Highlight Avatars
              SizedBox(
                height: 95,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  itemCount: _storyHighlights.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 14),
                  itemBuilder: (context, index) {
                    final story = _storyHighlights[index];
                    return InkWell(
                      onTap: () {
                        if (index == 0) {
                          ref.read(selectedCategoryProvider.notifier).state = 'cat-haircare';
                        } else if (index == 1 || index == 2) {
                          ref.read(selectedCategoryProvider.notifier).state = 'cat-skincare';
                        } else if (index == 3) {
                          context.push('/subscriptions');
                        }
                      },
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(2.5),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: AppColors.goldShimmerGradient,
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isDark ? AppColors.charcoalCard : AppColors.creamCard,
                              ),
                              child: Icon(story['icon'] as IconData, size: 22, color: story['color'] as Color),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            story['title'] as String,
                            style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // 3. Hero Carousel Banner
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: AppColors.luxurySageGradient,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.forestSageDark.withValues(alpha: 0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.goldAccent.withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.goldAccent, width: 0.8),
                          ),
                          child: Text(
                            _heroBanners[_activeHeroIndex]['tag']!,
                            style: const TextStyle(
                              color: AppColors.goldAccentLight,
                              fontSize: 9.5,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.4,
                            ),
                          ),
                        ),
                        Row(
                          children: List.generate(_heroBanners.length, (idx) {
                            return GestureDetector(
                              onTap: () => setState(() => _activeHeroIndex = idx),
                              child: Container(
                                margin: const EdgeInsets.only(left: 4),
                                width: _activeHeroIndex == idx ? 16 : 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: _activeHeroIndex == idx ? AppColors.goldAccent : Colors.white38,
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _heroBanners[_activeHeroIndex]['title']!,
                      style: const TextStyle(
                        fontFamily: 'serif',
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _heroBanners[_activeHeroIndex]['desc']!,
                      style: const TextStyle(
                        color: Color(0xFFD3E0D8),
                        fontSize: 12.5,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.goldAccent,
                            foregroundColor: AppColors.forestSageDark,
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                            textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                          onPressed: () {
                            if (_activeHeroIndex == 1) {
                              context.push('/subscriptions');
                            }
                          },
                          child: Text(_heroBanners[_activeHeroIndex]['cta']!),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white60),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            textStyle: const TextStyle(fontSize: 12),
                          ),
                          onPressed: () => context.push('/explore'),
                          child: const Text('View Catalog'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // 4. Category Filter Chips
              categoriesAsync.when(
                data: (categories) => SizedBox(
                  height: 42,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: const Text('All Products'),
                          selected: selectedCat == null,
                          onSelected: (_) => ref.read(selectedCategoryProvider.notifier).state = null,
                          selectedColor: isDark ? AppColors.goldAccent : AppColors.forestSage,
                          labelStyle: TextStyle(
                            color: selectedCat == null
                                ? (isDark ? AppColors.forestSageDark : Colors.white)
                                : (isDark ? AppColors.textLightPrimary : AppColors.textDarkPrimary),
                            fontWeight: selectedCat == null ? FontWeight.bold : FontWeight.normal,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      ...categories.map((cat) {
                        final isSelected = selectedCat == cat.id;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(cat.name),
                            selected: isSelected,
                            onSelected: (_) => ref.read(selectedCategoryProvider.notifier).state = cat.id,
                            selectedColor: isDark ? AppColors.goldAccent : AppColors.forestSage,
                            labelStyle: TextStyle(
                              color: isSelected
                                  ? (isDark ? AppColors.forestSageDark : Colors.white)
                                  : (isDark ? AppColors.textLightPrimary : AppColors.textDarkPrimary),
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              fontSize: 12,
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),

              const SizedBox(height: 16),

              // 5. Section Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Vaidyam Ayurvedic Formulations',
                      style: TextStyle(
                        fontFamily: 'serif',
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.push('/explore'),
                      child: const Text('View All', style: TextStyle(fontSize: 12, color: AppColors.goldAccent)),
                    ),
                  ],
                ),
              ),

              // 6. Products Grid
              productsAsync.when(
                data: (products) {
                  if (products.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(40),
                      alignment: Alignment.center,
                      child: const Text('No products matched your search.'),
                    );
                  }

                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.55,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      final isWishlisted = wishlist.contains(product.id);
                      return _ProductGridCard(
                        product: product,
                        isWishlisted: isWishlisted,
                        onWishlistToggle: () => ref.read(wishlistProvider.notifier).toggleWishlist(product.id),
                      );
                    },
                  );
                },
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(color: AppColors.forestSage),
                  ),
                ),
                error: (err, _) => Center(child: Text('Error: $err')),
              ),

              const SizedBox(height: 24),

              // 7. The Vaidyam Clean Promise Banner
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.charcoalCard : AppColors.creamCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? AppColors.charcoalBorder : AppColors.creamBorder,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.verified, color: AppColors.goldAccent, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'The Vaidyam Clean Promise',
                          style: TextStyle(
                            fontFamily: 'serif',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.goldAccent : AppColors.forestSageDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Formulated specifically for Indian hair and skin conditions. Every batch adheres to the highest dermatological purity standards.',
                      style: TextStyle(fontSize: 12, height: 1.4),
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildPromiseTag('🌿 100% Ayurvedic Extracts'),
                        _buildPromiseTag('🚫 Zero Sulfates & Parabens'),
                        _buildPromiseTag('🐰 Cruelty Free & Vegan'),
                        _buildPromiseTag('🔬 Dermatologist Approved'),
                        _buildPromiseTag('🧼 Grade 1 TFM 76% Soap'),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 8. Subscribe & Save Explainer Card
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [const Color(0xFF1E2F26), AppColors.charcoalCard]
                        : [const Color(0xFFE8F2EC), AppColors.creamCard],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.forestSage.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: AppColors.forestSage,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.autorenew, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Subscribe & Save 10% Extra',
                            style: TextStyle(fontFamily: 'serif', fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Choose 15, 30, 45, or 60 day auto-delivery on any consumable SKU. Cancel or edit anytime.',
                            style: TextStyle(fontSize: 11, height: 1.3),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 9. Verified Customer Reviews Carousel
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Customer Experiences',
                      style: TextStyle(fontFamily: 'serif', fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildReviewCard(
                            'Rohit M., Bangalore',
                            'Vaidyam Anti-Dandruff Shampoo',
                            '5.0',
                            'Dandruff disappeared in 2 weeks without stripping my scalp dry! The wooden cap aesthetic looks ultra premium in my bathroom.',
                            isDark,
                          ),
                          const SizedBox(width: 12),
                          _buildReviewCard(
                            'Ananya S., Mumbai',
                            'De-Tan Botanical Soap',
                            '5.0',
                            'The Kashmiri saffron and turmeric smell pure and authentic. Visible reduction in sun tan after 10 days.',
                            isDark,
                          ),
                          const SizedBox(width: 12),
                          _buildReviewCard(
                            'Karan D., Delhi',
                            'Deep Clean Face Wash',
                            '4.9',
                            'Salicylic acid + Green tea works wonders on oily T-zone and keeps active breakouts in check.',
                            isDark,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 10. Trust & Guarantees Bar
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.charcoalCard : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? AppColors.charcoalBorder : AppColors.creamBorder,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildTrustItem(Icons.local_shipping_outlined, 'Free Delivery\nAbove ₹499'),
                    _buildTrustItem(Icons.payments_outlined, 'Cash on\nDelivery'),
                    _buildTrustItem(Icons.verified_outlined, '100% Authentic\nDirect to You'),
                    _buildTrustItem(Icons.security, 'Razorpay\nSecured'),
                  ],
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPromiseTag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.forestSage.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.forestSage),
      ),
    );
  }

  Widget _buildReviewCard(String author, String product, String rating, String quote, bool isDark) {
    return Container(
      width: 260,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.charcoalCard : AppColors.creamCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppColors.charcoalBorder : AppColors.creamBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ...List.generate(5, (_) => const Icon(Icons.star, size: 14, color: AppColors.goldAccent)),
              const SizedBox(width: 6),
              Text(rating, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '"$quote"',
            style: const TextStyle(fontSize: 11.5, height: 1.4, fontStyle: FontStyle.italic),
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 10),
          Text(
            author,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
          ),
          Text(
            product,
            style: TextStyle(fontSize: 9.5, color: isDark ? AppColors.textLightSecondary : AppColors.textDarkSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildTrustItem(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, size: 20, color: AppColors.forestSage),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w600, height: 1.2),
        ),
      ],
    );
  }
}

class _ProductGridCard extends ConsumerWidget {
  final ProductModel product;
  final bool isWishlisted;
  final VoidCallback onWishlistToggle;

  const _ProductGridCard({
    required this.product,
    required this.isWishlisted,
    required this.onWishlistToggle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final variant = product.defaultVariant;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => context.push('/product/${product.id}', extra: product),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with tag & wishlist heart
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ProductImageWidget(
                    imageUrl: product.imageUrls.isNotEmpty ? product.imageUrls.first : '',
                  ),
                  if (variant.discountPercent > 0)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3.5),
                        decoration: BoxDecoration(
                          color: AppColors.goldAccent,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${variant.discountPercent.toInt()}% OFF',
                          style: const TextStyle(
                            color: AppColors.forestSageDark,
                            fontSize: 9.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: IconButton(
                      icon: Icon(
                        isWishlisted ? Icons.favorite : Icons.favorite_border,
                        color: isWishlisted ? Colors.red : Colors.white,
                        size: 20,
                      ),
                      onPressed: onWishlistToggle,
                    ),
                  ),
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.65),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.star, color: AppColors.goldAccent, size: 11),
                          const SizedBox(width: 3),
                          const Text(
                            '4.9',
                            style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.65),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        variant.sizeLabel,
                        style: const TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Product Details
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'VAIDYAM BOTANICALS',
                    style: TextStyle(
                      fontSize: 8.5,
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.w800,
                      color: isDark ? AppColors.goldAccent : AppColors.sageMuted,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'serif',
                      fontWeight: FontWeight.bold,
                      fontSize: 12.5,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        '₹${variant.price.toInt()}',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(width: 6),
                      if (variant.mrp > variant.price)
                        Text(
                          '₹${variant.mrp.toInt()}',
                          style: TextStyle(
                            fontSize: 11,
                            decoration: TextDecoration.lineThrough,
                            color: isDark ? AppColors.textLightSecondary : AppColors.textDarkSecondary,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () {
                        ref.read(cartProvider.notifier).addItem(
                              product: product,
                              variant: variant,
                            );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Added ${product.name} to Bag'),
                            duration: const Duration(seconds: 1),
                            action: SnackBarAction(
                              label: 'VIEW BAG',
                              textColor: AppColors.goldAccent,
                              onPressed: () => context.push('/cart'),
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.add_shopping_cart, size: 14),
                      label: const Text('Add to Bag', style: TextStyle(fontSize: 11)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
