import 'dart:async';

import 'package:kraftbase_chat/theme/app_theme.dart';
import 'package:kraftbase_chat/utils/generator.dart';
import 'package:flutter/material.dart';
import 'package:flutx/flutx.dart';
import 'package:kraftbase_chat/utils/supabase_service.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';

class ChatAudioScreen extends StatefulWidget {
  const ChatAudioScreen({super.key});
  @override
  _ChatAudioScreenState createState() => _ChatAudioScreenState();
}

class _ChatAudioScreenState extends State<ChatAudioScreen> {
  late Timer _timer;
  int _nowTime = 0;
  String timeText = "00 : 00";
  static const String appId = "76477fd643ec4e2f88fcbe7d60a5fa4b";

  bool isAudioOn = false, isVideoOn = true;
  late CustomTheme customTheme;
  late ThemeData theme;
  String token =
      "007eJxTYPi88fdioalqXxtef0n51X/qTV7iL32+o/aT3ix7oH/vKLOvAoO5mYm5eVqKmYlxarJJqlGahUVaclKqeYqZQaJpWqJJkvPRhSkNgYwMmT4ezIwMEAjiszCUpBaXMDAAAJitI1M=";

  int uid = 0; // uid of the local user

  int? _remoteUid; // uid of the remote user
  bool _isJoined = false; // Indicates if the local user has joined the channel
  late RtcEngine agoraEngine; // Agora engine instance

  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>(); // Global key to access the scaffold

  @override
  void initState() {
    super.initState();
    customTheme = AppTheme.customTheme;
    theme = AppTheme.theme;
    setupVoiceSDKEngine();
    startTimer();
  }

  @override
  void dispose() async {
    super.dispose();
    await agoraEngine.leaveChannel();
    _timer.cancel();
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

  showMessage(String message) {
    scaffoldMessengerKey.currentState?.showSnackBar(SnackBar(
      content: Text(message),
    ));
  }

  void join() async {
    // Set channel options including the client role and channel profile
    ChannelMediaOptions options = const ChannelMediaOptions(
      clientRoleType: ClientRoleType.clientRoleBroadcaster,
      channelProfile: ChannelProfileType.channelProfileCommunication,
    );

    await agoraEngine.joinChannel(
      token: token,
      channelId: 'test',
      options: options,
      uid: uid,
    );
  }

  void leave() {
    setState(() {
      _isJoined = false;
      _remoteUid = null;
    });
    agoraEngine.leaveChannel();
  }

  Future<void> setupVoiceSDKEngine() async {
    // retrieve or request microphone permission
    await [Permission.microphone].request();

    //create an instance of the Agora engine
    agoraEngine = createAgoraRtcEngine();
    await agoraEngine.initialize(const RtcEngineContext(appId: appId));

    // Register the event handler
    agoraEngine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          showMessage(
              "Local user uid:${connection.localUid} joined the channel");
          setState(() {
            _isJoined = true;
          });
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          showMessage("Remote user uid:$remoteUid joined the channel");
          setState(() {
            _remoteUid = remoteUid;
          });
        },
        onUserOffline: (RtcConnection connection, int remoteUid,
            UserOfflineReasonType reason) {
          showMessage("Remote user uid:$remoteUid left the channel");
          setState(() {
            _remoteUid = null;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    join();
    return Scaffold(
        body: Container(
      padding: FxSpacing.top(FxSpacing.safeAreaTop(context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            child: topWidget(),
          ),
          Expanded(child: Placeholder()),
          Container(
            child: bottomWidget(),
          )
        ],
      ),
    ));
  }
  // Build UI
  // @override
  // Widget build(BuildContext context) {
  //   return MaterialApp(
  //     scaffoldMessengerKey: scaffoldMessengerKey,
  //     home: Scaffold(
  //         appBar: AppBar(
  //           title: const Text('Get started with Voice Calling'),
  //         ),
  //         body: ListView(
  //           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
  //           children: [
  //             // Status text
  //             SizedBox(height: 40, child: Center(child: _status())),
  //             // Button Row
  //             Row(
  //               children: <Widget>[
  //                 Expanded(
  //                   child: ElevatedButton(
  //                     child: const Text("Join"),
  //                     onPressed: () => {join()},
  //                   ),
  //                 ),
  //                 const SizedBox(width: 10),
  //                 Expanded(
  //                   child: ElevatedButton(
  //                     child: const Text("Leave"),
  //                     onPressed: () => {leave()},
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ],
  //         )),
  //   );
  // }

  Widget _status() {
    String statusText;

    if (!_isJoined) {
      statusText = 'Join a channel';
    } else if (_remoteUid == null) {
      statusText = 'Waiting for a remote user to join...';
    } else {
      statusText = 'Connected to remote user, uid:$_remoteUid';
    }

    return Text(
      statusText,
    );
  }

  Widget singleCall(
      {required String name,
      required String image,
      bool micOn = false,
      bool cameraOn = false}) {
    return FxContainer.bordered(
      width: (MediaQuery.of(context).size.width - 74) / 2,
      height: 180,
      color: Colors.transparent,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(34)),
            child: Image(
              image: AssetImage(image),
              height: 68,
              width: 68,
              fit: BoxFit.cover,
            ),
          ),
          Container(
            margin: FxSpacing.top(8),
            child: FxText(
              name,
            ),
          ),
          Container(
            margin: FxSpacing.top(8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  micOn ? MdiIcons.microphoneOutline : MdiIcons.microphoneOff,
                  color: micOn
                      ? theme.colorScheme.onBackground
                      : theme.colorScheme.onBackground.withAlpha(180),
                  size: 22,
                ),
                Container(
                  margin: FxSpacing.left(8),
                  child: Icon(
                      cameraOn
                          ? MdiIcons.videoOutline
                          : MdiIcons.videoOffOutline,
                      color: cameraOn
                          ? theme.colorScheme.onBackground
                          : theme.colorScheme.onBackground.withAlpha(180),
                      size: 22),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget topWidget() {
    return FxContainer(
      height: 60,
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(16),
        bottomRight: Radius.circular(16),
      ),
      border: Border.all(width: 1, color: customTheme.border),
      padding: FxSpacing.fromLTRB(24, 0, 24, 0),
      child: Row(
        children: [
          InkWell(
            onTap: () async {
              leave();
              uploadDuration(timeText).then((result) {
                Navigator.pop(context);
              });
            },
            child: Icon(
              MdiIcons.chevronLeft,
              size: 24,
              color: theme.colorScheme.onBackground,
            ),
          ),
          Expanded(
            child: Container(
              margin: FxSpacing.left(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  FxText.titleSmall("Group Call",
                      color: theme.colorScheme.onBackground, fontWeight: 600),
                  FxText.bodySmall(timeText,
                      color: theme.colorScheme.onBackground)
                ],
              ),
            ),
          ),
          Icon(
            MdiIcons.accountPlusOutline,
            color: theme.colorScheme.onBackground,
            size: 22,
          )
        ],
      ),
    );
  }

  Widget bottomWidget() {
    return FxContainer(
      height: 72,
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(16),
        topRight: Radius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          InkWell(
            onTap: () {
              setState(() {
                isAudioOn = !isAudioOn;
              });
              if (isAudioOn) {}
            },
            child: Container(
              padding: FxSpacing.all(8),
              decoration: BoxDecoration(
                  color:
                      theme.colorScheme.primary.withAlpha(isAudioOn ? 40 : 0),
                  shape: BoxShape.circle),
              child: Center(
                child: Icon(
                  isAudioOn
                      ? MdiIcons.microphoneOutline
                      : MdiIcons.microphoneOff,
                  color: isAudioOn
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onBackground.withAlpha(200),
                ),
              ),
            ),
          ),
          InkWell(
            onTap: () {
              leave();
              Navigator.pop(context);
            },
            child: Container(
              padding: FxSpacing.all(8),
              decoration: BoxDecoration(
                  color: customTheme.colorError, shape: BoxShape.circle),
              child: Center(
                child: Icon(
                  MdiIcons.phoneHangupOutline,
                  color: customTheme.onError,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> uploadDuration(String timeText) async {
    var supabase = SupabaseService();
    String id = supabase.supabaseClient.auth.currentUser!.id;
    await SupabaseService().supabaseClient.from('messages').insert({
      'profile_id': id,
      'content': "Video Call duration: *$timeText*",
      'room_id': 'sample'
    });
    print('ho gaya');
  }
}
