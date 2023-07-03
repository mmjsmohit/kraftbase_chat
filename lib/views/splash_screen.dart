import 'package:flutter/material.dart';
import 'package:kraftbase_chat/constants/constants.dart';
import 'package:kraftbase_chat/views/auth/register.dart';
import 'package:kraftbase_chat/views/chat_rooms_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Screen to redirect users to the appropriate page depending on the initial auth state
class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    getInitialSession();
    super.initState();
  }

  Future<void> getInitialSession() async {
    // quick and dirty way to wait for the widget to mount
    await Future.delayed(Duration.zero);

    try {
      final session = await SupabaseAuth.instance.initialSession;
      if (session == null) {
        Navigator.of(context)
            .pushAndRemoveUntil(RegisterScreen.route(), (_) => false);
      } else {
        Navigator.of(context)
            .pushAndRemoveUntil(RoomsScreen.route(), (_) => false);
      }
    } catch (_) {
      context.showErrorSnackBar(
        message: 'Error occured during session refresh',
      );
      Navigator.of(context)
          .pushAndRemoveUntil(RegisterScreen.route(), (_) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
