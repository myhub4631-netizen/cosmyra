-- ==============================================================================
-- COSMYRA COSMETICS D2C PLATFORM - INITIAL DATABASE SCHEMA & SEED DATA
-- Version: 1.0.0
-- Date: August 14, 2026
-- Postgres Best Practices & RLS Enabled
-- ==============================================================================

-- Enable UUID Extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ------------------------------------------------------------------------------
-- 1. PROFILES & ROLES
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT NOT NULL,
    full_name TEXT,
    phone TEXT,
    role TEXT NOT NULL DEFAULT 'customer' CHECK (role IN ('customer', 'admin', 'staff')),
    avatar_url TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Public profiles are viewable by everyone" 
ON public.profiles FOR SELECT USING (true);

CREATE POLICY "Users can update their own profile" 
ON public.profiles FOR UPDATE USING (auth.uid() = id);

-- ------------------------------------------------------------------------------
-- 2. BRANDS & CATEGORIES (Cosmyra-Owned Brands Only)
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.brands (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL UNIQUE,
    slug TEXT NOT NULL UNIQUE,
    tagline TEXT,
    description TEXT,
    logo_url TEXT,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

ALTER TABLE public.brands ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Brands are viewable by everyone" ON public.brands FOR SELECT USING (true);
CREATE POLICY "Brands editable by admin only" ON public.brands FOR ALL USING (
    EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role IN ('admin', 'staff'))
);

CREATE TABLE IF NOT EXISTS public.categories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL UNIQUE,
    slug TEXT NOT NULL UNIQUE,
    description TEXT,
    icon_name TEXT,
    display_order INT DEFAULT 0,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

ALTER TABLE public.categories ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Categories are viewable by everyone" ON public.categories FOR SELECT USING (true);
CREATE POLICY "Categories editable by admin only" ON public.categories FOR ALL USING (
    EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role IN ('admin', 'staff'))
);

-- ------------------------------------------------------------------------------
-- 3. PRODUCTS & VARIANTS
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.products (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    brand_id UUID NOT NULL REFERENCES public.brands(id) ON DELETE CASCADE,
    category_id UUID NOT NULL REFERENCES public.categories(id) ON DELETE RESTRICT,
    name TEXT NOT NULL,
    slug TEXT NOT NULL UNIQUE,
    tagline TEXT,
    description TEXT NOT NULL,
    ingredients TEXT NOT NULL,
    how_to_use TEXT,
    free_from_claims JSONB DEFAULT '[]'::jsonb,
    certifications JSONB DEFAULT '[]'::jsonb,
    is_featured BOOLEAN DEFAULT false,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

CREATE INDEX IF NOT EXISTS idx_products_brand_id ON public.products(brand_id);
CREATE INDEX IF NOT EXISTS idx_products_category_id ON public.products(category_id);
CREATE INDEX IF NOT EXISTS idx_products_is_active ON public.products(is_active);

ALTER TABLE public.products ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Products are viewable by everyone" ON public.products FOR SELECT USING (is_active = true OR EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role IN ('admin', 'staff')));
CREATE POLICY "Products editable by admin only" ON public.products FOR ALL USING (
    EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role IN ('admin', 'staff'))
);

CREATE TABLE IF NOT EXISTS public.product_variants (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    product_id UUID NOT NULL REFERENCES public.products(id) ON DELETE CASCADE,
    sku TEXT NOT NULL UNIQUE,
    size_label TEXT NOT NULL, -- e.g. '200 ml', '125 g', '100 ml'
    price_inr NUMERIC(10, 2) NOT NULL,
    mrp_inr NUMERIC(10, 2) NOT NULL,
    stock_quantity INT NOT NULL DEFAULT 0,
    is_default BOOLEAN NOT NULL DEFAULT false,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

CREATE INDEX IF NOT EXISTS idx_variants_product_id ON public.product_variants(product_id);
ALTER TABLE public.product_variants ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Variants viewable by everyone" ON public.product_variants FOR SELECT USING (true);
CREATE POLICY "Variants editable by admin" ON public.product_variants FOR ALL USING (
    EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role IN ('admin', 'staff'))
);

CREATE TABLE IF NOT EXISTS public.product_images (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    product_id UUID NOT NULL REFERENCES public.products(id) ON DELETE CASCADE,
    image_url TEXT NOT NULL,
    alt_text TEXT,
    display_order INT DEFAULT 0,
    is_primary BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

CREATE INDEX IF NOT EXISTS idx_images_product_id ON public.product_images(product_id);
ALTER TABLE public.product_images ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Images viewable by everyone" ON public.product_images FOR SELECT USING (true);
CREATE POLICY "Images editable by admin" ON public.product_images FOR ALL USING (
    EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role IN ('admin', 'staff'))
);

-- ------------------------------------------------------------------------------
-- 4. ADDRESSES & GUEST SESSIONS
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.addresses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    recipient_name TEXT NOT NULL,
    phone TEXT NOT NULL,
    email TEXT,
    address_line1 TEXT NOT NULL,
    address_line2 TEXT,
    landmark TEXT,
    city TEXT NOT NULL,
    state TEXT NOT NULL,
    pincode TEXT NOT NULL,
    is_default BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

CREATE INDEX IF NOT EXISTS idx_addresses_user_id ON public.addresses(user_id);
ALTER TABLE public.addresses ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can manage their addresses" ON public.addresses FOR ALL USING (
    auth.uid() = user_id OR user_id IS NULL
);

-- ------------------------------------------------------------------------------
-- 5. ORDERS & ORDER ITEMS (Guest & Authenticated)
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.orders (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_number TEXT NOT NULL UNIQUE,
    user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    is_guest BOOLEAN NOT NULL DEFAULT false,
    customer_name TEXT NOT NULL,
    customer_email TEXT NOT NULL,
    customer_phone TEXT NOT NULL,
    shipping_address JSONB NOT NULL,
    subtotal_inr NUMERIC(10, 2) NOT NULL,
    discount_inr NUMERIC(10, 2) DEFAULT 0,
    shipping_fee_inr NUMERIC(10, 2) DEFAULT 0,
    total_amount_inr NUMERIC(10, 2) NOT NULL,
    payment_method TEXT NOT NULL CHECK (payment_method IN ('razorpay', 'cod')),
    payment_status TEXT NOT NULL DEFAULT 'pending' CHECK (payment_status IN ('pending', 'captured', 'failed', 'refunded')),
    razorpay_order_id TEXT,
    razorpay_payment_id TEXT,
    fulfillment_status TEXT NOT NULL DEFAULT 'placed' CHECK (fulfillment_status IN ('placed', 'confirmed', 'processing', 'shipped', 'delivered', 'cancelled', 'returned')),
    courier_partner TEXT CHECK (courier_partner IN ('shiprocket', 'delhivery', 'indiapost', 'other')),
    tracking_number TEXT,
    tracking_url TEXT,
    notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

CREATE INDEX IF NOT EXISTS idx_orders_user_id ON public.orders(user_id);
CREATE INDEX IF NOT EXISTS idx_orders_customer_email ON public.orders(customer_email);
CREATE INDEX IF NOT EXISTS idx_orders_fulfillment_status ON public.orders(fulfillment_status);

ALTER TABLE public.orders ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users view own orders or guest with email" ON public.orders FOR SELECT USING (
    auth.uid() = user_id OR EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role IN ('admin', 'staff'))
);
CREATE POLICY "Anyone can create orders" ON public.orders FOR INSERT WITH CHECK (true);
CREATE POLICY "Admins can update orders" ON public.orders FOR UPDATE USING (
    EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role IN ('admin', 'staff'))
);

CREATE TABLE IF NOT EXISTS public.order_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id UUID NOT NULL REFERENCES public.orders(id) ON DELETE CASCADE,
    product_variant_id UUID NOT NULL REFERENCES public.product_variants(id) ON DELETE RESTRICT,
    product_name TEXT NOT NULL,
    variant_name TEXT NOT NULL,
    unit_price_inr NUMERIC(10, 2) NOT NULL,
    quantity INT NOT NULL CHECK (quantity > 0),
    total_price_inr NUMERIC(10, 2) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

CREATE INDEX IF NOT EXISTS idx_order_items_order_id ON public.order_items(order_id);
ALTER TABLE public.order_items ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users view own order items" ON public.order_items FOR SELECT USING (
    EXISTS (
        SELECT 1 FROM public.orders o 
        WHERE o.id = public.order_items.order_id 
        AND (o.user_id = auth.uid() OR EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role IN ('admin', 'staff')))
    )
);
CREATE POLICY "Anyone can insert order items" ON public.order_items FOR INSERT WITH CHECK (true);

-- ------------------------------------------------------------------------------
-- 6. SUBSCRIBE & SAVE
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.subscriptions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    product_variant_id UUID NOT NULL REFERENCES public.product_variants(id) ON DELETE RESTRICT,
    address_id UUID REFERENCES public.addresses(id) ON DELETE SET NULL,
    frequency_days INT NOT NULL DEFAULT 30 CHECK (frequency_days IN (15, 30, 45, 60)),
    discount_percentage INT NOT NULL DEFAULT 10,
    status TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'paused', 'cancelled')),
    next_renewal_date DATE NOT NULL,
    payment_method TEXT NOT NULL DEFAULT 'cod' CHECK (payment_method IN ('razorpay', 'cod')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

CREATE INDEX IF NOT EXISTS idx_subscriptions_user_id ON public.subscriptions(user_id);
ALTER TABLE public.subscriptions ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can manage their subscriptions" ON public.subscriptions FOR ALL USING (
    auth.uid() = user_id OR EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role IN ('admin', 'staff'))
);

-- ------------------------------------------------------------------------------
-- 7. REVIEWS & RATINGS
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.reviews (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    product_id UUID NOT NULL REFERENCES public.products(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    rating INT NOT NULL CHECK (rating >= 1 AND rating <= 5),
    title TEXT,
    review_text TEXT,
    verified_purchase BOOLEAN DEFAULT false,
    is_approved BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

CREATE INDEX IF NOT EXISTS idx_reviews_product_id ON public.reviews(product_id);
ALTER TABLE public.reviews ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Approved reviews viewable by everyone" ON public.reviews FOR SELECT USING (is_approved = true);
CREATE POLICY "Users can create reviews" ON public.reviews FOR INSERT WITH CHECK (auth.uid() = user_id);

-- ------------------------------------------------------------------------------
-- 8. COUPONS
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.coupons (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    code TEXT NOT NULL UNIQUE,
    discount_type TEXT NOT NULL CHECK (discount_type IN ('percentage', 'fixed')),
    discount_value NUMERIC(10, 2) NOT NULL,
    min_order_value_inr NUMERIC(10, 2) DEFAULT 0,
    max_discount_inr NUMERIC(10, 2),
    valid_from TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    valid_until TIMESTAMPTZ NOT NULL,
    usage_limit INT,
    used_count INT DEFAULT 0,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

ALTER TABLE public.coupons ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Active coupons viewable by authenticated users" ON public.coupons FOR SELECT USING (is_active = true);
CREATE POLICY "Coupons editable by admin" ON public.coupons FOR ALL USING (
    EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role IN ('admin', 'staff'))
);

-- ------------------------------------------------------------------------------
-- 9. SEED DATA (Vaidyam Initial SKUs & Cosmyra Setup)
-- ------------------------------------------------------------------------------
DO $$
DECLARE
    v_brand_id UUID;
    v_cat_hair UUID;
    v_cat_skin UUID;
    v_cat_well UUID;
    v_shampoo_id UUID;
    v_soap_id UUID;
    v_facewash_id UUID;
BEGIN
    -- 1. Insert Brand: Vaidyam
    INSERT INTO public.brands (name, slug, tagline, description)
    VALUES (
        'Vaidyam',
        'vaidyam',
        'Pure Botanical Science for Hair & Skin',
        'Vaidyam blends authentic Ayurvedic botanicals with clean dermatology to deliver high-performance, non-toxic personal care.'
    )
    ON CONFLICT (slug) DO UPDATE SET name = EXCLUDED.name
    RETURNING id INTO v_brand_id;

    -- 2. Insert Categories
    INSERT INTO public.categories (name, slug, description, icon_name, display_order)
    VALUES 
        ('Haircare', 'haircare', 'Ayurvedic formulations for healthy scalp and strong hair', 'spa', 1),
        ('Skincare', 'skincare', 'Clean, potent skincare for radiant Indian skin', 'face', 2),
        ('Wellness', 'wellness', 'Holistic personal wellness & body care', 'favorite', 3)
    ON CONFLICT (slug) DO NOTHING;

    SELECT id INTO v_cat_hair FROM public.categories WHERE slug = 'haircare';
    SELECT id INTO v_cat_skin FROM public.categories WHERE slug = 'skincare';
    SELECT id INTO v_cat_well FROM public.categories WHERE slug = 'wellness';

    -- 3. Insert Product 1: Anti-Dandruff Shampoo
    INSERT INTO public.products (
        brand_id, category_id, name, slug, tagline, description, 
        ingredients, how_to_use, free_from_claims, is_featured
    )
    VALUES (
        v_brand_id, v_cat_hair,
        'Vaidyam Anti-Dandruff Herbal Shampoo',
        'vaidyam-anti-dandruff-shampoo',
        'Clinically proven botanical defense against flakes & scalp itch',
        'Formulated with Tea Tree Oil, Neem extract, and Climbazole in a gentle, sulfate-free lather. Restores scalp microbiome balance while nourishing hair roots from within.',
        'Aqua, Tea Tree Leaf Oil, Azadirachta Indica (Neem) Leaf Extract, Climbazole, Aloe Barbadensis Leaf Juice, Decyl Glucoside, Sodium Cocoyl Isethionate, Glycerin, Hydrolyzed Wheat Protein, D-Panthenol, Phenoxyethanol.',
        'Apply to wet hair and gently massage into scalp for 2 minutes. Rinse thoroughly with water. Use 3 times weekly for best results.',
        '["Sulfate Free", "Paraben Free", "Silicon Free", "Mineral Oil Free", "Cruelty Free", "Artificial Dye Free"]'::jsonb,
        true
    )
    ON CONFLICT (slug) DO UPDATE SET name = EXCLUDED.name
    RETURNING id INTO v_shampoo_id;

    -- Variant for Shampoo
    INSERT INTO public.product_variants (product_id, sku, size_label, price_inr, mrp_inr, stock_quantity, is_default)
    VALUES (v_shampoo_id, 'VDY-SHM-200', '200 ml', 399.00, 499.00, 200, true)
    ON CONFLICT (sku) DO NOTHING;

    -- 4. Insert Product 2: De-Tan Herbal Soap
    INSERT INTO public.products (
        brand_id, category_id, name, slug, tagline, description, 
        ingredients, how_to_use, free_from_claims, is_featured
    )
    VALUES (
        v_brand_id, v_cat_skin,
        'Vaidyam De-Tan Botanical Handcrafted Soap',
        'vaidyam-de-tan-soap',
        'Enriched with Turmeric, Saffron & Sandalwood for bright, glowing skin',
        'Handcrafted cold-processed soap bar infused with raw Kashmiri Saffron and Wild Turmeric. Removes stubborn sun tan, pigmentation, and gently exfoliates dead skin cells.',
        'Cocos Nucifera (Coconut) Oil, Elaeis Guineensis (Palm) Oil, Curcuma Longa (Turmeric) Extract, Crocus Sativus (Saffron) Extract, Santalum Album (Sandalwood) Powder, Kojic Acid Dipalmitate, Vitamin E, Essential Oils.',
        'Lather between wet palms and apply all over body and face. Leave on for 60 seconds before rinsing off with cool water.',
        '["Paraben Free", "Cruelty Free", "100% Vegetarian", "Handcrafted", "No Animal Fats", "Grade 1 TFM 76%"]'::jsonb,
        true
    )
    ON CONFLICT (slug) DO UPDATE SET name = EXCLUDED.name
    RETURNING id INTO v_soap_id;

    -- Variant for Soap
    INSERT INTO public.product_variants (product_id, sku, size_label, price_inr, mrp_inr, stock_quantity, is_default)
    VALUES (v_soap_id, 'VDY-SOP-125', '125 g', 199.00, 249.00, 200, true)
    ON CONFLICT (sku) DO NOTHING;

    -- 5. Insert Product 3: Face Wash
    INSERT INTO public.products (
        brand_id, category_id, name, slug, tagline, description, 
        ingredients, how_to_use, free_from_claims, is_featured
    )
    VALUES (
        v_brand_id, v_cat_skin,
        'Vaidyam Deep Clean Clarifying Face Wash',
        'vaidyam-deep-clean-face-wash',
        'Salicylic acid & Green Tea extract for oil control & acne defense',
        'A gentle, pH-balanced foaming gel that deep-cleans pores without stripping natural hydration. Combines Green Tea and Niacinamide to calm redness and prevent breakouts.',
        'Aqua, Camellia Sinensis (Green Tea) Leaf Water, Salicylic Acid (2%), Niacinamide, Cocamidopropyl Betaine, Sodium Lauroyl Sarcosinate, Allantoin, Hyaluronic Acid, Melaleuca Alternifolia (Tea Tree) Extract.',
        'Pump a small amount onto damp palms. Work into a mild foam and massage over face in circular motions for 30 seconds. Rinse with lukewarm water.',
        '["Soap Free", "Alcohol Free", "Non-Comedogenic", "Fragrance Free", "Paraben Free", "Cruelty Free"]'::jsonb,
        true
    )
    ON CONFLICT (slug) DO UPDATE SET name = EXCLUDED.name
    RETURNING id INTO v_facewash_id;

    -- Variant for Face Wash
    INSERT INTO public.product_variants (product_id, sku, size_label, price_inr, mrp_inr, stock_quantity, is_default)
    VALUES (v_facewash_id, 'VDY-FCW-100', '100 ml', 299.00, 375.00, 200, true)
    ON CONFLICT (sku) DO NOTHING;

    -- 6. Insert Welcome Coupon
    INSERT INTO public.coupons (code, discount_type, discount_value, min_order_value_inr, valid_until)
    VALUES ('COSMYRA10', 'percentage', 10.00, 399.00, timezone('utc'::text, now() + interval '1 year'))
    ON CONFLICT (code) DO NOTHING;

END $$;
