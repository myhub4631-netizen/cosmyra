import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../config/supabase_config.dart';
import '../models/media_item_model.dart';

final adminMediaProvider = StateNotifierProvider<AdminMediaNotifier, List<MediaItem>>((ref) {
  return AdminMediaNotifier();
});

class AdminMediaNotifier extends StateNotifier<List<MediaItem>> {
  AdminMediaNotifier() : super([]) {
    _loadMediaFromStorage();
  }

  static const String _storageKey = 'cosmyra_admin_media_library_v3';

  static final List<MediaItem> _initialMediaSeed = [
    MediaItem(
      id: 'media-logo-1',
      name: 'Cosmyra Gold Luxury Emblem Logo',
      url: 'assets/images/cosmyra_logo.png',
      category: 'Logos',
      sizeBytes: 128 * 1024,
      dimensions: '512 x 512 px',
      fileType: 'PNG',
      uploadedAt: DateTime.now().subtract(const Duration(days: 30)),
    ),
    MediaItem(
      id: 'media-prod-shampoo',
      name: 'Vaidyam Anti-Dandruff Herbal Shampoo Bottle',
      url: 'assets/images/shampoo.jpg',
      category: 'Products',
      sizeBytes: 420 * 1024,
      dimensions: '1200 x 1200 px',
      fileType: 'JPEG',
      uploadedAt: DateTime.now().subtract(const Duration(days: 20)),
    ),
    MediaItem(
      id: 'media-prod-soap',
      name: 'Vaidyam Handcrafted Ayurvedic Soap Bar',
      url: 'assets/images/soap.jpg',
      category: 'Products',
      sizeBytes: 380 * 1024,
      dimensions: '1200 x 1200 px',
      fileType: 'JPEG',
      uploadedAt: DateTime.now().subtract(const Duration(days: 15)),
    ),
    MediaItem(
      id: 'media-prod-facewash',
      name: 'Vaidyam Aloe & Neem Radiance Face Wash Gel',
      url: 'assets/images/facewash.jpg',
      category: 'Products',
      sizeBytes: 310 * 1024,
      dimensions: '1200 x 1200 px',
      fileType: 'JPEG',
      uploadedAt: DateTime.now().subtract(const Duration(days: 10)),
    ),
    MediaItem(
      id: 'media-banner-summer',
      name: 'Summer Sale Botanical Discount Banner',
      url: 'https://images.unsplash.com/photo-1540555700478-4be289fbecef?auto=format&fit=crop&w=1200&q=80',
      category: 'Banners',
      sizeBytes: 680 * 1024,
      dimensions: '1920 x 800 px',
      fileType: 'WEBP',
      uploadedAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    MediaItem(
      id: 'media-banner-saffron',
      name: 'Kumkumadi Saffron Golden Glow Promo Banner',
      url: 'https://images.unsplash.com/photo-1522337360788-8b13dee7a37e?auto=format&fit=crop&w=1200&q=80',
      category: 'Banners',
      sizeBytes: 740 * 1024,
      dimensions: '1920 x 800 px',
      fileType: 'WEBP',
      uploadedAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];

  Future<void> _loadMediaFromStorage() async {
    List<MediaItem> loaded = [];
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonStr = prefs.getString(_storageKey);
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(jsonStr);
        for (final item in decoded) {
          if (item is Map<String, dynamic>) {
            loaded.add(MediaItem.fromJson(item));
          }
        }
      }
    } catch (_) {}

    if (loaded.isNotEmpty) {
      state = loaded;
    } else {
      state = List.from(_initialMediaSeed);
      _saveMediaToStorage();
    }
  }

  Future<void> _saveMediaToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = state.map((m) => m.toJson()).toList();
      await prefs.setString(_storageKey, jsonEncode(jsonList));
    } catch (_) {}
  }

  Future<void> _syncToSupabase(MediaItem item) async {
    if (!SupabaseConfig.isConfigured) return;
    try {
      await supabase.from('media_library').upsert(item.toJson());
    } catch (_) {}
  }

  Future<void> addMedia({
    required String name,
    required String url,
    required String category,
    int? sizeBytes,
    String? dimensions,
    String? fileType,
  }) async {
    final String cleanUrl = url.trim();
    if (cleanUrl.isEmpty) return;

    final String detectedType = cleanUrl.startsWith('data:image/png')
        ? 'PNG'
        : cleanUrl.startsWith('data:image/jpeg')
            ? 'JPEG'
            : cleanUrl.startsWith('data:image/webp')
                ? 'WEBP'
                : cleanUrl.contains('.png')
                    ? 'PNG'
                    : cleanUrl.contains('.jpg') || cleanUrl.contains('.jpeg')
                        ? 'JPEG'
                        : 'WEBP';

    final newItem = MediaItem(
      id: 'media-${DateTime.now().millisecondsSinceEpoch}',
      name: name.trim().isEmpty ? 'Media Asset ${state.length + 1}' : name.trim(),
      url: cleanUrl,
      category: category,
      sizeBytes: sizeBytes ?? (cleanUrl.length * 0.75).round(),
      dimensions: dimensions ?? '1000 x 1000 px',
      fileType: fileType ?? detectedType,
      uploadedAt: DateTime.now(),
    );

    state = [newItem, ...state];
    await _saveMediaToStorage();
    await _syncToSupabase(newItem);
  }

  Future<void> deleteMedia(String mediaId) async {
    state = state.where((m) => m.id != mediaId).toList();
    await _saveMediaToStorage();

    if (SupabaseConfig.isConfigured) {
      try {
        await supabase.from('media_library').delete().eq('id', mediaId);
      } catch (_) {}
    }
  }

  Future<void> bulkDeleteMedia(Set<String> mediaIds) async {
    state = state.where((m) => !mediaIds.contains(m.id)).toList();
    await _saveMediaToStorage();
  }

  Future<void> updateCategory(String mediaId, String newCategory) async {
    state = [
      for (final m in state)
        if (m.id == mediaId) m.copyWith(category: newCategory) else m,
    ];
    await _saveMediaToStorage();
  }
}
