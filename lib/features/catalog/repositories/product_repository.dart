import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/supabase_config.dart';
import '../models/product_model.dart';

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepository();
});

final adminProductsProvider = StateNotifierProvider<AdminProductsNotifier, List<ProductModel>>((ref) {
  return AdminProductsNotifier();
});

class AdminProductsNotifier extends StateNotifier<List<ProductModel>> {
  AdminProductsNotifier() : super(ProductRepository._fallbackProducts);

  void addProduct(ProductModel product) {
    state = [product, ...state];
  }

  void updateProduct(ProductModel product) {
    state = state.map((p) => p.id == product.id ? product : p).toList();
  }

  void deleteProduct(String productId) {
    state = state.where((p) => p.id != productId).toList();
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
  }
}

final categoriesFutureProvider = FutureProvider<List<CategoryModel>>((ref) async {
  return ref.watch(productRepositoryProvider).getCategories();
});

final productsFutureProvider = Provider<AsyncValue<List<ProductModel>>>((ref) {
  final inMemoryProducts = ref.watch(adminProductsProvider);
  return AsyncData(inMemoryProducts);
});

final selectedCategoryProvider = StateProvider<String?>((ref) => null);
final selectedConcernProvider = StateProvider<String?>((ref) => null);
final searchQueryProvider = StateProvider<String>((ref) => '');

final wishlistProvider = StateNotifierProvider<WishlistNotifier, Set<String>>((ref) {
  return WishlistNotifier();
});

class WishlistNotifier extends StateNotifier<Set<String>> {
  WishlistNotifier() : super({'prod-1', 'prod-2', 'prod-3', 'prod-4', 'prod-5', 'prod-6'});

  void toggleWishlist(String productId) {
    if (state.contains(productId)) {
      state = {...state}..remove(productId);
    } else {
      state = {...state, productId};
    }
  }

  void removeFromWishlist(String productId) {
    state = {...state}..remove(productId);
  }

  void clearWishlist() {
    state = {};
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

  // Fallback initial Vaidyam 3 SKUs with local luxury asset images
  static final List<ProductModel> _fallbackProducts = [
    ProductModel(
      id: 'prod-1',
      brandId: 'brand-vaidyam',
      categoryId: 'cat-haircare',
      name: 'Vaidyam Anti-Dandruff Herbal Shampoo',
      slug: 'vaidyam-anti-dandruff-shampoo',
      tagline: 'Clinically proven botanical defense against flakes & scalp itch',
      description:
          'Formulated with Pure Tea Tree Leaf Oil, Neem extract, and Climbazole in a gentle, sulfate-free lather. Restores scalp microbiome balance while nourishing hair roots from within.',
      ingredients:
          'Aqua, Tea Tree Leaf Oil, Azadirachta Indica (Neem) Leaf Extract, Climbazole, Aloe Barbadensis Leaf Juice, Decyl Glucoside, Sodium Cocoyl Isethionate, Glycerin, Hydrolyzed Wheat Protein, D-Panthenol.',
      howToUse:
          'Apply to wet hair and gently massage into scalp for 2 minutes. Rinse thoroughly with water. Use 3 times weekly for best results.',
      freeFromClaims: const [
        'Sulfate Free',
        'Paraben Free',
        'Silicon Free',
        'Mineral Oil Free',
        'Cruelty Free',
        'Artificial Dye Free'
      ],
      isFeatured: true,
      variants: const [
        ProductVariant(
          id: 'var-1-200',
          productId: 'prod-1',
          sku: 'VDY-SHM-200',
          sizeLabel: '200 ml',
          price: 399.00,
          mrp: 499.00,
          stock: 200,
          isDefault: true,
        ),
      ],
      imageUrls: const [
        'assets/images/shampoo.jpg',
      ],
    ),
    ProductModel(
      id: 'prod-2',
      brandId: 'brand-vaidyam',
      categoryId: 'cat-skincare',
      name: 'Vaidyam De-Tan Botanical Handcrafted Soap',
      slug: 'vaidyam-de-tan-soap',
      tagline: 'Enriched with Turmeric, Kashmiri Saffron & Sandalwood for bright, glowing skin',
      description:
          'Handcrafted cold-processed soap bar infused with raw Kashmiri Saffron and Wild Turmeric. Removes stubborn sun tan, pigmentation, and gently exfoliates dead skin cells.',
      ingredients:
          'Cocos Nucifera (Coconut) Oil, Elaeis Guineensis (Palm) Oil, Curcuma Longa (Turmeric) Extract, Crocus Sativus (Saffron) Extract, Santalum Album (Sandalwood) Powder, Kojic Acid Dipalmitate, Vitamin E, Pure Essential Oils.',
      howToUse:
          'Lather between wet palms and apply all over body and face. Leave on for 60 seconds before rinsing off with cool water.',
      freeFromClaims: const [
        'Paraben Free',
        'Cruelty Free',
        '100% Vegetarian',
        'Handcrafted',
        'No Animal Fats',
        'Grade 1 TFM 76%'
      ],
      isFeatured: true,
      variants: const [
        ProductVariant(
          id: 'var-2-125',
          productId: 'prod-2',
          sku: 'VDY-SOP-125',
          sizeLabel: '125 g',
          price: 199.00,
          mrp: 249.00,
          stock: 200,
          isDefault: true,
        ),
      ],
      imageUrls: const [
        'assets/images/soap.jpg',
      ],
    ),
    ProductModel(
      id: 'prod-3',
      brandId: 'brand-vaidyam',
      categoryId: 'cat-skincare',
      name: 'Vaidyam Deep Clean Clarifying Face Wash',
      slug: 'vaidyam-deep-clean-face-wash',
      tagline: 'Salicylic acid (2%) & Green Tea extract for active oil control & acne defense',
      description:
          'A gentle, pH-balanced foaming gel that deep-cleans pores without stripping natural hydration. Combines Green Tea and Niacinamide to calm redness and prevent breakouts.',
      ingredients:
          'Aqua, Camellia Sinensis (Green Tea) Leaf Water, Salicylic Acid (2%), Niacinamide, Cocamidopropyl Betaine, Sodium Lauroyl Sarcosinate, Allantoin, Hyaluronic Acid, Melaleuca Alternifolia (Tea Tree) Extract.',
      howToUse:
          'Pump a small amount onto damp palms. Work into a mild foam and massage over face in circular motions for 30 seconds. Rinse with lukewarm water.',
      freeFromClaims: const [
        'Soap Free',
        'Alcohol Free',
        'Non-Comedogenic',
        'Fragrance Free',
        'Paraben Free',
        'Cruelty Free'
      ],
      isFeatured: true,
      variants: const [
        ProductVariant(
          id: 'var-3-100',
          productId: 'prod-3',
          sku: 'VDY-FCW-100',
          sizeLabel: '100 ml',
          price: 299.00,
          mrp: 375.00,
          stock: 200,
          isDefault: true,
        ),
      ],
      imageUrls: const [
        'assets/images/facewash.jpg',
      ],
    ),
  ];
}
