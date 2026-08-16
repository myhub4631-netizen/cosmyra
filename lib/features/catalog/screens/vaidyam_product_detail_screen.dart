import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../config/theme/app_colors.dart';
import '../../../shared/widgets/center_action_toast.dart';
import '../../cart/controllers/cart_controller.dart';
import '../models/product_model.dart';
import '../repositories/product_repository.dart';

class VaidyamProductDetailScreen extends ConsumerStatefulWidget {
  final ProductModel product;

  const VaidyamProductDetailScreen({super.key, required this.product});

  @override
  ConsumerState<VaidyamProductDetailScreen> createState() => _VaidyamProductDetailScreenState();
}

class _VaidyamProductDetailScreenState extends ConsumerState<VaidyamProductDetailScreen> {
  int _selectedImageIndex = 0;
  final int _selectedVariantIndex = 0;
  int _quantity = 1;
  String _activeTab = 'Description';
  String _selectedSearchCategory = 'All Categories';
  final TextEditingController _searchController = TextEditingController();

  final List<String> _sizeOptions = ['100 ml', '200 ml', '500 ml'];
  String _selectedSize = '200 ml';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartProvider);
    final wishlist = ref.watch(wishlistProvider);
    final totalCartCount = cartState.totalItemCount;

    final p = widget.product;
    final v = p.variants.isNotEmpty ? p.variants[_selectedVariantIndex] : p.defaultVariant;
    final discountPct = v.mrp > v.price ? (((v.mrp - v.price) / v.mrp) * 100).round() : 0;
    final isWishlisted = wishlist.contains(p.id);

    final imageUrls = p.imageUrls.isNotEmpty
        ? p.imageUrls
        : ['assets/images/shampoo.jpg', 'assets/images/soap.jpg', 'assets/images/facewash.jpg'];

    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth > 900;

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. Top Announcement Bar
            Container(
              width: double.infinity,
              color: const Color(0xFF4F46E5),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Text(
                      'Free Shipping on orders over ₹499 • 100% Certified Organic Botanicals',
                      style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isWide)
                    Row(
                      children: const [
                        Icon(Icons.facebook, color: Colors.white, size: 16),
                        SizedBox(width: 12),
                        Icon(Icons.camera_alt, color: Colors.white, size: 16),
                        SizedBox(width: 12),
                        Icon(Icons.play_circle_fill, color: Colors.white, size: 16),
                      ],
                    ),
                ],
              ),
            ),

            // 2. Main Header Bar (Logo, Category Search, Wishlist/Cart/Account)
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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
                            color: const Color(0xFF6366F1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.shopping_bag_outlined, color: Colors.white, size: 24),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Vaidyam Botanicals',
                          style: TextStyle(
                            fontFamily: 'serif',
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: AppColors.forestSageDark,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // Category Search Bar
                  if (isWide)
                    Container(
                      width: 480,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: const BoxDecoration(
                              border: Border(right: BorderSide(color: Color(0xFFE5E7EB))),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedSearchCategory,
                                style: const TextStyle(fontSize: 13, color: Color(0xFF374151), fontWeight: FontWeight.w500),
                                items: ['All Categories', 'Haircare', 'Skincare', 'Wellness']
                                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                                    .toList(),
                                onChanged: (val) => setState(() => _selectedSearchCategory = val ?? 'All Categories'),
                              ),
                            ),
                          ),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              decoration: const InputDecoration(
                                hintText: 'Search for products, brands and more...',
                                hintStyle: TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(horizontal: 12),
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () => context.go('/explore'),
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: const BoxDecoration(
                                color: Color(0xFF6366F1),
                                borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(7),
                                  bottomRight: Radius.circular(7),
                                ),
                              ),
                              child: const Icon(Icons.search, color: Colors.white, size: 20),
                            ),
                          ),
                        ],
                      ),
                    ),

                  const Spacer(),

                  // Shortcuts (Wishlist, Cart, Account)
                  Row(
                    children: [
                      InkWell(
                        onTap: () => context.go('/wishlist'),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Badge(
                              isLabelVisible: wishlist.isNotEmpty,
                              label: Text('${wishlist.length}'),
                              backgroundColor: const Color(0xFF6366F1),
                              child: const Icon(Icons.favorite_border, size: 22, color: Color(0xFF374151)),
                            ),
                            const SizedBox(height: 2),
                            const Text('Wishlist', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Color(0xFF4B5563))),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),
                      InkWell(
                        onTap: () => context.go('/cart'),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Badge(
                              isLabelVisible: totalCartCount > 0,
                              label: Text('$totalCartCount'),
                              backgroundColor: const Color(0xFF6366F1),
                              child: const Icon(Icons.shopping_cart_outlined, size: 22, color: Color(0xFF374151)),
                            ),
                            const SizedBox(height: 2),
                            const Text('Cart', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Color(0xFF4B5563))),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),
                      InkWell(
                        onTap: () => context.go('/dashboard'),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.person_outline, size: 22, color: Color(0xFF374151)),
                            SizedBox(height: 2),
                            Text('Account', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Color(0xFF4B5563))),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 3. Navigation Bar Links Header
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6366F1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.menu, color: Colors.white, size: 18),
                        SizedBox(width: 8),
                        Text('All Categories', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                        SizedBox(width: 16),
                        Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 18),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildNavLink('Home', () => context.go('/')),
                          _buildNavLink('Shop', () => context.go('/explore')),
                          _buildNavLink('Categories', () => context.go('/explore')),
                          _buildNavLink('Deals', () => context.go('/explore')),
                          _buildNavLink('New Arrivals', () => context.go('/explore')),
                          _buildNavLink('Best Sellers', () => context.go('/explore')),
                          _buildNavLink('Brands', () => context.go('/explore')),
                          _buildNavLink('Blog', () {}),
                          _buildNavLink('Contact', () {}),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 4. Breadcrumb Trail
            Container(
              width: double.infinity,
              color: const Color(0xFFF9FAFB),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1300),
                child: Row(
                  children: [
                    InkWell(onTap: () => context.go('/'), child: const Text('Home', style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)))),
                    const Text('  >  ', style: TextStyle(fontSize: 13, color: Color(0xFF9CA3AF))),
                    InkWell(onTap: () => context.go('/explore'), child: const Text('Haircare', style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)))),
                    const Text('  >  ', style: TextStyle(fontSize: 13, color: Color(0xFF9CA3AF))),
                    Expanded(child: Text(p.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF111827)), maxLines: 1, overflow: TextOverflow.ellipsis)),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 5. Main Product Showcase (Left Gallery + Right Product Specs)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1300),
                child: isWide
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Left Column: Image Gallery & 4 Trust Badges
                          Expanded(
                            flex: 5,
                            child: _buildGalleryAndTrustBadges(context, imageUrls),
                          ),
                          const SizedBox(width: 40),
                          // Right Column: Product Specs & Actions
                          Expanded(
                            flex: 6,
                            child: _buildProductSpecsAndActions(context, p, v, discountPct, isWishlisted),
                          ),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildGalleryAndTrustBadges(context, imageUrls),
                          const SizedBox(height: 32),
                          _buildProductSpecsAndActions(context, p, v, discountPct, isWishlisted),
                        ],
                      ),
              ),
            ),

            const SizedBox(height: 40),

            // 6. Bottom Tabbed Details Section (Description, Specs, Reviews, Q&A)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1300),
                child: _buildBottomDetailsTabs(context, p),
              ),
            ),

            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  Widget _buildNavLink(String label, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 24),
      child: InkWell(
        onTap: onTap,
        child: Text(
          label,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF374151)),
        ),
      ),
    );
  }

  // Left Showcase Column: Gallery & Trust Badges
  Widget _buildGalleryAndTrustBadges(BuildContext context, List<String> imageUrls) {
    final currentImage = imageUrls[_selectedImageIndex < imageUrls.length ? _selectedImageIndex : 0];

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Vertical Image Thumbnail Carousel
            Column(
              children: [
                ...imageUrls.asMap().entries.take(4).map((entry) {
                  final idx = entry.key;
                  final url = entry.value;
                  final isSelected = idx == _selectedImageIndex;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: InkWell(
                      onTap: () => setState(() => _selectedImageIndex = idx),
                      child: Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected ? const Color(0xFF6366F1) : const Color(0xFFE5E7EB),
                            width: isSelected ? 2 : 1,
                          ),
                          image: DecorationImage(
                            image: url.startsWith('data:')
                                ? MemoryImage(base64Decode(url.split(',').last)) as ImageProvider
                                : (url.startsWith('http') ? NetworkImage(url) as ImageProvider : AssetImage(url)),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
                if (imageUrls.length > 4)
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Center(
                      child: Text(
                        '+${imageUrls.length - 4}',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF4F46E5)),
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(width: 16),

            // Large Main Showcase Image Box
            Expanded(
              child: AspectRatio(
                aspectRatio: 1.0,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFF3F4F6)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 15,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    image: DecorationImage(
                      image: currentImage.startsWith('data:')
                          ? MemoryImage(base64Decode(currentImage.split(',').last)) as ImageProvider
                          : (currentImage.startsWith('http') ? NetworkImage(currentImage) as ImageProvider : AssetImage(currentImage)),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // 4 Trust Feature Badges Bar
        Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFF3F4F6)),
          ),
          child: Row(
            children: [
              Expanded(child: _buildTrustBadge(Icons.local_shipping_outlined, 'Free Shipping', 'On orders over ₹499')),
              Expanded(child: _buildTrustBadge(Icons.published_with_changes, 'Easy Returns', '30 days return policy')),
              Expanded(child: _buildTrustBadge(Icons.lock_outline, 'Secure Payment', '100% secure checkout')),
              Expanded(child: _buildTrustBadge(Icons.support_agent, '24/7 Support', 'Dedicated support')),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTrustBadge(IconData icon, String title, String subtitle) {
    return Column(
      children: [
        Icon(icon, size: 22, color: const Color(0xFF4F46E5)),
        const SizedBox(height: 6),
        Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF111827)), textAlign: TextAlign.center),
        const SizedBox(height: 2),
        Text(subtitle, style: const TextStyle(fontSize: 10, color: Color(0xFF6B7280)), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
      ],
    );
  }

  // Right Column: Product Specs & Actions
  Widget _buildProductSpecsAndActions(BuildContext context, ProductModel p, ProductVariant v, int discountPct, bool isWishlisted) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title & Wishlist Button Row
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    p.name,
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF111827), height: 1.2),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    p.tagline ?? 'Pure Organic Ayurvedic Formulation for Daily Wellness',
                    style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280), fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            IconButton(
              icon: Icon(
                isWishlisted ? Icons.favorite : Icons.favorite_border,
                color: isWishlisted ? const Color(0xFFEF4444) : const Color(0xFF9CA3AF),
                size: 26,
              ),
              onPressed: () {
                ref.read(wishlistProvider.notifier).toggleWishlist(p.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(isWishlisted ? 'Removed ${p.name} from Wishlist' : 'Added ${p.name} to Wishlist!')),
                );
              },
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Rating & Sales Count Bar
        Row(
          children: [
            Row(
              children: const [
                Icon(Icons.star, size: 18, color: Colors.amber),
                Icon(Icons.star, size: 18, color: Colors.amber),
                Icon(Icons.star, size: 18, color: Colors.amber),
                Icon(Icons.star, size: 18, color: Colors.amber),
                Icon(Icons.star_half, size: 18, color: Colors.amber),
              ],
            ),
            const SizedBox(width: 8),
            const Text('(4.3)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
            const SizedBox(width: 12),
            const Text('|   1,200 Ratings   |   200+ Sold', style: TextStyle(fontSize: 12, color: Color(0xFF6B7280), fontWeight: FontWeight.w500)),
          ],
        ),

        const SizedBox(height: 20),

        // Pricing Box
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text('₹${v.price.toInt()}', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
            const SizedBox(width: 12),
            if (v.mrp > v.price)
              Text('₹${v.mrp.toInt()}', style: const TextStyle(fontSize: 16, color: Color(0xFF9CA3AF), decoration: TextDecoration.lineThrough)),
            const SizedBox(width: 12),
            if (discountPct > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text('$discountPct% OFF', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
          ],
        ),

        const SizedBox(height: 20),
        const Divider(color: Color(0xFFE5E7EB)),
        const SizedBox(height: 20),

        // Key Bullet Highlights
        const Text('Key Highlights', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
        const SizedBox(height: 10),
        _buildHighlightBullet('100% Certified Organic Ayurvedic Ingredients'),
        _buildHighlightBullet('Deeply Hydrating, Nourishing & De-Tan Formulation'),
        _buildHighlightBullet('Sulfate-Free, Paraben-Free & Cruelty-Free Guarantee'),
        _buildHighlightBullet('Suitable for All Skin & Hair Types'),

        const SizedBox(height: 24),

        // Volume / Size Variant Selector
        Text('Color / Size: $_selectedSize', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
        const SizedBox(height: 10),
        Row(
          children: _sizeOptions.map((size) {
            final isSelected = _selectedSize == size;
            return Padding(
              padding: const EdgeInsets.only(right: 12),
              child: InkWell(
                onTap: () => setState(() => _selectedSize = size),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFEEF2FF) : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected ? const Color(0xFF4F46E5) : const Color(0xFFE5E7EB),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Text(
                    size,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected ? const Color(0xFF4F46E5) : const Color(0xFF374151),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 28),

        // Quantity Selector & Action Buttons Row
        Row(
          children: [
            // Quantity Selector Box
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove, size: 18, color: Color(0xFF374151)),
                    onPressed: () {
                      if (_quantity > 1) setState(() => _quantity--);
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text('$_quantity', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add, size: 18, color: Color(0xFF374151)),
                    onPressed: () => setState(() => _quantity++),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 16),

            // Add to Cart Button (Outlined)
            Expanded(
              child: SizedBox(
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: () {
                    for (int i = 0; i < _quantity; i++) {
                      ref.read(cartProvider.notifier).addItem(product: p, variant: v);
                    }
                    showCenterActionToast(
                      context,
                      title: 'Added to Shopping Bag! 🛍️',
                      message: '$_quantity x ${p.name}',
                      icon: Icons.shopping_bag_outlined,
                      iconColor: const Color(0xFF4F46E5),
                      primaryActionLabel: 'VIEW CART',
                      onPrimaryAction: () => context.push('/cart'),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF4F46E5), width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.shopping_cart_outlined, color: Color(0xFF4F46E5), size: 20),
                  label: const Text('Add to Cart', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF4F46E5))),
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Buy Now Button (Solid Purple)
            Expanded(
              child: SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    ref.read(cartProvider.notifier).addItem(product: p, variant: v);
                    context.go('/checkout');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4F46E5),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Buy Now', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHighlightBullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          const Icon(Icons.check_circle, size: 16, color: Color(0xFF4F46E5)),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13, color: Color(0xFF4B5563)))),
        ],
      ),
    );
  }

  // Bottom Detail Tabs Section
  Widget _buildBottomDetailsTabs(BuildContext context, ProductModel p) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tab Header Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
            ),
            child: Row(
              children: ['Description', 'Specifications', 'Reviews (1,200)', 'Q & A'].map((tab) {
                final isSelected = _activeTab == tab;
                return Padding(
                  padding: const EdgeInsets.only(right: 32),
                  child: InkWell(
                    onTap: () => setState(() => _activeTab = tab),
                    child: Column(
                      children: [
                        Text(
                          tab,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            color: isSelected ? const Color(0xFF4F46E5) : const Color(0xFF6B7280),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 2,
                          width: 60,
                          color: isSelected ? const Color(0xFF4F46E5) : Colors.transparent,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // Tab Content Body
          Padding(
            padding: const EdgeInsets.all(24),
            child: _buildTabContent(p),
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent(ProductModel p) {
    if (_activeTab == 'Specifications') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Product Specifications', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
          const SizedBox(height: 16),
          _buildSpecRow('SKU Code', p.defaultVariant.sku),
          _buildSpecRow('Ingredients (INCI)', p.ingredients),
          _buildSpecRow('Formulation Type', '100% Certified Organic Extract'),
          _buildSpecRow('Net Weight', p.defaultVariant.sizeLabel),
          _buildSpecRow('Shelf Life', '24 Months from Manufacturing'),
        ],
      );
    } else if (_activeTab == 'Reviews (1,200)') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Customer Reviews', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
          const SizedBox(height: 16),
          _buildReviewTile('Ananya Roy', '★★★★★', 'Absolutely amazing formulation! Hair feels super soft and healthy.'),
          const Divider(height: 24),
          _buildReviewTile('Vikramaditya S.', '★★★★★', 'Top quality organic product. Reduced dandruff significantly in 2 weeks.'),
        ],
      );
    } else if (_activeTab == 'Q & A') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Frequently Asked Questions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
          const SizedBox(height: 16),
          const Text('Q: Is this suitable for color-treated hair?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 4),
          const Text('A: Yes! It is 100% sulfate-free and completely safe for color-treated hair.', style: TextStyle(fontSize: 13, color: Color(0xFF4B5563))),
        ],
      );
    }

    // Default: Description Tab
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          p.description,
          style: const TextStyle(fontSize: 14, color: Color(0xFF374151), height: 1.6),
        ),
        const SizedBox(height: 20),
        const Text('How To Use:', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
        const SizedBox(height: 8),
        Text(
          (p.howToUse ?? '').isNotEmpty ? p.howToUse! : 'Apply a small amount onto damp scalp or skin. Gently massage in circular motions. Rinse thoroughly with warm water.',
          style: const TextStyle(fontSize: 14, color: Color(0xFF4B5563), height: 1.5),
        ),
      ],
    );
  }

  Widget _buildSpecRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(width: 180, child: Text(title, style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280), fontWeight: FontWeight.w500))),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF111827)))),
        ],
      ),
    );
  }

  Widget _buildReviewTile(String name, String stars, String review) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const CircleAvatar(radius: 14, child: Icon(Icons.person, size: 16)),
            const SizedBox(width: 10),
            Text(name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
            const SizedBox(width: 12),
            Text(stars, style: const TextStyle(color: Colors.amber, fontSize: 13)),
          ],
        ),
        const SizedBox(height: 8),
        Text(review, style: const TextStyle(fontSize: 13, color: Color(0xFF374151))),
      ],
    );
  }
}
