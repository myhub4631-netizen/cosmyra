import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../config/theme/app_colors.dart';
import '../../cart/controllers/cart_controller.dart';
import '../repositories/product_repository.dart';

class VaidyamHomeScreen extends ConsumerStatefulWidget {
  const VaidyamHomeScreen({super.key});

  @override
  ConsumerState<VaidyamHomeScreen> createState() => _VaidyamHomeScreenState();
}

class _VaidyamHomeScreenState extends ConsumerState<VaidyamHomeScreen> {
  String _selectedSearchCategory = 'All Categories';
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, String>> _categories = [
    {'title': 'Haircare', 'icon': '💇', 'asset': 'assets/images/shampoo.jpg'},
    {'title': 'Skincare', 'icon': '✨', 'asset': 'assets/images/facewash.jpg'},
    {'title': 'Soaps & Bar', 'icon': '🧴', 'asset': 'assets/images/soap.jpg'},
    {'title': 'Wellness Oils', 'icon': '🌿', 'asset': 'assets/images/soap.jpg'},
    {'title': 'Elixirs', 'icon': '🌸', 'asset': 'assets/images/shampoo.jpg'},
    {'title': 'Gift Combos', 'icon': '🎁', 'asset': 'assets/images/soap.jpg'},
    {'title': 'Hydration', 'icon': '💧', 'asset': 'assets/images/facewash.jpg'},
    {'title': 'Body Care', 'icon': '🍃', 'asset': 'assets/images/soap.jpg'},
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
    final productsAsync = ref.watch(productsFutureProvider);
    final totalCartCount = cartState.totalItemCount;

    return SingleChildScrollView(
      child: Column(
        children: [
          // 1. Top Announcement Bar
          Container(
            width: double.infinity,
            color: const Color(0xFF4F46E5), // Vibrant Purple
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Free Shipping on orders over ₹499 • 100% Certified Organic Botanicals',
                  style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                ),
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

                // Category Search Input Bar
                Container(
                  width: 520,
                  height: 46,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: Row(
                    children: [
                      // Category Dropdown
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

                      // Text Field
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: const InputDecoration(
                            hintText: 'Search for products, formulations, ingredients...',
                            hintStyle: TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 12),
                          ),
                        ),
                      ),

                      // Search Icon Button
                      InkWell(
                        onTap: () {
                          ref.read(searchQueryProvider.notifier).state = _searchController.text;
                          context.go('/explore');
                        },
                        child: Container(
                          width: 46,
                          height: 46,
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

                // Header Utility Shortcuts (Wishlist, Cart, Account)
                Row(
                  children: [
                    // Wishlist Shortcut
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
                    const SizedBox(width: 24),

                    // Cart Shortcut
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
                    const SizedBox(width: 24),

                    // Account / Master Admin Access
                    InkWell(
                      onTap: () => context.go('/admin'),
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

          // 3. Category Navigation Bar (Vibrant Purple Dropdown & Links)
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Row(
              children: [
                // All Categories Pill Button
                InkWell(
                  onTap: () => context.go('/explore'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6366F1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.menu, color: Colors.white, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'All Categories',
                          style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(width: 16),
                        Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 18),
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: 24),

                // Navigation Bar Links
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildNavLink('Home ⌵', isSelected: true, onTap: () => context.go('/')),
                        _buildNavLink('Shop', onTap: () => context.go('/explore')),
                        _buildNavLink('Categories ⌵', onTap: () => context.go('/explore')),
                        _buildNavLink('Subscribe & Save', onTap: () => context.go('/subscriptions')),
                        _buildNavLink('New Arrivals', onTap: () => context.go('/explore')),
                        _buildNavLink('Best Sellers', onTap: () => context.go('/explore')),
                        _buildNavLink('Ayurvedic Brands', onTap: () => context.go('/explore')),
                        _buildNavLink('Botanical Blog', onTap: () {}),
                        _buildNavLink('Contact Us', onTap: () {}),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // 4. Hero Banner Section (Soft Lavender Backdrop)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFF3E8FF), Color(0xFFF8FAFC), Color(0xFFFAF5FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'NEW ARRIVALS',
                        style: TextStyle(color: Color(0xFF6366F1), fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1.5),
                      ),
                      const SizedBox(height: 12),
                      RichText(
                        text: const TextSpan(
                          children: [
                            TextSpan(
                              text: 'Botanical Radiance\nCollection Up to ',
                              style: TextStyle(fontFamily: 'serif', fontSize: 36, fontWeight: FontWeight.w900, color: Color(0xFF1E2621), height: 1.2),
                            ),
                            TextSpan(
                              text: '40% Off',
                              style: TextStyle(fontFamily: 'serif', fontSize: 36, fontWeight: FontWeight.w900, color: Color(0xFF6366F1), height: 1.2),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'Discover handcrafted Ayurvedic formulations for scalp defense, skin glow & daily wellness.',
                        style: TextStyle(fontSize: 14, color: Color(0xFF4B5563)),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: () => context.go('/explore'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6366F1),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text('Shop Now', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          ),
                          const SizedBox(width: 14),
                          OutlinedButton(
                            onPressed: () => context.go('/explore'),
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF374151),
                              side: const BorderSide(color: Color(0xFFE5E7EB)),
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text('Explore Deals', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 30),

                // Hero Image Graphic
                Container(
                  width: 340,
                  height: 240,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    image: const DecorationImage(
                      image: AssetImage('assets/images/shampoo.jpg'),
                      fit: BoxFit.cover,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.purple.withValues(alpha: 0.15),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // 5. Trust Feature Bar (4 Value Proposition Cards)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFF3F4F6)),
            ),
            child: Row(
              children: [
                _buildTrustCard(Icons.local_shipping_outlined, 'Free Shipping', 'On orders over ₹499'),
                _buildTrustCard(Icons.replay_outlined, 'Easy Returns', '30 days return policy'),
                _buildTrustCard(Icons.lock_outline, 'Secure Payment', '100% secure checkout'),
                _buildTrustCard(Icons.headset_mic_outlined, '24/7 Support', 'Dedicated botanical support'),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // 6. Shop By Categories (Circular Grid)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Shop By Categories',
                      style: TextStyle(fontFamily: 'serif', fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
                    ),
                    TextButton(
                      onPressed: () => context.go('/explore'),
                      child: const Text('View All', style: TextStyle(color: Color(0xFF6366F1), fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _categories.map((cat) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 20),
                        child: InkWell(
                          onTap: () => context.go('/explore'),
                          child: Column(
                            children: [
                              Container(
                                width: 90,
                                height: 90,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF3F4F6),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: const Color(0xFFE5E7EB)),
                                  image: DecorationImage(
                                    image: AssetImage(cat['asset']!),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                cat['title']!,
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF374151)),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 36),

          // 7. Featured Formulations Showcase
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Bestselling Botanical Formulations',
                      style: TextStyle(fontFamily: 'serif', fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
                    ),
                    TextButton(
                      onPressed: () => context.go('/explore'),
                      child: const Text('Explore Catalog', style: TextStyle(color: Color(0xFF6366F1), fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                productsAsync.when(
                  data: (products) {
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 280,
                        mainAxisExtent: 340,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final p = products[index];
                        final v = p.defaultVariant;

                        return Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: const BorderSide(color: Color(0xFFE5E7EB)),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF8FAFC),
                                      borderRadius: BorderRadius.circular(8),
                                      image: DecorationImage(
                                        image: (p.imageUrls.isNotEmpty && p.imageUrls.first.startsWith('http'))
                                            ? NetworkImage(p.imageUrls.first) as ImageProvider
                                            : AssetImage(p.imageUrls.isNotEmpty ? p.imageUrls.first : 'assets/images/shampoo.jpg'),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  p.name,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF111827)),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: const [
                                    Icon(Icons.star, size: 14, color: Colors.amber),
                                    Icon(Icons.star, size: 14, color: Colors.amber),
                                    Icon(Icons.star, size: 14, color: Colors.amber),
                                    Icon(Icons.star, size: 14, color: Colors.amber),
                                    Icon(Icons.star, size: 14, color: Colors.amber),
                                    SizedBox(width: 4),
                                    Text('4.9 (128)', style: TextStyle(fontSize: 10, color: Color(0xFF6B7280))),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('₹${v.price.toInt()}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
                                        Text('MRP ₹${v.mrp.toInt()}', style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF), decoration: TextDecoration.lineThrough)),
                                      ],
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        ref.read(cartProvider.notifier).addItem(
                                              product: p,
                                              variant: v,
                                            );
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('Added ${p.name} to cart!')),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF6366F1),
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                        minimumSize: Size.zero,
                                      ),
                                      child: const Text('Add to Bag', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (_, __) => const SizedBox.shrink(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildNavLink(String title, {bool isSelected = false, required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.only(right: 20),
      child: InkWell(
        onTap: onTap,
        child: Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? const Color(0xFF6366F1) : const Color(0xFF374151),
          ),
        ),
      ),
    );
  }

  Widget _buildTrustCard(IconData icon, String title, String subtitle) {
    return Expanded(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF3E8FF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFF6366F1), size: 22),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF111827))),
                Text(subtitle, style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
