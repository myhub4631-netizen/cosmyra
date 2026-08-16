import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:convert';
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
  String _selectedStockStatus = 'All';

  final Set<String> _selectedProductIds = {};

  void _showAddProductModal(BuildContext context, ProductModel? existingProduct) {
    showDialog(
      context: context,
      builder: (context) => AdminProductEditorDialog(product: existingProduct),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, ProductModel product) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Color(0xFFDC2626)),
            SizedBox(width: 10),
            Text('Delete Product'),
          ],
        ),
        content: Text('Are you sure you want to delete "${product.name}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              ref.read(adminProductsProvider.notifier).deleteProduct(product.id);
              setState(() => _selectedProductIds.remove(product.id));
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Deleted "${product.name}" from catalog')),
              );
            },
            child: const Text('Delete Product'),
          ),
        ],
      ),
    );
  }

  void _showQuickRestockDialog(BuildContext context, ProductModel product) {
    int addAmount = 25;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Restock Stock: ${product.name}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Current Stock: ${product.defaultVariant.stock} Units', style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              const Text('Select quantity to add:', style: TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                children: [10, 25, 50, 100].map((amt) {
                  final isSel = addAmount == amt;
                  return ChoiceChip(
                    label: Text('+$amt Units'),
                    selected: isSel,
                    selectedColor: const Color(0xFF4F46E5),
                    labelStyle: TextStyle(color: isSel ? Colors.white : const Color(0xFF374151), fontWeight: FontWeight.bold),
                    onSelected: (val) {
                      if (val) setDialogState(() => addAmount = amt);
                    },
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF059669), foregroundColor: Colors.white),
              onPressed: () {
                ref.read(adminProductsProvider.notifier).restockProduct(product.id, addAmount);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Added +$addAmount units to ${product.name}')),
                );
              },
              child: const Text('Confirm Restock'),
            ),
          ],
        ),
      ),
    );
  }

  void _showBulkImportModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.file_download_outlined, color: Color(0xFF4F46E5)),
            SizedBox(width: 10),
            Text('Bulk Import / Add Products'),
          ],
        ),
        content: SizedBox(
          width: 520,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Quickly add catalog products using 1-click sample dataset or custom JSON payload.',
                style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Option A: Load 5 Sample Ayurvedic Botanical SKUs', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 6),
                    const Text('Imports Kumkumadi Elixir, Bhringraj Oil, Nalpamaradi Thailam, Shata Dhauta Ghrita, and Chandan Facewash instantly.', style: TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () {
                        final sampleProducts = [
                          ProductModel(
                            id: 'prod-${DateTime.now().millisecondsSinceEpoch}-1',
                            brandId: 'brand-vaidyam',
                            categoryId: 'cat-skincare',
                            name: 'Vaidyam Kumkumadi Radiance Elixir',
                            slug: 'kumkumadi-radiance-elixir',
                            tagline: 'Handcrafted Kashmiri Saffron & 26 Ayurvedic herbs',
                            description: 'Restores natural skin luminosity, repairs sun damage, and evens out pigmentation.',
                            ingredients: 'CroCus Sativus (Saffron), Santalum Album (Sandalwood), Vetiver, Sesame Oil.',
                            howToUse: 'Apply 3-4 drops onto cleansed face at bedtime.',
                            freeFromClaims: const ['Paraben Free', 'Sulfate Free', 'Cruelty Free'],
                            isFeatured: true,
                            variants: const [
                              ProductVariant(
                                id: 'v1-30ml',
                                productId: 'prod-sample-1',
                                sku: 'VDY-KUM-30',
                                sizeLabel: '30 ml Bottle',
                                price: 1799,
                                mrp: 2549,
                                stock: 200,
                                isDefault: true,
                              ),
                            ],
                            imageUrls: const ['assets/images/facewash.jpg'],
                          ),
                          ProductModel(
                            id: 'prod-${DateTime.now().millisecondsSinceEpoch}-2',
                            brandId: 'brand-vaidyam',
                            categoryId: 'cat-haircare',
                            name: 'Vaidyam Bhringraj Hair Defense Oil',
                            slug: 'bhringraj-hair-defense-oil',
                            tagline: 'Clinically proven scalp defense & root nourishment',
                            description: 'Enriched with pure Bhringraj, Amla, and Neem extracts to curb hair loss and flakes.',
                            ingredients: 'Eclipta Alba (Bhringraj), Azadirachta Indica (Neem), Coconut Oil.',
                            howToUse: 'Massage into scalp 30 minutes before washing.',
                            freeFromClaims: const ['Mineral Oil Free', 'Paraben Free'],
                            isFeatured: true,
                            variants: const [
                              ProductVariant(
                                id: 'v2-200ml',
                                productId: 'prod-sample-2',
                                sku: 'VDY-BHR-200',
                                sizeLabel: '200 ml Bottle',
                                price: 1299,
                                mrp: 1699,
                                stock: 150,
                                isDefault: true,
                              ),
                            ],
                            imageUrls: const ['assets/images/shampoo.jpg'],
                          ),
                          ProductModel(
                            id: 'prod-${DateTime.now().millisecondsSinceEpoch}-3',
                            brandId: 'brand-vaidyam',
                            categoryId: 'cat-wellness',
                            name: 'Vaidyam Nalpamaradi Body Thailam',
                            slug: 'nalpamaradi-body-thailam',
                            tagline: 'De-tan brightening body oil with turmeric & banyan bark',
                            description: 'Removes sun tan, nourishes deep skin layers, and imparts golden complexion.',
                            ingredients: 'Wild Turmeric, Banyan Bark, Vetiver Root.',
                            howToUse: 'Apply generously on body 15 minutes before bath.',
                            freeFromClaims: const ['100% Natural', 'Paraben Free'],
                            isFeatured: true,
                            variants: const [
                              ProductVariant(
                                id: 'v3-150ml',
                                productId: 'prod-sample-3',
                                sku: 'VDY-NAL-150',
                                sizeLabel: '150 ml Bottle',
                                price: 999,
                                mrp: 1399,
                                stock: 180,
                                isDefault: true,
                              ),
                            ],
                            imageUrls: const ['assets/images/soap.jpg'],
                          ),
                          ProductModel(
                            id: 'prod-${DateTime.now().millisecondsSinceEpoch}-4',
                            brandId: 'brand-vaidyam',
                            categoryId: 'cat-skincare',
                            name: 'Vaidyam Shata Dhauta Ghrita Clarifying Cream',
                            slug: 'shata-dhauta-ghrita-cream',
                            tagline: '100-times washed A2 ghee emulsion for skin repair',
                            description: 'Cools inflammation, repairs broken barrier, and deeply hydrates sensitive skin.',
                            ingredients: 'A2 Cow Ghee, Pure Rose Water, Kashmiri Saffron.',
                            howToUse: 'Apply small dab onto clean face and massage until absorbed.',
                            freeFromClaims: const ['Preservative Free', 'Fragrance Free'],
                            isFeatured: false,
                            variants: const [
                              ProductVariant(
                                id: 'v4-50g',
                                productId: 'prod-sample-4',
                                sku: 'VDY-SDG-50',
                                sizeLabel: '50 g Jar',
                                price: 1499,
                                mrp: 1999,
                                stock: 90,
                                isDefault: true,
                              ),
                            ],
                            imageUrls: const ['assets/images/facewash.jpg'],
                          ),
                          ProductModel(
                            id: 'prod-${DateTime.now().millisecondsSinceEpoch}-5',
                            brandId: 'brand-vaidyam',
                            categoryId: 'cat-skincare',
                            name: 'Vaidyam Chandan & Rose Purifying Face Wash',
                            slug: 'chandan-rose-face-wash',
                            tagline: 'Sulfate-free mild cleanser with pure Sandalwood water',
                            description: 'Gentle pH-balanced cleanser that washes away impurities without stripping moisture.',
                            ingredients: 'Sandalwood Water, Rose Petal Water, Aloe Vera Extract.',
                            howToUse: 'Lather onto wet face and rinse thoroughly.',
                            freeFromClaims: const ['Soap Free', 'Sulfate Free'],
                            isFeatured: true,
                            variants: const [
                              ProductVariant(
                                id: 'v5-150ml',
                                productId: 'prod-sample-5',
                                sku: 'VDY-CRF-150',
                                sizeLabel: '150 ml Pump',
                                price: 699,
                                mrp: 949,
                                stock: 220,
                                isDefault: true,
                              ),
                            ],
                            imageUrls: const ['assets/images/facewash.jpg'],
                          ),
                        ];

                        for (final p in sampleProducts) {
                          ref.read(adminProductsProvider.notifier).addProduct(p);
                        }

                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Successfully imported 5 Ayurvedic SKUs to catalog!')),
                        );
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4F46E5), foregroundColor: Colors.white),
                      icon: const Icon(Icons.download_done, size: 16),
                      label: const Text('Load 5 Sample SKUs'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
        ],
      ),
    );
  }

  void _showExportModal(BuildContext context, List<ProductModel> products) {
    final jsonStr = const JsonEncoder.withIndent('  ').convert(products.map((p) => p.toJson()).toList());
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Export Catalog JSON'),
        content: SizedBox(
          width: 580,
          height: 380,
          child: SingleChildScrollView(
            child: SelectableText(
              jsonStr,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
          ElevatedButton.icon(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: jsonStr));
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Catalog JSON copied to clipboard!')),
              );
            },
            icon: const Icon(Icons.copy, size: 16),
            label: const Text('Copy JSON'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final allProducts = ref.watch(adminProductsProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth > 1180;

    final filteredProducts = allProducts.where((p) {
      if (_searchQuery.isNotEmpty) {
        final matchName = p.name.toLowerCase().contains(_searchQuery);
        final matchSku = p.defaultVariant.sku.toLowerCase().contains(_searchQuery);
        final matchCategory = p.categoryId.toLowerCase().contains(_searchQuery);
        final matchTagline = (p.tagline ?? '').toLowerCase().contains(_searchQuery);
        if (!matchName && !matchSku && !matchCategory && !matchTagline) return false;
      }
      if (_selectedCategory != 'All Categories') {
        final catClean = _selectedCategory.toLowerCase().replaceAll(' ', '').replaceAll('cat-', '');
        final prodCatClean = p.categoryId.toLowerCase().replaceAll(' ', '').replaceAll('cat-', '');
        if (!prodCatClean.contains(catClean) && !catClean.contains(prodCatClean)) {
          return false;
        }
      }
      if (_selectedStockStatus == 'Active' && p.defaultVariant.stock == 0) {
        return false;
      }
      if (_selectedStockStatus == 'In Stock' && p.defaultVariant.stock <= 20) {
        return false;
      }
      if (_selectedStockStatus == 'Low Stock' && (p.defaultVariant.stock == 0 || p.defaultVariant.stock > 20)) {
        return false;
      }
      if ((_selectedStockStatus == 'Out of Stock' || _selectedStockStatus == 'Inactive') && p.defaultVariant.stock > 0) {
        return false;
      }
      return true;
    }).toList();

    final isAllSelected = filteredProducts.isNotEmpty && filteredProducts.every((p) => _selectedProductIds.contains(p.id));

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
                    onPressed: () => _showBulkImportModal(context),
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
                    onPressed: () => _showExportModal(context, allProducts),
                    icon: const Icon(Icons.file_upload_outlined, size: 18, color: Color(0xFF374151)),
                    label: const Text('Export', style: TextStyle(color: Color(0xFF374151), fontSize: 13, fontWeight: FontWeight.w600)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      side: const BorderSide(color: Color(0xFFD1D5DB)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  OutlinedButton.icon(
                    onPressed: () {
                      ref.read(adminProductsProvider.notifier).resetToDefaultCatalog();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Hard reset complete! Reset catalog to default products.'),
                          backgroundColor: Color(0xFF059669),
                        ),
                      );
                    },
                    icon: const Icon(Icons.restart_alt, size: 18, color: Color(0xFFDC2626)),
                    label: const Text('Hard Reset', style: TextStyle(color: Color(0xFFDC2626), fontSize: 13, fontWeight: FontWeight.w700)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      side: const BorderSide(color: Color(0xFFFCA5A5)),
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
              _buildMetricCard('Total Products', '${allProducts.length}', 'Active Catalog', Icons.shopping_bag_outlined, const Color(0xFFE0E7FF), const Color(0xFF4F46E5), true),
              _buildMetricCard('Active Products', '${allProducts.where((p) => p.defaultVariant.stock > 0).length}', 'In Stock', Icons.layers_outlined, const Color(0xFFD1FAE5), const Color(0xFF059669), true),
              _buildMetricCard('Low Stock', '${allProducts.where((p) => p.defaultVariant.stock > 0 && p.defaultVariant.stock <= 20).length}', 'Requires Reorder', Icons.warning_amber_rounded, const Color(0xFFFEF3C7), const Color(0xFFD97706), false),
              _buildMetricCard('Out of Stock', '${allProducts.where((p) => p.defaultVariant.stock == 0).length}', 'Urgent Action', Icons.highlight_off_rounded, const Color(0xFFFEE2E2), const Color(0xFFDC2626), false),
              _buildMetricCard('Total Inventory Value', '₹${allProducts.fold(0.0, (sum, p) => sum + (p.defaultVariant.price * p.defaultVariant.stock)).toInt()}', 'Valuation', Icons.account_balance_wallet_outlined, const Color(0xFFDBEAFE), const Color(0xFF2563EB), true),
            ],
          ),

          const SizedBox(height: 24),

          // Bulk Actions Floating Bar when items are checked
          if (_selectedProductIds.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1B4B),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Text('${_selectedProductIds.length} item(s) selected', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () {
                      for (final id in _selectedProductIds) {
                        ref.read(adminProductsProvider.notifier).restockProduct(id, 25);
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Added +25 units to ${_selectedProductIds.length} product(s)')),
                      );
                    },
                    icon: const Icon(Icons.add, size: 16, color: Colors.white),
                    label: const Text('Restock +25', style: TextStyle(color: Colors.white, fontSize: 12)),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: () {
                      for (final id in List.from(_selectedProductIds)) {
                        ref.read(adminProductsProvider.notifier).deleteProduct(id);
                      }
                      setState(() => _selectedProductIds.clear());
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Deleted selected products')),
                      );
                    },
                    icon: const Icon(Icons.delete_outline, size: 16, color: Color(0xFFFCA5A5)),
                    label: const Text('Delete Selected', style: TextStyle(color: Color(0xFFFCA5A5), fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white, size: 18),
                    onPressed: () => setState(() => _selectedProductIds.clear()),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

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
                                      hintText: 'Search by name, SKU, or category...',
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
                                      items: ['All Categories', 'cat-haircare', 'cat-skincare', 'cat-wellness']
                                          .map((c) => DropdownMenuItem(value: c, child: Text(c == 'All Categories' ? 'Category: All' : 'Category: ${c.replaceAll('cat-', '')}')))
                                          .toList(),
                                      onChanged: (val) => setState(() => _selectedCategory = val ?? 'All Categories'),
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
                                          .map((s) => DropdownMenuItem(value: s, child: Text('Stock: $s')))
                                          .toList(),
                                      onChanged: (val) => setState(() => _selectedStockStatus = val ?? 'All'),
                                    ),
                                  ),
                                ),

                                if (_searchQuery.isNotEmpty || _selectedCategory != 'All Categories' || _selectedStockStatus != 'All')
                                  TextButton(
                                    onPressed: () => setState(() {
                                      _searchQuery = '';
                                      _selectedCategory = 'All Categories';
                                      _selectedStockStatus = 'All';
                                    }),
                                    child: const Text('Clear Filters', style: TextStyle(fontSize: 11, color: Color(0xFFDC2626))),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const Divider(height: 1, color: Color(0xFFF3F4F6)),

                      // Horizontal Scrollable Data Table Container
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                            minWidth: 1150,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Data Table Header Row
                              Container(
                        color: const Color(0xFFFAFAFA),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 40,
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    if (isAllSelected) {
                                      _selectedProductIds.clear();
                                    } else {
                                      _selectedProductIds.addAll(filteredProducts.map((p) => p.id));
                                    }
                                  });
                                },
                                child: Icon(
                                  isAllSelected ? Icons.check_box : Icons.check_box_outline_blank,
                                  size: 16,
                                  color: isAllSelected ? const Color(0xFF4F46E5) : const Color(0xFF9CA3AF),
                                ),
                              ),
                            ),
                            const SizedBox(width: 260, child: Text('Product Details', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF6B7280)))),
                            const SizedBox(width: 160, child: Text('SKU / Product ID', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF6B7280)))),
                            const SizedBox(width: 130, child: Text('Category', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF6B7280)))),
                            const SizedBox(width: 120, child: Text('Price', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF6B7280)))),
                            const SizedBox(width: 130, child: Text('Stock', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF6B7280)))),
                            const SizedBox(width: 90, child: Text('Status', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF6B7280)))),
                            const SizedBox(width: 180, child: Text('Actions', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF6B7280)), textAlign: TextAlign.right)),
                          ],
                        ),
                      ),

                      const Divider(height: 1, color: Color(0xFFF3F4F6)),

                      // Table Data Rows List
                      filteredProducts.isEmpty
                          ? Padding(
                              padding: const EdgeInsets.all(32),
                              child: Column(
                                children: [
                                  const Icon(Icons.inventory_2_outlined, size: 48, color: Color(0xFF9CA3AF)),
                                  const SizedBox(height: 12),
                                  const Text('No products found in catalog.', style: TextStyle(color: Color(0xFF374151), fontWeight: FontWeight.bold, fontSize: 14)),
                                  const SizedBox(height: 6),
                                  const Text('Click "+ Add New Product" or "Import" to populate your store.', style: TextStyle(color: Color(0xFF6B7280), fontSize: 12)),
                                  const SizedBox(height: 16),
                                  ElevatedButton.icon(
                                    onPressed: () => _showBulkImportModal(context),
                                    icon: const Icon(Icons.file_download_outlined, size: 16),
                                    label: const Text('Load 5 Sample SKUs'),
                                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4F46E5), foregroundColor: Colors.white),
                                  ),
                                ],
                              ),
                            )
                          : ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: filteredProducts.length,
                              separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFF3F4F6)),
                              itemBuilder: (context, index) {
                                final prod = filteredProducts[index];
                                final v = prod.defaultVariant;
                                final imageUrl = prod.imageUrls.isNotEmpty ? prod.imageUrls.first : '';
                                final isSelected = _selectedProductIds.contains(prod.id);

                                return Container(
                                  color: isSelected ? const Color(0xFFEEF2FF) : Colors.transparent,
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: 40,
                                        child: InkWell(
                                          onTap: () {
                                            setState(() {
                                              if (isSelected) {
                                                _selectedProductIds.remove(prod.id);
                                              } else {
                                                _selectedProductIds.add(prod.id);
                                              }
                                            });
                                          },
                                          child: Icon(
                                            isSelected ? Icons.check_box : Icons.check_box_outline_blank,
                                            size: 16,
                                            color: isSelected ? const Color(0xFF4F46E5) : const Color(0xFFD1D5DB),
                                          ),
                                        ),
                                      ),

                                      // Product Image & Name & Variant (Width: 260)
                                      SizedBox(
                                        width: 260,
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 44,
                                              height: 44,
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFF3F4F6),
                                                borderRadius: BorderRadius.circular(8),
                                                image: imageUrl.isNotEmpty
                                                    ? DecorationImage(
                                                        image: imageUrl.startsWith('data:')
                                                            ? MemoryImage(base64Decode(imageUrl.split(',').last)) as ImageProvider
                                                            : (imageUrl.startsWith('http') ? NetworkImage(imageUrl) as ImageProvider : AssetImage(imageUrl)),
                                                        fit: BoxFit.cover,
                                                      )
                                                    : null,
                                              ),
                                              child: imageUrl.isEmpty ? const Icon(Icons.spa, color: Color(0xFF059669), size: 22) : null,
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    prod.name,
                                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF111827)),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                  const SizedBox(height: 3),
                                                  Row(
                                                    children: [
                                                      Text(v.sizeLabel, style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
                                                      if (prod.isFeatured) ...[
                                                        const SizedBox(width: 6),
                                                        Container(
                                                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
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

                                      // SKU / ID (Width: 160)
                                      SizedBox(
                                        width: 160,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFF3F4F6),
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                v.sku,
                                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF374151), fontFamily: 'monospace'),
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(prod.id, style: const TextStyle(fontSize: 10, color: Color(0xFF9CA3AF)), overflow: TextOverflow.ellipsis),
                                          ],
                                        ),
                                      ),

                                      // Category Pill (Width: 130)
                                      SizedBox(
                                        width: 130,
                                        child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: _getCategoryPillBg(prod.categoryId),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              prod.categoryId.replaceAll('cat-', '').toUpperCase(),
                                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: _getCategoryPillTextColor(prod.categoryId)),
                                            ),
                                          ),
                                        ),
                                      ),

                                      // Price & MRP (Width: 120)
                                      SizedBox(
                                        width: 120,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Text('₹${v.price.toInt()}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
                                                if (v.mrp > v.price) ...[
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    '₹${v.mrp.toInt()}',
                                                    style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF), decoration: TextDecoration.lineThrough),
                                                  ),
                                                ],
                                              ],
                                            ),
                                            if (v.discountPercent > 0) ...[
                                              const SizedBox(height: 2),
                                              Text('${v.discountPercent.toInt()}% OFF', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF059669))),
                                            ],
                                          ],
                                        ),
                                      ),

                                      // Stock Units & Restock CTA (Width: 130)
                                      SizedBox(
                                        width: 130,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Text('${v.stock} Units', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
                                                const SizedBox(width: 4),
                                                InkWell(
                                                  onTap: () => _showQuickRestockDialog(context, prod),
                                                  child: const Icon(Icons.add_circle_outline, size: 14, color: Color(0xFF4F46E5)),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              v.stock > 0 ? 'In Stock' : 'Out of Stock',
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: v.stock > 0 ? const Color(0xFF059669) : const Color(0xFFDC2626),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      // Status Badge (Width: 90)
                                      SizedBox(
                                        width: 90,
                                        child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: v.stock > 0 ? const Color(0xFFD1FAE5) : const Color(0xFFF3F4F6),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              v.stock > 0 ? 'Active' : 'Inactive',
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: v.stock > 0 ? const Color(0xFF059669) : const Color(0xFF6B7280),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),

                                      // Actions (Eye, Edit, Delete & 3-dot Menu) (Width: 180)
                                      SizedBox(
                                        width: 180,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            // View icon
                                            Tooltip(
                                              message: 'View Product Page',
                                              child: InkWell(
                                                onTap: () => context.push('/product/${prod.id}', extra: prod),
                                                borderRadius: BorderRadius.circular(6),
                                                child: Container(
                                                  padding: const EdgeInsets.all(5),
                                                  decoration: BoxDecoration(
                                                    color: const Color(0xFFF3F4F6),
                                                    borderRadius: BorderRadius.circular(6),
                                                    border: Border.all(color: const Color(0xFFE5E7EB)),
                                                  ),
                                                  child: const Icon(Icons.remove_red_eye_outlined, size: 14, color: Color(0xFF6B7280)),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            // Edit button
                                            Tooltip(
                                              message: 'Edit Product',
                                              child: InkWell(
                                                onTap: () => _showAddProductModal(context, prod),
                                                borderRadius: BorderRadius.circular(6),
                                                child: Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
                                                  decoration: BoxDecoration(
                                                    color: const Color(0xFFEEF2FF),
                                                    borderRadius: BorderRadius.circular(6),
                                                    border: Border.all(color: const Color(0xFFC7D2FE)),
                                                  ),
                                                  child: const Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      Icon(Icons.edit_outlined, size: 14, color: Color(0xFF4F46E5)),
                                                      SizedBox(width: 3),
                                                      Text('Edit', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF4F46E5))),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            // Delete button
                                            Tooltip(
                                              message: 'Delete Product',
                                              child: InkWell(
                                                onTap: () => _showDeleteConfirmationDialog(context, prod),
                                                borderRadius: BorderRadius.circular(6),
                                                child: Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
                                                  decoration: BoxDecoration(
                                                    color: const Color(0xFFFEE2E2),
                                                    borderRadius: BorderRadius.circular(6),
                                                    border: Border.all(color: const Color(0xFFFCA5A5)),
                                                  ),
                                                  child: const Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      Icon(Icons.delete_outline, size: 14, color: Color(0xFFDC2626)),
                                                      SizedBox(width: 3),
                                                      Text('Delete', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFDC2626))),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            // 3-dots menu
                                            PopupMenuButton<String>(
                                              padding: EdgeInsets.zero,
                                              icon: Container(
                                                padding: const EdgeInsets.all(5),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFFF3F4F6),
                                                  borderRadius: BorderRadius.circular(6),
                                                  border: Border.all(color: const Color(0xFFE5E7EB)),
                                                ),
                                                child: const Icon(Icons.more_vert, size: 14, color: Color(0xFF4B5563)),
                                              ),
                                              tooltip: 'More Options',
                                              onSelected: (action) {
                                                switch (action) {
                                                  case 'edit':
                                                    _showAddProductModal(context, prod);
                                                    break;
                                                  case 'change_image':
                                                    _showAddProductModal(context, prod);
                                                    break;
                                                  case 'restock':
                                                    _showQuickRestockDialog(context, prod);
                                                    break;
                                                  case 'copy_sku':
                                                    Clipboard.setData(ClipboardData(text: v.sku));
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      SnackBar(content: Text('Copied SKU "${v.sku}" to clipboard!')),
                                                    );
                                                    break;
                                                  case 'view':
                                                    context.push('/product/${prod.id}', extra: prod);
                                                    break;
                                                  case 'delete':
                                                    _showDeleteConfirmationDialog(context, prod);
                                                    break;
                                                }
                                              },
                                              itemBuilder: (context) => [
                                                const PopupMenuItem(
                                                  value: 'edit',
                                                  child: Row(
                                                    children: [
                                                      Icon(Icons.edit_outlined, size: 16, color: Color(0xFF4F46E5)),
                                                      SizedBox(width: 8),
                                                      Text('Edit Product', style: TextStyle(fontSize: 12)),
                                                    ],
                                                  ),
                                                ),
                                                const PopupMenuItem(
                                                  value: 'change_image',
                                                  child: Row(
                                                    children: [
                                                      Icon(Icons.image_outlined, size: 16, color: Color(0xFF059669)),
                                                      SizedBox(width: 8),
                                                      Text('Change Image / Assets', style: TextStyle(fontSize: 12)),
                                                    ],
                                                  ),
                                                ),
                                                const PopupMenuItem(
                                                  value: 'restock',
                                                  child: Row(
                                                    children: [
                                                      Icon(Icons.add_circle_outline, size: 16, color: Color(0xFF2563EB)),
                                                      SizedBox(width: 8),
                                                      Text('Quick Restock (+25)', style: TextStyle(fontSize: 12)),
                                                    ],
                                                  ),
                                                ),
                                                const PopupMenuItem(
                                                  value: 'copy_sku',
                                                  child: Row(
                                                    children: [
                                                      Icon(Icons.copy_outlined, size: 16, color: Color(0xFF374151)),
                                                      SizedBox(width: 8),
                                                      Text('Copy SKU', style: TextStyle(fontSize: 12)),
                                                    ],
                                                  ),
                                                ),
                                                const PopupMenuItem(
                                                  value: 'view',
                                                  child: Row(
                                                    children: [
                                                      Icon(Icons.remove_red_eye_outlined, size: 16, color: Color(0xFF6B7280)),
                                                      SizedBox(width: 8),
                                                      Text('View Product Page', style: TextStyle(fontSize: 12)),
                                                    ],
                                                  ),
                                                ),
                                                const PopupMenuDivider(),
                                                const PopupMenuItem(
                                                  value: 'delete',
                                                  child: Row(
                                                    children: [
                                                      Icon(Icons.delete_outline, size: 16, color: Color(0xFFDC2626)),
                                                      SizedBox(width: 8),
                                                      Text('Delete Product', style: TextStyle(fontSize: 12, color: Color(0xFFDC2626), fontWeight: FontWeight.bold)),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),

                      // Pagination Footer Bar
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Showing ${filteredProducts.length} of ${allProducts.length} products',
                              style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
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
                      _buildInventoryOverviewCard(allProducts),
                      const SizedBox(height: 16),
                      _buildQuickActionsCard(context, allProducts),
                      const SizedBox(height: 16),
                      _buildStockAlertsCard(allProducts),
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

  Widget _buildMetricCard(String title, String val, String sub, IconData icon, Color bg, Color iconColor, bool isPositive) {
    return Container(
      width: 195,
      padding: const EdgeInsets.all(16),
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
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
                child: Icon(icon, color: iconColor, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF6B7280))),
          const SizedBox(height: 4),
          Text(val, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
          const SizedBox(height: 4),
          Text(sub, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isPositive ? const Color(0xFF059669) : const Color(0xFFDC2626))),
        ],
      ),
    );
  }

  Widget _buildInventoryOverviewCard(List<ProductModel> products) {
    final total = products.length;
    final inStock = products.where((p) => p.defaultVariant.stock > 20).length;
    final lowStock = products.where((p) => p.defaultVariant.stock > 0 && p.defaultVariant.stock <= 20).length;
    final outOfStock = products.where((p) => p.defaultVariant.stock == 0).length;
    final inStockPct = total > 0 ? ((inStock / total) * 100).toInt() : 0;
    final lowStockPct = total > 0 ? ((lowStock / total) * 100).toInt() : 0;
    final outOfStockPct = total > 0 ? ((outOfStock / total) * 100).toInt() : 0;

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
                        value: total > 0 ? (inStock / total) : 0,
                        strokeWidth: 10,
                        backgroundColor: const Color(0xFFF3F4F6),
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF059669)),
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('$total', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
                        const Text('Total Products', style: TextStyle(fontSize: 8, color: Color(0xFF6B7280))),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLegendItem('In Stock', '$inStock ($inStockPct%)', const Color(0xFF059669)),
                    const SizedBox(height: 6),
                    _buildLegendItem('Low Stock', '$lowStock ($lowStockPct%)', const Color(0xFFD97706)),
                    const SizedBox(height: 6),
                    _buildLegendItem('Out of Stock', '$outOfStock ($outOfStockPct%)', const Color(0xFFDC2626)),
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

  Widget _buildQuickActionsCard(BuildContext context, List<ProductModel> products) {
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
          _buildQuickActionRow(context, Icons.file_download_outlined, 'Bulk Import Products', () => _showBulkImportModal(context)),
          _buildQuickActionRow(context, Icons.file_upload_outlined, 'Export Products JSON', () => _showExportModal(context, products)),
          _buildQuickActionRow(context, Icons.delete_forever_outlined, 'Clear All Products', () {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Clear All Products'),
                content: const Text('Are you sure you want to clear all products from the catalog?'),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFDC2626)),
                    onPressed: () {
                      ref.read(adminProductsProvider.notifier).clearAllProducts();
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Cleared all products from catalog.')),
                      );
                    },
                    child: const Text('Clear All', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            );
          }),
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

  Widget _buildStockAlertsCard(List<ProductModel> products) {
    final alertProducts = products.where((p) => p.defaultVariant.stock <= 20).toList();

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
          if (alertProducts.isEmpty)
            const Text('No stock alerts. All inventory levels healthy.', style: TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)))
          else
            ...alertProducts.take(3).map((p) {
              final isZero = p.defaultVariant.stock == 0;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _buildStockAlertRow(
                  p.name,
                  '${p.defaultVariant.stock} Units Left',
                  isZero ? 'Out of Stock' : 'Low Stock',
                  isZero ? const Color(0xFFFEE2E2) : const Color(0xFFFEF3C7),
                  isZero ? const Color(0xFFDC2626) : const Color(0xFFD97706),
                ),
              );
            }),
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
              Text(name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF111827)), maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 2),
              Text(sub, style: const TextStyle(fontSize: 10, color: Color(0xFF6B7280))),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(color: badgeBg, borderRadius: BorderRadius.circular(12)),
          child: Text(badgeText, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: badgeColor)),
        ),
      ],
    );
  }

  Color _getCategoryPillBg(String catId) {
    switch (catId) {
      case 'cat-haircare':
        return const Color(0xFFE0E7FF);
      case 'cat-skincare':
        return const Color(0xFFFEF3C7);
      case 'cat-wellness':
        return const Color(0xFFD1FAE5);
      default:
        return const Color(0xFFF3F4F6);
    }
  }

  Color _getCategoryPillTextColor(String catId) {
    switch (catId) {
      case 'cat-haircare':
        return const Color(0xFF4338CA);
      case 'cat-skincare':
        return const Color(0xFFB45309);
      case 'cat-wellness':
        return const Color(0xFF059669);
      default:
        return const Color(0xFF4B5563);
    }
  }
}
