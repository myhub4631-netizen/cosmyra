import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/brand_settings_controller.dart';
import '../controllers/homepage_cms_controller.dart';

class AdminWebsiteContentManagerView extends ConsumerStatefulWidget {
  final int initialSubTab;

  const AdminWebsiteContentManagerView({
    super.key,
    this.initialSubTab = 0,
  });

  @override
  ConsumerState<AdminWebsiteContentManagerView> createState() => _AdminWebsiteContentManagerViewState();
}

class _AdminWebsiteContentManagerViewState extends ConsumerState<AdminWebsiteContentManagerView> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  late TextEditingController _brandNameCtrl;
  late TextEditingController _brandTaglineCtrl;
  late TextEditingController _headerLogoCtrl;
  late TextEditingController _footerLogoCtrl;
  late TextEditingController _heroTitleCtrl;
  late TextEditingController _heroSubCtrl;
  late TextEditingController _seoTitleCtrl;
  late TextEditingController _seoDescCtrl;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 9, vsync: this, initialIndex: widget.initialSubTab.clamp(0, 8));

    final brand = ref.read(brandSettingsProvider);
    final cms = ref.read(homepageCmsProvider);

    _brandNameCtrl = TextEditingController(text: brand.brandName);
    _brandTaglineCtrl = TextEditingController(text: brand.brandTagline);
    _headerLogoCtrl = TextEditingController(text: brand.headerLogoUrl);
    _footerLogoCtrl = TextEditingController(text: brand.footerLogoUrl);
    _heroTitleCtrl = TextEditingController(text: cms.heroHeadline);
    _heroSubCtrl = TextEditingController(text: cms.heroSubheadline);
    _seoTitleCtrl = TextEditingController(text: 'Vaidyam Botanicals | 100% Pure Organic Ayurvedic Skincare & Haircare');
    _seoDescCtrl = TextEditingController(text: 'Shop authentic Ayurvedic oils, face serums, herbal soaps, and wellness elixirs online. Free shipping over ₹999.');
  }

  @override
  void dispose() {
    _tabController.dispose();
    _brandNameCtrl.dispose();
    _brandTaglineCtrl.dispose();
    _headerLogoCtrl.dispose();
    _footerLogoCtrl.dispose();
    _heroTitleCtrl.dispose();
    _heroSubCtrl.dispose();
    _seoTitleCtrl.dispose();
    _seoDescCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage(TextEditingController targetCtrl, String label) async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'webp', 'gif'],
        withData: true,
      );
      if (result != null && result.files.isNotEmpty) {
        final bytes = result.files.first.bytes;
        if (bytes != null) {
          final String base64Result = 'data:image/png;base64,${base64Encode(bytes)}';
          setState(() {
            targetCtrl.text = base64Result;
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Website $label uploaded! 🖼️')),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Image selection failed: $e')),
        );
      }
    }
  }

  Future<void> _saveSettings() async {
    final brand = ref.read(brandSettingsProvider);
    final cms = ref.read(homepageCmsProvider);

    await ref.read(brandSettingsProvider.notifier).updateBrandSettings(
          brand.copyWith(
            brandName: _brandNameCtrl.text.trim(),
            brandTagline: _brandTaglineCtrl.text.trim(),
            headerLogoUrl: _headerLogoCtrl.text.trim(),
            footerLogoUrl: _footerLogoCtrl.text.trim(),
          ),
        );

    await ref.read(homepageCmsProvider.notifier).updateCms(
          cms.copyWith(
            heroHeadline: _heroTitleCtrl.text.trim(),
            heroSubheadline: _heroSubCtrl.text.trim(),
          ),
        );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Website Content Manager settings published! Website updated in real-time.'),
          backgroundColor: Color(0xFF4F46E5),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth > 1100;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── TOP HEADER BANNER ──
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4F46E5), Color(0xFF3730A3)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4F46E5).withValues(alpha: 0.25),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.language_rounded, color: Colors.white, size: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        '🌐 Website Content Manager',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Manage website banners, static pages, collections, blog posts, navigation menus, FAQs, testimonials & SEO settings.',
                        style: TextStyle(fontSize: 13, color: Color(0xFFE0E7FF)),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _saveSettings,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF4F46E5),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.save_rounded, size: 20),
                  label: const Text('Save Website Changes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ── TAB BAR FOR ALL 9 WEBSITE SECTIONS ──
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              labelColor: const Color(0xFF4F46E5),
              unselectedLabelColor: const Color(0xFF64748B),
              indicatorColor: const Color(0xFF4F46E5),
              indicatorWeight: 3,
              labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              tabs: const [
                Tab(icon: Icon(Icons.image_outlined, size: 18), text: 'Banners'),
                Tab(icon: Icon(Icons.description_outlined, size: 18), text: 'Pages'),
                Tab(icon: Icon(Icons.layers_outlined, size: 18), text: 'Collections'),
                Tab(icon: Icon(Icons.edit_note_rounded, size: 18), text: 'Blog'),
                Tab(icon: Icon(Icons.menu_open_rounded, size: 18), text: 'Menus'),
                Tab(icon: Icon(Icons.chat_bubble_outline_rounded, size: 18), text: 'Testimonials'),
                Tab(icon: Icon(Icons.help_outline_rounded, size: 18), text: 'FAQs'),
                Tab(icon: Icon(Icons.search_rounded, size: 18), text: 'SEO Settings'),
                Tab(icon: Icon(Icons.settings_outlined, size: 18), text: 'Site Settings'),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ── MAIN CONTENT + LIVE WEB PREVIEW SIMULATOR ──
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Main Tab Content Area
              Expanded(
                flex: 7,
                child: SizedBox(
                  height: 620,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildBannersTab(),
                      _buildPagesTab(),
                      _buildCollectionsTab(),
                      _buildBlogTab(),
                      _buildMenusTab(),
                      _buildTestimonialsTab(),
                      _buildFaqsTab(),
                      _buildSeoTab(),
                      _buildSiteSettingsTab(),
                    ],
                  ),
                ),
              ),

              if (isWide) ...[
                const SizedBox(width: 24),
                // Live Web Screen Simulator Preview
                Expanded(
                  flex: 3,
                  child: _buildLiveWebPreview(),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  // 1. BANNERS TAB
  Widget _buildBannersTab() {
    return SingleChildScrollView(
      child: _buildSectionCard(
        title: 'Website Banners & Hero Slider Manager',
        icon: Icons.image_outlined,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Website Main Hero Headline', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
            const SizedBox(height: 6),
            TextField(
              controller: _heroTitleCtrl,
              decoration: InputDecoration(
                hintText: 'e.g. Pure Ayurvedic Formulations',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 14),
            const Text('Website Hero Subheadline', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
            const SizedBox(height: 6),
            TextField(
              controller: _heroSubCtrl,
              decoration: InputDecoration(
                hintText: 'e.g. 100% Certified Organic Botanicals for Radiant Glow',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ],
        ),
      ),
    );
  }

  // 2. PAGES TAB
  Widget _buildPagesTab() {
    final pages = [
      {'title': 'About Vaidyam Botanicals', 'url': '/about', 'status': 'Published'},
      {'title': 'Contact & Support', 'url': '/contact', 'status': 'Published'},
      {'title': 'Privacy Policy', 'url': '/privacy', 'status': 'Published'},
      {'title': 'Terms & Conditions', 'url': '/terms', 'status': 'Published'},
      {'title': 'Shipping & Returns Policy', 'url': '/shipping-policy', 'status': 'Published'},
    ];

    return _buildSectionCard(
      title: 'Website Static Pages CMS',
      icon: Icons.description_outlined,
      child: ListView.separated(
        shrinkWrap: true,
        itemCount: pages.length,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (context, index) {
          final p = pages[index];
          return ListTile(
            leading: const Icon(Icons.article_outlined, color: Color(0xFF4F46E5)),
            title: Text(p['title']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            subtitle: Text(p['url']!, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: const Color(0xFFEEF2FF), borderRadius: BorderRadius.circular(12)),
              child: Text(p['status']!, style: const TextStyle(color: Color(0xFF4F46E5), fontSize: 11, fontWeight: FontWeight.bold)),
            ),
          );
        },
      ),
    );
  }

  // 3. COLLECTIONS TAB
  Widget _buildCollectionsTab() {
    final collections = [
      {'name': 'Ayurvedic Haircare Oils', 'items': '18 Products', 'tag': 'Featured'},
      {'name': 'Kumkumadi Saffron Glow', 'items': '12 Products', 'tag': 'Popular'},
      {'name': 'Cold-Pressed Herbal Soaps', 'items': '15 Products', 'tag': 'Best Seller'},
      {'name': 'Wellness Radiance Elixirs', 'items': '9 Products', 'tag': 'New'},
    ];

    return _buildSectionCard(
      title: 'Website Collections Manager',
      icon: Icons.layers_outlined,
      child: ListView.separated(
        shrinkWrap: true,
        itemCount: collections.length,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (context, index) {
          final c = collections[index];
          return ListTile(
            leading: const Icon(Icons.collections_bookmark_rounded, color: Color(0xFF4F46E5)),
            title: Text(c['name']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            subtitle: Text(c['items']!, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
            trailing: Chip(
              label: Text(c['tag']!, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
              backgroundColor: const Color(0xFF4F46E5),
            ),
          );
        },
      ),
    );
  }

  // 4. BLOG TAB
  Widget _buildBlogTab() {
    final blogs = [
      {'title': '10 Benefits of Bhringraj Hair Oil for Thinning Hair', 'author': 'Dr. Ananya Sharma', 'date': '14 May 2024'},
      {'title': 'Secrets of Kumkumadi Tailam: Saffron Radiance Guide', 'author': 'Vaidya Rakesh Shastri', 'date': '10 May 2024'},
    ];

    return _buildSectionCard(
      title: 'Ayurveda & Skincare Blog Posts',
      icon: Icons.edit_note_rounded,
      child: ListView.separated(
        shrinkWrap: true,
        itemCount: blogs.length,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (context, index) {
          final b = blogs[index];
          return ListTile(
            leading: const Icon(Icons.menu_book_rounded, color: Color(0xFF4F46E5)),
            title: Text(b['title']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            subtitle: Text('By ${b['author']} • ${b['date']}', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
          );
        },
      ),
    );
  }

  // 5. MENUS TAB
  Widget _buildMenusTab() {
    return _buildSectionCard(
      title: 'Header Navigation Menu & Footer Links',
      icon: Icons.menu_open_rounded,
      child: Column(
        children: const [
          ListTile(leading: Icon(Icons.link), title: Text('Home', style: TextStyle(fontWeight: FontWeight.bold)), subtitle: Text('/')),
          ListTile(leading: Icon(Icons.link), title: Text('Shop Catalog', style: TextStyle(fontWeight: FontWeight.bold)), subtitle: Text('/shop')),
          ListTile(leading: Icon(Icons.link), title: Text('Categories', style: TextStyle(fontWeight: FontWeight.bold)), subtitle: Text('/categories')),
          ListTile(leading: Icon(Icons.link), title: Text('Explore Concerns', style: TextStyle(fontWeight: FontWeight.bold)), subtitle: Text('/explore')),
        ],
      ),
    );
  }

  // 6. TESTIMONIALS TAB
  Widget _buildTestimonialsTab() {
    final testimonials = [
      {'name': 'Priya S.', 'comment': 'The Bhringraj hair oil completely stopped my hair fall within 3 weeks!', 'rating': '5/5 Stars'},
      {'name': 'Rahul Verma', 'comment': 'Authentic Ayurvedic products. Very fast delivery and excellent packaging.', 'rating': '5/5 Stars'},
    ];

    return _buildSectionCard(
      title: 'Customer Verified Testimonials',
      icon: Icons.chat_bubble_outline_rounded,
      child: ListView.separated(
        shrinkWrap: true,
        itemCount: testimonials.length,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (context, index) {
          final t = testimonials[index];
          return ListTile(
            leading: const Icon(Icons.format_quote_rounded, color: Color(0xFF4F46E5)),
            title: Text(t['name']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            subtitle: Text(t['comment']!, style: const TextStyle(fontSize: 12, color: Color(0xFF334155))),
            trailing: Text(t['rating']!, style: const TextStyle(color: Color(0xFFD97706), fontWeight: FontWeight.bold, fontSize: 12)),
          );
        },
      ),
    );
  }

  // 7. FAQS TAB
  Widget _buildFaqsTab() {
    return _buildSectionCard(
      title: 'Frequently Asked Questions (FAQ)',
      icon: Icons.help_outline_rounded,
      child: Column(
        children: const [
          ListTile(
            title: Text('Are Vaidyam Botanicals products 100% natural?', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('Yes! All our oils, soaps, and face serums are 100% certified organic with zero harmful chemicals.'),
          ),
          Divider(),
          ListTile(
            title: Text('What is the estimated shipping time?', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('Orders are processed within 24 hours and delivered in 2–3 business days across India.'),
          ),
        ],
      ),
    );
  }

  // 8. SEO TAB
  Widget _buildSeoTab() {
    return SingleChildScrollView(
      child: _buildSectionCard(
        title: 'Website SEO & Meta Tag Configurations',
        icon: Icons.search_rounded,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('SEO Page Title Tag', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            TextField(controller: _seoTitleCtrl, decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)))),
            const SizedBox(height: 14),
            const Text('SEO Meta Description', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            TextField(controller: _seoDescCtrl, maxLines: 3, decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)))),
          ],
        ),
      ),
    );
  }

  // 9. SITE SETTINGS TAB
  Widget _buildSiteSettingsTab() {
    return SingleChildScrollView(
      child: _buildSectionCard(
        title: 'General Website Settings & Logos',
        icon: Icons.settings_outlined,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Website Brand Name', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            TextField(controller: _brandNameCtrl, decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)))),
            const SizedBox(height: 14),
            const Text('Website Tagline', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            TextField(controller: _brandTaglineCtrl, decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)))),
            const SizedBox(height: 14),
            const Text('Header Logo Image', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(child: TextField(controller: _headerLogoCtrl, decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))))),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: () => _pickImage(_headerLogoCtrl, 'Header Logo'),
                  icon: const Icon(Icons.upload, size: 18),
                  label: const Text('Upload'),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4F46E5), foregroundColor: Colors.white),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({required String title, required IconData icon, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF4F46E5), size: 22),
              const SizedBox(width: 10),
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  // LIVE DESKTOP WEB PREVIEW SIMULATOR
  Widget _buildLiveWebPreview() {
    final String headline = _heroTitleCtrl.text.trim().isNotEmpty ? _heroTitleCtrl.text.trim() : 'Pure Ayurvedic Formulations';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF475569), width: 4),
        boxShadow: const [BoxShadow(color: Color(0x33000000), blurRadius: 16, offset: Offset(0, 6))],
      ),
      child: Column(
        children: [
          // Browser Top Bar
          Row(
            children: [
              Row(
                children: const [
                  CircleAvatar(radius: 4, backgroundColor: Color(0xFFEF4444)),
                  SizedBox(width: 4),
                  CircleAvatar(radius: 4, backgroundColor: Color(0xFFF59E0B)),
                  SizedBox(width: 4),
                  CircleAvatar(radius: 4, backgroundColor: Color(0xFF10B981)),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(6)),
                  child: const Text('https://cosmyra.cloud', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 10)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Web Page Simulator Box
          Container(
            height: 520,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9)))),
                  child: Row(
                    children: [
                      const CircleAvatar(radius: 8, backgroundColor: Color(0xFF4F46E5), child: Icon(Icons.local_florist, color: Colors.white, size: 10)),
                      const SizedBox(width: 6),
                      Text(_brandNameCtrl.text.trim().isNotEmpty ? _brandNameCtrl.text.trim() : 'Vaidyam', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      const Spacer(),
                      Row(
                        children: const [
                          Text('Shop', style: TextStyle(fontSize: 9, color: Color(0xFF4B5563))),
                          SizedBox(width: 8),
                          Text('Explore', style: TextStyle(fontSize: 9, color: Color(0xFF4B5563))),
                          SizedBox(width: 8),
                          Icon(Icons.shopping_cart_outlined, size: 14),
                        ],
                      ),
                    ],
                  ),
                ),

                // Hero Banner
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(colors: [Color(0xFF4F46E5), Color(0xFF3730A3)]),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(headline, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                      const SizedBox(height: 4),
                      Text(_heroSubCtrl.text.trim(), style: const TextStyle(color: Color(0xFFE0E7FF), fontSize: 9), maxLines: 2),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
