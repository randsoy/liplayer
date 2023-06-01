import 'dart:math';

import 'package:flutter/material.dart';
import 'package:liplayer/liplayer.dart';

/// https://Liplayer.befovy.com/docs/zh/custom-ui.html#%E6%97%A0%E7%8A%B6%E6%80%81-ui-
Widget simplestUI(
    LiPlayer player, BuildContext context, Size viewSize, Rect texturePos) {
  Rect rect = Rect.fromLTRB(
      max(0.0, texturePos.left),
      max(0.0, texturePos.top),
      min(viewSize.width, texturePos.right),
      min(viewSize.height, texturePos.bottom));
  bool isPlaying = player.state == LiState.started;
  return Positioned.fromRect(
    rect: rect,
    child: Container(
      alignment: Alignment.bottomLeft,
      child: IconButton(
        icon: Icon(
          isPlaying ? Icons.pause : Icons.play_arrow,
          color: Colors.white,
        ),
        onPressed: () {
          isPlaying ? player.pause() : player.start();
        },
      ),
    ),
  );
}

/// https://Liplayer.befovy.com/docs/zh/custom-ui.html#%E6%9C%89%E7%8A%B6%E6%80%81-ui
class CustomLiPanel extends StatefulWidget {
  final LiPlayer player;
  final BuildContext buildContext;
  final Size viewSize;
  final Rect texturePos;

  const CustomLiPanel({
    super.key,
    required this.player,
    required this.buildContext,
    required this.viewSize,
    required this.texturePos,
  });

  @override
  createState() => _CustomLiPanelState();
}

class _CustomLiPanelState extends State<CustomLiPanel> {
  LiPlayer get player => widget.player;
  bool _playing = false;

  @override
  void initState() {
    super.initState();
    widget.player.addListener(_playerValueChanged);
  }

  void _playerValueChanged() {
    LiValue value = player.value;

    bool playing = (value.state == LiState.started);
    if (playing != _playing) {
      setState(() {
        _playing = playing;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Rect rect = Rect.fromLTRB(
        max(0.0, widget.texturePos.left),
        max(0.0, widget.texturePos.top),
        min(widget.viewSize.width, widget.texturePos.right),
        min(widget.viewSize.height, widget.texturePos.bottom));

    return Positioned.fromRect(
      rect: rect,
      child: Container(
        alignment: Alignment.bottomLeft,
        child: IconButton(
          icon: Icon(
            _playing ? Icons.pause : Icons.play_arrow,
            color: Colors.white,
          ),
          onPressed: () {
            _playing ? widget.player.pause() : widget.player.start();
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    player.removeListener(_playerValueChanged);
  }
}
