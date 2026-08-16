import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../admin/controllers/brand_settings_controller.dart';
import '../../admin/controllers/mobile_app_settings_controller.dart';
import '../../cart/controllers/cart_controller.dart';
import 'vaidyam_app_drawer_sheet.dart';

class VaidyamMobileAppHeader extends ConsumerWidget {
  final VoidCallback? onOpenDrawer;

  const VaidyamMobileAppHeader({
    super.key,
    this.onOpenDrawer,
  });

  static const Color _primaryPurple = Color(0xFF4338CA);
  static const Color _textDark = Color(0xFF0F172A);
  static const Color _textMuted = Color(0xFF64748B);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brandSettings = ref.watch(brandSettingsProvider);
    final mobileSettings = ref.watch(mobileAppSettingsProvider);
    final cartState = ref.watch(cartProvider);
    final int cartCount = cartState.totalItemCount;

    final String logoUrl = brandSettings.headerLogoUrl.isNotEmpty
        ? brandSettings.headerLogoUrl
        : (mobileSettings.mobileLogoUrl.isNotEmpty ? mobileSettings.mobileLogoUrl : '');


    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: Colors.white,
      child: Row(
        children: [
          // 1. Far Left Hamburger Menu Button ☰
          IconButton(
            icon: const Icon(Icons.menu_rounded, color: _textDark, size: 24),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            onPressed: onOpenDrawer ?? () => VaidyamAppDrawerSheet.show(context),
          ),

          const SizedBox(width: 8),

          // 2. Brand Logo (Managed by Admin Dashboard!)
          InkWell(
            onTap: () => context.go('/'),
            child: logoUrl.isNotEmpty
                ? ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 38, maxWidth: 180),
                    child: logoUrl.startsWith('data:image')
                        ? Image.memory(
                            base64Decode(logoUrl.split(',').last),
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => Image.asset(
                              'assets/images/cosmyra_logo.png',
                              height: 36,
                              fit: BoxFit.contain,
                            ),
                          )
                        : Image.network(
                            logoUrl,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => Image.asset(
                              'assets/images/cosmyra_logo.png',
                              height: 36,
                              fit: BoxFit.contain,
                            ),
                          ),
                  )
                : Image.asset(
                    'assets/images/cosmyra_logo.png',
                    height: 36,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => _buildDefaultPurpleEmblem(),
                  ),
          ),

          const Spacer(),

          const SizedBox(width: 8),

          // 4. Right Notification Bell 🔔 with purple dot
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none_rounded, color: _textDark, size: 24),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                onPressed: () => _showNotificationsSheet(context),
              ),
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: _primaryPurple,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(width: 4),

          // 5. Far Right Cart Icon 🛒 with badge (3)
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined, color: _textDark, size: 24),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                onPressed: () => context.push('/cart'),
              ),
              if (cartCount > 0)
                Positioned(
                  top: -2,
                  right: -2,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: _primaryPurple,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                    child: Center(
                      child: Text(
                        '$cartCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // Default Logo Widget using cosmyra_logo.png
  Widget _buildDefaultPurpleEmblem() {
    return Image.asset(
      'assets/images/cosmyra_logo.png',
      height: 32,
      fit: BoxFit.contain,
    );
  }

  // Brand Name & Subtitle Text
  Widget _buildBrandText(String name, String tagline) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          name,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w900,
            color: _textDark,
            height: 1.1,
          ),
        ),
        Text(
          tagline,
          style: const TextStyle(
            fontSize: 10,
            color: _textMuted,
            height: 1.1,
          ),
        ),
      ],
    );
  }

  // Category Drawer Bottom Sheet
  void _showCategoryDrawerSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Categories 🌿', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _textDark)),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                ],
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.face_rounded, color: _primaryPurple),
                title: const Text('Skin & Facial Care'),
                onTap: () {
                  Navigator.pop(ctx);
                  context.push('/shop?category=Skin Care');
                },
              ),
              ListTile(
                leading: const Icon(Icons.content_cut_rounded, color: _primaryPurple),
                title: const Text('Hair Oils & Shampoos'),
                onTap: () {
                  Navigator.pop(ctx);
                  context.push('/shop?category=Hair Care');
                },
              ),
              ListTile(
                leading: const Icon(Icons.spa_rounded, color: _primaryPurple),
                title: const Text('Pure Wellness & Supplements'),
                onTap: () {
                  Navigator.pop(ctx);
                  context.push('/shop?category=Wellness');
                },
              ),
              ListTile(
                leading: const Icon(Icons.admin_panel_settings_outlined, color: Color(0xFFD97706)),
                title: const Text('Admin Branding Dashboard'),
                subtitle: const Text('Upload & manage header logos'),
                onTap: () {
                  Navigator.pop(ctx);
                  context.push('/admin');
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Notifications Bottom Sheet
  void _showNotificationsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Notifications 🔔', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _textDark)),
              const SizedBox(height: 14),
              ListTile(
                leading: const Icon(Icons.local_shipping_outlined, color: Color(0xFF16A34A)),
                title: const Text('Order Out for Delivery! 🚚'),
                subtitle: const Text('Order #COS-9482 will be delivered today.'),
              ),
              ListTile(
                leading: const Icon(Icons.local_offer_outlined, color: _primaryPurple),
                title: const Text('Special Offer: 20% OFF Hair Care! 🌿'),
                subtitle: const Text('Use code BOTANICAL20 at checkout.'),
              ),
            ],
          ),
        );
      },
    );
  }
}
