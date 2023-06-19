import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:liplayer/liplayer.dart';

import 'app_bar.dart';
// import 'custom_ui.dart';

class VideoScreen extends StatefulWidget {
  final String url;

  const VideoScreen({
    super.key,
    required this.url,
  });

  @override
  createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  final LiPlayer player = LiPlayer();

  _VideoScreenState();

  @override
  void initState() {
    super.initState();
    player.setOption(LiOption.hostCategory, "enable-snapshot", 1);
    player.setOption(LiOption.playerCategory, "mediacodec-all-videos", 1);
    startPlay();
  }

  void startPlay() async {
    await player.setOption(LiOption.hostCategory, "request-screen-on", 1);
    await player.setOption(LiOption.hostCategory, "request-audio-focus", 1);
    await player.setDataSource(widget.url, autoPlay: true).catchError((e) {
      if (kDebugMode) {
        print("setDataSource error: $e");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const LiAppBar.defaultSetting(title: "Video"),
      body: Center(
        child: LiView(
          player: player,
          panelBuilder: defaultLiPanelBuilder,
          fsFit: LiFit.fill,
          color: Colors.black,
          // panelBuilder: simplestUI,
          // panelBuilder: (LiPlayer player, BuildContext context,
          //     Size viewSize, Rect texturePos) {
          //   return CustomLiPanel(
          //       player: player,
          //       buildContext: context,
          //       viewSize: viewSize,
          //       texturePos: texturePos);
          // },
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    player.release();
  }
}
