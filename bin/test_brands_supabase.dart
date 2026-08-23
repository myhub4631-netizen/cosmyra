import 'package:supabase/supabase.dart';

void main() async {
  final supabase = SupabaseClient(
    'https://tkwxkmmxweqrfdttkjfd.supabase.co',
    'sb_publishable_8qq6FNGeCch_xx3kWM9wcw_jmoleoON',
  );

  try {
    final response = await supabase
        .from('brands')
        .update({'description': 'Vaidyam Authentic Ayurvedic Botanicals & Science.'})
        .eq('id', '6242b75a-f2b3-4895-8927-95ce0e24fa3c')
        .select();

    print('Brand update result: $response');
  } catch (e) {
    print('Error: $e');
  }
}
