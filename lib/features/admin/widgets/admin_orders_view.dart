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
            child: SingleChildScrollView(
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

  void _showEditOrderDialog(Map<String, dynamic> order) {
    final String realId = (order['realId'] ?? order['id']).toString();
    final nameCtrl = TextEditingController(text: order['customerName']?.toString() ?? '');
    final emailCtrl = TextEditingController(text: order['customerEmail']?.toString() ?? '');
    final phoneCtrl = TextEditingController(text: order['customerPhone']?.toString() ?? '');
    final addressCtrl = TextEditingController(text: order['address']?.toString() ?? '');
    final courierCtrl = TextEditingController(text: order['courier']?.toString() == '-' ? '' : order['courier']?.toString() ?? '');
    final awbCtrl = TextEditingController(text: order['awb']?.toString() == '-' ? '' : order['awb']?.toString() ?? '');
    final amountCtrl = TextEditingController(text: order['amount']?.toString() ?? '0');

    String paymentStatus = order['paymentStatus']?.toString().toLowerCase() ?? 'pending';
    String fulfillmentStatus = order['status']?.toString().toLowerCase() ?? 'placed';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text('Edit Order Details: ${order['id']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              content: SizedBox(
                width: 480,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Customer Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF4F46E5))),
                      const SizedBox(height: 8),
                      TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Customer Full Name', border: OutlineInputBorder())),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(child: TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email Address', border: OutlineInputBorder()))),
                          const SizedBox(width: 10),
                          Expanded(child: TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'Phone Number', border: OutlineInputBorder()))),
                        ],
                      ),
                      const SizedBox(height: 10),
                      TextField(controller: addressCtrl, decoration: const InputDecoration(labelText: 'Shipping Address', border: OutlineInputBorder())),
                      const SizedBox(height: 16),
                      const Text('Payment & Amounts', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF4F46E5))),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: ['pending', 'captured', 'failed', 'refunded'].contains(paymentStatus) ? paymentStatus : 'pending',
                              decoration: const InputDecoration(labelText: 'Payment Status', border: OutlineInputBorder()),
                              items: const [
                                DropdownMenuItem(value: 'pending', child: Text('Pending ⏳')),
                                DropdownMenuItem(value: 'captured', child: Text('Paid / Captured ✅')),
                                DropdownMenuItem(value: 'failed', child: Text('Failed ❌')),
                                DropdownMenuItem(value: 'refunded', child: Text('Refunded 💸')),
                              ],
                              onChanged: (val) => setModalState(() => paymentStatus = val ?? 'pending'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: amountCtrl,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(labelText: 'Total Amount (₹)', border: OutlineInputBorder()),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text('Fulfillment & Shipping', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF4F46E5))),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: ['placed', 'confirmed', 'processing', 'shipped', 'delivered', 'cancelled'].contains(fulfillmentStatus) ? fulfillmentStatus : 'placed',
                        decoration: const InputDecoration(labelText: 'Fulfillment Status', border: OutlineInputBorder()),
                        items: const [
                          DropdownMenuItem(value: 'placed', child: Text('Placed')),
                          DropdownMenuItem(value: 'confirmed', child: Text('Confirmed')),
                          DropdownMenuItem(value: 'processing', child: Text('Processing')),
                          DropdownMenuItem(value: 'shipped', child: Text('Shipped')),
                          DropdownMenuItem(value: 'delivered', child: Text('Delivered')),
                          DropdownMenuItem(value: 'cancelled', child: Text('Cancelled')),
                        ],
                        onChanged: (val) => setModalState(() => fulfillmentStatus = val ?? 'placed'),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(child: TextField(controller: courierCtrl, decoration: const InputDecoration(labelText: 'Courier Partner', hintText: 'e.g. Shiprocket', border: OutlineInputBorder()))),
                          const SizedBox(width: 10),
                          Expanded(child: TextField(controller: awbCtrl, decoration: const InputDecoration(labelText: 'AWB / Tracking No.', hintText: 'e.g. AWB987654', border: OutlineInputBorder()))),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4F46E5), foregroundColor: Colors.white),
                  onPressed: () async {
                    final newAmt = double.tryParse(amountCtrl.text.trim()) ?? (order['amount'] as num).toDouble();
                    await ref.read(orderRepositoryProvider).updateOrderFullDetails(
                      orderId: realId,
                      customerName: nameCtrl.text.trim(),
                      customerEmail: emailCtrl.text.trim(),
                      customerPhone: phoneCtrl.text.trim(),
                      shippingAddress: {'address': addressCtrl.text.trim()},
                      paymentStatus: paymentStatus,
                      fulfillmentStatus: fulfillmentStatus,
                      courierPartner: courierCtrl.text.trim(),
                      trackingNumber: awbCtrl.text.trim(),
                      totalAmount: newAmt,
                    );

                    ref.invalidate(allAdminOrdersFutureProvider);
                    ref.invalidate(userOrdersFutureProvider);

                    if (mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Order ${order['id']} updated successfully!')),
                      );
                    }
                  },
                  child: const Text('Save Changes'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDeleteOrderConfirmationDialog(Map<String, dynamic> order) {
    final String realId = (order['realId'] ?? order['id']).toString();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: const [
              Icon(Icons.warning_amber_rounded, color: Color(0xFFDC2626), size: 24),
              SizedBox(width: 8),
              Text('Delete Order', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ],
          ),
          content: Text(
            'Are you sure you want to delete order "${order['id']}" for ${order['customerName']}? This action cannot be undone.',
            style: const TextStyle(fontSize: 14, color: Color(0xFF374151)),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFDC2626), foregroundColor: Colors.white),
              onPressed: () async {
                await ref.read(orderRepositoryProvider).deleteOrder(realId);
                ref.invalidate(allAdminOrdersFutureProvider);
                ref.invalidate(userOrdersFutureProvider);

                if (_selectedOrder != null && _selectedOrder!['id'] == order['id']) {
                  setState(() {
                    _selectedOrder = null;
                    _showRightPanel = false;
                  });
                }

                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Order ${order['id']} has been deleted.')),
                  );
                }
              },
              child: const Text('Delete Order'),
            ),
          ],
        );
      },
    );
  }

  void _showPrintInvoiceDialog(Map<String, dynamic> order) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Invoice: ${order['id']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
            ],
          ),
          content: SizedBox(
            width: 500,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFE2E8F0))),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text('COSMYRA BOTANICALS', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF4F46E5))),
                            Text('Certified 100% Organic Formulations', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('DATE: ${order['date']}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
                            Text('STATUS: ${order['status'].toString().toUpperCase()}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF10B981))),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Billed To:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF475569))),
                  Text(order['customerName'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1E293B))),
                  Text('${order['customerPhone']} • ${order['customerEmail']}', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                  Text(order['address'], style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                  const SizedBox(height: 16),
                  const Text('Order Items Breakdown:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF475569))),
                  const SizedBox(height: 8),
                  Table(
                    border: TableBorder.all(color: const Color(0xFFE2E8F0)),
                    children: [
                      const TableRow(
                        decoration: BoxDecoration(color: Color(0xFFF1F5F9)),
                        children: [
                          Padding(padding: EdgeInsets.all(8), child: Text('Item', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                          Padding(padding: EdgeInsets.all(8), child: Text('Price', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                        ],
                      ),
                      ...(order['items'] as List).map((i) => TableRow(
                        children: [
                          Padding(padding: const EdgeInsets.all(8), child: Text('${i['name']} (${i['variant']})', style: const TextStyle(fontSize: 11))),
                          Padding(padding: const EdgeInsets.all(8), child: Text('₹${_formatCurrency(i['price'])}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                        ],
                      )),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Amount Paid / Due:', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: Color(0xFF1E293B))),
                      Text('₹${_formatCurrency(order['amount'])}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Color(0xFF4F46E5))),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invoice sent to print queue! 🖨️')));
              },
              icon: const Icon(Icons.print, size: 16),
              label: const Text('Print Invoice'),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4F46E5), foregroundColor: Colors.white),
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

    ordersAsync.whenData((models) {
      for (var o in models) {
        final String addrStr = o.shippingAddress.values
            .where((v) => v != null && v.toString().trim().isNotEmpty)
            .join(', ');

        ordersList.add({
          'realId': o.id,
          'id': o.orderNumber,
          'itemsCount': o.items.fold(0, (sum, i) => sum + i.quantity),
          'shippingType': 'Standard',
          'customerName': o.customerName,
          'customerPhone': o.customerPhone,
          'customerEmail': o.customerEmail,
          'address': addrStr.isEmpty ? 'Patna, Bihar' : addrStr,
          'amount': o.totalAmount,
          'subtotal': o.subtotal,
          'discount': o.discount,
          'shippingCharge': o.shippingFee,
          'paymentType': o.paymentMethod.toLowerCase().contains('cod') ? 'Prepaid / COD' : 'Prepaid',
          'paymentStatus': o.paymentStatus == 'captured' ? 'Captured' : (o.paymentStatus == 'refunded' ? 'Refunded' : 'Pending'),
          'paymentMethod': o.paymentMethod,
          'status': o.fulfillmentStatus.isNotEmpty
              ? '${o.fulfillmentStatus[0].toUpperCase()}${o.fulfillmentStatus.substring(1)}'
              : 'Placed',
          'courier': o.courierPartner ?? 'Unassigned',
          'awb': o.trackingNumber ?? '-',
          'date': DateFormat('dd MMM yyyy hh:mm a').format(o.createdAt),
          'isNew': DateTime.now().difference(o.createdAt).inHours < 24,
          'items': o.items
              .map((i) => {
                    'name': i.productName,
                    'variant': i.variantName,
                    'price': i.totalPrice,
                  })
              .toList(),
        });
      }
    });

    // 1. Filter by search
    List<Map<String, dynamic>> filteredOrders = ordersList.where((o) {
      final query = _searchQuery.toLowerCase();
      final id = o['id'].toString().toLowerCase();
      final name = o['customerName'].toString().toLowerCase();
      final awb = o['awb'].toString().toLowerCase();
      return id.contains(query) || name.contains(query) || awb.contains(query);
    }).toList();

    // 2. Filter by Tab Status
    if (_selectedStatusTab != 'All') {
      filteredOrders = filteredOrders.where((o) => o['status'].toString().toLowerCase() == _selectedStatusTab.toLowerCase()).toList();
    }

    // Set initial selected order
    if (_selectedOrder == null && filteredOrders.isNotEmpty) {
      _selectedOrder = filteredOrders.first;
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth > 1100;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Orders & Fulfillment 📦',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF111827)),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Manage and track all customer orders across channels and couriers.',
                    style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: _showCreateOrderDialog,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('+ Create Order', style: TextStyle(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4F46E5),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Top 4 Metric KPI Cards
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildMetricCard('Total Orders', '${ordersList.length}', '+100% active', Icons.shopping_bag_outlined, const Color(0xFFEEF2FF), const Color(0xFF4F46E5), true),
                const SizedBox(width: 16),
                _buildMetricCard('Pending Fulfillment', '${ordersList.where((o) => o['status'] != 'Delivered' && o['status'] != 'Cancelled').length}', 'Requires action', Icons.assignment_late_outlined, const Color(0xFFFEF3C7), const Color(0xFFD97706), false),
                const SizedBox(width: 16),
                _buildMetricCard('Total Revenue', '₹${_formatCurrency(ordersList.fold(0.0, (sum, o) => sum + (o['amount'] as num).toDouble()))}', 'Lifetime sales', Icons.account_balance_wallet_outlined, const Color(0xFFECFDF5), const Color(0xFF059669), true),
                const SizedBox(width: 16),
                _buildMetricCard('Completed Orders', '${ordersList.where((o) => o['status'] == 'Delivered').length}', 'Delivered to users', Icons.check_circle_outline, const Color(0xFFF0FDF4), const Color(0xFF16A34A), true),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Main Table Layout (Left: Table, Right: Drawer)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Column: Orders Table & Filters
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Search & Filters Bar
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    height: 42,
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
                                            onChanged: (val) => setState(() => _searchQuery = val),
                                            decoration: const InputDecoration(
                                              hintText: 'Search by Order ID, Customer, AWB...',
                                              hintStyle: TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)),
                                              border: InputBorder.none,
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

                            // Status Filter Tabs
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  {'title': 'All', 'count': '${ordersList.length}'},
                                  {'title': 'Placed', 'count': '${ordersList.where((o) => o['status'] == 'Placed').length}'},
                                  {'title': 'Confirmed', 'count': '${ordersList.where((o) => o['status'] == 'Confirmed').length}'},
                                  {'title': 'Processing', 'count': '${ordersList.where((o) => o['status'] == 'Processing').length}'},
                                  {'title': 'Shipped', 'count': '${ordersList.where((o) => o['status'] == 'Shipped').length}'},
                                  {'title': 'Delivered', 'count': '${ordersList.where((o) => o['status'] == 'Delivered').length}'},
                                  {'title': 'Cancelled', 'count': '${ordersList.where((o) => o['status'] == 'Cancelled').length}'},
                                ].map((tab) {
                                  final isActive = _selectedStatusTab == tab['title'];
                                  return InkWell(
                                    onTap: () => setState(() => _selectedStatusTab = tab['title']!),
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
                                            tab['title']!,
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
                                              tab['count']!,
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
                              SizedBox(width: 110, child: Text('Actions', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF6B7280)), textAlign: TextAlign.right)),
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

                                    // Actions Column (View, Edit, Delete)
                                    SizedBox(
                                      width: 110,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.remove_red_eye_outlined, size: 16, color: Color(0xFF6B7280)),
                                            tooltip: 'View Details',
                                            onPressed: () {
                                              setState(() {
                                                _selectedOrder = order;
                                                _showRightPanel = true;
                                              });
                                            },
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.edit_outlined, size: 16, color: Color(0xFF4F46E5)),
                                            tooltip: 'Edit Order',
                                            onPressed: () => _showEditOrderDialog(order),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete_outline, size: 16, color: Color(0xFFEF4444)),
                                            tooltip: 'Delete Order',
                                            onPressed: () => _showDeleteOrderConfirmationDialog(order),
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

          const SizedBox(height: 12),
          // Action Buttons Bar inside Drawer
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: () => _showEditOrderDialog(order),
                icon: const Icon(Icons.edit, size: 12),
                label: const Text('Edit ✏️', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
              const SizedBox(width: 6),
              OutlinedButton.icon(
                onPressed: () => _showPrintInvoiceDialog(order),
                icon: const Icon(Icons.print, size: 12),
                label: const Text('Invoice 🖨️', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
              const SizedBox(width: 6),
              OutlinedButton.icon(
                onPressed: () => _showDeleteOrderConfirmationDialog(order),
                icon: const Icon(Icons.delete, size: 12, color: Color(0xFFDC2626)),
                label: const Text('Delete 🗑️', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFDC2626))),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFFCA5A5)),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
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
