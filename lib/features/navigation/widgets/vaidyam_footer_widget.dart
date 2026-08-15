import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../admin/controllers/footer_cms_controller.dart';

class VaidyamFooterWidget extends ConsumerStatefulWidget {
  const VaidyamFooterWidget({super.key});

  @override
  ConsumerState<VaidyamFooterWidget> createState() => _VaidyamFooterWidgetState();
}

class _VaidyamFooterWidgetState extends ConsumerState<VaidyamFooterWidget> {
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
    final footerState = ref.watch(footerCmsProvider);
    final activeSections = footerState.sections.where((s) => s['isActive'] == true).toList();

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
          // 1. Dynamic Footer Columns Grid
          isDesktop
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Column 1: Brand Info & Newsletter
                    Expanded(flex: 3, child: _buildBrandNewsletterCol(footerState)),
                    const SizedBox(width: 32),

                    // Dynamic Section Columns from Footer Manager State
                    ...activeSections.where((s) => s['type'] != 'newsletter_info' && s['type'] != 'bottom_bar').map((sec) {
                      final rawItems = sec['items'] as List? ?? [];
                      final links = rawItems.map((e) {
                        if (e is Map) {
                          return {'label': e['text']?.toString() ?? '', 'path': e['url']?.toString() ?? '/explore'};
                        }
                        return {'label': e.toString(), 'path': '/explore'};
                      }).toList();

                      return Expanded(
                        flex: 2,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 20),
                          child: _buildFooterLinkCol(sec['title']?.toString().toUpperCase() ?? 'SECTION', links),
                        ),
                      );
                    }),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBrandNewsletterCol(footerState),
                    const SizedBox(height: 32),
                    Wrap(
                      spacing: 32,
                      runSpacing: 24,
                      children: activeSections.where((s) => s['type'] != 'newsletter_info' && s['type'] != 'bottom_bar').map((sec) {
                        final rawItems = sec['items'] as List? ?? [];
                        final links = rawItems.map((e) {
                          if (e is Map) {
                            return {'label': e['text']?.toString() ?? '', 'path': e['url']?.toString() ?? '/explore'};
                          }
                          return {'label': e.toString(), 'path': '/explore'};
                        }).toList();

                        return SizedBox(
                          width: 150,
                          child: _buildFooterLinkCol(sec['title']?.toString().toUpperCase() ?? 'SECTION', links),
                        );
                      }).toList(),
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
              Text(
                footerState.copyrightText,
                style: const TextStyle(color: _textMuted, fontSize: 12),
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
  Widget _buildBrandNewsletterCol(FooterCmsState footerState) {
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
            Text(
              footerState.brandName,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          footerState.brandDescription,
          style: const TextStyle(color: _textMuted, fontSize: 13, height: 1.5),
        ),
        const SizedBox(height: 20),

        Text(
          footerState.newsletterTitle,
          style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          footerState.newsletterSubtitle,
          style: const TextStyle(color: _textMuted, fontSize: 12),
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
                    hintText: 'Enter your email address',
                    hintStyle: TextStyle(color: _textMuted, fontSize: 13),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _handleSubscribe,
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                elevation: 0,
              ),
              child: const Text('Subscribe', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Social Icons Row
        Row(
          children: [
            _socialIcon(Icons.facebook),
            const SizedBox(width: 12),
            _socialIcon(Icons.camera_alt_outlined),
            const SizedBox(width: 12),
            _socialIcon(Icons.close),
            const SizedBox(width: 12),
            _socialIcon(Icons.play_arrow_outlined),
          ],
        ),
      ],
    );
  }

  Widget _socialIcon(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        shape: BoxShape.circle,
        border: Border.all(color: _borderDark),
      ),
      child: Icon(icon, color: _textMuted, size: 16),
    );
  }

  // --- REUSABLE FOOTER LINK COLUMN ---
  Widget _buildFooterLinkCol(String title, List<Map<String, String>> links) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: links.map((link) {
            final label = link['label'] ?? '';
            final path = link['path'] ?? '/explore';

            return Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: InkWell(
                onTap: () {
                  if (path.isNotEmpty) {
                    context.push(path);
                  }
                },
                child: Text(
                  label,
                  style: const TextStyle(
                    color: _textMuted,
                    fontSize: 13,
                    height: 1.3,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // --- MIDDLE TRUST FEATURE STRIP ---
  Widget _buildMiddleTrustStrip(bool isDesktop) {
    final features = [
      {'icon': Icons.local_shipping_outlined, 'title': 'FREE SHIPPING', 'sub': 'On orders over ₹999'},
      {'icon': Icons.replay_outlined, 'title': 'EASY RETURNS', 'sub': 'Within 7 days return policy'},
      {'icon': Icons.lock_outline, 'title': '100% SECURE', 'sub': 'Encrypted payment gateway'},
      {'icon': Icons.verified_outlined, 'title': 'BEST QUALITY', 'sub': '100% Original Products'},
      {'icon': Icons.support_agent_outlined, 'title': '24/7 SUPPORT', 'sub': 'We are here to help'},
    ];

    return isDesktop
        ? Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: features.map((f) => _trustItem(f['icon'] as IconData, f['title'] as String, f['sub'] as String)).toList(),
          )
        : Wrap(
            spacing: 24,
            runSpacing: 16,
            children: features.map((f) => SizedBox(width: 160, child: _trustItem(f['icon'] as IconData, f['title'] as String, f['sub'] as String))).toList(),
          );
  }

  Widget _trustItem(IconData icon, String title, String sub) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            shape: BoxShape.circle,
            border: Border.all(color: _borderDark),
          ),
          child: Icon(icon, color: _primaryPurple, size: 20),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(color: _textLight, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
            const SizedBox(height: 2),
            Text(sub, style: const TextStyle(color: _textMuted, fontSize: 10)),
          ],
        ),
      ],
    );
  }

  // --- PAYMENT METHODS ---
  Widget _buildPaymentMethodsSection() {
    final methods = ['VISA', 'Mastercard', 'PayPal', 'UPI', 'Paytm', 'PhonePe'];

    return Row(
      children: [
        const Text('WE ACCEPT:', style: TextStyle(color: _textMuted, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
        const SizedBox(width: 12),
        Wrap(
          spacing: 8,
          children: methods.map((m) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: _borderDark),
              ),
              child: Text(
                m,
                style: const TextStyle(color: _textLight, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // --- APP DOWNLOAD ---
  Widget _buildAppDownloadSection() {
    return Row(
      children: [
        const Text('DOWNLOAD OUR APP:', style: TextStyle(color: _textMuted, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
        const SizedBox(width: 12),
        _appBadge('Google Play', Icons.shop_outlined),
        const SizedBox(width: 8),
        _appBadge('App Store', Icons.apple),
      ],
    );
  }

  Widget _appBadge(String store, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: _borderDark),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 14),
          const SizedBox(width: 6),
          Text(store, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
