import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../config/supabase_config.dart';
import '../models/broadcast_notification_model.dart';

final broadcastNotificationProvider =
    StateNotifierProvider<BroadcastNotificationNotifier, List<BroadcastNotificationModel>>((ref) {
  return BroadcastNotificationNotifier();
});

class BroadcastNotificationNotifier extends StateNotifier<List<BroadcastNotificationModel>> {
  static const String _prefsKey = 'cosmyra_broadcast_notifications_v1';
  static const String _storagePath = 'broadcast_notifications.json';
  Timer? _timer;

  BroadcastNotificationNotifier() : super(_defaultNotifications) {
    loadNotificationsFromCloud();
    _timer = Timer.periodic(const Duration(seconds: 10), (_) {
      loadNotificationsFromCloud();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  static const List<BroadcastNotificationModel> _defaultNotifications = [
    BroadcastNotificationModel(
      id: 'notif-default-1',
      title: '🌿 Special Weekend Offer!',
      body: 'Get flat 30% off on all Ayurvedic Hair Oils & Organic Botanicals today!',
      sentAt: '2026-08-24T12:00:00.000Z',
      type: 'offer',
      isActive: true,
    ),
    BroadcastNotificationModel(
      id: 'notif-default-2',
      title: '🎉 Welcome to Cosmyra Botanicals',
      body: 'Use code VAIDYAM20 to get 15% OFF on your first purchase.',
      sentAt: '2026-08-23T09:30:00.000Z',
      type: 'welcome',
      isActive: true,
    ),
  ];

  Future<void> loadNotificationsFromCloud() async {
    // 1. Fast local load
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_prefsKey);
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final List decoded = jsonDecode(jsonStr);
        final loaded = decoded.map((x) => BroadcastNotificationModel.fromJson(Map<String, dynamic>.from(x))).toList();
        if (loaded.isNotEmpty) {
          state = loaded;
        }
      }
    } catch (_) {}

    // 2. Sync from Supabase Cloud Storage product-images bucket
    try {
      if (SupabaseConfig.isConfigured) {
        final rawUrl = Supabase.instance.client.storage.from('product-images').getPublicUrl(_storagePath);
        final freshUrl = '$rawUrl?t=${DateTime.now().millisecondsSinceEpoch}';
        final response = await http.get(
          Uri.parse(freshUrl),
          headers: {'Cache-Control': 'no-cache, no-store, must-revalidate', 'Pragma': 'no-cache'},
        );

        if (response.statusCode == 200 && response.body.isNotEmpty) {
          final List decoded = jsonDecode(response.body);
          final loaded = decoded.map((x) => BroadcastNotificationModel.fromJson(Map<String, dynamic>.from(x))).toList();
          if (loaded.isNotEmpty) {
            state = loaded;
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString(_prefsKey, response.body);
          }
        }
      }
    } catch (_) {}
  }

  Future<void> sendBroadcastNotification({
    required String title,
    required String body,
    String? imageUrl,
  }) async {
    final newNotif = BroadcastNotificationModel(
      id: 'notif-${DateTime.now().millisecondsSinceEpoch}',
      title: title.trim(),
      body: body.trim(),
      sentAt: DateTime.now().toIso8601String(),
      imageUrl: imageUrl?.trim().isNotEmpty == true ? imageUrl!.trim() : null,
      type: 'broadcast',
      isActive: true,
    );

    final updated = [newNotif, ...state.where((n) => n.id != newNotif.id)];
    state = updated;
    await _saveToLocalAndCloud(updated);
  }

  Future<void> deleteNotification(String id) async {
    final updated = state.where((n) => n.id != id).toList();
    state = updated;
    await _saveToLocalAndCloud(updated);
  }

  Future<void> clearAllNotifications() async {
    state = [];
    await _saveToLocalAndCloud([]);
  }

  Future<void> _saveToLocalAndCloud(List<BroadcastNotificationModel> list) async {
    final jsonStr = jsonEncode(list.map((n) => n.toJson()).toList());

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey, jsonStr);
    } catch (_) {}

    try {
      if (SupabaseConfig.isConfigured) {
        final client = Supabase.instance.client;
        await client.storage.from('product-images').uploadBinary(
              _storagePath,
              utf8.encode(jsonStr),
              fileOptions: const FileOptions(upsert: true, contentType: 'application/json'),
            );
      }
    } catch (_) {}
  }
}
