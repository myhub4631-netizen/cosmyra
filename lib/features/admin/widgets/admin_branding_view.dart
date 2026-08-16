import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../controllers/brand_settings_controller.dart';
import '../../catalog/widgets/product_image_widget.dart';

class AdminBrandingView extends ConsumerStatefulWidget {
  const AdminBrandingView({super.key});

  @override
  ConsumerState<AdminBrandingView> createState() => _AdminBrandingViewState();
}

class _AdminBrandingViewState extends ConsumerState<AdminBrandingView> {
  late TextEditingController _nameCtrl;
  late TextEditingController _taglineCtrl;
  late TextEditingController _headerLogoCtrl;
  late TextEditingController _footerLogoCtrl;
  late TextEditingController _faviconCtrl;
  late TextEditingController _appIconCtrl;
  late bool _hideBrandTextWithLogo;

  @override
  void initState() {
    super.initState();
    final settings = ref.read(brandSettingsProvider);
    _nameCtrl = TextEditingController(text: settings.brandName);
    _taglineCtrl = TextEditingController(text: settings.brandTagline);
    _headerLogoCtrl = TextEditingController(text: settings.headerLogoUrl);
    _footerLogoCtrl = TextEditingController(text: settings.footerLogoUrl);
    _faviconCtrl = TextEditingController(text: settings.faviconUrl);
    _appIconCtrl = TextEditingController(text: settings.appIconUrl);
    _hideBrandTextWithLogo = settings.hideBrandTextWithLogo;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _taglineCtrl.dispose();
    _headerLogoCtrl.dispose();
    _footerLogoCtrl.dispose();
    _faviconCtrl.dispose();
    _appIconCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImageFile(TextEditingController targetCtrl, String label) async {
    try {
      FilePickerResult? result;
      try {
        result = await FilePicker.pickFiles(
          type: FileType.image,
          withData: true,
        );
      } catch (_) {
        result = await FilePicker.pickFiles(
          type: FileType.any,
          withData: true,
        );
      }
      if (result != null && result.files.isNotEmpty) {
        final bytes = result.files.first.bytes;
        if (bytes != null) {
          final String base64Result = 'data:image/png;base64,${base64Encode(bytes)}';
          setState(() {
            targetCtrl.text = base64Result;
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Custom $label loaded successfully! 🖼️')),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Brand & Logo Settings 🎨',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF111827)),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Upload and manage store logo, header icon, favicon, app icon, and brand slogan.',
                    style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () async {
                  await ref.read(brandSettingsProvider.notifier).updateSettings(
                        brandName: _nameCtrl.text.trim(),
                        brandTagline: _taglineCtrl.text.trim(),
                        headerLogoUrl: _headerLogoCtrl.text.trim(),
                        footerLogoUrl: _footerLogoCtrl.text.trim(),
                        faviconUrl: _faviconCtrl.text.trim(),
                        appIconUrl: _appIconCtrl.text.trim(),
                        hideBrandTextWithLogo: _hideBrandTextWithLogo,
                      );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Brand logos and icons saved successfully! 🚀')),
                    );
                  }
                },
                icon: const Icon(Icons.save_outlined, size: 18),
                label: const Text('Save Brand Settings', style: TextStyle(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4F46E5),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Brand Identity Card (Name & Tagline)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE5E7EB)),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Brand Identity', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _nameCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Store Brand Name',
                          hintText: 'e.g. Vaidyam Botanicals',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: _taglineCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Brand Tagline / Slogan',
                          hintText: 'e.g. Pure Ayurveda. Real Results.',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _hideBrandTextWithLogo,
                  activeColor: const Color(0xFF4F46E5),
                  title: const Text(
                    'Hide Brand Name & Tagline Text next to Header Logo',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF111827)),
                  ),
                  subtitle: const Text(
                    'Enable this if your uploaded Header Logo image already contains your store name/logo text (e.g. COSMYRA banner logo).',
                    style: TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
                  ),
                  onChanged: (val) {
                    setState(() {
                      _hideBrandTextWithLogo = val ?? false;
                    });
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Logos Grid (Header Logo, Footer Logo, Favicon, App Icon)
          Wrap(
            spacing: 20,
            runSpacing: 20,
            children: [
              _buildLogoCard(
                title: 'Header Logo 🖼️',
                subtitle: 'Shown in main navigation header bar on website.',
                controller: _headerLogoCtrl,
                label: 'Header Logo',
                recommendedSize: 'Width: 200px - 300px (PNG/WebP/SVG)',
              ),
              _buildLogoCard(
                title: 'Footer Logo 📜',
                subtitle: 'Shown at the bottom footer section on all pages.',
                controller: _footerLogoCtrl,
                label: 'Footer Logo',
                recommendedSize: 'Width: 180px - 250px (PNG/WebP)',
              ),
              _buildLogoCard(
                title: 'Browser Favicon 🌐',
                subtitle: 'Icon displayed on browser tabs next to page title.',
                controller: _faviconCtrl,
                label: 'Favicon',
                recommendedSize: '32x32 px or 64x64 px (ICO/PNG/SVG)',
              ),
              _buildLogoCard(
                title: 'App Icon (PWA & Mobile) 📱',
                subtitle: 'Icon used for mobile app launcher & PWA installation.',
                controller: _appIconCtrl,
                label: 'App Icon',
                recommendedSize: '512x512 px (Square PNG/WebP)',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLogoCard({
    required String title,
    required String subtitle,
    required TextEditingController controller,
    required String label,
    required String recommendedSize,
  }) {
    final String currentUrl = controller.text.trim();
    final bool hasImage = currentUrl.isNotEmpty;

    return Container(
      width: 480,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
          const SizedBox(height: 4),
          Text('Recommended: $recommendedSize', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF4F46E5))),

          const SizedBox(height: 16),

          // Image Preview Container
          Container(
            height: 110,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: hasImage
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: ProductImageWidget(
                        imageUrl: currentUrl,
                        fit: BoxFit.contain,
                      ),
                    ),
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.image_outlined, size: 36, color: Color(0xFF94A3B8)),
                        SizedBox(height: 4),
                        Text('No Custom Image Set (Using Default)', style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
                      ],
                    ),
                  ),
          ),

          const SizedBox(height: 14),

          // Action Buttons: Pick from Computer & Enter URL
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _pickImageFile(controller, label),
                  icon: const Icon(Icons.upload_file_outlined, size: 16),
                  label: const Text('Pick Image from Device 📁', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEEF2FF),
                    foregroundColor: const Color(0xFF4F46E5),
                    elevation: 0,
                    side: const BorderSide(color: Color(0xFFC7D2FE)),
                  ),
                ),
              ),
              if (hasImage) ...[
                const SizedBox(width: 8),
                IconButton(
                  tooltip: 'Clear Custom Image',
                  icon: const Icon(Icons.delete_outline, color: Color(0xFFEF4444), size: 20),
                  onPressed: () {
                    setState(() {
                      controller.clear();
                    });
                  },
                ),
              ],
            ],
          ),

          const SizedBox(height: 10),

          // Or input Image URL directly
          TextField(
            controller: controller,
            onChanged: (_) => setState(() {}),
            style: const TextStyle(fontSize: 12),
            decoration: const InputDecoration(
              hintText: 'Or enter image URL (https://... or data:image...)',
              hintStyle: TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
              isDense: true,
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }
}
