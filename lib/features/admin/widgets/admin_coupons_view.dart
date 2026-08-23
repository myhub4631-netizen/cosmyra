import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../coupons/controllers/coupon_controller.dart';

class AdminCouponsView extends ConsumerStatefulWidget {
  const AdminCouponsView({super.key});

  @override
  ConsumerState<AdminCouponsView> createState() => _AdminCouponsViewState();
}

class _AdminCouponsViewState extends ConsumerState<AdminCouponsView> {
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
                                DropdownMenuItem(value: 'percentage', child: Text('Percentage (%)')),
                                DropdownMenuItem(value: 'fixed', child: Text('Fixed Amount (₹)')),
                              ],
                              onChanged: (val) {
                                if (val != null) setModalState(() => discountType = val);
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: valCtrl,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: discountType == 'percentage' ? 'Discount %' : 'Discount INR (₹)',
                                border: const OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: minSpendCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Minimum Order Spend (₹)',
                          hintText: 'e.g. 499 (0 for no min spend)',
                          prefixIcon: Icon(Icons.shopping_bag_outlined),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          children: [
                            SwitchListTile(
                              title: const Text(
                                'Visible at Checkout Page',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E293B)),
                              ),
                              subtitle: const Text(
                                'Show this coupon card in available offers section during checkout',
                                style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                              ),
                              value: isVisibleAtCheckout,
                              activeColor: const Color(0xFF4F46E5),
                              onChanged: (val) => setModalState(() => isVisibleAtCheckout = val),
                              dense: true,
                            ),
                            const Divider(height: 1),
                            SwitchListTile(
                              title: const Text(
                                'Coupon Active',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E293B)),
                              ),
                              value: isActive,
                              activeColor: const Color(0xFF10B981),
                              onChanged: (val) => setModalState(() => isActive = val),
                              dense: true,
                            ),
                          ],
                        ),
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
                    final code = codeCtrl.text.trim().toUpperCase();
                    final title = titleCtrl.text.trim();
                    final val = double.tryParse(valCtrl.text) ?? 10.0;
                    final minSpend = double.tryParse(minSpendCtrl.text) ?? 0.0;

                    if (code.isEmpty || title.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please fill out code and title!')),
                      );
                      return;
                    }

                    final newModel = CouponModel(
                      id: isEdit ? coupon.id : 'c-${DateTime.now().millisecondsSinceEpoch}',
                      code: code,
                      title: title,
                      discountType: discountType,
                      discountValue: val,
                      minSpend: minSpend,
                      isVisibleAtCheckout: isVisibleAtCheckout,
                      isActive: isActive,
                    );

                    if (isEdit) {
                      ref.read(couponProvider.notifier).updateCoupon(newModel);
                    } else {
                      ref.read(couponProvider.notifier).addCoupon(newModel);
                    }

                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(isEdit ? 'Updated coupon $code!' : 'Created coupon $code!')),
                    );
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

  @override
  Widget build(BuildContext context) {
    final coupons = ref.watch(couponProvider);
    final notifier = ref.read(couponProvider.notifier);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Coupon & Discount Manager 🎟️',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF111827)),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Create, manage, and toggle visibility of checkout promo codes & discounts.',
                    style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () => _showAddEditCouponDialog(),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('+ Create Coupon', style: TextStyle(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4F46E5),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Coupons List Card Grid / Table
          if (coupons.isEmpty)
            Container(
              padding: const EdgeInsets.all(40),
              width: double.infinity,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
              child: const Center(
                child: Text('No coupons available. Click "+ Create Coupon" to add one!'),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: coupons.length,
              itemBuilder: (context, index) {
                final c = coupons[index];
                final discountLabel = c.discountType == 'percentage'
                    ? '${c.discountValue.toInt()}% OFF'
                    : '₹${c.discountValue.toInt()} OFF';

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: BorderSide(color: c.isActive ? const Color(0xFFE2E8F0) : const Color(0xFFF1F5F9)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEEF2FF),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFC7D2FE)),
                          ),
                          child: Text(
                            c.code,
                            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Color(0xFF4F46E5), letterSpacing: 1),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    c.effectiveTitle,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1E293B)),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFECFDF5),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      discountLabel,
                                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF059669)),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Min Spend: ₹${c.minSpend.toInt()} • ${c.isVisibleAtCheckout ? "Visible at Checkout Page" : "Hidden (Manual Input Only)"}',
                                style: TextStyle(fontSize: 12, color: c.isVisibleAtCheckout ? const Color(0xFF059669) : const Color(0xFFD97706), fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),

                        // Toggle Active & Visibility at Checkout
                        Row(
                          children: [
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  c.isActive ? 'Active' : 'Disabled',
                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: c.isActive ? const Color(0xFF059669) : const Color(0xFFEF4444)),
                                ),
                                Switch(
                                  value: c.isActive,
                                  activeColor: const Color(0xFF10B981),
                                  onChanged: (val) => notifier.toggleActive(c.id, val),
                                ),
                              ],
                            ),
                            const SizedBox(width: 12),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('Show at Checkout', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                                Switch(
                                  value: c.isVisibleAtCheckout,
                                  activeColor: const Color(0xFF4F46E5),
                                  onChanged: (val) => notifier.toggleVisibilityAtCheckout(c.id, val),
                                ),
                              ],
                            ),
                            const SizedBox(width: 12),
                            IconButton(
                              icon: const Icon(Icons.edit_outlined, color: Color(0xFF475569)),
                              onPressed: () => _showAddEditCouponDialog(coupon: c),
                              tooltip: 'Edit Coupon',
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Color(0xFFEF4444)),
                              onPressed: () => notifier.deleteCoupon(c.id),
                              tooltip: 'Delete Coupon',
                            ),
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
    );
  }
}
