import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../config/theme/app_colors.dart';
import '../../cart/controllers/cart_controller.dart';
import '../repositories/product_repository.dart';
import '../widgets/product_image_widget.dart';

class WishlistScreen extends ConsumerWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wishlist = ref.watch(wishlistProvider);
    final productsAsync = ref.watch(productsFutureProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('Wishlist (${wishlist.length})'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_bag_outlined),
            onPressed: () => context.push('/cart'),
          ),
        ],
      ),
      body: productsAsync.when(
        data: (allProducts) {
          final wishlistedProducts = allProducts.where((p) => wishlist.contains(p.id)).toList();

          if (wishlistedProducts.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.favorite_border, size: 70, color: isDark ? AppColors.charcoalBorder : AppColors.sageLight),
                    const SizedBox(height: 16),
                    const Text(
                      'Your Wishlist is Empty',
                      style: TextStyle(fontFamily: 'serif', fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Tap the heart icon on any product to save it to your ritual wishlist.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: AppColors.textDarkSecondary),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => context.go('/'),
                      child: const Text('Explore Vaidyam Products'),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: wishlistedProducts.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final product = wishlistedProducts[index];
              final variant = product.defaultVariant;

              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: SizedBox(
                          width: 80,
                          height: 80,
                          child: ProductImageWidget(
                            imageUrl: product.imageUrls.isNotEmpty ? product.imageUrls.first : '',
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.name,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Size: ${variant.sizeLabel}',
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark ? AppColors.textLightSecondary : AppColors.textDarkSecondary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '₹${variant.price.toInt()}',
                              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.favorite, color: Colors.red, size: 20),
                            onPressed: () => ref.read(wishlistProvider.notifier).toggleWishlist(product.id),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            onPressed: () {
                              ref.read(cartProvider.notifier).addItem(product: product, variant: variant);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Moved ${product.name} to Bag')),
                              );
                            },
                            child: const Text('Move to Bag', style: TextStyle(fontSize: 10.5)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.forestSage)),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
