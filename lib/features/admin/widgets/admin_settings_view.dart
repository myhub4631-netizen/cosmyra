import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/theme/app_colors.dart';
import '../../shipping/controllers/shipping_settings_controller.dart';

class AdminSettingsView extends ConsumerStatefulWidget {
  const AdminSettingsView({super.key});

  @override
  ConsumerState<AdminSettingsView> createState() => _AdminSettingsViewState();
}

class _AdminSettingsViewState extends ConsumerState<AdminSettingsView> {
  late TextEditingController _freeShippingThresholdController;
  late TextEditingController _flatShippingFeeController;
  late TextEditingController _superfastFeeController;
  late TextEditingController _gstRateController;

  bool _shiprocketActive = true;
  bool _delhiveryActive = true;
  bool _indiaPostActive = true;
  bool _bluedartActive = false;
  bool _isSuperfastActive = true;

  @override
  void initState() {
    super.initState();
    final settings = ref.read(shippingSettingsProvider);
    _freeShippingThresholdController = TextEditingController(text: settings.freeShippingThreshold.toInt().toString());
    _flatShippingFeeController = TextEditingController(text: settings.standardShippingFee.toInt().toString());
    _superfastFeeController = TextEditingController(text: settings.superfastDeliveryFee.toInt().toString());
    _gstRateController = TextEditingController(text: '18');
    _isSuperfastActive = settings.isSuperfastEnabled;
  }

  @override
  void dispose() {
    _freeShippingThresholdController.dispose();
    _flatShippingFeeController.dispose();
    _superfastFeeController.dispose();
    _gstRateController.dispose();
    super.dispose();
  }

  void _saveSettings() {
    final standardFee = double.tryParse(_flatShippingFeeController.text) ?? 0.0;
    final freeThreshold = double.tryParse(_freeShippingThresholdController.text) ?? 399.0;
    final superfastFee = double.tryParse(_superfastFeeController.text) ?? 60.0;

    final updated = ShippingSettings(
      standardShippingFee: standardFee,
      freeShippingThreshold: freeThreshold,
      isSuperfastEnabled: _isSuperfastActive,
      superfastDeliveryFee: superfastFee,
    );

    ref.read(shippingSettingsProvider.notifier).updateSettings(updated);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Successfully updated shipping charges & delivery settings!'),
        backgroundColor: Color(0xFF10B981),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    ref.listen<ShippingSettings>(shippingSettingsProvider, (prev, next) {
      if (mounted) {
        _freeShippingThresholdController.text = next.freeShippingThreshold.toInt().toString();
        _flatShippingFeeController.text = next.standardShippingFee.toInt().toString();
        _superfastFeeController.text = next.superfastDeliveryFee.toInt().toString();
        setState(() {
          _isSuperfastActive = next.isSuperfastEnabled;
        });
      }
    });

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Store & Logistics Configuration',
                    style: TextStyle(
                      fontFamily: 'serif',
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.goldAccent : AppColors.forestSageDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Manage shipping fees (Free / ₹0), superfast delivery charge (Rs 60), tax rules & courier integrations.',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? AppColors.textLightSecondary : AppColors.textDarkSecondary,
                    ),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: _saveSettings,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.forestSage,
                  foregroundColor: AppColors.softWhite,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                ),
                icon: const Icon(Icons.save_outlined, size: 18),
                label: const Text('Save Settings', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Shipping Rates & Superfast Delivery Management Card
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.local_shipping_outlined, color: Color(0xFF4F46E5), size: 22),
                      const SizedBox(width: 8),
                      const Text(
                        'Shipping Fee & Express Delivery Manager 🚚',
                        style: TextStyle(fontFamily: 'serif', fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Set standard delivery charge to 0 (Free), configure free shipping thresholds, and set Superfast Delivery fee (Rs 60).',
                    style: TextStyle(fontSize: 12, color: isDark ? AppColors.textLightSecondary : AppColors.textDarkSecondary),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _flatShippingFeeController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Standard Shipping Fee (₹)',
                            hintText: '0 for Free Delivery',
                            helperText: 'Set 0 for Free Delivery across all orders below threshold',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.currency_rupee),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          controller: _freeShippingThresholdController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Free Shipping Minimum Spend (₹)',
                            helperText: 'Orders above this subtotal qualify for ₹0 Free Delivery (Set 0 for sitewide Free)',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.shopping_bag_outlined),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          controller: _superfastFeeController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Superfast Express Delivery Fee (₹)',
                            helperText: 'Custom fee for 24-48h superfast express delivery (Default: Rs 60)',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.bolt, color: Colors.amber),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: SwitchListTile(
                      title: const Text(
                        'Enable ⚡ Superfast Express Delivery Option at Checkout',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      subtitle: const Text(
                        'Allows customers to choose 24-48 hr priority dispatch for Rs 60 during checkout',
                        style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                      ),
                      value: _isSuperfastActive,
                      activeColor: const Color(0xFF4F46E5),
                      onChanged: (val) => setState(() => _isSuperfastActive = val),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Logistics & Multi-Courier API Gateways Card
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Multi-Courier Logistics & API Integration Engine',
                    style: TextStyle(fontFamily: 'serif', fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Automated AWB generation, real-time rate comparison, and dispatch webhook routing.',
                    style: TextStyle(fontSize: 12, color: isDark ? AppColors.textLightSecondary : AppColors.textDarkSecondary),
                  ),
                  const SizedBox(height: 16),

                  SwitchListTile(
                    title: const Text('Shiprocket API (Primary Courier Aggregator)'),
                    subtitle: const Text('Auto-creates AWBs for Delhivery, Xpressbees, Shadowfax & Ecom Express'),
                    value: _shiprocketActive,
                    activeThumbColor: AppColors.goldAccent,
                    onChanged: (val) => setState(() => _shiprocketActive = val),
                  ),
                  const Divider(),
                  SwitchListTile(
                    title: const Text('Delhivery Direct API (Express Surface/Air)'),
                    subtitle: const Text('Direct enterprise API token configured'),
                    value: _delhiveryActive,
                    activeThumbColor: AppColors.goldAccent,
                    onChanged: (val) => setState(() => _delhiveryActive = val),
                  ),
                  const Divider(),
                  SwitchListTile(
                    title: const Text('India Post Speed Post Engine'),
                    subtitle: const Text('Covers 19,000+ PIN codes across remote India tier-3/4 locations'),
                    value: _indiaPostActive,
                    activeThumbColor: AppColors.goldAccent,
                    onChanged: (val) => setState(() => _indiaPostActive = val),
                  ),
                  const Divider(),
                  SwitchListTile(
                    title: const Text('BlueDart Express Integration'),
                    subtitle: const Text('Priority air express for premium orders'),
                    value: _bluedartActive,
                    activeThumbColor: AppColors.goldAccent,
                    onChanged: (val) => setState(() => _bluedartActive = val),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Botanical Store Profile Card
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Store Branding & Botanical Certifications',
                    style: TextStyle(fontFamily: 'serif', fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  const Text('Brand Title: Cosmyra • Vaidyam Botanicals', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  const Text('Ayurvedic License #: MH/AYUR/2026/00918', style: TextStyle(fontSize: 12)),
                  const SizedBox(height: 4),
                  const Text('Registered Address: 104 Heritage Heights, Bandra West, Mumbai, MH - 400050', style: TextStyle(fontSize: 12)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

