import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/center_action_toast.dart';
import '../../navigation/widgets/vaidyam_header_widget.dart';
import '../../navigation/widgets/vaidyam_mobile_bottom_nav_bar.dart';
import '../controllers/coupon_controller.dart';
import '../controllers/deals_offers_controller.dart';
import '../models/deal_offer_model.dart';

class DealsAndOffersScreen extends ConsumerWidget {
  const DealsAndOffersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deals = ref.watch(dealsOffersProvider).where((d) => d.isActive).toList();
    final coupons = ref.watch(couponProvider).where((c) => c.isActive).toList();
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth > 900;

    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFE),
      bottomNavigationBar: screenWidth <= 768 ? const VaidyamMobileBottomNavBar(activeTab: 'Home') : null,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isWide) const VaidyamHeaderWidget(activeTab: 'Shop'),

              // Custom Header Bar matching design
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: Color(0xFF1E293B)),
                      onPressed: () {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go('/');
                        }
                      },
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Deals & Offers',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF0F172A),
                              letterSpacing: -0.3,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Explore amazing offers and save more!',
                            style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                          ),
                        ],
                      ),
                    ),
                    // Notification Bell Badge
                    Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.notifications_none_rounded, size: 22, color: Color(0xFF334155)),
                        ),
                        Positioned(
                          right: 2,
                          top: 2,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Color(0xFFEF4444),
                              shape: BoxShape.circle,
                            ),
                            child: const Text(
                              '3',
                              style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const Divider(height: 1, color: Color(0xFFF1F5F9)),

              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isWide ? (screenWidth - 800) / 2 : 16.0,
                  vertical: 16.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Dynamic Deal Cards List
                    ...deals.map((deal) => Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: _buildDealCard(context, ref, deal, coupons),
                        )),

                    const SizedBox(height: 16),

                    // "How it works?" Section
                    const Text(
                      'How it works?',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                    ),
                    const SizedBox(height: 16),

                    _buildHowItWorksSteps(),

                    const SizedBox(height: 24),

                    // T&C Footer Banner
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFBEB),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFFDE68A)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle_rounded, color: Color(0xFFD97706), size: 18),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              'All offers are valid for a limited time only. *T&C Apply',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF92400E)),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              _showTermsDialog(context);
                            },
                            style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
                            child: const Text(
                              'View T&C',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFD97706), decoration: TextDecoration.underline),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDealCard(BuildContext context, WidgetRef ref, DealOfferModel deal, List<CouponModel> coupons) {
    Color cardBg;
    Color borderColor;
    Color iconBg;
    Color buttonColor;
    Color buttonTextColor;
    Widget leftIcon;
    Widget rightGraphic;

    switch (deal.cardTheme.toLowerCase()) {
      case 'green':
        cardBg = const Color(0xFFF0FDF4);
        borderColor = const Color(0xFFDCFCE7);
        iconBg = const Color(0xFF16A34A);
        buttonColor = const Color(0xFFDCFCE7);
        buttonTextColor = const Color(0xFF15803D);
        leftIcon = const Icon(Icons.card_giftcard_rounded, color: Colors.white, size: 22);
        rightGraphic = _buildReferralGraphic();
        break;
      case 'blue':
        cardBg = const Color(0xFFF0F9FF);
        borderColor = const Color(0xFFE0F2FE);
        iconBg = const Color(0xFF0284C7);
        buttonColor = const Color(0xFFE0F2FE);
        buttonTextColor = const Color(0xFF0369A1);
        leftIcon = const Text('BOGO', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 10));
        rightGraphic = _buildBogoGraphic();
        break;
      case 'purple':
        cardBg = const Color(0xFFFAF5FF);
        borderColor = const Color(0xFFF3E8FF);
        iconBg = const Color(0xFF9333EA);
        buttonColor = const Color(0xFFF3E8FF);
        buttonTextColor = const Color(0xFF7E22CE);
        leftIcon = const Icon(Icons.people_alt_rounded, color: Colors.white, size: 20);
        rightGraphic = _buildUgcGraphic();
        break;
      case 'red':
      default:
        cardBg = const Color(0xFFFFF5F5);
        borderColor = const Color(0xFFFFE4E4);
        iconBg = const Color(0xFFEF4444);
        buttonColor = const Color(0xFFFFE4E4);
        buttonTextColor = const Color(0xFFB91C1C);
        leftIcon = const Icon(Icons.local_offer_rounded, color: Colors.white, size: 20);
        rightGraphic = _buildCouponsGraphic();
        break;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1.2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: iconBg,
                        shape: BoxShape.circle,
                      ),
                      child: Center(child: leftIcon),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        deal.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  deal.description,
                  style: const TextStyle(fontSize: 13, color: Color(0xFF475569), height: 1.35),
                ),
                const SizedBox(height: 14),
                ElevatedButton(
                  onPressed: () {
                    _handleDealCardAction(context, deal, coupons);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonColor,
                    foregroundColor: buttonTextColor,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text(
                    deal.buttonLabel,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Graphic + Navigation Circle Button
          Column(
            children: [
              rightGraphic,
              const SizedBox(height: 12),
              InkWell(
                onTap: () => _handleDealCardAction(context, deal, coupons),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: iconBg,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.chevron_right_rounded, color: Colors.white, size: 22),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCouponsGraphic() {
    return Container(
      width: 90,
      height: 70,
      decoration: BoxDecoration(
        color: const Color(0xFFFCA5A5).withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: const [
          Icon(Icons.confirmation_number_outlined, size: 44, color: Color(0xFFEF4444)),
          Text('%', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFFB91C1C))),
        ],
      ),
    );
  }

  Widget _buildReferralGraphic() {
    return Container(
      width: 90,
      height: 70,
      decoration: BoxDecoration(
        color: const Color(0xFF86EFAC).withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: Icon(Icons.supervisor_account_rounded, size: 44, color: Color(0xFF16A34A)),
      ),
    );
  }

  Widget _buildBogoGraphic() {
    return Container(
      width: 90,
      height: 70,
      decoration: BoxDecoration(
        color: const Color(0xFF7DD3FC).withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.shopping_bag_rounded, size: 32, color: Color(0xFF0284C7)),
          Text('BUY 1 GET 1', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Color(0xFF0369A1))),
        ],
      ),
    );
  }

  Widget _buildUgcGraphic() {
    return Container(
      width: 90,
      height: 70,
      decoration: BoxDecoration(
        color: const Color(0xFFD8B4FE).withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: Icon(Icons.linked_camera_rounded, size: 40, color: Color(0xFF9333EA)),
      ),
    );
  }

  Widget _buildHowItWorksSteps() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 600;
        final steps = [
          _StepItem(icon: Icons.local_offer_outlined, iconBg: const Color(0xFFFFE4E4), iconColor: const Color(0xFFEF4444), title: 'Explore Offers', desc: 'Browse all available offers and deals'),
          _StepItem(icon: Icons.percent_rounded, iconBg: const Color(0xFFFFEDD5), iconColor: const Color(0xFFF97316), title: 'Choose & Apply', desc: 'Select the best offer and apply at checkout'),
          _StepItem(icon: Icons.shopping_bag_outlined, iconBg: const Color(0xFFDCFCE7), iconColor: const Color(0xFF16A34A), title: 'Shop & Save', desc: 'Complete your order and enjoy savings'),
          _StepItem(icon: Icons.card_giftcard_outlined, iconBg: const Color(0xFFF3E8FF), iconColor: const Color(0xFF9333EA), title: 'Earn Rewards', desc: 'Earn points and rewards on every order'),
        ];

        if (isNarrow) {
          return Column(
            children: steps.map((s) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(color: s.iconBg, shape: BoxShape.circle),
                    child: Icon(s.icon, color: s.iconColor, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(s.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A))),
                        Text(s.desc, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                      ],
                    ),
                  ),
                ],
              ),
            )).toList(),
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: steps.asMap().entries.map((entry) {
            final idx = entry.key;
            final s = entry.value;
            final isLast = idx == steps.length - 1;
            return Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(color: s.iconBg, shape: BoxShape.circle),
                          child: Icon(s.icon, color: s.iconColor, size: 22),
                        ),
                        const SizedBox(height: 8),
                        Text(s.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF0F172A)), textAlign: TextAlign.center),
                        const SizedBox(height: 2),
                        Text(s.desc, style: const TextStyle(fontSize: 10, color: Color(0xFF64748B)), textAlign: TextAlign.center, maxLines: 2),
                      ],
                    ),
                  ),
                  if (!isLast) const Icon(Icons.chevron_right_rounded, size: 16, color: Color(0xFFCBD5E1)),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  void _handleDealCardAction(BuildContext context, DealOfferModel deal, List<CouponModel> coupons) {
    if (deal.dealType == 'coupons') {
      _showCouponsModal(context, coupons);
    } else if (deal.dealType == 'referral') {
      context.push('/account?tab=Refer');
    } else if (deal.dealType == 'bogo') {
      context.push('/shop?sort=Highest%20Discount');
    } else if (deal.dealType == 'ugc') {
      _showUgcSubmissionDialog(context);
    } else {
      context.push(deal.targetRoute);
    }
  }

  void _showCouponsModal(BuildContext context, List<CouponModel> coupons) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Available Coupons 🏷️', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                ],
              ),
              const Divider(),
              const SizedBox(height: 8),
              if (coupons.isEmpty)
                const Padding(padding: EdgeInsets.all(24), child: Center(child: Text('No active promo coupons available right now.')))
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: coupons.length,
                    itemBuilder: (context, index) {
                      final c = coupons[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEEF2FF),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFC7D2FE)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(color: const Color(0xFF4F46E5), borderRadius: BorderRadius.circular(6)),
                              child: Text(c.code, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(c.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E293B))),
                                  if (c.minSpend > 0)
                                    Text('Min order value: ₹${c.minSpend.toInt()}', style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                                ],
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Clipboard.setData(ClipboardData(text: c.code));
                                Navigator.pop(context);
                                showCenterActionToast(
                                  context,
                                  title: 'Coupon Code Copied! 🏷️',
                                  message: '${c.code} copied to clipboard.',
                                  icon: Icons.content_copy,
                                );
                              },
                              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6366F1), foregroundColor: Colors.white),
                              child: const Text('COPY', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _showUgcSubmissionDialog(BuildContext context) {
    final linkCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: const [
              Icon(Icons.video_library_rounded, color: Color(0xFF9333EA)),
              SizedBox(width: 8),
              Text('Submit UGC Content 📹', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Post an unboxing, review or story on Instagram/YouTube tagging @CosmyraBotanicals and paste your post link below to earn ₹500 store credit!',
                style: TextStyle(fontSize: 12, color: Color(0xFF475569)),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: linkCtrl,
                decoration: const InputDecoration(
                  labelText: 'Social Post / Reel URL',
                  hintText: 'https://instagram.com/p/...',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF9333EA), foregroundColor: Colors.white),
              onPressed: () {
                if (linkCtrl.text.trim().isNotEmpty) {
                  Navigator.pop(context);
                  showCenterActionToast(
                    context,
                    title: 'Content Submitted! 🎉',
                    message: 'Our team will review your post and credit your wallet.',
                    icon: Icons.check_circle_outline,
                    iconColor: const Color(0xFF16A34A),
                  );
                }
              },
              child: const Text('Submit Link'),
            ),
          ],
        );
      },
    );
  }

  void _showTermsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Terms & Conditions 📜', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          content: const SingleChildScrollView(
            child: Text(
              '1. Promotional offers and coupons are valid for a limited time period only.\n'
              '2. Coupons cannot be combined with other ongoing offer codes unless explicitly specified.\n'
              '3. Referral rewards will be credited once the referred friend completes their first order.\n'
              '4. Cosmyra Botanicals reserves the right to modify or terminate offers at any time.',
              style: TextStyle(fontSize: 12, color: Color(0xFF334155), height: 1.5),
            ),
          ),
          actions: [
            ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('I Understand')),
          ],
        );
      },
    );
  }
}

class _StepItem {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String desc;

  const _StepItem({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.desc,
  });
}
