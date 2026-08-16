import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../config/theme/app_colors.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../cart/controllers/cart_controller.dart';
import '../../catalog/repositories/product_repository.dart';
import '../../coupons/controllers/coupon_controller.dart';
import '../../orders/repositories/order_repository.dart';
import '../widgets/vaidyam_mobile_checkout_screen_widget.dart';

class VaidyamCheckoutScreen extends ConsumerStatefulWidget {
  const VaidyamCheckoutScreen({super.key});

  @override
  ConsumerState<VaidyamCheckoutScreen> createState() => _VaidyamCheckoutScreenState();
}

class _VaidyamCheckoutScreenState extends ConsumerState<VaidyamCheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _pincodeController = TextEditingController(text: '800001');
  final _addressController = TextEditingController();
  final _cityController = TextEditingController(text: 'Patna');
  final _couponController = TextEditingController();
  String _selectedState = 'Bihar';
  bool _isDefaultAddress = true;
  String _selectedPaymentMethod = 'UPI / QR';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(currentUserProvider);
      final auth = ref.read(authControllerProvider);
      final name = auth.userName ?? user?.userMetadata?['full_name'] ?? (auth.isGuest ? auth.guestName : null);
      final phone = auth.userPhone ?? user?.phone ?? (auth.isGuest ? auth.guestPhone : null);
      if (name != null && name.isNotEmpty) {
        _nameController.text = name;
      }
      if (phone != null && phone.isNotEmpty) {
        _phoneController.text = phone;
      }
    });
  }

  final List<String> _indianStates = [
    'Maharashtra',
    'Delhi',
    'Karnataka',
    'Tamil Nadu',
    'West Bengal',
    'Gujarat',
    'Uttar Pradesh',
    'Telangana',
    'Kerala',
    'Rajasthan',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _pincodeController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartProvider);
    final wishlist = ref.watch(wishlistProvider);
    final totalCartCount = cartState.totalItemCount;

    // Calculate Real Subtotal, Coupon Discount & Total (NO Hardcoded 499 Discount!)
    final double subtotal = cartState.subtotal;
    final double discount = cartState.couponDiscount;
    final double shippingFee = cartState.shippingFee;
    final double total = cartState.finalTotal;
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth > 950;

    final List<Map<String, dynamic>> itemsList = cartState.items.asMap().entries.map((entry) {
      final item = entry.value;
      return <String, dynamic>{
        'id': item.product.id,
        'name': item.product.name,
        'category': item.product.categoryId,
        'variant': item.variant.sizeLabel.isNotEmpty ? item.variant.sizeLabel : 'Standard Pack',
        'price': item.variant.price,
        'mrp': item.variant.mrp,
        'quantity': item.quantity,
        'image': item.product.imageUrls.isNotEmpty ? item.product.imageUrls.first : 'assets/images/shampoo.jpg',
        'index': entry.key,
      };
    }).toList();

    if (screenWidth <= 768) {
      final auth = ref.watch(authControllerProvider);
      final user = ref.watch(currentUserProvider);
      final String name = _nameController.text.trim().isNotEmpty
          ? _nameController.text.trim()
          : (auth.userName ?? user?.userMetadata?['full_name'] ?? 'Mahboob Hasan');
      final String phone = _phoneController.text.trim().isNotEmpty
          ? _phoneController.text.trim()
          : (auth.userPhone ?? user?.phone ?? '+91 94730 40903');

      return VaidyamMobileCheckoutScreenWidget(
        itemsList: itemsList,
        subtotal: subtotal,
        discount: discount,
        shippingFee: shippingFee,
        finalTotal: total,
        userName: name,
        userPhone: phone,
        address: _addressController.text.trim().isNotEmpty ? _addressController.text.trim() : 'Flat 402, Green Glen Heights, Bellandur',
        city: _cityController.text.trim().isNotEmpty ? _cityController.text.trim() : 'Bengaluru',
        state: _selectedState.isNotEmpty ? _selectedState : 'Karnataka',
        pincode: _pincodeController.text.trim().isNotEmpty ? _pincodeController.text.trim() : '560103',
        onPlaceOrder: () async {
          await _ensureLoggedInAndPlaceOrder(context, () async {
            final currentAuth = ref.read(authControllerProvider);
            final currentUser = ref.read(currentUserProvider);
            final placedOrder = await ref.read(orderRepositoryProvider).placeOrder(
                  userId: currentUser?.id,
                  isGuest: currentAuth.isGuest,
                  customerName: name,
                  customerEmail: currentAuth.userEmail ?? currentUser?.email ?? 'customer@cosmyra.cloud',
                  customerPhone: phone,
                  shippingAddress: {
                    'name': name,
                    'phone': phone,
                    'address': _addressController.text.trim().isNotEmpty ? _addressController.text.trim() : 'Flat 402, Green Glen Heights, Bellandur',
                    'city': _cityController.text.trim().isNotEmpty ? _cityController.text.trim() : 'Bengaluru',
                    'state': _selectedState,
                    'pincode': _pincodeController.text.trim().isNotEmpty ? _pincodeController.text.trim() : '560103',
                  },
                  cartItems: cartState.items,
                  subtotal: subtotal,
                  discount: discount,
                  shippingFee: 0.0,
                  totalAmount: total,
                  paymentMethod: _selectedPaymentMethod,
                );

            ref.invalidate(userOrdersFutureProvider);
            ref.invalidate(allAdminOrdersFutureProvider);
            ref.read(cartProvider.notifier).clearCart();

            if (!context.mounted) return;

            showDialog(
              context: context,
              builder: (dialogCtx) => AlertDialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                title: Row(
                  children: const [
                    Icon(Icons.check_circle, color: Color(0xFF059669), size: 28),
                    SizedBox(width: 10),
                    Text('Order Placed! 🛍️'),
                  ],
                ),
                content: Text('Order #${placedOrder.id} has been placed successfully!\n\nThank you for shopping with Cosmyra.'),
                actions: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(dialogCtx);
                      context.go('/account');
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4338CA)),
                    child: const Text('View Order Details', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            );
          });
        },
      );
    }

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

            // 2. Main Header Bar (Logo, Search, Wishlist/Cart/Account)
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
                          'Cosmyra',
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
                      width: 440,
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
                            child: const Text('All Categories ⌵', style: TextStyle(fontSize: 13, color: Color(0xFF374151), fontWeight: FontWeight.w500)),
                          ),
                          const Expanded(
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              child: Text('Search for products, brands...', style: TextStyle(fontSize: 13, color: Color(0xFF9CA3AF))),
                            ),
                          ),
                          Container(
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

            const SizedBox(height: 24),

            // 4. Page Title Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1300),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    'Checkout',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Color(0xFF111827)),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // 5. Main 3-Column Checkout Card Grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1300),
                child: Form(
                  key: _formKey,
                  child: isWide
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Column 1: Delivery Address Form Card
                            Expanded(
                              flex: 4,
                              child: _buildAddressCard(context),
                            ),
                            const SizedBox(width: 24),
                            // Column 2: Payment Method Card
                            Expanded(
                              flex: 4,
                              child: _buildPaymentMethodCard(context),
                            ),
                            const SizedBox(width: 24),
                            // Column 3: Order Summary Card
                            Expanded(
                              flex: 4,
                              child: _buildOrderSummaryCard(context, subtotal, discount, total, totalCartCount > 0 ? totalCartCount : 3),
                            ),
                          ],
                        )
                      : Column(
                          children: [
                            _buildAddressCard(context),
                            const SizedBox(height: 24),
                            _buildPaymentMethodCard(context),
                            const SizedBox(height: 24),
                            _buildOrderSummaryCard(context, subtotal, discount, total, totalCartCount > 0 ? totalCartCount : 3),
                          ],
                        ),
                ),
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

  // Column 1: Delivery Address Form Card
  Widget _buildAddressCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF3F4F6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Delivery Address', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
          const SizedBox(height: 20),

          _buildInputField('Full Name', _nameController, 'Enter your full name'),
          const SizedBox(height: 16),
          _buildInputField('Mobile Number', _phoneController, 'Enter mobile number', keyboardType: TextInputType.phone),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(child: _buildInputField('Pincode', _pincodeController, 'Enter pincode', keyboardType: TextInputType.number)),
              const SizedBox(width: 12),
              Expanded(child: _buildInputField('Address', _addressController, 'House No., Building, Street, Area')),
            ],
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(child: _buildInputField('Town / City', _cityController, 'Enter city')),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('State', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF374151))),
                    const SizedBox(height: 8),
                    Container(
                      height: 46,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedState,
                          isExpanded: true,
                          style: const TextStyle(fontSize: 13, color: Color(0xFF111827), fontWeight: FontWeight.w500),
                          items: _indianStates.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                          onChanged: (val) => setState(() => _selectedState = val ?? 'Maharashtra'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              Checkbox(
                value: _isDefaultAddress,
                activeColor: const Color(0xFF4F46E5),
                onChanged: (val) => setState(() => _isDefaultAddress = val ?? true),
              ),
              const Text('Make this my default address', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF374151))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller, String hint, {TextInputType keyboardType = TextInputType.text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF374151))),
        const SizedBox(height: 8),
        Container(
          height: 46,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: const TextStyle(fontSize: 13, color: Color(0xFF111827), fontWeight: FontWeight.w500),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }

  // Column 2: Payment Method Card
  Widget _buildPaymentMethodCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF3F4F6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Payment Method', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
          const SizedBox(height: 20),

          _buildPaymentOption('UPI / QR', 'Pay using any UPI app', Icons.qr_code_scanner, 'UPI / QR'),
          const SizedBox(height: 12),
          _buildPaymentOption('Credit / Debit Card', 'Visa, MasterCard, RuPay', Icons.credit_card, 'Credit / Debit Card'),
          const SizedBox(height: 12),
          _buildPaymentOption('Net Banking', 'All major banks supported', Icons.account_balance, 'Net Banking'),
          const SizedBox(height: 12),
          _buildPaymentOption('Cash on Delivery', 'Pay when you receive', Icons.payments_outlined, 'Cash on Delivery'),

          const SizedBox(height: 24),

          // 100% Secure Payments Box
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFECFDF5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFA7F3D0)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.lock, color: Color(0xFF059669), size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('100% Secure Payments', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF065F46))),
                      SizedBox(height: 2),
                      Text('Your information is safe with us', style: TextStyle(fontSize: 11, color: Color(0xFF047857))),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption(String title, String subtitle, IconData icon, String value) {
    final isSelected = _selectedPaymentMethod == value;

    return InkWell(
      onTap: () => setState(() => _selectedPaymentMethod = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEEF2FF) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF4F46E5) : const Color(0xFFE5E7EB),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF4F46E5) : const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: isSelected ? Colors.white : const Color(0xFF4B5563), size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isSelected ? const Color(0xFF4F46E5) : const Color(0xFF111827))),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? const Color(0xFF4F46E5) : const Color(0xFF9CA3AF),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  // Column 3: Order Summary Card
  Widget _buildOrderSummaryCard(BuildContext context, double subtotal, double discount, double total, int itemCounts) {
    final cartState = ref.watch(cartProvider);
    final coupons = ref.watch(couponProvider);
    final visibleCoupons = coupons.where((c) => c.isActive && c.isVisibleAtCheckout).toList();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF3F4F6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Order Summary', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
          const SizedBox(height: 20),

          // ── COUPON CODE INPUT & APPLY ──
          const Text('Apply Coupon Code:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF374151))),
          const SizedBox(height: 8),
          if (cartState.appliedCouponCode != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFECFDF5),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFA7F3D0)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.confirmation_number_outlined, color: Color(0xFF059669), size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Applied: ${cartState.appliedCouponCode} (-₹${discount.toInt()})',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF065F46)),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () {
                      ref.read(cartProvider.notifier).removeCoupon();
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Coupon removed.')));
                    },
                    style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                    child: const Text('Remove ❌', style: TextStyle(color: Color(0xFFEF4444), fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ] else ...[
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 44,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: TextField(
                      controller: _couponController,
                      textCapitalization: TextCapitalization.characters,
                      decoration: const InputDecoration(
                        hintText: 'Enter Promo / Coupon Code',
                        hintStyle: TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    final code = _couponController.text.trim();
                    if (code.isEmpty) return;
                    final coupon = ref.read(couponProvider.notifier).findByCode(code);
                    if (coupon == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Invalid or expired coupon code "$code"!')),
                      );
                      return;
                    }
                    if (subtotal < coupon.minSpend) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Minimum order spend of ₹${coupon.minSpend.toInt()} required for ${coupon.code}!')),
                      );
                      return;
                    }
                    final applied = ref.read(cartProvider.notifier).applyCouponModel(coupon);
                    if (applied) {
                      _couponController.clear();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Coupon "${coupon.code}" applied successfully!')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4F46E5),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(80, 44),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('APPLY', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ],
            ),
          ],

          // ── VISIBLE COUPONS AT CHECKOUT ──
          if (visibleCoupons.isNotEmpty && cartState.appliedCouponCode == null) ...[
            const SizedBox(height: 16),
            const Text('Available Offers & Coupons:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF4B5563))),
            const SizedBox(height: 8),
            Column(
              children: visibleCoupons.map((c) {
                final discountText = c.discountType == 'percentage' ? '${c.discountValue.toInt()}% OFF' : '₹${c.discountValue.toInt()} OFF';
                final isEligible = subtotal >= c.minSpend;

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEEF2FF),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: const Color(0xFFC7D2FE)),
                        ),
                        child: Text(
                          c.code,
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF4F46E5)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$discountText - ${c.title}',
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (c.minSpend > 0)
                              Text(
                                'On orders above ₹${c.minSpend.toInt()}',
                                style: const TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                              ),
                          ],
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          if (!isEligible) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Add items worth ₹${(c.minSpend - subtotal).toInt()} more to use ${c.code}')),
                            );
                            return;
                          }
                          ref.read(cartProvider.notifier).applyCouponModel(c);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Applied ${c.code}!')),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: isEligible ? const Color(0xFF4F46E5) : const Color(0xFFCBD5E1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text('APPLY', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],

          const SizedBox(height: 20),
          const Divider(color: Color(0xFFE5E7EB)),
          const SizedBox(height: 16),

          _buildSummaryRow('Subtotal ($itemCounts Items)', '₹${subtotal.toInt()}'),
          const SizedBox(height: 12),
          if (discount > 0) ...[
            _buildSummaryRow('Coupon Discount', '- ₹${discount.toInt()}', isDiscount: true),
            const SizedBox(height: 12),
          ],
          _buildSummaryRow('Shipping', cartState.shippingFee == 0 ? 'Free' : '₹${cartState.shippingFee.toInt()}', isDiscount: cartState.shippingFee == 0),

          const SizedBox(height: 16),
          const Divider(color: Color(0xFFE5E7EB)),
          const SizedBox(height: 16),

          // Total Price Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Total', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
                  SizedBox(height: 2),
                  Text('(Inclusive of all taxes)', style: TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
                ],
              ),
              Text('₹${total.toInt()}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
            ],
          ),

          const SizedBox(height: 20),

          // Savings Banner Box (Only if discount > 0)
          if (discount > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFECFDF5),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFA7F3D0)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.stars, color: Color(0xFF059669), size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'You will save ₹${discount.toInt()} on this order',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF065F46)),
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 24),

          // Place Order Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () async {
                await _ensureLoggedInAndPlaceOrder(context, () async {
                  final auth = ref.read(authControllerProvider);
                  final user = ref.read(currentUserProvider);
                  final currentCartState = ref.read(cartProvider);

                  final String name = _nameController.text.trim().isNotEmpty
                      ? _nameController.text.trim()
                      : (auth.userName ?? user?.userMetadata?['full_name'] ?? 'Customer');
                  final String phone = _phoneController.text.trim().isNotEmpty
                      ? _phoneController.text.trim()
                      : (auth.userPhone ?? user?.phone ?? '+91 94730 40903');
                  final String email = auth.userEmail ?? user?.email ?? 'customer@cosmyra.cloud';

                  final Map<String, dynamic> shippingAddressMap = {
                    'name': name,
                    'phone': phone,
                    'address': _addressController.text.trim().isNotEmpty ? _addressController.text.trim() : 'Flat 402, Green Valley',
                    'city': _cityController.text.trim().isNotEmpty ? _cityController.text.trim() : 'Patna',
                    'state': _selectedState,
                    'pincode': _pincodeController.text.trim().isNotEmpty ? _pincodeController.text.trim() : '800001',
                  };

                  final placedOrder = await ref.read(orderRepositoryProvider).placeOrder(
                        userId: user?.id,
                        isGuest: auth.isGuest,
                        customerName: name,
                        customerEmail: email,
                        customerPhone: phone,
                        shippingAddress: shippingAddressMap,
                        cartItems: currentCartState.items,
                        subtotal: subtotal,
                        discount: discount,
                        shippingFee: 0.0,
                        totalAmount: total,
                        paymentMethod: _selectedPaymentMethod,
                      );

                  ref.invalidate(userOrdersFutureProvider);
                  ref.invalidate(allAdminOrdersFutureProvider);

                  if (!context.mounted) return;

                  showDialog(
                    context: context,
                    builder: (dialogCtx) => AlertDialog(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      title: Row(
                        children: const [
                          Icon(Icons.check_circle, color: Color(0xFF059669), size: 28),
                          SizedBox(width: 10),
                          Text('Order Placed!'),
                        ],
                      ),
                      content: Text(
                        'Thank you for your order, $name!\n\nOrder Number: ${placedOrder.orderNumber}\nTotal Amount: ₹${total.toInt()} via $_selectedPaymentMethod.\n\nEstimated Delivery: 2-3 Business Days.',
                        style: const TextStyle(fontSize: 14, color: Color(0xFF374151)),
                      ),
                      actions: [
                        ElevatedButton(
                          onPressed: () {
                            ref.read(cartProvider.notifier).clearCart();
                            Navigator.pop(dialogCtx);
                            context.go('/dashboard?tab=My%20Orders');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4F46E5),
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Go to My Orders'),
                        ),
                      ],
                    ),
                  );
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4F46E5),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Place Order', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),

          const SizedBox(height: 16),

          // Return to Cart Link
          Center(
            child: InkWell(
              onTap: () => context.go('/cart'),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.arrow_back, size: 16, color: Color(0xFF4B5563)),
                  SizedBox(width: 6),
                  Text('Return to Cart', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF4B5563))),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isDiscount = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280), fontWeight: FontWeight.w500)),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: isDiscount ? const Color(0xFF16A34A) : const Color(0xFF111827),
          ),
        ),
      ],
    );
  }

  Future<void> _ensureLoggedInAndPlaceOrder(BuildContext context, Future<void> Function() onPlaceOrderAction) async {
    final auth = ref.read(authControllerProvider);
    final user = ref.read(currentUserProvider);
    final bool isLoggedIn = auth.isLoggedIn || user != null;

    if (isLoggedIn) {
      await onPlaceOrderAction();
      return;
    }

    final emailCtrl = TextEditingController();
    final passwordCtrl = TextEditingController();
    bool isLoading = false;
    String? errorMsg;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setStateModal) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF4F46E5).withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.lock_outline_rounded, color: Color(0xFF4F46E5), size: 24),
                          ),
                          const SizedBox(width: 12),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Sign In to Place Order 🛍️', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                              Text('Sign in to confirm & track delivery', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                            ],
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Color(0xFF64748B)),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (errorMsg != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFFECACA)),
                      ),
                      child: Text(errorMsg!, style: const TextStyle(color: Color(0xFFDC2626), fontSize: 13)),
                    ),
                    const SizedBox(height: 14),
                  ],
                  TextField(
                    controller: emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email Address',
                      hintText: 'Enter your email',
                      prefixIcon: const Icon(Icons.email_outlined, size: 20),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: passwordCtrl,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      hintText: 'Enter your password',
                      prefixIcon: const Icon(Icons.lock_outline, size: 20),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: isLoading
                          ? null
                          : () async {
                              final email = emailCtrl.text.trim();
                              final pwd = passwordCtrl.text.trim();
                              if (email.isEmpty || pwd.isEmpty) {
                                setStateModal(() => errorMsg = 'Please enter both email and password.');
                                return;
                              }
                              setStateModal(() {
                                isLoading = true;
                                errorMsg = null;
                              });

                              final success = await ref.read(authControllerProvider.notifier).signInWithEmail(email: email, password: pwd);
                              if (success) {
                                if (context.mounted) {
                                  Navigator.pop(ctx);
                                }
                                await onPlaceOrderAction();
                              } else {
                                setStateModal(() {
                                  isLoading = false;
                                  errorMsg = ref.read(authControllerProvider).errorMessage ?? 'Sign in failed. Please try again.';
                                });
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4F46E5),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: isLoading
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text('Sign In & Place Order', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: TextButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        context.push('/login');
                      },
                      child: const Text("Don't have an account? Register / Sign Up", style: TextStyle(color: Color(0xFF4F46E5), fontSize: 13, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
