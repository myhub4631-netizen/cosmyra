import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  // Controllers for general mobile settings
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
  late TextEditingController _searchBannersCtrl;
  late TextEditingController _deepLinkCtrl;

  late bool _showAnnouncement;
  late bool _showHotSelling;
  late bool _showCategoryGrid;

  // Banner Filter State
  String _selectedStatusFilter = 'All Status';
  String _selectedPlacementFilter = 'All Placement';
  String _displayForTarget = 'All Users';
  bool _targetAndroid = true;
  bool _targetIOS = true;
  bool _autoRotate = true;
  int _rotateSeconds = 4;
  int _placementLimit = 5;

  // Sample App Banners Data matching user's screenshot 1-to-1
  List<Map<String, dynamic>> _bannersList = [
    {
      'id': 'b-1',
      'title': 'Great Deals on Ayurvedic & Skincare',
      'subtitle': 'Up to 60% OFF • Shop Now',
      'placement': 'Home - Carousel',
      'status': 'Active',
      'priority': 1,
      'schedule': '16 May - 31 May 2024',
      'impressions': '12,456',
      'bgGradient': [const Color(0xFF065F46), const Color(0xFF047857)],
      'tagText': 'Up to 60% OFF',
    },
    {
      'id': 'b-2',
      'title': '100% Pure & Natural Products',
      'subtitle': 'For Healthy & Glowing Skin',
      'placement': 'Home - Carousel',
      'status': 'Active',
      'priority': 2,
      'schedule': '16 May - 30 May 2024',
      'impressions': '9,856',
      'bgGradient': [const Color(0xFFFFF7ED), const Color(0xFFFFEDD5)],
      'tagText': '100% Organic',
    },
    {
      'id': 'b-3',
      'title': 'New Arrivals This Week',
      'subtitle': 'Explore Our Latest Collection',
      'placement': 'Home - Carousel',
      'status': 'Scheduled',
      'priority': 3,
      'schedule': '20 May - 05 Jun 2024',
      'impressions': '- Not started',
      'bgGradient': [const Color(0xFFEFF6FF), const Color(0xFFDBEAFE)],
      'tagText': 'NEW',
    },
    {
      'id': 'b-4',
      'title': 'Flat 20% OFF on All Oils',
      'subtitle': 'Limited Time Offer',
      'placement': 'Category Top',
      'status': 'Inactive',
      'priority': 4,
      'schedule': '-',
      'impressions': '2,145',
      'bgGradient': [const Color(0xFFFEF2F2), const Color(0xFFFEE2E2)],
      'tagText': '20% OFF',
    },
    {
      'id': 'b-5',
      'title': 'Free Shipping on Orders above ₹999',
      'subtitle': 'Shop More, Save More',
      'placement': 'Bottom Banner',
      'status': 'Active',
      'priority': 5,
      'schedule': '16 May - 31 May 2024',
      'impressions': '4,105',
      'bgGradient': [const Color(0xFFEEF2FF), const Color(0xFFE0E7FF)],
      'tagText': 'FREE DELIVERY',
    },
  ];

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
    _searchBannersCtrl = TextEditingController();
    _deepLinkCtrl = TextEditingController();

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
    _searchBannersCtrl.dispose();
    _deepLinkCtrl.dispose();
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
          content: Text('✅ App Content Manager settings saved successfully!'),
          backgroundColor: Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showAddBannerModal([Map<String, dynamic>? existingBanner]) {
    final titleCtrl = TextEditingController(text: existingBanner?['title'] ?? '');
    final subCtrl = TextEditingController(text: existingBanner?['subtitle'] ?? '');
    final tagCtrl = TextEditingController(text: existingBanner?['tagText'] ?? 'Special Offer');
    String placement = existingBanner?['placement'] ?? 'Home - Carousel';
    String status = existingBanner?['status'] ?? 'Active';
    int priority = existingBanner?['priority'] ?? (_bannersList.length + 1);

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dialogCtx, setStateModal) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Row(
                children: [
                  const Icon(Icons.add_photo_alternate_rounded, color: Color(0xFF10B981)),
                  const SizedBox(width: 10),
                  Text(existingBanner != null ? 'Edit App Banner' : 'Create New App Banner', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                ],
              ),
              content: SizedBox(
                width: 500,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Banner Title', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(height: 6),
                      TextField(controller: titleCtrl, decoration: InputDecoration(hintText: 'e.g. Great Deals on Skincare', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)))),
                      const SizedBox(height: 14),
                      const Text('Banner Subtitle / Offer Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(height: 6),
                      TextField(controller: subCtrl, decoration: InputDecoration(hintText: 'e.g. Up to 60% OFF • Shop Now', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)))),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Placement', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                const SizedBox(height: 6),
                                DropdownButtonFormField<String>(
                                  value: placement,
                                  decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)), contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
                                  items: ['Home - Carousel', 'Category Top', 'Bottom Banner']
                                      .map((p) => DropdownMenuItem(value: p, child: Text(p, style: const TextStyle(fontSize: 13))))
                                      .toList(),
                                  onChanged: (val) => setStateModal(() => placement = val!),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Status', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                const SizedBox(height: 6),
                                DropdownButtonFormField<String>(
                                  value: status,
                                  decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)), contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
                                  items: ['Active', 'Scheduled', 'Inactive']
                                      .map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(fontSize: 13))))
                                      .toList(),
                                  onChanged: (val) => setStateModal(() => status = val!),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      const Text('Promo Tag Pill Text', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(height: 6),
                      TextField(controller: tagCtrl, decoration: InputDecoration(hintText: 'e.g. FLAT 30% OFF', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)))),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                ElevatedButton.icon(
                  onPressed: () {
                    final title = titleCtrl.text.trim();
                    if (title.isEmpty) return;

                    setState(() {
                      if (existingBanner != null) {
                        existingBanner['title'] = title;
                        existingBanner['subtitle'] = subCtrl.text.trim();
                        existingBanner['tagText'] = tagCtrl.text.trim();
                        existingBanner['placement'] = placement;
                        existingBanner['status'] = status;
                      } else {
                        _bannersList.add({
                          'id': 'b-${DateTime.now().millisecondsSinceEpoch}',
                          'title': title,
                          'subtitle': subCtrl.text.trim(),
                          'placement': placement,
                          'status': status,
                          'priority': priority,
                          'schedule': '16 May - 31 May 2024',
                          'impressions': '0',
                          'bgGradient': [const Color(0xFF059669), const Color(0xFF047857)],
                          'tagText': tagCtrl.text.trim(),
                        });
                      }
                    });
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(existingBanner != null ? 'Banner updated!' : 'New App Banner added! 🎉'), backgroundColor: const Color(0xFF10B981)),
                    );
                  },
                  icon: const Icon(Icons.check, size: 18),
                  label: Text(existingBanner != null ? 'Update Banner' : 'Create Banner'),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), foregroundColor: Colors.white),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── SEGMENTED TAB BAR FOR ALL 9 SECTIONS ──
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              labelColor: const Color(0xFF10B981),
              unselectedLabelColor: const Color(0xFF64748B),
              indicatorColor: const Color(0xFF10B981),
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

          // Render active tab view
          _tabController.index == 0
              ? _buildAdvancedAppBannersPage()
              : IndexedStack(
                  index: _tabController.index,
                  children: [
                    const SizedBox.shrink(),
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
        ],
      ),
    );
  }

  // ── ADVANCED APP BANNERS PAGE (MATCHING SCREENSHOT 1-TO-1) ──
  Widget _buildAdvancedAppBannersPage() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth > 1100;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. 6 TOP ANALYTICS METRIC CARDS (KPI ROW)
        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final cardWidth = width > 1100
                ? (width - 60) / 6
                : width > 700
                    ? (width - 24) / 3
                    : (width - 12) / 2;

            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildKpiCard('Total Banners', '12', 'Active', Icons.auto_graph_rounded, const Color(0xFFECFDF5), const Color(0xFF10B981), cardWidth),
                _buildKpiCard('Impressions', '48,562', '18.6% vs last 7 days', Icons.show_chart_rounded, const Color(0xFFECFDF5), const Color(0xFF10B981), cardWidth),
                _buildKpiCard('Clicks', '12,845', '22.4% vs last 7 days', Icons.show_chart_rounded, const Color(0xFFF3E8FF), const Color(0xFF8B5CF6), cardWidth),
                _buildKpiCard('CTR', '26.47%', '3.2% vs last 7 days', Icons.trending_up_rounded, const Color(0xFFE0F2FE), const Color(0xFF0284C7), cardWidth),
                _buildKpiCard('Active on App', 'All Users', 'Visibility', Icons.check_circle_outline_rounded, const Color(0xFFECFDF5), const Color(0xFF10B981), cardWidth),
                _buildKpiCard('Last Updated', '16 May 2024', '10:28 AM', Icons.access_time_rounded, const Color(0xFFF3E8FF), const Color(0xFF8B5CF6), cardWidth),
              ],
            );
          },
        ),

        const SizedBox(height: 24),

        // 2. MANAGE APP BANNERS DATA TABLE & ACTION BAR CARD
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: const [BoxShadow(color: Color(0x06000000), blurRadius: 10, offset: Offset(0, 2))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row with Title & "Add New Banner" Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('Manage App Banners', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
                      SizedBox(height: 4),
                      Text('Create, edit and manage banners & promotional offers', style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                    ],
                  ),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => _showAddBannerModal(),
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Add New Banner', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          elevation: 0,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFE2E8F0))),
                        child: Row(
                          children: const [
                            Icon(Icons.grid_view_rounded, size: 16, color: Color(0xFF64748B)),
                            SizedBox(width: 4),
                            Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: Color(0xFF64748B)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Search & Filter Action Bar
              Row(
                children: [
                  // Search Banners Input
                  Expanded(
                    flex: 3,
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFE2E8F0))),
                      child: Row(
                        children: [
                          const Padding(padding: EdgeInsets.symmetric(horizontal: 10), child: Icon(Icons.search, size: 16, color: Color(0xFF94A3B8))),
                          Expanded(
                            child: TextField(
                              controller: _searchBannersCtrl,
                              decoration: const InputDecoration(hintText: 'Search banners...', hintStyle: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)), border: InputBorder.none, isDense: true),
                              onChanged: (_) => setState(() {}),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Status Filter Dropdown
                  Container(
                    height: 40,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFE2E8F0))),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedStatusFilter,
                        style: const TextStyle(fontSize: 12, color: Color(0xFF334155), fontWeight: FontWeight.w600),
                        items: ['All Status', 'Active', 'Scheduled', 'Inactive'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                        onChanged: (val) => setState(() => _selectedStatusFilter = val!),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Placement Filter Dropdown
                  Container(
                    height: 40,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFE2E8F0))),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedPlacementFilter,
                        style: const TextStyle(fontSize: 12, color: Color(0xFF334155), fontWeight: FontWeight.w600),
                        items: ['All Placement', 'Home - Carousel', 'Category Top', 'Bottom Banner'].map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                        onChanged: (val) => setState(() => _selectedPlacementFilter = val!),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Filter Button
                  OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.filter_list_rounded, size: 16, color: Color(0xFF334155)),
                    label: const Text('Filter', style: TextStyle(color: Color(0xFF334155), fontWeight: FontWeight.bold, fontSize: 13)),
                    style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10), side: const BorderSide(color: Color(0xFFE2E8F0)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Banners Data Table
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: 24,
                  horizontalMargin: 0,
                  headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
                  columns: const [
                    DataColumn(label: Text('Banner', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF64748B)))),
                    DataColumn(label: Text('Title & Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF64748B)))),
                    DataColumn(label: Text('Placement', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF64748B)))),
                    DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF64748B)))),
                    DataColumn(label: Text('Priority', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF64748B)))),
                    DataColumn(label: Text('Schedule', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF64748B)))),
                    DataColumn(label: Text('Performance', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF64748B)))),
                    DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF64748B)))),
                  ],
                  rows: _bannersList.map((banner) {
                    final status = banner['status'] as String;
                    final Color statusBg = status == 'Active' ? const Color(0xFFECFDF5) : (status == 'Scheduled' ? const Color(0xFFFFFBEB) : const Color(0xFFF1F5F9));
                    final Color statusFg = status == 'Active' ? const Color(0xFF10B981) : (status == 'Scheduled' ? const Color(0xFFF59E0B) : const Color(0xFF64748B));

                    return DataRow(
                      cells: [
                        // Banner Thumbnail
                        DataCell(
                          Container(
                            width: 80,
                            height: 42,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(colors: banner['bgGradient'] as List<Color>),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                banner['tagText'] as String,
                                style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                        // Title & Details
                        DataCell(
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(banner['title'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A))),
                              const SizedBox(height: 2),
                              Text(banner['subtitle'] as String, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                            ],
                          ),
                        ),
                        // Placement
                        DataCell(Text(banner['placement'] as String, style: const TextStyle(fontSize: 12, color: Color(0xFF334155)))),
                        // Status Badge
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(12)),
                            child: Text(status, style: TextStyle(color: statusFg, fontSize: 11, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        // Priority Badge
                        DataCell(
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(6)),
                            child: Center(child: Text('${banner['priority']}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF475569)))),
                          ),
                        ),
                        // Schedule Date Range
                        DataCell(Text(banner['schedule'] as String, style: const TextStyle(fontSize: 12, color: Color(0xFF475569)))),
                        // Performance Metrics
                        DataCell(
                          Row(
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(banner['impressions'] as String, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                                  if (banner['impressions'] != '- Not started') const Text('Impressions', style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
                                ],
                              ),
                              if (banner['impressions'] != '- Not started') ...[
                                const SizedBox(width: 8),
                                const Icon(Icons.show_chart_rounded, size: 16, color: Color(0xFF10B981)),
                              ],
                            ],
                          ),
                        ),
                        // Action Icon Buttons: View, Edit, Duplicate, Options
                        DataCell(
                          Row(
                            children: [
                              IconButton(icon: const Icon(Icons.visibility_outlined, size: 16, color: Color(0xFF64748B)), onPressed: () {}),
                              IconButton(icon: const Icon(Icons.edit_outlined, size: 16, color: Color(0xFF64748B)), onPressed: () => _showAddBannerModal(banner)),
                              IconButton(icon: const Icon(Icons.content_copy_rounded, size: 16, color: Color(0xFF64748B)), onPressed: () {}),
                              IconButton(
                                icon: const Icon(Icons.more_vert_rounded, size: 16, color: Color(0xFF64748B)),
                                onPressed: () {
                                  setState(() {
                                    _bannersList.removeWhere((b) => b['id'] == banner['id']);
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 16),

              // Table Pagination Footer Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Showing 1 to ${_bannersList.length} of 12 banners', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(6), border: Border.all(color: const Color(0xFFE2E8F0))),
                        child: Row(
                          children: const [
                            Text('5 / page', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
                            SizedBox(width: 4),
                            Icon(Icons.keyboard_arrow_down, size: 14, color: Color(0xFF64748B)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Row(
                        children: [
                          _buildPageBtn('<', false),
                          _buildPageBtn('1', true),
                          _buildPageBtn('2', false),
                          _buildPageBtn('3', false),
                          _buildPageBtn('>', false),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 28),

        // 3. BOTTOM 3 COLUMNS: ADVANCED SETTINGS, PERFORMANCE OVERVIEW, QUICK ACTIONS
        if (isWide)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 4, child: _buildAdvancedSettingsCard()),
              const SizedBox(width: 20),
              Expanded(flex: 4, child: _buildPerformanceOverviewCard()),
              const SizedBox(width: 20),
              Expanded(flex: 3, child: _buildQuickActionsCard()),
            ],
          )
        else ...[
          _buildAdvancedSettingsCard(),
          const SizedBox(height: 20),
          _buildPerformanceOverviewCard(),
          const SizedBox(height: 20),
          _buildQuickActionsCard(),
        ],

        const SizedBox(height: 36),

        // Footer Copyright Notice
        const Center(
          child: Text('© 2024 Vaidyam Botanicals. All rights reserved.', style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
        ),
      ],
    );
  }

  // ── KPI STAT CARD WIDGET ──
  Widget _buildKpiCard(String title, String value, String trend, IconData icon, Color iconBg, Color iconColor, double width) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: const [BoxShadow(color: Color(0x06000000), blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
              Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(8)), child: Icon(icon, color: iconColor, size: 14)),
            ],
          ),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(icon, size: 12, color: iconColor),
              const SizedBox(width: 4),
              Text(trend, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: iconColor)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPageBtn(String text, bool active) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: active ? const Color(0xFF10B981) : Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: active ? const Color(0xFF10B981) : const Color(0xFFE2E8F0)),
      ),
      child: Text(text, style: TextStyle(color: active ? Colors.white : const Color(0xFF475569), fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }

  // ── COLUMN 1: ADVANCED SETTINGS CARD ──
  Widget _buildAdvancedSettingsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Advanced Settings', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
          const SizedBox(height: 4),
          const Text('Configure banner behavior and targeting', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
          const SizedBox(height: 16),

          // Display For Targets
          const Text('Display For', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
          const SizedBox(height: 6),
          Row(
            children: ['All Users', 'Logged In Users', 'New Users'].map((target) {
              final isSelected = _displayForTarget == target;
              return GestureDetector(
                onTap: () => setState(() => _displayForTarget = target),
                child: Container(
                  margin: const EdgeInsets.only(right: 12),
                  child: Row(
                    children: [
                      Icon(isSelected ? Icons.radio_button_checked : Icons.radio_button_off, size: 16, color: isSelected ? const Color(0xFF10B981) : const Color(0xFF94A3B8)),
                      const SizedBox(width: 4),
                      Text(target, style: const TextStyle(fontSize: 12, color: Color(0xFF334155))),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 16),

          // Device Target Checkboxes
          const Text('Device', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
          const SizedBox(height: 6),
          Row(
            children: [
              Checkbox(value: _targetAndroid, activeColor: const Color(0xFF10B981), onChanged: (val) => setState(() => _targetAndroid = val!)),
              const Text('Android', style: TextStyle(fontSize: 12)),
              const SizedBox(width: 16),
              Checkbox(value: _targetIOS, activeColor: const Color(0xFF10B981), onChanged: (val) => setState(() => _targetIOS = val!)),
              const Text('iOS', style: TextStyle(fontSize: 12)),
            ],
          ),

          const SizedBox(height: 14),

          // Placement Limit
          Row(
            children: [
              const Text('Placement Limit', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
              const SizedBox(width: 12),
              Container(
                width: 50,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(6), border: Border.all(color: const Color(0xFFE2E8F0))),
                child: Text('$_placementLimit', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 8),
              const Expanded(child: Text('Max banners to show in carousel', style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)))),
            ],
          ),

          const SizedBox(height: 14),

          // Auto Rotate Toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text('Auto Rotate', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
                  const SizedBox(width: 12),
                  Switch(value: _autoRotate, activeColor: const Color(0xFF10B981), onChanged: (val) => setState(() => _autoRotate = val)),
                ],
              ),
              if (_autoRotate)
                Row(
                  children: [
                    const Text('Change banner every ', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(6), border: Border.all(color: const Color(0xFFE2E8F0))),
                      child: Text('$_rotateSeconds sec', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
            ],
          ),

          const SizedBox(height: 14),

          // Deep Link Input
          const Text('Deep Link (Optional)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
          const SizedBox(height: 6),
          TextField(
            controller: _deepLinkCtrl,
            decoration: InputDecoration(
              hintText: 'Enter deep link or URL',
              hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          ),
          const SizedBox(height: 4),
          const Text('Leave blank to open default screen', style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
        ],
      ),
    );
  }

  // ── COLUMN 2: PERFORMANCE OVERVIEW CARD ──
  Widget _buildPerformanceOverviewCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Performance Overview', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
          const SizedBox(height: 4),
          const Text('Banner performance analytics', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
          const SizedBox(height: 16),

          // 4 Metric Stat Badges Row
          Row(
            children: [
              Expanded(child: _buildMiniPerfStat('Total Impressions', '48,562', '18.6% vs last 7 days', const Color(0xFF10B981))),
              const SizedBox(width: 8),
              Expanded(child: _buildMiniPerfStat('Total Clicks', '12,845', '22.4% vs last 7 days', const Color(0xFF8B5CF6))),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _buildMiniPerfStat('CTR', '26.47%', '3.2% vs last 7 days', const Color(0xFF0284C7))),
              const SizedBox(width: 8),
              Expanded(child: _buildMiniPerfStat('Conversions', '2,145', '15.8% vs last 7 days', const Color(0xFFF59E0B))),
            ],
          ),

          const SizedBox(height: 18),

          // Dual Trend Visual Sparkline Container
          Container(
            height: 130,
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFF1F5F9))),
            child: CustomPaint(
              painter: DualChartPainter(),
            ),
          ),

          const SizedBox(height: 14),

          // Donut Chart Top Performing Banners
          Row(
            children: [
              const Text('Top Performing Banners', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
              const Spacer(),
              _buildLegendDot('Banner 1 (42%)', const Color(0xFF10B981)),
              const SizedBox(width: 8),
              _buildLegendDot('Banner 2 (28%)', const Color(0xFF0284C7)),
              const SizedBox(width: 8),
              _buildLegendDot('Banner 3 (18%)', const Color(0xFF8B5CF6)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniPerfStat(String title, String value, String trend, Color color) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(10), border: Border.all(color: color.withValues(alpha: 0.15))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
          const SizedBox(height: 2),
          Text('↑ $trend', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildLegendDot(String label, Color color) {
    return Row(
      children: [
        CircleAvatar(radius: 4, backgroundColor: color),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 10, color: Color(0xFF64748B))),
      ],
    );
  }

  // ── COLUMN 3: QUICK ACTIONS & PRO TIP CARD ──
  Widget _buildQuickActionsCard() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Quick Actions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
              const SizedBox(height: 14),
              _buildQuickActionTile('Add New Banner', Icons.add_rounded, () => _showAddBannerModal()),
              _buildQuickActionTile('Bulk Upload Banners', Icons.upload_file_rounded, () {}),
              _buildQuickActionTile('Reorder Banners', Icons.swap_vert_rounded, () {}),
              _buildQuickActionTile('Banner Templates', Icons.style_outlined, () {}),
              _buildQuickActionTile('Export Performance', Icons.download_rounded, () {}),
            ],
          ),
        ),
        const SizedBox(height: 14),
        // Tip Box (Light purple background)
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFF3E8FF),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFDDD6FE)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Icon(Icons.lightbulb_outline_rounded, color: Color(0xFF8B5CF6), size: 20),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Tip', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF6D28D9))),
                    SizedBox(height: 2),
                    Text(
                      'Keep banners fresh and engaging. We recommend updating banners every 2 weeks for better results.',
                      style: TextStyle(fontSize: 11, color: Color(0xFF5B21B6)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionTile(String label, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: const Color(0xFFECFDF5), borderRadius: BorderRadius.circular(6)), child: Icon(icon, color: const Color(0xFF10B981), size: 16)),
            const SizedBox(width: 10),
            Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
          ],
        ),
      ),
    );
  }

  // ── SUB-TABS 1 TO 8 IMPLEMENTATION ──
  Widget _buildAppPagesTab() {
    final pages = [
      {'name': 'Home Screen', 'route': '/', 'status': 'Active'},
      {'name': 'Shop Catalog Page', 'route': '/shop', 'status': 'Active'},
      {'name': 'Explore & Concerns', 'route': '/explore', 'status': 'Active'},
      {'name': 'Wishlist Page', 'route': '/wishlist', 'status': 'Active'},
      {'name': 'Cart & Checkout Screen', 'route': '/cart', 'status': 'Active'},
      {'name': 'Order History & Tracking', 'route': '/dashboard?tab=My%20Orders', 'status': 'Active'},
    ];
    return _buildTabContainer('App Pages Manager', Icons.description_outlined, pages);
  }

  Widget _buildAppCategoriesTab() {
    final categories = [
      {'name': 'Haircare & Oils', 'route': '💇', 'status': 'Hot'},
      {'name': 'Skincare & Serums', 'route': '✨', 'status': 'Popular'},
      {'name': 'Organic Soaps', 'route': '🧴', 'status': 'New'},
      {'name': 'Wellness Oils', 'route': '🌿', 'status': 'Best'},
    ];
    return _buildTabContainer('App Categories Grid Manager', Icons.grid_view_rounded, categories);
  }

  Widget _buildAppCollectionsTab() {
    final collections = [
      {'name': 'Botanical Combos & Gift Bundles', 'route': 'Featured', 'status': 'Active'},
      {'name': 'Pure Organic Herbal Oils', 'route': 'Top Oils', 'status': 'Active'},
    ];
    return _buildTabContainer('App Featured Collections & Curated Bundles', Icons.layers_outlined, collections);
  }

  Widget _buildAppConfigurationsTab() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('App Configurations & Support', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          TextField(controller: _appNameCtrl, decoration: InputDecoration(labelText: 'Mobile App Display Name', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)))),
          const SizedBox(height: 14),
          TextField(controller: _searchHintCtrl, decoration: InputDecoration(labelText: 'Search Bar Placeholder Hint', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)))),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: TextField(controller: _phoneCtrl, decoration: InputDecoration(labelText: 'Helpline Phone', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))))),
              const SizedBox(width: 12),
              Expanded(child: TextField(controller: _whatsappCtrl, decoration: InputDecoration(labelText: 'WhatsApp Support', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavTab() {
    final tabs = [
      {'name': 'Home Tab', 'route': '/', 'status': 'Active'},
      {'name': 'Explore Tab', 'route': '/explore', 'status': 'Active'},
      {'name': 'Wishlist Tab', 'route': '/wishlist', 'status': 'Active'},
      {'name': 'Account Tab', 'route': '/account', 'status': 'Active'},
    ];
    return _buildTabContainer('App Bottom Navigation Menu Manager', Icons.format_list_bulleted_rounded, tabs);
  }

  Widget _buildPushNotificationsTab() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Send Push Notifications', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 14),
          TextField(controller: _pushTitleCtrl, decoration: InputDecoration(labelText: 'Push Title', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)))),
          const SizedBox(height: 14),
          TextField(controller: _pushBodyCtrl, maxLines: 3, decoration: InputDecoration(labelText: 'Push Body', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)))),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('🚀 Push Notification broadcasted to all mobile app users!'), backgroundColor: Color(0xFF10B981)));
            },
            icon: const Icon(Icons.send_rounded, size: 18),
            label: const Text('Broadcast Notification'),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), foregroundColor: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildAppVersionTab() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text('App Version & Release Control', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          SizedBox(height: 12),
          Text('Current Release: v2.4.0 (Build 104) • Status: Published'),
        ],
      ),
    );
  }

  Widget _buildSplashOnboardingTab() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text('Splash & Onboarding Screens', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          SizedBox(height: 12),
          Text('Configure App Splash Screen Logo & Onboarding slides.'),
        ],
      ),
    );
  }

  Widget _buildTabContainer(String title, IconData icon, List<Map<String, String>> items) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [Icon(icon, color: const Color(0xFF10B981)), const SizedBox(width: 10), Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))]),
          const SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            itemCount: items.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final item = items[index];
              return ListTile(
                title: Text(item['name']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                subtitle: Text(item['route']!, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                trailing: Chip(label: Text(item['status']!, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)), backgroundColor: const Color(0xFF10B981)),
              );
            },
          ),
        ],
      ),
    );
  }
}

// Custom Painter for Dual Trend Sparkline Chart
class DualChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final greenPaint = Paint()
      ..color = const Color(0xFF10B981)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    final purplePaint = Paint()
      ..color = const Color(0xFF8B5CF6)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    final path1 = Path();
    path1.moveTo(0, size.height * 0.7);
    path1.cubicTo(size.width * 0.2, size.height * 0.2, size.width * 0.4, size.height * 0.8, size.width * 0.6, size.height * 0.3);
    path1.cubicTo(size.width * 0.8, size.height * 0.6, size.width * 0.9, size.height * 0.1, size.width, size.height * 0.4);

    final path2 = Path();
    path2.moveTo(0, size.height * 0.85);
    path2.cubicTo(size.width * 0.2, size.height * 0.5, size.width * 0.4, size.height * 0.9, size.width * 0.6, size.height * 0.5);
    path2.cubicTo(size.width * 0.8, size.height * 0.8, size.width * 0.9, size.height * 0.3, size.width, size.height * 0.6);

    canvas.drawPath(path1, greenPaint);
    canvas.drawPath(path2, purplePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
