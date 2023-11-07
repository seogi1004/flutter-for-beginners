import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:video_call/const/agora.dart';

class CamScreen extends StatefulWidget {
  const CamScreen({super.key});

  @override
  State<CamScreen> createState() => _CamScreenState();
}

class _CamScreenState extends State<CamScreen> {
  RtcEngine? engine;
  int? uid;
  int? otherUid;

  Future<bool> init() async {
    final resp = await [Permission.camera, Permission.microphone].request();
    final cameraPermission = resp[Permission.camera];
    final micPermission = resp[Permission.microphone];

    if (cameraPermission != PermissionStatus.granted ||
        micPermission != PermissionStatus.granted) {
      throw '카메라 또는 마이크 권한이 없습니다.';
    }

    if (engine == null) {
      engine = createAgoraRtcEngine();

      await engine!.initialize(
        const RtcEngineContext(
          appId: APP_ID,
          channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
        ),
      );

      engine!.registerEventHandler(
        RtcEngineEventHandler(
          onJoinChannelSuccess: (connection, elapsed) {
            print("채널에 입장했습니다. uid : ${connection.localUid}");
            setState(() {
              uid = connection.localUid;
            });
          },
          onLeaveChannel: (connection, stats) {
            print("채널 퇴장");
            setState(() {
              uid = null;
            });
          },
          onUserJoined: (connection, remoteUid, elapsed) {
            print("상대가 채널에 입장했습니다. uid : $remoteUid");
            setState(() {
              otherUid = remoteUid;
            });
          },
          onUserOffline: (connection, remoteUid, reason) {
            print("상대가 채널에서 나갔습니다. uid : $uid");
            setState(() {
              otherUid = null;
            });
          },
        ),
      );

      await engine!.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
      await engine!.enableAudio();
      await engine!.joinChannel(
        token: TEMP_TOKEN,
        channelId: CHANNER_NAME,
        uid: 0,
        options: const ChannelMediaOptions(),
      );
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LIVE'),
      ),
      body: FutureBuilder(
        future: init(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(snapshot.error.toString()),
            );
          }

          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Stack(
                  children: [
                    renderMainView(),
                    Align(
                      alignment: Alignment.topLeft,
                      child: Container(
                        color: Colors.grey,
                        height: 160,
                        width: 120,
                        child: renderSubView(),
                      ),
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: ElevatedButton(
                  onPressed: () async {
                    if (engine != null) {
                      await engine!.leaveChannel();
                    }

                    Navigator.of(context).pop();
                  },
                  child: const Text('채널 나가기'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget renderSubView() {
    if (uid != null) {
      return AgoraVideoView(
        controller: VideoViewController(
          rtcEngine: engine!,
          canvas: const VideoCanvas(uid: 0),
        ),
      );
    } else {
      return const CircularProgressIndicator();
    }
  }

  Widget renderMainView() {
    if (otherUid != null) {
      return AgoraVideoView(
        controller: VideoViewController.remote(
          rtcEngine: engine!,
          canvas: VideoCanvas(uid: otherUid),
          connection: const RtcConnection(channelId: CHANNER_NAME),
        ),
      );
    } else {
      return const Center(
        child: Text(
          "다른 사용자가 입장할 때까지 대기해주세요.",
          textAlign: TextAlign.center,
        ),
      );
    }
  }
}
