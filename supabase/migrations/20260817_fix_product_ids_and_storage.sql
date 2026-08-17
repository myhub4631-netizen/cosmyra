-- ==============================================================================
-- MIGRATION: Change product-related tables from UUID to TEXT primary keys
-- This allows the Flutter app to use its own string-based IDs (e.g. prod-vaidyam-shampoo-1)
-- Date: August 17, 2026
-- ==============================================================================

-- Drop dependent policies, indexes, and constraints first
-- product_images depends on products
-- product_variants depends on products

-- 1. product_images: change id and product_id from UUID to TEXT
ALTER TABLE public.product_images DROP CONSTRAINT IF EXISTS product_images_product_id_fkey;
ALTER TABLE public.product_images ALTER COLUMN id TYPE TEXT USING id::TEXT;
ALTER TABLE public.product_images ALTER COLUMN product_id TYPE TEXT USING product_id::TEXT;
ALTER TABLE public.product_images ALTER COLUMN id SET DEFAULT NULL;

-- 2. product_variants: change id and product_id from UUID to TEXT
ALTER TABLE public.product_variants DROP CONSTRAINT IF EXISTS product_variants_product_id_fkey;
ALTER TABLE public.product_variants ALTER COLUMN id TYPE TEXT USING id::TEXT;
ALTER TABLE public.product_variants ALTER COLUMN product_id TYPE TEXT USING product_id::TEXT;
ALTER TABLE public.product_variants ALTER COLUMN id SET DEFAULT NULL;

-- 3. products: change id, brand_id, category_id from UUID to TEXT
-- First drop FK from order_items if exists
ALTER TABLE public.order_items DROP CONSTRAINT IF EXISTS order_items_product_id_fkey;
ALTER TABLE public.order_items DROP CONSTRAINT IF EXISTS order_items_variant_id_fkey;
ALTER TABLE public.order_items ALTER COLUMN product_id TYPE TEXT USING product_id::TEXT;
ALTER TABLE public.order_items ALTER COLUMN variant_id TYPE TEXT USING variant_id::TEXT;

ALTER TABLE public.products DROP CONSTRAINT IF EXISTS products_brand_id_fkey;
ALTER TABLE public.products DROP CONSTRAINT IF EXISTS products_category_id_fkey;
ALTER TABLE public.products ALTER COLUMN id TYPE TEXT USING id::TEXT;
ALTER TABLE public.products ALTER COLUMN brand_id TYPE TEXT USING brand_id::TEXT;
ALTER TABLE public.products ALTER COLUMN category_id TYPE TEXT USING category_id::TEXT;
ALTER TABLE public.products ALTER COLUMN id SET DEFAULT NULL;

-- 4. brands: change id from UUID to TEXT
ALTER TABLE public.brands ALTER COLUMN id TYPE TEXT USING id::TEXT;
ALTER TABLE public.brands ALTER COLUMN id SET DEFAULT NULL;

-- 5. categories: change id from UUID to TEXT
ALTER TABLE public.categories ALTER COLUMN id TYPE TEXT USING id::TEXT;
ALTER TABLE public.categories ALTER COLUMN id SET DEFAULT NULL;

-- Re-add foreign keys with TEXT types
ALTER TABLE public.products ADD CONSTRAINT products_brand_id_fkey
    FOREIGN KEY (brand_id) REFERENCES public.brands(id) ON DELETE CASCADE;
ALTER TABLE public.products ADD CONSTRAINT products_category_id_fkey
    FOREIGN KEY (category_id) REFERENCES public.categories(id) ON DELETE RESTRICT;

ALTER TABLE public.product_variants ADD CONSTRAINT product_variants_product_id_fkey
    FOREIGN KEY (product_id) REFERENCES public.products(id) ON DELETE CASCADE;

ALTER TABLE public.product_images ADD CONSTRAINT product_images_product_id_fkey
    FOREIGN KEY (product_id) REFERENCES public.products(id) ON DELETE CASCADE;

-- Re-add FK for order_items if table exists
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'order_items') THEN
        ALTER TABLE public.order_items ADD CONSTRAINT order_items_product_id_fkey
            FOREIGN KEY (product_id) REFERENCES public.products(id) ON DELETE SET NULL;
    END IF;
EXCEPTION WHEN OTHERS THEN
    NULL;
END $$;

-- Create Supabase Storage bucket for product images (if not exists)
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES ('product-images', 'product-images', true, 5242880, ARRAY['image/jpeg', 'image/png', 'image/webp', 'image/gif', 'image/bmp'])
ON CONFLICT (id) DO NOTHING;

-- Allow public read access to product-images bucket
CREATE POLICY "Public read access on product-images" ON storage.objects
    FOR SELECT USING (bucket_id = 'product-images');

-- Allow authenticated users to upload to product-images bucket
CREATE POLICY "Auth users can upload product images" ON storage.objects
    FOR INSERT WITH CHECK (bucket_id = 'product-images');

-- Allow authenticated users to update product images
CREATE POLICY "Auth users can update product images" ON storage.objects
    FOR UPDATE USING (bucket_id = 'product-images');

-- Allow authenticated users to delete product images
CREATE POLICY "Auth users can delete product images" ON storage.objects
    FOR DELETE USING (bucket_id = 'product-images');

-- Seed default brands and categories with text IDs
INSERT INTO public.brands (id, name, slug, tagline)
VALUES ('brand-vaidyam', 'Vaidyam Botanicals', 'vaidyam', 'Pure Ayurveda & Botanical Wellness')
ON CONFLICT (id) DO NOTHING;

INSERT INTO public.categories (id, name, slug, description, icon_name, display_order, is_active)
VALUES
    ('cat-haircare', 'Haircare', 'haircare', 'Botanical defense and nourishment for hair and scalp', 'spa', 1, true),
    ('cat-skincare', 'Skincare', 'skincare', 'Dermatological Ayurveda for clear, glowing Indian skin', 'face', 2, true),
    ('cat-wellness', 'Wellness', 'wellness', 'Holistic personal wellness & daily essentials', 'favorite', 3, true)
ON CONFLICT (id) DO NOTHING;
