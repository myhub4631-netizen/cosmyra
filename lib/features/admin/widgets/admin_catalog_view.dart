import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/theme/app_colors.dart';
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
  String? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    final products = ref.watch(adminProductsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header & Add Product Action
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Catalog & Inventory Management (SKU CRUD)',
                    style: TextStyle(
                      fontFamily: 'serif',
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.goldAccent : AppColors.forestSageDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Create, edit, adjust stock, and manage botanical formulations.',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? AppColors.textLightSecondary : AppColors.textDarkSecondary,
                    ),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () => _showAddEditProductDialog(context, null),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.forestSage,
                  foregroundColor: AppColors.softWhite,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add New Product'),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Filters & Search Bar
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        hintText: 'Search SKU, Product Name, or Ingredients...',
                        prefixIcon: Icon(Icons.search, size: 20),
                        border: InputBorder.none,
                      ),
                      onChanged: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
                    ),
                  ),
                  const SizedBox(width: 12),
                  DropdownButton<String?>(
                    value: _selectedCategory,
                    hint: const Text('Filter Category'),
                    underline: const SizedBox.shrink(),
                    items: const [
                      DropdownMenuItem(value: null, child: Text('All Categories')),
                      DropdownMenuItem(value: 'cat-haircare', child: Text('Haircare')),
                      DropdownMenuItem(value: 'cat-skincare', child: Text('Skincare')),
                      DropdownMenuItem(value: 'cat-wellness', child: Text('Wellness')),
                    ],
                    onChanged: (val) => setState(() => _selectedCategory = val),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Product List Table
          Builder(
            builder: (context) {
              final filteredList = products.where((p) {
                if (_selectedCategory != null && p.categoryId != _selectedCategory) return false;
                if (_searchQuery.isNotEmpty) {
                  final matchName = p.name.toLowerCase().contains(_searchQuery);
                  final matchSku = p.defaultVariant.sku.toLowerCase().contains(_searchQuery);
                  final matchIngredients = p.ingredients.toLowerCase().contains(_searchQuery);
                  return matchName || matchSku || matchIngredients;
                }
                return true;
              }).toList();

              if (filteredList.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(40),
                  child: Center(
                    child: Text('No products match your filter parameters.'),
                  ),
                );
              }

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredList.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final product = filteredList[index];
                  final variant = product.defaultVariant;
                  final isLowStock = variant.stock < 50;

                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: AppColors.forestSage.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                              image: product.imageUrls.isNotEmpty
                                  ? DecorationImage(
                                      image: product.imageUrls.first.startsWith('http')
                                          ? NetworkImage(product.imageUrls.first) as ImageProvider
                                          : AssetImage(product.imageUrls.first),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child: product.imageUrls.isEmpty ? const Icon(Icons.spa, color: AppColors.forestSage) : null,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        product.name,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                      ),
                                    ),
                                    if (product.isFeatured)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppColors.goldAccent.withValues(alpha: 0.2),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: const Text('FEATURED', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.goldAccent)),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'SKU: ${variant.sku} • Size: ${variant.sizeLabel} • Price: ₹${variant.price.toInt()} (MRP: ₹${variant.mrp.toInt()})',
                                  style: TextStyle(fontSize: 12, color: isDark ? AppColors.textLightSecondary : AppColors.textDarkSecondary),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Ingredients: ${product.ingredients}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: isLowStock ? AppColors.error.withValues(alpha: 0.1) : AppColors.success.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        'Stock: ${variant.stock} Units ${isLowStock ? "(LOW)" : ""}',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: isLowStock ? AppColors.error : AppColors.success,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    OutlinedButton(
                                      onPressed: () {
                                        ref.read(adminProductsProvider.notifier).restockProduct(product.id, 10);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('Restocked +10 units for ${product.name}')),
                                        );
                                      },
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        minimumSize: Size.zero,
                                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      ),
                                      child: const Text('+10 Restock', style: TextStyle(fontSize: 11)),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit_outlined, color: AppColors.info, size: 20),
                                tooltip: 'Edit Product',
                                onPressed: () => _showAddEditProductDialog(context, product),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 20),
                                tooltip: 'Delete / Archive',
                                onPressed: () {
                                  ref.read(adminProductsProvider.notifier).deleteProduct(product.id);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Archived ${product.name}')),
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  void _showAddEditProductDialog(BuildContext context, ProductModel? product) {
    showDialog(
      context: context,
      builder: (context) => AdminProductEditorDialog(product: product),
    );
  }
}
