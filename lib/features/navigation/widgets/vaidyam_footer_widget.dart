import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class VaidyamFooterWidget extends StatefulWidget {
  const VaidyamFooterWidget({super.key});

  @override
  State<VaidyamFooterWidget> createState() => _VaidyamFooterWidgetState();
}

class _VaidyamFooterWidgetState extends State<VaidyamFooterWidget> {
  final TextEditingController _emailController = TextEditingController();
  String _selectedCountry = 'India';
  String _selectedLanguage = 'English';

  static const Color _bgDark = Color(0xFF0F172A);
  static const Color _primaryPurple = Color(0xFF4338CA);
  static const Color _borderDark = Color(0xFF1E293B);
  static const Color _textLight = Color(0xFFF8FAFC);
  static const Color _textMuted = Color(0xFF94A3B8);

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _handleSubscribe() {
    final email = _emailController.text.trim();
    if (email.isNotEmpty && email.contains('@')) {
      _emailController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Thank you for subscribing to Vaidyam Botanicals!'),
          backgroundColor: _primaryPurple,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid email address.'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1024;

    return Container(
      color: _bgDark,
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 48.0 : 20.0,
        vertical: 40.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Top Footer Grid (6 Columns)
          isDesktop
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Column 1: Brand Info & Newsletter
                    Expanded(flex: 3, child: _buildBrandNewsletterCol()),
                    const SizedBox(width: 32),

                    // Column 2: Shop
                    Expanded(
                      flex: 2,
                      child: _buildFooterLinkCol('SHOP', [
                        {'label': 'All Categories', 'path': '/explore'},
                        {'label': 'Today\'s Deals', 'path': '/explore'},
                        {'label': 'New Arrivals', 'path': '/explore'},
                        {'label': 'Best Sellers', 'path': '/explore'},
                        {'label': 'Featured Formulations', 'path': '/explore'},
                        {'label': 'Clearance Sale', 'path': '/explore'},
                      ]),
                    ),
                    const SizedBox(width: 24),

                    // Column 3: Customer Service
                    Expanded(
                      flex: 2,
                      child: _buildFooterLinkCol('CUSTOMER SERVICE', [
                        {'label': 'Track Your Order', 'path': '/orders'},
                        {'label': 'Returns & Refunds', 'path': '/orders'},
                        {'label': 'Shipping Information', 'path': '/orders'},
                        {'label': 'Payment Methods', 'path': '/cart'},
                        {'label': 'FAQ', 'path': '/dashboard'},
                        {'label': 'Contact Us', 'path': '/dashboard'},
                      ]),
                    ),
                    const SizedBox(width: 24),

                    // Column 4: My Account
                    Expanded(
                      flex: 2,
                      child: _buildFooterLinkCol('MY ACCOUNT', [
                        {'label': 'My Orders', 'path': '/orders'},
                        {'label': 'Wishlist', 'path': '/wishlist'},
                        {'label': 'Addresses', 'path': '/dashboard'},
                        {'label': 'Account Settings', 'path': '/dashboard'},
                        {'label': 'Notifications', 'path': '/dashboard'},
                        {'label': 'Logout', 'path': '/'},
                      ]),
                    ),
                    const SizedBox(width: 24),

                    // Column 5: About Us
                    Expanded(
                      flex: 2,
                      child: _buildFooterLinkCol('ABOUT US', [
                        {'label': 'About Vaidyam', 'path': '/'},
                        {'label': 'Our Story', 'path': '/'},
                        {'label': 'Careers', 'path': '/'},
                        {'label': 'Botanical Blog', 'path': '/'},
                        {'label': 'Privacy Policy', 'path': '/'},
                        {'label': 'Terms & Conditions', 'path': '/'},
                      ]),
                    ),
                    const SizedBox(width: 24),

                    // Column 6: Popular Categories
                    Expanded(flex: 3, child: _buildPopularCategoriesCol()),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBrandNewsletterCol(),
                    const SizedBox(height: 32),
                    Wrap(
                      spacing: 32,
                      runSpacing: 24,
                      children: [
                        SizedBox(
                          width: 150,
                          child: _buildFooterLinkCol('SHOP', [
                            {'label': 'All Categories', 'path': '/explore'},
                            {'label': 'Today\'s Deals', 'path': '/explore'},
                            {'label': 'Best Sellers', 'path': '/explore'},
                          ]),
                        ),
                        SizedBox(
                          width: 150,
                          child: _buildFooterLinkCol('MY ACCOUNT', [
                            {'label': 'My Orders', 'path': '/orders'},
                            {'label': 'Wishlist', 'path': '/wishlist'},
                            {'label': 'Settings', 'path': '/dashboard'},
                          ]),
                        ),
                      ],
                    ),
                  ],
                ),

          const SizedBox(height: 40),
          const Divider(color: _borderDark, height: 1),
          const SizedBox(height: 32),

          // 2. Middle Trust Feature Strip
          _buildMiddleTrustStrip(isDesktop),

          const SizedBox(height: 32),
          const Divider(color: _borderDark, height: 1),
          const SizedBox(height: 32),

          // 3. Payment Methods & App Download Row
          isDesktop
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildPaymentMethodsSection(),
                    _buildAppDownloadSection(),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPaymentMethodsSection(),
                    const SizedBox(height: 24),
                    _buildAppDownloadSection(),
                  ],
                ),

          const SizedBox(height: 32),
          const Divider(color: _borderDark, height: 1),
          const SizedBox(height: 24),

          // 4. Bottom Copyright & Region/Language Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '© 2026 Vaidyam Botanicals. All Rights Reserved.',
                style: TextStyle(color: _textMuted, fontSize: 12),
              ),
              Row(
                children: [
                  const Icon(Icons.location_on_outlined, color: _textMuted, size: 14),
                  const SizedBox(width: 4),
                  DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedCountry,
                      dropdownColor: _bgDark,
                      icon: const Icon(Icons.keyboard_arrow_down, color: _textMuted, size: 14),
                      style: const TextStyle(color: _textMuted, fontSize: 12),
                      onChanged: (val) => setState(() => _selectedCountry = val!),
                      items: ['India', 'United States', 'United Kingdom', 'Canada']
                          .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                          .toList(),
                    ),
                  ),
                  const Text('   |   ', style: TextStyle(color: _borderDark, fontSize: 12)),
                  const Icon(Icons.language_outlined, color: _textMuted, size: 14),
                  const SizedBox(width: 4),
                  DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedLanguage,
                      dropdownColor: _bgDark,
                      icon: const Icon(Icons.keyboard_arrow_down, color: _textMuted, size: 14),
                      style: const TextStyle(color: _textMuted, fontSize: 12),
                      onChanged: (val) => setState(() => _selectedLanguage = val!),
                      items: ['English', 'Hindi', 'Tamil', 'Malayalam']
                          .map((l) => DropdownMenuItem(value: l, child: Text(l)))
                          .toList(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- BRAND INFO & NEWSLETTER COLUMN ---
  Widget _buildBrandNewsletterCol() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Brand Logo
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _primaryPurple,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.local_florist, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            const Text(
              'Vaidyam Botanicals',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        const Text(
          'Your premier destination for certified organic Ayurvedic formulations. Quality, purity, and daily wellness – delivered to your doorstep.',
          style: TextStyle(color: _textMuted, fontSize: 13, height: 1.5),
        ),
        const SizedBox(height: 20),

        const Text(
          'Subscribe to our newsletter',
          style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        const Text(
          'Get updates on offers, new formulations and botanical rituals.',
          style: TextStyle(color: _textMuted, fontSize: 12),
        ),
        const SizedBox(height: 12),

        // Email Form Input & Submit
        Row(
          children: [
            Expanded(
              child: Container(
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: _borderDark),
                ),
                child: TextField(
                  controller: _emailController,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: const InputDecoration(
                    hintText: 'Enter your email',
                    hintStyle: TextStyle(color: _textMuted, fontSize: 13),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            InkWell(
              onTap: _handleSubscribe,
              child: Container(
                height: 40,
                width: 44,
                decoration: BoxDecoration(
                  color: _primaryPurple,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(Icons.arrow_forward, color: Colors.white, size: 18),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Social Icons Row
        Row(
          children: [
            _socialIconButton(Icons.facebook),
            const SizedBox(width: 10),
            _socialIconButton(Icons.camera_alt_outlined),
            const SizedBox(width: 10),
            _socialIconButton(Icons.alternate_email),
            const SizedBox(width: 10),
            _socialIconButton(Icons.play_arrow),
          ],
        ),
      ],
    );
  }

  Widget _socialIconButton(IconData icon) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        shape: BoxShape.circle,
        border: Border.all(color: _borderDark),
      ),
      child: Icon(icon, color: _textLight, size: 16),
    );
  }

  // --- FOOTER LINK COLUMN ---
  Widget _buildFooterLinkCol(String title, List<Map<String, String>> links) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 16),
        ...links.map((item) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: InkWell(
              onTap: () => context.push(item['path']!),
              child: Text(
                item['label']!,
                style: const TextStyle(color: _textMuted, fontSize: 13),
              ),
            ),
          );
        }),
      ],
    );
  }

  // --- POPULAR CATEGORIES COLUMN ---
  Widget _buildPopularCategoriesCol() {
    final popularList = [
      {'title': 'Haircare & Oils', 'asset': 'assets/images/shampoo.jpg'},
      {'title': 'Skincare & Serums', 'asset': 'assets/images/facewash.jpg'},
      {'title': 'Organic Soaps', 'asset': 'assets/images/soap.jpg'},
      {'title': 'Wellness Oils', 'asset': 'assets/images/soap.jpg'},
      {'title': 'Body Thailams', 'asset': 'assets/images/facewash.jpg'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'POPULAR CATEGORIES',
          style: TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 16),
        ...popularList.map((cat) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: InkWell(
              onTap: () => context.push('/explore'),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: _borderDark),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: Image.asset(
                        cat['asset']!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(Icons.spa, size: 16, color: _primaryPurple),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    cat['title']!,
                    style: const TextStyle(color: _textMuted, fontSize: 13),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  // --- MIDDLE TRUST FEATURE STRIP ---
  Widget _buildMiddleTrustStrip(bool isDesktop) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _middleTrustItem(Icons.local_shipping_outlined, 'FREE SHIPPING', 'On orders over ₹999'),
        _middleTrustItem(Icons.replay_outlined, 'EASY RETURNS', 'Within 7 days'),
        _middleTrustItem(Icons.verified_outlined, '100% SECURE', 'Payments'),
        _middleTrustItem(Icons.workspace_premium_outlined, 'BEST QUALITY', '100% Original Products'),
        _middleTrustItem(Icons.headset_mic_outlined, '24/7 SUPPORT', 'We\'re here to help'),
      ],
    );
  }

  Widget _middleTrustItem(IconData icon, String title, String subtitle) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            shape: BoxShape.circle,
            border: Border.all(color: _borderDark),
          ),
          child: Icon(icon, color: _primaryPurple, size: 18),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
            ),
            Text(
              subtitle,
              style: const TextStyle(color: _textMuted, fontSize: 11),
            ),
          ],
        ),
      ],
    );
  }

  // --- PAYMENT METHODS SECTION ---
  Widget _buildPaymentMethodsSection() {
    final paymentGateways = ['VISA', 'Mastercard', 'RuPay', 'UPI', 'Paytm', 'PhonePe'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'WE ACCEPT',
          style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
        const SizedBox(height: 12),
        Row(
          children: paymentGateways.map((name) {
            return Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                name,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  fontStyle: FontStyle.italic,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // --- APP DOWNLOAD SECTION ---
  Widget _buildAppDownloadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'DOWNLOAD OUR APP',
          style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
        const SizedBox(height: 4),
        const Text(
          'Get extra 10% off on your first app order.',
          style: TextStyle(color: _textMuted, fontSize: 12),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _appStoreBadge('GET IT ON', 'Google Play', Icons.android),
            const SizedBox(width: 12),
            _appStoreBadge('Download on the', 'App Store', Icons.apple),
          ],
        ),
      ],
    );
  }

  Widget _appStoreBadge(String line1, String line2, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _borderDark),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(line1, style: const TextStyle(color: _textMuted, fontSize: 9)),
              Text(line2, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}
