-- Migration: Fix RLS Policies for Product Management
-- Grants full insert/update/delete access on products, product_variants, and product_images tables

ALTER TABLE public.products ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Products viewable by everyone" ON public.products;
DROP POLICY IF EXISTS "Products editable by admin" ON public.products;
DROP POLICY IF EXISTS "Enable full access for products" ON public.products;
CREATE POLICY "Enable full access for products" ON public.products FOR ALL USING (true) WITH CHECK (true);

ALTER TABLE public.product_variants ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Variants viewable by everyone" ON public.product_variants;
DROP POLICY IF EXISTS "Variants editable by admin" ON public.product_variants;
DROP POLICY IF EXISTS "Enable full access for product_variants" ON public.product_variants;
CREATE POLICY "Enable full access for product_variants" ON public.product_variants FOR ALL USING (true) WITH CHECK (true);

ALTER TABLE public.product_images ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Images viewable by everyone" ON public.product_images;
DROP POLICY IF EXISTS "Images editable by admin" ON public.product_images;
DROP POLICY IF EXISTS "Enable full access for product_images" ON public.product_images;
CREATE POLICY "Enable full access for product_images" ON public.product_images FOR ALL USING (true) WITH CHECK (true);
