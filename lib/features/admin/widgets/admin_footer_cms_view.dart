import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AdminFooterCmsView extends ConsumerStatefulWidget {
  const AdminFooterCmsView({super.key});

  @override
  ConsumerState<AdminFooterCmsView> createState() => _AdminFooterCmsViewState();
}

class _AdminFooterCmsViewState extends ConsumerState<AdminFooterCmsView> {
  int _selectedTab = 0; // 0: Footer Sections, 1: Footer Settings, 2: SEO & Schema, 3: Custom CSS/JS, 4: Revision History
  bool _isSaving = false;
  bool _allChangesSaved = true;

  // Track collapsed section IDs
  final Set<String> _collapsedSectionIds = {};

  // SEO & Schema Controller State
  final _footerTitleCtrl = TextEditingController(text: 'Vaidyam Botanicals • Authentic Herbal & Ayurvedic Formulations');
  final _schemaOrgCtrl = TextEditingController(text: '{\n  "@context": "https://schema.org",\n  "@type": "Organization",\n  "name": "Vaidyam Botanicals",\n  "url": "https://cosmyra.cloud"\n}');

  // Custom CSS/JS State
  final _customFooterCssCtrl = TextEditingController(text: '/* Footer Specific Styles */\n.footer-bg { background-color: #0B132B; }\n.footer-link:hover { color: #818CF8; }');
  final _customFooterJsCtrl = TextEditingController(text: '// Footer Scripts & Tracking\nconsole.log("Cosmyra Footer Initialized");');

  // Footer Sections Data
  final List<Map<String, dynamic>> _footerSectionsList = [
    {
      'id': 'fsec-1',
      'number': 1,
      'title': 'Store Info & Newsletter',
      'isActive': true,
      'description': 'Store logo, description, newsletter subscription & social links.',
      'meta': '1 Content Block • 5 Social Links',
      'type': 'newsletter_info',
    },
    {
      'id': 'fsec-2',
      'number': 2,
      'title': 'Shop Links',
      'isActive': true,
      'description': 'Important shop pages and collections.',
      'meta': '8 Links',
      'type': 'links',
      'items': ['All Categories', "Today's Deals", 'New Arrivals', 'Best Sellers', 'Featured Formulations', 'Clearance Sale'],
    },
    {
      'id': 'fsec-3',
      'number': 3,
      'title': 'Customer Service',
      'isActive': true,
      'description': 'Help center, policies and support links.',
      'meta': '6 Links',
      'type': 'links',
      'items': ['Track Your Order', 'Returns & Refunds', 'Shipping Information', 'Payment Methods', 'FAQ', 'Contact Us'],
    },
    {
      'id': 'fsec-4',
      'number': 4,
      'title': 'My Account',
      'isActive': true,
      'description': 'User account related pages.',
      'meta': '5 Links',
      'type': 'links',
      'items': ['My Orders', 'Wishlist', 'Addresses', 'Account Settings', 'Notifications', 'Logout'],
    },
    {
      'id': 'fsec-5',
      'number': 5,
      'title': 'About Us',
      'isActive': true,
      'description': 'Company information and useful links.',
      'meta': '6 Links • 1 Content Block',
      'type': 'links',
      'items': ['About Vaidyam', 'Our Story', 'Careers', 'Botanical Blog', 'Privacy Policy', 'Terms & Conditions'],
    },
    {
      'id': 'fsec-6',
      'number': 6,
      'title': 'Popular Categories',
      'isActive': true,
      'description': 'Top product categories with icons.',
      'meta': '6 Categories',
      'type': 'categories',
      'items': ['Haircare & Oils', 'Skincare & Serums', 'Organic Soaps', 'Wellness Oils', 'Body Thailams'],
    },
    {
      'id': 'fsec-7',
      'number': 7,
      'title': 'Bottom Bar',
      'isActive': true,
      'description': 'Bottom bar with extra info and payment methods.',
      'meta': '2 Content Blocks • 6 Payment Methods',
      'type': 'bottom_bar',
    },
  ];

  void _reindexSections() {
    for (int i = 0; i < _footerSectionsList.length; i++) {
      _footerSectionsList[i]['number'] = i + 1;
    }
  }

  void _moveSection(int currentIndex, int direction) {
    final newIndex = currentIndex + direction;
    if (newIndex < 0 || newIndex >= _footerSectionsList.length) return;

    setState(() {
      final item = _footerSectionsList.removeAt(currentIndex);
      _footerSectionsList.insert(newIndex, item);
      _reindexSections();
      _allChangesSaved = false;
    });
  }

  void _showAddSectionModal() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Add New Footer Section', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          content: SizedBox(
            width: 450,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildSectionTemplateTile('Navigation Links Column', 'Add custom links list', Icons.link_outlined),
                  _buildSectionTemplateTile('HTML / Rich Text Block', 'Embed custom text, HTML or banners', Icons.code_outlined),
                  _buildSectionTemplateTile('Trust & Security Badges', 'Show payment badges & security seals', Icons.verified_user_outlined),
                  _buildSectionTemplateTile('App Download Banner', 'Promote iOS & Android mobile apps', Icons.phone_iphone_outlined),
                  _buildSectionTemplateTile('Contact & Support Info', 'Display phone, email & address block', Icons.contact_support_outlined),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ],
        );
      },
    );
  }

  Widget _buildSectionTemplateTile(String title, String desc, IconData icon) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: const Color(0xFFEEF2FF), borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: const Color(0xFF4F46E5), size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      subtitle: Text(desc, style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
      trailing: const Icon(Icons.add_circle_outline, color: Color(0xFF4F46E5)),
      onTap: () {
        setState(() {
          _footerSectionsList.add({
            'id': 'fsec-${_footerSectionsList.length + 1}',
            'number': _footerSectionsList.length + 1,
            'title': title,
            'isActive': true,
            'description': desc,
            'meta': 'Active • Custom Section',
            'type': 'custom',
          });
          _reindexSections();
          _allChangesSaved = false;
        });
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Footer section "$title" added!')));
      },
    );
  }

  void _showEditSectionDialog(Map<String, dynamic> section) {
    final titleCtrl = TextEditingController(text: section['title']);
    final descCtrl = TextEditingController(text: section['description']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Edit Footer Section: ${section['title']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Section Title')),
              const SizedBox(height: 12),
              TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Description / Subtitle')),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4F46E5), foregroundColor: Colors.white),
              onPressed: () {
                setState(() {
                  section['title'] = titleCtrl.text;
                  section['description'] = descCtrl.text;
                  _allChangesSaved = false;
                });
                Navigator.pop(context);
              },
              child: const Text('Save Changes'),
            ),
          ],
        );
      },
    );
  }

  void _confirmDeleteSection(Map<String, dynamic> section) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Footer Section?'),
          content: Text('Are you sure you want to delete "${section['title']}"?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFDC2626), foregroundColor: Colors.white),
              onPressed: () {
                setState(() {
                  _footerSectionsList.removeWhere((s) => s['id'] == section['id']);
                  _reindexSections();
                  _allChangesSaved = false;
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Deleted "${section['title']}"')));
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _saveAllChanges() {
    setState(() => _isSaving = true);
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        setState(() {
          _isSaving = false;
          _allChangesSaved = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All footer changes published to live storefront!')),
        );
      }
    });
  }

  void _resetToDefault() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Footer to Default?'),
        content: const Text('This will restore default sections, links, and layout settings.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4F46E5), foregroundColor: Colors.white),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Footer settings reset to default.')));
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 1100;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Footer Content Manager',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF111827)),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEEF2FF),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text('Advanced', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF4F46E5))),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Manage and customize all footer sections, links, content, and settings.',
                    style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
                  ),
                ],
              ),
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Opening live footer preview...')),
                      );
                    },
                    icon: const Icon(Icons.remove_red_eye_outlined, size: 18, color: Color(0xFF374151)),
                    label: const Text('Preview Footer', style: TextStyle(color: Color(0xFF374151), fontSize: 13, fontWeight: FontWeight.w600)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      side: const BorderSide(color: Color(0xFFD1D5DB)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  OutlinedButton(
                    onPressed: _resetToDefault,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      side: const BorderSide(color: Color(0xFFD1D5DB)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Reset to Default', style: TextStyle(color: Color(0xFF374151), fontSize: 13, fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton.icon(
                    onPressed: _isSaving ? null : _saveAllChanges,
                    icon: _isSaving
                        ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.save_outlined, size: 16),
                    label: const Text('Save All Changes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4F46E5),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 24),

          // 2. Tab Navigation Bar
          Row(
            children: [
              _buildNavTab(0, 'Footer Sections', Icons.vertical_split_outlined),
              const SizedBox(width: 8),
              _buildNavTab(1, 'Footer Settings', Icons.settings_outlined),
              const SizedBox(width: 8),
              _buildNavTab(2, 'SEO & Schema', Icons.search_outlined),
              const SizedBox(width: 8),
              _buildNavTab(3, 'Custom CSS/JS', Icons.code_outlined),
              const SizedBox(width: 8),
              _buildNavTab(4, 'Revision History', Icons.history_outlined),
            ],
          ),

          const SizedBox(height: 20),

          // 3. Stat Summary Metrics Bar (5 Cards)
          LayoutBuilder(
            builder: (context, constraints) {
              return Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  _buildStatCard('Footer Status', 'Published •', Icons.shield_outlined, const Color(0xFF059669), const Color(0xFFD1FAE5)),
                  _buildStatCard('Last Updated', '15 Aug 2026, 08:12 PM\nby Mahboob Hasan', Icons.lock_clock_outlined, const Color(0xFF4F46E5), const Color(0xFFEEF2FF)),
                  _buildStatCard('Total Sections', '7 Active Sections', Icons.grid_view_outlined, const Color(0xFF2563EB), const Color(0xFFDBEAFE)),
                  _buildStatCard('Total Links', '48 Links', Icons.link_outlined, const Color(0xFF7C3AED), const Color(0xFFF3E8FF)),
                  _buildStatCard('Custom Content Blocks', '6 Blocks', Icons.integration_instructions_outlined, const Color(0xFFD97706), const Color(0xFFFEF3C7)),
                ],
              );
            },
          ),

          const SizedBox(height: 24),

          // 4. Main Body: Split View (Left List + Right Live Preview & Tips)
          if (_selectedTab == 0)
            isDesktop
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left Column: Manage Footer Sections List (Flex 7)
                      Expanded(flex: 7, child: _buildManageFooterSectionsColumn()),
                      const SizedBox(width: 24),
                      // Right Column: Live Preview & Quick Tips (Flex 5)
                      Expanded(flex: 5, child: _buildRightPreviewAndTipsColumn()),
                    ],
                  )
                : Column(
                    children: [
                      _buildManageFooterSectionsColumn(),
                      const SizedBox(height: 24),
                      _buildRightPreviewAndTipsColumn(),
                    ],
                  ),

          if (_selectedTab == 1) _buildFooterSettingsTabBody(),
          if (_selectedTab == 2) _buildSeoSchemaTabBody(),
          if (_selectedTab == 3) _buildCustomCssJsTabBody(),
          if (_selectedTab == 4) _buildRevisionHistoryTabBody(),
        ],
      ),
    );
  }

  Widget _buildNavTab(int index, String title, IconData icon) {
    final isActive = _selectedTab == index;
    return InkWell(
      onTap: () => setState(() => _selectedTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: isActive ? Border.all(color: const Color(0xFFE5E7EB)) : null,
          boxShadow: isActive ? [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 4)] : null,
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: isActive ? const Color(0xFF4F46E5) : const Color(0xFF6B7280)),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                color: isActive ? const Color(0xFF111827) : const Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color iconColor, Color iconBg) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 6)],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 10, color: Color(0xFF6B7280), fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: iconColor == const Color(0xFF059669) ? const Color(0xFF059669) : const Color(0xFF111827)),
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- LEFT COLUMN: MANAGE FOOTER SECTIONS ----------------
  Widget _buildManageFooterSectionsColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Manage Footer Sections', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
                SizedBox(height: 2),
                Text('Enable, disable and customize each footer section.', style: TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
              ],
            ),
            Row(
              children: const [
                Icon(Icons.drag_indicator, size: 14, color: Color(0xFF9CA3AF)),
                SizedBox(width: 4),
                Text('Drag & drop to reorder sections', style: TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
              ],
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Section Cards List
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _footerSectionsList.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final sec = _footerSectionsList[index];
            return _buildFooterSectionCard(sec, index);
          },
        ),

        const SizedBox(height: 16),

        // Add New Section Dashed Button
        InkWell(
          onTap: _showAddSectionModal,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF818CF8), style: BorderStyle.solid),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.add, size: 16, color: Color(0xFF4F46E5)),
                SizedBox(width: 6),
                Text('Add New Section', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF4F46E5))),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFooterSectionCard(Map<String, dynamic> sec, int index) {
    final isActive = sec['isActive'] == true;
    final isCollapsed = _collapsedSectionIds.contains(sec['id']);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 6)],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          Row(
            children: [
              // Up / Down Reorder
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    onTap: index > 0 ? () => _moveSection(index, -1) : null,
                    child: Icon(Icons.arrow_drop_up, color: index > 0 ? const Color(0xFF4F46E5) : const Color(0xFFD1D5DB), size: 18),
                  ),
                  InkWell(
                    onTap: index < _footerSectionsList.length - 1 ? () => _moveSection(index, 1) : null,
                    child: Icon(Icons.arrow_drop_down, color: index < _footerSectionsList.length - 1 ? const Color(0xFF4F46E5) : const Color(0xFFD1D5DB), size: 18),
                  ),
                ],
              ),
              const SizedBox(width: 6),

              // Circle Badge Number
              Container(
                width: 26,
                height: 26,
                decoration: const BoxDecoration(color: Color(0xFFEEF2FF), shape: BoxShape.circle),
                child: Center(
                  child: Text('${sec['number']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF4F46E5))),
                ),
              ),
              const SizedBox(width: 12),

              // Title & Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(sec['title'], style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: isActive ? const Color(0xFFD1FAE5) : const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            isActive ? 'Active' : 'Disabled',
                            style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: isActive ? const Color(0xFF059669) : const Color(0xFF6B7280)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(sec['description'], style: const TextStyle(fontSize: 10, color: Color(0xFF6B7280))),
                    const SizedBox(height: 2),
                    Text(sec['meta'], style: const TextStyle(fontSize: 9, color: Color(0xFF9CA3AF), fontWeight: FontWeight.w500)),
                  ],
                ),
              ),

              // Action Controls
              Row(
                children: [
                  Switch(
                    value: isActive,
                    activeThumbColor: const Color(0xFF4F46E5),
                    onChanged: (val) {
                      setState(() {
                        sec['isActive'] = val;
                        _allChangesSaved = false;
                      });
                    },
                  ),
                  const SizedBox(width: 4),
                  OutlinedButton.icon(
                    onPressed: () => _showEditSectionDialog(sec),
                    icon: const Icon(Icons.edit_outlined, size: 14),
                    label: const Text('Edit', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      minimumSize: const Size(0, 30),
                      side: const BorderSide(color: Color(0xFFD1D5DB)),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 16, color: Color(0xFFDC2626)),
                    onPressed: () => _confirmDeleteSection(sec),
                  ),
                  IconButton(
                    icon: Icon(isCollapsed ? Icons.keyboard_arrow_right : Icons.keyboard_arrow_down, size: 16, color: const Color(0xFF9CA3AF)),
                    onPressed: () {
                      setState(() {
                        if (isCollapsed) {
                          _collapsedSectionIds.remove(sec['id']);
                        } else {
                          _collapsedSectionIds.add(sec['id'] as String);
                        }
                      });
                    },
                  ),
                ],
              ),
            ],
          ),

          if (!isCollapsed && sec['items'] != null) ...[
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: (sec['items'] as List).map((item) {
                  return Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(item.toString(), style: const TextStyle(fontSize: 10, color: Color(0xFF374151), fontWeight: FontWeight.w500)),
                  );
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ---------------- RIGHT COLUMN: LIVE PREVIEW & QUICK TIPS ----------------
  Widget _buildRightPreviewAndTipsColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Bar for Live Preview
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Live Preview', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.desktop_windows_outlined, size: 14, color: Color(0xFF374151)),
                      SizedBox(width: 4),
                      Text('Desktop ▾', style: TextStyle(fontSize: 11, color: Color(0xFF374151), fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                IconButton(
                  icon: const Icon(Icons.refresh, size: 16, color: Color(0xFF6B7280)),
                  onPressed: () {},
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Dark Navy Footer Live Preview Container
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF0B132B),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Row 1: Brand & Newsletter + Link Columns
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left Brand & Newsletter Block
                  Expanded(
                    flex: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.spa, color: Colors.white, size: 18),
                            SizedBox(width: 6),
                            Text('Vaidyam Botanicals', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Your premier destination for certified organic Ayurveda formulation. Pure wellness delivered to your doorstep.',
                          style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 10, height: 1.4),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Container(
                              width: 120,
                              height: 28,
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Align(
                                alignment: Alignment.centerLeft,
                                child: Text('Enter your email', style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 9)),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(color: const Color(0xFF4F46E5), borderRadius: BorderRadius.circular(4)),
                              child: const Icon(Icons.arrow_forward, color: Colors.white, size: 14),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: const [
                            Icon(Icons.facebook, color: Color(0xFF9CA3AF), size: 14),
                            SizedBox(width: 8),
                            Icon(Icons.camera_alt, color: Color(0xFF9CA3AF), size: 14),
                            SizedBox(width: 8),
                            Icon(Icons.close, color: Color(0xFF9CA3AF), size: 14),
                            SizedBox(width: 8),
                            Icon(Icons.play_arrow, color: Color(0xFF9CA3AF), size: 14),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Column: SHOP
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('SHOP', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 0.5)),
                        SizedBox(height: 8),
                        Text('All Categories', style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 9, height: 1.6)),
                        Text("Today's Deals", style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 9, height: 1.6)),
                        Text('New Arrivals', style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 9, height: 1.6)),
                        Text('Best Sellers', style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 9, height: 1.6)),
                        Text('Clearance Sale', style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 9, height: 1.6)),
                      ],
                    ),
                  ),

                  // Column: CUSTOMER SERVICE
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('CUSTOMER SERVICE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 9, letterSpacing: 0.5)),
                        SizedBox(height: 8),
                        Text('Track Your Order', style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 9, height: 1.6)),
                        Text('Returns & Refunds', style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 9, height: 1.6)),
                        Text('Shipping Info', style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 9, height: 1.6)),
                        Text('Payment Methods', style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 9, height: 1.6)),
                        Text('Contact Us', style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 9, height: 1.6)),
                      ],
                    ),
                  ),

                  // Column: MY ACCOUNT
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('MY ACCOUNT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 9, letterSpacing: 0.5)),
                        SizedBox(height: 8),
                        Text('My Orders', style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 9, height: 1.6)),
                        Text('Wishlist', style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 9, height: 1.6)),
                        Text('Addresses', style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 9, height: 1.6)),
                        Text('Account Settings', style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 9, height: 1.6)),
                        Text('Logout', style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 9, height: 1.6)),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),
              const Divider(color: Color(0xFF1E293B)),
              const SizedBox(height: 12),

              // Row 2: Categories, Trust Badges, We Accept
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Popular Categories
                  Expanded(
                    flex: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('POPULAR CATEGORIES', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 9, letterSpacing: 0.5)),
                        SizedBox(height: 8),
                        Text('💇 Haircare & Oils', style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 9, height: 1.5)),
                        Text('✨ Skincare & Serums', style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 9, height: 1.5)),
                        Text('🧴 Organic Soaps', style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 9, height: 1.5)),
                        Text('🌿 Wellness Oils', style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 9, height: 1.5)),
                        Text('🍃 Body Thailams', style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 9, height: 1.5)),
                      ],
                    ),
                  ),

                  // Trust Badges List
                  Expanded(
                    flex: 5,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('🚚 FREE SHIPPING - On orders over ₹999', style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 9, height: 1.6)),
                        Text('🔄 EASY RETURNS - Within 7 days', style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 9, height: 1.6)),
                        Text('🛡️ 100% SECURE - Safe Payments', style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 9, height: 1.6)),
                        Text('🏅 BEST QUALITY - 100% Original Products', style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 9, height: 1.6)),
                        Text('🎧 24/7 SUPPORT - We are here to help', style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 9, height: 1.6)),
                      ],
                    ),
                  ),

                  // We Accept Badges
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('WE ACCEPT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 9, letterSpacing: 0.5)),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 4,
                          runSpacing: 4,
                          children: ['VISA', 'Mastercard', 'UPI', 'Paytm', 'PhonePe'].map((p) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(3)),
                              child: Text(p, style: const TextStyle(fontSize: 8, color: Colors.white, fontWeight: FontWeight.bold)),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),
              const Divider(color: Color(0xFF1E293B)),
              const SizedBox(height: 8),

              // Bottom Copyright Line
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text('© 2026 Vaidyam Botanicals. All Rights Reserved.', style: TextStyle(color: Color(0xFF6B7280), fontSize: 8)),
                  Text('🇮🇳 India  |  🌐 English ▾', style: TextStyle(color: Color(0xFF6B7280), fontSize: 8)),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Quick Tips Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFEEF2FF),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFC7D2FE)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Row(
                children: [
                  Icon(Icons.lightbulb_outline, size: 16, color: Color(0xFF4F46E5)),
                  SizedBox(width: 6),
                  Text('Quick Tips', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF4F46E5))),
                ],
              ),
              SizedBox(height: 8),
              Text('| Use drag & drop to reorder footer sections.', style: TextStyle(fontSize: 11, color: Color(0xFF4B5563), height: 1.5)),
              Text('| Disable a section to hide it from the website.', style: TextStyle(fontSize: 11, color: Color(0xFF4B5563), height: 1.5)),
              Text('| Changes saved here will reflect on the website in real-time.', style: TextStyle(fontSize: 11, color: Color(0xFF4B5563), height: 1.5)),
              Text("| Click 'Preview Footer' to see live changes.", style: TextStyle(fontSize: 11, color: Color(0xFF4B5563), height: 1.5)),
            ],
          ),
        ),
      ],
    );
  }

  // ---------------- TAB 1: FOOTER SETTINGS ----------------
  Widget _buildFooterSettingsTabBody() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE5E7EB))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text('Global Footer Layout & Styling Settings', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
          SizedBox(height: 16),
          ListTile(title: Text('Footer Background Color'), subtitle: Text('Dark Navy (#0B132B)')),
          ListTile(title: Text('Text & Link Accent Color'), subtitle: Text('Indigo Accent (#818CF8)')),
          ListTile(title: Text('Show Payment Badges'), subtitle: Text('Enabled (VISA, Mastercard, UPI, Paytm)')),
          ListTile(title: Text('Show App Download Banner'), subtitle: Text('Enabled (Google Play & App Store)')),
        ],
      ),
    );
  }

  // ---------------- TAB 2: SEO & SCHEMA ----------------
  Widget _buildSeoSchemaTabBody() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE5E7EB))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Footer SEO & Schema.org Structured Data', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
          const SizedBox(height: 16),
          TextField(controller: _footerTitleCtrl, decoration: const InputDecoration(labelText: 'Footer Brand Title')),
          const SizedBox(height: 16),
          TextField(controller: _schemaOrgCtrl, maxLines: 6, style: const TextStyle(fontFamily: 'monospace', fontSize: 12), decoration: const InputDecoration(labelText: 'Schema.org JSON-LD Structured Data', border: OutlineInputBorder())),
        ],
      ),
    );
  }

  // ---------------- TAB 3: CUSTOM CSS/JS ----------------
  Widget _buildCustomCssJsTabBody() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE5E7EB))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Custom Footer CSS Code', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
          const SizedBox(height: 6),
          TextField(controller: _customFooterCssCtrl, maxLines: 6, style: const TextStyle(fontFamily: 'monospace', fontSize: 12), decoration: const InputDecoration(border: OutlineInputBorder())),
          const SizedBox(height: 20),
          const Text('Custom Footer JavaScript / Analytics Script', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
          const SizedBox(height: 6),
          TextField(controller: _customFooterJsCtrl, maxLines: 6, style: const TextStyle(fontFamily: 'monospace', fontSize: 12), decoration: const InputDecoration(border: OutlineInputBorder())),
        ],
      ),
    );
  }

  // ---------------- TAB 4: REVISION HISTORY ----------------
  Widget _buildRevisionHistoryTabBody() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE5E7EB))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text('Footer Change Log & Revision History', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
          SizedBox(height: 16),
          ListTile(
            leading: Icon(Icons.history, color: Color(0xFF4F46E5)),
            title: Text('v2.4 - Added Popular Categories & Payment Badges'),
            subtitle: Text('15 Aug 2026, 08:12 PM by Mahboob Hasan'),
            trailing: Text('Active', style: TextStyle(color: Color(0xFF059669), fontWeight: FontWeight.bold)),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.history, color: Color(0xFF6B7280)),
            title: Text('v2.3 - Updated Customer Service Links'),
            subtitle: Text('14 Aug 2026, 04:30 PM by Mahboob Hasan'),
          ),
        ],
      ),
    );
  }
}
