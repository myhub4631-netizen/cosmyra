import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../catalog/models/product_model.dart';
import '../../catalog/repositories/product_repository.dart';
import 'admin_product_editor_dialog.dart';

class AdminCatalogView extends ConsumerStatefulWidget {
  const AdminCatalogView({super.key});

  @override
  ConsumerState<AdminCatalogView> createState() => _AdminCatalogViewState();
}

class _AdminCatalogViewState extends ConsumerState<AdminCatalogView> {
  String _searchQuery = '';
  String _selectedCategory = 'All Categories';
  String _selectedBrand = 'All Brands';
  String _selectedStatus = 'All Status';
  String _selectedStockStatus = 'All';

  bool _statusActiveFilter = true;
  bool _stockInStockFilter = true;

  final List<Map<String, dynamic>> _catalogProducts = [
    {
      'id': 'PROD-001',
      'name': 'Vaidyam Anti-Dandruff Herbal Shampoo',
      'variant': '200 ml',
      'isFeatured': true,
      'sku': 'VDY-SHM-200',
      'barcode': '8906123456789',
      'category': 'Hair Care',
      'price': 399.0,
      'mrp': 499.0,
      'discount': '20% OFF',
      'stock': 200,
      'stockChange': '+15',
      'status': 'Active',
      'isVisible': true,
      'image': 'assets/images/shampoo.jpg',
    },
    {
      'id': 'PROD-002',
      'name': 'Vaidyam De-Tan Botanical Soap',
      'variant': '125 g',
      'isFeatured': false,
      'sku': 'VDY-SOP-125',
      'barcode': '8906123456790',
      'category': 'Bath & Body',
      'price': 199.0,
      'mrp': 249.0,
      'discount': '20% OFF',
      'stock': 125,
      'stockChange': '+8',
      'status': 'Active',
      'isVisible': true,
      'image': 'assets/images/soap.jpg',
    },
    {
      'id': 'PROD-003',
      'name': 'Vaidyam Deep Clean Face Wash',
      'variant': '100 ml',
      'isFeatured': false,
      'sku': 'VDY-FCW-100',
      'barcode': '8906123456791',
      'category': 'Skin Care',
      'price': 299.0,
      'mrp': 375.0,
      'discount': '20% OFF',
      'stock': 98,
      'stockChange': '+25',
      'status': 'Active',
      'isVisible': true,
      'image': 'assets/images/facewash.jpg',
    },
    {
      'id': 'PROD-004',
      'name': 'Vaidyam Herbal Hair Oil',
      'variant': '100 ml',
      'isFeatured': false,
      'sku': 'VDY-HO-100',
      'barcode': '8906123456792',
      'category': 'Hair Care',
      'price': 349.0,
      'mrp': 449.0,
      'discount': '22% OFF',
      'stock': 0,
      'stockChange': 'Out of Stock',
      'status': 'Inactive',
      'isVisible': false,
      'image': 'assets/images/hairoil.jpg',
    },
    {
      'id': 'PROD-005',
      'name': 'Vaidyam Vitamin C Serum',
      'variant': '30 ml',
      'isFeatured': false,
      'sku': 'VDY-SER-30',
      'barcode': '8906123456793',
      'category': 'Skin Care',
      'price': 599.0,
      'mrp': 749.0,
      'discount': '20% OFF',
      'stock': 30,
      'stockChange': '-5',
      'status': 'Active',
      'isVisible': true,
      'image': 'assets/images/serum.jpg',
    },
  ];

  void _showAddProductModal(BuildContext context, ProductModel? existingProduct) {
    showDialog(
      context: context,
      builder: (context) => AdminProductEditorDialog(product: existingProduct),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth > 1180;

    final filteredProducts = _catalogProducts.where((p) {
      if (_searchQuery.isNotEmpty) {
        final matchName = p['name'].toString().toLowerCase().contains(_searchQuery);
        final matchSku = p['sku'].toString().toLowerCase().contains(_searchQuery);
        final matchBarcode = p['barcode'].toString().toLowerCase().contains(_searchQuery);
        final matchCategory = p['category'].toString().toLowerCase().contains(_searchQuery);
        if (!matchName && !matchSku && !matchBarcode && !matchCategory) return false;
      }
      if (_selectedCategory != 'All Categories' && p['category'] != _selectedCategory) {
        return false;
      }
      if (_selectedStatus != 'All Status' && p['status'] != _selectedStatus) {
        return false;
      }
      return true;
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Page Header & Top Right CTAs
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Catalog & Inventory',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF111827)),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Manage your products, stock, pricing and inventory from one place.',
                    style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
                  ),
                ],
              ),
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Import products dialog launched...')),
                      );
                    },
                    icon: const Icon(Icons.file_download_outlined, size: 18, color: Color(0xFF374151)),
                    label: const Text('Import', style: TextStyle(color: Color(0xFF374151), fontSize: 13, fontWeight: FontWeight.w600)),
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
                        const SnackBar(content: Text('Exporting catalog data as CSV/Excel...')),
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
                    onPressed: () => _showAddProductModal(context, null),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('+ Add New Product', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
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
              _buildMetricCard('Total Products', '1,248', '↑ 12.5% this month', Icons.shopping_bag_outlined, const Color(0xFFE0E7FF), const Color(0xFF4F46E5), true),
              _buildMetricCard('Active Products', '1,102', '↑ 8.3% this month', Icons.layers_outlined, const Color(0xFFD1FAE5), const Color(0xFF059669), true),
              _buildMetricCard('Low Stock', '46', '↓ 3.1% this month', Icons.warning_amber_rounded, const Color(0xFFFEF3C7), const Color(0xFFD97706), false),
              _buildMetricCard('Out of Stock', '18', '↓ 6.7% this month', Icons.highlight_off_rounded, const Color(0xFFFEE2E2), const Color(0xFFDC2626), false),
              _buildMetricCard('Total Inventory Value', '₹12,45,680', '↑ 15.2% this month', Icons.account_balance_wallet_outlined, const Color(0xFFDBEAFE), const Color(0xFF2563EB), true),
            ],
          ),

          const SizedBox(height: 24),

          // 3. Main Data Table & Right Side Panel Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Column: Filter Controls Bar & Product Data Grid
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
                                      hintText: 'Search by name, SKU, barcode or category...',
                                      hintStyle: TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
                                      prefixIcon: Icon(Icons.search, size: 18, color: Color(0xFF9CA3AF)),
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.symmetric(vertical: 8),
                                    ),
                                    onChanged: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
                                  ),
                                ),

                                // Category Dropdown
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
                                      value: _selectedCategory,
                                      style: const TextStyle(fontSize: 12, color: Color(0xFF374151), fontWeight: FontWeight.w500),
                                      items: ['All Categories', 'Hair Care', 'Skin Care', 'Bath & Body']
                                          .map((c) => DropdownMenuItem(value: c, child: Text('Category: $c')))
                                          .toList(),
                                      onChanged: (val) => setState(() => _selectedCategory = val ?? 'All Categories'),
                                    ),
                                  ),
                                ),

                                // Brand Dropdown
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
                                      value: _selectedBrand,
                                      style: const TextStyle(fontSize: 12, color: Color(0xFF374151), fontWeight: FontWeight.w500),
                                      items: ['All Brands', 'Vaidyam Botanicals', 'Cosmyra Organics']
                                          .map((b) => DropdownMenuItem(value: b, child: Text('Brand: $b')))
                                          .toList(),
                                      onChanged: (val) => setState(() => _selectedBrand = val ?? 'All Brands'),
                                    ),
                                  ),
                                ),

                                // Status Dropdown
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
                                      value: _selectedStatus,
                                      style: const TextStyle(fontSize: 12, color: Color(0xFF374151), fontWeight: FontWeight.w500),
                                      items: ['All Status', 'Active', 'Inactive']
                                          .map((s) => DropdownMenuItem(value: s, child: Text('Status: $s')))
                                          .toList(),
                                      onChanged: (val) => setState(() => _selectedStatus = val ?? 'All Status'),
                                    ),
                                  ),
                                ),

                                // Stock Status Dropdown
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
                                      value: _selectedStockStatus,
                                      style: const TextStyle(fontSize: 12, color: Color(0xFF374151), fontWeight: FontWeight.w500),
                                      items: ['All', 'In Stock', 'Low Stock', 'Out of Stock']
                                          .map((st) => DropdownMenuItem(value: st, child: Text('Stock Status: $st')))
                                          .toList(),
                                      onChanged: (val) => setState(() => _selectedStockStatus = val ?? 'All'),
                                    ),
                                  ),
                                ),

                                // Filters Button
                                OutlinedButton.icon(
                                  onPressed: () {},
                                  icon: const Icon(Icons.tune, size: 16, color: Color(0xFF374151)),
                                  label: const Text('Filters', style: TextStyle(fontSize: 12, color: Color(0xFF374151))),
                                  style: OutlinedButton.styleFrom(
                                    minimumSize: const Size(0, 38),
                                    side: const BorderSide(color: Color(0xFFE5E7EB)),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                ),

                                // View Toggle
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

                            // Active Filter Chips Row
                            if (_statusActiveFilter || _stockInStockFilter) ...[
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  const Text('Selected Filters: ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF6B7280))),
                                  const SizedBox(width: 8),
                                  if (_statusActiveFilter) ...[
                                    _buildFilterChip('Status: Active', () => setState(() => _statusActiveFilter = false)),
                                    const SizedBox(width: 8),
                                  ],
                                  if (_stockInStockFilter) ...[
                                    _buildFilterChip('Stock Status: In Stock', () => setState(() => _stockInStockFilter = false)),
                                    const SizedBox(width: 8),
                                  ],
                                  const Spacer(),
                                  TextButton(
                                    onPressed: () {
                                      setState(() {
                                        _statusActiveFilter = false;
                                        _stockInStockFilter = false;
                                        _selectedCategory = 'All Categories';
                                        _selectedBrand = 'All Brands';
                                        _selectedStatus = 'All Status';
                                        _selectedStockStatus = 'All';
                                      });
                                    },
                                    child: const Text('Clear All', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF4F46E5))),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),

                      const Divider(height: 1, color: Color(0xFFF3F4F6)),

                      // Data Table Header Row
                      Container(
                        color: const Color(0xFFFAFAFA),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Row(
                          children: const [
                            SizedBox(width: 30, child: Icon(Icons.check_box_outline_blank, size: 16, color: Color(0xFF9CA3AF))),
                            Expanded(flex: 4, child: Text('Product Details', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF6B7280)))),
                            Expanded(flex: 3, child: Text('SKU / Barcode', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF6B7280)))),
                            Expanded(flex: 2, child: Text('Category', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF6B7280)))),
                            Expanded(flex: 2, child: Text('Price', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF6B7280)))),
                            Expanded(flex: 2, child: Text('Stock', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF6B7280)))),
                            Expanded(flex: 2, child: Text('Status', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF6B7280)))),
                            SizedBox(width: 50, child: Text('Visibility', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF6B7280)))),
                            SizedBox(width: 80, child: Text('Actions', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF6B7280)), textAlign: TextAlign.right)),
                          ],
                        ),
                      ),

                      const Divider(height: 1, color: Color(0xFFF3F4F6)),

                      // Table Data Rows List
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: filteredProducts.length,
                        separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFF3F4F6)),
                        itemBuilder: (context, index) {
                          final prod = filteredProducts[index];

                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            child: Row(
                              children: [
                                const SizedBox(width: 30, child: Icon(Icons.check_box_outline_blank, size: 16, color: Color(0xFFD1D5DB))),

                                // Product Image & Name & Variant
                                Expanded(
                                  flex: 4,
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 48,
                                        height: 48,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF3F4F6),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Icon(Icons.spa, color: Color(0xFF059669), size: 24),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              prod['name'],
                                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF111827)),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 3),
                                            Row(
                                              children: [
                                                Text(prod['variant'], style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
                                                if (prod['isFeatured'] == true) ...[
                                                  const SizedBox(width: 6),
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                                    decoration: BoxDecoration(
                                                      color: const Color(0xFFD1FAE5),
                                                      borderRadius: BorderRadius.circular(4),
                                                    ),
                                                    child: const Text('Featured', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF059669))),
                                                  ),
                                                ],
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // SKU / Barcode
                                Expanded(
                                  flex: 3,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(prod['sku'], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF374151))),
                                      const SizedBox(height: 2),
                                      Text(prod['barcode'], style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF))),
                                    ],
                                  ),
                                ),

                                // Category Pill
                                Expanded(
                                  flex: 2,
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: _getCategoryPillBg(prod['category']),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        prod['category'],
                                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _getCategoryPillTextColor(prod['category'])),
                                      ),
                                    ),
                                  ),
                                ),

                                // Price & MRP
                                Expanded(
                                  flex: 2,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text('₹${prod['price'].toInt()}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
                                          const SizedBox(width: 4),
                                          Text(
                                            '₹${prod['mrp'].toInt()}',
                                            style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF), decoration: TextDecoration.lineThrough),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Text(prod['discount'], style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF059669))),
                                    ],
                                  ),
                                ),

                                // Stock Units
                                Expanded(
                                  flex: 2,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('${prod['stock']} Units', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
                                      const SizedBox(height: 2),
                                      Text(
                                        prod['stockChange'],
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: prod['stockChange'].toString().startsWith('+')
                                              ? const Color(0xFF059669)
                                              : const Color(0xFFDC2626),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Status Badge
                                Expanded(
                                  flex: 2,
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: prod['status'] == 'Active' ? const Color(0xFFD1FAE5) : const Color(0xFFF3F4F6),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        prod['status'],
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: prod['status'] == 'Active' ? const Color(0xFF059669) : const Color(0xFF6B7280),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                // Visibility Icon
                                SizedBox(
                                  width: 50,
                                  child: Icon(
                                    prod['isVisible'] == true ? Icons.remove_red_eye_outlined : Icons.visibility_off_outlined,
                                    size: 18,
                                    color: const Color(0xFF6B7280),
                                  ),
                                ),

                                // Actions
                                SizedBox(
                                  width: 80,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit_outlined, size: 16, color: Color(0xFF4F46E5)),
                                        onPressed: () => _showAddProductModal(context, null),
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
                              'Showing 1 to ${filteredProducts.length} of 1,248 products',
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
                                _buildPageButton('125', false),
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

              // Right Column: Inventory Overview & Stock Alerts Widgets
              if (isWideScreen) ...[
                const SizedBox(width: 20),
                SizedBox(
                  width: 320,
                  child: Column(
                    children: [
                      _buildInventoryOverviewCard(),
                      const SizedBox(height: 16),
                      _buildQuickActionsCard(context),
                      const SizedBox(height: 16),
                      _buildStockAlertsCard(),
                    ],
                  ),
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

  Widget _buildInventoryOverviewCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Inventory Overview', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
          const SizedBox(height: 16),
          Row(
            children: [
              // Circular Donut Ring Graphic
              SizedBox(
                width: 100,
                height: 100,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 90,
                      height: 90,
                      child: CircularProgressIndicator(
                        value: 0.71,
                        strokeWidth: 10,
                        backgroundColor: const Color(0xFFF3F4F6),
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF059669)),
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text('1,248', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
                        Text('Total Products', style: TextStyle(fontSize: 8, color: Color(0xFF6B7280))),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 16),

              // Legend Column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLegendItem('In Stock', '892 (71%)', const Color(0xFF059669)),
                    const SizedBox(height: 6),
                    _buildLegendItem('Low Stock', '46 (4%)', const Color(0xFFD97706)),
                    const SizedBox(height: 6),
                    _buildLegendItem('Out of Stock', '18 (1%)', const Color(0xFFDC2626)),
                    const SizedBox(height: 6),
                    _buildLegendItem('Inactive', '292 (24%)', const Color(0xFF9CA3AF)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, String val, Color dotColor) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
        const Spacer(),
        Text(val, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
      ],
    );
  }

  Widget _buildQuickActionsCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Quick Actions', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
          const SizedBox(height: 12),
          _buildQuickActionRow(context, Icons.add, 'Add New Product', () => _showAddProductModal(context, null)),
          _buildQuickActionRow(context, Icons.file_download_outlined, 'Bulk Import Products', () {}),
          _buildQuickActionRow(context, Icons.file_upload_outlined, 'Export Products', () {}),
          _buildQuickActionRow(context, Icons.category_outlined, 'Manage Categories', () {}),
          _buildQuickActionRow(context, Icons.storefront_outlined, 'Manage Brands', () {}),
          _buildQuickActionRow(context, Icons.notifications_none_outlined, 'Low Stock Alert Settings', () {}),
        ],
      ),
    );
  }

  Widget _buildQuickActionRow(BuildContext context, IconData icon, String title, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(icon, size: 16, color: const Color(0xFF4F46E5)),
            const SizedBox(width: 10),
            Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF374151))),
            const Spacer(),
            const Icon(Icons.chevron_right, size: 16, color: Color(0xFF9CA3AF)),
          ],
        ),
      ),
    );
  }

  Widget _buildStockAlertsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('Stock Alerts', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
              Text('View All', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF4F46E5))),
            ],
          ),
          const SizedBox(height: 12),
          _buildStockAlertRow('Vaidyam Herbal Hair Oil', '0 Units Left', 'Out of Stock', const Color(0xFFFEE2E2), const Color(0xFFDC2626)),
          const SizedBox(height: 10),
          _buildStockAlertRow('Vaidyam Face Pack', '5 Units Left', 'Low Stock', const Color(0xFFFEF3C7), const Color(0xFFD97706)),
          const SizedBox(height: 10),
          _buildStockAlertRow('Vaidyam Night Cream', '7 Units Left', 'Low Stock', const Color(0xFFFEF3C7), const Color(0xFFD97706)),
        ],
      ),
    );
  }

  Widget _buildStockAlertRow(String name, String sub, String badgeText, Color badgeBg, Color badgeColor) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Icon(Icons.spa, color: Color(0xFF059669), size: 18),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF111827)), overflow: TextOverflow.ellipsis),
              const SizedBox(height: 2),
              Text(sub, style: const TextStyle(fontSize: 10, color: Color(0xFF6B7280))),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(color: badgeBg, borderRadius: BorderRadius.circular(4)),
          child: Text(badgeText, style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: badgeColor)),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String text, VoidCallback onRemove) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        border: Border.all(color: const Color(0xFFBFDBFE)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(text, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF2563EB))),
          const SizedBox(width: 4),
          InkWell(
            onTap: onRemove,
            child: const Icon(Icons.close, size: 12, color: Color(0xFF2563EB)),
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

  Color _getCategoryPillBg(String cat) {
    switch (cat) {
      case 'Hair Care':
        return const Color(0xFFEEF2FF);
      case 'Skin Care':
        return const Color(0xFFFEF3C7);
      case 'Bath & Body':
        return const Color(0xFFEFF6FF);
      default:
        return const Color(0xFFF3F4F6);
    }
  }

  Color _getCategoryPillTextColor(String cat) {
    switch (cat) {
      case 'Hair Care':
        return const Color(0xFF4F46E5);
      case 'Skin Care':
        return const Color(0xFFD97706);
      case 'Bath & Body':
        return const Color(0xFF2563EB);
      default:
        return const Color(0xFF374151);
    }
  }
}
