import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

  final List<Map<String, dynamic>> _ordersList = [
    {
      'id': 'CSM-2026-928412',
      'isNew': true,
      'itemsCount': 2,
      'shippingType': 'Standard',
      'customerName': 'Aarav Sharma',
      'customerEmail': 'aarav.sharma@example.com',
      'customerPhone': '+91 98765 43210',
      'amount': 538.00,
      'paymentType': 'Prepaid',
      'paymentStatus': 'Paid',
      'paymentMethod': 'UPI',
      'paymentId': 'pay_Qwe123456789',
      'status': 'Placed',
      'courier': 'Shiprocket',
      'awb': '124578963214',
      'date': '15 Aug 2026 06:45 PM',
      'address': 'Flat 402, Green Glen Heights, Bellandur, Bengaluru, Karnataka - 560103, India',
      'subtotal': 538.00,
      'shippingCharge': 40.00,
      'discount': 40.00,
      'items': [
        {'name': 'Vaidyam Anti-Dandruff Herbal Shampoo', 'variant': '200 ml x 1', 'price': 399.00},
        {'name': 'Vaidyam De-Tan Soap', 'variant': '125 g x 1', 'price': 199.00},
      ],
    },
    {
      'id': 'CSM-2026-928411',
      'isNew': false,
      'itemsCount': 1,
      'shippingType': 'Express',
      'customerName': 'Priya Verma',
      'customerEmail': 'priya.verma@example.com',
      'customerPhone': '+91 91234 56789',
      'amount': 289.00,
      'paymentType': 'Prepaid',
      'paymentStatus': 'Paid',
      'paymentMethod': 'Razorpay',
      'paymentId': 'pay_Rzp987654321',
      'status': 'Confirmed',
      'courier': 'Shiprocket',
      'awb': '124578963215',
      'date': '15 Aug 2026 05:20 PM',
      'address': '12B, Palm Grove Apartments, Bandra West, Mumbai, Maharashtra - 400050, India',
      'subtotal': 289.00,
      'shippingCharge': 0.00,
      'discount': 0.00,
      'items': [
        {'name': 'Vaidyam Vitamin C Serum', 'variant': '30 ml x 1', 'price': 289.00},
      ],
    },
    {
      'id': 'CSM-2026-928410',
      'isNew': false,
      'itemsCount': 3,
      'shippingType': 'Standard',
      'customerName': 'Ananya Roy',
      'customerEmail': 'ananya.roy@gmail.com',
      'customerPhone': '+91 98123 45678',
      'amount': 1148.00,
      'paymentType': 'COD',
      'paymentStatus': 'Pending',
      'paymentMethod': 'COD',
      'paymentId': 'COD-PENDING',
      'status': 'Processing',
      'courier': 'Delhivery',
      'awb': '345612789645',
      'date': '15 Aug 2026 03:10 PM',
      'address': '45/1, Indiranagar 100ft Road, Bengaluru, Karnataka - 560038, India',
      'subtotal': 1148.00,
      'shippingCharge': 50.00,
      'discount': 50.00,
      'items': [
        {'name': 'Vaidyam Deep Clean Face Wash', 'variant': '100 ml x 2', 'price': 598.00},
        {'name': 'Vaidyam Herbal Hair Oil', 'variant': '100 ml x 1', 'price': 350.00},
      ],
    },
    {
      'id': 'CSM-2026-928409',
      'isNew': false,
      'itemsCount': 2,
      'shippingType': 'Standard',
      'customerName': 'Rahul Sharma',
      'customerEmail': 'rahul.s@outlook.com',
      'customerPhone': '+91 97654 32109',
      'amount': 495.00,
      'paymentType': 'Prepaid',
      'paymentStatus': 'Paid',
      'paymentMethod': 'UPI',
      'paymentId': 'pay_Upi888777666',
      'status': 'Shipped',
      'courier': 'India Post',
      'awb': 'IP123456789IN',
      'date': '14 Aug 2026 11:30 AM',
      'address': 'House 88, Sector 15, Gurgaon, Haryana - 122001, India',
      'subtotal': 495.00,
      'shippingCharge': 0.00,
      'discount': 0.00,
      'items': [
        {'name': 'Vaidyam Botanical Face Mask', 'variant': '100 g x 1', 'price': 495.00},
      ],
    },
    {
      'id': 'CSM-2026-928408',
      'isNew': false,
      'itemsCount': 1,
      'shippingType': 'Standard',
      'customerName': 'Neha Kapoor',
      'customerEmail': 'neha.kapoor@example.com',
      'customerPhone': '+91 99887 77665',
      'amount': 199.00,
      'paymentType': 'Prepaid',
      'paymentStatus': 'Paid',
      'paymentMethod': 'Card',
      'paymentId': 'pay_Crd554433221',
      'status': 'Delivered',
      'courier': 'Delhivery',
      'awb': '345612789646',
      'date': '14 Aug 2026 10:20 AM',
      'address': 'Plot 14, Jubilee Hills, Hyderabad, Telangana - 500033, India',
      'subtotal': 199.00,
      'shippingCharge': 40.00,
      'discount': 40.00,
      'items': [
        {'name': 'Vaidyam De-Tan Soap', 'variant': '125 g x 1', 'price': 199.00},
      ],
    },
    {
      'id': 'CSM-2026-928407',
      'isNew': false,
      'itemsCount': 2,
      'shippingType': 'Standard',
      'customerName': 'Aman Singh',
      'customerEmail': 'aman.singh@example.com',
      'customerPhone': '+91 88991 23456',
      'amount': 798.00,
      'paymentType': 'Prepaid',
      'paymentStatus': 'Paid',
      'paymentMethod': 'UPI',
      'paymentId': 'pay_Upi112233445',
      'status': 'Cancelled',
      'courier': '-',
      'awb': '-',
      'date': '13 Aug 2026 09:15 PM',
      'address': 'Villa 7, Green Acres, Pune, Maharashtra - 411001, India',
      'subtotal': 798.00,
      'shippingCharge': 0.00,
      'discount': 0.00,
      'items': [
        {'name': 'Vaidyam Anti-Dandruff Herbal Shampoo', 'variant': '200 ml x 2', 'price': 798.00},
      ],
    },
    {
      'id': 'CSM-2026-928406',
      'isNew': false,
      'itemsCount': 1,
      'shippingType': 'Standard',
      'customerName': 'Saurabh Mehta',
      'customerEmail': 'saurabh.mehta@example.com',
      'customerPhone': '+91 77665 44332',
      'amount': 299.00,
      'paymentType': 'Prepaid',
      'paymentStatus': 'Refunded',
      'paymentMethod': 'UPI',
      'paymentId': 'pay_Ref667788990',
      'status': 'Returned',
      'courier': 'Delhivery',
      'awb': '345612789647',
      'date': '13 Aug 2026 06:40 PM',
      'address': '22, MG Road, Kolkata, West Bengal - 700007, India',
      'subtotal': 299.00,
      'shippingCharge': 0.00,
      'discount': 0.00,
      'items': [
        {'name': 'Vaidyam Deep Clean Face Wash', 'variant': '100 ml x 1', 'price': 299.00},
      ],
    },
    {
      'id': 'CSM-2026-928405',
      'isNew': false,
      'itemsCount': 4,
      'shippingType': 'Standard',
      'customerName': 'Kavya Iyer',
      'customerEmail': 'kavya.iyer@example.com',
      'customerPhone': '+91 95432 11876',
      'amount': 1899.00,
      'paymentType': 'Prepaid',
      'paymentStatus': 'Paid',
      'paymentMethod': 'Card',
      'paymentId': 'pay_Crd998877665',
      'status': 'Shipped',
      'courier': 'Shiprocket',
      'awb': '124578963216',
      'date': '13 Aug 2026 04:05 PM',
      'address': 'Flat 304, Royal Palms, Chennai, Tamil Nadu - 600001, India',
      'subtotal': 1899.00,
      'shippingCharge': 0.00,
      'discount': 100.00,
      'items': [
        {'name': 'Vaidyam Vitamin C Serum', 'variant': '30 ml x 2', 'price': 1198.00},
        {'name': 'Vaidyam Herbal Hair Oil', 'variant': '100 ml x 2', 'price': 700.00},
      ],
    },
  ];

  final List<Map<String, dynamic>> _statusTabs = [
    {'name': 'All', 'count': '2,843'},
    {'name': 'Placed', 'count': '527'},
    {'name': 'Confirmed', 'count': '412'},
    {'name': 'Processing', 'count': '321'},
    {'name': 'Shipped', 'count': '342'},
    {'name': 'Delivered', 'count': '1,128'},
    {'name': 'Cancelled', 'count': '68'},
    {'name': 'Returned', 'count': '45'},
  ];

  @override
  void initState() {
    super.initState();
    _selectedOrder = _ordersList[0];
  }

  void _showCreateOrderDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Create New Manual Order', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              TextField(decoration: InputDecoration(labelText: 'Customer Name', hintText: 'e.g. Aarav Sharma')),
              SizedBox(height: 10),
              TextField(decoration: InputDecoration(labelText: 'Phone Number', hintText: 'e.g. +91 98765 43210')),
              SizedBox(height: 10),
              TextField(decoration: InputDecoration(labelText: 'Shipping Address', hintText: 'Flat 402, Green Glen...')),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4F46E5),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Manual order created successfully!')),
                );
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
    final filteredOrders = _ordersList.where((o) {
      if (_searchQuery.isNotEmpty) {
        final numMatch = o['id'].toString().toLowerCase().contains(_searchQuery);
        final custMatch = o['customerName'].toString().toLowerCase().contains(_searchQuery);
        final phoneMatch = o['customerPhone'].toString().toLowerCase().contains(_searchQuery);
        final awbMatch = o['awb'].toString().toLowerCase().contains(_searchQuery);
        if (!numMatch && !custMatch && !phoneMatch && !awbMatch) return false;
      }
      if (_selectedStatusTab != 'All' && o['status'] != _selectedStatusTab) {
        return false;
      }
      return true;
    }).toList();

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
                  OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Importing orders CSV...')),
                      );
                    },
                    icon: const Icon(Icons.file_download_outlined, size: 18, color: Color(0xFF374151)),
                    label: const Text('Import Orders', style: TextStyle(color: Color(0xFF374151), fontSize: 13, fontWeight: FontWeight.w600)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      side: const BorderSide(color: Color(0xFFD1D5DB)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Exporting orders report...')),
                      );
                    },
                    icon: const Icon(Icons.file_upload_outlined, size: 18, color: Color(0xFF374151)),
                    label: const Text('Export', style: TextStyle(color: Color(0xFF374151), fontSize: 13, fontWeight: FontWeight.w600)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      side: const BorderSide(color: Color(0xFFD1D5DB)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton.icon(
                    onPressed: _showCreateOrderDialog,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('+ Create Order', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4F46E5),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 24),

          // 2. Summary Metric Cards Row (5 Stat Cards)
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _buildMetricCard('Total Orders', '2,843', '↑ 12.4% this month', Icons.shopping_bag_outlined, const Color(0xFFE0E7FF), const Color(0xFF4F46E5), true),
              _buildMetricCard('Completed Orders', '2,128', '↑ 10.8% this month', Icons.assignment_turned_in_outlined, const Color(0xFFD1FAE5), const Color(0xFF059669), true),
              _buildMetricCard('In Transit', '342', '↑ 4.6% this month', Icons.local_shipping_outlined, const Color(0xFFFEF3C7), const Color(0xFFD97706), true),
              _buildMetricCard('Returns / Refunds', '73', '↓ 3.2% this month', Icons.replay_outlined, const Color(0xFFF3E8FF), const Color(0xFF9333EA), false),
              _buildMetricCard('Total Revenue', '₹12,45,680', '↑ 15.2% this month', Icons.account_balance_wallet_outlined, const Color(0xFFDBEAFE), const Color(0xFF2563EB), true),
            ],
          ),

          const SizedBox(height: 24),

          // 3. Main Data Section with Filter Controls + Table + Right Order Details Panel
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Column: Search Filter Bar & Order Data Grid
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
                      // Filter Control Bar
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                // Search Input Box
                                Container(
                                  width: 260,
                                  height: 38,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF9FAFB),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: const Color(0xFFE5E7EB)),
                                  ),
                                  child: TextField(
                                    decoration: const InputDecoration(
                                      hintText: 'Search Order #, Customer, Phone, Email, SKU...',
                                      hintStyle: TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
                                      prefixIcon: Icon(Icons.search, size: 18, color: Color(0xFF9CA3AF)),
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.symmetric(vertical: 8),
                                    ),
                                    onChanged: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
                                  ),
                                ),

                                // Date Range Selector
                                Container(
                                  height: 38,
                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: const Color(0xFFE5E7EB)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Text('Date Range ', style: TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
                                      Text(_selectedDateRange, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF374151))),
                                      const SizedBox(width: 6),
                                      const Icon(Icons.calendar_today_outlined, size: 14, color: Color(0xFF6B7280)),
                                    ],
                                  ),
                                ),

                                // Sales Channel Dropdown
                                Container(
                                  height: 38,
                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: const Color(0xFFE5E7EB)),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: _selectedSalesChannel,
                                      style: const TextStyle(fontSize: 12, color: Color(0xFF374151), fontWeight: FontWeight.w500),
                                      items: ['All Channels', 'Website Direct', 'Mobile App', 'Amazon Store']
                                          .map((c) => DropdownMenuItem(value: c, child: Text('Sales Channel: $c')))
                                          .toList(),
                                      onChanged: (val) => setState(() => _selectedSalesChannel = val ?? 'All Channels'),
                                    ),
                                  ),
                                ),

                                // Fulfillment State Dropdown
                                Container(
                                  height: 38,
                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: const Color(0xFFE5E7EB)),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: _selectedFulfillmentState,
                                      style: const TextStyle(fontSize: 12, color: Color(0xFF374151), fontWeight: FontWeight.w500),
                                      items: ['All', 'Unfulfilled', 'Fulfilled']
                                          .map((f) => DropdownMenuItem(value: f, child: Text('Fulfillment: $f')))
                                          .toList(),
                                      onChanged: (val) => setState(() => _selectedFulfillmentState = val ?? 'All'),
                                    ),
                                  ),
                                ),

                                // More Filters Button
                                OutlinedButton.icon(
                                  onPressed: () {},
                                  icon: const Icon(Icons.tune, size: 16, color: Color(0xFF374151)),
                                  label: const Text('More Filters', style: TextStyle(fontSize: 12, color: Color(0xFF374151))),
                                  style: OutlinedButton.styleFrom(
                                    minimumSize: const Size(0, 38),
                                    side: const BorderSide(color: Color(0xFFE5E7EB)),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                ),

                                // View Mode Settings Button
                                Container(
                                  height: 38,
                                  width: 38,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: const Color(0xFFE5E7EB)),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.settings_outlined, size: 18, color: Color(0xFF374151)),
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),

                            // Status Filter Tabs Strip
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: _statusTabs.map((tab) {
                                  final isActive = _selectedStatusTab == tab['name'];
                                  return InkWell(
                                    onTap: () => setState(() => _selectedStatusTab = tab['name']),
                                    child: Container(
                                      margin: const EdgeInsets.only(right: 8),
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: isActive ? const Color(0xFF111827) : const Color(0xFFF3F4F6),
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

                      // Table Columns Header
                      Container(
                        color: const Color(0xFFFAFAFA),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Row(
                          children: const [
                            SizedBox(width: 30, child: Icon(Icons.check_box_outline_blank, size: 16, color: Color(0xFF9CA3AF))),
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
                                  const SizedBox(width: 30, child: Icon(Icons.check_box_outline_blank, size: 16, color: Color(0xFFD1D5DB))),

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
                                        IconButton(
                                          icon: const Icon(Icons.more_vert, size: 16, color: Color(0xFF6B7280)),
                                          onPressed: () {},
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

                      // Pagination Footer Bar
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Showing 1 to ${filteredOrders.length} of 2,843 orders',
                              style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                            ),
                            Row(
                              children: [
                                _buildPageButton('<', false),
                                _buildPageButton('1', true),
                                _buildPageButton('2', false),
                                _buildPageButton('3', false),
                                const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 4),
                                  child: Text('...', style: TextStyle(color: Color(0xFF6B7280))),
                                ),
                                _buildPageButton('356', false),
                                _buildPageButton('>', false),
                                const SizedBox(width: 16),
                                const Text('Show ', style: TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: const Color(0xFFE5E7EB)),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text('10 ▾', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                                ),
                                const Text(' per page', style: TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Right Column: Selected Order Details Drawer Panel
              if (_showRightPanel && _selectedOrder != null && isWideScreen) ...[
                const SizedBox(width: 20),
                SizedBox(
                  width: 320,
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(order['customerName'], style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF4F46E5))),
              const Text('View Profile', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF4F46E5))),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.email_outlined, size: 12, color: Color(0xFF6B7280)),
              const SizedBox(width: 6),
              Text(order['customerEmail'], style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('Delivery Address', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF374151))),
              Text('Copy', style: TextStyle(fontSize: 11, color: Color(0xFF4F46E5), fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 6),
          Text(order['address'], style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280), height: 1.4)),

          const SizedBox(height: 16),

          // Order Summary Breakdown
          const Text('Order Summary', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF374151))),
          const SizedBox(height: 8),
          _buildSummaryRow('Subtotal (${order['itemsCount']} Items)', '₹${order['subtotal']}'),
          _buildSummaryRow('Shipping Charge', '₹${order['shippingCharge']}'),
          _buildSummaryRow('Discount', '- ₹${order['discount']}', isDiscount: true),
          const Divider(height: 16, color: Color(0xFFF3F4F6)),
          _buildSummaryRow('Total Amount', '₹${order['amount']}', isTotal: true),
          _buildSummaryRow('Paid (${order['paymentMethod']})', '₹${order['amount']}', isPaid: true),
          const SizedBox(height: 2),
          Text('Payment ID: ${order['paymentId']}', style: const TextStyle(fontSize: 10, color: Color(0xFF9CA3AF))),

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
                    Text('₹${item['price']}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
                  ],
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 16),

          // Fulfillment & Tracking Card
          const Text('Fulfillment & Tracking', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF374151))),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Courier Partner', style: TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
              Text(order['courier'], style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('AWB Number', style: TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
              Row(
                children: [
                  Text(order['awb'], style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
                  const SizedBox(width: 4),
                  const Icon(Icons.copy, size: 10, color: Color(0xFF9CA3AF)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Tracking live courier status for ${order['id']}...')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4F46E5),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                  ),
                  child: const Text('Track Order', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFD1D5DB)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Print Invoice', style: TextStyle(fontSize: 11, color: Color(0xFF374151))),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Actions
          const Text('Actions', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF374151))),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFFFECACA))),
                  child: const Text('Cancel Order', style: TextStyle(fontSize: 11, color: Color(0xFFDC2626))),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFFBFDBFE))),
                  child: const Text('Edit Order', style: TextStyle(fontSize: 11, color: Color(0xFF2563EB))),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFFE5E7EB))),
              child: const Text('More Actions ▾', style: TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
            ),
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
              fontWeight: isTotal || isPaid ? FontWeight.bold : FontWeight.normal,
              color: isPaid ? const Color(0xFF059669) : const Color(0xFF6B7280),
            ),
          ),
          Text(
            val,
            style: TextStyle(
              fontSize: isTotal ? 13 : 11,
              fontWeight: isTotal || isPaid ? FontWeight.bold : FontWeight.normal,
              color: isPaid
                  ? const Color(0xFF059669)
                  : isDiscount
                      ? const Color(0xFFDC2626)
                      : const Color(0xFF111827),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageButton(String text, bool isActive) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF4F46E5) : Colors.white,
        border: Border.all(color: isActive ? const Color(0xFF4F46E5) : const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isActive ? Colors.white : const Color(0xFF374151),
          ),
        ),
      ),
    );
  }

  String _formatCurrency(double val) {
    return val.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
  }

  Color _getPaymentStatusColor(String status) {
    switch (status) {
      case 'Paid':
        return const Color(0xFF059669);
      case 'Pending':
        return const Color(0xFFD97706);
      case 'Refunded':
        return const Color(0xFF2563EB);
      default:
        return const Color(0xFF6B7280);
    }
  }

  Color _getStatusPillBg(String status) {
    switch (status) {
      case 'Placed':
        return const Color(0xFFEEF2FF);
      case 'Confirmed':
        return const Color(0xFFEFF6FF);
      case 'Processing':
        return const Color(0xFFFEF3C7);
      case 'Shipped':
        return const Color(0xFFEEF2FF);
      case 'Delivered':
        return const Color(0xFFD1FAE5);
      case 'Cancelled':
        return const Color(0xFFFEE2E2);
      case 'Returned':
        return const Color(0xFFFEF3C7);
      default:
        return const Color(0xFFF3F4F6);
    }
  }

  Color _getStatusPillTextColor(String status) {
    switch (status) {
      case 'Placed':
        return const Color(0xFF4F46E5);
      case 'Confirmed':
        return const Color(0xFF2563EB);
      case 'Processing':
        return const Color(0xFFD97706);
      case 'Shipped':
        return const Color(0xFF4F46E5);
      case 'Delivered':
        return const Color(0xFF059669);
      case 'Cancelled':
        return const Color(0xFFDC2626);
      case 'Returned':
        return const Color(0xFFD97706);
      default:
        return const Color(0xFF374151);
    }
  }
}
