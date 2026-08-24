import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/cart/screens/vaidyam_cart_screen.dart';
import '../features/catalog/models/product_model.dart';
import '../features/catalog/screens/explore_screen.dart';
import '../features/catalog/screens/product_detail_screen.dart';
import '../features/catalog/screens/wishlist_screen.dart';
import '../features/checkout/screens/checkout_screen.dart';
import '../features/navigation/main_nav_screen.dart';
import '../features/orders/models/order_model.dart';
import '../features/orders/screens/order_success_screen.dart';
import '../features/subscriptions/screens/subscriptions_screen.dart';
import '../features/admin/screens/admin_master_screen.dart';
import '../features/auth/screens/signup_screen.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/account/screens/user_dashboard_screen.dart';

import '../features/catalog/screens/vaidyam_home_screen.dart';
import '../features/catalog/screens/vaidyam_shop_screen.dart';
import '../features/catalog/screens/vaidyam_wishlist_screen.dart';
import '../features/orders/screens/vaidyam_orders_screen.dart';
import '../features/coupons/screens/deals_and_offers_screen.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const VaidyamHomeScreen(),
    ),
    GoRoute(
      path: '/deals',
      builder: (context, state) => const DealsAndOffersScreen(),
    ),
    GoRoute(
      path: '/offers',
      builder: (context, state) => const DealsAndOffersScreen(),
    ),
    GoRoute(
      path: '/deals-and-offers',
      builder: (context, state) => const DealsAndOffersScreen(),
    ),
    GoRoute(
      path: '/shop',
      builder: (context, state) => VaidyamShopScreen(
        initialCategory: state.uri.queryParameters['cat'] ?? state.uri.queryParameters['category'],
        showCategoriesFirst: state.uri.queryParameters['view'] == 'categories',
        searchParam: state.uri.queryParameters['q'],
        initialSort: state.uri.queryParameters['sort'],
      ),
    ),
    GoRoute(
      path: '/catalog',
      builder: (context, state) => VaidyamShopScreen(
        initialCategory: state.uri.queryParameters['cat'] ?? state.uri.queryParameters['category'],
        showCategoriesFirst: state.uri.queryParameters['view'] == 'categories',
        searchParam: state.uri.queryParameters['q'],
        initialSort: state.uri.queryParameters['sort'],
      ),
    ),
    GoRoute(
      path: '/categories',
      builder: (context, state) => VaidyamShopScreen(
        initialCategory: state.uri.queryParameters['cat'] ?? state.uri.queryParameters['category'],
        showCategoriesFirst: true,
        searchParam: state.uri.queryParameters['q'],
        initialSort: state.uri.queryParameters['sort'],
      ),
    ),
    GoRoute(
      path: '/category',
      builder: (context, state) => VaidyamShopScreen(
        initialCategory: state.uri.queryParameters['cat'] ?? state.uri.queryParameters['category'],
        showCategoriesFirst: state.uri.queryParameters['cat'] == null && state.uri.queryParameters['category'] == null,
        searchParam: state.uri.queryParameters['q'],
        initialSort: state.uri.queryParameters['sort'],
      ),
    ),
    GoRoute(
      path: '/explore',
      builder: (context, state) => const ExploreScreen(),
    ),
    GoRoute(
      path: '/user-dashboard',
      builder: (context, state) => UserDashboardScreen(initialTab: state.uri.queryParameters['tab']),
    ),
    GoRoute(
      path: '/account',
      builder: (context, state) => UserDashboardScreen(initialTab: state.uri.queryParameters['tab']),
    ),
    GoRoute(
      path: '/dashboard',
      builder: (context, state) => UserDashboardScreen(initialTab: state.uri.queryParameters['tab']),
    ),
    GoRoute(
      path: '/signup',
      builder: (context, state) => const SignupScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const SignupScreen(),
    ),
    GoRoute(
      path: '/subscriptions',
      builder: (context, state) => const SubscriptionsScreen(),
    ),
    GoRoute(
      path: '/wishlist',
      builder: (context, state) => const VaidyamWishlistScreen(),
    ),
    GoRoute(
      path: '/product/:id',
      builder: (context, state) {
        final product = state.extra as ProductModel?;
        final productId = state.pathParameters['id'];
        return ProductDetailScreen(product: product, productId: productId);
      },
    ),
    GoRoute(
      path: '/cart',
      builder: (context, state) => const VaidyamCartScreen(),
    ),
    GoRoute(
      path: '/checkout',
      builder: (context, state) => const CheckoutScreen(),
    ),
    GoRoute(
      path: '/order-success',
      builder: (context, state) {
        final order = state.extra as OrderModel;
        return OrderSuccessScreen(order: order);
      },
    ),
    GoRoute(
      path: '/orders',
      builder: (context, state) => const VaidyamOrdersScreen(),
    ),
    GoRoute(
      path: '/admin',
      builder: (context, state) => const AdminMasterScreen(),
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Text('Page not found: ${state.uri}'),
    ),
  ),
);
