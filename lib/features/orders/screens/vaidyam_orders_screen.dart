import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../shared/widgets/center_action_toast.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../cart/controllers/cart_controller.dart';
import '../../catalog/repositories/product_repository.dart';
import '../repositories/order_repository.dart';
import '../../navigation/widgets/vaidyam_footer_widget.dart';

class VaidyamOrdersScreen extends ConsumerStatefulWidget {
  const VaidyamOrdersScreen({super.key});

  @override
  ConsumerState<VaidyamOrdersScreen> createState() => _VaidyamOrdersScreenState();
}

class _VaidyamOrdersScreenState extends ConsumerState<VaidyamOrdersScreen> {
  final TextEditingController _headerSearchController = TextEditingController();
  final TextEditingController _orderSearchController = TextEditingController();
  String _selectedSearchCategory = 'All Categories';
  String _selectedStatusFilter = 'All Orders';
  String _selectedSidebarItem = 'My Orders';
  int _currentPage = 1;

  @override
  void dispose() {
    _headerSearchController.dispose();
    _orderSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartProvider);
    final wishlist = ref.watch(wishlistProvider);
    final ordersAsync = ref.watch(userOrdersFutureProvider);
    final itemCount = cartState.totalItemCount;

    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth > 950;

    // Combine real Riverpod orders + demo fallback orders
    final List<Map<String, dynamic>> allOrders = [];

    ordersAsync.whenData((realOrders) {
      for (var ro in realOrders) {
        for (var item in ro.items) {
          allOrders.add({
            'orderId': ro.orderNumber,
            'productName': item.productName,
            'category': 'Botanical Care',
            'variant': item.variantName,
            'qty': item.quantity,
            'price': item.totalPrice,
            'date': DateFormat('MMM dd, yyyy • hh:mm a').format(ro.createdAt),
            'status': ro.fulfillmentStatus.isNotEmpty
                ? ro.fulfillmentStatus[0].toUpperCase() +
                    ro.fulfillmentStatus.substring(1)
                : 'Processing',
            'statusDetail': 'Order Status: ${ro.fulfillmentStatus}',
            'image': '',
          });
        }
      }
    });



    // Filter by tab + search query
    final String query = _orderSearchController.text.trim().toLowerCase();
    final List<Map<String, dynamic>> filteredOrders = allOrders.where((ord) {
      final matchesTab = _selectedStatusFilter == 'All Orders' ||
          ord['status'].toString().toLowerCase() ==
              _selectedStatusFilter.toLowerCase();
      final matchesSearch = query.isEmpty ||
          ord['orderId'].toString().toLowerCase().contains(query) ||
          ord['productName'].toString().toLowerCase().contains(query) ||
          ord['category'].toString().toLowerCase().contains(query);
      return matchesTab && matchesSearch;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ─── 1. TOP ANNOUNCEMENT BAR ───
            Container(
              width: double.infinity,
              color: const Color(0xFF4338CA),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Row(
                children: [
                  const Icon(Icons.local_shipping_outlined,
                      color: Colors.white, size: 14),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Free Shipping on orders over ₹999',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isWide)
                    Row(
                      children: [
                        _topLink('Track Order', () => context.go('/orders')),
                        const Text('  |  ',
                            style: TextStyle(
                                color: Colors.white70, fontSize: 11)),
                        _topLink('Help & Support', () {}),
                        const Text('  |  ',
                            style: TextStyle(
                                color: Colors.white70, fontSize: 11)),
                        _topLink('Returns', () {}),
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
                          'ShopZone',
                          style: TextStyle(
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
                          Expanded(
                            child: TextField(
                              controller: _headerSearchController,
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
                        onTap: () => context.go('/cart'),
                      ),
                      const SizedBox(width: 22),
                      _headerAction(
                        icon: Icons.person_outline,
                        label: 'Account',
                        isActive: true,
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

            // ─── 4. MAIN TWO-COLUMN CONTAINER ───
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: isWide
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Left Sidebar: My Account Navigation
                            SizedBox(
                              width: 240,
                              child: _buildSidebar(context),
                            ),
                            const SizedBox(width: 28),
                            // Right Area: My Orders Content
                            Expanded(
                              child: _buildOrdersContent(
                                context,
                                filteredOrders,
                                allOrders.length,
                              ),
                            ),
                          ],
                        )
                      : Column(
                          children: [
                            _buildSidebarMobile(context),
                            const SizedBox(height: 24),
                            _buildOrdersContent(
                              context,
                              filteredOrders,
                              allOrders.length,
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
  //  TOP ANNOUNCEMENT LINK
  // ════════════════════════════════════════════
  Widget _topLink(String title, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Text(
        title,
        style: const TextStyle(
            color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500),
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
  //  LEFT SIDEBAR (DESKTOP)
  // ════════════════════════════════════════════
  Widget _buildSidebar(BuildContext context) {
    final items = [
      {'title': 'Dashboard', 'icon': Icons.grid_view_rounded, 'badge': 0},
      {'title': 'My Orders', 'icon': Icons.inventory_2_outlined, 'badge': 0},
      {'title': 'Wishlist', 'icon': Icons.favorite_border, 'badge': 0},
      {'title': 'Addresses', 'icon': Icons.location_on_outlined, 'badge': 0},
      {
        'title': 'Payment Methods',
        'icon': Icons.credit_card_outlined,
        'badge': 0
      },
      {'title': 'Coupons', 'icon': Icons.confirmation_number_outlined, 'badge': 0},
      {
        'title': 'Notifications',
        'icon': Icons.notifications_none_outlined,
        'badge': 3
      },
      {
        'title': 'Returns & Refunds',
        'icon': Icons.assignment_return_outlined,
        'badge': 0
      },
      {'title': 'Help & Support', 'icon': Icons.help_outline, 'badge': 0},
      {'title': 'Account Settings', 'icon': Icons.settings_outlined, 'badge': 0},
      {'title': 'Logout', 'icon': Icons.logout, 'badge': 0, 'isLogout': true},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 14, bottom: 16),
            child: Text(
              'My Account',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF111827),
              ),
            ),
          ),
          ...items.map((item) {
            final String title = item['title'] as String;
            final IconData icon = item['icon'] as IconData;
            final int badge = item['badge'] as int;
            final bool isLogout = item['isLogout'] == true;
            final bool isSelected = _selectedSidebarItem == title;

            return InkWell(
              onTap: () async {
                if (isLogout) {
                  await ref.read(authControllerProvider.notifier).signOut();
                  if (context.mounted) context.go('/login');
                } else if (title == 'Dashboard') {
                  context.go('/dashboard');
                } else if (title == 'Wishlist') {
                  context.go('/wishlist');
                } else if (title == 'My Orders') {
                  setState(() => _selectedSidebarItem = 'My Orders');
                } else {
                  context.go('/dashboard?tab=$title');
                }
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                margin: const EdgeInsets.only(bottom: 4),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFFEEF2FF)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: isSelected
                      ? const Border(
                          left: BorderSide(
                              color: Color(0xFF4338CA), width: 3))
                      : null,
                ),
                child: Row(
                  children: [
                    Icon(
                      icon,
                      size: 18,
                      color: isLogout
                          ? const Color(0xFFEF4444)
                          : (isSelected
                              ? const Color(0xFF4338CA)
                              : const Color(0xFF6B7280)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isLogout
                              ? const Color(0xFFEF4444)
                              : (isSelected
                                  ? const Color(0xFF4338CA)
                                  : const Color(0xFF374151)),
                        ),
                      ),
                    ),
                    if (badge > 0)
                      Container(
                        padding: const EdgeInsets.all(5),
                        decoration: const BoxDecoration(
                          color: Color(0xFFEF4444),
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '$badge',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // Mobile horizontal tabs for account items
  Widget _buildSidebarMobile(BuildContext context) {
    final tabs = [
      'Dashboard',
      'My Orders',
      'Wishlist',
      'Addresses',
      'Payment Methods',
      'Coupons',
      'Notifications',
    ];

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: tabs.map((t) {
            final isSel = _selectedSidebarItem == t;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(t),
                selected: isSel,
                selectedColor: const Color(0xFFEEF2FF),
                labelStyle: TextStyle(
                  color: isSel
                      ? const Color(0xFF4338CA)
                      : const Color(0xFF374151),
                  fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                ),
                onSelected: (_) {
                  if (t == 'Dashboard') context.go('/dashboard');
                  if (t == 'Wishlist') context.go('/wishlist');
                  setState(() => _selectedSidebarItem = t);
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // ════════════════════════════════════════════
  //  RIGHT MAIN AREA — MY ORDERS
  // ════════════════════════════════════════════
  Widget _buildOrdersContent(BuildContext context,
      List<Map<String, dynamic>> orders, int totalCount) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Top Title & Search / Filter Row ──
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'My Orders',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF111827),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Track, view and manage all your orders in one place.',
                    style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Search Input
            SizedBox(
              width: 250,
              height: 40,
              child: TextField(
                controller: _orderSearchController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Search by Order ID, Product...',
                  hintStyle: const TextStyle(
                      fontSize: 12, color: Color(0xFF9CA3AF)),
                  prefixIcon: const Icon(Icons.search,
                      size: 16, color: Color(0xFF9CA3AF)),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFF4338CA)),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            // Filter Button
            OutlinedButton.icon(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(0, 40),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
                side: const BorderSide(color: Color(0xFFE5E7EB)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                backgroundColor: Colors.white,
              ),
              icon: const Icon(Icons.tune,
                  size: 16, color: Color(0xFF374151)),
              label: const Text('Filter',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF374151))),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // ── Filter Tabs ──
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              'All Orders',
              'Processing',
              'Shipped',
              'Delivered',
              'Cancelled',
              'Returned',
            ].map((tabName) {
              final isSel = _selectedStatusFilter == tabName;
              return InkWell(
                onTap: () => setState(() => _selectedStatusFilter = tabName),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: isSel
                            ? const Color(0xFF4338CA)
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                  ),
                  child: Text(
                    tabName,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight:
                          isSel ? FontWeight.w700 : FontWeight.w500,
                      color: isSel
                          ? const Color(0xFF4338CA)
                          : const Color(0xFF6B7280),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        const Divider(height: 1, color: Color(0xFFE5E7EB)),
        const SizedBox(height: 20),

        // ── Order Cards List ──
        if (orders.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Column(
              children: [
                const Icon(Icons.shopping_bag_outlined, size: 54, color: Color(0xFF9CA3AF)),
                const SizedBox(height: 14),
                const Text(
                  'No Orders Placed Yet',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'You have not placed any orders yet. Explore our Ayurvedic formulations to start shopping.',
                  style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () => context.go('/explore'),
                  icon: const Icon(Icons.local_mall_outlined, size: 16),
                  label: const Text('Explore Vaidyam Formulations', style: TextStyle(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4338CA),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
          )
        else
          ...orders.map((ord) => _buildOrderCard(context, ord)),

        const SizedBox(height: 24),

        // ── Pagination Footer ──
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Showing 1 to ${orders.length} of $totalCount orders',
              style:
                  const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
            ),
            Row(
              children: [
                _pageBtn('<', false, () {}),
                const SizedBox(width: 4),
                _pageBtn('1', _currentPage == 1, () => setState(() => _currentPage = 1)),
                const SizedBox(width: 4),
                _pageBtn('2', _currentPage == 2, () => setState(() => _currentPage = 2)),
                const SizedBox(width: 4),
                _pageBtn('3', _currentPage == 3, () => setState(() => _currentPage = 3)),
                const SizedBox(width: 4),
                const Text('...',
                    style: TextStyle(color: Color(0xFF6B7280))),
                const SizedBox(width: 4),
                _pageBtn('>', false, () {}),
              ],
            ),
          ],
        ),
      ],
    );
  }

  // ════════════════════════════════════════════
  //  ORDER CARD ITEM
  // ════════════════════════════════════════════
  Widget _buildOrderCard(BuildContext context, Map<String, dynamic> ord) {
    final String orderId = ord['orderId'] ?? '#ORD0000';
    final String productName = ord['productName'] ?? 'Product';
    final String category = ord['category'] ?? '';
    final String variant = ord['variant'] ?? '';
    final int qty = (ord['qty'] as num).toInt();
    final double price = (ord['price'] as num).toDouble();
    final String date = ord['date'] ?? '';
    final String status = ord['status'] ?? 'Delivered';
    final String statusDetail = ord['statusDetail'] ?? '';
    final String imageUrl = ord['image'] ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product thumbnail image
              Container(
                width: 76,
                height: 76,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: imageUrl.isNotEmpty
                    ? Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (ctx, err, stack) => const Icon(
                            Icons.shopping_bag_outlined,
                            size: 28,
                            color: Color(0xFF9CA3AF)),
                      )
                    : const Icon(Icons.shopping_bag_outlined,
                        size: 28, color: Color(0xFF9CA3AF)),
              ),

              const SizedBox(width: 16),

              // Product Info Column
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      productName,
                      style: const TextStyle(
                        fontSize: 15,
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
                            fontSize: 12, color: Color(0xFF6B7280)),
                      ),
                    ],
                    if (variant.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        variant,
                        style: const TextStyle(
                            fontSize: 12, color: Color(0xFF9CA3AF)),
                      ),
                    ],
                    const SizedBox(height: 4),
                    Text(
                      'Qty: $qty',
                      style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF374151),
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // Order Metadata & Status Details (Center)
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order ID: $orderId',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      date,
                      style: const TextStyle(
                          fontSize: 12, color: Color(0xFF6B7280)),
                    ),
                    const SizedBox(height: 8),
                    _statusDetailRow(status, statusDetail),
                    const SizedBox(height: 10),
                    // Download Invoice button
                    OutlinedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text('Downloading invoice for $orderId...')),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        side: const BorderSide(color: Color(0xFFD1D5DB)),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6)),
                        minimumSize: const Size(0, 32),
                      ),
                      icon: const Icon(Icons.file_download_outlined,
                          size: 14, color: Color(0xFF4338CA)),
                      label: const Text('Download Invoice',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF4338CA))),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // Price & Item Count (Right)
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '₹${price.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$qty Item',
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF6B7280)),
                  ),
                ],
              ),

              const SizedBox(width: 20),

              // Status Badge & Action Buttons (Far Right)
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _statusBadge(status),
                  const SizedBox(height: 10),
                  InkWell(
                    onTap: () {
                      _showOrderDetailsModal(context, ord);
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text(
                          'View Details',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF4338CA),
                          ),
                        ),
                        SizedBox(width: 2),
                        Icon(Icons.chevron_right,
                            size: 16, color: Color(0xFF4338CA)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton(
                    onPressed: () {
                      showCenterActionToast(
                        context,
                        title: 'Re-ordered Item Added! 🛍️',
                        message: productName,
                        icon: Icons.shopping_bag_outlined,
                        iconColor: const Color(0xFF4F46E5),
                        primaryActionLabel: 'VIEW CART',
                        onPrimaryAction: () => context.go('/cart'),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      side: const BorderSide(color: Color(0xFF4338CA)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6)),
                      minimumSize: const Size(0, 32),
                    ),
                    child: const Text(
                      'Buy Again',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF4338CA),
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

  // ── Status Detail Line (Icon + Text) ──
  Widget _statusDetailRow(String status, String detail) {
    IconData iconData;
    Color iconColor;

    switch (status.toLowerCase()) {
      case 'delivered':
        iconData = Icons.check_circle_outline;
        iconColor = const Color(0xFF16A34A);
        break;
      case 'shipped':
        iconData = Icons.local_shipping_outlined;
        iconColor = const Color(0xFF2563EB);
        break;
      case 'processing':
        iconData = Icons.hourglass_empty;
        iconColor = const Color(0xFFD97706);
        break;
      case 'cancelled':
        iconData = Icons.cancel_outlined;
        iconColor = const Color(0xFFDC2626);
        break;
      default:
        iconData = Icons.info_outline;
        iconColor = const Color(0xFF4338CA);
    }

    return Row(
      children: [
        Icon(iconData, size: 15, color: iconColor),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            detail,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: iconColor,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // ── Status Badge ──
  Widget _statusBadge(String status) {
    Color bg;
    Color text;

    switch (status.toLowerCase()) {
      case 'delivered':
        bg = const Color(0xFFDCFCE7);
        text = const Color(0xFF15803D);
        break;
      case 'shipped':
        bg = const Color(0xFFDBEAFE);
        text = const Color(0xFF1D4ED8);
        break;
      case 'processing':
        bg = const Color(0xFFFEF3C7);
        text = const Color(0xFFD97706);
        break;
      case 'cancelled':
        bg = const Color(0xFFFEE2E2);
        text = const Color(0xFFDC2626);
        break;
      case 'returned':
        bg = const Color(0xFFF3E8FF);
        text = const Color(0xFF7E22CE);
        break;
      default:
        bg = const Color(0xFFEEF2FF);
        text = const Color(0xFF4338CA);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: text,
        ),
      ),
    );
  }

  // ── Page Button ──
  Widget _pageBtn(String label, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF4338CA) : Colors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
              color: isSelected
                  ? const Color(0xFF4338CA)
                  : const Color(0xFFE5E7EB)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : const Color(0xFF374151),
          ),
        ),
      ),
    );
  }

  // ── Show Order Details Dialog ──
  void _showOrderDetailsModal(BuildContext context, Map<String, dynamic> ord) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Order Details (${ord['orderId']})',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            _statusBadge(ord['status'] ?? 'Delivered'),
          ],
        ),
        content: SizedBox(
          width: 480,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Product: ${ord['productName']}',
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 14)),
              const SizedBox(height: 4),
              Text('Variant: ${ord['variant']} • Qty: ${ord['qty']}',
                  style: const TextStyle(color: Color(0xFF6B7280), fontSize: 13)),
              const SizedBox(height: 4),
              Text('Total Price: ₹${(ord['price'] as num).toInt()}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Color(0xFF4338CA))),
              const Divider(height: 24),
              const Text('Shipping Address:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 4),
              const Text('Rohit Sharma\n123 Green Park Colony, Sector 4\nNew Delhi, 110016\nPhone: +91 98765 43210',
                  style: TextStyle(fontSize: 12, color: Color(0xFF374151))),
              const Divider(height: 24),
              Text('Tracking Status: ${ord['statusDetail']}',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.go('/cart');
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4338CA),
                foregroundColor: Colors.white),
            child: const Text('Re-order Item'),
          ),
        ],
      ),
    );
  }
}
