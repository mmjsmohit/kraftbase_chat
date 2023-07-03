import 'dart:async';

import 'package:agora_uikit/agora_uikit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kraftbase_chat/cubit/chat/chat_cubit.dart';
import 'package:kraftbase_chat/theme/app_theme.dart';
import 'package:kraftbase_chat/utils/generator.dart';
import 'package:flutter/material.dart';
import 'package:flutx/flutx.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class ChatVideoScreen extends StatefulWidget {
  const ChatVideoScreen({super.key});

  @override
  _ChatVideoScreenState createState() => _ChatVideoScreenState();
}

class _ChatVideoScreenState extends State<ChatVideoScreen> {
  late CustomTheme customTheme;
  late ThemeData theme;
  late Timer _timer;
  int _nowTime = 0;
  String timeText = "00 : 00";

  bool isAudioOn = false, isVideoOn = true;
  final AgoraClient _client = AgoraClient(
      agoraConnectionData: AgoraConnectionData(
          appId: '76477fd643ec4e2f88fcbe7d60a5fa4b',
          channelName: 'test',
          tempToken:
              "007eJxTYPi88fdioalqXxtef0n51X/qTV7iL32+o/aT3ix7oH/vKLOvAoO5mYm5eVqKmYlxarJJqlGahUVaclKqeYqZQaJpWqJJkvPRhSkNgYwMmT4ezIwMEAjiszCUpBaXMDAAAJitI1M="));

  @override
  void initState() {
    super.initState();
    startTimer();
    _initAgora();
    customTheme = AppTheme.customTheme;
    theme = AppTheme.theme;
  }

  Future<void> _initAgora() async {
    await _client.initialize();
  }

  void startTimer() {
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(
      oneSec,
      (Timer timer) => setState(
        () {
          _nowTime = _nowTime + 1;
          timeText = Generator.getTextFromSeconds(time: _nowTime);
        },
      ),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  _submitMessage() async {
    BlocProvider.of<ChatCubit>(context).sendMessage('Video call ($timeText)');
    print('Video call duration logged!');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: <Widget>[
        // Image(
        //   image: AssetImage('./assets/images/apps/chat/video-bg-1.jpg'),
        //   fit: BoxFit.cover,
        //   height: MediaQuery.of(context).size.height,
        //   width: MediaQuery.of(context).size.width,
        // ),
        AgoraVideoViewer(client: _client),
        AgoraVideoButtons(
          client: _client,
          onDisconnect: () {
            _submitMessage();
            Navigator.pop(context);
          },
        ),
        Positioned(
          top: 48,
          left: 24,
          child: InkWell(
            onTap: () {
              _submitMessage();
              _client.engine.leaveChannel();
              Navigator.pop(context);
            },
            child: Container(
              padding: FxSpacing.all(8),
              decoration: BoxDecoration(
                  color: customTheme.card.withAlpha(120),
                  borderRadius: const BorderRadius.all(
                    Radius.circular(8),
                  ),
                  border: Border.all(width: 1, color: customTheme.card)),
              child: Icon(
                MdiIcons.chevronLeft,
                color: theme.colorScheme.onBackground,
              ),
            ),
          ),
        ),
        // Positioned(
        //   top: 48,
        //   right: 24,
        //   child: secondCall(),
        // ),
        Positioned(
          top: 25,
          // left: 0,
          right: 0,
          child: Container(
            margin: FxSpacing.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                timeWidget(),
                // bottomWidget(),
              ],
            ),
          ),
        )
      ],
    ));
  }

  Widget bottomWidget() {
    return Center(
      child: Container(
        padding: FxSpacing.all(12),
        decoration: BoxDecoration(
          color: customTheme.card.withAlpha(236),
          borderRadius: const BorderRadius.all(Radius.circular(64)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              margin: FxSpacing.bottom(8),
              padding: FxSpacing.all(10),
              decoration: BoxDecoration(
                  color: customTheme.card,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                        color: customTheme.shadowColor,
                        blurRadius: 6,
                        spreadRadius: 1,
                        offset: const Offset(0, 2))
                  ]),
              child: InkWell(
                onTap: () {
                  setState(() {
                    isAudioOn = !isAudioOn;
                  });
                },
                child: Icon(
                  isAudioOn
                      ? MdiIcons.microphoneOutline
                      : MdiIcons.microphoneOff,
                  size: 26,
                  color: theme.colorScheme.onBackground,
                ),
              ),
            ),
            Container(
              padding: FxSpacing.all(10),
              margin: FxSpacing.vertical(8),
              decoration: BoxDecoration(
                  color: customTheme.card,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                        color: customTheme.shadowColor,
                        blurRadius: 6,
                        spreadRadius: 1,
                        offset: const Offset(0, 2))
                  ]),
              child: InkWell(
                onTap: () {
                  setState(() {
                    isVideoOn = !isVideoOn;
                  });
                },
                child: Icon(
                  isVideoOn ? MdiIcons.videoOutline : MdiIcons.videoOffOutline,
                  color: theme.colorScheme.onBackground,
                  size: 26,
                ),
              ),
            ),
            Container(
              padding: FxSpacing.all(10),
              margin: FxSpacing.top(8),
              decoration: BoxDecoration(
                  color: customTheme.colorError,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                        color: customTheme.colorError.withAlpha(100),
                        blurRadius: 6,
                        spreadRadius: 1,
                        offset: const Offset(0, 2))
                  ]),
              child: InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Icon(
                  MdiIcons.phoneHangupOutline,
                  color: customTheme.onError,
                  size: 26,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget timeWidget() {
    return Container(
      padding: FxSpacing.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
          color: Colors.black.withAlpha(70),
          borderRadius: const BorderRadius.all(Radius.circular(32))),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
                color: customTheme.colorSuccess, shape: BoxShape.circle),
          ),
          Container(
            margin: FxSpacing.left(12),
            child: FxText.bodyMedium(timeText,
                color: Colors.white, letterSpacing: 0.4, fontWeight: 600),
          ),
        ],
      ),
    );
  }
}
