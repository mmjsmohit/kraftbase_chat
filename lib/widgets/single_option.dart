import 'package:flutter/material.dart';
import 'package:flutx/flutx.dart';
import 'package:kraftbase_chat/views/chat_contact_screen.dart';

class SingleOption extends StatelessWidget {
  final String title;
  final BuildContext context;
  final Widget navigation;
  final IconData icon;
  const SingleOption({
    super.key,
    required this.title,
    required this.context,
    required this.icon,
    required this.navigation,
  });

  @override
  Widget build(BuildContext context) {
    return singleOption(
        title: title, context: context, navigation: navigation, icon: icon);
  }

  Widget singleOption(
      {IconData? icon,
      required String title,
      Widget? navigation,
      required BuildContext context}) {
    return InkWell(
      onTap: () {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => navigation!));
      },
      child: Container(
        width: 120,
        decoration: BoxDecoration(
            color: theme.colorScheme.onPrimary.withAlpha(90),
            borderRadius: const BorderRadius.all(Radius.circular(8))),
        padding: FxSpacing.fromLTRB(16, 16, 0, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(4)),
                  color: theme.colorScheme.onPrimary),
              padding: FxSpacing.all(2),
              child: Icon(
                icon,
                size: 18,
                color: theme.colorScheme.primary,
              ),
            ),
            Container(
              margin: FxSpacing.top(8),
              child:
                  FxText.titleSmall(title, color: theme.colorScheme.onPrimary),
            )
          ],
        ),
      ),
    );
  }
}
