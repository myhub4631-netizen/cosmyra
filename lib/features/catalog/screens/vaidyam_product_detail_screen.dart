import 'dart:convert';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../config/theme/app_colors.dart';
import '../../cart/controllers/cart_controller.dart';
import '../../admin/controllers/brand_settings_controller.dart';
import '../models/product_model.dart';
import '../repositories/product_repository.dart';
import '../widgets/product_image_widget.dart';
import '../../navigation/widgets/vaidyam_footer_widget.dart';

class VaidyamProductDetailScreen extends ConsumerStatefulWidget {
  final ProductModel product;

  const VaidyamProductDetailScreen({super.key, required this.product});

  @override
  ConsumerState<VaidyamProductDetailScreen> createState() => _VaidyamProductDetailScreenState();
}

class _VaidyamProductDetailScreenState extends ConsumerState<VaidyamProductDetailScreen> {
  int _selectedImageIndex = 0;
  int _selectedVariantIndex = 0;
  int _quantity = 1;
  String _activeTab = 'Description';
  bool _isDescriptionExpanded = false;

  final TextEditingController _pincodeController = TextEditingController(text: '110001');
  String _pincodeLocation = 'Delhi';
  bool _isPincodeValid = true;

  @override
  void dispose() {
    _pincodeController.dispose();
    super.dispose();
  }

  void _showSizeGuideModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '📏 Product Volume & Usage Guide',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B)),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildGuideRow('100 ml', 'Travel Pack', 'Lasts ~2-3 weeks of daily face wash'),
            _buildGuideRow('200 ml', 'Standard Pack (Popular 🔥)', 'Lasts ~1.5 months of daily use'),
            _buildGuideRow('300 ml', 'Value Family Pack 🎁', 'Lasts ~2.5 months • Best Savings'),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4F46E5),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Got It', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuideRow(String size, String title, String desc) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFEEF2FF),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(size, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF4F46E5))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                Text(desc, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showWriteReviewModal(BuildContext context) {
    final ratingCtrl = ValueNotifier<double>(5.0);
    final reviewTextCtrl = TextEditingController();
    final nameCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('✏️ Write a Verified Review', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
              const SizedBox(height: 16),
              ValueListenableBuilder<double>(
                valueListenable: ratingCtrl,
                builder: (context, val, _) => Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return IconButton(
                      icon: Icon(
                        index < val ? Icons.star_rounded : Icons.star_border_rounded,
                        color: const Color(0xFFF59E0B),
                        size: 32,
                      ),
                      onPressed: () => ratingCtrl.value = (index + 1).toDouble(),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: nameCtrl,
                decoration: InputDecoration(
                  labelText: 'Your Name',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: reviewTextCtrl,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Share details about your experience...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('✨ Thank you! Your review has been submitted for verification.'),
                        backgroundColor: Color(0xFF10B981),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4F46E5),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Submit Review', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartProvider);
    final wishlist = ref.watch(wishlistProvider);
    final brandSettings = ref.watch(brandSettingsProvider);
    final totalCartCount = cartState.totalItemCount;

    final allProducts = ref.watch(adminProductsProvider);
    final p = allProducts.firstWhere(
      (prod) => prod.id.trim() == widget.product.id.trim() || prod.slug.trim().toLowerCase() == widget.product.slug.trim().toLowerCase(),
      orElse: () => widget.product,
    );
    final variants = p.variants.isNotEmpty ? p.variants : [p.defaultVariant];
    final v = variants[_selectedVariantIndex.clamp(0, variants.length - 1)];

    final double price = v.price;
    final double mrp = v.mrp > v.price ? v.mrp : v.price * 1.35;
    final int discountPct = (((mrp - price) / mrp) * 100).round();
    final bool isWishlisted = wishlist.contains(p.id);

    final imageUrls = p.formattedImageUrls.isNotEmpty
        ? p.formattedImageUrls
        : p.imageUrls;

    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth > 900;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          color: Colors.white,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF0F172A), size: 20),
                    onPressed: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go('/');
                      }
                    },
                  ),
                  InkWell(
                    onTap: () => context.go('/'),
                    child: Row(
                      children: [
                        Image.asset(
                          'assets/images/cosmyra_logo.png',
                          height: 32,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => const Icon(Icons.spa_rounded, color: Color(0xFF4F46E5), size: 24),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.verified_rounded, color: Color(0xFF6366F1), size: 16),
                      ],
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.search_rounded, color: Color(0xFF0F172A), size: 22),
                    onPressed: () => context.push('/shop'),
                  ),
                  Badge(
                    isLabelVisible: wishlist.isNotEmpty,
                    label: Text('${wishlist.length}'),
                    backgroundColor: const Color(0xFF6366F1),
                    child: IconButton(
                      icon: Icon(
                        isWishlisted ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                        color: isWishlisted ? const Color(0xFFEF4444) : const Color(0xFF0F172A),
                        size: 22,
                      ),
                      onPressed: () => ref.read(wishlistProvider.notifier).toggleWishlist(p.id),
                    ),
                  ),
                  Badge(
                    isLabelVisible: totalCartCount > 0,
                    label: Text('$totalCartCount'),
                    backgroundColor: const Color(0xFF6366F1),
                    child: IconButton(
                      icon: const Icon(Icons.shopping_cart_outlined, color: Color(0xFF0F172A), size: 22),
                      onPressed: () => context.push('/cart'),
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert_rounded, color: Color(0xFF0F172A), size: 22),
                    onSelected: (val) {
                      if (val == 'share') {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('🔗 Product link copied to clipboard!')),
                        );
                      } else if (val == 'support') {
                        context.push('/account');
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'share', child: Text('🔗 Share Product')),
                      const PopupMenuItem(value: 'support', child: Text('💬 Need Help / Support')),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),

      // Single Product Content Body
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (kDebugMode)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFFCA5A5)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('🔍 Live Product Media Diagnostic (Debug Mode)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF991B1B))),
                    const SizedBox(height: 4),
                    Text('Product ID: ${p.id} | SKU: ${v.sku}', style: const TextStyle(fontSize: 10, color: Color(0xFF7F1D1D))),
                    Text('Media Version: v${p.mediaVersion} | Product Version: v${p.productVersion}', style: const TextStyle(fontSize: 10, color: Color(0xFF7F1D1D))),
                    Text('Rendered Image URL: ${p.primaryImageUrl}', style: const TextStyle(fontSize: 10, fontFamily: 'monospace', color: Color(0xFF7F1D1D)), maxLines: 2, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            // 0. Announcement Bar
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              color: const Color(0xFF4338CA),
              child: const Text(
                '🌿 Free Shipping on all orders above ₹999!',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ),

            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isWide ? screenWidth * 0.15 : 12,
                vertical: 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Product Image Gallery Showcase
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        // Main Product Image
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: SizedBox(
                            height: 340,
                            width: double.infinity,
                            child: ProductImageWidget(
                              imageUrl: imageUrls[_selectedImageIndex.clamp(0, imageUrls.length - 1)],
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),

                        // Top-Left Badge (Bestseller / 100% Organic)
                        Positioned(
                          top: 14,
                          left: 14,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
                              ),
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
                            ),
                            child: Row(
                              children: const [
                                Icon(Icons.local_fire_department_rounded, color: Colors.white, size: 14),
                                SizedBox(width: 4),
                                Text(
                                  'Bestseller',
                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Top-Right Floating Actions (Wishlist, Share, Zoom)
                        Positioned(
                          top: 14,
                          right: 14,
                          child: Column(
                            children: [
                              _buildCircularImageAction(
                                icon: isWishlisted ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                color: isWishlisted ? const Color(0xFFEF4444) : const Color(0xFF334155),
                                onTap: () => ref.read(wishlistProvider.notifier).toggleWishlist(p.id),
                              ),
                              const SizedBox(height: 8),
                              _buildCircularImageAction(
                                icon: Icons.share_outlined,
                                color: const Color(0xFF334155),
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('🔗 Link copied to clipboard!')),
                                  );
                                },
                              ),
                              const SizedBox(height: 8),
                              _buildCircularImageAction(
                                icon: Icons.zoom_in_rounded,
                                color: const Color(0xFF334155),
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => Dialog(
                                      backgroundColor: Colors.transparent,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(16),
                                        child: ProductImageWidget(
                                          imageUrl: imageUrls[_selectedImageIndex.clamp(0, imageUrls.length - 1)],
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Thumbnails Strip
                  SizedBox(
                    height: 65,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: imageUrls.length + 1,
                      itemBuilder: (context, index) {
                        if (index == imageUrls.length) {
                          return Container(
                            width: 65,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEEF2FF),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFC7D2FE)),
                            ),
                            child: const Center(
                              child: Text(
                                '+3\nMore',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF4F46E5)),
                              ),
                            ),
                          );
                        }

                        final bool isSelected = _selectedImageIndex == index;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedImageIndex = index),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 65,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected ? const Color(0xFF4F46E5) : const Color(0xFFE2E8F0),
                                width: isSelected ? 2.5 : 1,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: ProductImageWidget(
                                imageUrl: imageUrls[index],
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Live Social Proof Banner
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFFCA5A5)),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.visibility_rounded, color: Color(0xFFEF4444), size: 16),
                        SizedBox(width: 8),
                        Text(
                          '1.5K people viewed this in last 24 hours',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFB91C1C)),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 2. Product Title, Subtitle, Ratings & Price
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          p.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF0F172A),
                            height: 1.25,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          p.tagline ?? 'Purifies skin & fights acne for a natural glow',
                          style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                        ),

                        const SizedBox(height: 10),

                        // Rating Bar & Sales Proof
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF4F46E5),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                children: const [
                                  Text(
                                    '4.8',
                                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                                  ),
                                  SizedBox(width: 3),
                                  Icon(Icons.star_rounded, color: Color(0xFFF59E0B), size: 12),
                                ],
                              ),
                            ),
                            const SizedBox(width: 6),
                            Row(
                              children: List.generate(
                                5,
                                (i) => const Icon(Icons.star_rounded, color: Color(0xFFF59E0B), size: 14),
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              '(256 Reviews)',
                              style: TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        Row(
                          children: const [
                            Icon(Icons.trending_up_rounded, color: Color(0xFF10B981), size: 16),
                            SizedBox(width: 4),
                            Text(
                              '1K+ bought in past month',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF047857)),
                            ),
                          ],
                        ),

                        const SizedBox(height: 14),
                        const Divider(color: Color(0xFFF1F5F9)),
                        const SizedBox(height: 10),

                        // Price & Discount Row
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              '₹${price.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (mrp > price) ...[
                              Text(
                                '₹${mrp.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF94A3B8),
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEEF2FF),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  '$discountPct% OFF',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFF4F46E5),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        const Text('Inclusive of all taxes', style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 3. Variant Selector (Select Size)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Select Size', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                            InkWell(
                              onTap: () => _showSizeGuideModal(context),
                              child: Row(
                                children: const [
                                  Icon(Icons.straighten_rounded, size: 14, color: Color(0xFF4F46E5)),
                                  SizedBox(width: 4),
                                  Text('Size Guide', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF4F46E5))),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        Row(
                          children: List.generate(variants.length, (idx) {
                            final varItem = variants[idx];
                            final bool isSelected = _selectedVariantIndex == idx;

                            return Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => _selectedVariantIndex = idx),
                                child: Container(
                                  margin: EdgeInsets.only(right: idx < variants.length - 1 ? 8 : 0),
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  decoration: BoxDecoration(
                                    color: isSelected ? const Color(0xFFEEF2FF) : Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isSelected ? const Color(0xFF4F46E5) : const Color(0xFFE2E8F0),
                                      width: isSelected ? 2 : 1,
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Text(
                                        varItem.sizeLabel,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: isSelected ? const Color(0xFF4F46E5) : const Color(0xFF0F172A),
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '₹${varItem.price.toStringAsFixed(0)}',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: isSelected ? const Color(0xFF4F46E5) : const Color(0xFF64748B),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 4. 4 Key Product Benefits Grid
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF2FF).withOpacity(0.5),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFC7D2FE)),
                    ),
                    child: GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      childAspectRatio: 2.5,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      children: [
                        _buildBenefitTile('🌱 100% Ayurvedic', 'Natural & Safe'),
                        _buildBenefitTile('🐰 Cruelty Free', 'No Animal Testing'),
                        _buildBenefitTile('🧪 Paraben Free', 'No Harmful Chemicals'),
                        _buildBenefitTile('🩺 Derm Tested', 'Tested for Safety'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 5. "Save More with Combos" Box
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAF5FF),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE9D5FF)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: const [
                                Text('🎁', style: TextStyle(fontSize: 16)),
                                SizedBox(width: 6),
                                Text(
                                  'Save More with Combos',
                                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF581C87)),
                                ),
                              ],
                            ),
                            InkWell(
                              onTap: () => context.push('/shop'),
                              child: const Text('View All >', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF7E22CE))),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.asset('assets/images/shampoo.jpg', height: 50, width: 50, fit: BoxFit.cover),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text('Neem Face Wash + Toner + Moisturizer', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                                  SizedBox(height: 2),
                                  Text('₹699  ₹997  (30% OFF)', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF7E22CE))),
                                ],
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                ref.read(cartProvider.notifier).addItem(product: p, variant: v, quantity: 1);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('✨ Combo bundle added to cart!'), backgroundColor: Color(0xFF10B981)),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF7E22CE),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: const Text('Add Combo', style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 6. Benefits Circle Icons Strip
                  SizedBox(
                    height: 85,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _buildCircleBenefit('🥊', 'Fights Acne\n& Pimples'),
                        _buildCircleBenefit('💧', 'Controls\nExcess Oil'),
                        _buildCircleBenefit('✨', 'Deep Cleansing\nFormula'),
                        _buildCircleBenefit('🌿', 'Soothes &\nHydrates Skin'),
                        _buildCircleBenefit('💖', 'For All\nSkin Types'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 7. Pincode Delivery Estimator & Trust Strip
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.location_on_rounded, color: Color(0xFF4F46E5), size: 18),
                            const SizedBox(width: 6),
                            const Text('Deliver to: ', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                            Text(
                              '$_pincodeLocation (${_pincodeController.text})',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                            ),
                            const Spacer(),
                            const Text('Delivery by Tomorrow, 17 May', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF10B981))),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildMiniTrustBadge('🚚', 'Free Shipping\nAbove ₹999'),
                            _buildMiniTrustBadge('💵', 'COD\nAvailable'),
                            _buildMiniTrustBadge('🔄', 'Easy Returns\nWithin 7 Days'),
                            _buildMiniTrustBadge('🛡️', '100% Secure\nPayment'),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 8. Content Tabs (Description, Ingredients, How to Use, Reviews, FAQs)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      children: [
                        // Tab Strip Header
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: ['Description', 'Ingredients', 'How to Use', 'Reviews (256)', 'FAQs'].map((tab) {
                              final bool isSelected = _activeTab == tab;
                              return GestureDetector(
                                onTap: () => setState(() => _activeTab = tab),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: isSelected ? const Color(0xFF4F46E5) : Colors.transparent,
                                        width: 2.5,
                                      ),
                                    ),
                                  ),
                                  child: Text(
                                    tab,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                                      color: isSelected ? const Color(0xFF4F46E5) : const Color(0xFF64748B),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        const Divider(height: 1, color: Color(0xFFE2E8F0)),

                        // Tab Body Content
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: _buildActiveTabContent(p),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),

            // Footer
            const VaidyamFooterWidget(),
          ],
        ),
      ),

      // 9. ⭐ Floating Bottom Sticky Action Bar (Add to Cart & Buy Now)
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              // Quantity Stepper
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove, size: 16, color: Color(0xFF334155)),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      onPressed: () {
                        if (_quantity > 1) setState(() => _quantity--);
                      },
                    ),
                    Text('$_quantity', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900)),
                    IconButton(
                      icon: const Icon(Icons.add, size: 16, color: Color(0xFF334155)),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      onPressed: () => setState(() => _quantity++),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),

              // Add to Cart Outlined Button
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    ref.read(cartProvider.notifier).addItem(
                          product: p,
                          variant: v,
                          quantity: _quantity,
                        );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('🛒 ${_quantity}x ${p.name} added to cart!'),
                        backgroundColor: const Color(0xFF10B981),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  icon: const Icon(Icons.shopping_cart_outlined, size: 16, color: Color(0xFF4F46E5)),
                  label: const Text('Add to Cart', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF4F46E5))),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF4F46E5), width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Buy Now Solid Button
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    ref.read(cartProvider.notifier).addItem(
                          product: p,
                          variant: v,
                          quantity: _quantity,
                        );
                    context.push('/checkout');
                  },
                  icon: const Icon(Icons.bolt_rounded, size: 16, color: Colors.white),
                  label: const Text('Buy Now', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4F46E5),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCircularImageAction({required IconData icon, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
        ),
        child: Icon(icon, color: color, size: 16),
      ),
    );
  }

  Widget _buildBenefitTile(String title, String sub) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
          Text(sub, style: const TextStyle(fontSize: 9, color: Color(0xFF64748B))),
        ],
      ),
    );
  }

  Widget _buildCircleBenefit(String emoji, String title) {
    return Padding(
      padding: const EdgeInsets.only(right: 14),
      child: Column(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: const Color(0xFFEEF2FF),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFC7D2FE)),
            ),
            child: Center(child: Text(emoji, style: const TextStyle(fontSize: 20))),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF334155), height: 1.1),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniTrustBadge(String emoji, String text) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 18)),
        const SizedBox(height: 2),
        Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
        ),
      ],
    );
  }

  Widget _buildActiveTabContent(ProductModel p) {
    switch (_activeTab) {
      case 'Ingredients':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('🌿 Pure Herbal Ingredients:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
            const SizedBox(height: 8),
            Text(
              p.ingredients.isNotEmpty
                  ? p.ingredients
                  : 'Neem Leaf Extract (Azadirachta Indica), Organic Turmeric Root (Curcuma Longa), Pure Aloe Vera Juice, Tea Tree Essential Oil, Purified Aqua.',
              style: const TextStyle(fontSize: 12, color: Color(0xFF475569), height: 1.5),
            ),
          ],
        );

      case 'How to Use':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('💆 Steps for Best Results:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
            const SizedBox(height: 10),
            _buildStepRow('1', 'Splash face with lukewarm water'),
            _buildStepRow('2', 'Pump small quantity onto palm and lather gently'),
            _buildStepRow('3', 'Massage in circular motion over face for 60 seconds'),
            _buildStepRow('4', 'Rinse thoroughly & pat dry with a soft towel'),
          ],
        );

      case 'Reviews (256)':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Column(
                  children: const [
                    Text('4.8', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
                    Text('Based on 256 reviews', style: TextStyle(fontSize: 9, color: Color(0xFF64748B))),
                  ],
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    children: [
                      _buildRatingBar('5★', 0.70),
                      _buildRatingBar('4★', 0.20),
                      _buildRatingBar('3★', 0.07),
                      _buildRatingBar('2★', 0.02),
                      _buildRatingBar('1★', 0.01),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // User Photo Submissions
            const Text('📸 Customer Photo Reviews:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
            const SizedBox(height: 8),
            Row(
              children: [
                ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.asset('assets/images/facewash.jpg', width: 60, height: 60, fit: BoxFit.cover)),
                const SizedBox(width: 8),
                ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.asset('assets/images/shampoo.jpg', width: 60, height: 60, fit: BoxFit.cover)),
                const SizedBox(width: 8),
                ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.asset('assets/images/soap.jpg', width: 60, height: 60, fit: BoxFit.cover)),
              ],
            ),

            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _showWriteReviewModal(context),
                icon: const Icon(Icons.edit_outlined, size: 14, color: Color(0xFF4F46E5)),
                label: const Text('Write a Review', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF4F46E5))),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF4F46E5)),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ],
        );

      case 'FAQs':
        return Column(
          children: const [
            ExpansionTile(
              title: Text('Is this suitable for daily use?', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              children: [Padding(padding: EdgeInsets.all(8), child: Text('Yes! It is 100% gentle and formulated for daily morning & night use.', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))))],
            ),
            ExpansionTile(
              title: Text('Does it cause skin dryness?', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              children: [Padding(padding: EdgeInsets.all(8), child: Text('No, pure Aloe Vera maintains natural skin moisture after every wash.', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))))],
            ),
          ],
        );

      case 'Description':
      default:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              p.description.isNotEmpty
                  ? p.description
                  : '${p.name} is an Ayurvedic formulation designed to deeply cleanse your skin, remove impurities and control excess oil naturally. Infused with pure Neem & Aloe Vera extracts.',
              maxLines: _isDescriptionExpanded ? 100 : 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, color: Color(0xFF475569), height: 1.5),
            ),
            const SizedBox(height: 6),
            InkWell(
              onTap: () => setState(() => _isDescriptionExpanded = !_isDescriptionExpanded),
              child: Text(
                _isDescriptionExpanded ? 'Read Less ^' : 'Read More v',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF4F46E5)),
              ),
            ),
          ],
        );
    }
  }

  Widget _buildStepRow(String step, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 10,
            backgroundColor: const Color(0xFFEEF2FF),
            child: Text(step, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF4F46E5))),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 12, color: Color(0xFF475569)))),
        ],
      ),
    );
  }

  Widget _buildRatingBar(String label, double val) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontSize: 10, color: Color(0xFF64748B))),
          const SizedBox(width: 6),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: val,
                minHeight: 6,
                backgroundColor: const Color(0xFFF1F5F9),
                color: const Color(0xFF4F46E5),
              ),
            ),
          ),
          const SizedBox(width: 6),
          Text('${(val * 100).round()}%', style: const TextStyle(fontSize: 9, color: Color(0xFF94A3B8))),
        ],
      ),
    );
  }
}
