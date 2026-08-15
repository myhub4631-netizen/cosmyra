/// Product Variant Model
class ProductVariant {
  final String id;
  final String productId;
  final String sku;
  final String sizeLabel;
  final double price;
  final double mrp;
  final int stock;
  final bool isDefault;

  const ProductVariant({
    required this.id,
    required this.productId,
    required this.sku,
    required this.sizeLabel,
    required this.price,
    required this.mrp,
    required this.stock,
    required this.isDefault,
  });

  ProductVariant copyWith({
    String? id,
    String? productId,
    String? sku,
    String? sizeLabel,
    double? price,
    double? mrp,
    int? stock,
    bool? isDefault,
  }) {
    return ProductVariant(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      sku: sku ?? this.sku,
      sizeLabel: sizeLabel ?? this.sizeLabel,
      price: price ?? this.price,
      mrp: mrp ?? this.mrp,
      stock: stock ?? this.stock,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  double get discountPercent => mrp > price ? (((mrp - price) / mrp) * 100).roundToDouble() : 0.0;

  factory ProductVariant.fromJson(Map<String, dynamic> json) {
    return ProductVariant(
      id: json['id'] ?? '',
      productId: json['product_id'] ?? '',
      sku: json['sku'] ?? '',
      sizeLabel: json['size_label'] ?? '',
      price: (json['price_inr'] as num?)?.toDouble() ?? 0.0,
      mrp: (json['mrp_inr'] as num?)?.toDouble() ?? 0.0,
      stock: json['stock_quantity'] ?? 0,
      isDefault: json['is_default'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'product_id': productId,
        'sku': sku,
        'size_label': sizeLabel,
        'price_inr': price,
        'mrp_inr': mrp,
        'stock_quantity': stock,
        'is_default': isDefault,
      };
}

/// Category Model
class CategoryModel {
  final String id;
  final String name;
  final String slug;
  final String? description;
  final String? iconName;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    this.iconName,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      description: json['description'],
      iconName: json['icon_name'],
    );
  }
}

/// Product Model
class ProductModel {
  final String id;
  final String brandId;
  final String categoryId;
  final String name;
  final String slug;
  final String? tagline;
  final String description;
  final String ingredients;
  final String? howToUse;
  final List<String> freeFromClaims;
  final List<ProductVariant> variants;
  final List<String> imageUrls;
  final bool isFeatured;

  const ProductModel({
    required this.id,
    required this.brandId,
    required this.categoryId,
    required this.name,
    required this.slug,
    this.tagline,
    required this.description,
    required this.ingredients,
    this.howToUse,
    required this.freeFromClaims,
    required this.variants,
    required this.imageUrls,
    this.isFeatured = false,
  });

  ProductVariant get defaultVariant =>
      variants.firstWhere((v) => v.isDefault, orElse: () => variants.first);

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final claimsList = json['free_from_claims'];
    List<String> claims = [];
    if (claimsList is List) {
      claims = claimsList.map((e) => e.toString()).toList();
    }

    final variantsList = json['product_variants'];
    List<ProductVariant> vars = [];
    if (variantsList is List) {
      vars = variantsList.map((v) => ProductVariant.fromJson(v)).toList();
    }

    final imagesList = json['product_images'];
    List<String> imgs = [];
    if (imagesList is List) {
      imgs = imagesList.map((i) => (i['image_url'] ?? '').toString()).toList();
    }

    return ProductModel(
      id: json['id'] ?? '',
      brandId: json['brand_id'] ?? '',
      categoryId: json['category_id'] ?? '',
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      tagline: json['tagline'],
      description: json['description'] ?? '',
      ingredients: json['ingredients'] ?? '',
      howToUse: json['how_to_use'],
      freeFromClaims: claims,
      variants: vars,
      imageUrls: imgs,
    );
  }

  ProductModel copyWith({
    String? id,
    String? brandId,
    String? categoryId,
    String? name,
    String? slug,
    String? tagline,
    String? description,
    String? ingredients,
    String? howToUse,
    List<String>? freeFromClaims,
    List<ProductVariant>? variants,
    List<String>? imageUrls,
    bool? isFeatured,
  }) {
    return ProductModel(
      id: id ?? this.id,
      brandId: brandId ?? this.brandId,
      categoryId: categoryId ?? this.categoryId,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      tagline: tagline ?? this.tagline,
      description: description ?? this.description,
      ingredients: ingredients ?? this.ingredients,
      howToUse: howToUse ?? this.howToUse,
      freeFromClaims: freeFromClaims ?? this.freeFromClaims,
      variants: variants ?? this.variants,
      imageUrls: imageUrls ?? this.imageUrls,
      isFeatured: isFeatured ?? this.isFeatured,
    );
  }
}
