import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../config/theme/app_colors.dart';
import '../../../shared/widgets/center_action_toast.dart';
import '../../cart/controllers/cart_controller.dart';
import '../../navigation/widgets/vaidyam_header_widget.dart';
import '../models/product_model.dart';
import '../repositories/product_repository.dart';
import '../widgets/product_image_widget.dart';

class VaidyamShopScreen extends ConsumerStatefulWidget {
  const VaidyamShopScreen({super.key});

  @override
  ConsumerState<VaidyamShopScreen> createState() => _VaidyamShopScreenState();
}

class _VaidyamShopScreenState extends ConsumerState<VaidyamShopScreen> {
  String _selectedSearchCategory = 'All Categories';
  final TextEditingController _searchController = TextEditingController();

  // Filters State
  String? _selectedCategory;
  RangeValues _priceRange = const RangeValues(0, 5000);
  double? _minRatingFilter;
  final Set<String> _selectedConcerns = {};
  String _sortBy = 'Popularity';
  bool _isGridView = true;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartProvider);
    final wishlist = ref.watch(wishlistProvider);
    final allProducts = ref.watch(adminProductsProvider);
    final totalCartCount = cartState.totalItemCount;

    // Apply all filters dynamically
    final filteredProducts = allProducts.where((p) {
      // Category filter
      if (_selectedCategory != null && _selectedCategory != 'all') {
        if (p.categoryId != _selectedCategory) return false;
      }
      // Price range filter
      final v = p.defaultVariant;
      if (v.price < _priceRange.start || v.price > _priceRange.end) {
        return false;
      }
      // Search query filter
      final query = _searchController.text.trim().toLowerCase();
      if (query.isNotEmpty) {
        final matchName = p.name.toLowerCase().contains(query);
        final matchDesc = p.description.toLowerCase().contains(query);
        final matchIng = p.ingredients.toLowerCase().contains(query);
        if (!matchName && !matchDesc && !matchIng) return false;
      }
      // Concerns filter
      if (_selectedConcerns.isNotEmpty) {
        bool matchConcern = false;
        for (final concern in _selectedConcerns) {
          if (p.description.toLowerCase().contains(concern.toLowerCase()) ||
              (p.tagline ?? '').toLowerCase().contains(concern.toLowerCase()) ||
              p.name.toLowerCase().contains(concern.toLowerCase())) {
            matchConcern = true;
            break;
          }
        }
        if (!matchConcern) return false;
      }
      return true;
    }).toList();

    // Sorting
    if (_sortBy == 'Price: Low to High') {
      filteredProducts.sort((a, b) => a.defaultVariant.price.compareTo(b.defaultVariant.price));
    } else if (_sortBy == 'Price: High to Low') {
      filteredProducts.sort((a, b) => b.defaultVariant.price.compareTo(a.defaultVariant.price));
    } else if (_sortBy == 'Newest') {
      filteredProducts.sort((a, b) => b.id.compareTo(a.id));
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth > 900;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SingleChildScrollView(
        child: Column(
        children: [
          const VaidyamHeaderWidget(activeTab: 'Shop', showValuePropositions: true),

          const SizedBox(height: 16),

          // 4. Main Body: Left Filter Sidebar + Right Products Catalog
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left Filter Sidebar (260px)
                SizedBox(
                  width: 260,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFF3F4F6)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Categories Filter
                        const Text('Shop by Category', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF111827))),
                        const SizedBox(height: 12),
                        _buildCategoryItem('All Categories', null, allProducts.length),
                        _buildCategoryItem('Haircare', 'cat-haircare', allProducts.where((p) => p.categoryId == 'cat-haircare').length),
                        _buildCategoryItem('Skincare', 'cat-skincare', allProducts.where((p) => p.categoryId == 'cat-skincare').length),
                        _buildCategoryItem('Wellness Oils', 'cat-wellness', allProducts.where((p) => p.categoryId == 'cat-wellness').length),
                        _buildCategoryItem('Soaps & Bars', 'cat-skincare', allProducts.where((p) => p.name.contains('Soap')).length),
                        _buildCategoryItem('Elixirs', 'cat-skincare', 4),

                        const Divider(height: 32),

                        // Price Range Slider
                        const Text('Filter By Price Range', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF111827))),
                        const SizedBox(height: 12),
                        RangeSlider(
                          values: _priceRange,
                          min: 0,
                          max: 5000,
                          divisions: 50,
                          activeColor: const Color(0xFF6366F1),
                          inactiveColor: const Color(0xFFE5E7EB),
                          labels: RangeLabels('₹${_priceRange.start.toInt()}', '₹${_priceRange.end.toInt()}'),
                          onChanged: (values) => setState(() => _priceRange = values),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('₹${_priceRange.start.toInt()}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF4B5563))),
                            Text('₹${_priceRange.end.toInt()}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF4B5563))),
                          ],
                        ),

                        const Divider(height: 32),

                        // Rating Filter
                        const Text('Rating', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF111827))),
                        const SizedBox(height: 10),
                        _buildRatingRadio(5.0, '5 Stars (120)'),
                        _buildRatingRadio(4.0, '4 Stars & above (85)'),
                        _buildRatingRadio(3.0, '3 Stars & above (43)'),

                        const Divider(height: 32),

                        // Ayurvedic Concerns Filter
                        const Text('Ayurvedic Concerns', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF111827))),
                        const SizedBox(height: 10),
                        _buildConcernCheckbox('Anti-Dandruff'),
                        _buildConcernCheckbox('De-Tan & Glow'),
                        _buildConcernCheckbox('Acne Defense'),
                        _buildConcernCheckbox('Hair Growth'),
                        _buildConcernCheckbox('Oil Control'),

                        const SizedBox(height: 16),
                        Center(
                          child: TextButton.icon(
                            onPressed: () {
                              setState(() {
                                _selectedCategory = null;
                                _priceRange = const RangeValues(0, 5000);
                                _minRatingFilter = null;
                                _selectedConcerns.clear();
                                _searchController.clear();
                              });
                            },
                            icon: const Icon(Icons.refresh, size: 16, color: Color(0xFF6366F1)),
                            label: const Text('Reset All Filters', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF6366F1))),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: 24),

                // Right Section: Top Promo Banner + Sorting Bar + Product Grid
                Expanded(
                  child: Column(
                    children: [
                      // Top Featured Promo Banner
                      Container(
                        width: double.infinity,
                        height: 160,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFF3E8FF), Color(0xFFFAF5FF), Color(0xFFF8FAFC)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text('UP TO 40% OFF', style: TextStyle(color: Color(0xFF6366F1), fontWeight: FontWeight.bold, fontSize: 12)),
                                  const SizedBox(height: 6),
                                  const Text('Summer Botanical Collection', style: TextStyle(fontFamily: 'serif', fontSize: 26, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
                                  const SizedBox(height: 12),
                                  ElevatedButton(
                                    onPressed: () {},
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF6366F1),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                    ),
                                    child: const Text('Shop Now', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ),
                            ),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.asset('assets/images/shampoo.jpg', width: 140, height: 110, fit: BoxFit.cover),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Control & Sorting Bar
                      Row(
                        children: [
                          Text(
                            'Showing 1–${filteredProducts.length} of ${allProducts.length} results',
                            style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280), fontWeight: FontWeight.w500),
                          ),
                          const Spacer(),

                          // Sort By Dropdown
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFFE5E7EB)),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _sortBy,
                                style: const TextStyle(fontSize: 13, color: Color(0xFF374151), fontWeight: FontWeight.w500),
                                items: ['Popularity', 'Price: Low to High', 'Price: High to Low', 'Newest']
                                    .map((s) => DropdownMenuItem(value: s, child: Text('Sort by: $s')))
                                    .toList(),
                                onChanged: (val) => setState(() => _sortBy = val ?? 'Popularity'),
                              ),
                            ),
                          ),

                          const SizedBox(width: 12),

                          // View Switcher (Grid vs List)
                          IconButton(
                            icon: Icon(Icons.grid_view, color: _isGridView ? const Color(0xFF6366F1) : const Color(0xFF9CA3AF)),
                            onPressed: () => setState(() => _isGridView = true),
                          ),
                          IconButton(
                            icon: Icon(Icons.view_list, color: !_isGridView ? const Color(0xFF6366F1) : const Color(0xFF9CA3AF)),
                            onPressed: () => setState(() => _isGridView = false),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Products Grid / List View
                      filteredProducts.isEmpty
                          ? Container(
                              padding: const EdgeInsets.all(60),
                              child: const Center(
                                child: Text('No botanical products match your selected filter criteria.'),
                              ),
                            )
                          : _isGridView
                              ? GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                                    maxCrossAxisExtent: 260,
                                    mainAxisExtent: 330,
                                    crossAxisSpacing: 16,
                                    mainAxisSpacing: 16,
                                  ),
                                  itemCount: filteredProducts.length,
                                  itemBuilder: (context, index) {
                                    final p = filteredProducts[index];
                                    return _buildProductCard(context, p);
                                  },
                                )
                              : ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: filteredProducts.length,
                                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                                  itemBuilder: (context, index) {
                                    final p = filteredProducts[index];
                                    return _buildProductListTile(context, p);
                                  },
                                ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    ),
    );
  }

  Widget _buildCategoryItem(String title, String? catId, int count) {
    final isSelected = _selectedCategory == catId;
    return InkWell(
      onTap: () => setState(() => _selectedCategory = catId),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? const Color(0xFF6366F1) : const Color(0xFF4B5563),
              ),
            ),
            const Spacer(),
            Text(
              '($count)',
              style: TextStyle(fontSize: 12, color: isSelected ? const Color(0xFF6366F1) : const Color(0xFF9CA3AF)),
            ),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right, size: 16, color: isSelected ? const Color(0xFF6366F1) : const Color(0xFF9CA3AF)),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingRadio(double rating, String label) {
    final isSelected = _minRatingFilter == rating;
    return InkWell(
      onTap: () => setState(() => _minRatingFilter = isSelected ? null : rating),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              size: 16,
              color: isSelected ? const Color(0xFF6366F1) : const Color(0xFF9CA3AF),
            ),
            const SizedBox(width: 8),
            Row(
              children: const [
                Icon(Icons.star, size: 14, color: Colors.amber),
                Icon(Icons.star, size: 14, color: Colors.amber),
                Icon(Icons.star, size: 14, color: Colors.amber),
                Icon(Icons.star, size: 14, color: Colors.amber),
                Icon(Icons.star, size: 14, color: Colors.amber),
              ],
            ),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF4B5563))),
          ],
        ),
      ),
    );
  }

  Widget _buildConcernCheckbox(String concern) {
    final isChecked = _selectedConcerns.contains(concern);
    return InkWell(
      onTap: () {
        setState(() {
          if (isChecked) {
            _selectedConcerns.remove(concern);
          } else {
            _selectedConcerns.add(concern);
          }
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Icon(
              isChecked ? Icons.check_box : Icons.check_box_outline_blank,
              size: 18,
              color: isChecked ? const Color(0xFF6366F1) : const Color(0xFF9CA3AF),
            ),
            const SizedBox(width: 8),
            Text(concern, style: const TextStyle(fontSize: 13, color: Color(0xFF374151))),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, ProductModel p) {
    return _ShopGridCardStateful(product: p);
  }

  Widget _buildProductListTile(BuildContext context, ProductModel p) {
    final v = p.defaultVariant;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: (p.imageUrls.isNotEmpty && p.imageUrls.first.startsWith('http'))
                      ? NetworkImage(p.imageUrls.first) as ImageProvider
                      : AssetImage(p.imageUrls.isNotEmpty ? p.imageUrls.first : 'assets/images/shampoo.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 4),
                  Text(p.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                  const SizedBox(height: 6),
                  Text('Price: ₹${v.price.toInt()} (MRP ₹${v.mrp.toInt()})', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                ref.read(cartProvider.notifier).addItem(product: p, variant: v);
                showCenterActionToast(
                  context,
                  title: 'Added to Shopping Bag! 🛍️',
                  message: p.name,
                  icon: Icons.shopping_bag_outlined,
                  iconColor: const Color(0xFF4F46E5),
                  primaryActionLabel: 'VIEW CART',
                  onPrimaryAction: () => context.push('/cart'),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6366F1), foregroundColor: Colors.white),
              icon: const Icon(Icons.add_shopping_cart, size: 16),
              label: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShopGridCardStateful extends ConsumerStatefulWidget {
  final ProductModel product;

  const _ShopGridCardStateful({required this.product});

  @override
  ConsumerState<_ShopGridCardStateful> createState() => _ShopGridCardStatefulState();
}

class _ShopGridCardStatefulState extends ConsumerState<_ShopGridCardStateful> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    final v = p.defaultVariant;
    final discountPct = v.mrp > v.price ? (((v.mrp - v.price) / v.mrp) * 100).round() : 0;
    final String imageUrl = p.imageUrls.isNotEmpty ? p.imageUrls.first : 'assets/images/shampoo.jpg';

    void openDetails() {
      context.push('/product/${p.id}', extra: p);
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _isHovered ? const Color(0xFF6366F1) : const Color(0xFFE5E7EB),
            width: _isHovered ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: _isHovered ? const Color(0xFF6366F1).withValues(alpha: 0.12) : Colors.black.withValues(alpha: 0.03),
              blurRadius: _isHovered ? 12 : 6,
              offset: Offset(0, _isHovered ? 5 : 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Image Stack with Contain Fit & 1.08x Scale & Click Navigation
            Expanded(
              child: GestureDetector(
                onTap: openDetails,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: AnimatedScale(
                          scale: _isHovered ? 1.08 : 1.0,
                          duration: const Duration(milliseconds: 220),
                          curve: Curves.easeOutCubic,
                          child: ProductImageWidget(
                            imageUrl: imageUrl,
                            fit: BoxFit.contain, // FULL IMAGE VISIBLE WITHOUT CROPPING
                            width: double.infinity,
                          ),
                        ),
                      ),
                    ),

                    // Floating Quick Overview Badge Overlay on Hover
                    if (_isHovered)
                      Positioned(
                        bottom: 6,
                        left: 6,
                        right: 6,
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 180),
                          opacity: _isHovered ? 1.0 : 0.0,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E1B4B).withValues(alpha: 0.92),
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: const [
                                BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.remove_red_eye_outlined, size: 11, color: Colors.white),
                                SizedBox(width: 4),
                                Text(
                                  'Quick Overview • Pure Botanical',
                                  style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                    // Discount Badge (Top-Left)
                    if (discountPct > 0)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEF4444),
                            borderRadius: BorderRadius.circular(6),
                            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
                          ),
                          child: Text(
                            '-$discountPct%',
                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Product Title - Clickable to open details!
            InkWell(
              onTap: openDetails,
              child: Text(
                p.name,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: _isHovered ? const Color(0xFF4F46E5) : const Color(0xFF111827),
                  decoration: _isHovered ? TextDecoration.underline : TextDecoration.none,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 4),

            // Rating Stars
            Row(
              children: const [
                Icon(Icons.star, size: 13, color: Colors.amber),
                Icon(Icons.star, size: 13, color: Colors.amber),
                Icon(Icons.star, size: 13, color: Colors.amber),
                Icon(Icons.star, size: 13, color: Colors.amber),
                Icon(Icons.star_half, size: 13, color: Colors.amber),
                SizedBox(width: 4),
                Text('(4.8)', style: TextStyle(fontSize: 10, color: Color(0xFF6B7280), fontWeight: FontWeight.w600)),
              ],
            ),

            const SizedBox(height: 8),

            // Price & Original MRP & Add to Cart Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '₹${v.price.toInt()}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF111827)),
                    ),
                    if (v.mrp > v.price)
                      Text(
                        '₹${v.mrp.toInt()}',
                        style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF), decoration: TextDecoration.lineThrough),
                      ),
                  ],
                ),
                InkWell(
                  onTap: () {
                    ref.read(cartProvider.notifier).addItem(product: p, variant: v);
                    showCenterActionToast(
                      context,
                      title: 'Added to Shopping Bag! 🛍️',
                      message: p.name,
                      icon: Icons.shopping_bag_outlined,
                      iconColor: const Color(0xFF4F46E5),
                      primaryActionLabel: 'VIEW CART',
                      onPrimaryAction: () => context.push('/cart'),
                    );
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _isHovered ? const Color(0xFF4F46E5) : const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: _isHovered ? const Color(0xFF4338CA) : const Color(0xFFE5E7EB)),
                    ),
                    child: Icon(
                      Icons.shopping_cart_outlined,
                      size: 18,
                      color: _isHovered ? Colors.white : const Color(0xFF374151),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
