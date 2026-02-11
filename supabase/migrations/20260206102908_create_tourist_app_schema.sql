/*
  # Create Tourist Attraction App Schema

  1. New Tables
    - `places`
      - `id` (uuid, primary key)
      - `name` (text) - Name of the tourist attraction
      - `name_en` (text) - English name
      - `description` (text) - Description of the place
      - `description_en` (text) - English description
      - `image_url` (text) - Main image URL
      - `images` (jsonb) - Array of additional image URLs
      - `opening_hours` (jsonb) - Opening hours by day
      - `is_open` (boolean) - Current open/closed status
      - `location` (text) - Location description
      - `map_link` (text) - Google Maps link
      - `keywords` (text[]) - Search keywords
      - `is_recommended` (boolean) - Show in recommended section
      - `category` (text) - Category: 'all', 'nature', 'cafe'
      - `created_at` (timestamptz)
      - `updated_at` (timestamptz)
    
    - `bookmarks`
      - `id` (uuid, primary key)
      - `user_id` (uuid, references auth.users)
      - `place_id` (uuid, references places)
      - `created_at` (timestamptz)
      - Unique constraint on (user_id, place_id)
    
    - `slider_images`
      - `id` (uuid, primary key)
      - `image_url` (text) - Image URL
      - `title` (text) - Optional title
      - `order_index` (integer) - Display order
      - `is_active` (boolean) - Whether to show this image
      - `created_at` (timestamptz)
    
    - `admin_settings`
      - `id` (uuid, primary key)
      - `key` (text, unique) - Setting key
      - `value` (jsonb) - Setting value
      - `updated_at` (timestamptz)

  2. Security
    - Enable RLS on all tables
    - Add policies for authenticated users to read places
    - Add policies for users to manage their own bookmarks
    - Add policies for admin operations
*/

-- Create places table
CREATE TABLE IF NOT EXISTS places (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  name_en text,
  description text,
  description_en text,
  image_url text,
  images jsonb DEFAULT '[]'::jsonb,
  opening_hours jsonb DEFAULT '{}'::jsonb,
  is_open boolean DEFAULT true,
  location text,
  map_link text,
  keywords text[] DEFAULT ARRAY[]::text[],
  is_recommended boolean DEFAULT false,
  category text NOT NULL DEFAULT 'all',
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Create bookmarks table
CREATE TABLE IF NOT EXISTS bookmarks (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  place_id uuid NOT NULL REFERENCES places(id) ON DELETE CASCADE,
  created_at timestamptz DEFAULT now(),
  UNIQUE(user_id, place_id)
);

-- Create slider_images table
CREATE TABLE IF NOT EXISTS slider_images (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  image_url text NOT NULL,
  title text,
  order_index integer NOT NULL DEFAULT 0,
  is_active boolean DEFAULT true,
  created_at timestamptz DEFAULT now()
);

-- Create admin_settings table
CREATE TABLE IF NOT EXISTS admin_settings (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  key text UNIQUE NOT NULL,
  value jsonb DEFAULT '{}'::jsonb,
  updated_at timestamptz DEFAULT now()
);

-- Enable RLS
ALTER TABLE places ENABLE ROW LEVEL SECURITY;
ALTER TABLE bookmarks ENABLE ROW LEVEL SECURITY;
ALTER TABLE slider_images ENABLE ROW LEVEL SECURITY;
ALTER TABLE admin_settings ENABLE ROW LEVEL SECURITY;

-- Places policies - everyone can read
CREATE POLICY "Anyone can view places"
  ON places FOR SELECT
  TO public
  USING (true);

CREATE POLICY "Authenticated users can insert places"
  ON places FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "Authenticated users can update places"
  ON places FOR UPDATE
  TO authenticated
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Authenticated users can delete places"
  ON places FOR DELETE
  TO authenticated
  USING (true);

-- Bookmarks policies
CREATE POLICY "Users can view own bookmarks"
  ON bookmarks FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Users can create own bookmarks"
  ON bookmarks FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own bookmarks"
  ON bookmarks FOR DELETE
  TO authenticated
  USING (auth.uid() = user_id);

-- Slider images policies - everyone can read
CREATE POLICY "Anyone can view active slider images"
  ON slider_images FOR SELECT
  TO public
  USING (is_active = true);

CREATE POLICY "Authenticated users can insert slider images"
  ON slider_images FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "Authenticated users can update slider images"
  ON slider_images FOR UPDATE
  TO authenticated
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Authenticated users can delete slider images"
  ON slider_images FOR DELETE
  TO authenticated
  USING (true);

-- Admin settings policies
CREATE POLICY "Anyone can view settings"
  ON admin_settings FOR SELECT
  TO public
  USING (true);

CREATE POLICY "Authenticated users can insert settings"
  ON admin_settings FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "Authenticated users can update settings"
  ON admin_settings FOR UPDATE
  TO authenticated
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Authenticated users can delete settings"
  ON admin_settings FOR DELETE
  TO authenticated
  USING (true);

-- Insert default slider settings
INSERT INTO admin_settings (key, value)
VALUES 
  ('slider_auto_play', '{"enabled": true, "interval": 5000}'::jsonb),
  ('slider_show_arrows', '{"enabled": true}'::jsonb)
ON CONFLICT (key) DO NOTHING;

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_places_category ON places(category);
CREATE INDEX IF NOT EXISTS idx_places_recommended ON places(is_recommended);
CREATE INDEX IF NOT EXISTS idx_bookmarks_user ON bookmarks(user_id);
CREATE INDEX IF NOT EXISTS idx_bookmarks_place ON bookmarks(place_id);
CREATE INDEX IF NOT EXISTS idx_slider_order ON slider_images(order_index);
