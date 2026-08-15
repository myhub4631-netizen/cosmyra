import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/theme/app_colors.dart';
import '../../orders/models/order_model.dart';
import '../../orders/repositories/order_repository.dart';

class AdminOrdersView extends ConsumerStatefulWidget {
  const AdminOrdersView({super.key});

  @override
  ConsumerState<AdminOrdersView> createState() => _AdminOrdersViewState();
}

class _AdminOrdersViewState extends ConsumerState<AdminOrdersView> {
  String _selectedStatus = 'all';
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final allOrdersAsync = ref.watch(allAdminOrdersFutureProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
                    'Orders & Multi-Courier Fulfillment Hub',
                    style: TextStyle(
                      fontFamily: 'serif',
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.goldAccent : AppColors.forestSageDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Manage order lifecycle, assign couriers (Shiprocket/Delhivery/India Post), and print invoices.',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? AppColors.textLightSecondary : AppColors.textDarkSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Search & Status Filters
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: const InputDecoration(
                            hintText: 'Search Order #, Customer Name, Phone, or Courier Tracking #...',
                            prefixIcon: Icon(Icons.search, size: 20),
                            border: InputBorder.none,
                          ),
                          onChanged: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 20),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: ['all', 'placed', 'confirmed', 'processing', 'shipped', 'delivered', 'cancelled'].map((status) {
                        final isSelected = _selectedStatus == status;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(status.toUpperCase(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                            selected: isSelected,
                            selectedColor: AppColors.forestSage,
                            labelStyle: TextStyle(color: isSelected ? AppColors.softWhite : null),
                            onSelected: (_) => setState(() => _selectedStatus = status),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Orders List
          allOrdersAsync.when(
            data: (orders) {
              final filteredOrders = orders.where((o) {
                if (_selectedStatus != 'all' && o.fulfillmentStatus.toLowerCase() != _selectedStatus) {
                  return false;
                }
                if (_searchQuery.isNotEmpty) {
                  final matchNum = o.orderNumber.toLowerCase().contains(_searchQuery);
                  final matchCust = o.customerName.toLowerCase().contains(_searchQuery);
                  final matchPhone = o.customerPhone.toLowerCase().contains(_searchQuery);
                  final matchTracking = (o.trackingNumber ?? '').toLowerCase().contains(_searchQuery);
                  return matchNum || matchCust || matchPhone || matchTracking;
                }
                return true;
              }).toList();

              if (filteredOrders.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(40),
                  child: Center(
                    child: Text('No orders found for selected criteria.'),
                  ),
                );
              }

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredOrders.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final order = filteredOrders[index];
                  final statusColor = _getStatusColor(order.fulfillmentStatus);

                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  SelectableText(
                                    order.orderNumber,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'monospace'),
                                  ),
                                  const SizedBox(width: 12),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: statusColor.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                                    ),
                                    child: Text(
                                      order.fulfillmentStatus.toUpperCase(),
                                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: statusColor),
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                '₹${order.totalAmount.toInt()}',
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 18,
                                  color: isDark ? AppColors.goldAccent : AppColors.forestSageDark,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Customer details
                          Row(
                            children: [
                              const Icon(Icons.person_outline, size: 16),
                              const SizedBox(width: 6),
                              Text(
                                '${order.customerName} (${order.customerEmail}) • ${order.customerPhone}',
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),

                          // Address
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.location_on_outlined, size: 16),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  'Delivery: ${order.shippingAddress['address_line1'] ?? ''}, ${order.shippingAddress['city'] ?? ''}, ${order.shippingAddress['state'] ?? ''} - ${order.shippingAddress['pincode'] ?? ''}',
                                  style: TextStyle(fontSize: 12, color: isDark ? AppColors.textLightSecondary : AppColors.textDarkSecondary),
                                ),
                              ),
                            ],
                          ),

                          const Divider(height: 20),

                          // Ordered Items Breakdown
                          Text(
                            'Order Items (${order.items.length}):',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: order.items.map((item) {
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppColors.forestSage.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '${item.productName} (${item.variantName}) x${item.quantity} - ₹${item.unitPrice.toInt()}',
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
                                ),
                              );
                            }).toList(),
                          ),

                          const SizedBox(height: 16),

                          // Fulfillment & Logistics Dispatch Controls
                          Wrap(
                            spacing: 16,
                            runSpacing: 12,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              // Status selection dropdown
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text('Fulfillment State: ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                  DropdownButton<String>(
                                    value: order.fulfillmentStatus,
                                    underline: const SizedBox.shrink(),
                                    items: ['placed', 'confirmed', 'processing', 'shipped', 'delivered', 'cancelled']
                                        .map((s) => DropdownMenuItem(
                                              value: s,
                                              child: Text(s.toUpperCase(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                            ))
                                        .toList(),
                                    onChanged: (newStatus) {
                                      if (newStatus != null) {
                                        ref.read(orderRepositoryProvider).updateOrderFulfillment(
                                              orderId: order.id,
                                              status: newStatus,
                                            );
                                        ref.invalidate(allAdminOrdersFutureProvider);
                                      }
                                    },
                                  ),
                                ],
                              ),

                              // Multi-Courier selector
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text('Courier Partner: ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                  DropdownButton<String>(
                                    value: order.courierPartner ?? 'shiprocket',
                                    underline: const SizedBox.shrink(),
                                    items: const [
                                      DropdownMenuItem(value: 'shiprocket', child: Text('Shiprocket (Primary)')),
                                      DropdownMenuItem(value: 'delhivery', child: Text('Delhivery Direct')),
                                      DropdownMenuItem(value: 'indiapost', child: Text('India Post (Speed Post)')),
                                      DropdownMenuItem(value: 'bluedart', child: Text('BlueDart Express')),
                                    ],
                                    onChanged: (newCourier) {
                                      if (newCourier != null) {
                                        final autoTrack = 'TRK-${newCourier.substring(0, 3).toUpperCase()}-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
                                        ref.read(orderRepositoryProvider).updateOrderFulfillment(
                                              orderId: order.id,
                                              status: order.fulfillmentStatus == 'placed' ? 'shipped' : order.fulfillmentStatus,
                                              courier: newCourier,
                                              trackingNumber: autoTrack,
                                            );
                                        ref.invalidate(allAdminOrdersFutureProvider);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('Assigned $newCourier ($autoTrack) to ${order.orderNumber}')),
                                        );
                                      }
                                    },
                                  ),
                                ],
                              ),

                              if (order.trackingNumber != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.info.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: SelectableText(
                                    'AWB: ${order.trackingNumber}',
                                    style: const TextStyle(fontSize: 11, fontFamily: 'monospace', fontWeight: FontWeight.bold, color: AppColors.info),
                                  ),
                                ),

                              const Spacer(),

                              // Action: Print Invoice
                              OutlinedButton.icon(
                                onPressed: () => _showInvoiceDialog(context, order),
                                icon: const Icon(Icons.print_outlined, size: 16),
                                label: const Text('Invoice & Packing Slip', style: TextStyle(fontSize: 11)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Text('Error loading orders: $err'),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'placed':
        return AppColors.info;
      case 'confirmed':
        return AppColors.forestSage;
      case 'processing':
        return AppColors.goldAccent;
      case 'shipped':
        return AppColors.info;
      case 'delivered':
        return AppColors.success;
      case 'cancelled':
        return AppColors.error;
      default:
        return AppColors.forestSage;
    }
  }

  void _showInvoiceDialog(BuildContext context, OrderModel order) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('TAX INVOICE • ${order.orderNumber}', style: const TextStyle(fontFamily: 'serif', fontSize: 16, fontWeight: FontWeight.bold)),
              IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.of(context).pop()),
            ],
          ),
          content: SizedBox(
            width: 500,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: Text(
                      'COSMYRA VAIDYAM BOTANICALS PVT LTD',
                      style: TextStyle(fontFamily: 'serif', fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.forestSageDark),
                    ),
                  ),
                  const Center(child: Text('GSTIN: 27AABCV1234F1Z0 • FSSAI: 10020022001144', style: TextStyle(fontSize: 10))),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Billed To:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                          Text(order.customerName, style: const TextStyle(fontSize: 12)),
                          Text(order.customerEmail, style: const TextStyle(fontSize: 11)),
                          Text(order.customerPhone, style: const TextStyle(fontSize: 11)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('Invoice Date: ${order.createdAt.year}-${order.createdAt.month}-${order.createdAt.day}', style: const TextStyle(fontSize: 11)),
                          Text('Payment Mode: ${order.paymentMethod.toUpperCase()}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          Text('Courier: ${(order.courierPartner ?? "Shiprocket").toUpperCase()}', style: const TextStyle(fontSize: 11)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Table(
                    border: TableBorder.all(color: AppColors.creamBorder),
                    children: [
                      const TableRow(
                        decoration: BoxDecoration(color: Color(0xFFF5F2EC)),
                        children: [
                          Padding(padding: EdgeInsets.all(8), child: Text('Item Formulation', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                          Padding(padding: EdgeInsets.all(8), child: Text('Qty', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                          Padding(padding: EdgeInsets.all(8), child: Text('Amount (INR)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                        ],
                      ),
                      ...order.items.map(
                        (i) => TableRow(
                          children: [
                            Padding(padding: const EdgeInsets.all(8), child: Text('${i.productName} (${i.variantName})', style: const TextStyle(fontSize: 11))),
                            Padding(padding: const EdgeInsets.all(8), child: Text('${i.quantity}', style: const TextStyle(fontSize: 11))),
                            Padding(padding: const EdgeInsets.all(8), child: Text('₹${(i.unitPrice * i.quantity).toInt()}', style: const TextStyle(fontSize: 11))),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('Subtotal: ₹${order.totalAmount.toInt()}', style: const TextStyle(fontSize: 12)),
                          const Text('GST (18% Included): Included', style: TextStyle(fontSize: 11, color: AppColors.textDarkSecondary)),
                          const SizedBox(height: 4),
                          Text(
                            'Grand Total: ₹${order.totalAmount.toInt()}',
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.forestSageDark),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Packing Slip & Invoice sent to print queue!')),
                );
              },
              icon: const Icon(Icons.print, size: 16),
              label: const Text('Print Packing Slip'),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.forestSage, foregroundColor: AppColors.softWhite),
            ),
          ],
        );
      },
    );
  }
}
