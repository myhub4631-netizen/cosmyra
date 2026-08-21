import 'package:supabase/supabase.dart';

void main() async {
  final supabase = SupabaseClient(
    'https://tkwxkmmxweqrfdttkjfd.supabase.co',
    'sb_publishable_8qq6FNGeCch_xx3kWM9wcw_jmoleoON',
  );

  final String brandId = '6242b75a-f2b3-4895-8927-95ce0e24fa3c';
  final String catHair = 'e12a1332-bfcb-4179-bdf8-52ecb5d7ee54';
  final String catSkin = 'b481633d-9952-410e-90e9-f93cec2b5b9e';
  final String catWell = 'd8743d43-e440-4372-a0f4-68fa1cfe3651';

  final List<Map<String, dynamic>> products = [
    {
      'id': '00001724-2150-4000-a000-000000000001',
      'brand_id': brandId,
      'category_id': catHair,
      'name': 'Bhringraj & Neem Botanical Shampoo',
      'slug': 'bhringraj-neem-botanical-shampoo',
      'tagline': 'Deep Scalp Cleans & Hairfall Control',
      'description': 'Handcrafted Ayurvedic formulation infused with pure Bhringraj, Neem, and Amla extracts to strengthen roots and stop hair fall naturally.',
      'ingredients': 'Organic Bhringraj, Neem Leaf Extract, Amla, Reetha, Shikakai, Virgin Coconut Oil, Purified Aqua.',
      'how_to_use': 'Apply 5-10ml on wet scalp, massage gently into rich lather for 2 minutes and rinse thoroughly with lukewarm water.',
      'free_from_claims': ['Paraben Free', 'Sulfate Free', 'Cruelty Free', '100% Vegan'],
      'is_featured': true,
      'is_active': true,
      'variant': {
        'id': '00001724-2150-4000-b000-000000000001',
        'sku': 'VDY-SHMP-200',
        'size_label': '200 ml',
        'price_inr': 399.0,
        'mrp_inr': 549.0,
        'stock_quantity': 150,
      },
      'image_url': 'assets/images/shampoo.jpg',
    },
    {
      'id': '00001724-2150-4000-a000-000000000002',
      'brand_id': brandId,
      'category_id': catSkin,
      'name': 'Saffron & Kumkumadi Radiance Face Wash',
      'slug': 'saffron-kumkumadi-radiance-facewash',
      'tagline': 'Golden Glow & Dark Spot Reduction',
      'description': 'Enriched with Kashmiri Saffron and 26 herbal extracts for clear, even-toned, and radiant Indian skin.',
      'ingredients': 'Kashmiri Saffron (Kesar), Kumkumadi Tailam, Aloe Vera Gel, Manjistha, Sandalwood Extract, Lotus Water.',
      'how_to_use': 'Squeeze small amount onto palms. Work into mild lather and massage on damp face in circular motions.',
      'free_from_claims': ['Soap Free', 'Paraben Free', 'Synthetic Color Free', 'Dermatologically Tested'],
      'is_featured': true,
      'is_active': true,
      'variant': {
        'id': '00001724-2150-4000-b000-000000000002',
        'sku': 'VDY-FW-100',
        'size_label': '100 ml',
        'price_inr': 299.0,
        'mrp_inr': 399.0,
        'stock_quantity': 200,
      },
      'image_url': 'assets/images/facewash.jpg',
    },
    {
      'id': '00001724-2150-4000-a000-000000000003',
      'brand_id': brandId,
      'category_id': catSkin,
      'name': 'Cold-Pressed Herbal De-Tan Soap Bar',
      'slug': 'cold-pressed-herbal-detan-soap',
      'tagline': 'Exfoliating Neem & Turmeric Bar',
      'description': 'Traditional cold-processed soap made with raw coconut oil, wild turmeric, and neem for deep skin detoxification.',
      'ingredients': 'Cold-Pressed Coconut Oil, Wild Turmeric (Kasturi Manjal), Neem Leaves, Vetiver Root Oil, Pure Glycerin.',
      'how_to_use': 'Lather gently over wet body during shower. Leave on skin for 1 minute before rinsing clean.',
      'free_from_claims': ['Palm Oil Free', 'Chemical Free', '100% Handcrafted', 'Biodegradable'],
      'is_featured': true,
      'is_active': true,
      'variant': {
        'id': '00001724-2150-4000-b000-000000000003',
        'sku': 'VDY-SOAP-125',
        'size_label': '125 g',
        'price_inr': 199.0,
        'mrp_inr': 249.0,
        'stock_quantity': 300,
      },
      'image_url': 'assets/images/soap.jpg',
    },
    {
      'id': '00001724-2150-4000-a000-000000000004',
      'brand_id': brandId,
      'category_id': catSkin,
      'name': 'Kumkumadi Tailam & Saffron Night Serum',
      'slug': 'kumkumadi-tailam-saffron-night-serum',
      'tagline': '100% Pure Youth Elixir & Overnight Repair',
      'description': 'Precious Ayurvedic miracle elixir formulation distilled with saffron stigmas, goat milk, and 26 botanicals for ageless radiance.',
      'ingredients': 'Saffron (Kesar), Goat Milk, Sandalwood (Chandan), Vetiver, Licorice (Yasthimadhu), Manjistha, Sesame Oil.',
      'how_to_use': 'Apply 3-4 drops on cleansed face before bedtime. Gently press into face and neck using fingertips until absorbed.',
      'free_from_claims': ['100% Organic', 'Mineral Oil Free', 'No Artificial Fragrance', 'Cruelty Free'],
      'is_featured': true,
      'is_active': true,
      'variant': {
        'id': '00001724-2150-4000-b000-000000000004',
        'sku': 'VDY-SER-30',
        'size_label': '30 ml',
        'price_inr': 699.0,
        'mrp_inr': 899.0,
        'stock_quantity': 100,
      },
      'image_url': 'assets/images/facewash.jpg',
    },
    {
      'id': '00001724-2150-4000-a000-000000000005',
      'brand_id': brandId,
      'category_id': catWell,
      'name': 'Nalpamaradi Clarifying Body Thailam',
      'slug': 'nalpamaradi-clarifying-body-thailam',
      'tagline': 'Brightening & Anti-Pigmentation Oil',
      'description': 'Heritage Ayurvedic skin oil made with 4 Ficus barks and turmeric to clarify complexion, reduce tan, and restore natural glow.',
      'ingredients': 'Bark of 4 Ficus Trees (Nalpamara), Turmeric, Sesame Oil, Vetiver, Banyan Bark, Peepal Bark.',
      'how_to_use': 'Massage gently over body 30 minutes before bathing. Wash off with warm water and herbal soap.',
      'free_from_claims': ['100% Herbal', 'No Synthetic Colors', 'Ayurvedic Pharmacopoeia Grade'],
      'is_featured': false,
      'is_active': true,
      'variant': {
        'id': '00001724-2150-4000-b000-000000000005',
        'sku': 'VDY-OIL-200',
        'size_label': '200 ml',
        'price_inr': 499.0,
        'mrp_inr': 649.0,
        'stock_quantity': 120,
      },
      'image_url': 'assets/images/soap.jpg',
    },
    {
      'id': '00001724-2150-4000-a000-000000000006',
      'brand_id': brandId,
      'category_id': catWell,
      'name': 'Organic Aloe Vera & Neem Hydrating Gel',
      'slug': 'organic-aloe-vera-neem-hydrating-gel',
      'tagline': 'Cooling Hydration for Face & Hair',
      'description': '99% pure cold-pressed aloe vera gel with organic neem water for multi-purpose skin soothing, scalp hydration, and acne control.',
      'ingredients': 'Cold-Pressed Aloe Vera Leaf Juice, Organic Neem Water, Green Tea Extract, Natural Vegetable Glycerin.',
      'how_to_use': 'Apply directly onto face, scalp, or skin after sun exposure or daily cleansing for instant cooling hydration.',
      'free_from_claims': ['Alcohol Free', 'Silicone Free', 'Non-Sticky', '100% Pure Gel'],
      'is_featured': false,
      'is_active': true,
      'variant': {
        'id': '00001724-2150-4000-b000-000000000006',
        'sku': 'VDY-ALOE-150',
        'size_label': '150 g',
        'price_inr': 249.0,
        'mrp_inr': 349.0,
        'stock_quantity': 180,
      },
      'image_url': 'assets/images/shampoo.jpg',
    },
  ];

  for (final p in products) {
    print('Syncing product: ${p['name']}...');
    final pData = {
      'id': p['id'],
      'brand_id': p['brand_id'],
      'category_id': p['category_id'],
      'name': p['name'],
      'slug': p['slug'],
      'tagline': p['tagline'],
      'description': p['description'],
      'ingredients': p['ingredients'],
      'how_to_use': p['how_to_use'],
      'free_from_claims': p['free_from_claims'],
      'is_featured': p['is_featured'],
      'is_active': true,
    };
    await supabase.from('products').upsert(pData);

    final v = p['variant'] as Map<String, dynamic>;
    final vData = {
      'id': v['id'],
      'product_id': p['id'],
      'sku': v['sku'],
      'size_label': v['size_label'],
      'price_inr': v['price_inr'],
      'mrp_inr': v['mrp_inr'],
      'stock_quantity': v['stock_quantity'],
      'is_default': true,
      'is_active': true,
    };
    await supabase.from('product_variants').upsert(vData);

    final imgData = {
      'id': '00001724-2150-4000-c000-' + p['id'].toString().substring(24),
      'product_id': p['id'],
      'image_url': p['image_url'],
      'alt_text': p['name'],
      'display_order': 0,
      'is_primary': true,
    };
    await supabase.from('product_images').upsert(imgData);
  }

  print('Done seeding live Supabase catalog!');
}
