import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/admin/controllers/mobile_app_settings_controller.dart';
import '../../features/catalog/models/product_model.dart';
import '../../features/catalog/repositories/product_repository.dart';
import '../../features/catalog/widgets/product_image_widget.dart';

class VaidyamMobileAjaxSearchBar extends ConsumerStatefulWidget {
  const VaidyamMobileAjaxSearchBar({super.key});

  @override
  ConsumerState<VaidyamMobileAjaxSearchBar> createState() => _VaidyamMobileAjaxSearchBarState();
}

class _VaidyamMobileAjaxSearchBarState extends ConsumerState<VaidyamMobileAjaxSearchBar> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _showOverlay = false;
  List<ProductModel> _searchResults = [];

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus && _controller.text.isEmpty) {
        setState(() {
          _showOverlay = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onQueryChanged(String query, List<ProductModel> allProducts) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) {
      setState(() {
        _searchResults = [];
        _showOverlay = false;
      });
      return;
    }

    final matches = allProducts.where((p) {
      final nameMatch = p.name.toLowerCase().contains(q);
      final taglineMatch = (p.tagline ?? '').toLowerCase().contains(q);
      final descMatch = p.description.toLowerCase().contains(q);
      final catMatch = p.categoryId.toLowerCase().contains(q);
      final ingredientsMatch = p.ingredients.toLowerCase().contains(q);
      return nameMatch || taglineMatch || descMatch || catMatch || ingredientsMatch;
    }).toList();

    setState(() {
      _searchResults = matches;
      _showOverlay = true;
    });
  }

  void _clearSearch() {
    _controller.clear();
    setState(() {
      _searchResults = [];
      _showOverlay = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final mobileSettings = ref.watch(mobileAppSettingsProvider);
    final allProducts = ref.watch(adminProductsProvider);
    final placeholder = mobileSettings.searchPlaceholder.isNotEmpty
        ? mobileSettings.searchPlaceholder
        : 'Search in Ayurveda, Haircare, Skincare...';

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Sleek Search Input Field Container
        Container(
          height: 46,
          margin: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: _focusNode.hasFocus ? const Color(0xFF6366F1) : const Color(0xFFE2E8F0),
              width: _focusNode.hasFocus ? 1.5 : 1.0,
            ),
            boxShadow: _focusNode.hasFocus
                ? [
                    BoxShadow(
                      color: const Color(0xFF6366F1).withOpacity(0.12),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Row(
            children: [
              const SizedBox(width: 14),
              const Icon(Icons.search_rounded, color: Color(0xFF6366F1), size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A), fontWeight: FontWeight.w500),
                  onChanged: (query) => _onQueryChanged(query, allProducts),
                  onSubmitted: (query) {
                    if (query.trim().isNotEmpty) {
                      context.push('/shop');
                    }
                  },
                  decoration: InputDecoration(
                    hintText: placeholder,
                    hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              if (_controller.text.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B), size: 18),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  onPressed: _clearSearch,
                ),
              IconButton(
                icon: const Icon(Icons.mic_none_rounded, color: Color(0xFF4338CA), size: 20),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('🎙️ Voice Search activated! Listening for botanical query...'),
                      backgroundColor: Color(0xFF4338CA),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
              const SizedBox(width: 4),
            ],
          ),
        ),

        // 2. Dynamic AJAX Floating Search Overlay
        if (_showOverlay)
          Container(
            margin: const EdgeInsets.only(left: 14, right: 14, top: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 16,
                  spreadRadius: 2,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Overlay Header
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                    border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.flash_on_rounded, size: 16, color: Color(0xFF10B981)),
                          const SizedBox(width: 6),
                          Text(
                            _searchResults.isEmpty
                                ? 'No Products Found'
                                : 'Live Results (${_searchResults.length})',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: _clearSearch,
                        child: const Text(
                          'Close ✕',
                          style: TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),

                // Overlay Product Results List
                if (_searchResults.isNotEmpty)
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 280),
                    child: ListView.separated(
                      shrinkWrap: true,
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      itemCount: _searchResults.length,
                      separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFF1F5F9)),
                      itemBuilder: (context, index) {
                        final product = _searchResults[index];
                        final imgUrl = product.imageUrls.isNotEmpty ? product.imageUrls.first : '';
                        final price = product.defaultVariant.price.toInt();
                        final mrp = product.defaultVariant.mrp.toInt();
                        final discount = product.defaultVariant.discountPercent.toInt();

                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                          dense: true,
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              width: 44,
                              height: 44,
                              color: const Color(0xFFF1F5F9),
                              child: ProductImageWidget(
                                imageUrl: imgUrl,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          title: Text(
                            product.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                          ),
                          subtitle: Row(
                            children: [
                              Text(
                                '₹$price',
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF4338CA)),
                              ),
                              if (mrp > price) ...[
                                const SizedBox(width: 6),
                                Text(
                                  '₹$mrp',
                                  style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8), decoration: TextDecoration.lineThrough),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                  decoration: BoxDecoration(color: const Color(0xFFECFDF5), borderRadius: BorderRadius.circular(4)),
                                  child: Text(
                                    '$discount% OFF',
                                    style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF10B981)),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Color(0xFF94A3B8)),
                          onTap: () {
                            _clearSearch();
                            context.push('/product/${product.id}', extra: product);
                          },
                        );
                      },
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.search_off_rounded, size: 32, color: Color(0xFF94A3B8)),
                          const SizedBox(height: 8),
                          Text(
                            'No products matching "${_controller.text}"',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Try searching for "Shampoo", "Hair Oil", "Serum", or "Soap"',
                            style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}
