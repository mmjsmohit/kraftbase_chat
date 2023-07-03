import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static const supabaseUrl = 'https://saouxgpzmqjlbpitsipz.supabase.co';
  static const supabaseKey = String.fromEnvironment('SUPABASE_KEY');
  SupabaseClient supabaseClient = SupabaseClient(supabaseUrl, supabaseKey);
}
