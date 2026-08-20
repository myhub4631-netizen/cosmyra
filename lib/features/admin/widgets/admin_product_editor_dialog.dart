import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/utils/web_image_picker.dart';
import '../../../config/theme/app_colors.dart';
import '../../catalog/models/product_model.dart';
import '../../catalog/repositories/product_repository.dart';
import '../../cart/controllers/cart_controller.dart';
import 'admin_media_view.dart';

class AdminProductEditorDialog extends ConsumerStatefulWidget {
  final ProductModel? product;

  const AdminProductEditorDialog({super.key, this.product});

  @override
  ConsumerState<AdminProductEditorDialog> createState() => _AdminProductEditorDialogState();
}

class _AdminProductEditorDialogState extends ConsumerState<AdminProductEditorDialog> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Tab 1: Basic & Pricing
  late TextEditingController _nameController;
  late TextEditingController _slugController;
  late TextEditingController _skuController;
  late TextEditingController _sizeController;
  late TextEditingController _priceController;
  late TextEditingController _mrpController;
  late TextEditingController _stockController;
  String _selectedCategory = 'cat-haircare';
  bool _isFeatured = false;

  // Tab 2: Descriptions & Botanicals
  late TextEditingController _taglineController;
  late TextEditingController _descController;
  late TextEditingController _ingredientsController;
  late TextEditingController _howToUseController;
  bool _vataBalance = true;
  bool _pittaBalance = true;
  bool _kaphaBalance = false;

  // Tab 3: Image Gallery
  late List<String> _imageUrls;
  int _primaryImageIndex = 0;
  late TextEditingController _newImageUrlController;
  late TextEditingController _imageAltController;

  // Tab 4: SEO & Metadata
  late TextEditingController _metaTitleController;
  late TextEditingController _metaDescController;
  late TextEditingController _keywordsController;
  late TextEditingController _canonicalUrlController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    final p = widget.product;
    _nameController = TextEditingController(text: p?.name ?? '');
    _slugController = TextEditingController(text: p?.slug ?? '');
    _skuController = TextEditingController(text: p?.defaultVariant.sku ?? '');
    _sizeController = TextEditingController(text: p?.defaultVariant.sizeLabel ?? '');
    _priceController = TextEditingController(text: p?.defaultVariant.price.toInt().toString() ?? '');
    _mrpController = TextEditingController(text: p?.defaultVariant.mrp.toInt().toString() ?? '');
    _stockController = TextEditingController(text: p?.defaultVariant.stock.toString() ?? '100');
    _selectedCategory = p?.categoryId ?? 'cat-haircare';
    _isFeatured = p?.isFeatured ?? false;

    _taglineController = TextEditingController(text: p?.tagline ?? 'Clinically proven botanical formulation');
    _descController = TextEditingController(text: p?.description ?? '');
    _ingredientsController = TextEditingController(text: p?.ingredients ?? '');
    _howToUseController = TextEditingController(text: p?.howToUse ?? 'Apply generously onto damp area and massage gently for 2 minutes.');
    _vataBalance = true;
    _pittaBalance = true;
    _kaphaBalance = false;

    _imageUrls = p != null && p.imageUrls.isNotEmpty
        ? List.from(p.imageUrls)
        : ['assets/images/shampoo.jpg'];
    _newImageUrlController = TextEditingController();
    _imageAltController = TextEditingController(text: '${p?.name ?? "Cosmyra Product"} - Vaidyam Botanicals');

    _metaTitleController = TextEditingController(text: p != null ? '${p.name} | Cosmyra Vaidyam Botanicals' : 'Ayurvedic Botanical Skin & Haircare | Cosmyra');
    _metaDescController = TextEditingController(
      text: p != null
          ? 'Buy ${p.name} online. ${p.tagline ?? p.description}'
          : 'Pure Ayurvedic botanical cosmetics handcrafted with organic ingredients for modern wellness.',
    );
    _keywordsController = TextEditingController(text: 'ayurveda, botanical haircare, sulfate free, herbal shampoo, organic cosmetics');
    _canonicalUrlController = TextEditingController(text: 'https://cosmyra.com/product/${p?.slug ?? "botanical-product"}');
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _slugController.dispose();
    _skuController.dispose();
    _sizeController.dispose();
    _priceController.dispose();
    _mrpController.dispose();
    _stockController.dispose();
    _taglineController.dispose();
    _descController.dispose();
    _ingredientsController.dispose();
    _howToUseController.dispose();
    _newImageUrlController.dispose();
    _imageAltController.dispose();
    _metaTitleController.dispose();
    _metaDescController.dispose();
    _keywordsController.dispose();
    _canonicalUrlController.dispose();
    super.dispose();
  }

  Future<void> _pickLocalComputerImage() async {
    try {
      final base64Result = await pickImageWebSafe();
      if (base64Result != null && base64Result.isNotEmpty) {
        setState(() {
          _imageUrls.insert(0, base64Result);
          _primaryImageIndex = 0;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✓ Custom image added successfully!'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error selecting image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  ImageProvider _getGalleryImageProvider(String url) {
    if (url.startsWith('data:')) {
      try {
        String cleanBase64 = url.split(',').last.replaceAll(RegExp(r'[\r\n\s]+'), '');
        try {
          return MemoryImage(base64Decode(cleanBase64));
        } catch (_) {
          cleanBase64 = Uri.decodeComponent(cleanBase64).replaceAll(RegExp(r'[\r\n\s]+'), '');
          return MemoryImage(base64Decode(cleanBase64));
        }
      } catch (_) {
        return const AssetImage('assets/images/shampoo.jpg');
      }
    } else if (url.startsWith('http://') || url.startsWith('https://')) {
      return NetworkImage(url);
    } else if (url.isNotEmpty) {
      return AssetImage(url);
    }
    return const AssetImage('assets/images/shampoo.jpg');
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.product != null;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Calculate discount %
    final priceVal = double.tryParse(_priceController.text) ?? 0.0;
    final mrpVal = double.tryParse(_mrpController.text) ?? 0.0;
    final discountPct = mrpVal > priceVal && mrpVal > 0 ? (((mrpVal - priceVal) / mrpVal) * 100).round() : 0;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 780,
        height: 680,
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Header Bar
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.forestSage.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.edit_note, color: AppColors.forestSage, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isEditing ? 'Edit Botanical Product & SEO Specs' : 'Add New Botanical Product & Master Specs',
                        style: const TextStyle(fontFamily: 'serif', fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Configure pricing, descriptions, multi-image gallery, and Google SERP metadata.',
                        style: TextStyle(fontSize: 12, color: isDark ? AppColors.textLightSecondary : AppColors.textDarkSecondary),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Tab Bar
            TabBar(
              controller: _tabController,
              labelColor: isDark ? AppColors.goldAccent : AppColors.forestSage,
              indicatorColor: isDark ? AppColors.goldAccent : AppColors.forestSage,
              tabs: const [
                Tab(icon: Icon(Icons.sell_outlined), text: '1. Basic & Pricing'),
                Tab(icon: Icon(Icons.description_outlined), text: '2. Botanicals & Details'),
                Tab(icon: Icon(Icons.collections_outlined), text: '3. Image Gallery'),
                Tab(icon: Icon(Icons.travel_explore), text: '4. SEO & Metadata'),
              ],
            ),

            const SizedBox(height: 16),

            // Tab Bar Body
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Tab 1: Basic & Pricing
                  SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: TextField(
                                controller: _nameController,
                                decoration: const InputDecoration(labelText: 'Product Name *', hintText: 'e.g. Vaidyam Anti-Dandruff Shampoo'),
                                onChanged: (val) {
                                  if (!isEditing) {
                                    final slug = val.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-').replaceAll(RegExp(r'^-|-$'), '');
                                    _slugController.text = slug;
                                    _canonicalUrlController.text = 'https://cosmyra.com/product/$slug';
                                    setState(() {});
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 1,
                              child: DropdownButtonFormField<String>(
                                initialValue: _selectedCategory,
                                decoration: const InputDecoration(labelText: 'Category *'),
                                items: const [
                                  DropdownMenuItem(value: 'cat-haircare', child: Text('Haircare')),
                                  DropdownMenuItem(value: 'cat-skincare', child: Text('Skincare')),
                                  DropdownMenuItem(value: 'cat-wellness', child: Text('Wellness')),
                                ],
                                onChanged: (val) => setState(() => _selectedCategory = val ?? 'cat-haircare'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _slugController,
                                decoration: const InputDecoration(labelText: 'URL Slug', hintText: 'vaidyam-anti-dandruff-shampoo'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                controller: _skuController,
                                decoration: const InputDecoration(labelText: 'SKU Code *'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                controller: _sizeController,
                                decoration: const InputDecoration(labelText: 'Size / Volume *', hintText: '200 ml'),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),
                        const Text('Pricing & Inventory Controls', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, fontFamily: 'serif')),
                        const SizedBox(height: 8),

                        Card(
                          color: AppColors.forestSage.withOpacity(0.05),
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _priceController,
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(labelText: 'Selling Price (₹) *'),
                                    onChanged: (_) => setState(() {}),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TextField(
                                    controller: _mrpController,
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(labelText: 'MRP (₹) *'),
                                    onChanged: (_) => setState(() {}),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.goldAccent.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Column(
                                    children: [
                                      const Text('Calculated Savings', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                                      Text(
                                        '$discountPct% OFF',
                                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.goldAccent),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TextField(
                                    controller: _stockController,
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(labelText: 'Available Stock *'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),
                        SwitchListTile(
                          title: const Text('Mark as Featured Formulation'),
                          subtitle: const Text('Display in Bestsellers hero carousel'),
                          value: _isFeatured,
                          activeTrackColor: AppColors.goldAccent,
                          onChanged: (val) => setState(() => _isFeatured = val),
                        ),
                      ],
                    ),
                  ),

                  // Tab 2: Botanicals & Details
                  SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          controller: _taglineController,
                          decoration: const InputDecoration(
                            labelText: 'Product Tagline / Punchline *',
                            hintText: 'e.g. Clinically proven botanical defense against flakes & scalp itch',
                          ),
                        ),
                        const SizedBox(height: 14),
                        TextField(
                          controller: _descController,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            labelText: 'Full Formulation Description *',
                            hintText: 'Detailed breakdown of ingredients, therapeutic benefits, and scalp microbiome balance.',
                          ),
                        ),
                        const SizedBox(height: 14),
                        TextField(
                          controller: _ingredientsController,
                          maxLines: 2,
                          decoration: const InputDecoration(
                            labelText: 'Botanical Ingredients (INCI List) *',
                            hintText: 'Aqua, Tea Tree Leaf Oil, Azadirachta Indica (Neem) Leaf Extract...',
                          ),
                        ),
                        const SizedBox(height: 14),
                        TextField(
                          controller: _howToUseController,
                          maxLines: 2,
                          decoration: const InputDecoration(
                            labelText: 'Application Rituals & Directions *',
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text('Ayurvedic Dosha Balancing Profile', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            FilterChip(
                              label: const Text('Vata Balancing'),
                              selected: _vataBalance,
                              selectedColor: AppColors.forestSage.withOpacity(0.2),
                              onSelected: (val) => setState(() => _vataBalance = val),
                            ),
                            const SizedBox(width: 8),
                            FilterChip(
                              label: const Text('Pitta Soothing'),
                              selected: _pittaBalance,
                              selectedColor: AppColors.goldAccent.withOpacity(0.2),
                              onSelected: (val) => setState(() => _pittaBalance = val),
                            ),
                            const SizedBox(width: 8),
                            FilterChip(
                              label: const Text('Kapha Cleansing'),
                              selected: _kaphaBalance,
                              selectedColor: AppColors.info.withOpacity(0.2),
                              onSelected: (val) => setState(() => _kaphaBalance = val),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Tab 3: Image Gallery
                  SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Computer File Upload Card Container
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1F2937) : const Color(0xFFF9FAFB),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.cloud_upload_outlined, color: AppColors.forestSage, size: 22),
                                  SizedBox(width: 8),
                                  Text(
                                    'Upload Custom Image from Computer',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textDarkPrimary),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Select high quality photos from your device (JPG, JPEG, PNG, WEBP, GIF, BMP)',
                                style: TextStyle(fontSize: 11, color: AppColors.textDarkSecondary),
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton.icon(
                                onPressed: _pickLocalComputerImage,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.forestSage,
                                  foregroundColor: AppColors.softWhite,
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                icon: const Icon(Icons.folder_open, size: 18),
                                label: const Text('Browse Files from Computer', style: TextStyle(fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Web URL / Asset Path Option
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _newImageUrlController,
                                decoration: const InputDecoration(
                                  labelText: 'Or Paste Image URL / Asset Path',
                                  hintText: 'assets/images/shampoo.jpg or https://...',
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton.icon(
                              onPressed: () {
                                if (_newImageUrlController.text.trim().isNotEmpty) {
                                  setState(() {
                                    _imageUrls.insert(0, _newImageUrlController.text.trim());
                                    _primaryImageIndex = 0;
                                    _newImageUrlController.clear();
                                  });
                                }
                              },
                              style: ElevatedButton.styleFrom(backgroundColor: AppColors.forestSage, foregroundColor: AppColors.softWhite),
                              icon: const Icon(Icons.add_photo_alternate, size: 18),
                              label: const Text('Add URL'),
                            ),
                            const SizedBox(width: 8),
                            OutlinedButton.icon(
                              onPressed: () async {
                                final selected = await showMediaPickerModal(context);
                                if (selected != null && selected.isNotEmpty) {
                                  setState(() {
                                    _imageUrls.insert(0, selected);
                                    _primaryImageIndex = 0;
                                  });
                                }
                              },
                              icon: const Icon(Icons.perm_media_outlined, size: 18),
                              label: const Text('Media Library'),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Color(0xFF4F46E5)),
                                foregroundColor: const Color(0xFF4F46E5),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Text('Quick Preset Luxury Assets:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: [
                            ActionChip(
                              avatar: const Icon(Icons.add, size: 14),
                              label: const Text('Shampoo Bottle'),
                              onPressed: () => setState(() {
                                _imageUrls.insert(0, 'assets/images/shampoo.jpg');
                                _primaryImageIndex = 0;
                              }),
                            ),
                            ActionChip(
                              avatar: const Icon(Icons.add, size: 14),
                              label: const Text('Handcrafted Soap'),
                              onPressed: () => setState(() {
                                _imageUrls.insert(0, 'assets/images/soap.jpg');
                                _primaryImageIndex = 0;
                              }),
                            ),
                            ActionChip(
                              avatar: const Icon(Icons.add, size: 14),
                              label: const Text('Face Wash Gel'),
                              onPressed: () => setState(() {
                                _imageUrls.insert(0, 'assets/images/facewash.jpg');
                                _primaryImageIndex = 0;
                              }),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Text('Configured Product Gallery Assets:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        const SizedBox(height: 12),

                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: List.generate(_imageUrls.length, (idx) {
                            final url = _imageUrls[idx];
                            final isPrimary = _primaryImageIndex == idx;

                            return Container(
                              width: 160,
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardTheme.color,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: isPrimary ? AppColors.goldAccent : AppColors.creamBorder, width: isPrimary ? 2 : 1),
                              ),
                              child: Column(
                                children: [
                                  Container(
                                    height: 90,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: AppColors.forestSage.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(6),
                                      image: DecorationImage(
                                        image: _getGalleryImageProvider(url),
                                        fit: BoxFit.cover,
                                        onError: (_, __) {},
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      InkWell(
                                        onTap: () => setState(() => _primaryImageIndex = idx),
                                        child: Text(
                                          isPrimary ? '★ Primary' : 'Set Primary',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: isPrimary ? FontWeight.bold : FontWeight.normal,
                                            color: isPrimary ? AppColors.goldAccent : AppColors.textDarkSecondary,
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline, size: 16, color: AppColors.error),
                                        onPressed: () {
                                          if (_imageUrls.length > 1) {
                                            setState(() {
                                              _imageUrls.removeAt(idx);
                                              if (_primaryImageIndex >= _imageUrls.length) {
                                                _primaryImageIndex = 0;
                                              }
                                            });
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          }),
                        ),

                        const SizedBox(height: 16),
                        TextField(
                          controller: _imageAltController,
                          decoration: const InputDecoration(
                            labelText: 'Image Accessibility Alt Text',
                            hintText: 'Vaidyam Botanical Shampoo bottle with natural ingredients',
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0FDF4),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFBBF7D0)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.sync_outlined, color: Color(0xFF166534), size: 18),
                                  const SizedBox(width: 8),
                                  const Text('Single Source of Truth Media Sync Status', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF166534), fontSize: 13)),
                                  const Spacer(),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFDCFCE7),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      'Media v${widget.product?.mediaVersion ?? 1} | Prod v${widget.product?.productVersion ?? 1}',
                                      style: const TextStyle(color: Color(0xFF15803D), fontSize: 10, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              const Wrap(
                                spacing: 12,
                                runSpacing: 6,
                                children: [
                                  Text('✓ Website', style: TextStyle(fontSize: 11, color: Color(0xFF15803D), fontWeight: FontWeight.w600)),
                                  Text('✓ Mobile App', style: TextStyle(fontSize: 11, color: Color(0xFF15803D), fontWeight: FontWeight.w600)),
                                  Text('✓ Product Page', style: TextStyle(fontSize: 11, color: Color(0xFF15803D), fontWeight: FontWeight.w600)),
                                  Text('✓ Homepage', style: TextStyle(fontSize: 11, color: Color(0xFF15803D), fontWeight: FontWeight.w600)),
                                  Text('✓ Category Listings', style: TextStyle(fontSize: 11, color: Color(0xFF15803D), fontWeight: FontWeight.w600)),
                                  Text('✓ Search', style: TextStyle(fontSize: 11, color: Color(0xFF15803D), fontWeight: FontWeight.w600)),
                                  Text('✓ Deals', style: TextStyle(fontSize: 11, color: Color(0xFF15803D), fontWeight: FontWeight.w600)),
                                  Text('✓ Wishlist & Cart', style: TextStyle(fontSize: 11, color: Color(0xFF15803D), fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Tab 4: SEO & Metadata
                  SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          controller: _metaTitleController,
                          decoration: const InputDecoration(
                            labelText: 'SEO Title Tag (60 chars max) *',
                            hintText: 'Vaidyam Anti-Dandruff Herbal Shampoo | Cosmyra',
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                        const SizedBox(height: 14),
                        TextField(
                          controller: _metaDescController,
                          maxLines: 2,
                          decoration: const InputDecoration(
                            labelText: 'SEO Meta Description (160 chars max) *',
                            hintText: 'Buy Vaidyam Anti-Dandruff Herbal Shampoo online. Pure Ayurvedic botanical scalp defense.',
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _keywordsController,
                                decoration: const InputDecoration(
                                  labelText: 'Target Keywords (Comma Separated)',
                                  hintText: 'herbal shampoo, scalp care, ayurvedic shampoo',
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                controller: _canonicalUrlController,
                                decoration: const InputDecoration(
                                  labelText: 'Canonical URL',
                                  hintText: 'https://cosmyra.com/product/vaidyam-shampoo',
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 18),
                        const Text('Live Google Search Snippet Preview:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, fontFamily: 'serif')),
                        const SizedBox(height: 8),

                        // SERP Card Preview
                        Card(
                          color: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _canonicalUrlController.text,
                                  style: const TextStyle(fontSize: 11, color: Color(0xFF202124)),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _metaTitleController.text,
                                  style: const TextStyle(fontSize: 16, color: Color(0xFF1A0DAB), fontWeight: FontWeight.w500),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _metaDescController.text,
                                  style: const TextStyle(fontSize: 13, color: Color(0xFF4D5156)),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Dialog Actions Footer
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () async {
                    try {
                      final pendingUrl = _newImageUrlController.text.trim();
                      final finalImageUrls = List<String>.from(_imageUrls);
                      if (pendingUrl.isNotEmpty && !finalImageUrls.contains(pendingUrl)) {
                        finalImageUrls.insert(0, pendingUrl);
                      }
                      if (_primaryImageIndex > 0 && _primaryImageIndex < finalImageUrls.length) {
                        final primaryUrl = finalImageUrls.removeAt(_primaryImageIndex);
                        finalImageUrls.insert(0, primaryUrl);
                      }

                      final name = _nameController.text.trim().isEmpty ? (widget.product?.name ?? 'New Botanical Product') : _nameController.text.trim();
                      final price = double.tryParse(_priceController.text) ?? (widget.product?.defaultVariant.price ?? 399.0);
                      final mrp = double.tryParse(_mrpController.text) ?? (widget.product?.defaultVariant.mrp ?? 499.0);
                      final stock = int.tryParse(_stockController.text) ?? (widget.product?.defaultVariant.stock ?? 100);
                      final sku = _skuController.text.trim().isEmpty
                          ? (widget.product?.defaultVariant.sku ?? 'VDY-SKU-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}')
                          : _skuController.text.trim();
                      final size = _sizeController.text.trim().isEmpty ? (widget.product?.defaultVariant.sizeLabel ?? '200 ml') : _sizeController.text.trim();
                      final prodId = (widget.product?.id ?? '').trim().isEmpty ? 'prod-${DateTime.now().millisecondsSinceEpoch}' : widget.product!.id.trim();

                      final variant = ProductVariant(
                        id: widget.product?.defaultVariant.id ?? 'var-${DateTime.now().millisecondsSinceEpoch}',
                        productId: prodId,
                        sku: sku,
                        sizeLabel: size,
                        price: price,
                        mrp: mrp,
                        stock: stock,
                        isDefault: true,
                      );

                      final updatedProd = ProductModel(
                        id: prodId,
                        brandId: widget.product?.brandId ?? 'brand-vaidyam',
                        categoryId: _selectedCategory,
                        name: name,
                        slug: _slugController.text.trim().isEmpty ? (widget.product?.slug ?? 'botanical-product') : _slugController.text.trim(),
                        tagline: _taglineController.text.trim(),
                        description: _descController.text.trim().isEmpty ? (widget.product?.description ?? 'Pure botanical formulation.') : _descController.text.trim(),
                        ingredients: _ingredientsController.text.trim().isEmpty ? (widget.product?.ingredients ?? 'Aqua, Botanical Extracts.') : _ingredientsController.text.trim(),
                        howToUse: _howToUseController.text.trim(),
                        freeFromClaims: widget.product?.freeFromClaims ?? const ['Sulfate Free', 'Paraben Free', 'Cruelty Free'],
                        variants: [variant],
                        imageUrls: finalImageUrls,
                        isFeatured: _isFeatured,
                      );

                      if (isEditing) {
                        ref.read(adminProductsProvider.notifier).updateProduct(updatedProd);
                        ref.read(cartProvider.notifier).refreshProductData(updatedProd);
                      } else {
                        ref.read(adminProductsProvider.notifier).addProduct(updatedProd);
                      }

                      ref.invalidate(productsFutureProvider);
                      ref.invalidate(filteredProductsProvider);

                      if (context.mounted) {
                        Navigator.of(context).pop(updatedProd);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(isEditing ? '✓ Saved "$name" & Synced Live!' : '✓ Published "$name" Live to Store!'),
                                ),
                              ],
                            ),
                            backgroundColor: const Color(0xFF059669),
                            behavior: SnackBarBehavior.floating,
                            duration: const Duration(seconds: 3),
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error saving product: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.forestSage, foregroundColor: AppColors.softWhite),
                  icon: const Icon(Icons.check_circle_outline, size: 18),
                  label: Text(isEditing ? 'Save Product & SEO Specs' : 'Publish Product'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
