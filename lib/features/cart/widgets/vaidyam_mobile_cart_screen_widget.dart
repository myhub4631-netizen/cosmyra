import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../controllers/cart_controller.dart';
import '../../catalog/widgets/product_image_widget.dart';
import '../../navigation/widgets/vaidyam_mobile_bottom_nav_bar.dart';

class VaidyamMobileCartScreenWidget extends ConsumerStatefulWidget {
  final List<Map<String, dynamic>> itemsList;
  final double totalMrp;
  final double subtotal;
  final double discount;
  final double finalTotal;
  final int itemCount;

  const VaidyamMobileCartScreenWidget({
    super.key,
    required this.itemsList,
    required this.totalMrp,
    required this.subtotal,
    required this.discount,
    required this.finalTotal,
    required this.itemCount,
  });

  @override
  ConsumerState<VaidyamMobileCartScreenWidget> createState() => _VaidyamMobileCartScreenWidgetState();
}

class _VaidyamMobileCartScreenWidgetState extends ConsumerState<VaidyamMobileCartScreenWidget> {
  static const Color _primaryPurple = Color(0xFF4338CA);
  static const Color _lightBg = Color(0xFFF8FAFC);
  static const Color _textDark = Color(0xFF0F172A);
  static const Color _textMuted = Color(0xFF64748B);

  // Track checked state per cart item key
  final Set<String> _checkedItems = {};

  @override
  void initState() {
    super.initState();
    // Default all items checked
    for (var item in widget.itemsList) {
      final String k = item['key']?.toString() ?? '${item['id']}_${item['index']}';
      _checkedItems.add(k);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _lightBg,
      bottomNavigationBar: widget.itemsList.isNotEmpty
          ? Container(
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
                          '₹${widget.finalTotal.toStringAsFixed(0)}',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF4F46E5)),
                        ),
                        const Text(
                          'Total Payable',
                          style: TextStyle(fontSize: 10, color: Color(0xFF64748B), fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const Spacer(),
                    ElevatedButton.icon(
                      onPressed: () => context.push('/checkout'),
                      icon: const Icon(Icons.arrow_forward_rounded, size: 18, color: Colors.white),
                      label: const Text('Proceed to Checkout', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4F46E5),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 3,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : const VaidyamMobileBottomNavBar(activeTab: 'Cart'),
      body: SafeArea(
        child: widget.itemsList.isEmpty
            ? _buildEmptyCartView(context)
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Header Bar: My Cart (3) + Wishlist Heart
                    _buildCartHeader(context),

                    const SizedBox(height: 16),

                    // 2. Savings Highlight Banner
                    if (widget.discount > 0) _buildSavingsBanner(),

                    const SizedBox(height: 16),

                    // 3. Cart Items List Cards
                    _buildCartItemsList(),

                    const SizedBox(height: 20),

                    // 4. Price Details Card
                    _buildPriceDetailsCard(),

                    const SizedBox(height: 20),

                    // 5. Proceed to Checkout Button
                    _buildCheckoutButton(context),

                    const SizedBox(height: 28),
                  ],
                ),
              ),
      ),
    );
  }

  // 1. Cart Header Bar
  Widget _buildCartHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const SizedBox(width: 32), // Spacer for centering
        Text(
          'My Cart (${widget.itemCount})',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: _textDark,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.favorite_border_rounded, color: _textDark, size: 24),
          onPressed: () => context.push('/wishlist'),
        ),
      ],
    );
  }

  // 2. Savings Banner
  Widget _buildSavingsBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFDCFCE7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFBBF7D0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(
              color: Color(0xFF16A34A),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.local_offer_rounded, color: Colors.white, size: 14),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Yay! You saved ₹${widget.discount.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')} on this order',
              style: const TextStyle(
                color: Color(0xFF15803D),
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 3. Cart Items List
  Widget _buildCartItemsList() {
    return Column(
      children: widget.itemsList.map((item) {
        final int index = (item['index'] is int) ? item['index'] as int : widget.itemsList.indexOf(item);
        final String key = item['key']?.toString() ?? '${item['id']}_$index';
        final bool isChecked = _checkedItems.contains(key);
        final double price = (item['price'] as num).toDouble();
        final double mrp = (item['mrp'] as num).toDouble();
        final int qty = (item['quantity'] as num).toInt();
        final int discountPct = mrp > price ? (((mrp - price) / mrp) * 100).round() : 0;
        final String name = (item['name'] ?? item['productName'] ?? 'Product') as String;
        final String variantLabel = (item['variant'] ?? item['variantLabel'] ?? 'Standard Pack') as String;
        final String image = (item['image'] ?? item['imageUrl'] ?? 'assets/images/shampoo.jpg') as String;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
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
              // Checkbox
              GestureDetector(
                onTap: () {
                  setState(() {
                    if (isChecked) {
                      _checkedItems.remove(key);
                    } else {
                      _checkedItems.add(key);
                    }
                  });
                },
                child: Container(
                  width: 22,
                  height: 22,
                  margin: const EdgeInsets.only(top: 10, right: 10),
                  decoration: BoxDecoration(
                    color: isChecked ? _primaryPurple : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isChecked ? _primaryPurple : const Color(0xFF94A3B8),
                      width: 1.5,
                    ),
                  ),
                  child: isChecked
                      ? const Icon(Icons.check_rounded, color: Colors.white, size: 16)
                      : null,
                ),
              ),

              // Product Image
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 80,
                  height: 80,
                  color: const Color(0xFFF8FAFC),
                  child: ProductImageWidget(
                    imageUrl: image,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Details & Stepper
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: _textDark,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      variantLabel,
                      style: const TextStyle(fontSize: 11, color: _textMuted),
                    ),
                    const SizedBox(height: 6),

                    // Price, MRP & Discount Tag
                    Row(
                      children: [
                        Text(
                          '₹${price.toInt()}',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: _textDark,
                          ),
                        ),
                        if (mrp > price) ...[
                          const SizedBox(width: 6),
                          Text(
                            '₹${mrp.toInt()}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: _textMuted,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '$discountPct% OFF',
                            style: const TextStyle(
                              color: Color(0xFFEF4444),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Stepper & Trash Remove
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Pill Stepper (- 1 +)
                        Container(
                          height: 32,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove, size: 14, color: _textDark),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                onPressed: () {
                                  if (qty > 1) {
                                    ref.read(cartProvider.notifier).updateQuantity(index, qty - 1);
                                  } else {
                                    ref.read(cartProvider.notifier).removeItem(index);
                                  }
                                },
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                child: Text(
                                  '$qty',
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _textDark),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add, size: 14, color: _textDark),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                onPressed: () {
                                  ref.read(cartProvider.notifier).updateQuantity(index, qty + 1);
                                },
                              ),
                            ],
                          ),
                        ),

                        // Trash Can Delete Button
                        IconButton(
                          icon: const Icon(Icons.delete_outline_rounded, color: _textMuted, size: 20),
                          onPressed: () {
                            ref.read(cartProvider.notifier).removeItem(index);
                          },
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

  // 4. Price Details Card
  Widget _buildPriceDetailsCard() {
    final formatCurrency = (double amount) {
      return '₹${amount.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}';
    };

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Price Details',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: _textDark,
            ),
          ),
          const SizedBox(height: 14),

          // Total MRP
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total MRP', style: TextStyle(fontSize: 13, color: _textMuted)),
              Text(
                formatCurrency(widget.totalMrp),
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _textDark),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Discount on MRP
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Discount on MRP', style: TextStyle(fontSize: 13, color: _textMuted)),
              Text(
                '- ${formatCurrency(widget.discount)}',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF16A34A)),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Shipping Charges
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('Shipping Charges', style: TextStyle(fontSize: 13, color: _textMuted)),
              Text(
                'Free',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF16A34A)),
              ),
            ],
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: Color(0xFFE2E8F0)),
          ),

          // Grand Total Amount
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Total Amount',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: _textDark),
                  ),
                  SizedBox(height: 2),
                  Text(
                    '(Inclusive of all taxes)',
                    style: TextStyle(fontSize: 10, color: _textMuted),
                  ),
                ],
              ),
              Text(
                formatCurrency(widget.finalTotal),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: _textDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 5. Proceed to Checkout Button
  Widget _buildCheckoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: () => context.push('/checkout'),
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryPurple,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 2,
        ),
        child: const Text(
          'Proceed to Checkout',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // Empty Cart View
  Widget _buildEmptyCartView(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: _primaryPurple.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.shopping_bag_outlined, color: _primaryPurple, size: 64),
            ),
            const SizedBox(height: 20),
            const Text(
              'Your Cart is Empty',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: _textDark),
            ),
            const SizedBox(height: 8),
            const Text(
              'Looks like you haven\'t added any botanical formulations yet.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: _textMuted),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/shop'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Start Shopping', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
