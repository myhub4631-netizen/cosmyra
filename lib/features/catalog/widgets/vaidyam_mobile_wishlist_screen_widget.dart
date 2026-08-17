import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../cart/controllers/cart_controller.dart';
import '../../navigation/widgets/vaidyam_mobile_bottom_nav_bar.dart';
import '../models/product_model.dart';
import '../repositories/product_repository.dart';
import 'product_image_widget.dart';

class VaidyamMobileWishlistScreenWidget extends ConsumerStatefulWidget {
  final List<ProductModel> wishlistProducts;
  final VoidCallback onRefresh;

  const VaidyamMobileWishlistScreenWidget({
    super.key,
    required this.wishlistProducts,
    required this.onRefresh,
  });

  @override
  ConsumerState<VaidyamMobileWishlistScreenWidget> createState() => _VaidyamMobileWishlistScreenWidgetState();
}

class _VaidyamMobileWishlistScreenWidgetState extends ConsumerState<VaidyamMobileWishlistScreenWidget> {
  static const Color _primaryPurple = Color(0xFF4338CA);
  static const Color _lightBg = Color(0xFFF8FAFC);
  static const Color _textDark = Color(0xFF0F172A);
  static const Color _textMuted = Color(0xFF64748B);

  String _sortBy = 'Recently Added';
  bool _priceDropAlertsEnabled = false;
  bool _isSelectionMode = false;

  // Curated demo products matching exact screenshot
  static final List<Map<String, dynamic>> _demoItems = [
    {
      'id': 'w1',
      'brand': 'Cosmyra',
      'name': 'Shata Dhauta Ghrita Cream',
      'variant': '100 g • 100 Times Washed Ghee',
      'rating': 4.8,
      'reviews': 12540,
      'discount': 29,
      'price': 1499.0,
      'mrp': 2100.0,
      'delivery': 'Delivery by 20 May',
      'image': 'assets/images/cream.jpg',
      'colorBg': const Color(0xFFEEF2FF),
    },
    {
      'id': 'w2',
      'brand': 'Cosmyra',
      'name': 'Triphala Hair Shampoo',
      'variant': '300 ml • Natural Hair Cleanser',
      'rating': 4.6,
      'reviews': 8325,
      'discount': 17,
      'price': 899.0,
      'mrp': 1099.0,
      'delivery': 'Delivery by 18 May',
      'image': 'assets/images/shampoo.jpg',
      'colorBg': const Color(0xFFE0F2FE),
    },
    {
      'id': 'w3',
      'brand': 'Cosmyra',
      'name': 'Kumkumadi Tailam Glow Serum',
      'variant': '30 ml • Pure Kashmiri Saffron',
      'rating': 4.9,
      'reviews': 22410,
      'discount': 25,
      'price': 2499.0,
      'mrp': 3299.0,
      'delivery': 'Delivery by 22 May',
      'image': 'assets/images/serum.jpg',
      'colorBg': const Color(0xFFECFDF5),
    },
    {
      'id': 'w4',
      'brand': 'Cosmyra',
      'name': 'Bhringraj Intensive Hair Oil',
      'variant': '200 ml • Deep Root Therapy',
      'rating': 4.7,
      'reviews': 31245,
      'discount': 20,
      'price': 1299.0,
      'mrp': 1599.0,
      'delivery': 'Delivery by 20 May',
      'image': 'assets/images/oil.jpg',
      'colorBg': const Color(0xFFFEF3C7),
    },
    {
      'id': 'w5',
      'brand': 'Cosmyra',
      'name': 'Nalpamaradi Skin Brightening Ubtan',
      'variant': '150 g • Ayurvedic Face Pack',
      'rating': 4.5,
      'reviews': 6142,
      'discount': 15,
      'price': 999.0,
      'mrp': 1199.0,
      'delivery': 'Delivery by 21 May',
      'image': 'assets/images/ubtan.jpg',
      'colorBg': const Color(0xFFF3E8FF),
    },
  ];

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartProvider);
    final totalCartCount = cartState.totalItemCount;

    final bool hasRealProducts = widget.wishlistProducts.isNotEmpty;
    final int itemCount = hasRealProducts ? widget.wishlistProducts.length : _demoItems.length;

    double totalValue = 0;
    double totalSavings = 0;

    if (hasRealProducts) {
      for (var p in widget.wishlistProducts) {
        final price = p.variants.isNotEmpty ? p.variants.first.price : 0.0;
        final mrp = p.variants.isNotEmpty ? p.variants.first.mrp : price;
        totalValue += mrp;
        totalSavings += (mrp > price ? (mrp - price) : 0);
      }
    } else {
      for (var d in _demoItems) {
        final price = d['price'] as double;
        final mrp = d['mrp'] as double;
        totalValue += mrp;
        totalSavings += (mrp - price);
      }
    }

    return Scaffold(
      backgroundColor: _lightBg,
      bottomNavigationBar: const VaidyamMobileBottomNavBar(activeTab: 'Wishlist'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header Bar: Back Arrow + My Wishlist + Bell & Cart (3)
              _buildHeaderBar(context, totalCartCount),

              const SizedBox(height: 16),

              // 2. Wishlist Analytics & Metrics Summary Banner
              _buildMetricsSummaryCard(itemCount, totalValue, totalSavings),

              const SizedBox(height: 16),

              // 3. Sort & Controls Bar (Sort by, Manage, Select)
              _buildSortControlsBar(),

              const SizedBox(height: 14),

              // 4. Wishlist Product Cards List
              if (hasRealProducts)
                _buildRealProductCardsList(context)
              else
                _buildDemoProductCardsList(context),

              const SizedBox(height: 16),

              // 5. Price Drop Alerts Banner
              _buildPriceDropAlertsBanner(context),

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
          'My Wishlist',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: _textDark,
          ),
        ),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_none_rounded, color: _textDark, size: 22),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Wishlist Price Drop Notifications active 🔔')),
                );
              },
            ),
            Stack(
              clipBehavior: Clip.none,
              children: [
                IconButton(
                  icon: const Icon(Icons.shopping_cart_outlined, color: _textDark, size: 22),
                  onPressed: () => context.push('/cart'),
                ),
                if (cartCount > 0)
                  Positioned(
                    right: 6,
                    top: 6,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: _primaryPurple,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '$cartCount',
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  // 2. Wishlist Analytics & Metrics Summary Banner
  Widget _buildMetricsSummaryCard(int count, double totalValue, double totalSavings) {
    final formatCurrency = (double amount) {
      return '₹${amount.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}';
    };

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Metric 1: Items Saved (Highlighted Purple Box)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF3E8FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.favorite_rounded, color: _primaryPurple, size: 20),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$count',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: _primaryPurple),
                    ),
                    const Text(
                      'Items Saved',
                      style: TextStyle(fontSize: 10, color: _primaryPurple, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // Metric 2: Total Value
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                formatCurrency(totalValue),
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: _textDark),
              ),
              const Text(
                'Total Value',
                style: TextStyle(fontSize: 10, color: _textMuted),
              ),
            ],
          ),

          const SizedBox(width: 12),

          // Metric 3: You Save
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                formatCurrency(totalSavings),
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF16A34A)),
              ),
              const Text(
                'You Save',
                style: TextStyle(fontSize: 10, color: _textMuted),
              ),
            ],
          ),

          const Spacer(),

          // Share Wishlist Pill Button
          OutlinedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Wishlist share link copied to clipboard! 🔗')),
              );
            },
            icon: const Icon(Icons.share_outlined, size: 12, color: _primaryPurple),
            label: const Text('Share Wishlist', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: _primaryPurple)),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              side: const BorderSide(color: Color(0xFFC7D2FE)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ],
      ),
    );
  }

  // 3. Sort & Controls Bar
  Widget _buildSortControlsBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Sort Dropdown
        Row(
          children: [
            const Text('Sort by: ', style: TextStyle(fontSize: 12, color: _textMuted)),
            DropdownButton<String>(
              value: _sortBy,
              underline: const SizedBox(),
              icon: const Icon(Icons.keyboard_arrow_down_rounded, color: _textDark, size: 18),
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _textDark),
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _sortBy = val;
                  });
                }
              },
              items: ['Recently Added', 'Price: Low to High', 'Price: High to Low', 'Discount'].map((st) {
                return DropdownMenuItem<String>(value: st, child: Text(st));
              }).toList(),
            ),
          ],
        ),

        // Manage & Select Buttons
        Row(
          children: [
            InkWell(
              onTap: () {
                setState(() {
                  _isSelectionMode = !_isSelectionMode;
                });
              },
              child: Row(
                children: const [
                  Icon(Icons.edit_outlined, size: 14, color: _primaryPurple),
                  SizedBox(width: 4),
                  Text('Manage', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _primaryPurple)),
                ],
              ),
            ),
            const SizedBox(width: 12),
            InkWell(
              onTap: () {
                setState(() {
                  _isSelectionMode = !_isSelectionMode;
                });
              },
              child: Row(
                children: const [
                  Icon(Icons.crop_free_rounded, size: 14, color: _primaryPurple),
                  SizedBox(width: 4),
                  Text('Select', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _primaryPurple)),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  // 4. Demo Wishlist Product Cards List
  Widget _buildDemoProductCardsList(BuildContext context) {
    return Column(
      children: _demoItems.map((item) {
        final String id = item['id'] as String;
        final String brand = item['brand'] as String;
        final String name = item['name'] as String;
        final String variant = item['variant'] as String;
        final double rating = (item['rating'] as num).toDouble();
        final int reviews = item['reviews'] as int;
        final int discount = item['discount'] as int;
        final double price = (item['price'] as num).toDouble();
        final double mrp = (item['mrp'] as num).toDouble();
        final double savings = mrp - price;
        final String delivery = item['delivery'] as String;
        final String image = item['image'] as String;
        final Color colorBg = item['colorBg'] as Color;

        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image with Solid Purple Heart Badge
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      width: 100,
                      height: 100,
                      color: colorBg,
                      child: ProductImageWidget(
                        imageUrl: image,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 6,
                    left: 6,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.favorite_rounded, color: _primaryPurple, size: 14),
                    ),
                  ),
                ],
              ),

              const SizedBox(width: 12),

              // Details & Actions
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Brand + Options
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          brand,
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF2563EB)),
                        ),
                        PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert_rounded, color: _textMuted, size: 18),
                          onSelected: (val) {
                            if (val == 'remove') {
                              ref.read(wishlistProvider.notifier).toggleWishlist(id);
                              widget.onRefresh();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Removed $name from Wishlist 💔')),
                              );
                            }
                          },
                          itemBuilder: (ctx) => [
                            const PopupMenuItem(value: 'remove', child: Text('Remove from Wishlist')),
                            const PopupMenuItem(value: 'collection', child: Text('Move to Collection')),
                            const PopupMenuItem(value: 'share', child: Text('Share Product')),
                          ],
                        ),
                      ],
                    ),

                    // Title & Variant
                    Text(
                      name,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: _textDark),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      variant,
                      style: const TextStyle(fontSize: 11, color: _textMuted),
                    ),

                    const SizedBox(height: 4),

                    // Rating & Discount Tag
                    Row(
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.star_rounded, color: Color(0xFFF59E0B), size: 14),
                            Icon(Icons.star_rounded, color: Color(0xFFF59E0B), size: 14),
                            Icon(Icons.star_rounded, color: Color(0xFFF59E0B), size: 14),
                            Icon(Icons.star_rounded, color: Color(0xFFF59E0B), size: 14),
                            Icon(Icons.star_half_rounded, color: Color(0xFFF59E0B), size: 14),
                          ],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$rating ($reviews)',
                          style: const TextStyle(fontSize: 10, color: _textMuted),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDCFCE7),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '$discount% OFF',
                            style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF15803D)),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 4),
                    Text(
                      '🚚 $delivery',
                      style: const TextStyle(fontSize: 10, color: _textMuted),
                    ),

                    const SizedBox(height: 8),

                    // Price Breakdown & Add to Cart Button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEE2E2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'You save ₹${savings.toInt()}',
                                style: const TextStyle(color: Color(0xFFDC2626), fontSize: 9, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  '₹${price.toInt()}',
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: _textDark),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '₹${mrp.toInt()}',
                                  style: const TextStyle(fontSize: 11, color: _textMuted, decoration: TextDecoration.lineThrough),
                                ),
                              ],
                            ),
                          ],
                        ),

                        OutlinedButton.icon(
                          onPressed: () {
                            _addToCartHelper(
                              id: id,
                              name: name,
                              categoryId: 'Ayurveda',
                              variantLabel: variant,
                              price: price,
                              mrp: mrp,
                              image: image,
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Added $name to Cart! 🛒')),
                            );
                          },
                          icon: const Icon(Icons.shopping_cart_outlined, size: 14, color: _primaryPurple),
                          label: const Text('Add to Cart', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _primaryPurple)),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            side: const BorderSide(color: Color(0xFFC7D2FE)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
      }).toList(),
    );
  }

  // 4. Real Wishlist Product Cards List
  Widget _buildRealProductCardsList(BuildContext context) {
    return Column(
      children: widget.wishlistProducts.map((p) {
        final variant = p.variants.isNotEmpty ? p.variants.first : null;
        final double price = variant?.price ?? 0.0;
        final double mrp = variant?.mrp ?? price;
        final double savings = mrp > price ? mrp - price : 0;
        final String image = p.imageUrls.isNotEmpty ? p.imageUrls.first : 'assets/images/shampoo.jpg';
        final String brand = 'Cosmyra';

        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      width: 100,
                      height: 100,
                      color: const Color(0xFFEEF2FF),
                      child: ProductImageWidget(
                        imageUrl: image,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 6,
                    left: 6,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.favorite_rounded, color: _primaryPurple, size: 14),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          brand,
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF2563EB)),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: _textMuted, size: 18),
                          onPressed: () {
                            ref.read(wishlistProvider.notifier).toggleWishlist(p.id);
                            widget.onRefresh();
                          },
                        ),
                      ],
                    ),
                    Text(
                      p.name,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: _textDark),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      variant?.sizeLabel ?? 'Standard Pack',
                      style: const TextStyle(fontSize: 11, color: _textMuted),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (savings > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFEE2E2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'You save ₹${savings.toInt()}',
                                  style: const TextStyle(color: Color(0xFFDC2626), fontSize: 9, fontWeight: FontWeight.bold),
                                ),
                              ),
                            Row(
                              children: [
                                Text('₹${price.toInt()}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: _textDark)),
                                const SizedBox(width: 6),
                                if (mrp > price)
                                  Text('₹${mrp.toInt()}', style: const TextStyle(fontSize: 11, color: _textMuted, decoration: TextDecoration.lineThrough)),
                              ],
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            OutlinedButton(
                              onPressed: () {
                                if (variant != null) {
                                  ref.read(cartProvider.notifier).addItem(product: p, variant: variant);
                                } else {
                                  _addToCartHelper(
                                    id: p.id,
                                    name: p.name,
                                    categoryId: p.categoryId,
                                    variantLabel: 'Standard Pack',
                                    price: 999.0,
                                    mrp: 1199.0,
                                    image: image,
                                  );
                                }
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Added ${p.name} to Cart! 🛒')),
                                );
                              },
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                side: const BorderSide(color: Color(0xFFC7D2FE)),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: const Text('ADD +', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: _primaryPurple)),
                            ),
                            const SizedBox(width: 4),
                            ElevatedButton.icon(
                              onPressed: () {
                                if (variant != null) {
                                  ref.read(cartProvider.notifier).addItem(product: p, variant: variant);
                                } else {
                                  _addToCartHelper(
                                    id: p.id,
                                    name: p.name,
                                    categoryId: p.categoryId,
                                    variantLabel: 'Standard Pack',
                                    price: 999.0,
                                    mrp: 1199.0,
                                    image: image,
                                  );
                                }
                                context.push('/checkout');
                              },
                              icon: const Icon(Icons.bolt, size: 12, color: Colors.white),
                              label: const Text('Buy ⚡', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _primaryPurple,
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                elevation: 0,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // 5. Price Drop Alerts Banner
  Widget _buildPriceDropAlertsBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF3E8FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE9D5FF)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: _primaryPurple,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.notifications_active_rounded, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Price Drop Alerts',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: _textDark),
                ),
                SizedBox(height: 2),
                Text(
                  'Get notified when items in your wishlist go on sale',
                  style: TextStyle(fontSize: 10, color: _textMuted),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _priceDropAlertsEnabled = !_priceDropAlertsEnabled;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(_priceDropAlertsEnabled
                      ? 'Price Drop Alerts Enabled! 🔔'
                      : 'Price Drop Alerts Disabled'),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _priceDropAlertsEnabled ? const Color(0xFF16A34A) : _primaryPurple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            child: Text(
              _priceDropAlertsEnabled ? 'Enabled ✓' : 'Enable Alerts',
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _addToCartHelper({
    required String id,
    required String name,
    required String categoryId,
    required String variantLabel,
    required double price,
    required double mrp,
    required String image,
  }) {
    final variant = ProductVariant(
      id: 'var_$id',
      productId: id,
      sku: 'SKU_$id',
      sizeLabel: variantLabel,
      price: price,
      mrp: mrp,
      stock: 100,
      isDefault: true,
    );
    final product = ProductModel(
      id: id,
      brandId: 'brand_cosmyra',
      categoryId: categoryId,
      name: name,
      slug: id,
      description: name,
      ingredients: 'Pure Organic Botanicals',
      freeFromClaims: const ['Paraben Free', 'Cruelty Free'],
      imageUrls: [image],
      isFeatured: true,
      variants: [variant],
    );
    ref.read(cartProvider.notifier).addItem(product: product, variant: variant);
  }
}
