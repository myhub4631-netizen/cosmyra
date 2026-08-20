-- ==============================================================================
-- MIGRATION: Add Product Versioning & Canonical Media Fields
-- Date: August 21, 2026
-- ==============================================================================

-- 1. Add versioning columns to public.products
ALTER TABLE public.products 
ADD COLUMN IF NOT EXISTS media_version INT NOT NULL DEFAULT 1,
ADD COLUMN IF NOT EXISTS product_version INT NOT NULL DEFAULT 1,
ADD COLUMN IF NOT EXISTS media_updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now());

-- 2. Add versioning and ordering columns to public.product_images
ALTER TABLE public.product_images
ADD COLUMN IF NOT EXISTS version INT NOT NULL DEFAULT 1,
ADD COLUMN IF NOT EXISTS sort_order INT NOT NULL DEFAULT 0;

-- Index for fast lookup by product and order
CREATE INDEX IF NOT EXISTS idx_images_product_order ON public.product_images(product_id, display_order);
