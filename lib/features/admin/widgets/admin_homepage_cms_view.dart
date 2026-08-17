import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/homepage_cms_controller.dart';
import '../controllers/countdown_timer_controller.dart';

class AdminHomepageCmsView extends ConsumerStatefulWidget {
  const AdminHomepageCmsView({super.key});

  @override
  ConsumerState<AdminHomepageCmsView> createState() => _AdminHomepageCmsViewState();
}

class _AdminHomepageCmsViewState extends ConsumerState<AdminHomepageCmsView> {
  int _selectedTab = 0; // 0: Sections, 1: SEO, 2: Theme, 3: Custom CSS/JS
  bool _isSaving = false;
  bool _allChangesSaved = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cmsState = ref.read(homepageCmsProvider);
      setState(() {
        _sectionsList = List<Map<String, dynamic>>.from(cmsState.sections.map((s) => Map<String, dynamic>.from(s)));
      });
    });
  }

  void _syncProvider() {
    ref.read(homepageCmsProvider.notifier).updateSections(_sectionsList);
  }

  // Track collapsed section IDs
  final Set<String> _collapsedSectionIds = {};

  // SEO Controller State
  final _metaTitleCtrl = TextEditingController(text: 'Vaidyam Botanicals • Pure Herbal Skincare & Wellness');
  final _metaDescCtrl = TextEditingController(text: 'Discover 100% authentic Ayurvedic formulations, herbal hair oils, serums, and natural soaps.');

  // Custom CSS/JS State
  final _customCssCtrl = TextEditingController(text: '/* Custom Global Styling */\n.hero-slider { border-radius: 16px; }\n.deal-card:hover { transform: translateY(-4px); }');
  final _customJsCtrl = TextEditingController(text: '// Custom Analytics & Scripts\nconsole.log("Cosmyra Homepage Loaded");');

  // Homepage Sections Data
  List<Map<String, dynamic>> _sectionsList = [
    {
      'id': 'sec-1',
      'number': 1,
      'title': 'Hero Banner / Slider',
      'isActive': true,
      'description': 'Main banner slider that appears at the top of the homepage.',
      'meta': '5 Slides • Auto Play: 5s • Show Arrows: Yes • Show Dots: Yes',
      'type': 'slider',
      'items': [
        {'title': 'Monsoon Herbal Sale', 'sub': 'Flat 20% OFF', 'color': const Color(0xFFFEF3C7)},
        {'title': 'Pure Neem Facewash', 'sub': 'New Launch', 'color': const Color(0xFFD1FAE5)},
        {'title': 'Kumkumadi Tailam', 'sub': 'Best Seller', 'color': const Color(0xFFEEF2FF)},
        {'title': 'Ayurvedic Hair Care', 'sub': '100% Natural', 'color': const Color(0xFFE0E7FF)},
        {'title': 'Botanical Soaps Pack', 'sub': 'Organic', 'color': const Color(0xFFF3E8FF)},
      ],
      'addLabel': '+ Add Slide',
    },
    {
      'id': 'sec-2',
      'number': 2,
      'title': 'Shop by Categories',
      'isActive': true,
      'description': 'Category grid section with icons and category links.',
      'meta': '8 Categories • Columns: 8 • Style: Circle • Show Title: Yes',
      'type': 'categories',
      'items': [
        {'name': 'Haircare', 'title': 'Haircare & Oils', 'icon': Icons.spa, 'emoji': '💇', 'asset': 'assets/images/shampoo.jpg'},
        {'name': 'Skincare', 'title': 'Skincare & Serums', 'icon': Icons.face, 'emoji': '✨', 'asset': 'assets/images/facewash.jpg'},
        {'name': 'Soaps', 'title': 'Organic Soaps', 'icon': Icons.clean_hands, 'emoji': '🧴', 'asset': 'assets/images/soap.jpg'},
        {'name': 'Wellness Oils', 'title': 'Wellness Oils', 'icon': Icons.opacity, 'emoji': '🌿', 'asset': 'assets/images/soap.jpg'},
        {'name': 'Elixirs', 'title': 'Radiance Elixirs', 'icon': Icons.local_pharmacy, 'emoji': '🌸', 'asset': 'assets/images/shampoo.jpg'},
        {'name': 'Gift Combos', 'title': 'Gift Combos', 'icon': Icons.card_giftcard, 'emoji': '🎁', 'asset': 'assets/images/soap.jpg'},
        {'name': 'Aloe Vera', 'title': 'Aloe & Hydration', 'icon': Icons.eco, 'emoji': '💧', 'asset': 'assets/images/facewash.jpg'},
        {'name': 'Body Care', 'title': 'Body Thailams', 'icon': Icons.self_improvement, 'emoji': '🍃', 'asset': 'assets/images/soap.jpg'},
      ],
      'addLabel': '+ Add Category',
    },
    {
      'id': 'sec-3',
      'number': 3,
      'title': "Today's Best Deals",
      'isActive': true,
      'description': 'Showcase best selling products with offers.',
      'meta': '6 Products • Show Discount: Yes • Show Rating: Yes',
      'type': 'deals',
      'items': [
        {'name': 'Anti-Dandruff Shampoo', 'tag': '29% OFF', 'price': '₹399'},
        {'name': 'De-Tan Botanical Soap', 'tag': '23% OFF', 'price': '₹199'},
        {'name': 'Deep Clean Face Wash', 'tag': '28% OFF', 'price': '₹299'},
        {'name': 'Herbal Hair Oil', 'tag': '25% OFF', 'price': '₹349'},
        {'name': 'Vitamin C Serum', 'tag': '20% OFF', 'price': '₹599'},
        {'name': 'Kumkumadi Night Cream', 'tag': '25% OFF', 'price': '₹699'},
      ],
      'addLabel': '+ Add Product',
    },
    {
      'id': 'sec-4',
      'number': 4,
      'title': 'Trending & Popular Formulations',
      'isActive': true,
      'description': 'Highlight trending and popular formulations.',
      'meta': '4 Products • Layout: Horizontal • Show Filter: Yes',
      'type': 'trending',
      'items': [
        {'name': 'Bhringraj Elixir', 'tag': 'Trending'},
        {'name': 'Nalpamaradi Oil', 'tag': 'Popular'},
        {'name': 'Ubtan Scrub', 'tag': 'New'},
        {'name': 'Rose Water Toner', 'tag': 'Hot'},
      ],
      'addLabel': '+ Add Item',
    },
    {
      'id': 'sec-5',
      'number': 5,
      'title': 'Benefits / Trust Badges',
      'isActive': true,
      'description': 'Key features and trust indicators.',
      'meta': '4 Items • Style: Icon + Text • Background: Light',
      'type': 'benefits',
      'items': [
        {'title': 'Free Shipping', 'sub': 'On orders over ₹999', 'icon': Icons.local_shipping_outlined},
        {'title': 'Easy Returns', 'sub': 'Within 7 days', 'icon': Icons.replay_outlined},
        {'title': 'Best Quality', 'sub': '100% Original', 'icon': Icons.verified_outlined},
        {'title': 'Secure Payments', 'sub': 'Multiple options', 'icon': Icons.lock_outline},
      ],
      'addLabel': '+ Add Item',
    },
    {
      'id': 'sec-6',
      'number': 6,
      'title': 'Top Brands',
      'isActive': true,
      'description': 'Display top brands customers love.',
      'meta': '6 Brands • Style: Logo Grid • Show Title: Yes',
      'type': 'brands',
      'items': [
        {'name': 'VAIDYAM', 'tag': 'Organic Botanicals'},
        {'name': 'KOTTAKKAL', 'tag': 'Traditional Ayurveda'},
        {'name': 'FOREST ESSENTIALS', 'tag': 'Luxurious Beauty'},
        {'name': 'KAMA AYURVEDA', 'tag': 'Pure Formulations'},
        {'name': 'BIOTIQUE', 'tag': 'Botanical Skincare'},
        {'name': 'COSMYRA', 'tag': 'Ayurvedic Formulations'},
      ],
      'addLabel': '+ Add Brand',
    },
    {
      'id': 'sec-7',
      'number': 7,
      'title': 'Newsletter Section',
      'isActive': true,
      'description': 'Newsletter subscription section.',
      'meta': 'Style: Center • Background: Dark',
      'type': 'newsletter',
      'items': [],
      'addLabel': '',
    },
  ];

  void _reindexSections() {
    for (int i = 0; i < _sectionsList.length; i++) {
      _sectionsList[i]['number'] = i + 1;
    }
  }

  void _moveSection(int currentIndex, int direction) {
    final newIndex = currentIndex + direction;
    if (newIndex < 0 || newIndex >= _sectionsList.length) return;

    setState(() {
      final item = _sectionsList.removeAt(currentIndex);
      _sectionsList.insert(newIndex, item);
      _reindexSections();
      _allChangesSaved = false;
    });
    _syncProvider();
  }

  void _showReorderSectionsModal() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text('Reorder Homepage Sections', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              content: SizedBox(
                width: 500,
                height: 400,
                child: ReorderableListView.builder(
                  itemCount: _sectionsList.length,
                  onReorder: (oldIndex, newIndex) {
                    setState(() {
                      if (newIndex > oldIndex) newIndex -= 1;
                      final item = _sectionsList.removeAt(oldIndex);
                      _sectionsList.insert(newIndex, item);
                      _reindexSections();
                      _allChangesSaved = false;
                    });
                    _syncProvider();
                    setModalState(() {});
                  },
                  itemBuilder: (context, index) {
                    final sec = _sectionsList[index];
                    return Card(
                      key: ValueKey(sec['id']),
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        leading: CircleAvatar(
                          radius: 14,
                          backgroundColor: const Color(0xFFEEF2FF),
                          child: Text('${index + 1}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF4F46E5))),
                        ),
                        title: Text(sec['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        subtitle: Text(sec['description'], style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_upward, size: 16),
                              onPressed: index > 0
                                  ? () {
                                      _moveSection(index, -1);
                                      setModalState(() {});
                                    }
                                  : null,
                            ),
                            IconButton(
                              icon: const Icon(Icons.arrow_downward, size: 16),
                              onPressed: index < _sectionsList.length - 1
                                  ? () {
                                      _moveSection(index, 1);
                                      setModalState(() {});
                                    }
                                  : null,
                            ),
                            const Icon(Icons.drag_handle, color: Color(0xFF9CA3AF)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              actions: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4F46E5), foregroundColor: Colors.white),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Done'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showAddSectionModal() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Add New Homepage Section', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          content: SizedBox(
            width: 450,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildSectionTemplateTile('Testimonials & Reviews', 'Show customer feedback carousel', Icons.rate_review_outlined),
                  _buildSectionTemplateTile('Video Banner', 'Embed YouTube or HTML5 video background', Icons.play_circle_outline),
                  _buildSectionTemplateTile('FAQ Accordion', 'Frequently asked questions block', Icons.quiz_outlined),
                  _buildSectionTemplateTile('Instagram Feed', 'Live Instagram posts grid', Icons.camera_alt_outlined),
                  _buildSectionTemplateTile('Countdown Flash Sale', 'Timer countdown for flash deals', Icons.timer_outlined),
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
          _sectionsList.add({
            'id': 'sec-${_sectionsList.length + 1}',
            'number': _sectionsList.length + 1,
            'title': title,
            'isActive': true,
            'description': desc,
            'meta': 'Active • Custom Block',
            'type': 'custom',
            'items': [],
            'addLabel': '+ Add Item',
          });
          _reindexSections();
          _allChangesSaved = false;
        });
        _syncProvider();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Section "$title" added!')));
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
          title: Text('Edit Section: ${section['title']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
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
                _syncProvider();
                Navigator.pop(context);
              },
              child: const Text('Save Changes'),
            ),
          ],
        );
      },
    );
  }

  void _showSectionSettingsDialog(Map<String, dynamic> section) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Section Settings: ${section['title']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const ListTile(title: Text('Layout Width'), subtitle: Text('Full Width (100%)')),
              const ListTile(title: Text('Background Style'), subtitle: Text('Light Clean Background')),
              const ListTile(title: Text('Mobile Animation'), subtitle: Text('Smooth Fade Slide')),
            ],
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4F46E5), foregroundColor: Colors.white),
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _showAddItemDialog(Map<String, dynamic> section) {
    final titleCtrl = TextEditingController();
    final subCtrl = TextEditingController();
    String selectedEmoji = section['type'] == 'categories' ? '✨' : '';

    final popularEmojis = ['💇', '✨', '🧴', '🌿', '🌸', '🎁', '💧', '🍃', '🧪', '💆', '☀️', '⚡', '❤️', '👑'];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text('Add Item to ${section['title']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              content: SizedBox(
                width: 420,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: titleCtrl,
                        decoration: InputDecoration(
                          labelText: section['type'] == 'categories' ? 'Category Name' : 'Item Name / Title',
                          hintText: section['type'] == 'categories' ? 'e.g. Face Serum' : 'e.g. Kumkumadi Serum',
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (section['type'] != 'categories')
                        TextField(
                          controller: subCtrl,
                          decoration: const InputDecoration(labelText: 'Subtitle / Discount Tag / Price', hintText: 'e.g. 20% OFF or ₹399'),
                        ),

                      if (section['type'] == 'categories') ...[
                        const SizedBox(height: 16),
                        const Text('Choose Category Icon / Emoji:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF374151))),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: popularEmojis.map((e) {
                            final isSel = selectedEmoji == e;
                            return InkWell(
                              onTap: () {
                                setModalState(() => selectedEmoji = e);
                              },
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: isSel ? const Color(0xFFEEF2FF) : const Color(0xFFF3F4F6),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: isSel ? const Color(0xFF4F46E5) : Colors.transparent, width: 2),
                                ),
                                child: Text(e, style: const TextStyle(fontSize: 22)),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Text(
                              selectedEmoji.isNotEmpty ? 'Selected Icon: $selectedEmoji' : 'Selected Icon: None (No Icon)',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF4F46E5)),
                            ),
                            const Spacer(),
                            if (selectedEmoji.isNotEmpty)
                              TextButton.icon(
                                onPressed: () => setModalState(() => selectedEmoji = ''),
                                icon: const Icon(Icons.close, size: 14, color: Color(0xFFDC2626)),
                                label: const Text('Remove Icon', style: TextStyle(fontSize: 11, color: Color(0xFFDC2626))),
                              ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4F46E5), foregroundColor: Colors.white),
                  onPressed: () {
                    final nameText = titleCtrl.text.trim();
                    if (nameText.isNotEmpty) {
                      setState(() {
                        final items = section['items'] as List;
                        items.add({
                          'title': nameText,
                          'name': nameText,
                          'sub': subCtrl.text.trim(),
                          'tag': subCtrl.text.trim().isNotEmpty ? subCtrl.text.trim() : 'New',
                          'price': subCtrl.text.trim().contains('₹') ? subCtrl.text.trim() : '₹299',
                          'color': const Color(0xFFEEF2FF),
                          'icon': Icons.spa,
                          'emoji': selectedEmoji,
                        });
                        if (section['type'] == 'categories') {
                          section['meta'] = '${items.length} Categories • Columns: ${items.length} • Style: Circle • Show Title: Yes';
                        }
                        _allChangesSaved = false;
                      });
                      _syncProvider();
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Added "$nameText" to ${section['title']}')));
                    }
                  },
                  child: const Text('Add Item'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditItemDialog(Map<String, dynamic> section, int itemIdx) {
    final items = section['items'] as List;
    final item = items[itemIdx] as Map<String, dynamic>;

    final titleCtrl = TextEditingController(text: item['title']?.toString() ?? item['name']?.toString() ?? '');
    final subCtrl = TextEditingController(text: item['sub']?.toString() ?? item['tag']?.toString() ?? '');
    String selectedEmoji = item['emoji']?.toString() ?? '';

    final popularEmojis = ['💇', '✨', '🧴', '🌿', '🌸', '🎁', '💧', '🍃', '🧪', '💆', '☀️', '⚡', '❤️', '👑'];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text('Edit ${item['name'] ?? 'Item'}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              content: SizedBox(
                width: 420,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: titleCtrl,
                        decoration: InputDecoration(
                          labelText: section['type'] == 'categories' ? 'Category Name' : 'Item Name / Title',
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (section['type'] != 'categories')
                        TextField(
                          controller: subCtrl,
                          decoration: const InputDecoration(labelText: 'Subtitle / Tag / Price'),
                        ),

                      if (section['type'] == 'categories') ...[
                        const SizedBox(height: 16),
                        const Text('Category Icon / Emoji:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF374151))),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: popularEmojis.map((e) {
                            final isSel = selectedEmoji == e;
                            return InkWell(
                              onTap: () {
                                setModalState(() => selectedEmoji = e);
                              },
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: isSel ? const Color(0xFFEEF2FF) : const Color(0xFFF3F4F6),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: isSel ? const Color(0xFF4F46E5) : Colors.transparent, width: 2),
                                ),
                                child: Text(e, style: const TextStyle(fontSize: 22)),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Text(
                              selectedEmoji.isNotEmpty ? 'Selected Icon: $selectedEmoji' : 'Selected Icon: None (No Icon)',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF4F46E5)),
                            ),
                            const Spacer(),
                            if (selectedEmoji.isNotEmpty)
                              TextButton.icon(
                                onPressed: () => setModalState(() => selectedEmoji = ''),
                                icon: const Icon(Icons.close, size: 14, color: Color(0xFFDC2626)),
                                label: const Text('Remove Icon', style: TextStyle(fontSize: 11, color: Color(0xFFDC2626))),
                              ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  style: TextButton.styleFrom(foregroundColor: const Color(0xFFDC2626)),
                  onPressed: () {
                    setState(() {
                      items.removeAt(itemIdx);
                      _allChangesSaved = false;
                    });
                    _syncProvider();
                    Navigator.pop(context);
                  },
                  child: const Text('Delete Item'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4F46E5), foregroundColor: Colors.white),
                  onPressed: () {
                    final nameText = titleCtrl.text.trim();
                    if (nameText.isNotEmpty) {
                      setState(() {
                        item['title'] = nameText;
                        item['name'] = nameText;
                        item['sub'] = subCtrl.text.trim();
                        item['emoji'] = selectedEmoji;
                        _allChangesSaved = false;
                      });
                      _syncProvider();
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Updated "$nameText"')));
                    }
                  },
                  child: const Text('Save Item'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _confirmDeleteSection(Map<String, dynamic> section) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Section?'),
          content: Text('Are you sure you want to delete "${section['title']}"?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFDC2626), foregroundColor: Colors.white),
              onPressed: () {
                setState(() {
                  _sectionsList.removeWhere((s) => s['id'] == section['id']);
                  _reindexSections();
                  _allChangesSaved = false;
                });
                _syncProvider();
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
    _syncProvider();
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        setState(() {
          _isSaving = false;
          _allChangesSaved = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All homepage changes published to live storefront!')),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Page Header & Actions Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Homepage Content Manager',
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
                    'Manage, customize and control all sections of your homepage.',
                    style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
                  ),
                ],
              ),
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Opening live storefront preview...')),
                      );
                    },
                    icon: const Icon(Icons.remove_red_eye_outlined, size: 18, color: Color(0xFF374151)),
                    label: const Text('Preview Homepage', style: TextStyle(color: Color(0xFF374151), fontSize: 13, fontWeight: FontWeight.w600)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      side: const BorderSide(color: Color(0xFFD1D5DB)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton.icon(
                    onPressed: _showAddSectionModal,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('+ Add Section ▾', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4F46E5),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 24),

          // 2. Tab Bar & Global Save Strip
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Tabs List
              Row(
                children: [
                  _buildNavTab(0, 'Sections', Icons.grid_view_outlined),
                  const SizedBox(width: 8),
                  _buildNavTab(1, 'SEO Settings', Icons.language_outlined),
                  const SizedBox(width: 8),
                  _buildNavTab(2, 'Theme Settings', Icons.palette_outlined),
                  const SizedBox(width: 8),
                  _buildNavTab(3, 'Custom CSS/JS', Icons.code_outlined),
                  const SizedBox(width: 8),
                  _buildNavTab(4, 'Sale Timer Control ⏱️', Icons.timer_outlined),
                ],
              ),

              // Save Status & Button
              Row(
                children: [
                  Row(
                    children: [
                      Icon(_allChangesSaved ? Icons.check_circle : Icons.error_outline, size: 14, color: _allChangesSaved ? const Color(0xFF059669) : const Color(0xFFD97706)),
                      const SizedBox(width: 4),
                      Text(
                        _allChangesSaved ? 'All changes saved' : 'Unsaved changes',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _allChangesSaved ? const Color(0xFF059669) : const Color(0xFFD97706)),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
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

          const SizedBox(height: 20),

          // 3. Tab Body Views
          if (_selectedTab == 0) _buildSectionsTabBody(),
          if (_selectedTab == 1) _buildSeoTabBody(),
          if (_selectedTab == 2) _buildThemeTabBody(),
          if (_selectedTab == 3) _buildCustomCssJsTabBody(),
          if (_selectedTab == 4) _buildSaleTimerTabBody(),
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
          boxShadow: isActive ? [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 4)] : null,
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

  // ---------------- TAB 0: SECTIONS MANAGER LIST ----------------
  Widget _buildSectionsTabBody() {
    return Column(
      children: [
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _sectionsList.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final sec = _sectionsList[index];
            return _buildSectionCard(sec, index);
          },
        ),

        const SizedBox(height: 20),

        // Bottom Tip Bar & Reorder Action
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.info_outline, size: 16, color: Color(0xFF4F46E5)),
                  SizedBox(width: 8),
                  Text('Tip: Drag and drop sections to reorder them on your homepage.', style: TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                ],
              ),
              OutlinedButton.icon(
                onPressed: _showReorderSectionsModal,
                icon: const Icon(Icons.swap_vert, size: 16, color: Color(0xFF374151)),
                label: const Text('Reorder Sections', style: TextStyle(fontSize: 12, color: Color(0xFF374151))),
                style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFFD1D5DB))),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionCard(Map<String, dynamic> sec, int index) {
    final isActive = sec['isActive'] == true;
    final isCollapsed = _collapsedSectionIds.contains(sec['id']);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Up / Down Reorder Buttons
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    onTap: index > 0 ? () => _moveSection(index, -1) : null,
                    child: Icon(Icons.arrow_drop_up, color: index > 0 ? const Color(0xFF4F46E5) : const Color(0xFFD1D5DB), size: 20),
                  ),
                  InkWell(
                    onTap: index < _sectionsList.length - 1 ? () => _moveSection(index, 1) : null,
                    child: Icon(Icons.arrow_drop_down, color: index < _sectionsList.length - 1 ? const Color(0xFF4F46E5) : const Color(0xFFD1D5DB), size: 20),
                  ),
                ],
              ),
              const SizedBox(width: 6),

              // Number Badge Circle
              Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(color: Color(0xFFEEF2FF), shape: BoxShape.circle),
                child: Center(
                  child: Text(
                    '${sec['number']}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF4F46E5)),
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Title & Meta Information
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(sec['title'], style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
                        const SizedBox(width: 8),
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
                    Text(sec['description'], style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
                    const SizedBox(height: 2),
                    Text(sec['meta'], style: const TextStyle(fontSize: 10, color: Color(0xFF9CA3AF), fontWeight: FontWeight.w500)),
                  ],
                ),
              ),

              // Action Buttons Row
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
                      _syncProvider();
                    },
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 18, color: Color(0xFF6B7280)),
                    tooltip: 'Edit Title & Subtitle',
                    onPressed: () => _showEditSectionDialog(sec),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add, size: 18, color: Color(0xFF6B7280)),
                    tooltip: 'Add Item',
                    onPressed: () => _showAddItemDialog(sec),
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings_outlined, size: 18, color: Color(0xFF6B7280)),
                    tooltip: 'Section Settings',
                    onPressed: () => _showSectionSettingsDialog(sec),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy, size: 18, color: Color(0xFF6B7280)),
                    tooltip: 'Duplicate Section',
                    onPressed: () {
                      setState(() {
                        final copy = Map<String, dynamic>.from(sec);
                        copy['id'] = 'sec-${_sectionsList.length + 1}';
                        copy['number'] = _sectionsList.length + 1;
                        copy['title'] = '${sec['title']} (Copy)';
                        _sectionsList.insert(index + 1, copy);
                        _reindexSections();
                        _allChangesSaved = false;
                      });
                      _syncProvider();
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 18, color: Color(0xFFDC2626)),
                    tooltip: 'Delete Section',
                    onPressed: () => _confirmDeleteSection(sec),
                  ),
                  IconButton(
                    icon: Icon(isCollapsed ? Icons.keyboard_arrow_right : Icons.keyboard_arrow_down, size: 18, color: const Color(0xFF9CA3AF)),
                    tooltip: isCollapsed ? 'Expand Preview' : 'Collapse Preview',
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

          if (!isCollapsed) ...[
            const SizedBox(height: 14),

            // Visual Preview Strip for Items
            if (sec['type'] == 'newsletter') ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF0B132B),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Subscribe to our newsletter', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                        Text('Get updates on offers, new formulations and botanical rituals.', style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 10)),
                      ],
                    ),
                    const Spacer(),
                    Container(
                      width: 180,
                      height: 32,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Enter your email address', style: TextStyle(fontSize: 10, color: Color(0xFF9CA3AF))),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(color: const Color(0xFF4F46E5), borderRadius: BorderRadius.circular(6)),
                      child: const Text('Subscribe', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ],
                ),
              ),
            ] else ...[
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    ...(sec['items'] as List).asMap().entries.map((entry) {
                      final itemIdx = entry.key;
                      final item = entry.value;

                      return Stack(
                        clipBehavior: Clip.none,
                        children: [
                          InkWell(
                            onTap: () => _showEditItemDialog(sec, itemIdx),
                            child: Container(
                              margin: const EdgeInsets.only(right: 10),
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFAFAFA),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: const Color(0xFFF3F4F6)),
                              ),
                              child: _buildItemPreviewWidget(sec['type'], item),
                            ),
                          ),
                          Positioned(
                            top: -6,
                            right: 4,
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  (sec['items'] as List).removeAt(itemIdx);
                                  if (sec['type'] == 'categories') {
                                    sec['meta'] = '${(sec['items'] as List).length} Categories • Columns: ${(sec['items'] as List).length} • Style: Circle • Show Title: Yes';
                                  }
                                  _allChangesSaved = false;
                                });
                                _syncProvider();
                              },
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: const BoxDecoration(color: Color(0xFFDC2626), shape: BoxShape.circle),
                                child: const Icon(Icons.close, size: 10, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      );
                    }),

                    // Add Item CTA Button Card
                    if (sec['addLabel'].toString().isNotEmpty)
                      InkWell(
                        onTap: () => _showAddItemDialog(sec),
                        child: Container(
                          width: 90,
                          height: 54,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFE5E7EB), style: BorderStyle.solid),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.add, size: 16, color: Color(0xFF6B7280)),
                              const SizedBox(height: 2),
                              Text(sec['addLabel'], style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF6B7280)), textAlign: TextAlign.center),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildItemPreviewWidget(String type, Map<String, dynamic> item) {
    switch (type) {
      case 'slider':
        return Container(
          width: 80,
          height: 40,
          decoration: BoxDecoration(color: item['color'] as Color? ?? const Color(0xFFEEF2FF), borderRadius: BorderRadius.circular(6)),
          child: Center(
            child: Text(item['title']?.toString() ?? 'Slide', style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Color(0xFF111827)), textAlign: TextAlign.center),
          ),
        );
      case 'categories':
        final emoji = item['emoji']?.toString() ?? '';
        final iconData = item['icon'] is IconData ? (item['icon'] as IconData) : null;
        final name = item['name']?.toString() ?? item['title']?.toString() ?? 'Category';

        return Column(
          children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: const Color(0xFFEEF2FF),
              child: emoji.isNotEmpty
                  ? Text(emoji, style: const TextStyle(fontSize: 12))
                  : (iconData != null ? Icon(iconData, size: 14, color: const Color(0xFF4F46E5)) : const Icon(Icons.spa, size: 14, color: Color(0xFF4F46E5))),
            ),
            const SizedBox(height: 2),
            Text(name, style: const TextStyle(fontSize: 9, color: Color(0xFF374151))),
          ],
        );
      case 'deals':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(color: const Color(0xFFFEE2E2), borderRadius: BorderRadius.circular(4)),
              child: Text(item['tag']?.toString() ?? 'OFFER', style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Color(0xFFDC2626))),
            ),
            const SizedBox(height: 2),
            Text(item['name']?.toString() ?? 'Product', style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
            Text(item['price']?.toString() ?? '₹299', style: const TextStyle(fontSize: 9, color: Color(0xFF059669))),
          ],
        );
      case 'benefits':
        return Row(
          children: [
            Icon(item['icon'] as IconData? ?? Icons.verified_outlined, size: 16, color: const Color(0xFF4F46E5)),
            const SizedBox(width: 6),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item['title']?.toString() ?? 'Feature', style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
                Text(item['sub']?.toString() ?? '', style: const TextStyle(fontSize: 8, color: Color(0xFF6B7280))),
              ],
            ),
          ],
        );
      case 'brands':
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Text(item['name']?.toString() ?? 'Brand', style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF374151))),
        );
      default:
        return Text(item['name']?.toString() ?? item['title']?.toString() ?? 'Item', style: const TextStyle(fontSize: 9));
    }
  }

  // ---------------- TAB 1: SEO SETTINGS ----------------
  Widget _buildSeoTabBody() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE5E7EB))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Homepage SEO & Meta Tags', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
          const SizedBox(height: 4),
          const Text('Optimize search engine visibility and social media sharing cards for your homepage.', style: TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
          const SizedBox(height: 20),
          TextField(controller: _metaTitleCtrl, decoration: const InputDecoration(labelText: 'Meta Title', hintText: 'Enter title tag...')),
          const SizedBox(height: 16),
          TextField(controller: _metaDescCtrl, maxLines: 3, decoration: const InputDecoration(labelText: 'Meta Description', hintText: 'Enter meta description...')),
          const SizedBox(height: 16),
          const TextField(decoration: InputDecoration(labelText: 'OpenGraph Image URL', hintText: 'https://cosmyra.cloud/assets/og-image.jpg')),
          const SizedBox(height: 16),
          const TextField(decoration: InputDecoration(labelText: 'Canonical URL', hintText: 'https://cosmyra.cloud/')),
        ],
      ),
    );
  }

  // ---------------- TAB 2: THEME SETTINGS ----------------
  Widget _buildThemeTabBody() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE5E7EB))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Homepage Styling & Theme Settings', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
          const SizedBox(height: 16),
          Row(
            children: [
              const Text('Primary Accent Color: ', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              Container(width: 24, height: 24, decoration: const BoxDecoration(color: Color(0xFF4F46E5), shape: BoxShape.circle)),
              const SizedBox(width: 8),
              const Text('#4F46E5', style: TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Text('Font Family: ', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(border: Border.all(color: const Color(0xFFE5E7EB)), borderRadius: BorderRadius.circular(6)),
                child: const Text('Plus Jakarta Sans / Inter', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
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
          const Text('Custom CSS Code', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
          const SizedBox(height: 6),
          TextField(controller: _customCssCtrl, maxLines: 6, style: const TextStyle(fontFamily: 'monospace', fontSize: 12), decoration: const InputDecoration(border: OutlineInputBorder())),
          const SizedBox(height: 20),
          const Text('Custom JavaScript / Analytics Header Code', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
          const SizedBox(height: 6),
          TextField(controller: _customJsCtrl, maxLines: 6, style: const TextStyle(fontFamily: 'monospace', fontSize: 12), decoration: const InputDecoration(border: OutlineInputBorder())),
        ],
      ),
    );
  }

  // ---------------- TAB 4: SALE TIMER CONTROL ----------------
  Widget _buildSaleTimerTabBody() {
    final timerState = ref.watch(countdownTimerProvider);
    final timerNotifier = ref.read(countdownTimerProvider.notifier);

    final hoursCtrl = TextEditingController(text: (timerState.remainingSeconds ~/ 3600).toString().padLeft(2, '0'));
    final minsCtrl = TextEditingController(text: ((timerState.remainingSeconds % 3600) ~/ 60).toString().padLeft(2, '0'));
    final secsCtrl = TextEditingController(text: (timerState.remainingSeconds % 60).toString().padLeft(2, '0'));
    final labelCtrl = TextEditingController(text: timerState.labelText);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.timer_outlined, color: Color(0xFFDC2626), size: 24),
                        SizedBox(width: 10),
                        Text(
                          'Homepage Sale Countdown Timer Manager',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Text('Timer Active', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        Switch(
                          value: timerState.isActive,
                          onChanged: (val) => timerNotifier.toggleActive(val),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'Set custom sale duration, reset countdown timers, and manage banner ticker text live on the homepage.',
                  style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
                ),
                const Divider(height: 32),

                // Live Preview Box
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFCA5A5)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.remove_red_eye_outlined, color: Color(0xFFDC2626), size: 20),
                      const SizedBox(width: 10),
                      const Text(
                        'Live Storefront Banner Preview:  ',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF991B1B)),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFFCA5A5)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.timer_outlined, size: 14, color: Color(0xFFDC2626)),
                            const SizedBox(width: 5),
                            Text(
                              '${timerState.labelText} ',
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFFB91C1C)),
                            ),
                            Text(
                              '${(timerState.remainingSeconds ~/ 3600).toString().padLeft(2, '0')}h ${((timerState.remainingSeconds % 3600) ~/ 60).toString().padLeft(2, '0')}m ${(timerState.remainingSeconds % 60).toString().padLeft(2, '0')}s',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFFDC2626)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Quick Preset Buttons Row
                const Text('Quick Timer Reset Presets:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF374151))),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 12,
                  runSpacing: 10,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        timerNotifier.resetTimer(hours: 24, minutes: 0, seconds: 0);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reset countdown timer to 24 Hours!')));
                      },
                      icon: const Icon(Icons.replay_outlined, size: 16),
                      label: const Text('Reset to 24 Hours 🔄'),
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4F46E5), foregroundColor: Colors.white),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        timerNotifier.resetTimer(hours: 12, minutes: 0, seconds: 0);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reset countdown timer to 12 Hours!')));
                      },
                      icon: const Icon(Icons.timer, size: 16),
                      label: const Text('Reset to 12 Hours ⏱️'),
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF059669), foregroundColor: Colors.white),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        timerNotifier.resetTimer(hours: 6, minutes: 0, seconds: 0);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reset countdown timer to 6 Hours!')));
                      },
                      icon: const Icon(Icons.local_fire_department, size: 16),
                      label: const Text('Reset to 6 Hours 🔥'),
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD97706), foregroundColor: Colors.white),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        timerNotifier.resetTimer(hours: 1, minutes: 0, seconds: 0);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reset countdown timer to 1 Hour Flash Sale!')));
                      },
                      icon: const Icon(Icons.bolt, size: 16),
                      label: const Text('Flash Sale (1 Hour) ⚡'),
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFDC2626), foregroundColor: Colors.white),
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                // Custom Timer Duration Form Inputs
                const Text('Set Custom Timer Duration & Banner Text:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF374151))),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: hoursCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Hours',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.hourglass_top),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: minsCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Minutes',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.access_time),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: secsCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Seconds',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.timer),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: labelCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Timer Label Banner Text',
                    hintText: 'e.g. 🔥 Sale Ends In: or ⚡ Monsoon Special Ends:',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.subtitles),
                  ),
                ),
                const SizedBox(height: 18),
                ElevatedButton.icon(
                  onPressed: () {
                    final h = int.tryParse(hoursCtrl.text) ?? 5;
                    final m = int.tryParse(minsCtrl.text) ?? 42;
                    final s = int.tryParse(secsCtrl.text) ?? 18;
                    timerNotifier.resetTimer(hours: h, minutes: m, seconds: s, labelText: labelCtrl.text);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Updated Sale Timer to ${h}h ${m}m ${s}s with label "${labelCtrl.text}"!')),
                    );
                  },
                  icon: const Icon(Icons.save, size: 18),
                  label: const Text('Apply & Save Custom Timer', style: TextStyle(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4F46E5),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
