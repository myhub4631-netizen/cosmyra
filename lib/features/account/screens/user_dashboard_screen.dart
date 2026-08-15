import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../shared/widgets/center_action_toast.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../cart/controllers/cart_controller.dart';
import '../../catalog/repositories/product_repository.dart';
import '../../navigation/widgets/vaidyam_footer_widget.dart';
import '../../navigation/widgets/vaidyam_header_widget.dart';
import '../../orders/repositories/order_repository.dart';

class UserDashboardScreen extends ConsumerStatefulWidget {
  final String? initialTab;

  const UserDashboardScreen({super.key, this.initialTab});

  @override
  ConsumerState<UserDashboardScreen> createState() => _UserDashboardScreenState();
}

class _UserDashboardScreenState extends ConsumerState<UserDashboardScreen> {
  late String _selectedTab;
  String _selectedSearchCategory = 'All Categories';
  final TextEditingController _searchController = TextEditingController();

  // Mock State for Addresses
  final List<Map<String, dynamic>> _userAddresses = [
    {
      'id': 'addr-1',
      'name': 'Mahboob Hasan',
      'phone': '+91 94730 40903',
      'street': 'Flat 402, Green Valley Apartments, MG Road',
      'city': 'Bangalore',
      'state': 'Karnataka',
      'pincode': '560001',
      'type': 'HOME',
      'isDefault': true,
    },
    {
      'id': 'addr-2',
      'name': 'Mahboob Hasan',
      'phone': '+91 94730 40903',
      'street': 'Tech Park B, 5th Floor, Outer Ring Road',
      'city': 'Bangalore',
      'state': 'Karnataka',
      'pincode': '560103',
      'type': 'WORK',
      'isDefault': false,
    },
  ];

  // Mock State for Saved Payment Methods
  final List<Map<String, dynamic>> _paymentMethods = [
    {
      'id': 'pay-1',
      'type': 'UPI',
      'name': 'Google Pay / PhonePe',
      'detail': 'mahboob@okicici',
      'isDefault': true,
    },
    {
      'id': 'pay-2',
      'type': 'CARD',
      'name': 'HDFC Bank Visa Debit Card',
      'detail': '•••• •••• •••• 4092 (Exp 08/28)',
      'isDefault': false,
    },
  ];

  // Notifications State
  final List<Map<String, dynamic>> _notifications = [];

  // FAQ Accordion Expanded State
  final Map<int, bool> _faqExpanded = {0: true, 1: false, 2: false, 3: false};

  // Preference Toggles
  bool _emailNewsletter = true;
  bool _smsUpdates = true;
  bool _whatsappAlerts = true;

  final List<Map<String, dynamic>> _sidebarNavItems = [
    {'title': 'Dashboard', 'icon': Icons.home_outlined, 'route': null},
    {'title': 'My Orders', 'icon': Icons.inventory_2_outlined, 'route': '/orders'},
    {'title': 'My Wishlist', 'icon': Icons.favorite_border, 'route': '/wishlist'},
    {'title': 'My Addresses', 'icon': Icons.location_on_outlined, 'route': null},
    {'title': 'Account Details', 'icon': Icons.person_outline, 'route': null},
    {'title': 'Change Password', 'icon': Icons.lock_outline, 'route': null},
    {'title': 'Payment Methods', 'icon': Icons.credit_card_outlined, 'route': null},
    {'title': 'Coupons', 'icon': Icons.confirmation_number_outlined, 'route': null},
    {'title': 'Notifications', 'icon': Icons.notifications_none_outlined, 'route': null},
    {'title': 'Returns & Refunds', 'icon': Icons.assignment_return_outlined, 'route': null},
    {'title': 'Help & Support', 'icon': Icons.help_outline, 'route': null},
    {'title': 'Account Settings', 'icon': Icons.settings_outlined, 'route': null},
    {'title': 'Logout', 'icon': Icons.logout, 'route': null},
  ];

  @override
  void initState() {
    super.initState();
    _selectedTab = _normalizeTabName(widget.initialTab) ?? 'Dashboard';
    _loadSavedAddresses();
    _loadSavedPaymentMethods();
    _loadSavedNotifications();
  }

  IconData _getNotificationIcon(String? iconType) {
    switch (iconType) {
      case 'shipping':
        return Icons.local_shipping_outlined;
      case 'offer':
        return Icons.favorite_outline;
      case 'ayurveda':
        return Icons.spa_outlined;
      default:
        return Icons.notifications_none_outlined;
    }
  }

  String _getNotificationIconType(IconData icon) {
    if (icon == Icons.local_shipping_outlined) return 'shipping';
    if (icon == Icons.favorite_outline) return 'offer';
    if (icon == Icons.spa_outlined) return 'ayurveda';
    return 'default';
  }

  Future<void> _loadSavedNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonStr = prefs.getString('cosmyra_user_notifications_v1');
      if (jsonStr != null) {
        final List<dynamic> decoded = jsonDecode(jsonStr);
        setState(() {
          _notifications.clear();
          for (var item in decoded) {
            final map = Map<String, dynamic>.from(item as Map);
            final String iconType = map['icon_type'] as String? ?? 'default';
            final int colorVal = map['color_val'] as int? ?? 0xFF4F46E5;
            _notifications.add({
              'id': map['id'],
              'title': map['title'],
              'message': map['message'],
              'time': map['time'],
              'isRead': map['isRead'] == true,
              'icon': _getNotificationIcon(iconType),
              'icon_type': iconType,
              'color': Color(colorVal),
              'color_val': colorVal,
            });
          }
        });
      }
    } catch (_) {}
  }

  Future<void> _saveNotificationsToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final listToSave = _notifications.map((n) {
        final IconData icon = n['icon'] is IconData ? n['icon'] as IconData : Icons.notifications_none_outlined;
        final Color color = n['color'] is Color ? n['color'] as Color : const Color(0xFF4F46E5);
        return {
          'id': n['id'],
          'title': n['title'],
          'message': n['message'],
          'time': n['time'],
          'isRead': n['isRead'] == true,
          'icon_type': _getNotificationIconType(icon),
          'color_val': color.value,
        };
      }).toList();
      await prefs.setString('cosmyra_user_notifications_v1', jsonEncode(listToSave));
    } catch (_) {}
  }

  Future<void> _confirmDeleteNotification(BuildContext context, int idx) async {
    setState(() {
      _notifications.removeAt(idx);
    });
    await _saveNotificationsToStorage();
    if (context.mounted) {
      showCenterActionToast(
        context,
        title: 'Notification Deleted 🗑️',
        message: 'Notification removed from inbox.',
        icon: Icons.delete_outline,
        iconColor: const Color(0xFFDC2626),
        primaryActionLabel: null,
      );
    }
  }

  Future<void> _clearAllNotifications(BuildContext context) async {
    if (_notifications.isEmpty) return;
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.cleaning_services_outlined, color: Color(0xFFDC2626)),
            SizedBox(width: 8),
            Text('Clear All Notifications?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        content: const Text(
          'Are you sure you want to clear all notifications from your inbox?\n\nThis action cannot be undone.',
          style: TextStyle(fontSize: 13, color: Color(0xFF4B5563)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF6B7280))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Clear All', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() {
        _notifications.clear();
      });
      await _saveNotificationsToStorage();
      if (context.mounted) {
        showCenterActionToast(
          context,
          title: 'Notifications Cleared! 🔔',
          message: 'All notifications have been removed.',
          icon: Icons.notifications_off_outlined,
          iconColor: const Color(0xFFDC2626),
          primaryActionLabel: null,
        );
      }
    }
  }

  Future<void> _loadSavedAddresses() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonStr = prefs.getString('cosmyra_user_addresses_v1');
      if (jsonStr != null) {
        final List<dynamic> decoded = jsonDecode(jsonStr);
        setState(() {
          _userAddresses.clear();
          _userAddresses.addAll(decoded.map((item) => Map<String, dynamic>.from(item as Map)));
        });
      }
    } catch (_) {}
  }

  Future<void> _saveAddressesToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('cosmyra_user_addresses_v1', jsonEncode(_userAddresses));
    } catch (_) {}
  }

  Future<void> _loadSavedPaymentMethods() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonStr = prefs.getString('cosmyra_user_payment_methods_v1');
      if (jsonStr != null) {
        final List<dynamic> decoded = jsonDecode(jsonStr);
        setState(() {
          _paymentMethods.clear();
          _paymentMethods.addAll(decoded.map((item) => Map<String, dynamic>.from(item as Map)));
        });
      }
    } catch (_) {}
  }

  Future<void> _savePaymentMethodsToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('cosmyra_user_payment_methods_v1', jsonEncode(_paymentMethods));
    } catch (_) {}
  }

  Future<void> _confirmDeletePaymentMethod(BuildContext context, int idx) async {
    final pay = _paymentMethods[idx];
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.delete_outline, color: Color(0xFFDC2626)),
            SizedBox(width: 8),
            Text('Remove Payment Method?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        content: Text(
          'Are you sure you want to remove ${pay['name']} (${pay['detail']})?\n\nThis action cannot be undone.',
          style: const TextStyle(fontSize: 13, color: Color(0xFF4B5563)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF6B7280))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Remove Payment Method', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() {
        _paymentMethods.removeAt(idx);
      });
      await _savePaymentMethodsToStorage();
      if (context.mounted) {
        showCenterActionToast(
          context,
          title: 'Payment Method Removed! 💳',
          message: 'Selected payment option has been removed.',
          icon: Icons.credit_card_off_outlined,
          iconColor: const Color(0xFFDC2626),
          primaryActionLabel: null,
        );
      }
    }
  }

  Future<void> _confirmDeleteAddress(BuildContext context, int idx) async {
    final addr = _userAddresses[idx];
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.delete_outline, color: Color(0xFFDC2626)),
            SizedBox(width: 8),
            Text('Delete Address?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        content: Text(
          'Are you sure you want to delete the ${addr['type']} address for "${addr['name']}"?\n\nThis action cannot be undone.',
          style: const TextStyle(fontSize: 13, color: Color(0xFF4B5563)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF6B7280))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete Address', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final bool wasDefault = addr['isDefault'] == true;
      setState(() {
        _userAddresses.removeAt(idx);
        if (wasDefault && _userAddresses.isNotEmpty) {
          _userAddresses.first['isDefault'] = true;
        }
      });
      await _saveAddressesToStorage();
      if (context.mounted) {
        showCenterActionToast(
          context,
          title: 'Address Removed! 🗑️',
          message: 'Selected delivery address has been deleted.',
          icon: Icons.delete_outline,
          iconColor: const Color(0xFFDC2626),
          primaryActionLabel: null,
        );
      }
    }
  }

  @override
  void didUpdateWidget(covariant UserDashboardScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialTab != null && widget.initialTab != oldWidget.initialTab) {
      setState(() {
        _selectedTab = _normalizeTabName(widget.initialTab) ?? 'Dashboard';
      });
    }
  }

  String? _normalizeTabName(String? raw) {
    if (raw == null) return null;
    final r = raw.trim().toLowerCase();
    if (r.contains('address')) return 'My Addresses';
    if (r.contains('payment')) return 'Payment Methods';
    if (r.contains('coupon')) return 'Coupons';
    if (r.contains('notification')) return 'Notifications';
    if (r.contains('return') || r.contains('refund')) return 'Returns & Refunds';
    if (r.contains('help') || r.contains('support')) return 'Help & Support';
    if (r.contains('password')) return 'Change Password';
    if (r.contains('detail') || r.contains('profile')) return 'Account Details';
    if (r.contains('setting')) return 'Account Settings';
    if (r.contains('order')) return 'My Orders';
    if (r.contains('wishlist')) return 'My Wishlist';
    return 'Dashboard';
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ═════════════════════════════════════════════════════════════
  // DIALOGS & ACTION HANDLERS
  // ═════════════════════════════════════════════════════════════

  void _showAddAddressDialog(BuildContext context, {Map<String, dynamic>? editAddress}) {
    final nameCtrl = TextEditingController(text: editAddress?['name'] ?? '');
    final phoneCtrl = TextEditingController(text: editAddress?['phone'] ?? '');
    final streetCtrl = TextEditingController(text: editAddress?['street'] ?? '');
    final cityCtrl = TextEditingController(text: editAddress?['city'] ?? 'Bangalore');
    final stateCtrl = TextEditingController(text: editAddress?['state'] ?? 'Karnataka');
    final pincodeCtrl = TextEditingController(text: editAddress?['pincode'] ?? '560001');
    String type = editAddress?['type'] ?? 'HOME';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDlgState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(editAddress == null ? 'Add New Delivery Address' : 'Edit Delivery Address', style: const TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Full Name', border: OutlineInputBorder())),
                const SizedBox(height: 10),
                TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'Mobile Number', border: OutlineInputBorder())),
                const SizedBox(height: 10),
                TextField(controller: streetCtrl, decoration: const InputDecoration(labelText: 'Flat / House No. & Street Address', border: OutlineInputBorder())),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: TextField(controller: cityCtrl, decoration: const InputDecoration(labelText: 'City', border: OutlineInputBorder()))),
                    const SizedBox(width: 8),
                    Expanded(child: TextField(controller: stateCtrl, decoration: const InputDecoration(labelText: 'State', border: OutlineInputBorder()))),
                  ],
                ),
                const SizedBox(height: 10),
                TextField(controller: pincodeCtrl, decoration: const InputDecoration(labelText: 'Pincode', border: OutlineInputBorder())),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text('Address Type:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(width: 12),
                    ChoiceChip(
                      label: const Text('HOME'),
                      selected: type == 'HOME',
                      onSelected: (_) => setDlgState(() => type = 'HOME'),
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('WORK'),
                      selected: type == 'WORK',
                      onSelected: (_) => setDlgState(() => type = 'WORK'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                if (nameCtrl.text.trim().isEmpty || streetCtrl.text.trim().isEmpty) return;
                setState(() {
                  if (editAddress != null) {
                    editAddress['name'] = nameCtrl.text.trim();
                    editAddress['phone'] = phoneCtrl.text.trim();
                    editAddress['street'] = streetCtrl.text.trim();
                    editAddress['city'] = cityCtrl.text.trim();
                    editAddress['state'] = stateCtrl.text.trim();
                    editAddress['pincode'] = pincodeCtrl.text.trim();
                    editAddress['type'] = type;
                  } else {
                    _userAddresses.add({
                      'id': 'addr-${DateTime.now().millisecondsSinceEpoch}',
                      'name': nameCtrl.text.trim(),
                      'phone': phoneCtrl.text.trim(),
                      'street': streetCtrl.text.trim(),
                      'city': cityCtrl.text.trim(),
                      'state': stateCtrl.text.trim(),
                      'pincode': pincodeCtrl.text.trim(),
                      'type': type,
                      'isDefault': _userAddresses.isEmpty,
                    });
                  }
                });
                _saveAddressesToStorage();
                Navigator.pop(ctx);
                showCenterActionToast(
                  context,
                  title: editAddress == null ? 'Address Saved! 📍' : 'Address Updated! ✏️',
                  message: '${type} address has been saved to your account.',
                  icon: Icons.location_on_outlined,
                  iconColor: const Color(0xFF4F46E5),
                  primaryActionLabel: null,
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4F46E5), foregroundColor: Colors.white),
              child: const Text('Save Address'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddPaymentMethodDialog(BuildContext context) {
    final upiCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Add Payment Method', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter your Virtual Payment Address (UPI ID) for instant checkout:'),
            const SizedBox(height: 12),
            TextField(controller: upiCtrl, decoration: const InputDecoration(hintText: 'username@upi', labelText: 'UPI ID / VPA', border: OutlineInputBorder())),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (upiCtrl.text.trim().isNotEmpty) {
                setState(() {
                  _paymentMethods.add({
                    'id': 'pay-${DateTime.now().millisecondsSinceEpoch}',
                    'type': 'UPI',
                    'name': 'Saved UPI ID',
                    'detail': upiCtrl.text.trim(),
                    'isDefault': false,
                  });
                });
                _savePaymentMethodsToStorage();
                Navigator.pop(ctx);
                showCenterActionToast(
                  context,
                  title: 'Payment Method Saved! 💳',
                  message: 'Your UPI ID (${upiCtrl.text.trim()}) is saved for 1-Click checkout.',
                  icon: Icons.credit_card_rounded,
                  iconColor: const Color(0xFF4F46E5),
                  primaryActionLabel: null,
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4F46E5), foregroundColor: Colors.white),
            child: const Text('Save Payment Method'),
          ),
        ],
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context, String currentName, String currentEmail, String currentPhone) {
    final nameCtrl = TextEditingController(text: currentName);
    final emailCtrl = TextEditingController(text: currentEmail);
    final phoneCtrl = TextEditingController(text: currentPhone);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Edit Account Profile', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Full Name', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: emailCtrl, readOnly: true, decoration: const InputDecoration(labelText: 'Email Address (Account ID)', border: OutlineInputBorder(), fillColor: Color(0xFFF3F4F6), filled: true)),
            const SizedBox(height: 12),
            TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'Phone Number', border: OutlineInputBorder())),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (nameCtrl.text.trim().isNotEmpty) {
                await ref.read(authControllerProvider.notifier).updateUserProfile(
                      name: nameCtrl.text.trim(),
                      phone: phoneCtrl.text.trim(),
                    );
                if (!ctx.mounted) return;
                Navigator.pop(ctx);
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Profile details updated successfully!')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4F46E5), foregroundColor: Colors.white),
            child: const Text('Save Changes'),
          ),
        ],
      ),
    );
  }

  void _showReferralDialog(BuildContext context, String referCode) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Refer & Earn ₹250', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Share your unique referral link with friends. When they place their first order, you both get ₹250 credit!'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'https://cosmyra.cloud/refer?code=$referCode',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF4F46E5)),
                    ),
                  ),
                  const Icon(Icons.copy, size: 18, color: Color(0xFF4F46E5)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Referral link copied to clipboard!')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4F46E5), foregroundColor: Colors.white),
            child: const Text('Copy Link'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartProvider);
    final wishlist = ref.watch(wishlistProvider);
    final ordersAsync = ref.watch(userOrdersFutureProvider);
    final totalCartCount = cartState.totalItemCount;

    final user = ref.watch(currentUserProvider);
    final auth = ref.watch(authControllerProvider);

    final String displayName = auth.userName ??
        user?.userMetadata?['full_name'] ??
        (auth.isGuest ? auth.guestName : null) ??
        (user?.email != null ? user!.email!.split('@').first : 'Valued Customer');

    final String displayEmail = auth.userEmail ??
        user?.email ??
        (auth.isGuest ? auth.guestEmail : null) ??
        'No email registered';

    final String displayPhone = auth.userPhone ??
        user?.phone ??
        (auth.isGuest ? auth.guestPhone : null) ??
        (auth.userPhone?.isNotEmpty == true ? auth.userPhone! : 'No phone provided');

    final String referCode = displayName.replaceAll(' ', '').toUpperCase();
    final String firstFirstName = displayName.split(' ').first;

    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth > 900;

    final int realOrdersCount = ordersAsync.value?.length ?? 0;
    final int wishlistCount = wishlist.length;

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const VaidyamHeaderWidget(activeTab: 'Account', showValuePropositions: true),

            const SizedBox(height: 24),

            // 4. Main Body: Split View Sidebar Nav & Dynamic Panel
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left Sidebar Navigation Card (Fixed 240px)
                  SizedBox(
                    width: 240,
                    child: _buildSidebarNav(context, displayName, displayEmail),
                  ),
                  const SizedBox(width: 24),

                  // Right Dynamic Content Panel
                  Expanded(
                    child: _buildSelectedTabPanel(context, displayName, firstFirstName, displayEmail, displayPhone, referCode, isWide, realOrdersCount, wishlistCount),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 48),

            // 5. Storefront Footer
            const VaidyamFooterWidget(),
          ],
        ),
      ),
    );
  }

  Widget _navLink(BuildContext context, String title, String route) {
    return Padding(
      padding: const EdgeInsets.only(right: 20),
      child: InkWell(
        onTap: () => context.go(route),
        child: Text(
          title,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF374151)),
        ),
      ),
    );
  }

  Widget _buildSidebarNav(BuildContext context, String displayName, String displayEmail) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 8)],
      ),
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        children: [
          // Small User Bio Info Header
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: const Color(0xFF4F46E5),
                  child: Text(
                    displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(displayName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF111827)), maxLines: 1, overflow: TextOverflow.ellipsis),
                      Text(displayEmail, style: const TextStyle(fontSize: 10, color: Color(0xFF6B7280)), maxLines: 1, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          const SizedBox(height: 4),

          ..._sidebarNavItems.map((item) {
            final isSelected = _selectedTab == item['title'];
            final isLogout = item['title'] == 'Logout';

            return InkWell(
              onTap: () async {
                if (isLogout) {
                  await ref.read(authControllerProvider.notifier).signOut();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Logged out successfully.')));
                    context.go('/login');
                  }
                } else if (item['route'] != null) {
                  context.go(item['route'] as String);
                } else {
                  setState(() => _selectedTab = item['title'] as String);
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFEEF2FF) : Colors.transparent,
                  border: isSelected
                      ? const Border(left: BorderSide(color: Color(0xFF4F46E5), width: 3))
                      : null,
                ),
                child: Row(
                  children: [
                    Icon(
                      item['icon'] as IconData,
                      size: 18,
                      color: isLogout
                          ? Colors.red
                          : (isSelected ? const Color(0xFF4F46E5) : const Color(0xFF6B7280)),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      item['title'] as String,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isLogout
                            ? Colors.red
                            : (isSelected ? const Color(0xFF4F46E5) : const Color(0xFF374151)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════
  // MAIN SWITCH PANEL SELECTOR
  // ═════════════════════════════════════════════════════════════
  Widget _buildSelectedTabPanel(
    BuildContext context,
    String displayName,
    String firstFirstName,
    String displayEmail,
    String displayPhone,
    String referCode,
    bool isWide,
    int realOrdersCount,
    int wishlistCount,
  ) {
    switch (_selectedTab) {
      case 'My Addresses':
        return _buildAddressesView(context);
      case 'Payment Methods':
        return _buildPaymentMethodsView(context);
      case 'Coupons':
        return _buildCouponsView(context);
      case 'Notifications':
        return _buildNotificationsView(context);
      case 'Returns & Refunds':
        return _buildReturnsRefundsView(context);
      case 'Help & Support':
        return _buildHelpSupportView(context);
      case 'Account Details':
        return _buildAccountDetailsView(context, displayName, displayEmail, displayPhone);
      case 'Change Password':
        return _buildChangePasswordView(context);
      case 'Account Settings':
        return _buildAccountSettingsView(context, displayName, displayEmail);
      case 'Dashboard':
      default:
        return _buildDashboardOverview(context, displayName, firstFirstName, displayEmail, displayPhone, referCode, isWide, realOrdersCount, wishlistCount);
    }
  }

  // ═════════════════════════════════════════════════════════════
  // 1. DASHBOARD OVERVIEW VIEW
  // ═════════════════════════════════════════════════════════════
  Widget _buildDashboardOverview(
    BuildContext context,
    String displayName,
    String firstFirstName,
    String displayEmail,
    String displayPhone,
    String referCode,
    bool isWide,
    int totalOrdersCount,
    int wishlistCount,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Welcome Greeting Header
        Row(
          children: [
            Text(
              'Welcome back, $firstFirstName! 👋',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF111827)),
            ),
          ],
        ),
        const SizedBox(height: 4),
        const Text(
          "Here's what's happening with your account.",
          style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
        ),

        const SizedBox(height: 24),

        // 4 Key Summary Stat Cards Bar (Responsive Layout)
        isWide
            ? Row(
                children: [
                  Expanded(child: _buildStatCard('Total Orders', '$totalOrdersCount', 'View all orders', Icons.shopping_bag_outlined, const Color(0xFFEEF2FF), const Color(0xFF4F46E5), () => context.go('/orders'))),
                  const SizedBox(width: 16),
                  Expanded(child: _buildStatCard('Wishlist Items', '$wishlistCount', 'View wishlist', Icons.favorite_border, const Color(0xFFFEE2E2), const Color(0xFFEF4444), () => context.go('/wishlist'))),
                  const SizedBox(width: 16),
                  Expanded(child: _buildStatCard('Addresses', '${_userAddresses.length}', 'Manage addresses', Icons.location_on_outlined, const Color(0xFFE0E7FF), const Color(0xFF6366F1), () => setState(() => _selectedTab = 'My Addresses'))),
                  const SizedBox(width: 16),
                  Expanded(child: _buildStatCard('Account Balance', '₹0', 'View balance', Icons.account_balance_wallet_outlined, const Color(0xFFFEF3C7), const Color(0xFFD97706), () {})),
                ],
              )
            : Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  SizedBox(width: (MediaQuery.of(context).size.width - 60) / 2, child: _buildStatCard('Total Orders', '$totalOrdersCount', 'View all orders', Icons.shopping_bag_outlined, const Color(0xFFEEF2FF), const Color(0xFF4F46E5), () => context.go('/orders'))),
                  SizedBox(width: (MediaQuery.of(context).size.width - 60) / 2, child: _buildStatCard('Wishlist Items', '$wishlistCount', 'View wishlist', Icons.favorite_border, const Color(0xFFFEE2E2), const Color(0xFFEF4444), () => context.go('/wishlist'))),
                  SizedBox(width: (MediaQuery.of(context).size.width - 60) / 2, child: _buildStatCard('Addresses', '${_userAddresses.length}', 'Manage addresses', Icons.location_on_outlined, const Color(0xFFE0E7FF), const Color(0xFF6366F1), () => setState(() => _selectedTab = 'My Addresses'))),
                  SizedBox(width: (MediaQuery.of(context).size.width - 60) / 2, child: _buildStatCard('Account Balance', '₹0', 'View balance', Icons.account_balance_wallet_outlined, const Color(0xFFFEF3C7), const Color(0xFFD97706), () {})),
                ],
              ),

        const SizedBox(height: 24),

        // Two Column Content Grid (Recent Orders Table + Right Account Details Widgets)
        isWide
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left: Recent Orders Table Card (Expanded)
                  Expanded(
                    flex: 7,
                    child: _buildRecentOrdersCard(context),
                  ),
                  const SizedBox(width: 24),

                  // Right: Account Profile Card + Refer & Earn Widget (Flex 5)
                  Expanded(
                    flex: 5,
                    child: Column(
                      children: [
                        _buildAccountDetailsCard(context, displayName, displayEmail, displayPhone),
                        const SizedBox(height: 20),
                        _buildReferCard(context, referCode),
                      ],
                    ),
                  ),
                ],
              )
            : Column(
                children: [
                  _buildRecentOrdersCard(context),
                  const SizedBox(height: 24),
                  _buildAccountDetailsCard(context, displayName, displayEmail, displayPhone),
                  const SizedBox(height: 20),
                  _buildReferCard(context, referCode),
                ],
              ),
      ],
    );
  }

  // ═════════════════════════════════════════════════════════════
  // 2. MY ADDRESSES VIEW
  // ═════════════════════════════════════════════════════════════
  Widget _buildAddressesView(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
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
                  Text('My Delivery Addresses', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
                  SizedBox(height: 4),
                  Text('Manage your saved delivery addresses for fast 1-Click checkout.', style: TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () => _showAddAddressDialog(context),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add New Address', style: TextStyle(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4F46E5),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          if (_userAddresses.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: const [
                    Icon(Icons.location_off_outlined, size: 48, color: Color(0xFF9CA3AF)),
                    SizedBox(height: 12),
                    Text('No saved addresses yet', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _userAddresses.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, idx) {
                final addr = _userAddresses[idx];
                final bool isDefault = addr['isDefault'] == true;

                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDefault ? const Color(0xFFF5F3FF) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isDefault ? const Color(0xFF6366F1) : const Color(0xFFE5E7EB), width: isDefault ? 1.5 : 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEEF2FF),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(addr['type'] as String, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF4F46E5))),
                          ),
                          const SizedBox(width: 8),
                          if (isDefault)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFD1FAE5),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text('DEFAULT ADDRESS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF059669))),
                            ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, size: 18, color: Color(0xFF4F46E5)),
                            onPressed: () => _showAddAddressDialog(context, editAddress: addr),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                            onPressed: () => _confirmDeleteAddress(context, idx),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(addr['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF111827))),
                      const SizedBox(height: 4),
                      Text('${addr['street']}, ${addr['city']}, ${addr['state']} - ${addr['pincode']}', style: const TextStyle(fontSize: 13, color: Color(0xFF374151))),
                      const SizedBox(height: 4),
                      Text('Phone: ${addr['phone']}', style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                      const SizedBox(height: 12),
                      if (!isDefault)
                        OutlinedButton(
                          onPressed: () {
                            setState(() {
                              for (var a in _userAddresses) {
                                a['isDefault'] = false;
                              }
                              addr['isDefault'] = true;
                            });
                            _saveAddressesToStorage();
                            showCenterActionToast(
                              context,
                              title: 'Default Address Updated! 📍',
                              message: '${addr['type']} address set as default delivery location.',
                              icon: Icons.check_circle_rounded,
                              iconColor: const Color(0xFF059669),
                              primaryActionLabel: null,
                            );
                          },
                          style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6)),
                          child: const Text('Set as Default', style: TextStyle(fontSize: 11)),
                        ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════
  // 3. PAYMENT METHODS VIEW
  // ═════════════════════════════════════════════════════════════
  Widget _buildPaymentMethodsView(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
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
                  Text('Saved Payment Methods', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
                  SizedBox(height: 4),
                  Text('Manage your saved cards, UPI IDs, and payment defaults.', style: TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () => _showAddPaymentMethodDialog(context),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add Payment Method', style: TextStyle(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4F46E5),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          if (_paymentMethods.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Column(
                children: [
                  const Icon(Icons.credit_card_off_outlined, size: 48, color: Color(0xFF9CA3AF)),
                  const SizedBox(height: 12),
                  const Text('No Saved Payment Methods', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF111827))),
                  const SizedBox(height: 4),
                  const Text('Save a card or UPI ID for faster 1-Click checkout on Cosmyra.', style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)), textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => _showAddPaymentMethodDialog(context),
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Add Payment Method', style: TextStyle(fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4F46E5),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ],
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _paymentMethods.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, idx) {
                final pay = _paymentMethods[idx];
                final isUpi = pay['type'] == 'UPI';

                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEEF2FF),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(isUpi ? Icons.account_balance_wallet_outlined : Icons.credit_card_outlined, color: const Color(0xFF4F46E5), size: 24),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(pay['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF111827))),
                            const SizedBox(height: 2),
                            Text(pay['detail'] as String, style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                        onPressed: () => _confirmDeletePaymentMethod(context, idx),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════
  // 4. COUPONS VIEW
  // ═════════════════════════════════════════════════════════════
  Widget _buildCouponsView(BuildContext context) {
    final coupons = [
      {'code': 'VAIDYAM20', 'discount': '20% OFF', 'desc': 'Get 20% instant discount on all Organic Skincare & Herbal Hair oils', 'min': 'Min. order ₹799', 'exp': 'Valid till Dec 31, 2026', 'color': const Color(0xFF4F46E5)},
      {'code': 'WELCOME100', 'discount': 'FLAT ₹100 OFF', 'desc': 'Flat ₹100 discount on your first Vaidyam Botanicals purchase', 'min': 'No min order required', 'exp': 'Valid for new accounts', 'color': const Color(0xFF059669)},
      {'code': 'FREESHIP', 'discount': 'FREE SHIPPING', 'desc': 'Free Express Courier shipping directly to your doorstep', 'min': 'Min. order ₹499', 'exp': 'Always active', 'color': const Color(0xFFD97706)},
      {'code': 'HERBAL15', 'discount': '15% CASHBACK', 'desc': '15% cashback credited to your account balance on herbal serums', 'min': 'Min. order ₹999', 'exp': 'Valid this month', 'color': const Color(0xFF6366F1)},
    ];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('My Coupons & Exclusive Offers', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
          const SizedBox(height: 4),
          const Text('Apply available discount promo codes during checkout for instant savings.', style: TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
          const SizedBox(height: 24),

          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 380,
              mainAxisExtent: 160,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: coupons.length,
            itemBuilder: (context, idx) {
              final c = coupons[idx];
              final color = c['color'] as Color;

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: color.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(6)),
                          child: Text(c['code'] as String, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1)),
                        ),
                        InkWell(
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Coupon code ${c['code']} copied!')));
                          },
                          child: Text('COPY CODE', style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 11)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(c['discount'] as String, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: color)),
                    const SizedBox(height: 4),
                    Text(c['desc'] as String, style: const TextStyle(fontSize: 11, color: Color(0xFF374151)), maxLines: 2, overflow: TextOverflow.ellipsis),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(c['min'] as String, style: const TextStyle(fontSize: 10, color: Color(0xFF6B7280))),
                        Text(c['exp'] as String, style: const TextStyle(fontSize: 10, color: Color(0xFF6B7280))),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════
  // 5. NOTIFICATIONS VIEW
  // ═════════════════════════════════════════════════════════════
  Widget _buildNotificationsView(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
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
                  Text('Notification Center', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
                  SizedBox(height: 4),
                  Text('Stay updated on order status, price drops, and announcements.', style: TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                ],
              ),
              Row(
                children: [
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        for (var n in _notifications) {
                          n['isRead'] = true;
                        }
                      });
                      _saveNotificationsToStorage();
                      showCenterActionToast(
                        context,
                        title: 'All Read! 🔔',
                        message: 'All notifications marked as read.',
                        icon: Icons.done_all,
                        iconColor: const Color(0xFF4F46E5),
                        primaryActionLabel: null,
                      );
                    },
                    icon: const Icon(Icons.done_all, size: 16, color: Color(0xFF4F46E5)),
                    label: const Text('Mark All Read', style: TextStyle(color: Color(0xFF4F46E5), fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: () => _clearAllNotifications(context),
                    icon: const Icon(Icons.cleaning_services_outlined, size: 16, color: Color(0xFFDC2626)),
                    label: const Text('Clear All', style: TextStyle(color: Color(0xFFDC2626), fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          if (_notifications.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Column(
                children: const [
                  Icon(Icons.notifications_off_outlined, size: 48, color: Color(0xFF9CA3AF)),
                  SizedBox(height: 12),
                  Text('No New Notifications', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF111827))),
                  SizedBox(height: 4),
                  Text("You're all caught up! Order updates, offers, and herbal tips will appear here.", style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)), textAlign: TextAlign.center),
                ],
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _notifications.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, idx) {
                final n = _notifications[idx];
                final bool isRead = n['isRead'] == true;
                final color = n['color'] as Color;

                return InkWell(
                  onTap: () {
                    setState(() => n['isRead'] = true);
                    _saveNotificationsToStorage();
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
                          child: Icon(n['icon'] as IconData, color: color, size: 20),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(n['title'] as String, style: TextStyle(fontWeight: isRead ? FontWeight.w600 : FontWeight.bold, fontSize: 14, color: const Color(0xFF111827))),
                                  const SizedBox(width: 8),
                                  if (!isRead)
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(color: Color(0xFF4F46E5), shape: BoxShape.circle),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(n['message'] as String, style: const TextStyle(fontSize: 12, color: Color(0xFF4B5563))),
                              const SizedBox(height: 4),
                              Text(n['time'] as String, style: const TextStyle(fontSize: 10, color: Color(0xFF9CA3AF))),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 16, color: Color(0xFF9CA3AF)),
                          onPressed: () => _confirmDeleteNotification(context, idx),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════
  // 6. RETURNS & REFUNDS VIEW
  // ═════════════════════════════════════════════════════════════
  Widget _buildReturnsRefundsView(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
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
                  Text('Returns & Refunds Manager', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
                  SizedBox(height: 4),
                  Text('Track return status or initiate a return for delivered orders.', style: TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () {
                  context.go('/orders');
                },
                icon: const Icon(Icons.assignment_return_outlined, size: 16),
                label: const Text('Request New Return', style: TextStyle(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4F46E5),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Policy Summary Banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFEEF2FF),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFC7D2FE)),
            ),
            child: Row(
              children: const [
                Icon(Icons.verified_outlined, color: Color(0xFF4F46E5), size: 24),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('10-Day Money Back Guarantee', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF312E81))),
                      Text('Hassle-free doorstep pickup & 100% refund credited within 24-48 hours of item collection.', style: TextStyle(fontSize: 11, color: Color(0xFF4338CA))),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          const Text('Active Return Requests', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
          const SizedBox(height: 12),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Column(
              children: const [
                Icon(Icons.assignment_turned_in_outlined, size: 48, color: Color(0xFF9CA3AF)),
                SizedBox(height: 12),
                Text('No active return requests', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF374151))),
                SizedBox(height: 4),
                Text('All your delivered orders are in good standing.', style: TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════
  // 7. HELP & SUPPORT VIEW
  // ═════════════════════════════════════════════════════════════
  Widget _buildHelpSupportView(BuildContext context) {
    final faqs = [
      {'q': 'How do I track my order shipment?', 'a': 'You can track your order in real-time by visiting "My Orders" tab on your dashboard or using the tracking link sent to your SMS and email.'},
      {'q': 'What is Vaidyam Botanicals return policy?', 'a': 'We offer a 10-day 100% money-back return policy on unopened botanical products. Contact support to schedule a free doorstep pickup.'},
      {'q': 'Are all ingredients 100% natural and certified organic?', 'a': 'Yes! All Vaidyam Botanicals formulations use certified organic herbs, cold-pressed oils, and zero synthetic parabens or sulfates.'},
      {'q': 'How do I apply coupon codes during checkout?', 'a': 'On the checkout screen, enter your promo code in the "Apply Coupon" box and click Apply to claim instant discounts.'},
    ];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Help & Customer Support', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
          const SizedBox(height: 4),
          const Text('We are available 24/7 to assist you with order tracking, skincare guidance, and refunds.', style: TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
          const SizedBox(height: 24),

          // 3 Contact Channels
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: const Color(0xFFECFDF5), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFA7F3D0))),
                  child: Column(
                    children: const [
                      Icon(Icons.chat_bubble_outline, color: Color(0xFF059669), size: 28),
                      SizedBox(height: 8),
                      Text('WhatsApp Support', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF065F46))),
                      SizedBox(height: 2),
                      Text('+91 94730 40903', style: TextStyle(fontSize: 11, color: Color(0xFF047857))),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: const Color(0xFFEEF2FF), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFC7D2FE))),
                  child: Column(
                    children: const [
                      Icon(Icons.phone_outlined, color: Color(0xFF4F46E5), size: 28),
                      SizedBox(height: 8),
                      Text('Toll-Free Helpline', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF312E81))),
                      SizedBox(height: 2),
                      Text('1800-123-8243', style: TextStyle(fontSize: 11, color: Color(0xFF4338CA))),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: const Color(0xFFFEF3C7), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFFDE68A))),
                  child: Column(
                    children: const [
                      Icon(Icons.email_outlined, color: Color(0xFFD97706), size: 28),
                      SizedBox(height: 8),
                      Text('Email Care', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF92400E))),
                      SizedBox(height: 2),
                      Text('support@cosmyra.cloud', style: TextStyle(fontSize: 11, color: Color(0xFFB45309))),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),
          const Text('Frequently Asked Questions (FAQ)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
          const SizedBox(height: 12),

          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: faqs.length,
            itemBuilder: (context, idx) {
              final bool isExp = _faqExpanded[idx] == true;
              final f = faqs[idx];

              return Column(
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(f['q']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF111827))),
                    trailing: Icon(isExp ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, color: const Color(0xFF4F46E5)),
                    onTap: () => setState(() => _faqExpanded[idx] = !isExp),
                  ),
                  if (isExp)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(f['a']!, style: const TextStyle(fontSize: 12, color: Color(0xFF4B5563), height: 1.5)),
                    ),
                  const Divider(height: 1),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════
  // 8. ACCOUNT DETAILS VIEW
  // ═════════════════════════════════════════════════════════════
  Widget _buildAccountDetailsView(BuildContext context, String displayName, String displayEmail, String displayPhone) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
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
                  Text('Account Details', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
                  SizedBox(height: 4),
                  Text('View and edit your personal profile information.', style: TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () => _showEditProfileDialog(context, displayName, displayEmail, displayPhone),
                icon: const Icon(Icons.edit, size: 16),
                label: const Text('Edit Profile'),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4F46E5), foregroundColor: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _detailRow('Full Name', displayName),
          const Divider(height: 24),
          _detailRow('Email Address', displayEmail),
          const Divider(height: 24),
          _detailRow('Mobile Number', displayPhone),
          const Divider(height: 24),
          _detailRow('Account Status', 'Active • Verified Customer'),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Row(
      children: [
        SizedBox(width: 140, child: Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280), fontWeight: FontWeight.w500))),
        Expanded(child: Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF111827)))),
      ],
    );
  }

  // ═════════════════════════════════════════════════════════════
  // 9. CHANGE PASSWORD VIEW
  // ═════════════════════════════════════════════════════════════
  Widget _buildChangePasswordView(BuildContext context) {
    final currCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Change Security Password', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
          const SizedBox(height: 4),
          const Text('Update your password to keep your account safe.', style: TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
          const SizedBox(height: 24),

          SizedBox(
            width: 400,
            child: Column(
              children: [
                TextField(controller: currCtrl, obscureText: true, decoration: const InputDecoration(labelText: 'Current Password', border: OutlineInputBorder())),
                const SizedBox(height: 16),
                TextField(controller: newCtrl, obscureText: true, decoration: const InputDecoration(labelText: 'New Password', border: OutlineInputBorder())),
                const SizedBox(height: 16),
                TextField(controller: confirmCtrl, obscureText: true, decoration: const InputDecoration(labelText: 'Confirm New Password', border: OutlineInputBorder())),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (newCtrl.text.isNotEmpty && newCtrl.text == confirmCtrl.text) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password updated successfully!')));
                        currCtrl.clear();
                        newCtrl.clear();
                        confirmCtrl.clear();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Passwords do not match'), backgroundColor: Colors.red));
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4F46E5),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Update Password', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════
  // 10. ACCOUNT SETTINGS VIEW
  // ═════════════════════════════════════════════════════════════
  Widget _buildAccountSettingsView(BuildContext context, String displayName, String displayEmail) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Account & Privacy Preferences', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
          const SizedBox(height: 4),
          const Text('Manage communication alerts and account privacy settings.', style: TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
          const SizedBox(height: 24),

          SwitchListTile(
            title: const Text('Email Newsletter & Special Discounts', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            subtitle: const Text('Receive promotional offers and herbal product guides.', style: TextStyle(fontSize: 12)),
            value: _emailNewsletter,
            activeColor: const Color(0xFF4F46E5),
            onChanged: (val) => setState(() => _emailNewsletter = val),
          ),
          const Divider(height: 1),
          SwitchListTile(
            title: const Text('SMS Order Dispatch Updates', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            subtitle: const Text('Receive courier tracking links via SMS.', style: TextStyle(fontSize: 12)),
            value: _smsUpdates,
            activeColor: const Color(0xFF4F46E5),
            onChanged: (val) => setState(() => _smsUpdates = val),
          ),
          const Divider(height: 1),
          SwitchListTile(
            title: const Text('WhatsApp Instant Delivery Alerts', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            subtitle: const Text('Receive real-time order updates on WhatsApp.', style: TextStyle(fontSize: 12)),
            value: _whatsappAlerts,
            activeColor: const Color(0xFF4F46E5),
            onChanged: (val) => setState(() => _whatsappAlerts = val),
          ),

          const SizedBox(height: 32),
          const Text('Danger Zone', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.red)),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () async {
              await ref.read(authControllerProvider.notifier).signOut();
              if (context.mounted) {
                context.go('/login');
              }
            },
            icon: const Icon(Icons.delete_forever, size: 16, color: Colors.red),
            label: const Text('Delete Account', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════
  // SHARED DASHBOARD WIDGETS
  // ═════════════════════════════════════════════════════════════
  Widget _buildStatCard(String label, String value, String actionLabel, IconData icon, Color bg, Color color, VoidCallback onTap) {
    return Container(
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
            decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280), fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
                const SizedBox(height: 4),
                InkWell(
                  onTap: onTap,
                  child: Text(actionLabel, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentOrdersCard(BuildContext context) {
    final ordersAsync = ref.watch(userOrdersFutureProvider);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Recent Orders', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
              InkWell(
                onTap: () => context.go('/orders'),
                child: const Text('View All', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF4F46E5))),
              ),
            ],
          ),
          const SizedBox(height: 16),

          ordersAsync.when(
            data: (realOrders) {
              if (realOrders.isEmpty) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Column(
                    children: [
                      const Icon(Icons.shopping_bag_outlined, size: 48, color: Color(0xFF9CA3AF)),
                      const SizedBox(height: 12),
                      const Text('No Recent Orders', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
                      const SizedBox(height: 4),
                      const Text('You have not placed any orders yet. Explore our Ayurvedic formulations to start shopping.', style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)), textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () => context.go('/explore'),
                        icon: const Icon(Icons.local_mall_outlined, size: 16),
                        label: const Text('Explore Formulations'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4F46E5),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: realOrders.take(4).length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, idx) {
                  final ord = realOrders[idx];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(ord.orderNumber, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF111827))),
                            Text(DateFormat('MMM dd, yyyy').format(ord.createdAt), style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
                          ],
                        ),
                        const Spacer(),
                        Text('₹${ord.totalAmount.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF111827))),
                        const SizedBox(width: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: const Color(0xFFFEF3C7), borderRadius: BorderRadius.circular(6)),
                          child: Text(ord.fulfillmentStatus, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFD97706))),
                        ),
                        const SizedBox(width: 16),
                        InkWell(
                          onTap: () => context.go('/orders'),
                          child: const Text('Track Order', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF4F46E5))),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
            loading: () => const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator())),
            error: (_, __) => const Text('Unable to load orders', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountDetailsCard(BuildContext context, String displayName, String displayEmail, String displayPhone) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Account Details', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
          const SizedBox(height: 16),
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: const Color(0xFF4F46E5),
                child: Text(
                  displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(displayName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
                    Text(displayEmail, style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)), overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.phone_outlined, size: 16, color: Color(0xFF6B7280)),
              const SizedBox(width: 8),
              Text(displayPhone, style: const TextStyle(fontSize: 12, color: Color(0xFF374151), fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _showEditProfileDialog(context, displayName, displayEmail, displayPhone),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFE5E7EB)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              icon: const Icon(Icons.edit_outlined, size: 16, color: Color(0xFF4F46E5)),
              label: const Text('Edit Profile', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF4F46E5))),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReferCard(BuildContext context, String referCode) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4F46E5), Color(0xFF6366F1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('REFER & EARN', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
              Icon(Icons.card_giftcard, color: Colors.white, size: 20),
            ],
          ),
          const SizedBox(height: 6),
          const Text('Invite your friends and earn', style: TextStyle(color: Color(0xFFE0E7FF), fontSize: 12)),
          const SizedBox(height: 10),
          const Text('₹250', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900)),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _showReferralDialog(context, referCode),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF4F46E5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Invite Now', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
