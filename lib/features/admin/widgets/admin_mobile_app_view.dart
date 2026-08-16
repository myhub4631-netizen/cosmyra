import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/theme/app_colors.dart';
import '../controllers/mobile_app_settings_controller.dart';
import '../../catalog/widgets/product_image_widget.dart';

class AdminMobileAppView extends ConsumerStatefulWidget {
  const AdminMobileAppView({super.key});

  @override
  ConsumerState<AdminMobileAppView> createState() => _AdminMobileAppViewState();
}

class _AdminMobileAppViewState extends ConsumerState<AdminMobileAppView> {
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

  late bool _showAnnouncement;
  late bool _showHotSelling;
  late bool _showCategoryGrid;

  @override
  void initState() {
    super.initState();
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

    _showAnnouncement = settings.showAnnouncementBar;
    _showHotSelling = settings.showHotSellingSection;
    _showCategoryGrid = settings.showCategoryGrid;
  }

  @override
  void dispose() {
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

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(mobileAppSettingsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header title banner
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
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
                    color: Colors.white.withValues(alpha: 0.15),
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
                        '📱 Mobile App Dedicated Control Panel',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Manage mobile app banners, mobile-only headers, announcement bars & app sections in real-time.',
                        style: TextStyle(fontSize: 13, color: Color(0xFFE0E7FF)),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () async {
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

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('✅ Mobile App Settings saved successfully! Mobile app updated in real-time.'),
                          backgroundColor: Color(0xFF10B981),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF4F46E5),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.save_rounded, size: 20),
                  label: const Text('Publish Mobile Settings', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // 1. Mobile App Header & Announcement Settings
          _buildCardSection(
            title: '1. Mobile App Header & Announcement Marquee',
            icon: Icons.title_rounded,
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Mobile App Display Name', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
                          const SizedBox(height: 6),
                          TextField(
                            controller: _appNameCtrl,
                            decoration: InputDecoration(
                              hintText: 'e.g. Vaidyam Mobile / Cosmyra',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Search Bar Placeholder Hint', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
                          const SizedBox(height: 6),
                          TextField(
                            controller: _searchHintCtrl,
                            decoration: InputDecoration(
                              hintText: 'e.g. Search in Ayurveda, Haircare, Skincare...',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Mobile Logo Uploader
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Mobile App Dedicated Logo', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _logoCtrl,
                            decoration: InputDecoration(
                              hintText: 'Enter Mobile Logo Image URL or Upload Image',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton.icon(
                          onPressed: () => _pickImage(_logoCtrl, 'Logo'),
                          icon: const Icon(Icons.upload_file_rounded, size: 18),
                          label: const Text('Upload Image'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4F46E5),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Top Announcement Bar Text & Toggle
                SwitchListTile(
                  title: const Text('Show Top Announcement Marquee Bar on Mobile', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  subtitle: const Text('Displays promo banner bar at the very top of mobile screen'),
                  value: _showAnnouncement,
                  activeColor: const Color(0xFF4F46E5),
                  onChanged: (val) => setState(() => _showAnnouncement = val),
                ),
                if (_showAnnouncement) ...[
                  const SizedBox(height: 8),
                  TextField(
                    controller: _announcementCtrl,
                    decoration: InputDecoration(
                      labelText: 'Announcement Bar Message',
                      hintText: 'e.g. 🌿 Special Offer: Free Shipping on all orders above ₹999!',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 24),

          // 2. Mobile Hero Banner & Offer Slider Panel
          _buildCardSection(
            title: '2. Mobile App Top Hero Banner & Offer Cards',
            icon: Icons.view_carousel_rounded,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Mobile Hero Banner Title', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
                          const SizedBox(height: 6),
                          TextField(
                            controller: _bannerTitleCtrl,
                            decoration: InputDecoration(
                              hintText: 'e.g. Great Deals on Ayurveda & Skincare',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Mobile Discount Tag Text', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
                          const SizedBox(height: 6),
                          TextField(
                            controller: _bannerDiscountCtrl,
                            decoration: InputDecoration(
                              hintText: 'e.g. Up to 60% OFF • Shop Now',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text('Mobile Banner Subtitle / Description', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
                const SizedBox(height: 6),
                TextField(
                  controller: _bannerSubCtrl,
                  decoration: InputDecoration(
                    hintText: 'e.g. 100% Pure Certified Organic Formulations',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                ),
                const SizedBox(height: 16),

                // Mobile Banner Image Upload
                const Text('Mobile Hero Banner Background Image', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _bannerImageCtrl,
                        decoration: InputDecoration(
                          hintText: 'Enter Image URL or Upload Custom Banner Image',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton.icon(
                      onPressed: () => _pickImage(_bannerImageCtrl, 'Banner Image'),
                      icon: const Icon(Icons.image_rounded, size: 18),
                      label: const Text('Upload Banner'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4F46E5),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // 3. Mobile Homepage Section Visibility Toggles
          _buildCardSection(
            title: '3. Mobile App Homepage Layout & Section Controls',
            icon: Icons.dashboard_customize_rounded,
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Show Category Quick Grid on Mobile App', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  subtitle: const Text('Displays circular & card category shortcuts on mobile home screen'),
                  value: _showCategoryGrid,
                  activeColor: const Color(0xFF4F46E5),
                  onChanged: (val) => setState(() => _showCategoryGrid = val),
                ),
                const Divider(),
                SwitchListTile(
                  title: const Text('Show Hot Selling / Featured Products Section', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  subtitle: const Text('Displays top selling Ayurvedic product cards carousel on mobile app'),
                  value: _showHotSelling,
                  activeColor: const Color(0xFF4F46E5),
                  onChanged: (val) => setState(() => _showHotSelling = val),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // 4. Mobile Support & WhatsApp Settings
          _buildCardSection(
            title: '4. Mobile Support & 1-Tap WhatsApp Contact',
            icon: Icons.support_agent_rounded,
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Support Helpline Phone', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _phoneCtrl,
                        decoration: InputDecoration(
                          hintText: '+91 94730 40903',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('WhatsApp Business Number', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _whatsappCtrl,
                        decoration: InputDecoration(
                          hintText: '+91 94730 40903',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        ),
                      ),
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

  Widget _buildCardSection({required String title, required IconData icon, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(color: Color(0x08000000), blurRadius: 10, offset: Offset(0, 2)),
        ],
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
}
