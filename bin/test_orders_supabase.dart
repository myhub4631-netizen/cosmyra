import 'package:postgrest/postgrest.dart';
import '../lib/config/supabase_config.dart';

void main() async {
  print('Testing Postgrest orders table...');
  try {
    final client = PostgrestClient(
      '${SupabaseConfig.url}/rest/v1',
      headers: {
        'apikey': SupabaseConfig.anonKey,
        'Authorization': 'Bearer ${SupabaseConfig.anonKey}',
      },
    );

    final res = await client.from('orders').select('*, order_items(*)');
    print('Current orders count in Supabase: ${(res as List).length}');
    for (var o in res) {
      print('Order ${o['order_number']}: Total ₹${o['total_amount_inr']}, User: ${o['user_id']}, Name: ${o['customer_name']}');
    }
  } catch (e, stack) {
    print('Supabase orders fetch error: $e');
    print(stack);
  }
}
