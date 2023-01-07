import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter_agora/src/utils/project_padding.dart';
import 'package:flutter_agora/src/utils/settings.dart';
import 'package:flutter_agora/src/utils/strings.dart';

import '../widgets/app_button.dart';

class CallPage extends StatefulWidget {
  const CallPage({Key? key, this.channelName, this.role}) : super(key: key);

  final String? channelName;
  final ClientRoleType? role;

  @override
  State<CallPage> createState() => _CallPageState();
}

class _CallPageState extends State<CallPage> {
  final ProjectString _projectString = ProjectString();
  final ProjectPadding _projectPadding = ProjectPadding();

  final _users = <int>[];
  final _infoStrings = <String>[];
  bool muted = false;
  bool viewPanel = false;
  late RtcEngine _engine;

  bool _localUserJoined = false;
  int _remoteUid = 0;

  @override
  void initState() {
    super.initState();
    initialize();
  }

  @override
  void dispose() {
    super.dispose();
    _users.clear();
    _engine.leaveChannel();
  }

  Future<void> initialize() async {
    if (appId.isEmpty) {
      setState(() {
        _infoStrings.add('APP_ID is missing provide your APP_ID in settings.dart');
      });
      _infoStrings.add('Agora Engine is not starting');
      return;
    }
    //for initializing agora
    _engine = createAgoraRtcEngine();
    await _engine.enableVideo();
    await _engine.setChannelProfile(ChannelProfileType.channelProfileLiveBroadcasting);
    await _engine.setClientRole(role: widget.role!);

    //for agora eventhandlers
    _addAgoraEventHandler();
    VideoEncoderConfiguration configuration = VideoEncoderConfiguration();
    // final cannot modified -- configuration.dimensions = VideoDimensions(height: 1920, width: 1080);
    await _engine.setVideoEncoderConfiguration(configuration);
    await _engine.joinChannel(
      token: token,
      channelId: widget.channelName!,
      uid: 0,
      options: const ChannelMediaOptions(),
    );
  }

  void _addAgoraEventHandler() {
    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: _onJoinChannelSuccess,
        onUserJoined: _onUserJoined,
        onLeaveChannel: _onLeaveChannel,
        onUserOffline: _onUserOffline,
        onFirstRemoteVideoFrame: _onFirstRemoteVideoFrame,
      ),
    );
  }

  void _onJoinChannelSuccess(RtcConnection connection, int elapsed) {
    setState(() {
      final info = "local user ${connection.localUid} joine.";
      _infoStrings.add(info);
      _localUserJoined = true;
    });
  }

  void _onUserJoined(RtcConnection connection, int remoteUid, int elapsed) {
    setState(() {
      final info = "remote user $remoteUid joined.";
      _infoStrings.add(info);
      _remoteUid = remoteUid;
      _users.add(_remoteUid);
    });
  }

  void _onLeaveChannel(RtcConnection connection, RtcStats stats) {
    setState(() {
      _infoStrings.add("Leave channel");
      _users.clear();
    });
  }

  void _onUserOffline(RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
    setState(() {
      final info = "Remote user $remoteUid has left the channel.";
      _infoStrings.add(info);
      _remoteUid = 0;
      _users.remove(remoteUid);
    });
  }

  void _onFirstRemoteVideoFrame(RtcConnection connection, int remoteUid, int width, int height, int elapsed) {
    setState(() {
      final info = "First remote video $remoteUid $width x $height";
      _infoStrings.add(info);
    });
  }

  void _viewPanel() {
    setState(() {
      viewPanel = !viewPanel;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(_projectString.title),
        actions: [
          IconButton(
            onPressed: _viewPanel,
            icon: const Icon(Icons.info_outline),
          ),
        ],
      ),
      body: Center(
        child: Stack(
          children: [
            _viewRows(),
            _panel(),
            _toolBar(),
          ],
        ),
      ),
    );
  }

  Widget _viewRows() {
    final List<StatefulWidget> list = [];
    if (widget.role == ClientRoleType.clientRoleBroadcaster) {
      list.add(
        _localUserJoined
            ? AgoraVideoView(
                controller: VideoViewController(
                  rtcEngine: _engine,
                  canvas: const VideoCanvas(uid: 0),
                ),
              )
            : const CircularProgressIndicator(),
      );
    }

    for (var _remoteUid in _users) {
      list.add(
        AgoraVideoView(
          controller: VideoViewController.remote(
            rtcEngine: _engine,
            canvas: VideoCanvas(uid: _remoteUid),
            connection: RtcConnection(channelId: widget.channelName),
          ),
        ),
      );

      final view = list;

      return Column(
        children: List.generate(
          view.length,
          (index) => Expanded(
            child: view[index],
          ),
        ),
      );
    }
  }

  Widget _toolBar() {
    if (widget.role == ClientRoleType.clientRoleAudience) return const SizedBox();
    return Container(
      alignment: Alignment.bottomCenter,
      padding: _projectPadding.mediumPadding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ProjectRawMaterialButton(type: ButtonType.mic, muted: muted, onPressed: handleMute),
          ProjectRawMaterialButton(type: ButtonType.close, onPressed: endCall),
          ProjectRawMaterialButton(type: ButtonType.switchCamera, onPressed: switchCamera),
        ],
      ),
    );
  }

  void handleMute() {
    setState(() {
      muted = !muted;
    });
    _engine.muteLocalAudioStream(muted);
  }

  void endCall() {
    Navigator.pop(context);
  }

  void switchCamera() {
    _engine.switchCamera();
  }

  Widget _panel() {
    return Visibility(
      visible: viewPanel,
      child: Container(
        padding: _projectPadding.verticalHighPadding,
        alignment: Alignment.bottomCenter,
        child: FractionallySizedBox(
          heightFactor: .5,
          child: Container(
            padding: _projectPadding.verticalHighPadding,
            child: ListView.builder(
              reverse: true,
              itemCount: _infoStrings.length,
              itemBuilder: (BuildContext context, int index) {
                if (_infoStrings.isEmpty) return const Text('null');
                return Padding(
                  padding: _projectPadding.symmetricLowPadding,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Container(
                          padding: _projectPadding.symmetricxxsPadding,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            _infoStrings[index],
                            style: Theme.of(context).textTheme.subtitle1,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
