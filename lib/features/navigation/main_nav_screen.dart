import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/theme/app_colors.dart';
import '../catalog/repositories/product_repository.dart';
import '../catalog/screens/explore_screen.dart';
import '../catalog/screens/vaidyam_home_screen.dart';
import '../catalog/screens/wishlist_screen.dart';
import '../profile/screens/profile_screen.dart';
import '../subscriptions/screens/subscriptions_screen.dart';

final mainNavTabProvider = StateProvider<int>((ref) => 0);

class MainNavScreen extends ConsumerWidget {
  const MainNavScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTab = ref.watch(mainNavTabProvider);
    final wishlist = ref.watch(wishlistProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final pages = const [
      VaidyamHomeScreen(),
      ExploreScreen(),
      SubscriptionsScreen(),
      WishlistScreen(),
      ProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: currentTab,
        children: pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.charcoalCard : AppColors.creamCard,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, -3),
            ),
          ],
          border: Border(
            top: BorderSide(
              color: isDark ? AppColors.charcoalBorder : AppColors.creamBorder,
              width: 1,
            ),
          ),
        ),
        child: SafeArea(
          child: NavigationBar(
            selectedIndex: currentTab,
            onDestinationSelected: (index) {
              ref.read(mainNavTabProvider.notifier).state = index;
            },
            backgroundColor: isDark ? AppColors.charcoalCard : AppColors.creamCard,
            indicatorColor: isDark ? AppColors.goldAccent.withOpacity(0.25) : AppColors.forestSage.withOpacity(0.15),
            elevation: 0,
            destinations: [
              const NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home, color: AppColors.forestSage),
                label: 'Shop',
              ),
              const NavigationDestination(
                icon: Icon(Icons.explore_outlined),
                selectedIcon: Icon(Icons.explore, color: AppColors.forestSage),
                label: 'Explore',
              ),
              const NavigationDestination(
                icon: Icon(Icons.autorenew_outlined),
                selectedIcon: Icon(Icons.autorenew, color: AppColors.goldAccent),
                label: 'Subscribe',
              ),
              NavigationDestination(
                icon: Badge(
                  isLabelVisible: wishlist.isNotEmpty,
                  label: Text('${wishlist.length}'),
                  backgroundColor: AppColors.goldAccent,
                  textColor: AppColors.forestSageDark,
                  child: const Icon(Icons.favorite_border),
                ),
                selectedIcon: const Icon(Icons.favorite, color: Colors.red),
                label: 'Wishlist',
              ),
              const NavigationDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person, color: AppColors.forestSage),
                label: 'Account',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
