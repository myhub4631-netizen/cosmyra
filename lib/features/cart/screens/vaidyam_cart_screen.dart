import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../controllers/cart_controller.dart';
import '../../catalog/repositories/product_repository.dart';
import '../../catalog/widgets/product_image_widget.dart';
import '../../navigation/widgets/vaidyam_footer_widget.dart';
import '../../navigation/widgets/vaidyam_mobile_bottom_nav_bar.dart';

class VaidyamCartScreen extends ConsumerStatefulWidget {
  const VaidyamCartScreen({super.key});

  @override
  ConsumerState<VaidyamCartScreen> createState() => _VaidyamCartScreenState();
}

class _VaidyamCartScreenState extends ConsumerState<VaidyamCartScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedSearchCategory = 'All Categories';

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartProvider);
    final wishlist = ref.watch(wishlistProvider);
    final products = ref.watch(adminProductsProvider);

    // Build cart items list strictly from cartState.items
    final List<Map<String, dynamic>> itemsList = cartState.items.asMap().entries.map((entry) {
      final item = entry.value;
      return <String, dynamic>{
        'id': item.product.id,
        'name': item.product.name,
        'category': item.product.categoryId,
        'variant': item.variant.sizeLabel.isNotEmpty
            ? item.variant.sizeLabel
            : 'Default Variant',
        'price': item.variant.price,
        'mrp': item.variant.mrp,
        'quantity': item.quantity,
        'image': item.product.imageUrls.isNotEmpty
            ? item.product.imageUrls.first
            : '',
        'rawItem': item,
        'index': entry.key,
      };
    }).toList();

    // Calculate totals
    double subtotal = 0;
    double totalMrp = 0;
    int itemCount = 0;
    for (var item in itemsList) {
      final price = (item['price'] as num).toDouble();
      final mrp = (item['mrp'] as num).toDouble();
      final qty = (item['quantity'] as num).toInt();
      subtotal += price * qty;
      totalMrp += mrp * qty;
      itemCount += qty;
    }

    final double discount = (totalMrp - subtotal) > 0 ? (totalMrp - subtotal) : 0.0;
    final double finalTotal = (subtotal - discount).clamp(0, double.infinity);
    final bool freeShipping = subtotal >= 499;

    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth > 950;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      bottomNavigationBar: screenWidth <= 768 ? const VaidyamMobileBottomNavBar(activeTab: 'Cart') : null,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ─── 1. TOP ANNOUNCEMENT BAR ───
            Container(
              width: double.infinity,
              color: const Color(0xFF4338CA),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 9),
              child: Row(
                children: [
                  const Icon(Icons.local_shipping_outlined,
                      color: Colors.white, size: 15),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Free Shipping on orders over ₹999',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isWide)
                    Row(
                      children: const [
                        Icon(Icons.facebook, color: Colors.white, size: 15),
                        SizedBox(width: 12),
                        Icon(Icons.camera_alt_outlined,
                            color: Colors.white, size: 15),
                        SizedBox(width: 12),
                        Icon(Icons.play_circle_outline,
                            color: Colors.white, size: 15),
                      ],
                    ),
                ],
              ),
            ),

            // ─── 2. MAIN HEADER BAR ───
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
              child: Row(
                children: [
                  // Brand logo
                  InkWell(
                    onTap: () => context.go('/'),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4338CA),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.shopping_bag_outlined,
                              color: Colors.white, size: 22),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Cosmyra',
                          style: TextStyle(
                            fontFamily: 'serif',
                            fontSize: isWide ? 22 : 18,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF1F2937),
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // Search bar (desktop)
                  if (isWide)
                    Container(
                      width: 440,
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFD1D5DB)),
                      ),
                      child: Row(
                        children: [
                          // Category dropdown
                          Container(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 12),
                            decoration: const BoxDecoration(
                              border: Border(
                                  right:
                                      BorderSide(color: Color(0xFFD1D5DB))),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedSearchCategory,
                                style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF374151),
                                    fontWeight: FontWeight.w500),
                                icon: const Icon(Icons.keyboard_arrow_down,
                                    size: 16, color: Color(0xFF6B7280)),
                                items: [
                                  'All Categories',
                                  'Headphones',
                                  'Smart Watches',
                                  'Footwear',
                                  'Skincare',
                                  'Haircare',
                                  'Wellness'
                                ]
                                    .map((c) => DropdownMenuItem(
                                        value: c, child: Text(c)))
                                    .toList(),
                                onChanged: (val) => setState(() =>
                                    _selectedSearchCategory =
                                        val ?? 'All Categories'),
                              ),
                            ),
                          ),
                          // Search input
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              decoration: const InputDecoration(
                                hintText:
                                    'Search for products, brands and more...',
                                hintStyle: TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF9CA3AF)),
                                border: InputBorder.none,
                                contentPadding:
                                    EdgeInsets.symmetric(horizontal: 12),
                              ),
                            ),
                          ),
                          // Search button
                          InkWell(
                            onTap: () => context.go('/explore'),
                            child: Container(
                              width: 42,
                              height: 42,
                              decoration: const BoxDecoration(
                                color: Color(0xFF4338CA),
                                borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(7),
                                  bottomRight: Radius.circular(7),
                                ),
                              ),
                              child: const Icon(Icons.search,
                                  color: Colors.white, size: 20),
                            ),
                          ),
                        ],
                      ),
                    ),

                  const Spacer(),

                  // Header actions: Wishlist / Cart / Account
                  Row(
                    children: [
                      _headerAction(
                        icon: Icons.favorite_border,
                        label: 'Wishlist',
                        badgeCount: wishlist.length,
                        onTap: () => context.go('/wishlist'),
                      ),
                      const SizedBox(width: 22),
                      _headerAction(
                        icon: Icons.shopping_cart_outlined,
                        label: 'Cart',
                        badgeCount: itemCount,
                        isActive: true,
                        onTap: () => context.go('/cart'),
                      ),
                      const SizedBox(width: 22),
                      _headerAction(
                        icon: Icons.person_outline,
                        label: 'Account',
                        onTap: () => context.go('/dashboard'),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ─── 3. NAVIGATION BAR ───
            Container(
              color: Colors.white,
              padding: const EdgeInsets.only(
                  left: 28, right: 28, top: 2, bottom: 12),
              child: Row(
                children: [
                  // "All Categories" pill button
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4338CA),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.menu, color: Colors.white, size: 16),
                        SizedBox(width: 8),
                        Text('All Categories',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w600)),
                        SizedBox(width: 8),
                        Icon(Icons.keyboard_arrow_down,
                            color: Colors.white, size: 16),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                  // Nav links
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _navLink('Home', () => context.go('/')),
                          _navLink('Shop', () => context.go('/explore')),
                          _navLink(
                              'Categories', () => context.go('/explore')),
                          _navLink('Deals', () => context.go('/explore')),
                          _navLink(
                              'New Arrivals', () => context.go('/explore')),
                          _navLink(
                              'Best Sellers', () => context.go('/explore')),
                          _navLink('Brands', () => context.go('/explore')),
                          _navLink('Blog', () {}),
                          _navLink('Contact', () {}),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1, color: Color(0xFFE5E7EB)),

            const SizedBox(height: 28),

            // ─── 4. PAGE TITLE ───
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: RichText(
                      text: TextSpan(
                        children: [
                          const TextSpan(
                            text: 'Shopping Cart ',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF111827),
                            ),
                          ),
                          TextSpan(
                            text: '($itemCount Items)',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ─── 5. MAIN 2-COLUMN LAYOUT ───
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: isWide
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Left: Cart Items Table
                            Expanded(
                              child: _buildCartTable(
                                  context, itemsList, true),
                            ),
                            const SizedBox(width: 28),
                            // Right: Order Summary
                            SizedBox(
                              width: 340,
                              child: _buildOrderSummary(
                                context,
                                subtotal: subtotal,
                                discount: discount,
                                finalTotal: finalTotal,
                                freeShipping: freeShipping,
                                itemCount: itemCount,
                              ),
                            ),
                          ],
                        )
                      : Column(
                          children: [
                            _buildCartTable(context, itemsList, true),
                            const SizedBox(height: 24),
                            _buildOrderSummary(
                              context,
                              subtotal: subtotal,
                              discount: discount,
                              finalTotal: finalTotal,
                              freeShipping: freeShipping,
                              itemCount: itemCount,
                            ),
                          ],
                        ),
                ),
              ),
            ),

            const SizedBox(height: 60),
            const VaidyamFooterWidget(),
          ],
        ),
      ),
    );
  }

  // ════════════════════════════════════════════
  //  HEADER ACTION ICON (Wishlist/Cart/Account)
  // ════════════════════════════════════════════
  Widget _headerAction({
    required IconData icon,
    required String label,
    int badgeCount = 0,
    bool isActive = false,
    required VoidCallback onTap,
  }) {
    final color = isActive ? const Color(0xFF4338CA) : const Color(0xFF374151);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Badge(
            isLabelVisible: badgeCount > 0,
            label: Text('$badgeCount',
                style: const TextStyle(fontSize: 10, color: Colors.white)),
            backgroundColor: const Color(0xFF4338CA),
            child: Icon(icon, size: 22, color: color),
          ),
          const SizedBox(height: 3),
          Text(label,
              style: TextStyle(
                  fontSize: 11, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════
  //  NAVIGATION LINK
  // ════════════════════════════════════════════
  Widget _navLink(String label, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 28),
      child: InkWell(
        onTap: onTap,
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
      ),
    );
  }

  // ════════════════════════════════════════════
  //  LEFT COLUMN — CART ITEMS TABLE
  // ════════════════════════════════════════════
  Widget _buildCartTable(BuildContext context,
      List<Map<String, dynamic>> itemsList, bool usingRealCart) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          // Table Scrollable Container with fixed width columns (No Expanded inside unbounded constraints)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Table Header ──
                  Container(
                    width: 720,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 14),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(11),
                        topRight: Radius.circular(11),
                      ),
                      border:
                          Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
                    ),
                    child: Row(
                      children: const [
                        SizedBox(
                            width: 300,
                            child: Text('Product',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF374151)))),
                        SizedBox(
                            width: 100,
                            child: Center(
                                child: Text('Price',
                                    style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF374151))))),
                        SizedBox(
                            width: 120,
                            child: Center(
                                child: Text('Quantity',
                                    style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF374151))))),
                        SizedBox(
                            width: 100,
                            child: Center(
                                child: Text('Total',
                                    style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF374151))))),
                        SizedBox(
                            width: 50,
                            child: Center(
                                child: Text('Action',
                                    style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF374151))))),
                      ],
                    ),
                  ),

                  // ── Item Rows ──
                  if (itemsList.isEmpty)
                    Container(
                      width: 720,
                      padding: const EdgeInsets.all(40),
                      child: const Center(
                        child: Text(
                          'Your cart is currently empty.',
                          style: TextStyle(
                              fontSize: 14, color: Color(0xFF6B7280)),
                        ),
                      ),
                    )
                  else
                    ...itemsList.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final item = entry.value;
                      final isLast = idx == itemsList.length - 1;

                      final String name = item['name'] ?? 'Product';
                      final String category = item['category'] ?? '';
                      final String variant = item['variant'] ?? '';
                      final double price = (item['price'] as num).toDouble();
                      final double mrp = (item['mrp'] as num).toDouble();
                      final int quantity = (item['quantity'] as num).toInt();
                      final String imageUrl = item['image'] ?? '';

                      return Container(
                        width: 720,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 18),
                        decoration: BoxDecoration(
                          border: isLast
                              ? null
                              : const Border(
                                  bottom:
                                      BorderSide(color: Color(0xFFF3F4F6))),
                        ),
                        child: Row(
                          children: [
                            // ── Product Column ──
                            SizedBox(
                              width: 300,
                              child: Row(
                                children: [
                                  // Product image container with ProductImageWidget
                                  Container(
                                    width: 70,
                                    height: 70,
                                    clipBehavior: Clip.antiAlias,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF3F4F6),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: ProductImageWidget(
                                      imageUrl: imageUrl,
                                      fit: BoxFit.contain,
                                      width: 70,
                                      height: 70,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  // Product details
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          name,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF111827),
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        if (category.isNotEmpty) ...[
                                          const SizedBox(height: 3),
                                          Text(
                                            category,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Color(0xFF6B7280),
                                            ),
                                          ),
                                        ],
                                        if (variant.isNotEmpty) ...[
                                          const SizedBox(height: 3),
                                          Text(
                                            variant,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Color(0xFF9CA3AF),
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // ── Price Column ──
                            SizedBox(
                              width: 100,
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '₹${price.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF111827),
                                      ),
                                    ),
                                    if (mrp > price)
                                      Text(
                                        '₹${mrp.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF9CA3AF),
                                          decoration:
                                              TextDecoration.lineThrough,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),

                            // ── Quantity Column ──
                            SizedBox(
                              width: 120,
                              child: Center(
                                child: Container(
                                  height: 36,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                        color: const Color(0xFFD1D5DB)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // Minus
                                      InkWell(
                                        onTap: () {
                                          if (item['index'] != null) {
                                            ref
                                                .read(cartProvider.notifier)
                                                .updateQuantity(
                                                    item['index'] as int,
                                                    quantity - 1);
                                          }
                                        },
                                        child: Container(
                                          width: 32,
                                          height: 36,
                                          alignment: Alignment.center,
                                          decoration: const BoxDecoration(
                                            border: Border(
                                                right: BorderSide(
                                                    color: Color(0xFFD1D5DB))),
                                          ),
                                          child: const Text('–',
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                  color: Color(0xFF374151))),
                                        ),
                                      ),
                                      // Count
                                      Container(
                                        width: 36,
                                        alignment: Alignment.center,
                                        child: Text(
                                          '$quantity',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF111827),
                                          ),
                                        ),
                                      ),
                                      // Plus
                                      InkWell(
                                        onTap: () {
                                          if (item['index'] != null) {
                                            ref
                                                .read(cartProvider.notifier)
                                                .updateQuantity(
                                                    item['index'] as int,
                                                    quantity + 1);
                                          }
                                        },
                                        child: Container(
                                          width: 32,
                                          height: 36,
                                          alignment: Alignment.center,
                                          decoration: const BoxDecoration(
                                            border: Border(
                                                left: BorderSide(
                                                    color: Color(0xFFD1D5DB))),
                                          ),
                                          child: const Text('+',
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                  color: Color(0xFF374151))),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            // ── Total Column ──
                            SizedBox(
                              width: 100,
                              child: Center(
                                child: Text(
                                  '₹${(price * quantity).toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF111827),
                                  ),
                                ),
                              ),
                            ),

                            // ── Action (Delete) Column ──
                            SizedBox(
                              width: 50,
                              child: Center(
                                child: InkWell(
                                  onTap: () {
                                    if (item['index'] != null) {
                                      ref
                                          .read(cartProvider.notifier)
                                          .removeItem(item['index'] as int);
                                    }
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content:
                                              Text('Removed $name from cart')),
                                    );
                                  },
                                  borderRadius: BorderRadius.circular(6),
                                  child: Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                          color: const Color(0xFFE5E7EB)),
                                    ),
                                    child: const Icon(Icons.delete_outline,
                                        size: 18, color: Color(0xFF6B7280)),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                ],
              ),
            ),
          ),

          // ── Bottom Action Bar ──
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Continue Shopping
                OutlinedButton.icon(
                  onPressed: () => context.go('/explore'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 14),
                    side: const BorderSide(color: Color(0xFFD1D5DB)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  icon: const Icon(Icons.arrow_back,
                      size: 16, color: Color(0xFF374151)),
                  label: const Text('Continue Shopping',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF374151))),
                ),
                // Clear Cart
                OutlinedButton(
                  onPressed: () {
                    ref.read(cartProvider.notifier).clearCart();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Cart cleared')),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 14),
                    side: const BorderSide(color: Color(0xFFD1D5DB)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Clear Cart',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF374151))),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════
  //  RIGHT COLUMN — ORDER SUMMARY
  // ════════════════════════════════════════════
  Widget _buildOrderSummary(
    BuildContext context, {
    required double subtotal,
    required double discount,
    required double finalTotal,
    required bool freeShipping,
    required int itemCount,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          const Text(
            'Order Summary',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Color(0xFF111827),
            ),
          ),

          const SizedBox(height: 24),

          // Subtotal
          _summaryRow(
            'Subtotal ($itemCount Items)',
            '₹${subtotal.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
          ),
          const SizedBox(height: 14),

          // Discount
          _summaryRow(
            'Discount',
            '-₹${discount.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
            valueColor: const Color(0xFFDC2626),
          ),
          const SizedBox(height: 14),

          // Shipping
          _summaryRow(
            'Shipping',
            freeShipping ? 'Free' : '₹49',
            valueColor: const Color(0xFF16A34A),
          ),

          const SizedBox(height: 18),
          const Divider(color: Color(0xFFE5E7EB), height: 1),
          const SizedBox(height: 18),

          // Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Total',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF111827),
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    '(Inclusive of all taxes)',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
                ],
              ),
              Text(
                '₹${finalTotal.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF111827),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Proceed to Checkout button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () => context.go('/checkout'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4338CA),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text(
                'Proceed to Checkout',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Trust badges
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _trustBadge(Icons.verified_user_outlined, '100% Secure',
                  'Payment'),
              _trustBadge(
                  Icons.published_with_changes, 'Easy', 'Returns'),
              _trustBadge(Icons.headset_mic_outlined, '24/7', 'Support'),
            ],
          ),
        ],
      ),
    );
  }

  // ── Summary Row ──
  Widget _summaryRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF6B7280),
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: valueColor ?? const Color(0xFF111827),
          ),
        ),
      ],
    );
  }

  // ── Trust Badge ──
  Widget _trustBadge(IconData icon, String line1, String line2) {
    return Column(
      children: [
        Icon(icon, size: 22, color: const Color(0xFF374151)),
        const SizedBox(height: 6),
        Text(line1,
            style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Color(0xFF374151)),
            textAlign: TextAlign.center),
        Text(line2,
            style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
            textAlign: TextAlign.center),
      ],
    );
  }
}
