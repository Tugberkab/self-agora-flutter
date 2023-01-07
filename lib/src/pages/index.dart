import 'dart:developer';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_agora/src/pages/call.dart';
import 'package:flutter_agora/src/utils/project_padding.dart';
import 'package:flutter_agora/src/utils/strings.dart';
import 'package:permission_handler/permission_handler.dart';

class IndexPage extends StatefulWidget {
  const IndexPage({Key? key}) : super(key: key);

  @override
  State<IndexPage> createState() => _IndexPageState();
}

class _IndexPageState extends State<IndexPage> {
  final _channelController = TextEditingController();
  bool _validateError = false;
  ClientRoleType? _role = ClientRoleType.clientRoleBroadcaster;
  final ProjectString _projectString = ProjectString();
  final ProjectPadding _projectPadding = ProjectPadding();

  @override
  void dispose() {
    _channelController.dispose();
    super.dispose();
  }

  void _focusClose() {
    FocusScope.of(context).requestFocus(FocusNode());
  }

  void _changeRole(ClientRoleType? role) {
    setState(() {
      _role = role;
    });
  }

  Future<void> onJoin() async {
    setState(() {
      _channelController.text.isEmpty ? _validateError = true : false;
    });
    if (_channelController.text.isNotEmpty) {
      await handleCameraAndMic(Permission.camera);
      await handleCameraAndMic(Permission.microphone);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CallPage(
            channelName: _channelController.text,
            role: _role,
          ),
        ),
      );
    }
  }

  Future<void> handleCameraAndMic(Permission permission) async {
    final status = await permission.request();
    log(status.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_projectString.title),
      ),
      body: GestureDetector(
        onTap: _focusClose,
        child: SingleChildScrollView(
          child: Padding(
            padding: _projectPadding.mediumPadding,
            child: Column(
              children: [
                Padding(
                  padding: _projectPadding.highPadding,
                  child: Image.asset('assets/telephone.png'),
                ),
                TextField(
                  controller: _channelController,
                  decoration: InputDecoration(
                    errorText: _validateError ? 'Channel name is mandatory' : null,
                    hintText: 'Channel Name',
                  ),
                ),
                RadioListTile(
                  title: Text(_projectString.broadcaster),
                  onChanged: (ClientRoleType? role) => _changeRole(role),
                  value: ClientRoleType.clientRoleBroadcaster,
                  groupValue: _role,
                ),
                RadioListTile(
                  title: Text(_projectString.audience),
                  onChanged: (ClientRoleType? role) => _changeRole(role),
                  value: ClientRoleType.clientRoleAudience,
                  groupValue: _role,
                ),
                ElevatedButton(
                  onPressed: onJoin,
                  child: Text(_projectString.join),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
