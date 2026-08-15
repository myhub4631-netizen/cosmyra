import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../config/theme/app_colors.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../cart/controllers/cart_controller.dart';
import '../../catalog/repositories/product_repository.dart';
import '../../orders/repositories/order_repository.dart';

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

    // Calculate Subtotal & Total
    final double rawSubtotal = cartState.subtotal;
    final double subtotal = rawSubtotal > 0 ? rawSubtotal : 11797.0;
    final double discount = subtotal > 3000 ? 1299.0 : 499.0;
    final double total = subtotal - discount;

    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth > 950;

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

          _buildSummaryRow('Subtotal ($itemCounts Items)', '₹${subtotal.toInt()}'),
          const SizedBox(height: 12),
          _buildSummaryRow('Discount', '- ₹${discount.toInt()}', isDiscount: true),
          const SizedBox(height: 12),
          _buildSummaryRow('Shipping', 'Free', isDiscount: true),

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

          // Savings Banner Box
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
                final auth = ref.read(authControllerProvider);
                final user = ref.read(currentUserProvider);
                final currentCartState = ref.read(cartProvider);

                final String name = _nameController.text.trim().isNotEmpty
                    ? _nameController.text.trim()
                    : (auth.userName ?? user?.userMetadata?['full_name'] ?? 'Customer');
                final String phone = _phoneController.text.trim().isNotEmpty
                    ? _phoneController.text.trim()
                    : (auth.userPhone ?? user?.phone ?? '+91 94730 40903');
                final String email = auth.userEmail ?? user?.email ?? '1mdollar2027@gmail.com';

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
}
