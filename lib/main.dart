import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kraftbase_chat/cubit/profiles/profiles_cubit.dart';
import 'package:kraftbase_chat/theme/app_notifier.dart';
import 'package:kraftbase_chat/theme/app_theme.dart';
import 'package:kraftbase_chat/views/splash_screen.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const supabaseUrl = 'https://saouxgpzmqjlbpitsipz.supabase.co';
const supabaseKey =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNhb3V4Z3B6bXFqbGJwaXRzaXB6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE2ODc5NDU2NzYsImV4cCI6MjAwMzUyMTY3Nn0.RfzEUsIq8HyefvFniHG5wlfh2L5uXVQQ_gattZEO4HE';

Future<void> main() async {
  //You will need to initialize AppThemeNotifier class for theme changes.
  WidgetsFlutterBinding.ensureInitialized();

  AppTheme.init();
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseKey);
  runApp(ChangeNotifierProvider<AppNotifier>(
    create: (context) => AppNotifier(),
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProfilesCubit>(
      create: (context) => ProfilesCubit(),
      child: MaterialApp(
        title: 'Flutter Demo',
        home: const SplashScreen(),
        theme: AppTheme.theme,
      ),
    );
  }
}
