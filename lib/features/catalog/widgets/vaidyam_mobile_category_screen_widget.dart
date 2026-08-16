import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../cart/controllers/cart_controller.dart';
import '../../navigation/widgets/vaidyam_mobile_bottom_nav_bar.dart';

class VaidyamMobileCategoryScreenWidget extends ConsumerStatefulWidget {
  final Function(String categoryId)? onSelectCategory;

  const VaidyamMobileCategoryScreenWidget({
    super.key,
    this.onSelectCategory,
  });

  @override
  ConsumerState<VaidyamMobileCategoryScreenWidget> createState() => _VaidyamMobileCategoryScreenWidgetState();
}

class _VaidyamMobileCategoryScreenWidgetState extends ConsumerState<VaidyamMobileCategoryScreenWidget> {
  static const Color _primaryPurple = Color(0xFF4338CA);
  static const Color _lightBg = Color(0xFFF8FAFC);
  static const Color _textDark = Color(0xFF0F172A);
  static const Color _textMuted = Color(0xFF64748B);

  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> _categoriesList = [
    {
      'id': 'haircare',
      'title': 'Haircare & Herbal Oils',
      'itemsCount': '125 items',
      'icon': Icons.content_cut_rounded,
      'color': const Color(0xFFEEF2FF),
      'iconColor': const Color(0xFF4338CA),
    },
    {
      'id': 'skincare',
      'title': 'Skincare & Kumkumadi Serums',
      'itemsCount': '230 items',
      'icon': Icons.face_rounded,
      'color': const Color(0xFFE0F2FE),
      'iconColor': const Color(0xFF0284C7),
    },
    {
      'id': 'soaps',
      'title': 'Cold-Pressed Organic Soaps',
      'itemsCount': '320 items',
      'icon': Icons.sanitizer_rounded,
      'color': const Color(0xFFFEE2E2),
      'iconColor': const Color(0xFFE11D48),
    },
    {
      'id': 'wellness',
      'title': 'Wellness & Immunity Oils',
      'itemsCount': '180 items',
      'icon': Icons.spa_rounded,
      'color': const Color(0xFFEFF6FF),
      'iconColor': const Color(0xFF2563EB),
    },
    {
      'id': 'elixirs',
      'title': 'Radiance & Glow Elixirs',
      'itemsCount': '200 items',
      'icon': Icons.local_florist_rounded,
      'color': const Color(0xFFFCE7F3),
      'iconColor': const Color(0xFFDB2777),
    },
    {
      'id': 'combos',
      'title': 'Ayurvedic Gift Combos & Sets',
      'itemsCount': '150 items',
      'icon': Icons.card_giftcard_rounded,
      'color': const Color(0xFFF3E8FF),
      'iconColor': const Color(0xFF9333EA),
    },
    {
      'id': 'bodycare',
      'title': 'Body Care & Ubtans',
      'itemsCount': '210 items',
      'icon': Icons.clean_hands_rounded,
      'color': const Color(0xFFFDE8E8),
      'iconColor': const Color(0xFFD97706),
    },
    {
      'id': 'herbs',
      'title': 'Pure Herbs & Churnas',
      'itemsCount': '190 items',
      'icon': Icons.eco_rounded,
      'color': const Color(0xFFDCFCE7),
      'iconColor': const Color(0xFF16A34A),
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartProvider);
    final int cartCount = cartState.totalItemCount;

    return Scaffold(
      backgroundColor: _lightBg,
      bottomNavigationBar: const VaidyamMobileBottomNavBar(activeTab: 'Categories'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header Bar: Back Arrow + Category + Cart (2)
              _buildHeaderBar(context, cartCount),

              const SizedBox(height: 16),

              // 2. Category Search Field Bar
              _buildSearchFieldBar(),

              const SizedBox(height: 16),

              // 3. Promo Carousel Banner Card (Purple Gradient)
              _buildPromoBannerCard(context),

              const SizedBox(height: 20),

              // 4. Category List Cards Container
              _buildCategoryListCard(context),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // 1. Header Bar
  Widget _buildHeaderBar(BuildContext context, int cartCount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: _textDark, size: 20),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/');
            }
          },
        ),
        const Text(
          'Category',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: _textDark,
          ),
        ),
        Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              icon: const Icon(Icons.shopping_cart_outlined, color: _textDark, size: 24),
              onPressed: () => context.push('/cart'),
            ),
            if (cartCount > 0)
              Positioned(
                top: -2,
                right: -2,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: _primaryPurple,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                  child: Center(
                    child: Text(
                      '$cartCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  // 2. Category Search Field Bar
  Widget _buildSearchFieldBar() {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.search_rounded, color: _textMuted, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search in category...',
                hintStyle: TextStyle(fontSize: 13, color: _textMuted),
                border: InputBorder.none,
                isDense: true,
              ),
              onChanged: (val) {
                setState(() {});
              },
            ),
          ),
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear_rounded, size: 16, color: _textMuted),
              onPressed: () {
                setState(() {
                  _searchController.clear();
                });
              },
            ),
        ],
      ),
    );
  }

  // 3. Promo Carousel Banner Card
  Widget _buildPromoBannerCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3730A3), Color(0xFF4338CA), Color(0xFF6366F1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4338CA).withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Great Deals on',
                      style: TextStyle(color: Color(0xFFE0E7FF), fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Ayurveda & Skincare',
                      style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: const [
                        Text('Up to ', style: TextStyle(color: Colors.white, fontSize: 13)),
                        Text(
                          '60% Off',
                          style: TextStyle(color: Color(0xFFFBBF24), fontSize: 16, fontWeight: FontWeight.w900),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    ElevatedButton(
                      onPressed: () => context.push('/shop'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: _primaryPurple,
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        elevation: 0,
                      ),
                      child: const Text('Shop Now', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),

              // Decorative Icon Banner Right
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(Icons.spa_rounded, color: Colors.white, size: 50),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Dots indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
              const SizedBox(width: 6),
              Container(width: 8, height: 8, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.4), shape: BoxShape.circle)),
            ],
          ),
        ],
      ),
    );
  }

  // 4. Category List Cards Container
  Widget _buildCategoryListCard(BuildContext context) {
    final search = _searchController.text.trim().toLowerCase();
    final filteredCategories = _categoriesList.where((cat) {
      if (search.isEmpty) return true;
      return (cat['title'] as String).toLowerCase().contains(search);
    }).toList();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: filteredCategories.asMap().entries.map((entry) {
          final idx = entry.key;
          final cat = entry.value;

          return Column(
            children: [
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                leading: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: cat['color'] as Color,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Icon(cat['icon'] as IconData, color: cat['iconColor'] as Color, size: 24),
                  ),
                ),
                title: Text(
                  cat['title'] as String,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: _textDark),
                ),
                subtitle: Text(
                  cat['itemsCount'] as String,
                  style: const TextStyle(fontSize: 11, color: _textMuted),
                ),
                trailing: const Icon(Icons.chevron_right_rounded, color: _textMuted, size: 22),
                onTap: () {
                  if (widget.onSelectCategory != null) {
                    widget.onSelectCategory!(cat['id'] as String);
                  } else {
                    context.push('/shop');
                  }
                },
              ),
              if (idx < filteredCategories.length - 1)
                const Divider(height: 1, indent: 76, endIndent: 16, color: Color(0xFFF1F5F9)),
            ],
          );
        }).toList(),
      ),
    );
  }
}
