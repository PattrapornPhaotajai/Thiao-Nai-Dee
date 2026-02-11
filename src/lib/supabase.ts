import { createClient } from '@supabase/supabase-js';

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL;
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY;

if (!supabaseUrl || !supabaseAnonKey) {
  throw new Error('Missing Supabase environment variables');
}

export const supabase = createClient(supabaseUrl, supabaseAnonKey);

export type Place = {
  id: string;
  name: string;
  name_en?: string;
  description?: string;
  description_en?: string;
  image_url?: string;
  images?: string[];
  opening_hours?: Record<string, string>;
  is_open: boolean;
  location?: string;
  map_link?: string;
  keywords?: string[];
  is_recommended: boolean;
  category: string;
  created_at: string;
  updated_at: string;
};

export type Bookmark = {
  id: string;
  user_id: string;
  place_id: string;
  created_at: string;
};

export type SliderImage = {
  id: string;
  image_url: string;
  title?: string;
  order_index: number;
  is_active: boolean;
  created_at: string;
};
