import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product_model.dart';
import '../repositories/product_repository.dart';
import 'vaidyam_product_detail_screen.dart';

class ProductDetailScreen extends ConsumerWidget {
  final ProductModel? product;
  final String? productId;

  const ProductDetailScreen({
    super.key,
    this.product,
    this.productId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(adminProductsProvider);
    final targetProduct = product ??
        products.firstWhere(
          (p) => p.id == productId,
          orElse: () => products.first,
        );

    return VaidyamProductDetailScreen(product: targetProduct);
  }
}
