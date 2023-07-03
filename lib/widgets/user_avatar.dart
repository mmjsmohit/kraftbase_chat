import 'package:flutter/material.dart';

class UserAvatar extends StatelessWidget {
  final String userId;
  const UserAvatar({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      child: Text(userId.substring(0, 2)),
    );
  }
}
