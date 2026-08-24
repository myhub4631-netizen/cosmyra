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
    final double priceVal = (json['price_inr'] as num?)?.toDouble() ??
        (json['price'] as num?)?.toDouble() ??
        (json['priceINR'] as num?)?.toDouble() ??
        0.0;
    final double mrpVal = (json['mrp_inr'] as num?)?.toDouble() ??
        (json['mrp'] as num?)?.toDouble() ??
        (json['mrpINR'] as num?)?.toDouble() ??
        priceVal;
    final int stockVal = (json['stock_quantity'] as num?)?.toInt() ??
        (json['stock'] as num?)?.toInt() ??
        (json['stockQuantity'] as num?)?.toInt() ??
        100;

    return ProductVariant(
      id: (json['id'] ?? '').toString(),
      productId: (json['product_id'] ?? json['productId'] ?? '').toString(),
      sku: (json['sku'] ?? 'VDY-SKU').toString(),
      sizeLabel: (json['size_label'] ?? json['sizeLabel'] ?? '200 ml').toString(),
      price: priceVal,
      mrp: mrpVal,
      stock: stockVal,
      isDefault: json['is_default'] ?? json['isDefault'] ?? true,
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
      iconName: json['icon_name'] ?? json['iconName'],
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
  final int mediaVersion;
  final int productVersion;
  final String? updatedAt;
  final String? mediaUpdatedAt;

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
    this.mediaVersion = 1,
    this.productVersion = 1,
    this.updatedAt,
    this.mediaUpdatedAt,
  });

  /// Returns canonical image URL with cache-busting version parameter
  String appendVersionToUrl(String url) {
    final trimmed = url.trim();
    if (trimmed.isEmpty || trimmed.startsWith('data:') || trimmed.startsWith('assets/')) {
      return trimmed;
    }
    final uri = Uri.parse(trimmed);
    final queryParams = Map<String, String>.from(uri.queryParameters);
    queryParams['v'] = mediaVersion.toString();
    return uri.replace(queryParameters: queryParams).toString();
  }

  /// Get primary image URL with version parameter
  String get primaryImageUrl {
    final raw = imageUrls.isNotEmpty ? imageUrls.first : '';
    return appendVersionToUrl(raw);
  }

  /// Get formatted image URLs with version parameters
  List<String> get formattedImageUrls {
    return imageUrls.map((url) => appendVersionToUrl(url)).toList();
  }

  double get rating => 4.8;

  ProductVariant get defaultVariant => variants.firstWhere(
        (v) => v.isDefault,
        orElse: () => variants.isNotEmpty
            ? variants.first
            : ProductVariant(
                id: 'var-$id',
                productId: id,
                sku: 'VDY-$id',
                sizeLabel: '200 ml',
                price: 399.0,
                mrp: 499.0,
                stock: 100,
                isDefault: true,
              ),
      );

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final claimsList = json['free_from_claims'] ?? json['freeFromClaims'];
    List<String> claims = [];
    if (claimsList is List) {
      claims = claimsList.map((e) => e.toString()).toList();
    }

    final variantsList = json['product_variants'] ?? json['variants'];
    List<ProductVariant> vars = [];
    if (variantsList is List) {
      vars = variantsList
          .map((v) => ProductVariant.fromJson(v is Map<String, dynamic> ? v : {}))
          .toList();
    }

    final imagesList = json['product_images'] ?? json['imageUrls'] ?? json['image_urls'];
    List<String> imgs = [];
    if (imagesList is List) {
      final sortedList = List.from(imagesList);
      sortedList.sort((a, b) {
        if (a is Map && b is Map) {
          final int orderA = (a['display_order'] as num?)?.toInt() ?? 0;
          final int orderB = (b['display_order'] as num?)?.toInt() ?? 0;
          return orderA.compareTo(orderB);
        }
        return 0;
      });
      imgs = sortedList.map((i) {
        if (i is Map) return (i['image_url'] ?? i['url'] ?? '').toString();
        return i.toString();
      }).where((img) => img.isNotEmpty).toList();
    }

    if (imgs.isEmpty) {
      final singleImg = json['primary_image'] ??
          json['primaryImage'] ??
          json['image'] ??
          json['imageUrl'] ??
          json['featured_image'] ??
          json['featuredImage'];
      if (singleImg != null && singleImg.toString().trim().isNotEmpty) {
        imgs = [singleImg.toString().trim()];
      } else {
        final slug = (json['slug'] ?? '').toString().toLowerCase();
        final name = (json['name'] ?? '').toString().toLowerCase();
        if (slug.contains('shampoo') || name.contains('shampoo')) {
          imgs = ['https://tkwxkmmxweqrfdttkjfd.supabase.co/storage/v1/object/public/product-images/catalog_baseline/shampoo.jpg'];
        } else if (slug.contains('soap') || name.contains('soap')) {
          imgs = ['https://tkwxkmmxweqrfdttkjfd.supabase.co/storage/v1/object/public/product-images/catalog_baseline/soap.jpg'];
        } else if (slug.contains('face') || slug.contains('cleanser') || name.contains('face') || name.contains('cleanser')) {
          imgs = ['https://tkwxkmmxweqrfdttkjfd.supabase.co/storage/v1/object/public/product-images/catalog_baseline/facewash.jpg'];
        } else if (slug.contains('serum') || name.contains('serum') || slug.contains('kumkumadi') || name.contains('kumkumadi')) {
          imgs = ['https://tkwxkmmxweqrfdttkjfd.supabase.co/storage/v1/object/public/product-images/catalog_baseline/facewash.jpg'];
        } else if (slug.contains('oil') || name.contains('oil') || slug.contains('thailam') || name.contains('thailam')) {
          imgs = ['https://tkwxkmmxweqrfdttkjfd.supabase.co/storage/v1/object/public/product-images/catalog_baseline/soap.jpg'];
        } else {
          imgs = ['https://tkwxkmmxweqrfdttkjfd.supabase.co/storage/v1/object/public/product-images/catalog_baseline/shampoo.jpg'];
        }
      }
    }

    if (vars.isEmpty) {
      final fallbackPrice = (json['price'] as num?)?.toDouble() ?? 399.0;
      final fallbackMrp = (json['mrp'] as num?)?.toDouble() ?? 499.0;
      vars = [
        ProductVariant(
          id: 'var-${json['id'] ?? DateTime.now().millisecondsSinceEpoch}',
          productId: (json['id'] ?? '').toString(),
          sku: (json['sku'] ?? 'VDY-SKU').toString(),
          sizeLabel: (json['size_label'] ?? json['sizeLabel'] ?? '200 ml').toString(),
          price: fallbackPrice,
          mrp: fallbackMrp,
          stock: (json['stock'] as num?)?.toInt() ?? 100,
          isDefault: true,
        ),
      ];
    }

    return ProductModel(
      id: (json['id'] ?? '').toString(),
      brandId: (json['brand_id'] ?? json['brandId'] ?? 'brand-vaidyam').toString(),
      categoryId: (json['category_id'] ?? json['categoryId'] ?? 'cat-skincare').toString(),
      name: (json['name'] ?? 'Botanical Product').toString(),
      slug: (json['slug'] ?? 'botanical-product').toString(),
      tagline: json['tagline']?.toString(),
      description: (json['description'] ?? 'Botanical formulation.').toString(),
      ingredients: (json['ingredients'] ?? 'Aqua, Herbal extract.').toString(),
      howToUse: json['how_to_use']?.toString() ?? json['howToUse']?.toString(),
      freeFromClaims: claims,
      variants: vars,
      imageUrls: imgs,
      isFeatured: json['is_featured'] ?? json['isFeatured'] ?? false,
      mediaVersion: (json['media_version'] ?? json['mediaVersion'] as num?)?.toInt() ?? 1,
      productVersion: (json['product_version'] ?? json['productVersion'] as num?)?.toInt() ?? 1,
      updatedAt: json['updated_at']?.toString() ?? json['updatedAt']?.toString(),
      mediaUpdatedAt: json['media_updated_at']?.toString() ?? json['mediaUpdatedAt']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'brand_id': brandId,
        'category_id': categoryId,
        'name': name,
        'slug': slug,
        'tagline': tagline,
        'description': description,
        'ingredients': ingredients,
        'how_to_use': howToUse,
        'free_from_claims': freeFromClaims,
        'product_variants': variants.map((v) => v.toJson()).toList(),
        'product_images': imageUrls.asMap().entries.map((e) => {'image_url': e.value, 'display_order': e.key}).toList(),
        'is_featured': isFeatured,
        'media_version': mediaVersion,
        'product_version': productVersion,
        'updated_at': updatedAt,
        'media_updated_at': mediaUpdatedAt,
      };

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
    int? mediaVersion,
    int? productVersion,
    String? updatedAt,
    String? mediaUpdatedAt,
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
      mediaVersion: mediaVersion ?? this.mediaVersion,
      productVersion: productVersion ?? this.productVersion,
      updatedAt: updatedAt ?? this.updatedAt,
      mediaUpdatedAt: mediaUpdatedAt ?? this.mediaUpdatedAt,
    );
  }
}
