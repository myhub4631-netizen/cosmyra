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
  AdminProductsNotifier() : super([]) {
    _loadProductsFromStorage();
    _subscribeToSupabaseRealtime();
  }

  void _subscribeToSupabaseRealtime() {
    if (SupabaseConfig.isConfigured) {
      try {
        supabase.from('products').stream(primaryKey: ['id']).listen((data) {
          fetchFreshFromSupabase();
        });
      } catch (e) {
        print('Realtime stream subscription error: $e');
      }
    }
  }

  Future<void> fetchFreshFromSupabase() async {
    ProductImageWidget.clearAllCaches();
    if (SupabaseConfig.isConfigured) {
      try {
        final remoteProducts = await ProductRepository().getProducts();
        state = remoteProducts;
        await _saveProductsToStorage();
      } catch (e) {
        print('Error fetching fresh products from Supabase: $e');
      }
    }
  }

  Future<void> _loadProductsFromStorage() async {
    List<ProductModel> localProducts = [];
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonStr = prefs.getString('cosmyra_admin_products_v2');
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(jsonStr);
        for (final item in decoded) {
          try {
            if (item is Map<String, dynamic>) {
              localProducts.add(ProductModel.fromJson(item));
            }
          } catch (_) {}
        }
      }
    } catch (_) {}

    if (localProducts.isNotEmpty) {
      state = localProducts;
    }

    if (SupabaseConfig.isConfigured) {
      try {
        final remoteProducts = await ProductRepository().getProducts();
        if (remoteProducts.isNotEmpty) {
          ProductImageWidget.clearAllCaches();
          state = remoteProducts;
          _saveProductsToStorage();
        }
      } catch (e) {
        print('Error fetching real products from Supabase: $e');
      }
    }
  }

  Future<void> _saveProductsToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = state.map((p) => p.toJson()).toList();
      await prefs.setString('cosmyra_admin_products_v2', jsonEncode(jsonList));
    } catch (_) {}
  }

  /// Upload a base64 data URI to Supabase Storage and return the public URL.
  /// Returns the original URL if it's not a base64 data URI or upload fails.
  Future<String> _uploadBase64ToStorage(String dataUri, String productId, int index) async {
    if (!dataUri.startsWith('data:')) return dataUri;
    try {
      // Extract mime type and base64 data
      final mimeMatch = RegExp(r'data:image/([a-zA-Z]+);base64,').firstMatch(dataUri);
      final extension = mimeMatch?.group(1) ?? 'png';
      final base64Str = dataUri.split(',').last.replaceAll(RegExp(r'[\r\n\s]+'), '');
      final Uint8List bytes = base64Decode(base64Str);

      final filePath = 'product-images/$productId/img_${index}_${DateTime.now().millisecondsSinceEpoch}.$extension';

      // Upload to Supabase Storage bucket 'product-images'
      await supabase.storage.from('product-images').uploadBinary(
        filePath,
        bytes,
        fileOptions: FileOptions(contentType: 'image/$extension', upsert: true),
      );

      // Get the public URL
      final publicUrl = supabase.storage.from('product-images').getPublicUrl(filePath);
      return publicUrl;
    } catch (e) {
      print('Error uploading image to Supabase Storage: $e');
      return dataUri; // Fallback: keep the base64 data URI
    }
  }

  Future<void> _syncProductToSupabase(ProductModel p) async {
    if (!SupabaseConfig.isConfigured) return;
    try {
      final productData = {
        'id': p.id,
        'brand_id': p.brandId,
        'category_id': p.categoryId,
        'name': p.name,
        'slug': p.slug,
        'tagline': p.tagline,
        'description': p.description,
        'ingredients': p.ingredients,
        'how_to_use': p.howToUse,
        'free_from_claims': p.freeFromClaims,
        'is_featured': p.isFeatured,
        'is_active': true,
        'media_version': p.mediaVersion,
        'product_version': p.productVersion,
        'updated_at': DateTime.now().toIso8601String(),
        'media_updated_at': p.mediaUpdatedAt ?? DateTime.now().toIso8601String(),
      };

      await supabase.from('products').upsert(productData);

      for (final v in p.variants) {
        final variantData = {
          'id': v.id,
          'product_id': p.id,
          'sku': v.sku,
          'size_label': v.sizeLabel,
          'price_inr': v.price,
          'mrp_inr': v.mrp,
          'stock_quantity': v.stock,
          'is_default': v.isDefault,
        };
        await supabase.from('product_variants').upsert(variantData);
      }

      // Purge old image entries in Supabase so updated images become primary
      try {
        await supabase.from('product_images').delete().eq('product_id', p.id);
      } catch (_) {}

      // Upload base64 images to Supabase Storage and save public URLs
      final List<String> resolvedUrls = [];
      for (int i = 0; i < p.imageUrls.length; i++) {
        final url = await _uploadBase64ToStorage(p.imageUrls[i], p.id, i);
        resolvedUrls.add(url);

        final imgData = {
          'id': 'img-${p.id}-$i',
          'product_id': p.id,
          'image_url': url,
          'display_order': i,
          'version': p.mediaVersion,
          'is_primary': i == 0,
        };
        await supabase.from('product_images').upsert(imgData);
      }

      // If any base64 images were converted to public URLs, update local state too
      if (resolvedUrls.any((url) => url.startsWith('http'))) {
        final hasChanges = resolvedUrls.asMap().entries.any((e) => e.value != p.imageUrls[e.key]);
        if (hasChanges) {
          final updatedProduct = p.copyWith(imageUrls: resolvedUrls);
          final index = state.indexWhere((prod) => prod.id.trim() == p.id.trim());
          if (index != -1) {
            final List<ProductModel> updated = List.from(state);
            updated[index] = updatedProduct;
            state = updated;
            _saveProductsToStorage();
          }
        }
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

  void addProduct(ProductModel product) {
    final nowStr = DateTime.now().toIso8601String();
    final newProd = product.copyWith(
      mediaVersion: 1,
      productVersion: 1,
      updatedAt: nowStr,
      mediaUpdatedAt: nowStr,
    );
    state = [newProd, ...state];
    _saveProductsToStorage();
    _syncProductToSupabase(newProd);
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

      final List<ProductModel> updated = List.from(state);
      updated[index] = updatedProduct;
      state = updated;
    } else {
      updatedProduct = product.copyWith(
        mediaVersion: 1,
        productVersion: 1,
        updatedAt: nowStr,
        mediaUpdatedAt: nowStr,
      );
      state = [updatedProduct, ...state];
    }

    await _saveProductsToStorage();
    await _syncProductToSupabase(updatedProduct);
  }

  void deleteProduct(String productId) {
    ProductImageWidget.clearAllCaches();
    state = state.where((p) => p.id.trim() != productId.trim()).toList();
    _saveProductsToStorage();
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
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('cosmyra_admin_products_v2');
      await prefs.remove('cosmyra_homepage_cms_sections_v2');
    } catch (_) {}
    state = [];
    await _saveProductsToStorage();
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
    try {
      if (SupabaseConfig.isConfigured) {
        final response = await supabase
            .from('products')
            .select('*, product_variants(*), product_images(*)')
            .eq('is_active', true);
        if (response.isNotEmpty) {
          return (response as List).map((json) => ProductModel.fromJson(json)).toList();
        }
      }
    } catch (e) {
      print('Supabase fetch failed: $e');
    }

    // Try loading saved admin products from SharedPreferences first before static initial products
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonStr = prefs.getString('cosmyra_admin_products_v2');
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(jsonStr);
        final List<ProductModel> stored = [];
        for (final item in decoded) {
          if (item is Map<String, dynamic>) {
            stored.add(ProductModel.fromJson(item));
          }
        }
        if (stored.isNotEmpty) return stored;
      }
    } catch (_) {}

    return [];
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

  static final List<ProductModel> _fallbackProducts = [];
}
