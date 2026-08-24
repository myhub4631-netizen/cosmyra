import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../config/theme/app_colors.dart';
import '../../../shared/widgets/center_action_toast.dart';
import '../../cart/controllers/cart_controller.dart';
import '../../navigation/widgets/vaidyam_header_widget.dart';
import '../../navigation/widgets/vaidyam_mobile_bottom_nav_bar.dart';
import '../widgets/vaidyam_mobile_category_screen_widget.dart';
import '../models/product_model.dart';
import '../repositories/product_repository.dart';
import '../widgets/product_image_widget.dart';

class VaidyamShopScreen extends ConsumerStatefulWidget {
  final String? initialCategory;
  final bool showCategoriesFirst;
  final String? searchParam;
  final String? initialSort;

  const VaidyamShopScreen({
    super.key,
    this.initialCategory,
    this.showCategoriesFirst = false,
    this.searchParam,
    this.initialSort,
  });

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
  bool _showingCategoryView = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialCategory != null && widget.initialCategory!.isNotEmpty) {
      _selectedCategory = widget.initialCategory;
    }
    if (widget.searchParam != null && widget.searchParam!.isNotEmpty) {
      _searchController.text = widget.searchParam!;
    }
    if (widget.initialSort != null && widget.initialSort!.isNotEmpty) {
      _sortBy = widget.initialSort!;
    }
    _showingCategoryView = widget.showCategoriesFirst;
  }

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
        final cleanSelected = _selectedCategory!.replaceAll('cat-', '').toLowerCase();
        final cleanProductCat = p.categoryId.replaceAll('cat-', '').toLowerCase();
        if (cleanProductCat != cleanSelected && p.categoryId != _selectedCategory) return false;
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

    // Enhanced Sorting options
    if (_sortBy == 'Price: Low to High') {
      filteredProducts.sort((a, b) => a.defaultVariant.price.compareTo(b.defaultVariant.price));
    } else if (_sortBy == 'Price: High to Low') {
      filteredProducts.sort((a, b) => b.defaultVariant.price.compareTo(a.defaultVariant.price));
    } else if (_sortBy == 'Newest') {
      filteredProducts.sort((a, b) => b.id.compareTo(a.id));
    } else if (_sortBy == 'Customer Rating') {
      filteredProducts.sort((a, b) => b.rating.compareTo(a.rating));
    } else if (_sortBy == 'Highest Discount') {
      filteredProducts.sort((a, b) {
        final discA = a.defaultVariant.mrp > 0 ? (a.defaultVariant.mrp - a.defaultVariant.price) / a.defaultVariant.mrp : 0;
        final discB = b.defaultVariant.mrp > 0 ? (b.defaultVariant.mrp - b.defaultVariant.price) / b.defaultVariant.mrp : 0;
        return discB.compareTo(discA);
      });
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth > 900;

    if (screenWidth <= 768 && _showingCategoryView) {
      return VaidyamMobileCategoryScreenWidget(
        onSelectCategory: (catId) {
          setState(() {
            _selectedCategory = catId;
            _showingCategoryView = false;
          });
        },
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      bottomNavigationBar: screenWidth <= 768 ? const VaidyamMobileBottomNavBar(activeTab: 'Categories') : null,
      body: SingleChildScrollView(
        child: Column(
        children: [
          const VaidyamHeaderWidget(activeTab: 'Shop', showValuePropositions: false),

          if (screenWidth <= 768 && _selectedCategory != null)
            Container(
              width: double.infinity,
              color: const Color(0xFFEEF2FF),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  InkWell(
                    onTap: () {
                      setState(() {
                        _selectedCategory = null;
                      });
                    },
                    child: Row(
                      children: const [
                        Icon(Icons.arrow_back_ios_new_rounded, size: 14, color: Color(0xFF4338CA)),
                        SizedBox(width: 4),
                        Text(
                          'Back to All Categories',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF4338CA)),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Category: ${_selectedCategory!}',
                    style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 16),

          // 4. Main Body: Responsive Filter Sidebar + Products Catalog Grid
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isWide ? 24.0 : 12.0),
            child: isWide
                ? Row(
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
                          child: _buildFilterSidebarContent(allProducts),
                        ),
                      ),

                      const SizedBox(width: 24),

                      // Right Section: Catalog Grid
                      Expanded(
                        child: _buildProductsCatalogSection(context, filteredProducts, allProducts, isWide, screenWidth),
                      ),
                    ],
                  )
                : Column(
                    children: [
                      // Mobile Filter Button Bar
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
                                    builder: (context) {
                                      return DraggableScrollableSheet(
                                        initialChildSize: 0.8,
                                        maxChildSize: 0.95,
                                        minChildSize: 0.5,
                                        expand: false,
                                        builder: (context, scrollCtrl) {
                                          return SingleChildScrollView(
                                            controller: scrollCtrl,
                                            padding: const EdgeInsets.all(20),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    const Text('Filter & Refine Products 🎛️', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                                    IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                                                  ],
                                                ),
                                                const Divider(),
                                                _buildFilterSidebarContent(allProducts),
                                                const SizedBox(height: 20),
                                                SizedBox(
                                                  width: double.infinity,
                                                  child: ElevatedButton(
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor: const Color(0xFF6366F1),
                                                      foregroundColor: Colors.white,
                                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                                    ),
                                                    onPressed: () => Navigator.pop(context),
                                                    child: const Text('Apply Filters', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  );
                                },
                                icon: const Icon(Icons.tune, size: 16, color: Color(0xFF6366F1)),
                                label: Text(
                                  _selectedCategory != null || _selectedConcerns.isNotEmpty
                                      ? 'Filters Applied (${(_selectedCategory != null ? 1 : 0) + _selectedConcerns.length}) 🎛️'
                                      : 'Filter Products 🎛️',
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF6366F1)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      _buildProductsCatalogSection(context, filteredProducts, allProducts, isWide, screenWidth),
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
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 90,
                height: 90,
                child: ProductImageWidget(
                  imageUrl: p.primaryImageUrl,
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

  Widget _buildFilterSidebarContent(List<ProductModel> allProducts) {
    return Column(
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
    );
  }

  Widget _buildProductsCatalogSection(
    BuildContext context,
    List<ProductModel> filteredProducts,
    List<ProductModel> allProducts,
    bool isWide,
    double screenWidth,
  ) {
    return Column(
      children: [
        // First 4 Featured Products Section
        if (allProducts.isNotEmpty) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE5E7EB)),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.star_rounded, color: Color(0xFFF59E0B), size: 20),
                    SizedBox(width: 6),
                    Text(
                      'Featured Products ⭐',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF111827)),
                    ),
                    Spacer(),
                    Text(
                      'Top Formulations',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF6366F1)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final featured4 = allProducts.take(4).toList();
                    final double cardWidth = isWide ? (constraints.maxWidth - 36) / 4 : (constraints.maxWidth - 12) / 2;
                    return Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: featured4.map((p) {
                        return SizedBox(
                          width: cardWidth,
                          child: _buildProductCard(context, p),
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],

        const SizedBox(height: 16),

        // Control & Sorting Bar
        Row(
          children: [
            Expanded(
              child: Text(
                'Showing 1–${filteredProducts.length} of ${allProducts.length} results',
                style: TextStyle(fontSize: isWide ? 13 : 11, color: const Color(0xFF6B7280), fontWeight: FontWeight.w500),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),

            // Sort By Dropdown
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _sortBy,
                  style: const TextStyle(fontSize: 11, color: Color(0xFF374151), fontWeight: FontWeight.w500),
                  items: [
                    'Popularity',
                    'Price: Low to High',
                    'Price: High to Low',
                    'Newest',
                    'Customer Rating',
                    'Highest Discount',
                  ]
                      .map((s) => DropdownMenuItem(value: s, child: Text(isWide ? 'Sort by: $s' : s)))
                      .toList(),
                  onChanged: (val) => setState(() => _sortBy = val ?? 'Popularity'),
                ),
              ),
            ),

            const SizedBox(width: 8),

            // View Switcher (Grid vs List)
            IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              icon: Icon(Icons.grid_view, size: 20, color: _isGridView ? const Color(0xFF6366F1) : const Color(0xFF9CA3AF)),
              onPressed: () => setState(() => _isGridView = true),
            ),
            const SizedBox(width: 6),
            IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              icon: Icon(Icons.view_list, size: 20, color: !_isGridView ? const Color(0xFF6366F1) : const Color(0xFF9CA3AF)),
              onPressed: () => setState(() => _isGridView = false),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Products Grid / List View
        filteredProducts.isEmpty
            ? Container(
                padding: const EdgeInsets.all(40),
                child: const Center(
                  child: Text('No botanical products match your selected filter criteria.'),
                ),
              )
            : _isGridView
                ? GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: screenWidth < 600 ? 2 : (screenWidth < 900 ? 3 : 4),
                      childAspectRatio: screenWidth < 600 ? 0.58 : 0.72,
                      crossAxisSpacing: screenWidth < 600 ? 10 : 16,
                      mainAxisSpacing: screenWidth < 600 ? 10 : 16,
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
    final String imageUrl = p.primaryImageUrl;

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
              color: _isHovered ? const Color(0xFF6366F1).withOpacity(0.12) : Colors.black.withOpacity(0.03),
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
                              color: const Color(0xFF1E1B4B).withOpacity(0.92),
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
                Row(
                  children: [
                    InkWell(
                      onTap: () {
                        ref.read(cartProvider.notifier).addItem(product: p, variant: v);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('✨ ${p.name} added to cart!'), backgroundColor: const Color(0xFF10B981)),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEEF2FF),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFFC7D2FE)),
                        ),
                        child: const Text('ADD +', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF4F46E5))),
                      ),
                    ),
                    const SizedBox(width: 4),
                    InkWell(
                      onTap: () {
                        ref.read(cartProvider.notifier).addItem(product: p, variant: v);
                        context.push('/checkout');
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF4F46E5)]),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text('Buy ⚡', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
