import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../config/supabase_config.dart';
import '../models/product_model.dart';

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepository();
});

final adminProductsProvider = StateNotifierProvider<AdminProductsNotifier, List<ProductModel>>((ref) {
  return AdminProductsNotifier();
});

class AdminProductsNotifier extends StateNotifier<List<ProductModel>> {
  AdminProductsNotifier() : super([]) {
    _loadProductsFromStorage();
  }

  static final List<ProductModel> initialCatalogProducts = [
    ProductModel(
      id: 'prod-vaidyam-shampoo-1',
      brandId: 'brand-vaidyam',
      categoryId: 'cat-haircare',
      name: 'Vaidyam Anti-Dandruff Herbal Shampoo',
      slug: 'anti-dandruff-herbal-shampoo',
      tagline: 'Deep scalp cleansing with Tea Tree, Neem & Bhringraj',
      description: 'Clears flakes, controls excess scalp sebum, and restores hair vitality with 100% organic botanicals.',
      ingredients: 'Tea Tree Extract, Bhringraj, Neem, Aloe Vera, Purified Aqua.',
      howToUse: 'Apply on wet hair, lather gently for 2 minutes, and rinse thoroughly.',
      freeFromClaims: const ['100% Natural', 'Paraben Free', 'Sulfate Free'],
      isFeatured: true,
      variants: const [
        ProductVariant(
          id: 'v-shm-200ml',
          productId: 'prod-vaidyam-shampoo-1',
          sku: 'VDY-SHM-200',
          sizeLabel: '200 ml Bottle',
          price: 399,
          mrp: 499,
          stock: 200,
          isDefault: true,
        ),
      ],
      imageUrls: const ['assets/images/shampoo.jpg'],
    ),
    ProductModel(
      id: 'prod-vaidyam-soap-2',
      brandId: 'brand-vaidyam',
      categoryId: 'cat-skincare',
      name: 'Vaidyam De-Tan Botanical Soap',
      slug: 'de-tan-botanical-soap',
      tagline: 'Pure Turmeric & Sandalwood complexion brightening bar',
      description: 'Removes stubborn sun tan, deeply hydrates, and leaves skin smooth and glowing.',
      ingredients: 'Wild Turmeric, Red Sandalwood, Coconut Oil, Essential Fragrance Oils.',
      howToUse: 'Lather gently over wet body during bath and rinse with warm water.',
      freeFromClaims: const ['Handcrafted', 'Cruelty Free', 'Chemical Free'],
      isFeatured: true,
      variants: const [
        ProductVariant(
          id: 'v-sop-125g',
          productId: 'prod-vaidyam-soap-2',
          sku: 'VDY-SOP-125',
          sizeLabel: '125 g Bar',
          price: 199,
          mrp: 249,
          stock: 125,
          isDefault: true,
        ),
      ],
      imageUrls: const ['assets/images/soap.jpg'],
    ),
    ProductModel(
      id: 'prod-vaidyam-facewash-3',
      brandId: 'brand-vaidyam',
      categoryId: 'cat-skincare',
      name: 'Vaidyam Deep Clean Face Wash',
      slug: 'deep-clean-face-wash',
      tagline: 'Gentle clarifying wash with Neem & Chandan',
      description: 'Removes pore impurities, prevents acne breakouts, and keeps skin soft and hydrated.',
      ingredients: 'Neem Leaf Extract, Chandan (Sandalwood), Tulsi, Aqua.',
      howToUse: 'Squeeze small amount on wet palm, massage over face, and wash off.',
      freeFromClaims: const ['Paraben Free', 'Dermatologically Tested'],
      isFeatured: true,
      variants: const [
        ProductVariant(
          id: 'v-fcw-100ml',
          productId: 'prod-vaidyam-facewash-3',
          sku: 'VDY-FCW-100',
          sizeLabel: '100 ml Tube',
          price: 299,
          mrp: 375,
          stock: 98,
          isDefault: true,
        ),
      ],
      imageUrls: const ['assets/images/facewash.jpg'],
    ),
    ProductModel(
      id: 'prod-vaidyam-hairoil-4',
      brandId: 'brand-vaidyam',
      categoryId: 'cat-haircare',
      name: 'Vaidyam Herbal Hair Oil',
      slug: 'herbal-hair-oil',
      tagline: 'Roots invigorating hair growth & scalp tonic',
      description: 'Nourishes dry roots, prevents premature graying, and promotes thick hair growth.',
      ingredients: 'Bhringraj, Amla, Brahmi, Sesame Seed Oil.',
      howToUse: 'Warm oil gently and massage into scalp 1 hour before hair wash.',
      freeFromClaims: const ['100% Herbal', 'No Artificial Color'],
      isFeatured: false,
      variants: const [
        ProductVariant(
          id: 'v-ho-100ml',
          productId: 'prod-vaidyam-hairoil-4',
          sku: 'VDY-HO-100',
          sizeLabel: '100 ml Bottle',
          price: 349,
          mrp: 449,
          stock: 0,
          isDefault: true,
        ),
      ],
      imageUrls: const ['assets/images/shampoo.jpg'],
    ),
    ProductModel(
      id: 'prod-vaidyam-serum-5',
      brandId: 'brand-vaidyam',
      categoryId: 'cat-skincare',
      name: 'Vaidyam Vitamin C Serum',
      slug: 'vitamin-c-serum',
      tagline: 'Brightening boost with Amla & Hyaluronic Acid',
      description: 'Fades dark spots, boosts collagen production, and gives radiant skin tone.',
      ingredients: 'Phyllanthus Emblica (Amla Vitamin C), Hyaluronic Acid, Ferulic Acid.',
      howToUse: 'Apply 3-5 drops in morning skincare routine before moisturizer.',
      freeFromClaims: const ['Cruelty Free', 'Dermatologist Formulated'],
      isFeatured: true,
      variants: const [
        ProductVariant(
          id: 'v-ser-30ml',
          productId: 'prod-vaidyam-serum-5',
          sku: 'VDY-SER-30',
          sizeLabel: '30 ml Dropper',
          price: 599,
          mrp: 749,
          stock: 30,
          isDefault: true,
        ),
      ],
      imageUrls: const ['assets/images/facewash.jpg'],
    ),
  ];

  Future<void> _loadProductsFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonStr = prefs.getString('cosmyra_admin_products_v2');
      if (jsonStr != null) {
        final List<dynamic> decoded = jsonDecode(jsonStr);
        final List<ProductModel> loaded = [];
        for (final item in decoded) {
          try {
            if (item is Map<String, dynamic>) {
              loaded.add(ProductModel.fromJson(item));
            }
          } catch (_) {}
        }
        state = loaded;
        return;
      }
    } catch (_) {}

    state = List.from(initialCatalogProducts);
    _saveProductsToStorage();
  }

  Future<void> _saveProductsToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = state.map((p) => p.toJson()).toList();
      await prefs.setString('cosmyra_admin_products_v2', jsonEncode(jsonList));
    } catch (_) {}
  }

  void addProduct(ProductModel product) {
    state = [product, ...state];
    _saveProductsToStorage();
  }

  void updateProduct(ProductModel product) {
    state = [
      for (final p in state)
        if (p.id == product.id) product else p,
    ];
    _saveProductsToStorage();
  }

  void deleteProduct(String productId) {
    state = state.where((p) => p.id.trim() != productId.trim()).toList();
    _saveProductsToStorage();
  }

  Future<void> resetToDefaultCatalog() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('cosmyra_admin_products_v2');
    } catch (_) {}
    state = List.from(initialCatalogProducts);
    _saveProductsToStorage();
  }

  void restockProduct(String productId, int addAmount) {
    state = state.map((p) {
      if (p.id == productId) {
        final updatedVariants = p.variants.map((v) {
          if (v.isDefault) {
            return v.copyWith(stock: v.stock + addAmount);
          }
          return v;
        }).toList();
        return p.copyWith(variants: updatedVariants);
      }
      return p;
    }).toList();
    _saveProductsToStorage();
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
    } catch (_) {}

    return _fallbackProducts;
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
