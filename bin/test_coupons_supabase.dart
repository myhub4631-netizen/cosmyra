import 'package:supabase/supabase.dart';

void main() async {
  final supabase = SupabaseClient(
    'https://tkwxkmmxweqrfdttkjfd.supabase.co',
    'sb_publishable_8qq6FNGeCch_xx3kWM9wcw_jmoleoON',
  );

  try {
    final res = await supabase.from('coupons').select();
    print('Current coupons in DB (${res.length}):');
    for (var row in res) {
      print(row);
    }
  } catch (e) {
    print('Error: $e');
  }
}
