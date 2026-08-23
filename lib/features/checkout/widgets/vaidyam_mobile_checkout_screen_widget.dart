import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../cart/controllers/cart_controller.dart';
import '../../catalog/widgets/product_image_widget.dart';
import '../../coupons/controllers/coupon_controller.dart';
import '../../orders/repositories/order_repository.dart';

class VaidyamMobileCheckoutScreenWidget extends ConsumerStatefulWidget {
  final List<Map<String, dynamic>> itemsList;
  final double subtotal;
  final double discount;
  final double shippingFee;
  final double finalTotal;
  final String userName;
  final String userPhone;
  final String address;
  final String city;
  final String state;
  final String pincode;
  final VoidCallback onPlaceOrder;

  const VaidyamMobileCheckoutScreenWidget({
    super.key,
    required this.itemsList,
    required this.subtotal,
    required this.discount,
    required this.shippingFee,
    required this.finalTotal,
    required this.userName,
    required this.userPhone,
    required this.address,
    required this.city,
    required this.state,
    required this.pincode,
    required this.onPlaceOrder,
  });

  @override
  ConsumerState<VaidyamMobileCheckoutScreenWidget> createState() => _VaidyamMobileCheckoutScreenWidgetState();
}

class _VaidyamMobileCheckoutScreenWidgetState extends ConsumerState<VaidyamMobileCheckoutScreenWidget> {
  static const Color _primaryPurple = Color(0xFF4338CA);
  static const Color _lightBg = Color(0xFFF8FAFC);
  static const Color _textDark = Color(0xFF0F172A);
  static const Color _textMuted = Color(0xFF64748B);

  String _selectedPaymentMethod = 'UPI'; // 'UPI', 'CARD', 'NETBANKING', 'COD'

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartProvider);
    final adminCoupons = ref.watch(couponProvider);

    // Keep applied coupon synced with Admin Coupon Manager settings
    ref.read(cartProvider.notifier).syncWithCoupons(adminCoupons);

    return Scaffold(
      backgroundColor: _lightBg,
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '₹${cartState.finalTotal.toStringAsFixed(0)}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF4F46E5)),
                  ),
                  const Text(
                    'Total Amount',
                    style: TextStyle(fontSize: 10, color: Color(0xFF64748B), fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: widget.onPlaceOrder,
                icon: const Icon(Icons.lock_outline_rounded, size: 18, color: Colors.white),
                label: const Text(
                  'Proceed to Pay 🔒',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 3,
                ),
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header Bar: Back Arrow + Logo + 100% Secure Badge
              _buildHeaderBar(context),

              const SizedBox(height: 16),

              // 2. Step Progress Tracker Bar (1 Cart -> 2 Address -> 3 Payment)
              _buildStepTrackerBar(),

              const SizedBox(height: 16),

              // 3. Page Title & Subtitle
              const Text(
                'Checkout',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: _textDark,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'Review your order and complete the purchase',
                style: TextStyle(fontSize: 12, color: _textMuted),
              ),

              const SizedBox(height: 20),

              // 4. Order Items Summary Card
              _buildOrderItemsCard(context),

              const SizedBox(height: 16),

              // 5. Apply Coupon Code Card
              _buildCouponCard(context, cartState),

              const SizedBox(height: 16),

              // 6. Price Summary Card
              _buildPriceSummaryCard(),

              const SizedBox(height: 16),

              // 7. Delivery Address Card
              _buildDeliveryAddressCard(context),

              const SizedBox(height: 16),

              // 8. Payment Method Selection Card
              _buildPaymentMethodCard(),

              const SizedBox(height: 24),

              // 9. Proceed to Pay Button
              _buildProceedToPayButton(),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // 1. Header Bar
  Widget _buildHeaderBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: _textDark, size: 20),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/cart');
            }
          },
        ),

        // Brand Logo
        InkWell(
          onTap: () => context.go('/'),
          child: Image.asset(
            'assets/images/cosmyra_full_logo.png',
            height: 38,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => Image.asset(
              'assets/images/cosmyra_logo.png',
              height: 38,
              fit: BoxFit.contain,
            ),
          ),
        ),

        // 100% Secure Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFDCFCE7),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: const [
              Icon(Icons.verified_user_rounded, color: Color(0xFF16A34A), size: 12),
              SizedBox(width: 4),
              Text(
                '100% Secure',
                style: TextStyle(color: Color(0xFF15803D), fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 2. Step Progress Tracker Bar
  Widget _buildStepTrackerBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Step 1: Cart
        _buildStepItem(stepNum: '1', label: 'Cart', isCompleted: true, isActive: false),
        _buildStepConnector(isCompleted: true),
        // Step 2: Address
        _buildStepItem(stepNum: '2', label: 'Address', isCompleted: false, isActive: true),
        _buildStepConnector(isCompleted: false),
        // Step 3: Payment
        _buildStepItem(stepNum: '3', label: 'Payment', isCompleted: false, isActive: false),
      ],
    );
  }

  Widget _buildStepItem({
    required String stepNum,
    required String label,
    required bool isCompleted,
    required bool isActive,
  }) {
    final Color bgColor = (isCompleted || isActive) ? _primaryPurple : const Color(0xFFE2E8F0);
    final Color textColor = (isCompleted || isActive) ? Colors.white : _textMuted;

    return Column(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: bgColor,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: isCompleted
                ? const Icon(Icons.check_rounded, color: Colors.white, size: 16)
                : Text(
                    stepNum,
                    style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: (isActive || isCompleted) ? FontWeight.bold : FontWeight.w500,
            color: (isActive || isCompleted) ? _textDark : _textMuted,
          ),
        ),
      ],
    );
  }

  Widget _buildStepConnector({required bool isCompleted}) {
    return Container(
      width: 50,
      height: 2,
      margin: const EdgeInsets.only(bottom: 16, left: 4, right: 4),
      color: isCompleted ? _primaryPurple : const Color(0xFFE2E8F0),
    );
  }

  // 4. Order Items Summary Card
  Widget _buildOrderItemsCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Order Items (${widget.itemsList.length})',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: _textDark),
              ),
              InkWell(
                onTap: () => context.push('/cart'),
                child: Row(
                  children: const [
                    Icon(Icons.edit_outlined, size: 14, color: _primaryPurple),
                    SizedBox(width: 4),
                    Text(
                      'Edit',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _primaryPurple),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          ...widget.itemsList.map((item) {
            final int index = (item['index'] is int) ? item['index'] as int : widget.itemsList.indexOf(item);
            final double price = (item['price'] as num).toDouble();
            final int qty = (item['quantity'] as num).toInt();
            final String name = (item['name'] ?? item['productName'] ?? 'Ayurvedic Formulation') as String;
            final String variant = (item['variant'] ?? item['variantLabel'] ?? 'Standard Pack') as String;
            final String image = (item['image'] ?? item['imageUrl'] ?? 'assets/images/shampoo.jpg') as String;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 60,
                      height: 60,
                      color: const Color(0xFFF8FAFC),
                      child: ProductImageWidget(
                        imageUrl: image,
                        height: 60,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: _textDark),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          variant,
                          style: const TextStyle(fontSize: 11, color: _textMuted),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '₹${(price * qty).toInt()}',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: _textDark),
                      ),
                      const SizedBox(height: 6),

                      // Mini Stepper
                      Container(
                        height: 28,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove, size: 12, color: _textDark),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(minWidth: 26, minHeight: 26),
                              onPressed: () {
                                if (qty > 1) {
                                  ref.read(cartProvider.notifier).updateQuantity(index, qty - 1);
                                } else {
                                  ref.read(cartProvider.notifier).removeItem(index);
                                }
                              },
                            ),
                            Text('$qty', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _textDark)),
                            IconButton(
                              icon: const Icon(Icons.add, size: 12, color: _textDark),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(minWidth: 26, minHeight: 26),
                              onPressed: () {
                                ref.read(cartProvider.notifier).updateQuantity(index, qty + 1);
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // 5. Apply Coupon Code Card
  Widget _buildCouponCard(BuildContext context, CartState cartState) {
    final bool hasCoupon = cartState.appliedCouponCode != null && cartState.appliedCouponCode!.isNotEmpty;

    return InkWell(
      onTap: () {
        _showCouponSelectionModal(context);
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: hasCoupon ? _primaryPurple : const Color(0xFFE2E8F0)),
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
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _primaryPurple.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.local_offer_outlined, color: _primaryPurple, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hasCoupon ? 'Coupon Applied: ${cartState.appliedCouponCode}' : 'Apply Coupon Code',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: hasCoupon ? const Color(0xFF16A34A) : _textDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    hasCoupon
                        ? 'Savings applied on order total'
                        : 'Save more on your order',
                    style: const TextStyle(fontSize: 11, color: _textMuted),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: _textMuted, size: 22),
          ],
        ),
      ),
    );
  }

  // 6. Price Summary Card
  Widget _buildPriceSummaryCard() {
    final formatCurrency = (double amount) {
      return '₹${amount.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}';
    };

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Price Summary',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: _textDark),
          ),
          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Items Total', style: TextStyle(fontSize: 12, color: _textMuted)),
              Text(formatCurrency(widget.subtotal), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _textDark)),
            ],
          ),
          const SizedBox(height: 8),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Discount', style: TextStyle(fontSize: 12, color: _textMuted)),
              Text('- ${formatCurrency(widget.discount)}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF16A34A))),
            ],
          ),
          const SizedBox(height: 8),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Shipping ℹ️', style: TextStyle(fontSize: 12, color: _textMuted)),
              Text(
                widget.shippingFee == 0 ? 'FREE' : '₹${widget.shippingFee.toInt()}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: widget.shippingFee == 0 ? const Color(0xFF16A34A) : _textDark,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Grand Total Highlight Card
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF3E8FF),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Grand Total',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: _textDark),
                    ),
                    Text(
                      formatCurrency(widget.finalTotal),
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: _primaryPurple),
                    ),
                  ],
                ),
                if (widget.discount > 0) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.eco_rounded, color: Color(0xFF16A34A), size: 14),
                      const SizedBox(width: 4),
                      Text(
                        'You are saving ${formatCurrency(widget.discount)} on this order!',
                        style: const TextStyle(color: Color(0xFF15803D), fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 7. Delivery Address Card
  Widget _buildDeliveryAddressCard(BuildContext context) {
    final String name = widget.userName.isNotEmpty ? widget.userName : 'Mahboob Hasan';
    final String phone = widget.userPhone.isNotEmpty ? widget.userPhone : '+91 94730 40903';
    final String fullAddr = '${widget.address.isNotEmpty ? widget.address : "Flat 402, Green Glen Heights, Bellandur"}, ${widget.city.isNotEmpty ? widget.city : "Bengaluru"} - ${widget.pincode.isNotEmpty ? widget.pincode : "560103"}, ${widget.state.isNotEmpty ? widget.state : "Karnataka"}, India';

    return Container(
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
              const Text(
                'Delivery Address',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: _textDark),
              ),
              InkWell(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Address change options open 📍')),
                  );
                },
                child: const Text(
                  'Change',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _primaryPurple),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _primaryPurple.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.location_on_rounded, color: _primaryPurple, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          name,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: _textDark),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEEF2FF),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text('Home', style: TextStyle(color: _primaryPurple, fontSize: 9, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      fullAddr,
                      style: const TextStyle(fontSize: 12, color: _textMuted, height: 1.3),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      phone,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _textDark),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 8. Payment Method Selection Card
  Widget _buildPaymentMethodCard() {
    final options = [
      {
        'id': 'UPI',
        'title': 'UPI (Google Pay / PhonePe / Paytm)',
        'sub': 'Pay instantly with UPI',
        'icon': Icons.qr_code_2_rounded,
        'badge': 'BHIM UPI',
      },
      {
        'id': 'CARD',
        'title': 'Credit / Debit Card',
        'sub': 'Visa, Mastercard, RuPay',
        'icon': Icons.credit_card_rounded,
        'badge': 'VISA / MC',
      },
      {
        'id': 'NETBANKING',
        'title': 'Net Banking',
        'sub': 'All major banks',
        'icon': Icons.account_balance_rounded,
        'badge': 'BANKS',
      },
      {
        'id': 'COD',
        'title': 'Cash on Delivery',
        'sub': 'Pay when you receive (₹49 extra)',
        'icon': Icons.payments_rounded,
        'badge': 'COD',
      },
    ];

    return Container(
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
              const Text(
                'Payment Method',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: _textDark),
              ),
              Row(
                children: const [
                  Icon(Icons.verified_user_rounded, color: Color(0xFF16A34A), size: 14),
                  SizedBox(width: 4),
                  Text(
                    '100% Secure',
                    style: TextStyle(color: Color(0xFF15803D), fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),

          ...options.map((opt) {
            final String id = opt['id'] as String;
            final bool isSelected = _selectedPaymentMethod == id;

            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedPaymentMethod = id;
                });
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFEEF2FF) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? _primaryPurple : const Color(0xFFE2E8F0),
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Radio<String>(
                      value: id,
                      groupValue: _selectedPaymentMethod,
                      activeColor: _primaryPurple,
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _selectedPaymentMethod = val;
                          });
                        }
                      },
                    ),
                    Icon(opt['icon'] as IconData, color: isSelected ? _primaryPurple : _textMuted, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            opt['title'] as String,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                              color: _textDark,
                            ),
                          ),
                          Text(
                            opt['sub'] as String,
                            style: const TextStyle(fontSize: 10, color: _textMuted),
                          ),
                        ],
                      ),
                    ),
                    if (isSelected)
                      const Icon(Icons.check_circle_rounded, color: _primaryPurple, size: 18),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // 9. Proceed to Pay Button
  Widget _buildProceedToPayButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: widget.onPlaceOrder,
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryPurple,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 3,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Proceed to Pay ₹${widget.finalTotal.toInt()}',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_rounded, size: 18),
          ],
        ),
      ),
    );
  }

  // Modal to apply/select coupons
  void _showCouponSelectionModal(BuildContext context) {
    final couponCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Consumer(
          builder: (modalCtx, modalRef, child) {
            final currentCart = modalRef.watch(cartProvider);
            final liveCoupons = modalRef.watch(couponProvider);
            final activeVisibleCoupons = liveCoupons.where((c) => c.isActive && c.isVisibleAtCheckout).toList();
            final bool hasApplied = currentCart.appliedCouponCode != null && currentCart.appliedCouponCode!.isNotEmpty;

            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Apply Coupon Code', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _textDark)),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, size: 20, color: _textMuted),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Coupon Input Box
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: couponCtrl,
                          textCapitalization: TextCapitalization.characters,
                          decoration: InputDecoration(
                            hintText: 'Enter Coupon Code (e.g. VAIDYAM20)',
                            hintStyle: const TextStyle(fontSize: 12, color: _textMuted),
                            filled: true,
                            fillColor: const Color(0xFFF8FAFC),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          final code = couponCtrl.text.trim();
                          if (code.isEmpty) return;
                          final applied = modalRef.read(cartProvider.notifier).applyCoupon(code, availableCoupons: liveCoupons);
                          if (applied) {
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Coupon "$code" applied successfully!'),
                                backgroundColor: const Color(0xFF16A34A),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Invalid, disabled, or ineligible coupon code "$code"!'),
                                backgroundColor: Colors.red.shade700,
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primaryPurple,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('APPLY', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      ),
                    ],
                  ),

                  if (hasApplied) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFA7F3D0)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Active: ${currentCart.appliedCouponCode} (Saved ₹${currentCart.couponDiscount.toInt()})',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF065F46)),
                          ),
                          TextButton(
                            onPressed: () {
                              modalRef.read(cartProvider.notifier).removeCoupon();
                              Navigator.pop(ctx);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Coupon removed')),
                              );
                            },
                            child: const Text('REMOVE', style: TextStyle(fontSize: 11, color: Colors.red, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),
                  const Text('Available Coupons:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: _textDark)),
                  const SizedBox(height: 8),

                  if (activeVisibleCoupons.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text('No promo coupons currently available.', style: TextStyle(fontSize: 12, color: _textMuted)),
                    )
                  else
                    ...activeVisibleCoupons.map((coupon) {
                      final bool isThisApplied = currentCart.appliedCouponCode == coupon.code;
                      final bool isEligible = currentCart.subtotal >= coupon.minSpend;
                      final discountLabel = coupon.discountType == 'percentage'
                          ? '${coupon.discountValue.toInt()}% OFF'
                          : '₹${coupon.discountValue.toInt()} OFF';

                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: isThisApplied ? _primaryPurple : const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: _primaryPurple.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.local_offer, color: _primaryPurple, size: 16),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        coupon.code,
                                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: _textDark),
                                      ),
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFECFDF5),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          discountLabel,
                                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF059669)),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    coupon.title,
                                    style: const TextStyle(fontSize: 11, color: _textMuted),
                                  ),
                                ],
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                if (!isEligible) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Add items worth ₹${(coupon.minSpend - currentCart.subtotal).toInt()} more to use ${coupon.code}')),
                                  );
                                  return;
                                }
                                modalRef.read(cartProvider.notifier).applyCouponModel(coupon);
                                Navigator.pop(ctx);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Applied ${coupon.code}!')),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isThisApplied ? const Color(0xFF16A34A) : _primaryPurple,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: Text(
                                isThisApplied ? 'APPLIED' : 'APPLY',
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
