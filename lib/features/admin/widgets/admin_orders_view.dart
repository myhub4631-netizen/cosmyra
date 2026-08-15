import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../orders/models/order_model.dart';
import '../../orders/repositories/order_repository.dart';
import '../../cart/models/cart_item_model.dart';
import '../../catalog/models/product_model.dart';

class AdminOrdersView extends ConsumerStatefulWidget {
  const AdminOrdersView({super.key});

  @override
  ConsumerState<AdminOrdersView> createState() => _AdminOrdersViewState();
}

class _AdminOrdersViewState extends ConsumerState<AdminOrdersView> {
  String _searchQuery = '';
  String _selectedStatusTab = 'All';

  String _selectedDateRange = 'Last 30 Days';
  String _selectedSalesChannel = 'All Channels';
  String _selectedFulfillmentState = 'All';

  Map<String, dynamic>? _selectedOrder;
  bool _showRightPanel = true;

  void _showCreateOrderDialog() {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final addressCtrl = TextEditingController();
    final productCtrl = TextEditingController(text: 'Vaidyam Botanical Serum');
    final amountCtrl = TextEditingController(text: '499');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Create New Manual Order', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          content: SizedBox(
            width: 380,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Customer Name', hintText: 'e.g. Mahboob Hasan')),
                const SizedBox(height: 10),
                TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'Phone Number', hintText: 'e.g. +91 94730 40903')),
                const SizedBox(height: 10),
                TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Customer Email', hintText: 'e.g. 1mdollar2027@gmail.com')),
                const SizedBox(height: 10),
                TextField(controller: addressCtrl, decoration: const InputDecoration(labelText: 'Shipping Address', hintText: 'Flat 402, Green Valley, Patna')),
                const SizedBox(height: 10),
                TextField(controller: productCtrl, decoration: const InputDecoration(labelText: 'Product Name')),
                const SizedBox(height: 10),
                TextField(controller: amountCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Total Amount (₹)')),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4F46E5),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () async {
                final name = nameCtrl.text.trim().isEmpty ? 'Manual Order Customer' : nameCtrl.text.trim();
                final phone = phoneCtrl.text.trim().isEmpty ? '+91 94730 40903' : phoneCtrl.text.trim();
                final email = emailCtrl.text.trim().isEmpty ? '1mdollar2027@gmail.com' : emailCtrl.text.trim();
                final address = addressCtrl.text.trim().isEmpty ? 'Patna, Bihar' : addressCtrl.text.trim();
                final amt = double.tryParse(amountCtrl.text.trim()) ?? 499.0;
                final prodName = productCtrl.text.trim().isEmpty ? 'Vaidyam Botanical Serum' : productCtrl.text.trim();

                final dummyVariant = ProductVariant(
                  id: 'v-manual-${DateTime.now().millisecondsSinceEpoch}',
                  productId: 'p-manual-${DateTime.now().millisecondsSinceEpoch}',
                  sku: 'MAN-001',
                  sizeLabel: 'Standard Unit',
                  price: amt,
                  mrp: amt,
                  stock: 100,
                  isDefault: true,
                );

                final dummyProduct = ProductModel(
                  id: 'p-manual-${DateTime.now().millisecondsSinceEpoch}',
                  brandId: 'b-vaidyam',
                  categoryId: 'c-botanical',
                  name: prodName,
                  slug: 'manual-product',
                  description: 'Manual order item created by Admin',
                  ingredients: 'Natural Botanicals',
                  freeFromClaims: ['Paraben-Free'],
                  variants: [dummyVariant],
                  imageUrls: [],
                  isFeatured: false,
                );

                final cartItem = CartItem(
                  product: dummyProduct,
                  variant: dummyVariant,
                  quantity: 1,
                );

                await ref.read(orderRepositoryProvider).placeOrder(
                  isGuest: false,
                  customerName: name,
                  customerEmail: email,
                  customerPhone: phone,
                  shippingAddress: {
                    'name': name,
                    'phone': phone,
                    'address': address,
                    'city': 'Patna',
                    'state': 'Bihar',
                    'pincode': '800001',
                  },
                  cartItems: [cartItem],
                  subtotal: amt,
                  discount: 0,
                  shippingFee: 0,
                  totalAmount: amt,
                  paymentMethod: 'COD',
                );

                ref.invalidate(allAdminOrdersFutureProvider);
                ref.invalidate(userOrdersFutureProvider);

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Manual order created successfully!')),
                  );
                }
              },
              child: const Text('Create Order'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final ordersAsync = ref.watch(allAdminOrdersFutureProvider);

    final List<Map<String, dynamic>> ordersList = [];
    ordersAsync.whenData((realOrders) {
      for (var ro in realOrders) {
        final addressStr = [
          ro.shippingAddress['address'] ?? ro.shippingAddress['address_line1'] ?? '',
          ro.shippingAddress['city'] ?? '',
          ro.shippingAddress['state'] ?? '',
          ro.shippingAddress['pincode'] ?? '',
        ].where((s) => s.toString().isNotEmpty).join(', ');

        ordersList.add({
          'id': ro.orderNumber.isNotEmpty ? ro.orderNumber : ro.id,
          'realId': ro.id,
          'isNew': ro.fulfillmentStatus.toLowerCase() == 'placed',
          'itemsCount': ro.items.fold<int>(0, (sum, i) => sum + i.quantity),
          'shippingType': 'Standard',
          'customerName': ro.customerName.isNotEmpty ? ro.customerName : 'Customer',
          'customerEmail': ro.customerEmail,
          'customerPhone': ro.customerPhone,
          'amount': ro.totalAmount,
          'paymentType': ro.paymentMethod.toUpperCase() == 'COD' ? 'COD' : 'Prepaid',
          'paymentStatus': ro.paymentStatus.isNotEmpty ? (ro.paymentStatus[0].toUpperCase() + ro.paymentStatus.substring(1)) : 'Paid',
          'paymentMethod': ro.paymentMethod,
          'paymentId': 'pay_${ro.id}',
          'status': ro.fulfillmentStatus.isNotEmpty ? (ro.fulfillmentStatus[0].toUpperCase() + ro.fulfillmentStatus.substring(1)) : 'Placed',
          'courier': ro.courierPartner ?? 'Unassigned',
          'awb': ro.trackingNumber ?? '-',
          'date': DateFormat('dd MMM yyyy hh:mm a').format(ro.createdAt),
          'address': addressStr.isNotEmpty ? addressStr : 'Customer Address Provided',
          'subtotal': ro.subtotal,
          'shippingCharge': ro.shippingFee,
          'discount': ro.discount,
          'items': ro.items.map((i) => {
            'name': i.productName,
            'variant': '${i.variantName} x ${i.quantity}',
            'price': i.totalPrice,
          }).toList(),
        });
      }
    });

    final bool currentSelectedExists = _selectedOrder != null && ordersList.any((o) => o['id'] == _selectedOrder!['id']);
    if (!currentSelectedExists && ordersList.isNotEmpty) {
      _selectedOrder = ordersList.first;
    } else if (ordersList.isEmpty) {
      _selectedOrder = null;
    }

    final int allCount = ordersList.length;
    final int placedCount = ordersList.where((o) => o['status'].toString().toLowerCase() == 'placed').length;
    final int confirmedCount = ordersList.where((o) => o['status'].toString().toLowerCase() == 'confirmed').length;
    final int processingCount = ordersList.where((o) => o['status'].toString().toLowerCase() == 'processing').length;
    final int shippedCount = ordersList.where((o) => o['status'].toString().toLowerCase() == 'shipped').length;
    final int deliveredCount = ordersList.where((o) => o['status'].toString().toLowerCase() == 'delivered').length;
    final int cancelledCount = ordersList.where((o) => o['status'].toString().toLowerCase() == 'cancelled').length;
    final int returnedCount = ordersList.where((o) => o['status'].toString().toLowerCase() == 'returned').length;

    final List<Map<String, dynamic>> statusTabs = [
      {'name': 'All', 'count': '$allCount'},
      {'name': 'Placed', 'count': '$placedCount'},
      {'name': 'Confirmed', 'count': '$confirmedCount'},
      {'name': 'Processing', 'count': '$processingCount'},
      {'name': 'Shipped', 'count': '$shippedCount'},
      {'name': 'Delivered', 'count': '$deliveredCount'},
      {'name': 'Cancelled', 'count': '$cancelledCount'},
      {'name': 'Returned', 'count': '$returnedCount'},
    ];

    final filteredOrders = ordersList.where((o) {
      if (_searchQuery.isNotEmpty) {
        final numMatch = o['id'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
        final custMatch = o['customerName'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
        final phoneMatch = o['customerPhone'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
        final awbMatch = o['awb'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
        if (!numMatch && !custMatch && !phoneMatch && !awbMatch) return false;
      }
      if (_selectedStatusTab != 'All' && o['status'].toString().toLowerCase() != _selectedStatusTab.toLowerCase()) {
        return false;
      }
      return true;
    }).toList();

    final double totalRevenue = ordersList.fold<double>(0.0, (sum, o) => sum + ((o['amount'] as num?)?.toDouble() ?? 0.0));

    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth > 1150;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Page Header & Action Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Orders & Fulfillment',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF111827)),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Manage and track all customer orders across channels and couriers.',
                    style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
                  ),
                ],
              ),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: _showCreateOrderDialog,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Create Order', style: TextStyle(fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4F46E5),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 24),

          // 2. Metrics Bar
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildMetricCard('Total Orders', '$allCount', '+100% active', Icons.inventory_2_outlined, const Color(0xFFEEF2FF), const Color(0xFF4F46E5), true),
                const SizedBox(width: 16),
                _buildMetricCard('Pending Fulfillment', '${placedCount + confirmedCount + processingCount}', 'Requires action', Icons.pending_actions_outlined, const Color(0xFFFEF3C7), const Color(0xFFD97706), false),
                const SizedBox(width: 16),
                _buildMetricCard('Total Revenue', '₹${_formatCurrency(totalRevenue)}', 'Lifetime sales', Icons.account_balance_wallet_outlined, const Color(0xFFECFDF5), const Color(0xFF059669), true),
                const SizedBox(width: 16),
                _buildMetricCard('Completed Orders', '$deliveredCount', 'Delivered to users', Icons.task_alt_outlined, const Color(0xFFF0FDF4), const Color(0xFF16A34A), true),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // 3. Main Data Card & Right Drawer
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Column: Filter Tabs, Search Bar & Orders Table
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 2)),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Header & Filters
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                // Search Input
                                Expanded(
                                  child: Container(
                                    height: 40,
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF9FAFB),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: const Color(0xFFE5E7EB)),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.search, size: 18, color: Color(0xFF9CA3AF)),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: TextField(
                                            onChanged: (val) => setState(() => _searchQuery = val.trim()),
                                            style: const TextStyle(fontSize: 13),
                                            decoration: const InputDecoration(
                                              hintText: 'Search by Order ID, Customer, AWB...',
                                              hintStyle: TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)),
                                              border: InputBorder.none,
                                              isDense: true,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),

                            // Status Filter Chips
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: statusTabs.map((tab) {
                                  final isActive = _selectedStatusTab == tab['name'];
                                  return InkWell(
                                    onTap: () => setState(() => _selectedStatusTab = tab['name']),
                                    child: Container(
                                      margin: const EdgeInsets.only(right: 8),
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: isActive ? const Color(0xFF4F46E5) : const Color(0xFFF3F4F6),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Row(
                                        children: [
                                          Text(
                                            tab['name'],
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: isActive ? Colors.white : const Color(0xFF374151),
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: isActive ? Colors.white.withValues(alpha: 0.2) : Colors.white,
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: Text(
                                              tab['count'],
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: isActive ? Colors.white : const Color(0xFF6B7280),
                                              ),
                                            ),
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

                      const Divider(height: 1, color: Color(0xFFF3F4F6)),

                      if (filteredOrders.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(48),
                          alignment: Alignment.center,
                          child: Column(
                            children: [
                              const Icon(Icons.inventory_2_outlined, size: 56, color: Color(0xFF9CA3AF)),
                              const SizedBox(height: 12),
                              const Text('No Customer Orders Found', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF111827))),
                              const SizedBox(height: 4),
                              const Text('When customers place orders on Cosmyra, they will appear here for live tracking and fulfillment.', style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)), textAlign: TextAlign.center),
                              const SizedBox(height: 20),
                              ElevatedButton.icon(
                                onPressed: _showCreateOrderDialog,
                                icon: const Icon(Icons.add, size: 16),
                                label: const Text('Create Manual Order', style: TextStyle(fontWeight: FontWeight.bold)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF4F46E5),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                              ),
                            ],
                          ),
                        )
                      else ...[
                        // Table Columns Header
                        Container(
                          color: const Color(0xFFFAFAFA),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: Row(
                            children: const [
                              Expanded(flex: 3, child: Text('Order Details', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF6B7280)))),
                              Expanded(flex: 3, child: Text('Customer', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF6B7280)))),
                              Expanded(flex: 2, child: Text('Amount', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF6B7280)))),
                              Expanded(flex: 2, child: Text('Payment', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF6B7280)))),
                              Expanded(flex: 2, child: Text('Status', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF6B7280)))),
                              Expanded(flex: 3, child: Text('Fulfillment / Courier', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF6B7280)))),
                              Expanded(flex: 2, child: Text('Date', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF6B7280)))),
                              SizedBox(width: 70, child: Text('Actions', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF6B7280)), textAlign: TextAlign.right)),
                            ],
                          ),
                        ),

                        const Divider(height: 1, color: Color(0xFFF3F4F6)),

                        // Order Rows List
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: filteredOrders.length,
                          separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFF3F4F6)),
                          itemBuilder: (context, index) {
                            final order = filteredOrders[index];
                            final isSelected = _selectedOrder != null && _selectedOrder!['id'] == order['id'];

                            return InkWell(
                              onTap: () {
                                setState(() {
                                  _selectedOrder = order;
                                  _showRightPanel = true;
                                });
                              },
                              child: Container(
                                color: isSelected ? const Color(0xFFEEF2FF) : Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                child: Row(
                                  children: [
                                    // Order Details
                                    Expanded(
                                      flex: 3,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text(order['id'], style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
                                              if (order['isNew'] == true) ...[
                                                const SizedBox(width: 6),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                                  decoration: BoxDecoration(color: const Color(0xFFE0E7FF), borderRadius: BorderRadius.circular(4)),
                                                  child: const Text('NEW', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF4F46E5))),
                                                ),
                                              ],
                                            ],
                                          ),
                                          const SizedBox(height: 2),
                                          Text('${order['itemsCount']} Items • ${order['shippingType']}', style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
                                        ],
                                      ),
                                    ),

                                    // Customer Name & Phone
                                    Expanded(
                                      flex: 3,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(order['customerName'], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
                                          const SizedBox(height: 2),
                                          Text(order['customerPhone'], style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
                                        ],
                                      ),
                                    ),

                                    // Amount
                                    Expanded(
                                      flex: 2,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('₹${_formatCurrency(order['amount'])}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
                                          const SizedBox(height: 2),
                                          Text(order['paymentType'], style: const TextStyle(fontSize: 10, color: Color(0xFF059669), fontWeight: FontWeight.w600)),
                                        ],
                                      ),
                                    ),

                                    // Payment Status & Method
                                    Expanded(
                                      flex: 2,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            order['paymentStatus'],
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: _getPaymentStatusColor(order['paymentStatus']),
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(order['paymentMethod'], style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
                                        ],
                                      ),
                                    ),

                                    // Order Status Pill
                                    Expanded(
                                      flex: 2,
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: _getStatusPillBg(order['status']),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            order['status'],
                                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _getStatusPillTextColor(order['status'])),
                                          ),
                                        ),
                                      ),
                                    ),

                                    // Fulfillment / Courier
                                    Expanded(
                                      flex: 3,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(order['courier'], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF374151))),
                                          if (order['awb'] != '-') ...[
                                            const SizedBox(height: 2),
                                            Text('AWB: ${order['awb']}', style: const TextStyle(fontSize: 10, color: Color(0xFF6B7280))),
                                          ],
                                        ],
                                      ),
                                    ),

                                    // Date
                                    Expanded(
                                      flex: 2,
                                      child: Text(order['date'], style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
                                    ),

                                    // Actions
                                    SizedBox(
                                      width: 70,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.remove_red_eye_outlined, size: 16, color: Color(0xFF6B7280)),
                                            onPressed: () {
                                              setState(() {
                                                _selectedOrder = order;
                                                _showRightPanel = true;
                                              });
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // Right Column: Selected Order Details Drawer Panel
              if (_showRightPanel && _selectedOrder != null && isWideScreen) ...[
                const SizedBox(width: 20),
                SizedBox(
                  width: 340,
                  child: _buildOrderDetailsDrawer(_selectedOrder!),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String label, String value, String trend, IconData icon, Color iconBg, Color iconColor, bool isPositive) {
    return Container(
      width: 210,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 12),
          Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280), fontWeight: FontWeight.w500)),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
          const SizedBox(height: 4),
          Text(
            trend,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: isPositive ? const Color(0xFF059669) : const Color(0xFFDC2626),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderDetailsDrawer(Map<String, dynamic> order) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 16, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text('Order ${order['id']}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 18, color: Color(0xFF6B7280)),
                onPressed: () => setState(() => _showRightPanel = false),
              ),
            ],
          ),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: const Color(0xFFEEF2FF), borderRadius: BorderRadius.circular(4)),
                child: Text(order['status'], style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF4F46E5))),
              ),
              const SizedBox(width: 8),
              Text(order['date'], style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
            ],
          ),

          const SizedBox(height: 16),

          // Customer Information Card
          const Text('Customer Information', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF374151))),
          const SizedBox(height: 8),
          Text(order['customerName'], style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF4F46E5))),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.email_outlined, size: 12, color: Color(0xFF6B7280)),
              const SizedBox(width: 6),
              Expanded(child: Text(order['customerEmail'], style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280)), overflow: TextOverflow.ellipsis)),
            ],
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              const Icon(Icons.phone_outlined, size: 12, color: Color(0xFF6B7280)),
              const SizedBox(width: 6),
              Text(order['customerPhone'], style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
            ],
          ),

          const SizedBox(height: 16),

          // Delivery Address Card
          const Text('Delivery Address', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF374151))),
          const SizedBox(height: 6),
          Text(order['address'], style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280), height: 1.4)),

          const SizedBox(height: 16),

          // Order Summary Breakdown
          const Text('Order Summary', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF374151))),
          const SizedBox(height: 8),
          _buildSummaryRow('Subtotal (${order['itemsCount']} Items)', '₹${_formatCurrency(order['subtotal'])}'),
          _buildSummaryRow('Shipping Charge', '₹${_formatCurrency(order['shippingCharge'])}'),
          _buildSummaryRow('Discount', '- ₹${_formatCurrency(order['discount'])}', isDiscount: true),
          const Divider(height: 16, color: Color(0xFFF3F4F6)),
          _buildSummaryRow('Total Amount', '₹${_formatCurrency(order['amount'])}', isTotal: true),

          const SizedBox(height: 16),

          // Items List
          Text('Items (${order['itemsCount']})', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF374151))),
          const SizedBox(height: 8),
          Column(
            children: (order['items'] as List).map<Widget>((item) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(6)),
                      child: const Icon(Icons.spa, size: 16, color: Color(0xFF059669)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item['name'], style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF111827)), overflow: TextOverflow.ellipsis),
                          Text(item['variant'], style: const TextStyle(fontSize: 10, color: Color(0xFF6B7280))),
                        ],
                      ),
                    ),
                    Text('₹${_formatCurrency(item['price'])}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
                  ],
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 16),

          // Quick Fulfillment Status & Courier Update
          const Text('Update Order Fulfillment', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF374151))),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: ['Placed', 'Confirmed', 'Processing', 'Shipped', 'Delivered', 'Cancelled'].map((st) {
              final isCurrent = order['status'].toString().toLowerCase() == st.toLowerCase();
              return ChoiceChip(
                label: Text(st, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isCurrent ? Colors.white : const Color(0xFF374151))),
                selected: isCurrent,
                selectedColor: const Color(0xFF4F46E5),
                backgroundColor: const Color(0xFFF3F4F6),
                side: BorderSide.none,
                onSelected: (sel) async {
                  if (sel) {
                    final realId = order['realId'] ?? order['id'];
                    await ref.read(orderRepositoryProvider).updateOrderFulfillment(
                          orderId: realId.toString(),
                          status: st.toLowerCase(),
                        );
                    ref.invalidate(allAdminOrdersFutureProvider);
                    ref.invalidate(userOrdersFutureProvider);
                    setState(() {
                      order['status'] = st;
                    });
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Order status updated to $st')),
                      );
                    }
                  }
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String val, {bool isTotal = false, bool isPaid = false, bool isDiscount = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isTotal ? const Color(0xFF111827) : const Color(0xFF6B7280),
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            val,
            style: TextStyle(
              fontSize: isTotal ? 13 : 11,
              fontWeight: FontWeight.bold,
              color: isDiscount
                  ? const Color(0xFF059669)
                  : (isPaid ? const Color(0xFF059669) : const Color(0xFF111827)),
            ),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(dynamic amount) {
    if (amount == null) return '0.00';
    final double numAmount = (amount is num) ? amount.toDouble() : (double.tryParse(amount.toString()) ?? 0.0);
    return numAmount.toStringAsFixed(2);
  }

  Color _getPaymentStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
      case 'captured':
        return const Color(0xFF059669);
      case 'pending':
        return const Color(0xFFD97706);
      case 'failed':
      case 'refunded':
        return const Color(0xFFDC2626);
      default:
        return const Color(0xFF6B7280);
    }
  }

  Color _getStatusPillBg(String status) {
    switch (status.toLowerCase()) {
      case 'placed':
        return const Color(0xFFEEF2FF);
      case 'confirmed':
        return const Color(0xFFECFDF5);
      case 'processing':
        return const Color(0xFFFEF3C7);
      case 'shipped':
        return const Color(0xFFE0F2FE);
      case 'delivered':
        return const Color(0xFFF0FDF4);
      case 'cancelled':
      case 'returned':
        return const Color(0xFFFEE2E2);
      default:
        return const Color(0xFFF3F4F6);
    }
  }

  Color _getStatusPillTextColor(String status) {
    switch (status.toLowerCase()) {
      case 'placed':
        return const Color(0xFF4F46E5);
      case 'confirmed':
        return const Color(0xFF059669);
      case 'processing':
        return const Color(0xFFD97706);
      case 'shipped':
        return const Color(0xFF0284C7);
      case 'delivered':
        return const Color(0xFF16A34A);
      case 'cancelled':
      case 'returned':
        return const Color(0xFFDC2626);
      default:
        return const Color(0xFF374151);
    }
  }
}
