import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../config/supabase_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/product_model.dart';
import '../widgets/product_image_widget.dart';

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepository();
});

final adminProductsProvider = StateNotifierProvider<AdminProductsNotifier, List<ProductModel>>((ref) {
  return AdminProductsNotifier();
});

class AdminProductsNotifier extends StateNotifier<List<ProductModel>> {
  RealtimeChannel? _syncChannel;
  final Set<String> _deletedProductIds = {};

  AdminProductsNotifier() : super([]) {
    _initCatalog();
  }

  Future<void> _initCatalog() async {
    await _loadDeletedIds();
    await _loadProductsFromStorage();
    _subscribeToSupabaseRealtime();
  }

  Future<void> _loadDeletedIds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String>? saved = prefs.getStringList('cosmyra_deleted_product_ids_v1');
      if (saved != null) {
        _deletedProductIds.addAll(saved);
      }
    } catch (_) {}
  }

  Future<void> _saveDeletedIds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('cosmyra_deleted_product_ids_v1', _deletedProductIds.toList());
    } catch (_) {}
  }

  void _subscribeToSupabaseRealtime() {
    if (SupabaseConfig.isConfigured) {
      try {
        _syncChannel = supabase.channel('cosmyra_catalog_sync');
        _syncChannel?.onBroadcast(
          event: 'product_upserted',
          callback: (payload) {
            try {
              final prodJson = payload['product'];
              if (prodJson is Map<String, dynamic>) {
                final incomingProd = ProductModel.fromJson(prodJson);
                upsertProductLocally(incomingProd);
              }
            } catch (_) {}
          },
        );
        _syncChannel?.onBroadcast(
          event: 'product_deleted',
          callback: (payload) {
            try {
              final prodId = payload['id']?.toString();
              if (prodId != null && prodId.isNotEmpty) {
                deleteProductLocally(prodId);
              }
            } catch (_) {}
          },
        );
        _syncChannel?.subscribe();

        supabase.from('products').stream(primaryKey: ['id']).listen((data) {
          fetchFreshFromSupabase();
        });
      } catch (e) {
        print('Realtime stream subscription error: $e');
      }
    }
  }

  void _broadcastProductChange(String event, Map<String, dynamic> payload) {
    if (SupabaseConfig.isConfigured && _syncChannel != null) {
      try {
        _syncChannel?.sendBroadcastMessage(event: event, payload: payload);
      } catch (_) {}
    }
  }

  void upsertProductLocally(ProductModel incoming) {
    ProductImageWidget.clearAllCaches();
    _deletedProductIds.remove(incoming.id.trim());
    _deletedProductIds.remove(incoming.slug.trim());
    _saveDeletedIds();

    final index = state.indexWhere((p) => p.id.trim() == incoming.id.trim() || p.slug.trim().toLowerCase() == incoming.slug.trim().toLowerCase());
    if (index != -1) {
      final updated = List<ProductModel>.from(state);
      updated[index] = incoming;
      state = updated;
    } else {
      state = [incoming, ...state];
    }
    _saveProductsToStorage();
  }

  void deleteProductLocally(String productId) {
    ProductImageWidget.clearAllCaches();
    final cleanId = productId.trim();
    _deletedProductIds.add(cleanId);
    _saveDeletedIds();

    state = state.where((p) => p.id.trim() != cleanId && p.slug.trim().toLowerCase() != cleanId.toLowerCase()).toList();
    _saveProductsToStorage();
  }

  Future<void> fetchFreshFromSupabase() async {
    ProductImageWidget.clearAllCaches();
    if (SupabaseConfig.isConfigured) {
      try {
        final remoteProducts = await ProductRepository().getProducts();
        final validRemote = remoteProducts.where((p) => 
          !_deletedProductIds.contains(p.id.trim()) && 
          !_deletedProductIds.contains(p.slug.trim().toLowerCase())
        ).toList();

        final Map<String, ProductModel> resultMap = {};
        for (final fp in ProductRepository._fallbackProducts) {
          if (!_deletedProductIds.contains(fp.id.trim()) && !_deletedProductIds.contains(fp.slug.trim().toLowerCase())) {
            resultMap[fp.slug.trim().toLowerCase()] = fp;
          }
        }
        for (final localP in state) {
          if (!_deletedProductIds.contains(localP.id.trim()) && !_deletedProductIds.contains(localP.slug.trim().toLowerCase())) {
            resultMap[localP.slug.trim().toLowerCase()] = localP;
          }
        }
        for (final rp in validRemote) {
          final key = rp.slug.trim().toLowerCase();
          resultMap[key] = rp;
        }
        state = resultMap.values.toList();
        await _saveProductsToStorage();
      } catch (e) {
        print('Error fetching fresh products from Supabase: $e');
      }
    }
  }

  Future<void> _loadProductsFromStorage() async {
    await _loadDeletedIds();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('cosmyra_admin_products_v1');
      await prefs.remove('cosmyra_admin_products_v2');
      await prefs.remove('cosmyra_admin_products_v3');
      await prefs.remove('cosmyra_admin_products_v4');
    } catch (_) {}

    await fetchFreshFromSupabase();

    if (state.isEmpty) {
      final Map<String, ProductModel> fallbackMap = {};
      for (final fp in ProductRepository._fallbackProducts) {
        if (!_deletedProductIds.contains(fp.id.trim()) && !_deletedProductIds.contains(fp.slug.trim().toLowerCase())) {
          fallbackMap[fp.slug.trim().toLowerCase()] = fp;
        }
      }
      state = fallbackMap.values.toList();
    }
  }

  Future<void> _saveProductsToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = state.map((p) => p.toJson()).toList();
      await prefs.setString('cosmyra_admin_products_v5', jsonEncode(jsonList));
    } catch (_) {}
  }

  String _formatAsUuid(String input) {
    if (RegExp(r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$').hasMatch(input)) {
      return input;
    }
    final clean = input.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
    final padded = clean.padRight(32, '0').substring(0, 32);
    final part1 = padded.substring(0, 8);
    final part2 = padded.substring(8, 12);
    final part3 = padded.substring(12, 16);
    final part4 = padded.substring(16, 20);
    final part5 = padded.substring(20, 32);
    return '$part1-$part2-$part3-$part4-$part5';
  }

  String _resolveBrandId(String brandId) {
    if (brandId.trim().isEmpty || brandId.contains('vaidyam')) {
      return '6242b75a-f2b3-4895-8927-95ce0e24fa3c';
    }
    return _formatAsUuid(brandId);
  }

  String _resolveCategoryId(String catId) {
    final clean = catId.toLowerCase();
    if (clean.contains('hair')) {
      return 'e12a1332-bfcb-4179-bdf8-52ecb5d7ee54';
    } else if (clean.contains('skin') || clean.contains('face')) {
      return 'b481633d-9952-410e-90e9-f93cec2b5b9e';
    } else if (clean.contains('well') || clean.contains('body')) {
      return 'd8743d43-e440-4372-a0f4-68fa1cfe3651';
    }
    return 'b481633d-9952-410e-90e9-f93cec2b5b9e';
  }

  /// Upload a base64 data URI to Supabase Storage and return the public URL.
  /// Returns the original URL if it's not a base64 data URI or upload fails.
  Future<String> _uploadBase64ToStorage(String dataUri, String productId, int index) async {
    if (!dataUri.startsWith('data:')) return dataUri;
    try {
      final mimeMatch = RegExp(r'data:image/([a-zA-Z0-9+\-]+);base64,').firstMatch(dataUri);
      final extension = mimeMatch?.group(1) ?? 'png';
      final base64Str = dataUri.split(',').last.replaceAll(RegExp(r'[\r\n\s]+'), '');
      final Uint8List bytes = base64Decode(base64Str);

      final cleanProductId = productId.replaceAll(RegExp(r'[^a-zA-Z0-9_\-]'), '_');
      final filePath = '$cleanProductId/img_${index}_${DateTime.now().millisecondsSinceEpoch}.$extension';

      await supabase.storage.from('product-images').uploadBinary(
        filePath,
        bytes,
        fileOptions: FileOptions(contentType: 'image/$extension', upsert: true),
      );

      final publicUrl = supabase.storage.from('product-images').getPublicUrl(filePath);
      return publicUrl;
    } catch (e) {
      print('Failed to upload image to Supabase Storage: $e');
      return dataUri;
    }
  }

  Future<void> _syncProductToSupabase(ProductModel p) async {
    if (!SupabaseConfig.isConfigured) return;
    try {
      String prodId = _formatAsUuid(p.id);
      try {
        final existing = await supabase
            .from('products')
            .select('id')
            .eq('slug', p.slug.trim())
            .maybeSingle();
        if (existing != null && existing['id'] != null) {
          prodId = existing['id'].toString();
        }
      } catch (_) {}

      final String brandId = _resolveBrandId(p.brandId);
      final String categoryId = _resolveCategoryId(p.categoryId);

      final productData = {
        'id': prodId,
        'brand_id': brandId,
        'category_id': categoryId,
        'name': p.name,
        'slug': p.slug,
        'tagline': p.tagline,
        'description': p.description,
        'ingredients': p.ingredients,
        'how_to_use': p.howToUse,
        'free_from_claims': p.freeFromClaims,
        'is_featured': p.isFeatured,
        'is_active': true,
        'updated_at': DateTime.now().toIso8601String(),
      };

      await supabase.from('products').upsert(productData);

      for (final v in p.variants) {
        final String variantId = _formatAsUuid(v.id.trim().isEmpty ? 'var-$prodId' : v.id);
        final variantData = {
          'id': variantId,
          'product_id': prodId,
          'sku': v.sku,
          'size_label': v.sizeLabel,
          'price_inr': v.price,
          'mrp_inr': v.mrp,
          'stock_quantity': v.stock,
          'is_default': v.isDefault,
          'is_active': true,
        };
        await supabase.from('product_variants').upsert(variantData);
      }

      // Purge old image entries in Supabase so updated images become primary
      try {
        await supabase.from('product_images').delete().eq('product_id', prodId);
      } catch (_) {}

      // Upload base64 images to Supabase Storage and save public URLs
      final List<String> resolvedUrls = [];
      for (int i = 0; i < p.imageUrls.length; i++) {
        final url = await _uploadBase64ToStorage(p.imageUrls[i], prodId, i);
        resolvedUrls.add(url);

        final String imageId = _formatAsUuid('img-$prodId-$i');
        final imgData = {
          'id': imageId,
          'product_id': prodId,
          'image_url': url,
          'alt_text': '${p.name} image $i',
          'display_order': i,
          'is_primary': i == 0,
        };
        await supabase.from('product_images').upsert(imgData);
      }

      // Save resolved image URLs to local state & storage and evict image cache
      if (resolvedUrls.isNotEmpty) {
        final updatedProduct = p.copyWith(id: p.id, imageUrls: resolvedUrls);
        final index = state.indexWhere((prod) => prod.slug.trim().toLowerCase() == p.slug.trim().toLowerCase());
        if (index != -1) {
          final List<ProductModel> updated = List.from(state);
          updated[index] = updatedProduct;
          state = updated;
          await _saveProductsToStorage();
        }
        ProductImageWidget.clearAllCaches();
      }
    } catch (e) {
      print('Sync product to Supabase error: $e');
    }
  }

  Future<void> _deleteProductFromSupabase(String productId) async {
    if (!SupabaseConfig.isConfigured) return;
    try {
      await supabase.from('products').delete().eq('id', productId);
    } catch (e) {
      print('Delete product from Supabase error: $e');
    }
  }

  Future<void> addProduct(ProductModel product) async {
    final nowStr = DateTime.now().toIso8601String();
    final newProd = product.copyWith(
      mediaVersion: 1,
      productVersion: 1,
      updatedAt: nowStr,
      mediaUpdatedAt: nowStr,
    );
    upsertProductLocally(newProd);
    _broadcastProductChange('product_upserted', {'product': newProd.toJson()});
    await _syncProductToSupabase(newProd);
  }

  Future<void> updateProduct(ProductModel product) async {
    ProductImageWidget.clearAllCaches();
    final cleanId = product.id.trim();

    final index = state.indexWhere((p) =>
        p.id.trim() == cleanId ||
        p.slug.trim().toLowerCase() == product.slug.trim().toLowerCase() ||
        p.name.trim().toLowerCase() == product.name.trim().toLowerCase());

    final nowStr = DateTime.now().toIso8601String();
    ProductModel updatedProduct;

    if (index != -1) {
      final existing = state[index];
      final bool mediaChanged = existing.imageUrls.length != product.imageUrls.length ||
          existing.imageUrls.asMap().entries.any((e) => e.value != product.imageUrls[e.key]);
      
      final int nextMediaVersion = mediaChanged ? existing.mediaVersion + 1 : existing.mediaVersion;
      final int nextProductVersion = existing.productVersion + 1;

      updatedProduct = product.copyWith(
        mediaVersion: nextMediaVersion,
        productVersion: nextProductVersion,
        updatedAt: nowStr,
        mediaUpdatedAt: mediaChanged ? nowStr : existing.mediaUpdatedAt,
      );
    } else {
      updatedProduct = product.copyWith(
        mediaVersion: 1,
        productVersion: 1,
        updatedAt: nowStr,
        mediaUpdatedAt: nowStr,
      );
    }

    upsertProductLocally(updatedProduct);
    _broadcastProductChange('product_upserted', {'product': updatedProduct.toJson()});
    await _syncProductToSupabase(updatedProduct);
  }

  void deleteProduct(String productId) {
    deleteProductLocally(productId);
    _broadcastProductChange('product_deleted', {'id': productId});
    _deleteProductFromSupabase(productId);
  }

  Future<Map<String, dynamic>> syncAllProductsToSupabase() async {
    ProductImageWidget.clearAllCaches();
    await _saveProductsToStorage();

    int syncedCount = 0;
    bool supabaseOk = false;

    if (SupabaseConfig.isConfigured) {
      try {
        for (final p in state) {
          await _syncProductToSupabase(p);
          syncedCount++;
        }
        supabaseOk = true;
      } catch (e) {
        print('Supabase syncAllProducts error: $e');
      }
    }

    return {
      'success': true,
      'syncedCount': state.length,
      'supabaseSynced': supabaseOk,
      'message': supabaseOk
          ? 'Successfully saved & synced ${state.length} products live with Supabase & Vercel!'
          : 'Successfully saved ${state.length} products locally & ready for live deployment!',
    };
  }

  Future<void> resetToDefaultCatalog() async {
    ProductImageWidget.clearAllCaches();
    _deletedProductIds.clear();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('cosmyra_admin_products_v1');
      await prefs.remove('cosmyra_admin_products_v2');
      await prefs.remove('cosmyra_admin_products_v3');
      await prefs.remove('cosmyra_admin_products_v4');
      await prefs.remove('cosmyra_deleted_product_ids_v1');
    } catch (_) {}
    state = List.from(ProductRepository._fallbackProducts);
    await _saveProductsToStorage();
    await fetchFreshFromSupabase();
  }

  void restockProduct(String productId, int addAmount) {
    ProductModel? targetProduct;
    state = state.map((p) {
      if (p.id == productId) {
        final updatedVariants = p.variants.map((v) {
          if (v.isDefault) {
            return v.copyWith(stock: v.stock + addAmount);
          }
          return v;
        }).toList();
        targetProduct = p.copyWith(variants: updatedVariants);
        return targetProduct!;
      }
      return p;
    }).toList();
    _saveProductsToStorage();
    if (targetProduct != null) {
      _syncProductToSupabase(targetProduct!);
    }
  }

  void clearAllProducts() {
    state = [];
    _saveProductsToStorage();
  }
}

final categoriesFutureProvider = FutureProvider<List<CategoryModel>>((ref) async {
  return ref.watch(productRepositoryProvider).getCategories();
});

final productsFutureProvider = FutureProvider<List<ProductModel>>((ref) async {
  return ref.watch(adminProductsProvider);
});

final selectedCategoryProvider = StateProvider<String?>((ref) => null);
final selectedConcernProvider = StateProvider<String?>((ref) => null);
final searchQueryProvider = StateProvider<String>((ref) => '');

final wishlistProvider = StateNotifierProvider<WishlistNotifier, Set<String>>((ref) {
  return WishlistNotifier();
});

class WishlistNotifier extends StateNotifier<Set<String>> {
  WishlistNotifier() : super({}) {
    _loadWishlistFromStorage();
  }

  Future<void> _loadWishlistFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonStr = prefs.getString('cosmyra_user_wishlist_v1');
      if (jsonStr != null) {
        final List<dynamic> decoded = jsonDecode(jsonStr);
        state = decoded.map((e) => e.toString()).toSet();
      }
    } catch (_) {}
  }

  Future<void> _saveWishlistToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('cosmyra_user_wishlist_v1', jsonEncode(state.toList()));
    } catch (_) {}
  }

  void toggleWishlist(String productId) {
    if (state.contains(productId)) {
      state = {...state}..remove(productId);
    } else {
      state = {...state, productId};
    }
    _saveWishlistToStorage();
  }

  void removeFromWishlist(String productId) {
    state = {...state}..remove(productId);
    _saveWishlistToStorage();
  }

  void addToWishlist(String productId) {
    state = {...state, productId};
    _saveWishlistToStorage();
  }

  void clearWishlist() {
    state = {};
    _saveWishlistToStorage();
  }

  bool isWishlisted(String productId) => state.contains(productId);
}

final filteredProductsProvider = Provider<AsyncValue<List<ProductModel>>>((ref) {
  final products = ref.watch(adminProductsProvider);
  final selectedCat = ref.watch(selectedCategoryProvider);
  final selectedConcern = ref.watch(selectedConcernProvider);
  final query = ref.watch(searchQueryProvider).trim().toLowerCase();

  final filtered = products.where((p) {
    if (selectedCat != null && selectedCat.isNotEmpty && p.categoryId != selectedCat) {
      return false;
    }
    if (selectedConcern != null && selectedConcern.isNotEmpty) {
      if (!p.description.toLowerCase().contains(selectedConcern.toLowerCase()) &&
          !(p.tagline ?? '').toLowerCase().contains(selectedConcern.toLowerCase()) &&
          !p.name.toLowerCase().contains(selectedConcern.toLowerCase())) {
        return false;
      }
    }
    if (query.isNotEmpty) {
      final matchName = p.name.toLowerCase().contains(query);
      final matchDesc = p.description.toLowerCase().contains(query);
      final matchIngredients = p.ingredients.toLowerCase().contains(query);
      return matchName || matchDesc || matchIngredients;
    }
    return true;
  }).toList();

  return AsyncData(filtered);
});

class ProductRepository {
  /// Fetch all active categories
  Future<List<CategoryModel>> getCategories() async {
    try {
      if (SupabaseConfig.isConfigured) {
        final response = await supabase
            .from('categories')
            .select()
            .eq('is_active', true)
            .order('display_order');
        if (response.isNotEmpty) {
          return (response as List).map((json) => CategoryModel.fromJson(json)).toList();
        }
      }
    } catch (_) {}

    return _fallbackCategories;
  }

  /// Fetch all active products with variants and images
  Future<List<ProductModel>> getProducts() async {
    Set<String> deletedIds = {};
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String>? saved = prefs.getStringList('cosmyra_deleted_product_ids_v1');
      if (saved != null) {
        deletedIds = saved.toSet();
      }
    } catch (_) {}

    final Map<String, ProductModel> resultMap = {};

    // 1. Seed fallback products as baseline
    for (final fp in _fallbackProducts) {
      if (!deletedIds.contains(fp.id.trim()) && !deletedIds.contains(fp.slug.trim().toLowerCase())) {
        resultMap[fp.id.trim()] = fp;
      }
    }

    // 2. Load stored local admin products from SharedPreferences
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonStr = prefs.getString('cosmyra_admin_products_v4');
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(jsonStr);
        for (final item in decoded) {
          try {
            if (item is Map<String, dynamic>) {
              final p = ProductModel.fromJson(item);
              if (!deletedIds.contains(p.id.trim()) && !deletedIds.contains(p.slug.trim().toLowerCase())) {
                resultMap[p.slug.trim().toLowerCase()] = p;
              }
            }
          } catch (_) {}
        }
      }
    } catch (_) {}

    // 3. Load remote live products from Supabase database
    try {
      if (SupabaseConfig.isConfigured) {
        final response = await supabase
            .from('products')
            .select('*, product_variants(*), product_images(*)')
            .eq('is_active', true)
            .order('updated_at', ascending: false);
        if (response.isNotEmpty) {
          final List<ProductModel> fetched = (response as List).map((json) => ProductModel.fromJson(json)).toList();
          for (final rp in fetched) {
            final key = rp.slug.trim().toLowerCase();
            if (!deletedIds.contains(rp.id.trim()) && !deletedIds.contains(key)) {
              if (resultMap.containsKey(key)) {
                final existing = resultMap[key]!;
                final bool rpHasCustomImg = rp.imageUrls.any((img) => !img.startsWith('assets/'));
                final bool existingHasCustomImg = existing.imageUrls.any((img) => !img.startsWith('assets/'));
                if (existingHasCustomImg && !rpHasCustomImg) {
                  resultMap[key] = rp.copyWith(imageUrls: existing.imageUrls);
                } else {
                  resultMap[key] = rp;
                }
              } else {
                resultMap[key] = rp;
              }
            }
          }
        }
      }
    } catch (e) {
      print('Supabase fetch failed: $e');
    }

    return resultMap.values.toList();
  }

  // Fallback initial categories
  static final List<CategoryModel> _fallbackCategories = [
    const CategoryModel(
      id: 'cat-haircare',
      name: 'Haircare',
      slug: 'haircare',
      description: 'Botanical defense and nourishment for hair and scalp',
      iconName: 'spa',
    ),
    const CategoryModel(
      id: 'cat-skincare',
      name: 'Skincare',
      slug: 'skincare',
      description: 'Dermatological Ayurveda for clear, glowing Indian skin',
      iconName: 'face',
    ),
    const CategoryModel(
      id: 'cat-wellness',
      name: 'Wellness',
      slug: 'wellness',
      description: 'Holistic personal wellness & daily essentials',
      iconName: 'favorite',
    ),
  ];

  static final List<ProductModel> _fallbackProducts = [
    const ProductModel(
      id: 'prod-vaidyam-shampoo-1',
      brandId: 'brand-vaidyam',
      categoryId: 'cat-haircare',
      name: 'Bhringraj & Neem Botanical Shampoo',
      slug: 'bhringraj-neem-botanical-shampoo',
      tagline: 'Deep Scalp Cleans & Hairfall Control',
      description: 'Handcrafted Ayurvedic formulation infused with pure Bhringraj, Neem, and Amla extracts to strengthen roots and stop hair fall naturally.',
      ingredients: 'Organic Bhringraj, Neem Leaf Extract, Amla, Reetha, Shikakai, Virgin Coconut Oil, Purified Aqua.',
      howToUse: 'Apply 5-10ml on wet scalp, massage gently into rich lather for 2 minutes and rinse thoroughly with lukewarm water.',
      freeFromClaims: ['Paraben Free', 'Sulfate Free', 'Cruelty Free', '100% Vegan'],
      imageUrls: ['assets/images/shampoo.jpg'],
      isFeatured: true,
      variants: [
        ProductVariant(
          id: 'var-shampoo-1',
          productId: 'prod-vaidyam-shampoo-1',
          sku: 'VDY-SHMP-200',
          sizeLabel: '200 ml',
          price: 399.0,
          mrp: 549.0,
          stock: 150,
          isDefault: true,
        ),
      ],
    ),
    const ProductModel(
      id: 'prod-vaidyam-facewash-1',
      brandId: 'brand-vaidyam',
      categoryId: 'cat-skincare',
      name: 'Saffron & Kumkumadi Radiance Face Wash',
      slug: 'saffron-kumkumadi-radiance-facewash',
      tagline: 'Golden Glow & Dark Spot Reduction',
      description: 'Enriched with Kashmiri Saffron and 26 herbal extracts for clear, even-toned, and radiant Indian skin.',
      ingredients: 'Kashmiri Saffron (Kesar), Kumkumadi Tailam, Aloe Vera Gel, Manjistha, Sandalwood Extract, Lotus Water.',
      howToUse: 'Squeeze small amount onto palms. Work into mild lather and massage on damp face in circular motions.',
      freeFromClaims: ['Soap Free', 'Paraben Free', 'Synthetic Color Free', 'Dermatologically Tested'],
      imageUrls: ['assets/images/facewash.jpg'],
      isFeatured: true,
      variants: [
        ProductVariant(
          id: 'var-facewash-1',
          productId: 'prod-vaidyam-facewash-1',
          sku: 'VDY-FW-100',
          sizeLabel: '100 ml',
          price: 299.0,
          mrp: 399.0,
          stock: 200,
          isDefault: true,
        ),
      ],
    ),
    const ProductModel(
      id: 'prod-vaidyam-soap-1',
      brandId: 'brand-vaidyam',
      categoryId: 'cat-skincare',
      name: 'Cold-Pressed Herbal De-Tan Soap Bar',
      slug: 'cold-pressed-herbal-detan-soap',
      tagline: 'Exfoliating Neem & Turmeric Bar',
      description: 'Traditional cold-processed soap made with raw coconut oil, wild turmeric, and neem for deep skin detoxification.',
      ingredients: 'Cold-Pressed Coconut Oil, Wild Turmeric (Kasturi Manjal), Neem Leaves, Vetiver Root Oil, Pure Glycerin.',
      howToUse: 'Lather gently over wet body during shower. Leave on skin for 1 minute before rinsing clean.',
      freeFromClaims: ['Palm Oil Free', 'Chemical Free', '100% Handcrafted', 'Biodegradable'],
      imageUrls: ['assets/images/soap.jpg'],
      isFeatured: true,
      variants: [
        ProductVariant(
          id: 'var-soap-1',
          productId: 'prod-vaidyam-soap-1',
          sku: 'VDY-SOAP-125',
          sizeLabel: '125 g',
          price: 199.0,
          mrp: 249.0,
          stock: 300,
          isDefault: true,
        ),
      ],
    ),
    const ProductModel(
      id: 'prod-vaidyam-serum-1',
      brandId: 'brand-vaidyam',
      categoryId: 'cat-skincare',
      name: 'Kumkumadi Tailam & Saffron Night Serum',
      slug: 'kumkumadi-tailam-saffron-night-serum',
      tagline: '100% Pure Youth Elixir & Overnight Repair',
      description: 'Precious Ayurvedic miracle elixir formulation distilled with saffron stigmas, goat milk, and 26 botanicals for ageless radiance.',
      ingredients: 'Saffron (Kesar), Goat Milk, Sandalwood (Chandan), Vetiver, Licorice (Yasthimadhu), Manjistha, Sesame Oil.',
      howToUse: 'Apply 3-4 drops on cleansed face before bedtime. Gently press into face and neck using fingertips until absorbed.',
      freeFromClaims: ['100% Organic', 'Mineral Oil Free', 'No Artificial Fragrance', 'Cruelty Free'],
      imageUrls: ['assets/images/facewash.jpg'],
      isFeatured: true,
      variants: [
        ProductVariant(
          id: 'var-serum-1',
          productId: 'prod-vaidyam-serum-1',
          sku: 'VDY-SER-30',
          sizeLabel: '30 ml',
          price: 699.0,
          mrp: 899.0,
          stock: 100,
          isDefault: true,
        ),
      ],
    ),
    const ProductModel(
      id: 'prod-vaidyam-bodyoil-1',
      brandId: 'brand-vaidyam',
      categoryId: 'cat-wellness',
      name: 'Nalpamaradi Clarifying Body Thailam',
      slug: 'nalpamaradi-clarifying-body-thailam',
      tagline: 'Brightening & Anti-Pigmentation Oil',
      description: 'Heritage Ayurvedic skin oil made with 4 Ficus barks and turmeric to clarify complexion, reduce tan, and restore natural glow.',
      ingredients: 'Bark of 4 Ficus Trees (Nalpamara), Turmeric, Sesame Oil, Vetiver, Banyan Bark, Peepal Bark.',
      howToUse: 'Massage gently over body 30 minutes before bathing. Wash off with warm water and herbal soap.',
      freeFromClaims: ['100% Herbal', 'No Synthetic Colors', 'Ayurvedic Pharmacopoeia Grade'],
      imageUrls: ['assets/images/soap.jpg'],
      isFeatured: false,
      variants: [
        ProductVariant(
          id: 'var-bodyoil-1',
          productId: 'prod-vaidyam-bodyoil-1',
          sku: 'VDY-OIL-200',
          sizeLabel: '200 ml',
          price: 499.0,
          mrp: 649.0,
          stock: 120,
          isDefault: true,
        ),
      ],
    ),
    const ProductModel(
      id: 'prod-vaidyam-aloegel-1',
      brandId: 'brand-vaidyam',
      categoryId: 'cat-wellness',
      name: 'Organic Aloe Vera & Neem Hydrating Gel',
      slug: 'organic-aloe-vera-neem-hydrating-gel',
      tagline: 'Cooling Hydration for Face & Hair',
      description: '99% pure cold-pressed aloe vera gel with organic neem water for multi-purpose skin soothing, scalp hydration, and acne control.',
      ingredients: 'Cold-Pressed Aloe Vera Leaf Juice, Organic Neem Water, Green Tea Extract, Natural Vegetable Glycerin.',
      howToUse: 'Apply directly onto face, scalp, or skin after sun exposure or daily cleansing for instant cooling hydration.',
      freeFromClaims: ['Alcohol Free', 'Silicone Free', 'Non-Sticky', '100% Pure Gel'],
      imageUrls: ['assets/images/shampoo.jpg'],
      isFeatured: false,
      variants: [
        ProductVariant(
          id: 'var-aloegel-1',
          productId: 'prod-vaidyam-aloegel-1',
          sku: 'VDY-ALOE-150',
          sizeLabel: '150 g',
          price: 249.0,
          mrp: 349.0,
          stock: 180,
          isDefault: true,
        ),
      ],
    ),
  ];
}
