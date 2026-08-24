import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../coupons/controllers/coupon_controller.dart';
import '../../coupons/controllers/deals_offers_controller.dart';
import '../../coupons/models/deal_offer_model.dart';

class AdminCouponsView extends ConsumerStatefulWidget {
  const AdminCouponsView({super.key});

  @override
  ConsumerState<AdminCouponsView> createState() => _AdminCouponsViewState();
}

class _AdminCouponsViewState extends ConsumerState<AdminCouponsView> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showAddEditCouponDialog({CouponModel? coupon}) {
    final isEdit = coupon != null;
    final codeCtrl = TextEditingController(text: coupon?.code ?? '');
    final titleCtrl = TextEditingController(text: coupon?.title ?? '');
    final valCtrl = TextEditingController(text: coupon?.discountValue.toStringAsFixed(0) ?? '20');
    final minSpendCtrl = TextEditingController(text: coupon?.minSpend.toStringAsFixed(0) ?? '399');
    String discountType = coupon?.discountType ?? 'percentage';
    bool isVisibleAtCheckout = coupon?.isVisibleAtCheckout ?? true;
    bool isActive = coupon?.isActive ?? true;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text(
                isEdit ? 'Edit Coupon: ${coupon.code}' : 'Create New Coupon / Offer',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              content: SizedBox(
                width: 460,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: codeCtrl,
                        textCapitalization: TextCapitalization.characters,
                        decoration: const InputDecoration(
                          labelText: 'Coupon Code *',
                          hintText: 'e.g. VAIDYAM20, ORGANIC100',
                          prefixIcon: Icon(Icons.confirmation_number_outlined),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: titleCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Coupon Title / Offer Summary *',
                          hintText: 'e.g. Get 20% OFF on all organic formulations',
                          prefixIcon: Icon(Icons.subtitles_outlined),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: discountType,
                              decoration: const InputDecoration(
                                labelText: 'Discount Type',
                                border: OutlineInputBorder(),
                              ),
                              items: const [
                                DropdownMenuItem(value: 'percentage', child: Text('Percentage (% OFF)')),
                                DropdownMenuItem(value: 'fixed', child: Text('Fixed Amount (₹ OFF)')),
                              ],
                              onChanged: (val) => setModalState(() => discountType = val ?? 'percentage'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: valCtrl,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: discountType == 'percentage' ? 'Discount %' : 'Amount ₹',
                                border: const OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: minSpendCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Minimum Order Value (₹)',
                          hintText: '399',
                          prefixIcon: Icon(Icons.currency_rupee),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 14),
                      SwitchListTile(
                        title: const Text('Show at Checkout Page'),
                        subtitle: const Text('Allows users to select & auto-apply coupon'),
                        value: isVisibleAtCheckout,
                        onChanged: (val) => setModalState(() => isVisibleAtCheckout = val),
                      ),
                      SwitchListTile(
                        title: const Text('Is Active Coupon'),
                        value: isActive,
                        onChanged: (val) => setModalState(() => isActive = val),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4F46E5), foregroundColor: Colors.white),
                  onPressed: () {
                    if (codeCtrl.text.trim().isEmpty || titleCtrl.text.trim().isEmpty) return;
                    final newCoupon = CouponModel(
                      id: coupon?.id ?? 'cpn-${DateTime.now().millisecondsSinceEpoch}',
                      code: codeCtrl.text.trim().toUpperCase(),
                      title: titleCtrl.text.trim(),
                      discountType: discountType,
                      discountValue: double.tryParse(valCtrl.text.trim()) ?? 10.0,
                      minSpend: double.tryParse(minSpendCtrl.text.trim()) ?? 0.0,
                      isVisibleAtCheckout: isVisibleAtCheckout,
                      isActive: isActive,
                    );
                    ref.read(couponProvider.notifier).addCoupon(newCoupon);
                    Navigator.pop(context);
                  },
                  child: Text(isEdit ? 'Save Changes' : 'Create Coupon'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showAddEditDealDialog({DealOfferModel? deal}) {
    final isEdit = deal != null;
    final titleCtrl = TextEditingController(text: deal?.title ?? '');
    final descCtrl = TextEditingController(text: deal?.description ?? '');
    final btnCtrl = TextEditingController(text: deal?.buttonLabel ?? 'View Offer');
    final routeCtrl = TextEditingController(text: deal?.targetRoute ?? '/shop');
    final badgeCtrl = TextEditingController(text: deal?.badgeText ?? '');
    String cardTheme = deal?.cardTheme ?? 'red';
    String dealType = deal?.dealType ?? 'coupons';
    bool isActive = deal?.isActive ?? true;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text(
                isEdit ? 'Edit Deal Card: ${deal.title}' : 'Create New Deal Card 🏷️',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              content: SizedBox(
                width: 480,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: titleCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Deal Card Title *',
                          hintText: 'e.g. Refer & Earn, Coupons, Buy 1 Get 1',
                          prefixIcon: Icon(Icons.title),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: descCtrl,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          labelText: 'Deal Description *',
                          hintText: 'e.g. Use coupons to get instant discounts on your orders.',
                          prefixIcon: Icon(Icons.description_outlined),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: btnCtrl,
                              decoration: const InputDecoration(
                                labelText: 'Button Label *',
                                hintText: 'e.g. View All Coupons',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: cardTheme,
                              decoration: const InputDecoration(
                                labelText: 'Card Color Theme',
                                border: OutlineInputBorder(),
                              ),
                              items: const [
                                DropdownMenuItem(value: 'red', child: Text('🔴 Red / Pink')),
                                DropdownMenuItem(value: 'green', child: Text('🟢 Green')),
                                DropdownMenuItem(value: 'blue', child: Text('🔵 Blue')),
                                DropdownMenuItem(value: 'purple', child: Text('🟣 Purple')),
                              ],
                              onChanged: (val) => setModalState(() => cardTheme = val ?? 'red'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: dealType,
                              decoration: const InputDecoration(
                                labelText: 'Deal Type Action',
                                border: OutlineInputBorder(),
                              ),
                              items: const [
                                DropdownMenuItem(value: 'coupons', child: Text('Coupons Sheet')),
                                DropdownMenuItem(value: 'referral', child: Text('Referral Page')),
                                DropdownMenuItem(value: 'bogo', child: Text('BOGO Offer Catalog')),
                                DropdownMenuItem(value: 'ugc', child: Text('UGC Content Submit')),
                                DropdownMenuItem(value: 'custom', child: Text('Custom Route Link')),
                              ],
                              onChanged: (val) => setModalState(() => dealType = val ?? 'coupons'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: routeCtrl,
                              decoration: const InputDecoration(
                                labelText: 'Target Route URL',
                                hintText: '/shop, /account',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: badgeCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Badge Tag (Optional)',
                          hintText: 'e.g. HOT, BOGO, NEW',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 14),
                      SwitchListTile(
                        title: const Text('Is Active Deal Card'),
                        value: isActive,
                        onChanged: (val) => setModalState(() => isActive = val),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4F46E5), foregroundColor: Colors.white),
                  onPressed: () {
                    if (titleCtrl.text.trim().isEmpty) return;
                    final newDeal = DealOfferModel(
                      id: deal?.id ?? 'deal-${DateTime.now().millisecondsSinceEpoch}',
                      title: titleCtrl.text.trim(),
                      description: descCtrl.text.trim(),
                      buttonLabel: btnCtrl.text.trim(),
                      dealType: dealType,
                      targetRoute: routeCtrl.text.trim(),
                      cardTheme: cardTheme,
                      badgeText: badgeCtrl.text.trim().isNotEmpty ? badgeCtrl.text.trim() : null,
                      isActive: isActive,
                    );
                    ref.read(dealsOffersProvider.notifier).updateDeal(newDeal);
                    Navigator.pop(context);
                  },
                  child: Text(isEdit ? 'Save Deal Card' : 'Create Deal Card'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final coupons = ref.watch(couponProvider);
    final couponNotifier = ref.read(couponProvider.notifier);
    final deals = ref.watch(dealsOffersProvider);
    final dealsNotifier = ref.read(dealsOffersProvider.notifier);

    return Column(
      children: [
        // Tab Bar
        Container(
          color: Colors.white,
          child: TabBar(
            controller: _tabController,
            labelColor: const Color(0xFF4F46E5),
            unselectedLabelColor: const Color(0xFF64748B),
            indicatorColor: const Color(0xFF4F46E5),
            indicatorWeight: 3,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            tabs: const [
              Tab(text: 'Checkout Coupons & Codes 🎟️'),
              Tab(text: 'Deals & Offers Cards Manager 🏷️'),
            ],
          ),
        ),

        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              // TAB 1: Coupons Manager
              SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text('Coupon & Discount Manager 🎟️', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
                            SizedBox(height: 4),
                            Text('Create, manage, and toggle checkout promo codes & discounts.', style: TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
                          ],
                        ),
                        ElevatedButton.icon(
                          onPressed: () => _showAddEditCouponDialog(),
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('+ Create Coupon', style: TextStyle(fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4F46E5), foregroundColor: Colors.white),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    if (coupons.isEmpty)
                      const Card(child: Padding(padding: EdgeInsets.all(32), child: Center(child: Text('No coupons available.'))))
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: coupons.length,
                        itemBuilder: (context, index) {
                          final c = coupons[index];
                          final discountLabel = c.discountType == 'percentage' ? '${c.discountValue.toInt()}% OFF' : '₹${c.discountValue.toInt()} OFF';
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(color: const Color(0xFFEEF2FF), borderRadius: BorderRadius.circular(8)),
                                    child: Text(c.code, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Color(0xFF4F46E5))),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(c.effectiveTitle, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                        const SizedBox(height: 2),
                                        Text('Min Spend: ₹${c.minSpend.toInt()} • Discount: $discountLabel', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                                      ],
                                    ),
                                  ),
                                  Switch(value: c.isActive, activeColor: const Color(0xFF10B981), onChanged: (val) => couponNotifier.toggleActive(c.id, val)),
                                  IconButton(icon: const Icon(Icons.edit_outlined), onPressed: () => _showAddEditCouponDialog(coupon: c)),
                                  IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red), onPressed: () => couponNotifier.deleteCoupon(c.id)),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),

              // TAB 2: Deals & Offers Cards Manager
              SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text('Deals & Offers Cards Manager 🏷️', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
                            SizedBox(height: 4),
                            Text('Manage the offer cards displayed on user site at /deals (Coupons, Refer & Earn, BOGO, UGC).', style: TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
                          ],
                        ),
                        ElevatedButton.icon(
                          onPressed: () => _showAddEditDealDialog(),
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('+ Add Deal Card', style: TextStyle(fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), foregroundColor: Colors.white),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    if (deals.isEmpty)
                      const Card(child: Padding(padding: EdgeInsets.all(32), child: Center(child: Text('No deal cards configured.'))))
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: deals.length,
                        itemBuilder: (context, index) {
                          final d = deals[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: d.cardTheme == 'green'
                                        ? Colors.green
                                        : (d.cardTheme == 'blue' ? Colors.blue : (d.cardTheme == 'purple' ? Colors.purple : Colors.red)),
                                    child: Text(d.title.isNotEmpty ? d.title[0] : 'D', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(d.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                            if (d.badgeText != null) ...[
                                              const SizedBox(width: 8),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                decoration: BoxDecoration(color: const Color(0xFF6366F1), borderRadius: BorderRadius.circular(4)),
                                                child: Text(d.badgeText!, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                                              ),
                                            ],
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(d.description, style: const TextStyle(fontSize: 12, color: Color(0xFF475569))),
                                        const SizedBox(height: 2),
                                        Text('Button: "${d.buttonLabel}" • Action: ${d.dealType} (${d.targetRoute})', style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Text(d.isActive ? 'Active' : 'Hidden', style: TextStyle(fontSize: 11, color: d.isActive ? Colors.green : Colors.red, fontWeight: FontWeight.bold)),
                                      Switch(value: d.isActive, activeColor: const Color(0xFF10B981), onChanged: (val) => dealsNotifier.toggleDealActive(d.id)),
                                      IconButton(icon: const Icon(Icons.edit_outlined), onPressed: () => _showAddEditDealDialog(deal: d)),
                                      IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red), onPressed: () => dealsNotifier.deleteDeal(d.id)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
