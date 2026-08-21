-- Migration: Fix All RLS Policies and Storage Bucket Permissions for Cosmyra
-- Copy & paste this entire script into your Supabase Dashboard SQL Editor and click 'Run':
-- https://supabase.com/dashboard/project/tkwxkmmxweqrfdttkjfd/sql/new

-- 1. Enable Full Access on 'products' table
ALTER TABLE public.products ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Products viewable by everyone" ON public.products;
DROP POLICY IF EXISTS "Products editable by admin" ON public.products;
DROP POLICY IF EXISTS "Enable full access for products" ON public.products;
CREATE POLICY "Enable full access for products" ON public.products FOR ALL USING (true) WITH CHECK (true);

-- 2. Enable Full Access on 'product_variants' table
ALTER TABLE public.product_variants ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Variants viewable by everyone" ON public.product_variants;
DROP POLICY IF EXISTS "Variants editable by admin" ON public.product_variants;
DROP POLICY IF EXISTS "Enable full access for product_variants" ON public.product_variants;
CREATE POLICY "Enable full access for product_variants" ON public.product_variants FOR ALL USING (true) WITH CHECK (true);

-- 3. Enable Full Access on 'product_images' table
ALTER TABLE public.product_images ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Images viewable by everyone" ON public.product_images;
DROP POLICY IF EXISTS "Images editable by admin" ON public.product_images;
DROP POLICY IF EXISTS "Enable full access for product_images" ON public.product_images;
CREATE POLICY "Enable full access for product_images" ON public.product_images FOR ALL USING (true) WITH CHECK (true);

-- 4. Enable Public Read & Upload Access on 'product-images' Storage Bucket
INSERT INTO storage.buckets (id, name, public) 
VALUES ('product-images', 'product-images', true)
ON CONFLICT (id) DO UPDATE SET public = true;

DROP POLICY IF EXISTS "Public read access for product-images" ON storage.objects;
CREATE POLICY "Public read access for product-images" ON storage.objects
FOR SELECT USING (bucket_id = 'product-images');

DROP POLICY IF EXISTS "Public insert access for product-images" ON storage.objects;
CREATE POLICY "Public insert access for product-images" ON storage.objects
FOR INSERT WITH CHECK (bucket_id = 'product-images');

DROP POLICY IF EXISTS "Public update access for product-images" ON storage.objects;
CREATE POLICY "Public update access for product-images" ON storage.objects
FOR UPDATE USING (bucket_id = 'product-images');

DROP POLICY IF EXISTS "Public delete access for product-images" ON storage.objects;
CREATE POLICY "Public delete access for product-images" ON storage.objects
FOR DELETE USING (bucket_id = 'product-images');
