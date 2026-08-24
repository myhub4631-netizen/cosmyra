import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../config/supabase_config.dart';
import '../models/deal_offer_model.dart';

final dealsOffersProvider = StateNotifierProvider<DealsOffersNotifier, List<DealOfferModel>>((ref) {
  return DealsOffersNotifier();
});

class DealsOffersNotifier extends StateNotifier<List<DealOfferModel>> {
  DealsOffersNotifier() : super(_defaultDeals) {
    loadDealsFromCloud();
  }

  static const List<DealOfferModel> _defaultDeals = [
    DealOfferModel(
      id: 'deal-coupons',
      title: 'Coupons',
      description: 'Use coupons to get instant discounts on your orders.',
      buttonLabel: 'View All Coupons',
      dealType: 'coupons',
      targetRoute: '/shop',
      cardTheme: 'red',
      isActive: true,
    ),
    DealOfferModel(
      id: 'deal-referral',
      title: 'Refer & Earn',
      description: 'Refer your friends and earn exciting rewards.',
      buttonLabel: 'Refer Now',
      dealType: 'referral',
      targetRoute: '/account?tab=Refer',
      cardTheme: 'green',
      isActive: true,
    ),
    DealOfferModel(
      id: 'deal-bogo',
      title: 'Buy One Get One',
      description: 'Shop your favorite products with exciting BOGO offers.',
      buttonLabel: 'Shop BOGO Offers',
      dealType: 'bogo',
      targetRoute: '/shop?sort=Highest%20Discount',
      cardTheme: 'blue',
      badgeText: 'BOGO',
      isActive: true,
    ),
    DealOfferModel(
      id: 'deal-ugc',
      title: 'UGC Promo for Us',
      description: 'Create content, tag us and get exclusive rewards!',
      buttonLabel: 'Submit Now',
      dealType: 'ugc',
      targetRoute: '/ugc-promo',
      cardTheme: 'purple',
      isActive: true,
    ),
  ];

  Future<void> loadDealsFromCloud() async {
    try {
      if (SupabaseConfig.isConfigured) {
        final rawUrl = Supabase.instance.client.storage.from('product-images').getPublicUrl('deals_and_offers.json');
        final url = '$rawUrl?t=${DateTime.now().millisecondsSinceEpoch}';
        final response = await http.get(Uri.parse(url));
        if (response.statusCode == 200 && response.body.isNotEmpty) {
          final List jsonList = jsonDecode(response.body);
          final loaded = jsonList.map((item) => DealOfferModel.fromJson(item)).toList();
          if (loaded.isNotEmpty) {
            state = loaded;
          }
        }
      }
    } catch (_) {}
  }

  Future<void> saveDealsToCloud(List<DealOfferModel> newDeals) async {
    state = newDeals;
    try {
      if (SupabaseConfig.isConfigured) {
        final String jsonStr = jsonEncode(newDeals.map((d) => d.toJson()).toList());
        final client = Supabase.instance.client;
        await client.storage.from('product-images').uploadBinary(
              'deals_and_offers.json',
              utf8.encode(jsonStr),
              fileOptions: const FileOptions(upsert: true, contentType: 'application/json'),
            );
      }
    } catch (_) {}
  }

  Future<void> toggleDealActive(String id) async {
    final updated = state.map((d) {
      if (d.id == id) {
        return DealOfferModel(
          id: d.id,
          title: d.title,
          description: d.description,
          buttonLabel: d.buttonLabel,
          dealType: d.dealType,
          targetRoute: d.targetRoute,
          cardTheme: d.cardTheme,
          badgeText: d.badgeText,
          isActive: !d.isActive,
        );
      }
      return d;
    }).toList();
    await saveDealsToCloud(updated);
  }

  Future<void> updateDeal(DealOfferModel updatedDeal) async {
    final exists = state.any((d) => d.id == updatedDeal.id);
    List<DealOfferModel> newList;
    if (exists) {
      newList = state.map((d) => d.id == updatedDeal.id ? updatedDeal : d).toList();
    } else {
      newList = [...state, updatedDeal];
    }
    await saveDealsToCloud(newList);
  }

  Future<void> deleteDeal(String id) async {
    final newList = state.where((d) => d.id != id).toList();
    await saveDealsToCloud(newList);
  }
}
