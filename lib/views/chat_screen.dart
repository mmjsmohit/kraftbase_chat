import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutx/flutx.dart';
import 'package:kraftbase_chat/models/profile_model.dart';
import 'package:kraftbase_chat/theme/app_theme.dart';
import 'package:kraftbase_chat/views/chat_audio_screen.dart';
import 'package:kraftbase_chat/views/chat_video_screen.dart';
import 'package:kraftbase_chat/widgets/user_avatar.dart';
import 'package:kraftbase_chat/cubit/chat/chat_cubit.dart';

import 'package:kraftbase_chat/models/message_model.dart';
import 'package:kraftbase_chat/constants/constants.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:timeago/timeago.dart';

/// Screen to chat with someone.
///
/// Displays chat bubbles as a ListView and TextField to enter new chat.
class ChatScreen extends StatelessWidget {
  static Profile? profile;
  static String? roomToken;
  const ChatScreen({Key? key}) : super(key: key);

  static Route<void> route(String roomId, Profile user) {
    profile = user;
    roomToken = roomId;
    return MaterialPageRoute(
      builder: (context) => BlocProvider<ChatCubit>(
        create: (context) => ChatCubit()..setMessagesListener(roomId),
        child: const ChatScreen(),
      ),
    );
  }

  void _submitCallAlert(String type, BuildContext context) async {
    final text =
        "A $type call has been initiated! Please press the $type call button to join.";
    if (text.isEmpty) {
      return;
    }
    BlocProvider.of<ChatCubit>(context).sendMessage('tag: alert:$text');

    BlocProvider.of<ChatCubit>(context).sendMessage(text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 230, 238, 250),
      body: BlocConsumer<ChatCubit, ChatState>(
        listener: (context, state) {
          if (state is ChatError) {
            context.showErrorSnackBar(message: state.message);
          }
        },
        builder: (context, state) {
          if (state is ChatInitial) {
            return preloader;
          } else if (state is ChatLoaded) {
            final messages = state.messages;
            return SafeArea(
              child: Column(
                children: [
                  // appBarWidget(context),
                  FxContainer(
                    padding: FxSpacing.all(16),
                    color: AppTheme.theme.backgroundColor.withAlpha(60),
                    child: Row(
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Icon(
                            MdiIcons.chevronLeft,
                            color: theme.colorScheme.onBackground,
                          ),
                        ),
                        Container(
                          margin: FxSpacing.left(8),
                          child: ClipRRect(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(16)),
                            child: CircleAvatar(
                              radius: 16,
                              child: Text(profile!.username.substring(0, 2)),
                            ),
                          ),
                        ),
                        Container(
                          margin: FxSpacing.left(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              FxText.bodyLarge(profile!.username,
                                  color: theme.colorScheme.onBackground,
                                  fontWeight: 600),
                              FxText.bodySmall("Online",
                                  color: theme.colorScheme.onBackground,
                                  muted: true,
                                  fontWeight: 600),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Container(
                            alignment: Alignment.centerRight,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                InkWell(
                                  onTap: () {
                                    _submitCallAlert('Voice', context);
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const ChatAudioScreen()));
                                  },
                                  child: Container(
                                    padding: FxSpacing.all(4),
                                    child: Icon(
                                      MdiIcons.phoneOutline,
                                      color: theme.colorScheme.onBackground,
                                      size: 18,
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    _submitCallAlert('Video', context);
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const ChatVideoScreen()));
                                  },
                                  child: Container(
                                    margin: FxSpacing.left(8),
                                    padding: FxSpacing.all(4),
                                    child: Icon(
                                      MdiIcons.videoOutline,
                                      color: theme.colorScheme.onBackground,
                                      size: 22,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),

                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      reverse: true,
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final message = messages[index];
                        return _ChatBubble(message: message);
                      },
                    ),
                  ),
                  _MessageBar(),
                ],
              ),
            );
          } else if (state is ChatEmpty) {
            return Column(
              children: [
                const Expanded(
                  child: Center(
                    child: Text('Start your conversation now :)'),
                  ),
                ),
                _MessageBar(),
              ],
            );
          } else if (state is ChatError) {
            return Center(child: Text(state.message));
          }
          throw UnimplementedError();
        },
      ),
    );
  }
}

/// Set of widget that contains TextField and Button to submit message
class _MessageBar extends StatefulWidget {
  final TextEditingController _textController = TextEditingController();
  _MessageBar({
    Key? key,
  }) : super(key: key);

  @override
  State<_MessageBar> createState() => _MessageBarState();
}

class _MessageBarState extends State<_MessageBar> {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).cardColor,
      child: Padding(
        padding: EdgeInsets.only(
          top: 8,
          left: 8,
          right: 8,
          bottom: MediaQuery.of(context).padding.bottom,
        ),
        child: Row(
          children: [
            Expanded(
              child: TextFormField(
                keyboardType: TextInputType.text,
                maxLines: null,
                autofocus: true,
                controller: widget._textController,
                decoration: const InputDecoration(
                  hintText: 'Type a message',
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.all(8),
                ),
              ),
            ),
            IconButton(
              onPressed: () => _submitMessage(),
              icon: Icon(MdiIcons.send),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    widget._textController.dispose();
    super.dispose();
  }

  void _submitMessage() async {
    final text = widget._textController.text;
    if (text.isEmpty) {
      return;
    }
    BlocProvider.of<ChatCubit>(context).sendMessage(text);
    widget._textController.clear();
  }
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({
    Key? key,
    required this.message,
  }) : super(key: key);

  final Message message;

  @override
  Widget build(BuildContext context) {
    List<Widget> chatContents = [
      if (!message.isMine) UserAvatar(userId: message.profileId),
      const SizedBox(width: 12),
      Flexible(
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: 8,
            horizontal: 12,
          ),
          decoration: BoxDecoration(
            color: message.isMine
                ? const Color.fromARGB(255, 87, 144, 223)
                : Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: MarkdownBody(data: message.content),
        ),
      ),
      const SizedBox(width: 12),
      MarkdownBody(
        data: format(message.createdAt, locale: 'en_short'),
      ),
      const SizedBox(width: 60),
    ];
    if (message.isMine) {
      chatContents = chatContents.reversed.toList();
    }
    if (message.content.contains('tag: alert')) {
      return Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.greenAccent.withAlpha(80)),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 18),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: message.content.contains('Voice')
                  ? Expanded(
                      child: IconButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const ChatAudioScreen()));
                        },
                        icon: Icon(MdiIcons.phone),
                      ),
                    )
                  : Expanded(
                      child: IconButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const ChatVideoScreen()));
                        },
                        icon: Icon(MdiIcons.video),
                      ),
                    ),
            ),
            Text(
                message.content.contains('Voice') ? 'Voice Call' : 'Video Call')
          ],
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 18),
      child: Row(
        mainAxisAlignment:
            message.isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: chatContents,
      ),
    );
  }
}
