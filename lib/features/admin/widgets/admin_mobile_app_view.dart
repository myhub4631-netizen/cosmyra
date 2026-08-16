import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/theme/app_colors.dart';
import '../controllers/mobile_app_settings_controller.dart';

class AdminMobileAppView extends ConsumerStatefulWidget {
  final int initialSubTab;

  const AdminMobileAppView({
    super.key,
    this.initialSubTab = 0,
  });

  @override
  ConsumerState<AdminMobileAppView> createState() => _AdminMobileAppViewState();
}

class _AdminMobileAppViewState extends ConsumerState<AdminMobileAppView> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  late TextEditingController _appNameCtrl;
  late TextEditingController _logoCtrl;
  late TextEditingController _announcementCtrl;
  late TextEditingController _searchHintCtrl;
  late TextEditingController _bannerTitleCtrl;
  late TextEditingController _bannerSubCtrl;
  late TextEditingController _bannerDiscountCtrl;
  late TextEditingController _bannerImageCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _whatsappCtrl;
  late TextEditingController _pushTitleCtrl;
  late TextEditingController _pushBodyCtrl;

  late bool _showAnnouncement;
  late bool _showHotSelling;
  late bool _showCategoryGrid;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 9, vsync: this, initialIndex: widget.initialSubTab.clamp(0, 8));

    final settings = ref.read(mobileAppSettingsProvider);
    _appNameCtrl = TextEditingController(text: settings.mobileAppName);
    _logoCtrl = TextEditingController(text: settings.mobileLogoUrl);
    _announcementCtrl = TextEditingController(text: settings.announcementBarText);
    _searchHintCtrl = TextEditingController(text: settings.searchPlaceholder);
    _bannerTitleCtrl = TextEditingController(text: settings.bannerTitle);
    _bannerSubCtrl = TextEditingController(text: settings.bannerSubtitle);
    _bannerDiscountCtrl = TextEditingController(text: settings.bannerDiscountTag);
    _bannerImageCtrl = TextEditingController(text: settings.bannerImageUrl);
    _phoneCtrl = TextEditingController(text: settings.supportPhone);
    _whatsappCtrl = TextEditingController(text: settings.whatsappNumber);
    _pushTitleCtrl = TextEditingController(text: '🌿 Special Weekend Offer!');
    _pushBodyCtrl = TextEditingController(text: 'Get flat 30% off on all Ayurvedic Hair Oils today!');

    _showAnnouncement = settings.showAnnouncementBar;
    _showHotSelling = settings.showHotSellingSection;
    _showCategoryGrid = settings.showCategoryGrid;
  }

  @override
  void dispose() {
    _tabController.dispose();
    _appNameCtrl.dispose();
    _logoCtrl.dispose();
    _announcementCtrl.dispose();
    _searchHintCtrl.dispose();
    _bannerTitleCtrl.dispose();
    _bannerSubCtrl.dispose();
    _bannerDiscountCtrl.dispose();
    _bannerImageCtrl.dispose();
    _phoneCtrl.dispose();
    _whatsappCtrl.dispose();
    _pushTitleCtrl.dispose();
    _pushBodyCtrl.dispose();
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
              SnackBar(content: Text('Custom Mobile $label uploaded! 🖼️')),
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
    final settings = ref.read(mobileAppSettingsProvider);
    final updated = settings.copyWith(
      mobileAppName: _appNameCtrl.text.trim(),
      mobileLogoUrl: _logoCtrl.text.trim(),
      announcementBarText: _announcementCtrl.text.trim(),
      showAnnouncementBar: _showAnnouncement,
      searchPlaceholder: _searchHintCtrl.text.trim(),
      bannerTitle: _bannerTitleCtrl.text.trim(),
      bannerSubtitle: _bannerSubCtrl.text.trim(),
      bannerDiscountTag: _bannerDiscountCtrl.text.trim(),
      bannerImageUrl: _bannerImageCtrl.text.trim(),
      supportPhone: _phoneCtrl.text.trim(),
      whatsappNumber: _whatsappCtrl.text.trim(),
      showHotSellingSection: _showHotSelling,
      showCategoryGrid: _showCategoryGrid,
    );

    await ref.read(mobileAppSettingsProvider.notifier).updateSettings(updated);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ App Content Manager settings published! Mobile app updated in real-time.'),
          backgroundColor: Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(mobileAppSettingsProvider);
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
                colors: [Color(0xFF10B981), Color(0xFF059669)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF10B981).withValues(alpha: 0.25),
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
                  child: const Icon(Icons.phone_iphone_rounded, color: Colors.white, size: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        '📱 Mobile App Content Manager',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Manage app banners, app pages, categories, collections, configurations & push notifications in real-time.',
                        style: TextStyle(fontSize: 13, color: Color(0xFFECFDF5)),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _saveSettings,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF059669),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.save_rounded, size: 20),
                  label: const Text('Save App Changes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ── TAB BAR FOR ALL 9 MOBILE APP SECTIONS ──
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              labelColor: const Color(0xFF059669),
              unselectedLabelColor: const Color(0xFF64748B),
              indicatorColor: const Color(0xFF059669),
              indicatorWeight: 3,
              labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              tabs: const [
                Tab(icon: Icon(Icons.image_outlined, size: 18), text: 'App Banners'),
                Tab(icon: Icon(Icons.description_outlined, size: 18), text: 'App Pages'),
                Tab(icon: Icon(Icons.grid_view_rounded, size: 18), text: 'App Categories'),
                Tab(icon: Icon(Icons.layers_outlined, size: 18), text: 'App Collections'),
                Tab(icon: Icon(Icons.settings_suggest_outlined, size: 18), text: 'App Configurations'),
                Tab(icon: Icon(Icons.format_list_bulleted_rounded, size: 18), text: 'Bottom Navigation'),
                Tab(icon: Icon(Icons.notifications_active_outlined, size: 18), text: 'Push Notifications'),
                Tab(icon: Icon(Icons.system_update_rounded, size: 18), text: 'App Version'),
                Tab(icon: Icon(Icons.smartphone_rounded, size: 18), text: 'Splash & Onboarding'),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ── MAIN CONTENT + LIVE MOBILE PREVIEW SIDEBAR ──
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
                      _buildAppBannersTab(),
                      _buildAppPagesTab(),
                      _buildAppCategoriesTab(),
                      _buildAppCollectionsTab(),
                      _buildAppConfigurationsTab(),
                      _buildBottomNavTab(),
                      _buildPushNotificationsTab(),
                      _buildAppVersionTab(),
                      _buildSplashOnboardingTab(),
                    ],
                  ),
                ),
              ),

              if (isWide) ...[
                const SizedBox(width: 24),
                // Live Mobile App Screen Simulator Preview
                Expanded(
                  flex: 3,
                  child: _buildLiveMobileAppPreview(settings),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  // 1. APP BANNERS TAB
  Widget _buildAppBannersTab() {
    return SingleChildScrollView(
      child: _buildSectionCard(
        title: 'App Banners & Promo Offer Cards',
        icon: Icons.image_outlined,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Primary Hero Banner Title', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
            const SizedBox(height: 6),
            TextField(
              controller: _bannerTitleCtrl,
              decoration: InputDecoration(
                hintText: 'e.g. Great Deals on Ayurveda & Skincare',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 14),
            const Text('Banner Discount Tag Text', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
            const SizedBox(height: 6),
            TextField(
              controller: _bannerDiscountCtrl,
              decoration: InputDecoration(
                hintText: 'e.g. Up to 60% OFF • Shop Now',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 14),
            const Text('Banner Subtitle / Description', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
            const SizedBox(height: 6),
            TextField(
              controller: _bannerSubCtrl,
              decoration: InputDecoration(
                hintText: 'e.g. 100% Pure Certified Organic Formulations',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 14),
            const Text('Banner Background Image', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _bannerImageCtrl,
                    decoration: InputDecoration(
                      hintText: 'Enter Image URL or Upload Image',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: () => _pickImage(_bannerImageCtrl, 'Banner Image'),
                  icon: const Icon(Icons.upload_file, size: 18),
                  label: const Text('Upload'),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF059669), foregroundColor: Colors.white),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 2. APP PAGES TAB
  Widget _buildAppPagesTab() {
    final pages = [
      {'name': 'Home Screen', 'route': '/', 'status': 'Active (Default)'},
      {'name': 'Shop Catalog Page', 'route': '/shop', 'status': 'Active'},
      {'name': 'Explore & Concerns', 'route': '/explore', 'status': 'Active'},
      {'name': 'Wishlist Page', 'route': '/wishlist', 'status': 'Active'},
      {'name': 'Cart & Checkout Screen', 'route': '/cart', 'status': 'Active'},
      {'name': 'Order History & Tracking', 'route': '/dashboard?tab=My%20Orders', 'status': 'Active'},
    ];

    return _buildSectionCard(
      title: 'App Screen Pages Manager',
      icon: Icons.description_outlined,
      child: ListView.separated(
        shrinkWrap: true,
        itemCount: pages.length,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (context, index) {
          final page = pages[index];
          return ListTile(
            leading: const Icon(Icons.smartphone_rounded, color: Color(0xFF059669)),
            title: Text(page['name']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            subtitle: Text(page['route']!, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: const Color(0xFFECFDF5), borderRadius: BorderRadius.circular(12)),
              child: Text(page['status']!, style: const TextStyle(color: Color(0xFF059669), fontSize: 11, fontWeight: FontWeight.bold)),
            ),
          );
        },
      ),
    );
  }

  // 3. APP CATEGORIES TAB
  Widget _buildAppCategoriesTab() {
    final categories = [
      {'name': 'Haircare & Oils', 'icon': '💇', 'badge': 'Hot'},
      {'name': 'Skincare & Serums', 'icon': '✨', 'badge': 'Popular'},
      {'name': 'Organic Soaps', 'icon': '🧴', 'badge': 'New'},
      {'name': 'Wellness Oils', 'icon': '🌿', 'badge': 'Best'},
      {'name': 'Radiance Elixirs', 'icon': '🌸', 'badge': 'Top'},
      {'name': 'Gift Combos', 'icon': '🎁', 'badge': 'Offer'},
    ];

    return _buildSectionCard(
      title: 'App Category Grid Manager',
      icon: Icons.grid_view_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SwitchListTile(
            title: const Text('Show Category Story Grid on App', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text('Displays circular category shortcuts on top of home screen'),
            value: _showCategoryGrid,
            activeColor: const Color(0xFF059669),
            onChanged: (val) => setState(() => _showCategoryGrid = val),
          ),
          const Divider(),
          ListView.builder(
            shrinkWrap: true,
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final cat = categories[index];
              return ListTile(
                leading: Text(cat['icon']!, style: const TextStyle(fontSize: 22)),
                title: Text(cat['name']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                trailing: Chip(
                  label: Text(cat['badge']!, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  backgroundColor: const Color(0xFF059669),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // 4. APP COLLECTIONS TAB
  Widget _buildAppCollectionsTab() {
    return _buildSectionCard(
      title: 'App Featured Collections & Curated Bundles',
      icon: Icons.layers_outlined,
      child: Column(
        children: [
          SwitchListTile(
            title: const Text('Show Hot Selling Products Section', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text('Displays top selling Ayurvedic product cards carousel on mobile app'),
            value: _showHotSelling,
            activeColor: const Color(0xFF059669),
            onChanged: (val) => setState(() => _showHotSelling = val),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.auto_awesome_rounded, color: Color(0xFFF59E0B)),
            title: const Text('Botanical Combos & Gift Bundles', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text('Featured on App Home Screen'),
            trailing: const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981)),
          ),
          ListTile(
            leading: const Icon(Icons.water_drop_rounded, color: Color(0xFF0284C7)),
            title: const Text('Pure Organic Herbal Oils', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text('Featured on Explore Screen'),
            trailing: const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981)),
          ),
        ],
      ),
    );
  }

  // 5. APP CONFIGURATIONS TAB
  Widget _buildAppConfigurationsTab() {
    return SingleChildScrollView(
      child: _buildSectionCard(
        title: 'App General Configurations & Support',
        icon: Icons.settings_suggest_outlined,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Mobile App Display Name', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
            const SizedBox(height: 6),
            TextField(
              controller: _appNameCtrl,
              decoration: InputDecoration(hintText: 'e.g. Vaidyam Mobile', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 14),
            const Text('Search Bar Placeholder Hint', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
            const SizedBox(height: 6),
            TextField(
              controller: _searchHintCtrl,
              decoration: InputDecoration(hintText: 'e.g. Search in Ayurveda...', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 14),
            SwitchListTile(
              title: const Text('Show Top Announcement Marquee Bar', style: TextStyle(fontWeight: FontWeight.bold)),
              value: _showAnnouncement,
              activeColor: const Color(0xFF059669),
              onChanged: (val) => setState(() => _showAnnouncement = val),
            ),
            if (_showAnnouncement) ...[
              TextField(
                controller: _announcementCtrl,
                decoration: InputDecoration(labelText: 'Announcement Message', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 14),
            ],
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Helpline Phone', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      TextField(controller: _phoneCtrl, decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)))),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('WhatsApp Support', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      TextField(controller: _whatsappCtrl, decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)))),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 6. BOTTOM NAVIGATION TAB
  Widget _buildBottomNavTab() {
    final tabs = [
      {'title': 'Home', 'icon': Icons.home_rounded, 'route': '/'},
      {'title': 'Explore', 'icon': Icons.grid_view_rounded, 'route': '/explore'},
      {'title': 'Wishlist', 'icon': Icons.favorite_border_rounded, 'route': '/wishlist'},
      {'title': 'Account', 'icon': Icons.person_outline_rounded, 'route': '/account'},
    ];

    return _buildSectionCard(
      title: 'App Bottom Navigation Menu Manager',
      icon: Icons.format_list_bulleted_rounded,
      child: ListView.separated(
        shrinkWrap: true,
        itemCount: tabs.length,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (context, index) {
          final tab = tabs[index];
          return ListTile(
            leading: Icon(tab['icon'] as IconData, color: const Color(0xFF059669)),
            title: Text(tab['title'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            subtitle: Text('Navigates to ${tab['route']}', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
            trailing: const Icon(Icons.check_circle, color: Color(0xFF10B981)),
          );
        },
      ),
    );
  }

  // 7. PUSH NOTIFICATIONS TAB
  Widget _buildPushNotificationsTab() {
    return SingleChildScrollView(
      child: _buildSectionCard(
        title: 'Send Push Notifications to App Users',
        icon: Icons.notifications_active_outlined,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Push Title', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            TextField(controller: _pushTitleCtrl, decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)))),
            const SizedBox(height: 14),
            const Text('Push Notification Body Text', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            TextField(controller: _pushBodyCtrl, maxLines: 3, decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)))),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('🚀 Push notification broadcasted to all mobile app users!'), backgroundColor: Color(0xFF10B981)),
                );
              },
              icon: const Icon(Icons.send_rounded, size: 18),
              label: const Text('Broadcast Push Notification'),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF059669), foregroundColor: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  // 8. APP VERSION TAB
  Widget _buildAppVersionTab() {
    return _buildSectionCard(
      title: 'App Version & Release Control',
      icon: Icons.system_update_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ListTile(
            leading: Icon(Icons.verified_rounded, color: Color(0xFF10B981), size: 28),
            title: Text('Current Release Version: v2.4.0 (Build 104)', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('Target Android SDK: 34 • Release Status: Published'),
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            title: const Text('Enforce Mandatory In-App Update', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text('Prompts app users to update immediately when a new build is available'),
            value: false,
            onChanged: (val) {},
          ),
        ],
      ),
    );
  }

  // 9. SPLASH & ONBOARDING TAB
  Widget _buildSplashOnboardingTab() {
    return _buildSectionCard(
      title: 'Splash Screen & Onboarding Screens',
      icon: Icons.smartphone_rounded,
      child: Column(
        children: const [
          ListTile(
            leading: Icon(Icons.local_florist_rounded, color: Color(0xFF059669), size: 28),
            title: Text('App Splash Screen Logo', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('Displays Vaidyam Botanicals leaf logo with elegant fade animation'),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.auto_awesome, color: Color(0xFFF59E0B), size: 28),
            title: Text('Onboarding Slide 1: 100% Pure Ayurveda', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('Certified Organic Formulations & Natural Extracts'),
          ),
        ],
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
              Icon(icon, color: const Color(0xFF059669), size: 22),
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

  // ── LIVE MOBILE APP SCREEN PREVIEW SIMULATOR ──
  Widget _buildLiveMobileAppPreview(MobileAppSettings settings) {
    final String bannerTitle = _bannerTitleCtrl.text.trim().isNotEmpty ? _bannerTitleCtrl.text.trim() : settings.bannerTitle;
    final String bannerDiscount = _bannerDiscountCtrl.text.trim().isNotEmpty ? _bannerDiscountCtrl.text.trim() : settings.bannerDiscountTag;
    final String announcement = _announcementCtrl.text.trim().isNotEmpty ? _announcementCtrl.text.trim() : settings.announcementBarText;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: const Color(0xFF334155), width: 6),
        boxShadow: const [BoxShadow(color: Color(0x33000000), blurRadius: 20, offset: Offset(0, 8))],
      ),
      child: Column(
        children: [
          // Speaker notch
          Container(
            width: 70,
            height: 6,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(color: const Color(0xFF334155), borderRadius: BorderRadius.circular(3)),
          ),

          // Mobile App Screen Container
          Container(
            height: 520,
            decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(20)),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Announcement Bar
                if (_showAnnouncement)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    color: const Color(0xFF059669),
                    child: Text(
                      announcement,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                // Mobile Header
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  color: Colors.white,
                  child: Row(
                    children: [
                      const Icon(Icons.menu, size: 18, color: Color(0xFF0F172A)),
                      const SizedBox(width: 8),
                      const CircleAvatar(radius: 10, backgroundColor: Color(0xFF059669), child: Icon(Icons.local_florist, color: Colors.white, size: 12)),
                      const SizedBox(width: 6),
                      Text(_appNameCtrl.text.trim().isNotEmpty ? _appNameCtrl.text.trim() : 'Vaidyam', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      const Spacer(),
                      const Icon(Icons.shopping_cart_outlined, size: 18, color: Color(0xFF0F172A)),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Search bar
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFE2E8F0))),
                          child: Row(
                            children: [
                              const Icon(Icons.search, size: 14, color: Color(0xFF94A3B8)),
                              const SizedBox(width: 6),
                              Text(_searchHintCtrl.text.trim().isNotEmpty ? _searchHintCtrl.text.trim() : 'Search...', style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Hero Banner preview
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [Color(0xFF059669), Color(0xFF047857)]),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
                                child: Text(bannerDiscount, style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Color(0xFF059669))),
                              ),
                              const SizedBox(height: 6),
                              Text(bannerTitle, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),

                        if (_showCategoryGrid) ...[
                          const Text('Categories', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: const [
                              _PreviewCategoryBubble('Haircare', '💇'),
                              _PreviewCategoryBubble('Skincare', '✨'),
                              _PreviewCategoryBubble('Soaps', '🧴'),
                              _PreviewCategoryBubble('Oils', '🌿'),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                // Mobile Bottom Bar preview
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  color: Colors.white,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: const [
                      Icon(Icons.home, size: 18, color: Color(0xFF059669)),
                      Icon(Icons.grid_view, size: 18, color: Color(0xFF94A3B8)),
                      Icon(Icons.favorite_border, size: 18, color: Color(0xFF94A3B8)),
                      Icon(Icons.person_outline, size: 18, color: Color(0xFF94A3B8)),
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

class _PreviewCategoryBubble extends StatelessWidget {
  final String title;
  final String icon;

  const _PreviewCategoryBubble(this.title, this.icon);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(radius: 14, backgroundColor: const Color(0xFFECFDF5), child: Text(icon, style: const TextStyle(fontSize: 12))),
        const SizedBox(height: 2),
        Text(title, style: const TextStyle(fontSize: 8, color: Color(0xFF334155))),
      ],
    );
  }
}
