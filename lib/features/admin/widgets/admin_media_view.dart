import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/utils/web_image_picker.dart';
import '../../catalog/widgets/product_image_widget.dart';
import '../models/media_item_model.dart';
import '../repositories/media_repository.dart';

/// Admin Media Management View Widget
class AdminMediaView extends ConsumerStatefulWidget {
  const AdminMediaView({super.key});

  @override
  ConsumerState<AdminMediaView> createState() => _AdminMediaViewState();
}

class _AdminMediaViewState extends ConsumerState<AdminMediaView> {
  String _searchQuery = '';
  String _selectedCategory = 'All Categories';
  String _sortBy = 'Newest';
  bool _isGridView = true;

  final Set<String> _selectedMediaIds = {};

  final List<String> _categories = [
    'All Categories',
    'Products',
    'Banners',
    'Logos',
    'Promos',
    'General',
  ];

  Future<void> _handleUploadFromComputer() async {
    try {
      final base64Result = await pickImageWebSafe();
      if (base64Result != null && base64Result.isNotEmpty) {
        if (!mounted) return;

        final nameController = TextEditingController(text: 'Uploaded Asset ${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}');
        String selectedCat = 'Products';

        await showDialog(
          context: context,
          builder: (ctx) => StatefulBuilder(
            builder: (context, setModalState) => AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text('Save Uploaded Asset', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              content: SizedBox(
                width: 440,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      height: 140,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: ProductImageWidget(imageUrl: base64Result, fit: BoxFit.contain),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Asset Name / Title',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: selectedCat,
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(),
                      ),
                      items: ['Products', 'Banners', 'Logos', 'Promos', 'General']
                          .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                          .toList(),
                      onChanged: (val) => setModalState(() => selectedCat = val ?? 'Products'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                ElevatedButton.icon(
                  onPressed: () {
                    ref.read(adminMediaProvider.notifier).addMedia(
                          name: nameController.text,
                          url: base64Result,
                          category: selectedCat,
                        );
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('✓ Media asset uploaded & saved successfully!'),
                        backgroundColor: Color(0xFF059669),
                      ),
                    );
                  },
                  icon: const Icon(Icons.cloud_upload),
                  label: const Text('Save Asset'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4F46E5),
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _handleAddUrlModal() async {
    final nameController = TextEditingController();
    final urlController = TextEditingController();
    String category = 'Products';

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Add Media by URL', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          content: SizedBox(
            width: 460,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Asset Name',
                    hintText: 'e.g. Saffron Face Serum Bottle',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: urlController,
                  decoration: const InputDecoration(
                    labelText: 'Image Web URL',
                    hintText: 'https://images.unsplash.com/... or assets/images/...',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: category,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  items: ['Products', 'Banners', 'Logos', 'Promos', 'General']
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (val) => setModalState(() => category = val ?? 'Products'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton.icon(
              onPressed: () {
                if (urlController.text.trim().isNotEmpty) {
                  ref.read(adminMediaProvider.notifier).addMedia(
                        name: nameController.text,
                        url: urlController.text,
                        category: category,
                      );
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('✓ Image URL added to Media Library!'),
                      backgroundColor: Color(0xFF059669),
                    ),
                  );
                }
              },
              icon: const Icon(Icons.add_link),
              label: const Text('Add Asset'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4F46E5),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showInspectModal(MediaItem item) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: 680,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      item.name,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Center(
                child: Container(
                  height: 320,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: ProductImageWidget(imageUrl: item.url, fit: BoxFit.contain),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _infoPill('Category', item.category),
                    _infoPill('File Format', item.fileType),
                    _infoPill('File Size', item.formattedSize),
                    _infoPill('Dimensions', item.dimensions),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: item.url));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('📋 Asset URL copied to clipboard!')),
                        );
                      },
                      icon: const Icon(Icons.copy, size: 16),
                      label: const Text('Copy Asset URL / Code'),
                      style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: () async {
                      await ref.read(adminMediaProvider.notifier).deleteMedia(item.id);
                      if (ctx.mounted) Navigator.pop(ctx);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Asset deleted from library.')),
                        );
                      }
                    },
                    icon: const Icon(Icons.delete_outline, size: 16),
                    label: const Text('Delete Asset'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFDC2626),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoPill(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaItems = ref.watch(adminMediaProvider);

    // Apply Filter & Search
    List<MediaItem> filtered = mediaItems.where((item) {
      if (_selectedCategory != 'All Categories' && item.category != _selectedCategory) {
        return false;
      }
      final query = _searchQuery.trim().toLowerCase();
      if (query.isNotEmpty) {
        return item.name.toLowerCase().contains(query) || item.category.toLowerCase().contains(query);
      }
      return true;
    }).toList();

    // Sort
    if (_sortBy == 'Newest') {
      filtered.sort((a, b) => b.uploadedAt.compareTo(a.uploadedAt));
    } else if (_sortBy == 'Oldest') {
      filtered.sort((a, b) => a.uploadedAt.compareTo(b.uploadedAt));
    } else if (_sortBy == 'Size') {
      filtered.sort((a, b) => b.sizeBytes.compareTo(a.sizeBytes));
    } else if (_sortBy == 'Name') {
      filtered.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    }

    final int totalCount = mediaItems.length;
    final double totalMb = mediaItems.fold(0, (sum, m) => sum + m.sizeBytes) / (1024 * 1024);
    final int productCount = mediaItems.where((m) => m.category == 'Products').length;
    final int bannerCount = mediaItems.where((m) => m.category == 'Banners').length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header Toolbar Title & Primary Upload Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Media Library & Assets',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF111827)),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Manage all product photography, banners, logos, and marketing images.',
                    style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
                  ),
                ],
              ),
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: _handleAddUrlModal,
                    icon: const Icon(Icons.add_link, size: 18, color: Color(0xFF374151)),
                    label: const Text('Add Image URL', style: TextStyle(color: Color(0xFF374151), fontSize: 13, fontWeight: FontWeight.w600)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      side: const BorderSide(color: Color(0xFFD1D5DB)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton.icon(
                    onPressed: _handleUploadFromComputer,
                    icon: const Icon(Icons.cloud_upload_rounded, size: 18),
                    label: const Text('+ Upload Media File', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4F46E5),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      elevation: 1,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 24),

          // 2. Metrics Summary Cards Row
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _buildMetricCard('Total Assets', '$totalCount Files', 'Stored Media', Icons.perm_media_outlined, const Color(0xFFEEF2FF), const Color(0xFF4F46E5)),
              _buildMetricCard('Storage Used', '${totalMb.toStringAsFixed(1)} MB', 'Library Size', Icons.sd_card_outlined, const Color(0xFFD1FAE5), const Color(0xFF059669)),
              _buildMetricCard('Product Shots', '$productCount Items', 'Catalog Assets', Icons.shopping_bag_outlined, const Color(0xFFFEF3C7), const Color(0xFFD97706)),
              _buildMetricCard('Banners & Hero', '$bannerCount Items', 'CMS Graphics', Icons.burst_mode_outlined, const Color(0xFFF3E8FF), const Color(0xFF9333EA)),
            ],
          ),

          const SizedBox(height: 24),

          // 3. Search & Category Filters Bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Row(
              children: [
                // Search Input Box
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
                            onChanged: (val) => setState(() => _searchQuery = val),
                            style: const TextStyle(fontSize: 13),
                            decoration: const InputDecoration(
                              hintText: 'Search media assets by name or category...',
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
                const SizedBox(width: 16),

                // Category Filter Dropdown
                Container(
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedCategory,
                      style: const TextStyle(fontSize: 13, color: Color(0xFF374151), fontWeight: FontWeight.w500),
                      items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                      onChanged: (val) => setState(() => _selectedCategory = val ?? 'All Categories'),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Sort Dropdown
                Container(
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _sortBy,
                      style: const TextStyle(fontSize: 13, color: Color(0xFF374151), fontWeight: FontWeight.w500),
                      items: ['Newest', 'Oldest', 'Size', 'Name']
                          .map((s) => DropdownMenuItem(value: s, child: Text('Sort: $s')))
                          .toList(),
                      onChanged: (val) => setState(() => _sortBy = val ?? 'Newest'),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // View Mode Toggle Icons
                IconButton(
                  icon: Icon(Icons.grid_view, color: _isGridView ? const Color(0xFF4F46E5) : const Color(0xFF9CA3AF)),
                  onPressed: () => setState(() => _isGridView = true),
                ),
                IconButton(
                  icon: Icon(Icons.view_list_rounded, color: !_isGridView ? const Color(0xFF4F46E5) : const Color(0xFF9CA3AF)),
                  onPressed: () => setState(() => _isGridView = false),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 4. Media Asset Grid / List View Container
          filtered.isEmpty
              ? Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(48),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: Column(
                    children: const [
                      Icon(Icons.photo_library_outlined, size: 48, color: Color(0xFF9CA3AF)),
                      SizedBox(height: 12),
                      Text('No Media Assets Found', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF111827))),
                      SizedBox(height: 4),
                      Text('Try uploading new images or clearing search filters.', style: TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
                    ],
                  ),
                )
              : _isGridView
                  ? GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filtered.length,
                      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 240,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.82,
                      ),
                      itemBuilder: (context, index) {
                        final item = filtered[index];
                        return _buildMediaCard(item);
                      },
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final item = filtered[index];
                        return _buildMediaRow(item);
                      },
                    ),
        ],
      ),
    );
  }

  Widget _buildMediaCard(MediaItem item) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: const [BoxShadow(color: Color(0x05000000), blurRadius: 6, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Preview Container
          Expanded(
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: SizedBox(
                    width: double.infinity,
                    height: double.infinity,
                    child: ProductImageWidget(imageUrl: item.url, fit: BoxFit.cover),
                  ),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.65),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      item.category,
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Metadata & Quick Actions
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF111827)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${item.fileType} • ${item.formattedSize}',
                      style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.copy, size: 16, color: Color(0xFF4F46E5)),
                          tooltip: 'Copy Asset Code / URL',
                          constraints: const BoxConstraints(),
                          padding: const EdgeInsets.all(4),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: item.url));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('📋 Asset URL copied to clipboard!')),
                            );
                          },
                        ),
                        const SizedBox(width: 4),
                        IconButton(
                          icon: const Icon(Icons.visibility_outlined, size: 16, color: Color(0xFF059669)),
                          tooltip: 'Inspect Asset',
                          constraints: const BoxConstraints(),
                          padding: const EdgeInsets.all(4),
                          onPressed: () => _showInspectModal(item),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaRow(MediaItem item) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 60,
              height: 60,
              child: ProductImageWidget(imageUrl: item.url, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF111827))),
                const SizedBox(height: 4),
                Text('${item.category} • ${item.dimensions} • ${item.formattedSize}', style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
              ],
            ),
          ),
          OutlinedButton.icon(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: item.url));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('📋 Asset URL copied!')),
              );
            },
            icon: const Icon(Icons.copy, size: 14),
            label: const Text('Copy Link', style: TextStyle(fontSize: 12)),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.visibility_outlined, color: Color(0xFF059669)),
            onPressed: () => _showInspectModal(item),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Color(0xFFDC2626)),
            onPressed: () => ref.read(adminMediaProvider.notifier).deleteMedia(item.id),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, String sub, IconData icon, Color bg, Color color) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
            ],
          ),
        ],
      ),
    );
  }
}

/// Helper Modal to allow selecting any asset from Media Library anywhere in the Admin console
Future<String?> showMediaPickerModal(BuildContext context) async {
  String? selectedUrl;

  await showDialog(
    context: context,
    builder: (ctx) => Consumer(
      builder: (context, ref, child) {
        final mediaItems = ref.watch(adminMediaProvider);
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            width: 780,
            height: 600,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Select Asset from Media Library', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
                    IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: GridView.builder(
                    itemCount: mediaItems.length,
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 180,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.9,
                    ),
                    itemBuilder: (context, index) {
                      final item = mediaItems[index];
                      return InkWell(
                        onTap: () {
                          selectedUrl = item.url;
                          Navigator.pop(ctx);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Column(
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                  child: SizedBox(
                                    width: double.infinity,
                                    child: ProductImageWidget(imageUrl: item.url, fit: BoxFit.cover),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(6),
                                child: Text(
                                  item.name,
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ),
  );

  return selectedUrl;
}
