import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../admin/controllers/brand_settings_controller.dart';

class VaidyamFooterWidget extends ConsumerWidget {
  const VaidyamFooterWidget({super.key});

  static const Color _bgDark = Color(0xFF0F172A);
  static const Color _cardDark = Color(0xFF1E293B);
  static const Color _primaryPurple = Color(0xFF6366F1);
  static const Color _textLight = Color(0xFFF8FAFC);
  static const Color _textMuted = Color(0xFF94A3B8);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brandSettings = ref.watch(brandSettingsProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 900;

    final String logoUrl = brandSettings.footerLogoUrl.isNotEmpty
        ? brandSettings.footerLogoUrl
        : brandSettings.headerLogoUrl;

    return Container(
      decoration: const BoxDecoration(
        color: _bgDark,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 48.0 : 20.0,
        vertical: 36.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Top Section: 5 Columns Grid
          if (isDesktop)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Col 1: Brand & Description & Follow Us
                Expanded(flex: 3, child: _buildBrandCol(context, logoUrl)),
                const SizedBox(width: 24),

                // Col 2: Quick Links
                Expanded(flex: 2, child: _buildQuickLinksCol(context)),
                const SizedBox(width: 24),

                // Col 3: Customer Service
                Expanded(flex: 2, child: _buildCustomerServiceCol(context)),
                const SizedBox(width: 24),

                // Col 4: My Account
                Expanded(flex: 2, child: _buildMyAccountCol(context)),
                const SizedBox(width: 24),

                // Col 5: We Accept (Payment Logos)
                Expanded(flex: 3, child: _buildWeAcceptCol()),
              ],
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBrandCol(context, logoUrl),
                const SizedBox(height: 28),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildQuickLinksCol(context)),
                    Expanded(child: _buildCustomerServiceCol(context)),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildMyAccountCol(context)),
                    Expanded(child: _buildWeAcceptCol()),
                  ],
                ),
              ],
            ),

          const SizedBox(height: 32),
          const Divider(color: Color(0xFF1E293B), height: 1),
          const SizedBox(height: 24),

          // 2. Feature Trust Strip: Free Shipping | Easy Returns | 100% Secure | 24/7 Support
          _buildTrustStrip(isDesktop),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // Col 1: Brand Logo, Slogan, and Social Links
  Widget _buildBrandCol(BuildContext context, String logoUrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Brand Logo
        InkWell(
          onTap: () => context.go('/'),
          child: logoUrl.isNotEmpty
              ? ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 40, maxWidth: 180),
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
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/images/cosmyra_logo.png',
                      height: 38,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Icon(Icons.spa_rounded, color: Color(0xFF10B981), size: 28),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Vaidyam Botanicals',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ],
                ),
        ),

        const SizedBox(height: 14),

        const Text(
          'Your one-stop destination for the best products online. Quality, convenience and great prices – delivered to your doorstep.',
          style: TextStyle(
            color: _textMuted,
            fontSize: 12,
            height: 1.6,
          ),
        ),

        const SizedBox(height: 18),

        const Text(
          'Follow Us',
          style: TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 10),

        // Social Media Buttons
        Row(
          children: [
            _buildSocialIcon(Icons.facebook_rounded),
            const SizedBox(width: 8),
            _buildSocialIcon(Icons.camera_alt_outlined),
            const SizedBox(width: 8),
            _buildSocialIcon(Icons.flutter_dash),
            const SizedBox(width: 8),
            _buildSocialIcon(Icons.play_arrow_rounded),
            const SizedBox(width: 8),
            _buildSocialIcon(Icons.pin_drop_outlined),
          ],
        ),
      ],
    );
  }

  // Social Icon Circle
  Widget _buildSocialIcon(IconData icon) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Icon(icon, color: Colors.white, size: 16),
    );
  }

  // Col 2: Quick Links
  Widget _buildQuickLinksCol(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'QUICK LINKS',
          style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
        const SizedBox(height: 14),
        _buildFooterLink('All Categories', () => context.push('/categories')),
        _buildFooterLink("Today's Deals", () => context.push('/shop')),
        _buildFooterLink('New Arrivals', () => context.push('/shop')),
        _buildFooterLink('Best Sellers', () => context.push('/shop')),
      ],
    );
  }

  // Col 3: Customer Service
  Widget _buildCustomerServiceCol(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'CUSTOMER SERVICE',
          style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
        const SizedBox(height: 14),
        _buildFooterLink('Track Your Order', () => context.push('/orders')),
        _buildFooterLink('Returns & Refunds', () => context.push('/account')),
        _buildFooterLink('Shipping Info', () => context.push('/explore')),
        _buildFooterLink('Help & Support', () => context.push('/account')),
      ],
    );
  }

  // Col 4: My Account
  Widget _buildMyAccountCol(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'MY ACCOUNT',
          style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
        const SizedBox(height: 14),
        _buildFooterLink('My Orders', () => context.push('/orders')),
        _buildFooterLink('Wishlist', () => context.push('/wishlist')),
        _buildFooterLink('Addresses', () => context.push('/account')),
        _buildFooterLink('Login / Sign Up', () => context.push('/login')),
      ],
    );
  }

  // Col 5: We Accept (Payment Logos)
  Widget _buildWeAcceptCol() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'WE ACCEPT',
          style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildPaymentBadge('VISA', const Color(0xFF1A1F71), Colors.white),
            _buildMastercardBadge(),
            _buildPaymentBadge('RuPay', const Color(0xFF003874), const Color(0xFFF26522)),
            _buildPaymentBadge('UPI', const Color(0xFF0F766E), const Color(0xFF059669)),
            _buildPaymentBadge('Paytm', const Color(0xFF00B9F1), const Color(0xFF002E6D)),
            _buildPaymentBadge('PhonePe', const Color(0xFF5F259F), Colors.white),
          ],
        ),
      ],
    );
  }

  // Generic Payment Pill Badge
  Widget _buildPaymentBadge(String label, Color color1, Color color2) {
    return Container(
      width: 60,
      height: 32,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w900,
            color: color1,
          ),
        ),
      ),
    );
  }

  // Mastercard Specific Badge
  Widget _buildMastercardBadge() {
    return Container(
      width: 60,
      height: 32,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(width: 12, height: 12, decoration: const BoxDecoration(color: Color(0xFFEB001B), shape: BoxShape.circle)),
            Transform.translate(
              offset: const Offset(-4, 0),
              child: Container(width: 12, height: 12, decoration: BoxDecoration(color: const Color(0xFFF79E1B).withValues(alpha: 0.8), shape: BoxShape.circle)),
            ),
          ],
        ),
      ),
    );
  }

  // Footer Link Row Item
  Widget _buildFooterLink(String title, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        child: Text(
          title,
          style: const TextStyle(
            color: _textMuted,
            fontSize: 12,
            height: 1.3,
          ),
        ),
      ),
    );
  }

  // Trust Strip (Free Shipping, Easy Returns, 100% Secure, 24/7 Support)
  Widget _buildTrustStrip(bool isDesktop) {
    final List<Map<String, dynamic>> items = [
      {
        'icon': Icons.local_shipping_outlined,
        'title': 'FREE SHIPPING',
        'sub': 'On orders over ₹999',
      },
      {
        'icon': Icons.autorenew_rounded,
        'title': 'EASY RETURNS',
        'sub': 'Within 7 days',
      },
      {
        'icon': Icons.verified_user_outlined,
        'title': '100% SECURE',
        'sub': 'Safe Payments',
      },
      {
        'icon': Icons.headset_mic_outlined,
        'title': '24/7 SUPPORT',
        'sub': "We're here to help",
      },
    ];

    if (isDesktop) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: items.map((item) {
          return Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(item['icon'] as IconData, color: _primaryPurple, size: 20),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      item['title'] as String,
                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      item['sub'] as String,
                      style: const TextStyle(color: _textMuted, fontSize: 10),
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      );
    }

    return Column(
      children: items.map((item) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(item['icon'] as IconData, color: _primaryPurple, size: 20),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['title'] as String,
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    item['sub'] as String,
                    style: const TextStyle(color: _textMuted, fontSize: 11),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
