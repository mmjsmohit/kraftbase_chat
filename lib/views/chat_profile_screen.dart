import 'package:kraftbase_chat/constants/constants.dart';
import 'package:kraftbase_chat/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutx/flutx.dart';
import 'package:kraftbase_chat/utils/supabase_service.dart';
import 'package:kraftbase_chat/views/auth/register.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatProfileScreen extends StatefulWidget {
  @override
  _ChatProfileScreenState createState() => _ChatProfileScreenState();
}

class _ChatProfileScreenState extends State<ChatProfileScreen> {
  late CustomTheme customTheme;
  late ThemeData theme;
  late SupabaseService supabaseService;

  @override
  void initState() {
    super.initState();
    customTheme = AppTheme.customTheme;
    theme = AppTheme.theme;
    supabaseService = SupabaseService();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          leading: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: Icon(
              MdiIcons.chevronLeft,
              size: 20,
              color: theme.colorScheme.onBackground,
            ),
          ),
          title: FxText.bodyLarge("Account",
              color: theme.colorScheme.onBackground, fontWeight: 600),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: FxSpacing.fromLTRB(20, 20, 20, 0),
              child: FxText.bodySmall("SETTINGS",
                  fontWeight: 600,
                  letterSpacing: 0.4,
                  color: theme.colorScheme.onBackground),
            ),
            Container(
              margin: FxSpacing.fromLTRB(20, 20, 20, 0),
              child: FutureBuilder(
                future: getId(),
                builder: (context, snapshot) {
                  return Row(
                    children: [
                      Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                ClipRRect(
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(26)),
                                    child: CircleAvatar(
                                      radius: 26,
                                      child: Text((snapshot.data as String)
                                          .substring(0, 2)),
                                    )),
                                Container(
                                  margin: FxSpacing.left(20),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      FxText.bodyMedium(snapshot.data as String,
                                          color: theme.colorScheme.onBackground,
                                          fontWeight: 500),
                                      FxText.bodyMedium(
                                          "I'm using Kraftbase_chat",
                                          color: theme.colorScheme.onBackground,
                                          fontWeight: 500),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                      )
                    ],
                  );
                },
              ),
            ),
            Container(
              margin: FxSpacing.fromLTRB(20, 20, 20, 0),
              child: Column(
                children: [
                  ListTile(
                    onTap: () async {
                      await supabase.auth.signOut();
                      Navigator.of(context).pushAndRemoveUntil(
                        RegisterScreen.route(),
                        (route) => false,
                      );
                    },
                    leading: Icon(
                      MdiIcons.logoutVariant,
                      color: theme.colorScheme.onBackground,
                    ),
                    title: FxText.titleSmall("Logout",
                        fontWeight: 600,
                        letterSpacing: 0,
                        color: theme.colorScheme.onBackground),
                  ),
                ],
              ),
            )
          ],
        ));
  }

  Widget singleRequest(
      {required String image,
      required String name,
      required String status,
      required String option}) {
    return Container(
      decoration: BoxDecoration(
          border: Border.all(color: customTheme.border, width: 1),
          borderRadius: const BorderRadius.all(Radius.circular(4))),
      padding: FxSpacing.all(20),
      child: Column(
        children: [
          ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(26)),
              child: Image(
                image: AssetImage(image),
                height: 52,
                width: 52,
              )),
          Container(
            margin: FxSpacing.top(8),
            child: FxText.bodyMedium(name,
                color: theme.colorScheme.onBackground, fontWeight: 600),
          ),
          FxText.bodySmall(status,
              color: theme.colorScheme.onBackground,
              fontWeight: 500,
              muted: true),
          Container(
            padding: FxSpacing.fromLTRB(10, 6, 10, 6),
            margin: FxSpacing.top(8),
            decoration: BoxDecoration(
                border: Border.all(color: customTheme.border, width: 1),
                borderRadius: const BorderRadius.all(Radius.circular(20))),
            child: FxText.bodyMedium(option,
                color: theme.colorScheme.onBackground, fontWeight: 500),
          )
        ],
      ),
    );
  }

  getId() async {
    final User? user = supabase.auth.currentUser;
    return user!.userMetadata!['username'];
  }
}
