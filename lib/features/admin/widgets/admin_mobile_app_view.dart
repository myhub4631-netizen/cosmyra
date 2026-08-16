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
  late TextEditingController _searchCategoriesCtrl;
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

  // ── APP PAGES EDITOR STATE ──
  String _selectedPageName = 'Home Screen';
  int _selectedSectionIndex = 0;
  String _sectionEditorTab = 'Content';
  String _sliderType = 'Image Slider';
  final TextEditingController _sectionTitleCtrl = TextEditingController(text: 'Top Banner Slider');
  bool _sliderAutoPlay = true;
  int _sliderInterval = 3;
  bool _sliderShowDots = true;
  bool _sliderShowArrows = false;
  bool _sliderInfiniteLoop = true;
  String _sectionStatus = 'Active';
  String _sectionVisibleFor = 'All Users';
  bool _sectionAndroid = true;
  bool _sectionIOS = true;
  String _sectionPlacement = 'Top of Page';
  int _sectionPriority = 1;

  // ── APP CATEGORIES SECTION STATE ──
  String _categoryStatusFilter = 'All Status';
  String _categoryTypeFilter = 'All Type';
  bool _showCategoryIcons = true;
  bool _enableCategoryBadges = true;
  bool _showProductCount = false;
  String _categoryImageRatio = '1:1 (Square)';

  String _hotBadgeColor = '#FF4D4F';
  String _popularBadgeColor = '#FA8C16';
  String _newBadgeColor = '#1890FF';
  String _bestBadgeColor = '#52C41A';

  List<Map<String, dynamic>> _categoriesList = [
    {
      'id': 'cat-1',
      'name': 'Haircare & Oils',
      'slug': '/haircare-oils',
      'type': 'Hot',
      'products': 86,
      'status': 'Active',
      'visibility': 'Visible',
      'order': 1,
      'updated': '16 May 2024 10:28 AM',
      'icon': Icons.face_retouching_natural_rounded,
      'color': const Color(0xFFFEF3C7),
    },
    {
      'id': 'cat-2',
      'name': 'Skincare & Serums',
      'slug': '/skincare-serums',
      'type': 'Popular',
      'products': 72,
      'status': 'Active',
      'visibility': 'Visible',
      'order': 2,
      'updated': '16 May 2024 09:15 AM',
      'icon': Icons.auto_awesome_rounded,
      'color': const Color(0xFFFEE2E2),
    },
    {
      'id': 'cat-3',
      'name': 'Organic Soaps',
      'slug': '/organic-soaps',
      'type': 'New',
      'products': 45,
      'status': 'Active',
      'visibility': 'Visible',
      'order': 3,
      'updated': '15 May 2024 04:45 PM',
      'icon': Icons.soap_rounded,
      'color': const Color(0xFFE0F2FE),
    },
    {
      'id': 'cat-4',
      'name': 'Wellness Oils',
      'slug': '/wellness-oils',
      'type': 'Best',
      'products': 28,
      'status': 'Active',
      'visibility': 'Visible',
      'order': 4,
      'updated': '15 May 2024 02:30 PM',
      'icon': Icons.spa_rounded,
      'color': const Color(0xFFDCFCE7),
    },
    {
      'id': 'cat-5',
      'name': 'Ayurvedic Supplements',
      'slug': '/ayurvedic-supplements',
      'type': '-',
      'products': 12,
      'status': 'Active',
      'visibility': 'Hidden',
      'order': 5,
      'updated': '14 May 2024 11:20 AM',
      'icon': Icons.medication_rounded,
      'color': const Color(0xFFF3E8FF),
    },
    {
      'id': 'cat-6',
      'name': 'Gift Sets & Combos',
      'slug': '/gift-sets-combos',
      'type': '-',
      'products': 5,
      'status': 'Inactive',
      'visibility': 'Hidden',
      'order': 6,
      'updated': '14 May 2024 09:05 AM',
      'icon': Icons.card_giftcard_rounded,
      'color': const Color(0xFFFCE7F3),
    },
  ];

  List<Map<String, dynamic>> _homePageSections = [
    {'id': 'banner_slider', 'title': 'Top Banner Slider', 'icon': Icons.view_carousel_rounded, 'enabled': true},
    {'id': 'category_list', 'title': 'Category List', 'icon': Icons.grid_view_rounded, 'enabled': true},
    {'id': 'promo_banner', 'title': 'Promo Banner', 'icon': Icons.label_important_outline_rounded, 'enabled': true},
    {'id': 'featured_collections', 'title': 'Featured Collections', 'icon': Icons.layers_outlined, 'enabled': true},
    {'id': 'best_selling', 'title': 'Best Selling Products', 'icon': Icons.shopping_bag_outlined, 'enabled': true},
    {'id': 'new_arrivals', 'title': 'New Arrivals', 'icon': Icons.auto_awesome_rounded, 'enabled': true},
    {'id': 'benefits_section', 'title': 'Benefits Section', 'icon': Icons.spa_outlined, 'enabled': false},
    {'id': 'instagram_feed', 'title': 'Instagram Feed', 'icon': Icons.camera_alt_outlined, 'enabled': false},
  ];

  List<Map<String, dynamic>> _sliderImages = [
    {'title': 'Up to 60% OFF - Shop Now', 'route': '/shop', 'color': 0xFF059669},
    {'title': 'Pure & Natural Products', 'route': '/collections/natural', 'color': 0xFFF59E0B},
    {'title': 'New Arrivals This Week', 'route': '/collections/new-arrivals', 'color': 0xFF0284C7},
  ];

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
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });

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
    _searchCategoriesCtrl = TextEditingController();
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
    _searchCategoriesCtrl.dispose();
    _deepLinkCtrl.dispose();
    _sectionTitleCtrl.dispose();
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

  void _showAddCategoryModal([Map<String, dynamic>? existingCategory]) {
    final nameCtrl = TextEditingController(text: existingCategory?['name'] ?? '');
    final slugCtrl = TextEditingController(text: existingCategory?['slug'] ?? '/');
    String type = existingCategory?['type'] ?? 'Hot';
    String status = existingCategory?['status'] ?? 'Active';
    String visibility = existingCategory?['visibility'] ?? 'Visible';
    int order = existingCategory?['order'] ?? (_categoriesList.length + 1);

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dialogCtx, setStateModal) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Row(
                children: [
                  const Icon(Icons.grid_view_rounded, color: Color(0xFF10B981)),
                  const SizedBox(width: 10),
                  Text(existingCategory != null ? 'Edit App Category' : 'Add New App Category', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                ],
              ),
              content: SizedBox(
                width: 480,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Category Name', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(height: 6),
                      TextField(controller: nameCtrl, decoration: InputDecoration(hintText: 'e.g. Haircare & Oils', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)))),
                      const SizedBox(height: 14),
                      const Text('URL Slug / Route', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(height: 6),
                      TextField(controller: slugCtrl, decoration: InputDecoration(hintText: 'e.g. /haircare-oils', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)))),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Badge Type', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                const SizedBox(height: 6),
                                DropdownButtonFormField<String>(
                                  value: type,
                                  decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)), contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
                                  items: ['Hot', 'Popular', 'New', 'Best', '-']
                                      .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                                      .toList(),
                                  onChanged: (val) => setStateModal(() => type = val!),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Visibility', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                const SizedBox(height: 6),
                                DropdownButtonFormField<String>(
                                  value: visibility,
                                  decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)), contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
                                  items: ['Visible', 'Hidden']
                                      .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                                      .toList(),
                                  onChanged: (val) => setStateModal(() => visibility = val!),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                ElevatedButton.icon(
                  onPressed: () {
                    final name = nameCtrl.text.trim();
                    if (name.isEmpty) return;

                    setState(() {
                      if (existingCategory != null) {
                        existingCategory['name'] = name;
                        existingCategory['slug'] = slugCtrl.text.trim();
                        existingCategory['type'] = type;
                        existingCategory['visibility'] = visibility;
                      } else {
                        _categoriesList.add({
                          'id': 'cat-${DateTime.now().millisecondsSinceEpoch}',
                          'name': name,
                          'slug': slugCtrl.text.trim(),
                          'type': type,
                          'products': 10,
                          'status': status,
                          'visibility': visibility,
                          'order': order,
                          'updated': 'Just now',
                          'icon': Icons.category_rounded,
                          'color': const Color(0xFFECFDF5),
                        });
                      }
                    });
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(existingCategory != null ? 'Category updated!' : 'New App Category added! 🎉'), backgroundColor: const Color(0xFF10B981)),
                    );
                  },
                  icon: const Icon(Icons.check, size: 18),
                  label: Text(existingCategory != null ? 'Update Category' : 'Add Category'),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), foregroundColor: Colors.white),
                ),
              ],
            );
          },
        );
      },
    );
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
              : _tabController.index == 1
                  ? _buildAdvancedAppPagesPage()
                  : _tabController.index == 2
                      ? _buildAdvancedAppCategoriesPage()
                      : IndexedStack(
                          index: _tabController.index,
                          children: [
                            const SizedBox.shrink(),
                            const SizedBox.shrink(),
                            const SizedBox.shrink(),
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

  // ── ADVANCED APP BANNERS PAGE ──
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

              Row(
                children: [
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
                  OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.filter_list_rounded, size: 16, color: Color(0xFF334155)),
                    label: const Text('Filter', style: TextStyle(color: Color(0xFF334155), fontWeight: FontWeight.bold, fontSize: 13)),
                    style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10), side: const BorderSide(color: Color(0xFFE2E8F0)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                  ),
                ],
              ),

              const SizedBox(height: 20),

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
                        DataCell(Text(banner['placement'] as String, style: const TextStyle(fontSize: 12, color: Color(0xFF334155)))),
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(12)),
                            child: Text(status, style: TextStyle(color: statusFg, fontSize: 11, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        DataCell(
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(6)),
                            child: Center(child: Text('${banner['priority']}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF475569)))),
                          ),
                        ),
                        DataCell(Text(banner['schedule'] as String, style: const TextStyle(fontSize: 12, color: Color(0xFF475569)))),
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

        const Center(
          child: Text('© 2024 Vaidyam Botanicals. All rights reserved.', style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
        ),
      ],
    );
  }

  // ── ADVANCED APP PAGES PAGE ──
  Widget _buildAdvancedAppPagesPage() {
    final activeSection = _homePageSections[_selectedSectionIndex];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('App Pages > Home Screen', style: TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text('Edit Page: $_selectedPageName', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: const Color(0xFFECFDF5), borderRadius: BorderRadius.circular(12)),
                      child: const Text('Active', style: TextStyle(color: Color(0xFF10B981), fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                const Text('Manage and customize sections, content and layout of this page', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
              ],
            ),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFE2E8F0))),
                  child: Row(
                    children: [
                      const Icon(Icons.smartphone_rounded, size: 16, color: Color(0xFF64748B)),
                      const SizedBox(width: 6),
                      DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedPageName,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
                          items: ['Home Screen', 'Shop Catalog', 'Explore Page', 'Wishlist Page', 'Cart Page']
                              .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                              .toList(),
                          onChanged: (val) => setState(() => _selectedPageName = val!),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Add Section', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10), side: const BorderSide(color: Color(0xFFE2E8F0)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                  child: const Text('More ···', style: TextStyle(color: Color(0xFF475569), fontSize: 12)),
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 20),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 250,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Page Sections', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                    const SizedBox(height: 2),
                    const Text('Drag and drop sections to reorder', style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
                    const SizedBox(height: 14),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _homePageSections.length,
                      itemBuilder: (context, index) {
                        final sec = _homePageSections[index];
                        final isSelected = index == _selectedSectionIndex;

                        return GestureDetector(
                          onTap: () => setState(() {
                            _selectedSectionIndex = index;
                            _sectionTitleCtrl.text = sec['title'] as String;
                          }),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFFECFDF5) : const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: isSelected ? const Color(0xFF10B981) : const Color(0xFFE2E8F0)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.drag_indicator_rounded, size: 16, color: Color(0xFF94A3B8)),
                                const SizedBox(width: 6),
                                Icon(sec['icon'] as IconData, size: 16, color: isSelected ? const Color(0xFF10B981) : const Color(0xFF64748B)),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(sec['title'] as String, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isSelected ? const Color(0xFF065F46) : const Color(0xFF334155))),
                                      Text('ID: ${sec['id']}', style: const TextStyle(fontSize: 9, color: Color(0xFF94A3B8))),
                                    ],
                                  ),
                                ),
                                Switch(
                                  value: sec['enabled'] as bool,
                                  activeColor: const Color(0xFF10B981),
                                  onChanged: (val) => setState(() => sec['enabled'] = val),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      height: 38,
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFF10B981), style: BorderStyle.solid),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.add, size: 16, color: Color(0xFF10B981)),
                            SizedBox(width: 4),
                            Text('Add Section', style: TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold, fontSize: 12)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(width: 16),

            Expanded(
              child: Container(
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
                        Text('Edit Section: ${activeSection['title']}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
                        const SizedBox(width: 10),
                        Text('ID: ${activeSection['id']}', style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(color: const Color(0xFFECFDF5), borderRadius: BorderRadius.circular(10)),
                          child: const Text('Active', style: TextStyle(color: Color(0xFF10B981), fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                        const Spacer(),
                        IconButton(icon: const Icon(Icons.content_copy_rounded, size: 16, color: Color(0xFF64748B)), onPressed: () {}),
                        IconButton(icon: const Icon(Icons.delete_outline_rounded, size: 16, color: Color(0xFFEF4444)), onPressed: () {}),
                      ],
                    ),

                    const SizedBox(height: 14),

                    Row(
                      children: ['Content', 'Settings', 'Style', 'Visibility', 'Targeting'].map((t) {
                        final isSel = _sectionEditorTab == t;
                        return GestureDetector(
                          onTap: () => setState(() => _sectionEditorTab = t),
                          child: Container(
                            margin: const EdgeInsets.only(right: 20),
                            padding: const EdgeInsets.only(bottom: 6),
                            decoration: BoxDecoration(border: Border(bottom: BorderSide(color: isSel ? const Color(0xFF10B981) : Colors.transparent, width: 2))),
                            child: Text(t, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isSel ? const Color(0xFF10B981) : const Color(0xFF64748B))),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 16),
                    const Divider(height: 1),
                    const SizedBox(height: 16),

                    const Text('Section Title (Internal)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _sectionTitleCtrl,
                      decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
                    ),
                    const SizedBox(height: 2),
                    const Text('This title is only for internal reference', style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),

                    const SizedBox(height: 16),

                    const Text('Slider Type', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildSliderTypeCard('Image Slider', 'Multiple images with dots', Icons.photo_library_outlined, _sliderType == 'Image Slider'),
                        const SizedBox(width: 10),
                        _buildSliderTypeCard('Single Banner', 'Single image/banner', Icons.image_outlined, _sliderType == 'Single Banner'),
                        const SizedBox(width: 10),
                        _buildSliderTypeCard('Auto Rotating', 'Auto rotate banners', Icons.autorenew_rounded, _sliderType == 'Auto Rotating'),
                      ],
                    ),

                    const SizedBox(height: 18),

                    const Text('Slider Images', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
                    const SizedBox(height: 8),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _sliderImages.length,
                      itemBuilder: (context, index) {
                        final img = _sliderImages[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFE2E8F0))),
                          child: Row(
                            children: [
                              const Icon(Icons.drag_indicator, size: 16, color: Color(0xFF94A3B8)),
                              const SizedBox(width: 8),
                              Container(
                                width: 44,
                                height: 28,
                                decoration: BoxDecoration(color: Color(img['color'] as int), borderRadius: BorderRadius.circular(6)),
                                child: const Center(child: Icon(Icons.image, color: Colors.white, size: 14)),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(img['title'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF0F172A))),
                                    Text(img['route'] as String, style: const TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                                  ],
                                ),
                              ),
                              IconButton(icon: const Icon(Icons.edit_outlined, size: 16, color: Color(0xFF64748B)), onPressed: () {}),
                              IconButton(icon: const Icon(Icons.link_rounded, size: 16, color: Color(0xFF64748B)), onPressed: () {}),
                              IconButton(icon: const Icon(Icons.delete_outline, size: 16, color: Color(0xFFEF4444)), onPressed: () => setState(() => _sliderImages.removeAt(index))),
                            ],
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 8),
                    Row(
                      children: [
                        OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.add, size: 16, color: Color(0xFF10B981)),
                          label: const Text('Add Image', style: TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold, fontSize: 12)),
                          style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFF10B981)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                        ),
                        const SizedBox(width: 10),
                        const Text('Recommended size: 1242x400px | Max 5MB', style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
                      ],
                    ),

                    const SizedBox(height: 18),

                    const Text('Slider Settings', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Row(
                          children: [
                            const Text('Auto Play', style: TextStyle(fontSize: 12)),
                            Switch(value: _sliderAutoPlay, activeColor: const Color(0xFF10B981), onChanged: (val) => setState(() => _sliderAutoPlay = val)),
                          ],
                        ),
                        const SizedBox(width: 24),
                        Row(
                          children: [
                            const Text('Interval ', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(6), border: Border.all(color: const Color(0xFFE2E8F0))),
                              child: Row(
                                children: [
                                  Text('$_sliderInterval sec', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                  const Icon(Icons.arrow_drop_down, size: 14),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Row(
                          children: [
                            const Text('Show Dots', style: TextStyle(fontSize: 12)),
                            Switch(value: _sliderShowDots, activeColor: const Color(0xFF10B981), onChanged: (val) => setState(() => _sliderShowDots = val)),
                          ],
                        ),
                        const SizedBox(width: 24),
                        Row(
                          children: [
                            const Text('Show Arrows', style: TextStyle(fontSize: 12)),
                            Switch(value: _sliderShowArrows, activeColor: const Color(0xFF10B981), onChanged: (val) => setState(() => _sliderShowArrows = val)),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Text('Infinite Loop', style: TextStyle(fontSize: 12)),
                        Switch(value: _sliderInfiniteLoop, activeColor: const Color(0xFF10B981), onChanged: (val) => setState(() => _sliderInfiniteLoop = val)),
                      ],
                    ),

                    const SizedBox(height: 14),
                    Row(
                      children: const [
                        Text('Advanced Options', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
                        Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: Color(0xFF64748B)),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(width: 16),

            SizedBox(
              width: 240,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Section Status', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(color: const Color(0xFFECFDF5), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFA7F3D0))),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _sectionStatus,
                              style: const TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold, fontSize: 12),
                              items: ['Active', 'Inactive', 'Scheduled'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                              onChanged: (val) => setState(() => _sectionStatus = val!),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),

                        const Text('Visible For', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
                        const SizedBox(height: 4),
                        Column(
                          children: ['All Users', 'Logged In Users', 'New Users'].map((target) {
                            final isSel = _sectionVisibleFor == target;
                            return GestureDetector(
                              onTap: () => setState(() => _sectionVisibleFor = target),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 3),
                                child: Row(
                                  children: [
                                    Icon(isSel ? Icons.radio_button_checked : Icons.radio_button_off, size: 14, color: isSel ? const Color(0xFF10B981) : const Color(0xFF94A3B8)),
                                    const SizedBox(width: 6),
                                    Text(target, style: const TextStyle(fontSize: 11, color: Color(0xFF334155))),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),

                        const SizedBox(height: 12),

                        const Text('Devices', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
                        Row(
                          children: [
                            Checkbox(value: _sectionAndroid, activeColor: const Color(0xFF10B981), onChanged: (v) => setState(() => _sectionAndroid = v!)),
                            const Text('Android', style: TextStyle(fontSize: 11)),
                            Checkbox(value: _sectionIOS, activeColor: const Color(0xFF10B981), onChanged: (v) => setState(() => _sectionIOS = v!)),
                            const Text('iOS', style: TextStyle(fontSize: 11)),
                          ],
                        ),

                        const SizedBox(height: 8),

                        const Text('Placement', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
                        const SizedBox(height: 4),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(6), border: Border.all(color: const Color(0xFFE2E8F0))),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _sectionPlacement,
                              style: const TextStyle(fontSize: 11, color: Color(0xFF334155)),
                              items: ['Top of Page', 'Middle of Page', 'Bottom of Page'].map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                              onChanged: (v) => setState(() => _sectionPlacement = v!),
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        const Text('Priority Order', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
                        const SizedBox(height: 4),
                        Container(
                          height: 32,
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(6), border: Border.all(color: const Color(0xFFE2E8F0))),
                          child: Text('$_sectionPriority', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(height: 2),
                        const Text('Lower numbers appear first', style: TextStyle(fontSize: 9, color: Color(0xFF94A3B8))),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Performance (Last 7 Days)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text('Impressions', style: TextStyle(fontSize: 9, color: Color(0xFF64748B))),
                                Text('48,562', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF10B981))),
                                Text('↑ 18.6%', style: TextStyle(fontSize: 9, color: Color(0xFF10B981))),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text('Clicks', style: TextStyle(fontSize: 9, color: Color(0xFF64748B))),
                                Text('12,845', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF0284C7))),
                                Text('↑ 22.4%', style: TextStyle(fontSize: 9, color: Color(0xFF0284C7))),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text('CTR', style: TextStyle(fontSize: 9, color: Color(0xFF64748B))),
                                Text('26.47%', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF8B5CF6))),
                                Text('↑ 3.2%', style: TextStyle(fontSize: 9, color: Color(0xFF8B5CF6))),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Section ID', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(activeSection['id'] as String, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                            const Icon(Icons.content_copy_rounded, size: 14, color: Color(0xFF64748B)),
                          ],
                        ),
                        const SizedBox(height: 2),
                        const Text('Use this ID for API or developer reference', style: TextStyle(fontSize: 9, color: Color(0xFF94A3B8))),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 16),

            SizedBox(
              width: 200,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Quick Actions', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                        const SizedBox(height: 10),
                        _buildQuickActionTile('Duplicate Section', Icons.content_copy_rounded, () {}),
                        _buildQuickActionTile('Copy Section ID', Icons.link_rounded, () {}),
                        _buildQuickActionTile('Disable Section', Icons.block_rounded, () {}),
                        _buildQuickActionTile('Delete Section', Icons.delete_outline_rounded, () {}, isDanger: true),
                        _buildQuickActionTile('Export Section Data', Icons.download_rounded, () {}),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF2FF),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFC7D2FE)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Row(
                          children: [
                            Icon(Icons.lightbulb_outline_rounded, size: 16, color: Color(0xFF4F46E5)),
                            SizedBox(width: 6),
                            Text('Tips', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF3730A3))),
                          ],
                        ),
                        SizedBox(height: 6),
                        Text('• Drag and drop sections to reorder', style: TextStyle(fontSize: 10, color: Color(0xFF4338CA))),
                        SizedBox(height: 3),
                        Text('• Use visibility settings to target specific user groups', style: TextStyle(fontSize: 10, color: Color(0xFF4338CA))),
                        SizedBox(height: 3),
                        Text('• Changes are saved in real-time', style: TextStyle(fontSize: 10, color: Color(0xFF4338CA))),
                        SizedBox(height: 3),
                        Text('• Preview your changes before publishing', style: TextStyle(fontSize: 10, color: Color(0xFF4338CA))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.arrow_back, size: 16, color: Color(0xFF475569)),
                label: const Text('Back to Pages', style: TextStyle(color: Color(0xFF475569), fontWeight: FontWeight.bold, fontSize: 13)),
                style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFFCBD5E1)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              ),
              const Spacer(),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.visibility_outlined, size: 16, color: Color(0xFF4F46E5)),
                label: const Text('Preview Changes', style: TextStyle(color: Color(0xFF4F46E5), fontWeight: FontWeight.bold, fontSize: 13)),
                style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFF818CF8)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: _saveSettings,
                icon: const Icon(Icons.save_rounded, size: 16),
                label: const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 36),

        const Center(
          child: Text('© 2024 Vaidyam Botanicals. All rights reserved.', style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
        ),
      ],
    );
  }

  // ── ADVANCED APP CATEGORIES PAGE (MATCHING SCREENSHOT 1-TO-1) ──
  Widget _buildAdvancedAppCategoriesPage() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth > 1100;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title & Top Action Bar Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Category Section Manager', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
                SizedBox(height: 4),
                Text('Create, organize and manage app categories to display in the app', style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
              ],
            ),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () => _showAddCategoryModal(),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add New Category', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                  ),
                ),
                const SizedBox(width: 10),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.download_rounded, size: 16, color: Color(0xFF334155)),
                  label: const Text('Import Categories', style: TextStyle(color: Color(0xFF334155), fontWeight: FontWeight.bold, fontSize: 13)),
                  style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10), side: const BorderSide(color: Color(0xFFE2E8F0)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10), side: const BorderSide(color: Color(0xFFE2E8F0)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                  child: const Text('··· More ∨', style: TextStyle(color: Color(0xFF475569), fontSize: 12)),
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 20),

        // 4 KPI SUMMARY METRIC CARDS (ROW)
        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final cardWidth = width > 900 ? (width - 36) / 4 : (width - 12) / 2;

            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildKpiCard('Total Categories', '12', 'Active', Icons.grid_view_rounded, const Color(0xFFECFDF5), const Color(0xFF10B981), cardWidth),
                _buildKpiCard('Visible on App', '10', '80% of total', Icons.visibility_outlined, const Color(0xFFECFDF5), const Color(0xFF10B981), cardWidth),
                _buildKpiCard('Total Products', '248', 'Across all categories', Icons.inventory_2_outlined, const Color(0xFFECFDF5), const Color(0xFF10B981), cardWidth),
                _buildKpiCard('Last Updated', '16 May 2024', '10:28 AM', Icons.calendar_today_rounded, const Color(0xFFECFDF5), const Color(0xFF10B981), cardWidth),
              ],
            );
          },
        ),

        const SizedBox(height: 24),

        // MAIN CONTENT AREA: TABLE (LEFT) + RIGHT SIDEBAR
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // LEFT PANEL: "ALL CATEGORIES" DATA TABLE
            Expanded(
              flex: 7,
              child: Container(
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
                    const Text('All Categories', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                    const SizedBox(height: 16),

                    // Search & Filter Action Bar
                    Row(
                      children: [
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
                                    controller: _searchCategoriesCtrl,
                                    decoration: const InputDecoration(hintText: 'Search categories...', hintStyle: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)), border: InputBorder.none, isDense: true),
                                    onChanged: (_) => setState(() {}),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          height: 40,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFE2E8F0))),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _categoryStatusFilter,
                              style: const TextStyle(fontSize: 12, color: Color(0xFF334155), fontWeight: FontWeight.w600),
                              items: ['All Status', 'Active', 'Inactive'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                              onChanged: (val) => setState(() => _categoryStatusFilter = val!),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          height: 40,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFE2E8F0))),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _categoryTypeFilter,
                              style: const TextStyle(fontSize: 12, color: Color(0xFF334155), fontWeight: FontWeight.w600),
                              items: ['All Type', 'Hot', 'Popular', 'New', 'Best'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                              onChanged: (val) => setState(() => _categoryTypeFilter = val!),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.filter_list_rounded, size: 16, color: Color(0xFF334155)),
                          label: const Text('Filter', style: TextStyle(color: Color(0xFF334155), fontWeight: FontWeight.bold, fontSize: 12)),
                          style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10), side: const BorderSide(color: Color(0xFFE2E8F0)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Data Table
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columnSpacing: 20,
                        horizontalMargin: 0,
                        headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
                        columns: const [
                          DataColumn(label: Text('Category', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF64748B)))),
                          DataColumn(label: Text('Type', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF64748B)))),
                          DataColumn(label: Text('Products', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF64748B)))),
                          DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF64748B)))),
                          DataColumn(label: Text('Visibility', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF64748B)))),
                          DataColumn(label: Text('Order', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF64748B)))),
                          DataColumn(label: Text('Updated On', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF64748B)))),
                          DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF64748B)))),
                        ],
                        rows: _categoriesList.map((cat) {
                          final type = cat['type'] as String;
                          Color badgeBg = Colors.transparent;
                          Color badgeFg = Colors.transparent;
                          if (type == 'Hot') { badgeBg = const Color(0xFFFFF1F0); badgeFg = const Color(0xFFFF4D4F); }
                          else if (type == 'Popular') { badgeBg = const Color(0xFFFFF7E6); badgeFg = const Color(0xFFFA8C16); }
                          else if (type == 'New') { badgeBg = const Color(0xFFE6F7FF); badgeFg = const Color(0xFF1890FF); }
                          else if (type == 'Best') { badgeBg = const Color(0xFFF6FFED); badgeFg = const Color(0xFF52C41A); }

                          final isVisible = cat['visibility'] == 'Visible';
                          final isActive = cat['status'] == 'Active';

                          return DataRow(
                            cells: [
                              // Icon & Category Name + Slug
                              DataCell(
                                Row(
                                  children: [
                                    Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(color: cat['color'] as Color, borderRadius: BorderRadius.circular(10)),
                                      child: Icon(cat['icon'] as IconData, size: 18, color: const Color(0xFF334155)),
                                    ),
                                    const SizedBox(width: 10),
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(cat['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A))),
                                        Text(cat['slug'] as String, style: const TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              // Type Badge
                              DataCell(
                                type != '-'
                                    ? Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(color: badgeBg, borderRadius: BorderRadius.circular(10)),
                                        child: Text(type, style: TextStyle(color: badgeFg, fontSize: 10, fontWeight: FontWeight.bold)),
                                      )
                                    : const Text('-', style: TextStyle(color: Color(0xFF94A3B8))),
                              ),
                              // Products Count
                              DataCell(Text('${cat['products']}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF334155)))),
                              // Status Badge
                              DataCell(
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(color: isActive ? const Color(0xFFECFDF5) : const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(10)),
                                  child: Text(cat['status'] as String, style: TextStyle(color: isActive ? const Color(0xFF10B981) : const Color(0xFF64748B), fontSize: 11, fontWeight: FontWeight.bold)),
                                ),
                              ),
                              // Visibility
                              DataCell(
                                Row(
                                  children: [
                                    Icon(isVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 14, color: isVisible ? const Color(0xFF10B981) : const Color(0xFFEF4444)),
                                    const SizedBox(width: 4),
                                    Text(cat['visibility'] as String, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isVisible ? const Color(0xFF10B981) : const Color(0xFFEF4444))),
                                  ],
                                ),
                              ),
                              // Order Box
                              DataCell(
                                Container(
                                  width: 28,
                                  height: 28,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(6), border: Border.all(color: const Color(0xFFE2E8F0))),
                                  child: Text('${cat['order']}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                ),
                              ),
                              // Updated On Date
                              DataCell(Text(cat['updated'] as String, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)))),
                              // Actions Icons
                              DataCell(
                                Row(
                                  children: [
                                    IconButton(icon: const Icon(Icons.edit_outlined, size: 16, color: Color(0xFF64748B)), onPressed: () => _showAddCategoryModal(cat)),
                                    IconButton(icon: const Icon(Icons.link_rounded, size: 16, color: Color(0xFF64748B)), onPressed: () {}),
                                    IconButton(icon: const Icon(Icons.more_vert_rounded, size: 16, color: Color(0xFF64748B)), onPressed: () {}),
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

                    // Pagination Footer Bar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Showing 1 to ${_categoriesList.length} of 12 categories', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(6), border: Border.all(color: const Color(0xFFE2E8F0))),
                              child: Row(
                                children: const [
                                  Text('10 / page', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
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
            ),

            if (isWide) ...[
              const SizedBox(width: 20),
              // RIGHT SIDEBAR: QUICK STATS + TIPS + VISIBILITY GUIDE
              SizedBox(
                width: 280,
                child: Column(
                  children: [
                    // Category Quick Stats Donut Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Category Quick Stats', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Container(
                                width: 70,
                                height: 70,
                                decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color(0xFF10B981), width: 8)),
                                child: const Center(child: Icon(Icons.pie_chart_rounded, size: 24, color: Color(0xFF10B981))),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  children: [
                                    _buildLegendRow('Hot', '3 (25%)', const Color(0xFFFF4D4F)),
                                    _buildLegendRow('Popular', '3 (25%)', const Color(0xFFFA8C16)),
                                    _buildLegendRow('New', '2 (17%)', const Color(0xFF1890FF)),
                                    _buildLegendRow('Best', '2 (17%)', const Color(0xFF52C41A)),
                                    _buildLegendRow('Others', '2 (16%)', const Color(0xFF94A3B8)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          const Divider(height: 1),
                          const SizedBox(height: 8),
                          const Center(child: Text('Total 12 Categories', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF64748B)))),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Tips Card (Light green tint)
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFA7F3D0)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Row(
                            children: [
                              Icon(Icons.lightbulb_outline_rounded, size: 16, color: Color(0xFF10B981)),
                              SizedBox(width: 6),
                              Text('Tips', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF065F46))),
                            ],
                          ),
                          SizedBox(height: 6),
                          Text('• Drag & drop to reorder categories', style: TextStyle(fontSize: 10, color: Color(0xFF047857))),
                          SizedBox(height: 3),
                          Text('• Mark category as Hot/Popular/New to highlight in app', style: TextStyle(fontSize: 10, color: Color(0xFF047857))),
                          SizedBox(height: 3),
                          Text('• Hide categories without deleting them', style: TextStyle(fontSize: 10, color: Color(0xFF047857))),
                          SizedBox(height: 3),
                          Text('• Changes reflect instantly in the app', style: TextStyle(fontSize: 10, color: Color(0xFF047857))),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Category Visibility Guide Card
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('Category Visibility Guide', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                          SizedBox(height: 8),
                          Text('🟢 Visible: Category shown in app', style: TextStyle(fontSize: 10, color: Color(0xFF334155))),
                          SizedBox(height: 3),
                          Text('🔵 Hidden: Category hidden from users', style: TextStyle(fontSize: 10, color: Color(0xFF334155))),
                          SizedBox(height: 3),
                          Text('🔴 Inactive: Category disabled (not used)', style: TextStyle(fontSize: 10, color: Color(0xFF334155))),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),

        const SizedBox(height: 28),

        // BOTTOM 3-COLUMN SETTINGS SECTION (GLOBAL SETTINGS, BADGE MANAGEMENT, DEFAULT IMAGE)
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // COLUMN 1: CATEGORY SETTINGS
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Category Settings', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                    const SizedBox(height: 2),
                    const Text('Global Category Settings', style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text('Show Category Icons', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                            Text('Display icons with category names', style: TextStyle(fontSize: 9, color: Color(0xFF94A3B8))),
                          ],
                        ),
                        Switch(value: _showCategoryIcons, activeColor: const Color(0xFF10B981), onChanged: (v) => setState(() => _showCategoryIcons = v)),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text('Enable Category Badges', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                            Text('Show Hot, Popular, New, Best badges', style: TextStyle(fontSize: 9, color: Color(0xFF94A3B8))),
                          ],
                        ),
                        Switch(value: _enableCategoryBadges, activeColor: const Color(0xFF10B981), onChanged: (v) => setState(() => _enableCategoryBadges = v)),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text('Show Product Count', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                            Text('Display product count on category', style: TextStyle(fontSize: 9, color: Color(0xFF94A3B8))),
                          ],
                        ),
                        Switch(value: _showProductCount, activeColor: const Color(0xFF10B981), onChanged: (v) => setState(() => _showProductCount = v)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Category Image Ratio', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(6), border: Border.all(color: const Color(0xFFE2E8F0))),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _categoryImageRatio,
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
                              items: ['1:1 (Square)', '4:3 (Landscape)', '16:9 (Wide)'].map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                              onChanged: (val) => setState(() => _categoryImageRatio = val!),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(width: 16),

            // COLUMN 2: BADGE MANAGEMENT
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Badge Management', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                    const SizedBox(height: 2),
                    const Text('Manage category badges and colors', style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
                    const SizedBox(height: 14),
                    _buildBadgeRow('Hot', _hotBadgeColor, const Color(0xFFFF4D4F)),
                    _buildBadgeRow('Popular', _popularBadgeColor, const Color(0xFFFA8C16)),
                    _buildBadgeRow('New', _newBadgeColor, const Color(0xFF1890FF)),
                    _buildBadgeRow('Best', _bestBadgeColor, const Color(0xFF52C41A)),
                  ],
                ),
              ),
            ),

            const SizedBox(width: 16),

            // COLUMN 3: DEFAULT CATEGORY IMAGE
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Default Category Image', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                    const SizedBox(height: 2),
                    const Text('Upload default image for categories without custom image', style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
                    const SizedBox(height: 14),
                    Container(
                      height: 110,
                      width: double.infinity,
                      decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.upload_file_rounded, size: 24, color: Color(0xFF94A3B8)),
                          SizedBox(height: 4),
                          Text('Upload Image', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
                          SizedBox(height: 2),
                          Text('Recommended: 512x512px | PNG, JPG up to 2MB', style: TextStyle(fontSize: 9, color: Color(0xFF94A3B8))),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Center(
                      child: OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFFE2E8F0)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))),
                        child: const Text('Remove Image', style: TextStyle(fontSize: 11, color: Color(0xFF475569))),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 36),

        // Copyright Notice
        const Center(
          child: Text('© 2024 Vaidyam Botanicals. All rights reserved.', style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
        ),
      ],
    );
  }

  Widget _buildLegendRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          CircleAvatar(radius: 3.5, backgroundColor: color),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
          const Spacer(),
          Text(value, style: const TextStyle(fontSize: 10, color: Color(0xFF64748B))),
        ],
      ),
    );
  }

  Widget _buildBadgeRow(String badgeName, String hexCode, Color swatchColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          CircleAvatar(radius: 4, backgroundColor: swatchColor),
          const SizedBox(width: 6),
          SizedBox(width: 50, child: Text(badgeName, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(4), border: Border.all(color: const Color(0xFFE2E8F0))),
            child: Text(hexCode, style: const TextStyle(fontSize: 10, fontFamily: 'monospace')),
          ),
          const SizedBox(width: 6),
          Container(width: 14, height: 14, decoration: BoxDecoration(color: swatchColor, borderRadius: BorderRadius.circular(3))),
          const SizedBox(width: 6),
          const Icon(Icons.edit_outlined, size: 14, color: Color(0xFF94A3B8)),
        ],
      ),
    );
  }

  Widget _buildSliderTypeCard(String title, String subtitle, IconData icon, bool isSelected) {
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _sliderType = title),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFECFDF5) : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: isSelected ? const Color(0xFF10B981) : const Color(0xFFE2E8F0), width: isSelected ? 2 : 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 16, color: isSelected ? const Color(0xFF10B981) : const Color(0xFF64748B)),
                  const SizedBox(width: 6),
                  Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: isSelected ? const Color(0xFF065F46) : const Color(0xFF334155))),
                ],
              ),
              const SizedBox(height: 2),
              Text(subtitle, style: const TextStyle(fontSize: 9, color: Color(0xFF94A3B8))),
            ],
          ),
        ),
      ),
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

  Widget _buildQuickActionTile(String label, IconData icon, VoidCallback onTap, {bool isDanger = false}) {
    final color = isDanger ? const Color(0xFFEF4444) : const Color(0xFF334155);
    final bg = isDanger ? const Color(0xFFFEF2F2) : const Color(0xFFECFDF5);
    final iconColor = isDanger ? const Color(0xFFEF4444) : const Color(0xFF10B981);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)), child: Icon(icon, color: iconColor, size: 15)),
            const SizedBox(width: 10),
            Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }

  // ── SUB-TABS 3 TO 8 IMPLEMENTATION ──
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
