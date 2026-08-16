import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../cart/controllers/cart_controller.dart';
import '../repositories/order_repository.dart';
import '../../navigation/widgets/vaidyam_mobile_bottom_nav_bar.dart';

class VaidyamMobileOrdersScreenWidget extends ConsumerStatefulWidget {
  const VaidyamMobileOrdersScreenWidget({super.key});

  @override
  ConsumerState<VaidyamMobileOrdersScreenWidget> createState() => _VaidyamMobileOrdersScreenWidgetState();
}

class _VaidyamMobileOrdersScreenWidgetState extends ConsumerState<VaidyamMobileOrdersScreenWidget> {
  static const Color _primaryPurple = Color(0xFF4338CA);
  static const Color _lightBg = Color(0xFFF8FAFC);
  static const Color _textDark = Color(0xFF0F172A);
  static const Color _textMuted = Color(0xFF64748B);

  String _activeStatus = 'All Orders';
  String _sortBy = 'Date Placed';

  final List<Map<String, dynamic>> _statusFilters = [
    {'label': 'All Orders', 'count': '24', 'icon': Icons.shopping_bag_outlined},
    {'label': 'Processing', 'count': '3', 'icon': Icons.inventory_2_outlined},
    {'label': 'Shipped', 'count': '7', 'icon': Icons.local_shipping_outlined},
    {'label': 'Delivered', 'count': '12', 'icon': Icons.check_circle_outline_rounded},
    {'label': 'Cancelled', 'count': '2', 'icon': Icons.cancel_outlined},
    {'label': 'Returns', 'count': '1', 'icon': Icons.autorenew_rounded},
  ];

  final List<Map<String, dynamic>> _demoOrdersList = [
    {
      'id': '#ORD12345678',
      'date': '16 May 2024',
      'itemsCount': '2 Items',
      'price': '₹3,798',
      'isPaid': true,
      'status': 'Delivered',
      'statusText': 'Delivered on 20 May 2024',
      'image': 'assets/images/shampoo.jpg',
      'type': 'delivered',
    },
    {
      'id': '#ORD12345677',
      'date': '14 May 2024',
      'itemsCount': '1 Item',
      'price': '₹2,499',
      'isPaid': true,
      'status': 'Shipped',
      'statusText': 'Expected Delivery 22 May 2024',
      'image': 'assets/images/facewash.jpg',
      'type': 'shipped',
    },
    {
      'id': '#ORD12345676',
      'date': '12 May 2024',
      'itemsCount': '1 Item',
      'price': '₹7,499',
      'isPaid': true,
      'status': 'Processing',
      'statusText': 'Your order is being processed',
      'image': 'assets/images/soap.jpg',
      'type': 'processing',
    },
    {
      'id': '#ORD12345675',
      'date': '10 May 2024',
      'itemsCount': '2 Items',
      'price': '₹1,799',
      'isPaid': true,
      'status': 'Cancelled',
      'statusText': 'Cancelled on 11 May 2024',
      'image': 'assets/images/kumkumadi.jpg',
      'type': 'cancelled',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartProvider);
    final int cartCount = cartState.totalItemCount;
    final ordersAsync = ref.watch(userOrdersFutureProvider);
    final userOrders = ordersAsync.value ?? [];

    final List<Map<String, dynamic>> combinedOrders = [];

    for (var ro in userOrders) {
      final String firstImg = ro.items.isNotEmpty && ro.items.first.productName.contains('Shampoo')
          ? 'assets/images/shampoo.jpg'
          : (ro.items.isNotEmpty && ro.items.first.productName.contains('Soap') ? 'assets/images/soap.jpg' : 'assets/images/facewash.jpg');

      final String statusName = ro.fulfillmentStatus.substring(0, 1).toUpperCase() + ro.fulfillmentStatus.substring(1);

      combinedOrders.add({
        'id': ro.orderNumber,
        'date': '${ro.createdAt.day} May 2026',
        'itemsCount': '${ro.items.length} ${ro.items.length == 1 ? "Item" : "Items"}',
        'price': '₹${ro.totalAmount.toStringAsFixed(0)}',
        'isPaid': ro.paymentStatus == 'captured' || ro.paymentStatus == 'paid',
        'status': statusName,
        'statusText': 'Order ${ro.orderNumber} placed successfully',
        'image': firstImg,
        'type': ro.fulfillmentStatus.toLowerCase(),
      });
    }

    combinedOrders.addAll(_demoOrdersList);

    final filteredOrders = combinedOrders.where((order) {
      if (_activeStatus == 'All Orders') return true;
      return (order['status'] as String).toLowerCase() == _activeStatus.toLowerCase();
    }).toList();

    return Scaffold(
      backgroundColor: _lightBg,
      bottomNavigationBar: const VaidyamMobileBottomNavBar(activeTab: 'Account'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header Bar: Back Arrow + My Orders + Search + Cart
              _buildHeaderBar(context, cartCount),

              const SizedBox(height: 16),

              // 2. Horizontal Status Filter Scroll Bar
              _buildStatusFilterRow(combinedOrders),

              const SizedBox(height: 16),

              // 3. Sort & Filter Bar
              _buildSortFilterBar(),

              const SizedBox(height: 16),

              // 4. Order Item Cards List
              ...filteredOrders.map((order) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _buildOrderCard(context, order),
                  )),

              const SizedBox(height: 8),

              // 5. Help & Support Banner Box
              _buildNeedHelpCard(context),

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
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'My Orders',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: _textDark),
              ),
              Text(
                'Track and manage all your orders',
                style: TextStyle(fontSize: 11, color: _textMuted),
              ),
            ],
          ),
        ),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.search_rounded, color: _textDark, size: 22),
              onPressed: () => context.push('/shop'),
            ),
            Stack(
              clipBehavior: Clip.none,
              children: [
                IconButton(
                  icon: const Icon(Icons.shopping_cart_outlined, color: _textDark, size: 24),
                  onPressed: () => context.push('/cart'),
                ),
                if (cartCount > 0)
                  Positioned(
                    top: -2,
                    right: -2,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: _primaryPurple,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                      child: Center(
                        child: Text(
                          '$cartCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
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

  // 2. Horizontal Status Filter Scroll Bar
  Widget _buildStatusFilterRow(List<Map<String, dynamic>> combinedOrders) {
    int allCount = combinedOrders.length;
    int processingCount = combinedOrders.where((o) => (o['status'] as String).toLowerCase() == 'processing' || (o['status'] as String).toLowerCase() == 'placed').length;
    int shippedCount = combinedOrders.where((o) => (o['status'] as String).toLowerCase() == 'shipped').length;
    int deliveredCount = combinedOrders.where((o) => (o['status'] as String).toLowerCase() == 'delivered').length;
    int cancelledCount = combinedOrders.where((o) => (o['status'] as String).toLowerCase() == 'cancelled').length;
    int returnsCount = combinedOrders.where((o) => (o['status'] as String).toLowerCase() == 'returns' || (o['status'] as String).toLowerCase() == 'returned').length;

    final List<Map<String, dynamic>> dynamicFilters = [
      {'label': 'All Orders', 'count': '$allCount', 'icon': Icons.shopping_bag_outlined},
      {'label': 'Processing', 'count': '$processingCount', 'icon': Icons.inventory_2_outlined},
      {'label': 'Shipped', 'count': '$shippedCount', 'icon': Icons.local_shipping_outlined},
      {'label': 'Delivered', 'count': '$deliveredCount', 'icon': Icons.check_circle_outline_rounded},
      {'label': 'Cancelled', 'count': '$cancelledCount', 'icon': Icons.cancel_outlined},
      {'label': 'Returns', 'count': '$returnsCount', 'icon': Icons.autorenew_rounded},
    ];

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: dynamicFilters.map((filter) {
            final String label = filter['label'] as String;
            final String count = filter['count'] as String;
            final IconData icon = filter['icon'] as IconData;
            final bool isActive = _activeStatus == label;

            return GestureDetector(
              onTap: () {
                setState(() {
                  _activeStatus = label;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                margin: const EdgeInsets.only(right: 6),
                decoration: BoxDecoration(
                  color: isActive ? const Color(0xFFF3E8FF) : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: isActive ? Border.all(color: _primaryPurple.withValues(alpha: 0.3)) : null,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      icon,
                      size: 20,
                      color: isActive ? _primaryPurple : _textMuted,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                        color: isActive ? _primaryPurple : _textDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      count,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: isActive ? _primaryPurple : _textMuted,
                      ),
                    ),
                    if (isActive)
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        width: 24,
                        height: 3,
                        decoration: BoxDecoration(
                          color: _primaryPurple,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // 3. Sort & Filter Bar
  Widget _buildSortFilterBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const Text('Sort by: ', style: TextStyle(fontSize: 12, color: _textMuted)),
            DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _sortBy,
                icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: _textDark),
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _textDark),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _sortBy = val;
                    });
                  }
                },
                items: const [
                  DropdownMenuItem(value: 'Date Placed', child: Text('Date Placed')),
                  DropdownMenuItem(value: 'Total Price', child: Text('Total Price')),
                  DropdownMenuItem(value: 'Status', child: Text('Status')),
                ],
              ),
            ),
          ],
        ),

        // Filter Action Button
        OutlinedButton.icon(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Order filters applied 🎯')),
            );
          },
          icon: const Icon(Icons.filter_list_rounded, size: 16, color: _textDark),
          label: const Text('Filter', style: TextStyle(fontSize: 12, color: _textDark, fontWeight: FontWeight.bold)),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            side: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
        ),
      ],
    );
  }

  // 4. Single Order Card Builder
  Widget _buildOrderCard(BuildContext context, Map<String, dynamic> order) {
    final String type = order['type'] as String;
    final String status = order['status'] as String;
    final String statusText = order['statusText'] as String;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top Info Row
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Thumbnail
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Icon(
                      _getOrderProductIcon(type),
                      color: _primaryPurple,
                      size: 36,
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // Order Meta Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Order ID',
                        style: TextStyle(fontSize: 10, color: _textMuted),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        order['id'] as String,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: _textDark),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${order['date']} • ${order['itemsCount']}',
                        style: const TextStyle(fontSize: 11, color: _textMuted),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Text(
                            order['price'] as String,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: _textDark),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3E8FF),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'Paid',
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: _primaryPurple),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Status Badge Right
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildStatusPill(status),
                    const SizedBox(height: 6),
                    SizedBox(
                      width: 110,
                      child: Text(
                        statusText,
                        style: const TextStyle(fontSize: 10, color: _textMuted),
                        textAlign: TextAlign.end,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Icon(Icons.chevron_right_rounded, color: _textMuted, size: 20),
                  ],
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: Color(0xFFF1F5F9)),

          // Bottom Quick Action Buttons Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: _buildActionRowForType(context, type),
          ),
        ],
      ),
    );
  }

  // Get status pill widget
  Widget _buildStatusPill(String status) {
    Color bg = const Color(0xFFF1F5F9);
    Color fg = _textDark;
    IconData icon = Icons.info_outline;

    if (status == 'Delivered') {
      bg = const Color(0xFFDCFCE7);
      fg = const Color(0xFF15803D);
      icon = Icons.check_circle_outline_rounded;
    } else if (status == 'Shipped') {
      bg = const Color(0xFFE0F2FE);
      fg = const Color(0xFF0284C7);
      icon = Icons.local_shipping_outlined;
    } else if (status == 'Processing') {
      bg = const Color(0xFFFEF3C7);
      fg = const Color(0xFFD97706);
      icon = Icons.hourglass_empty_rounded;
    } else if (status == 'Cancelled') {
      bg = const Color(0xFFFEE2E2);
      fg = const Color(0xFFDC2626);
      icon = Icons.cancel_outlined;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: fg),
          const SizedBox(width: 4),
          Text(
            status,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: fg),
          ),
        ],
      ),
    );
  }

  // Action Buttons per Order Type matching screenshot 1-to-1
  Widget _buildActionRowForType(BuildContext context, String type) {
    if (type == 'delivered') {
      return Row(
        children: [
          Expanded(child: _buildActionButton(Icons.star_outline_rounded, 'Rate & Review', () => _showReviewModal(context))),
          _buildVerticalDivider(),
          Expanded(child: _buildActionButton(Icons.location_on_outlined, 'Track Order', () => _showTrackingModal(context))),
          _buildVerticalDivider(),
          Expanded(child: _buildActionButton(Icons.description_outlined, 'View Invoice', () => _showInvoiceModal(context))),
          _buildVerticalDivider(),
          Expanded(child: _buildActionButton(Icons.autorenew_rounded, 'Reorder', () => _reorderItems(context))),
        ],
      );
    } else if (type == 'shipped') {
      return Row(
        children: [
          Expanded(child: _buildActionButton(Icons.location_on_outlined, 'Track Order', () => _showTrackingModal(context))),
          _buildVerticalDivider(),
          Expanded(child: _buildActionButton(Icons.description_outlined, 'View Invoice', () => _showInvoiceModal(context))),
          _buildVerticalDivider(),
          Expanded(child: _buildActionButton(Icons.cancel_outlined, 'Cancel Order', () => _showCancelModal(context), color: const Color(0xFFDC2626))),
          _buildVerticalDivider(),
          Expanded(child: _buildActionButton(Icons.autorenew_rounded, 'Reorder', () => _reorderItems(context))),
        ],
      );
    } else if (type == 'processing') {
      return Row(
        children: [
          Expanded(child: _buildActionButton(Icons.cancel_outlined, 'Cancel Order', () => _showCancelModal(context), color: const Color(0xFFDC2626))),
          _buildVerticalDivider(),
          Expanded(child: _buildActionButton(Icons.description_outlined, 'View Invoice', () => _showInvoiceModal(context))),
          _buildVerticalDivider(),
          Expanded(child: _buildActionButton(Icons.edit_outlined, 'Edit Order', () => _showEditModal(context))),
        ],
      );
    } else {
      // Cancelled
      return Row(
        children: [
          Expanded(child: _buildActionButton(Icons.description_outlined, 'View Details', () => _showInvoiceModal(context))),
          _buildVerticalDivider(),
          Expanded(child: _buildActionButton(Icons.shopping_cart_outlined, 'Buy Again', () => _reorderItems(context))),
        ],
      );
    }
  }

  // Action Button Item
  Widget _buildActionButton(IconData icon, String label, VoidCallback onTap, {Color? color}) {
    final c = color ?? _textDark;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: c),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: c),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerticalDivider() {
    return Container(height: 16, width: 1, color: const Color(0xFFE2E8F0));
  }

  // 5. Need Help Card
  Widget _buildNeedHelpCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F3FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFDDD6FE)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _primaryPurple.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(Icons.card_giftcard_rounded, color: _primaryPurple, size: 24),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Need help with your order?',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: _textDark),
                ),
                SizedBox(height: 2),
                Text(
                  "We're here to help. Contact our support team.",
                  style: TextStyle(fontSize: 10, color: _textMuted),
                ),
              ],
            ),
          ),
          OutlinedButton.icon(
            onPressed: () => _showSupportModal(context),
            icon: const Icon(Icons.chat_bubble_outline_rounded, size: 14, color: _primaryPurple),
            label: const Text('Contact Support', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _primaryPurple)),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              side: const BorderSide(color: _primaryPurple),
              backgroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getOrderProductIcon(String type) {
    if (type == 'delivered') return Icons.headphones_rounded;
    if (type == 'shipped') return Icons.watch_rounded;
    if (type == 'processing') return Icons.checkroom_rounded;
    return Icons.spa_rounded;
  }

  // Modals & Action Handlers
  void _showTrackingModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('Order Tracking 📍', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            Text('• Order Placed: 16 May 2024, 10:30 AM'),
            Text('• Out for Delivery: 20 May 2024, 08:00 AM'),
            Text('• Delivered: 20 May 2024, 02:15 PM'),
          ],
        ),
      ),
    );
  }

  void _showInvoiceModal(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Downloading Order Invoice PDF... 📄')),
    );
  }

  void _showReviewModal(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Opening Product Rating & Review dialog ⭐')),
    );
  }

  void _showCancelModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Order?'),
        content: const Text('Are you sure you want to cancel this order? Refund will be processed in 24 hours.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('No')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Order Cancelled Successfully ❌')));
            },
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }

  void _showEditModal(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Editing order delivery address... ✏️')),
    );
  }

  void _reorderItems(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Items added to cart! Proceeding to Checkout 🛒')),
    );
  }

  void _showSupportModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('Support Team 🎧', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            Text('WhatsApp: +91 94730 40903'),
            Text('Email: support@cosmyra.cloud'),
            Text('Helpline: 1800-200-9999 (24/7 Mon-Sun)'),
          ],
        ),
      ),
    );
  }
}
