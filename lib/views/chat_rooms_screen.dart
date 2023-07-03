import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutx/flutx.dart';
import 'package:kraftbase_chat/cubit/rooms/rooms_cubit.dart';
import 'package:kraftbase_chat/cubit/profiles/profiles_cubit.dart';

import 'package:kraftbase_chat/models/profile_model.dart';
import 'package:kraftbase_chat/theme/app_theme.dart';
import 'package:kraftbase_chat/constants/constants.dart';
import 'package:kraftbase_chat/views/chat_profile_screen.dart';
import 'package:kraftbase_chat/views/chat_screen.dart';
import 'package:kraftbase_chat/widgets/single_option.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:timeago/timeago.dart';

/// Displays the list of chat threads
class RoomsScreen extends StatefulWidget {
  const RoomsScreen({Key? key}) : super(key: key);

  static Route<void> route() {
    return MaterialPageRoute(
      builder: (context) => BlocProvider<RoomCubit>(
        create: (context) => RoomCubit()..initializeRooms(context),
        child: const RoomsScreen(),
      ),
    );
  }

  @override
  State<RoomsScreen> createState() => _RoomsScreenState();
}

class _RoomsScreenState extends State<RoomsScreen> {
  late CustomTheme customTheme;
  late ThemeData theme;

  @override
  void initState() {
    super.initState();
    customTheme = AppTheme.customTheme;
    theme = AppTheme.theme;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<RoomCubit, RoomState>(
        builder: (context, state) {
          if (state is RoomsLoading) {
            return preloader;
          } else if (state is RoomsLoaded) {
            final newUsers = state.newUsers;
            final rooms = state.rooms;
            return BlocBuilder<ProfilesCubit, ProfilesState>(
              builder: (context, state) {
                if (state is ProfilesLoaded) {
                  final profiles = state.profiles;
                  return Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                            color: AppTheme.theme.colorScheme.primary,
                            borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(8),
                                bottomRight: Radius.circular(8))),
                        padding: FxSpacing.fromLTRB(0, 42, 0, 64),
                        child: ListView(
                          shrinkWrap: true,
                          physics: const ClampingScrollPhysics(),
                          children: <Widget>[
                            Container(
                              margin: FxSpacing.fromLTRB(32, 0, 0, 32),
                              child: FxText.headlineSmall("Chats",
                                  color: theme.colorScheme.onPrimary,
                                  fontWeight: 700),
                            ),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: <Widget>[
                                  Container(
                                    margin: FxSpacing.horizontal(20),
                                    child: SingleOption(
                                      title: "Account",
                                      navigation: ChatProfileScreen(),
                                      icon: MdiIcons.accountOutline,
                                      context: context,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                          width: double.infinity,
                          child: Center(child: _NewUsers(newUsers: newUsers))),
                      Expanded(
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
                          itemCount: rooms.length,
                          itemBuilder: (context, index) {
                            final room = rooms[index];
                            final otherUser = profiles[room.otherUserId];

                            return Column(
                              children: [
                                const Divider(
                                  height: 0,
                                ),
                                ListTile(
                                  onTap: () => Navigator.of(context).push(
                                      ChatScreen.route(room.id, otherUser!)),
                                  leading: CircleAvatar(
                                    child: otherUser == null
                                        ? preloader
                                        : Text(
                                            otherUser.username.substring(0, 2)),
                                  ),
                                  title: Text(otherUser == null
                                      ? 'Loading...'
                                      : otherUser.username),
                                  subtitle: room.lastMessage != null
                                      ? Text(
                                          room.lastMessage!.content,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        )
                                      : const Text('Room created'),
                                  trailing: Text(format(
                                      room.lastMessage?.createdAt ??
                                          room.createdAt,
                                      locale: 'en_short')),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  );
                } else {
                  return preloader;
                }
              },
            );
          } else if (state is RoomsEmpty) {
            final newUsers = state.newUsers;
            return Column(
              children: [
                _NewUsers(newUsers: newUsers),
                const Expanded(
                  child: Center(
                    child: Text('Start a chat by tapping on available users'),
                  ),
                ),
              ],
            );
          } else if (state is RoomsError) {
            return Center(child: Text(state.message));
          }
          throw UnimplementedError();
        },
      ),
    );
  }
}

class _NewUsers extends StatelessWidget {
  const _NewUsers({
    Key? key,
    required this.newUsers,
  }) : super(key: key);

  final List<Profile> newUsers;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      scrollDirection: Axis.horizontal,
      child: Row(
        children: newUsers
            .map<Widget>((user) => InkWell(
                  onTap: () async {
                    try {
                      final roomId = await BlocProvider.of<RoomCubit>(context)
                          .createRoom(user.id);
                      Navigator.of(context)
                          .push(ChatScreen.route(roomId, user));
                    } catch (_) {
                      context.showErrorSnackBar(
                          message: 'Failed creating a new room');
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                      width: 60,
                      child: Column(
                        children: [
                          CircleAvatar(
                            child: Text(user.username.substring(0, 2)),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            user.username,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }
}
