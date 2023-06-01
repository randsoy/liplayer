// ignore_for_file: use_build_context_synchronously

part of liplayer;

/// The signature of the [LayoutBuilder] builder function.
///
/// Must not return null.
/// The return widget is placed as one of [Stack]'s children.
/// If change LiView between normal mode and full screen mode, the panel would
/// be rebuild. [data] can be used to pass value from different panel.
typedef LiPanelWidgetBuilder = Widget Function(LiPlayer player, LiData data,
    BuildContext context, Size viewSize, Rect texturePos);

/// How a video should be inscribed into [LiView].
///
/// See also [BoxFit]
class LiFit {
  const LiFit(
      {this.alignment = Alignment.center,
      this.aspectRatio = -1,
      this.sizeFactor = 1.0});

  /// [Alignment] for this [LiView] Container.
  /// alignment is applied to Texture inner LiView
  final Alignment alignment;

  /// [aspectRatio] controls inner video texture widget's aspect ratio.
  ///
  /// A [LiView] has an important child widget which display the video frame.
  /// This important inner widget is a [Texture] in this version.
  /// Normally, we want the aspectRatio of [Texture] to be same
  /// as playback's real video frame's aspectRatio.
  /// It's also the default behaviour of [LiView]
  /// or if aspectRatio is assigned null or negative value.
  ///
  /// If you want to change this default behaviour,
  /// just pass the aspectRatio you want.
  ///
  /// Addition: double.infinate is a special value.
  /// The aspect ratio of inner Texture will be same as LiView's aspect ratio
  /// if you set double.infinate to attribute aspectRatio.
  final double aspectRatio;

  /// The size of [Texture] is multiplied by this factor.
  ///
  /// Some spacial values:
  ///  * (-1.0, -0.0) scaling up to max of [LiView]'s width and height
  ///  * (-2.0, -1.0) scaling up to [LiView]'s width
  ///  * (-3.0, -2.0) scaling up to [LiView]'s height
  final double sizeFactor;

  /// Fill the target LiView box by distorting the video's aspect ratio.
  static const LiFit fill = LiFit(
    sizeFactor: 1.0,
    aspectRatio: double.infinity,
    alignment: Alignment.center,
  );

  /// As large as possible while still containing the video entirely within the
  /// target LiView box.
  static const LiFit contain = LiFit(
    sizeFactor: 1.0,
    aspectRatio: -1,
    alignment: Alignment.center,
  );

  /// As small as possible while still covering the entire target LiView box.
  static const LiFit cover = LiFit(
    sizeFactor: -0.5,
    aspectRatio: -1,
    alignment: Alignment.center,
  );

  /// Make sure the full width of the source is shown, regardless of
  /// whether this means the source overflows the target box vertically.
  static const LiFit fitWidth = LiFit(sizeFactor: -1.5);

  /// Make sure the full height of the source is shown, regardless of
  /// whether this means the source overflows the target box horizontally.
  static const LiFit fitHeight = LiFit(sizeFactor: -2.5);

  /// As large as possible while still containing the video entirely within the
  /// target LiView box. But change video's aspect ratio to 4:3.
  static const LiFit ar4_3 = LiFit(aspectRatio: 4.0 / 3.0);

  /// As large as possible while still containing the video entirely within the
  /// target LiView box. But change video's aspect ratio to 16:9.
  static const LiFit ar16_9 = LiFit(aspectRatio: 16.0 / 9.0);
}

/// [LiView] is a widget that can display the video frame of [LiPlayer].
///
/// Actually, it is a Container widget contains many children.
/// The most important is a Texture which display the read video frame.
class LiView extends StatefulWidget {
  const LiView({
    super.key,
    required this.player,
    this.width,
    this.height,
    this.fit = LiFit.contain,
    this.fsFit = LiFit.contain,
    this.panelBuilder = defaultLiPanelBuilder,
    this.color = const Color(0xFF607D8B),
    this.cover,
    this.fs = true,
    this.onDispose,
  });

  /// The player that need display video by this [LiView].
  /// Will be passed to [panelBuilder].
  final LiPlayer player;

  /// builder to build panel Widget
  final LiPanelWidgetBuilder panelBuilder;

  /// This method will be called when LiView dispose.
  /// LiData is managed inner LiView. User can change LiData in custom panel.
  /// See [panelBuilder]'s second argument.
  /// And check if some value need to be recover on LiView dispose.
  final void Function(LiData)? onDispose;

  /// background color
  final Color color;

  /// cover image provider
  final ImageProvider? cover;

  /// How a video should be inscribed into this [LiView].
  final LiFit fit;

  /// How a video should be inscribed into this [LiView] at fullScreen mode.
  final LiFit fsFit;

  /// Nullable, width of [LiView]
  /// If null, the weight will be as big as possible.
  final double? width;

  /// Nullable, height of [LiView].
  /// If null, the height will be as big as possible.
  final double? height;

  /// Enable or disable the full screen
  ///
  /// If [fs] is true, LiView make response to the [LiValue.fullScreen] value changed,
  /// and push o new full screen mode page when [LiValue.fullScreen] is true, pop full screen page when [LiValue.fullScreen]  become false.
  ///
  /// If [fs] is false, LiView never make response to the change of [LiValue.fullScreen].
  /// But you can still call [LiPlayer.enterFullScreen] and [LiPlayer.exitFullScreen] and make your own full screen pages.
  final bool fs;

  @override
  createState() => _LiViewState();
}

class _LiViewState extends State<LiView> {
  int _textureId = -1;
  double _vWidth = -1;
  double _vHeight = -1;
  bool _fullScreen = false;

  final LiData _mpData = LiData();
  ValueNotifier<int> paramNotifier = ValueNotifier(0);

  @override
  void initState() {
    super.initState();
    Size? s = widget.player.value.size;
    if (s != null) {
      _vWidth = s.width;
      _vHeight = s.height;
    }
    widget.player.addListener(_mpValueListener);
    _nativeSetup();
  }

  Future<void> _nativeSetup() async {
    if (widget.player.value.prepared) {
      _setupTexture();
    }
    paramNotifier.value = paramNotifier.value + 1;
  }

  void _setupTexture() async {
    final int? vid = await widget.player.setupSurface();
    if (vid == null) {
      LiLog.e("failed to set surface");
      return;
    }
    LiLog.i("view setup, vid:$vid");
    if (mounted) {
      setState(() {
        _textureId = vid;
      });
    }
  }

  void _mpValueListener() async {
    LiValue value = widget.player.value;
    if (value.prepared && _textureId < 0) {
      _setupTexture();
    }

    if (widget.fs) {
      if (value.fullScreen && !_fullScreen) {
        _fullScreen = true;
        await _pushFullScreenWidget(context);
      } else if (_fullScreen && !value.fullScreen) {
        Navigator.of(context).pop();
        _fullScreen = false;
      }

      // save width and height to make judgement about whether to
      // request landscape when enter full screen mode
      Size? size = value.size;
      if (size != null && value.prepared) {
        _vWidth = size.width;
        _vHeight = size.height;
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    widget.player.removeListener(_mpValueListener);

    var brightness = _mpData.getValue(LiData._mpViewPanelBrightness);
    if (brightness != null && brightness is double) {
      LiPlugin.setScreenBrightness(brightness);
      _mpData.clearValue(LiData._mpViewPanelBrightness);
    }

    var volume = _mpData.getValue(LiData._mpViewPanelVolume);
    if (volume != null && volume is double) {
      LiVolume.setVol(volume);
      _mpData.clearValue(LiData._mpViewPanelVolume);
    }

    widget.onDispose?.call(_mpData);
  }

  AnimatedWidget _defaultRoutePageBuilder(
      BuildContext context, Animation<double> animation) {
    return AnimatedBuilder(
      animation: animation,
      builder: (BuildContext context, Widget? child) {
        return Scaffold(
          resizeToAvoidBottomInset: false,
          body: _InnerLiView(
            mpViewState: this,
            fullScreen: true,
            cover: widget.cover,
            data: _mpData,
          ),
        );
      },
    );
  }

  Widget _fullScreenRoutePageBuilder(BuildContext context,
      Animation<double> animation, Animation<double> secondaryAnimation) {
    return _defaultRoutePageBuilder(context, animation);
  }

  Future<dynamic> _pushFullScreenWidget(BuildContext context) async {
    final TransitionRoute route = PageRouteBuilder(
      settings: const RouteSettings(),
      pageBuilder: _fullScreenRoutePageBuilder,
    );

    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: []);
    bool changed = false;
    // var orientation = MediaQuery.of(context).orientation;
    // LiLog.d("start enter fullscreen. orientation:$orientation");
    if (_vWidth >= _vHeight) {
      if (MediaQuery.of(context).orientation == Orientation.portrait) {
        changed = await LiPlugin.setOrientationLandscape();
      }
    } else {
      if (MediaQuery.of(context).orientation == Orientation.landscape) {
        changed = await LiPlugin.setOrientationPortrait();
      }
    }
    LiLog.d("screen orientation changed:$changed");

    await Navigator.of(context).push(route);
    _fullScreen = false;
    widget.player.exitFullScreen();
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom]);
    if (changed) {
      if (_vWidth >= _vHeight) {
        await LiPlugin.setOrientationPortrait();
      } else {
        await LiPlugin.setOrientationLandscape();
      }
    }
  }

  @override
  void didUpdateWidget(Widget oldWidget) {
    super.didUpdateWidget(oldWidget as LiView);
    paramNotifier.value = paramNotifier.value + 1;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: _fullScreen
          ? Container()
          : _InnerLiView(
              mpViewState: this,
              fullScreen: false,
              cover: widget.cover,
              data: _mpData,
            ),
    );
  }
}

class _InnerLiView extends StatefulWidget {
  const _InnerLiView({
    required this.mpViewState,
    required this.fullScreen,
    required this.cover,
    required this.data,
  });

  final _LiViewState mpViewState;
  final bool fullScreen;
  final ImageProvider? cover;
  final LiData data;

  @override
  __InnermpViewState createState() => __InnermpViewState();
}

class __InnermpViewState extends State<_InnerLiView> {
  late LiPlayer _player;
  LiPanelWidgetBuilder? _panelBuilder;
  Color? _color;
  LiFit _fit = LiFit.contain;
  int _textureId = -1;
  double _vWidth = -1;
  double _vHeight = -1;
  final bool _vFullScreen = false;
  int _degree = 0;
  bool _videoRender = false;

  @override
  void initState() {
    super.initState();
    _player = fView.player;
    _mpValueListener();
    fView.player.addListener(_mpValueListener);
    if (widget.fullScreen) {
      widget.mpViewState.paramNotifier.addListener(_voidValueListener);
    }
  }

  LiView get fView => widget.mpViewState.widget;

  void _voidValueListener() {
    var binding = WidgetsBinding.instance;
    binding.addPostFrameCallback((_) => _mpValueListener());
  }

  void _mpValueListener() {
    if (!mounted) return;

    LiPanelWidgetBuilder panelBuilder = fView.panelBuilder;
    Color color = fView.color;
    LiFit fit = widget.fullScreen ? fView.fsFit : fView.fit;
    int textureId = widget.mpViewState._textureId;

    LiValue value = _player.value;

    _degree = value.rotate;
    double width = _vWidth;
    double height = _vHeight;
    bool fullScreen = value.fullScreen;
    bool videoRender = value.videoRenderStart;

    Size? size = value.size;
    if (size != null && value.prepared) {
      width = size.width;
      height = size.height;
    }

    if (width != _vWidth ||
        height != _vHeight ||
        fullScreen != _vFullScreen ||
        panelBuilder != _panelBuilder ||
        color != _color ||
        fit != _fit ||
        textureId != _textureId ||
        _videoRender != videoRender) {
      if (mounted) {
        setState(() {});
      }
    }
  }

  Size applyAspectRatio(BoxConstraints constraints, double aspectRatio) {
    assert(constraints.hasBoundedHeight && constraints.hasBoundedWidth);

    constraints = constraints.loosen();

    double width = constraints.maxWidth;
    double height = width;

    if (width.isFinite) {
      height = width / aspectRatio;
    } else {
      height = constraints.maxHeight;
      width = height * aspectRatio;
    }

    if (width > constraints.maxWidth) {
      width = constraints.maxWidth;
      height = width / aspectRatio;
    }

    if (height > constraints.maxHeight) {
      height = constraints.maxHeight;
      width = height * aspectRatio;
    }

    if (width < constraints.minWidth) {
      width = constraints.minWidth;
      height = width / aspectRatio;
    }

    if (height < constraints.minHeight) {
      height = constraints.minHeight;
      width = height * aspectRatio;
    }

    return constraints.constrain(Size(width, height));
  }

  double getAspectRatio(BoxConstraints constraints, double ar) {
    if (ar < 0) {
      ar = _vWidth / _vHeight;
    } else if (ar.isInfinite) {
      ar = constraints.maxWidth / constraints.maxHeight;
    }
    return ar;
  }

  /// calculate Texture size
  Size getTxSize(BoxConstraints constraints, LiFit fit) {
    Size childSize = applyAspectRatio(
        constraints, getAspectRatio(constraints, fit.aspectRatio));
    double sizeFactor = fit.sizeFactor;
    if (-1.0 < sizeFactor && sizeFactor < -0.0) {
      sizeFactor = max(constraints.maxWidth / childSize.width,
          constraints.maxHeight / childSize.height);
    } else if (-2.0 < sizeFactor && sizeFactor < -1.0) {
      sizeFactor = constraints.maxWidth / childSize.width;
    } else if (-3.0 < sizeFactor && sizeFactor < -2.0) {
      sizeFactor = constraints.maxHeight / childSize.height;
    } else if (sizeFactor < 0) {
      sizeFactor = 1.0;
    }
    childSize = childSize * sizeFactor;
    return childSize;
  }

  /// calculate Texture offset
  Offset getTxOffset(BoxConstraints constraints, Size childSize, LiFit fit) {
    final Alignment resolvedAlignment = fit.alignment;
    final Offset diff = (constraints.biggest - childSize) as Offset;
    return resolvedAlignment.alongOffset(diff);
  }

  Widget buildTexture() {
    Widget tex = _textureId > 0 ? Texture(textureId: _textureId) : Container();
    if (_degree != 0 && _textureId > 0) {
      return RotatedBox(
        quarterTurns: _degree ~/ 90,
        child: tex,
      );
    }
    return tex;
  }

  @override
  void dispose() {
    super.dispose();
    fView.player.removeListener(_mpValueListener);
    widget.mpViewState.paramNotifier.removeListener(_mpValueListener);
  }

  @override
  Widget build(BuildContext context) {
    _panelBuilder = fView.panelBuilder;
    _color = fView.color;
    _fit = widget.fullScreen ? fView.fsFit : fView.fit;
    _textureId = widget.mpViewState._textureId;

    LiValue value = _player.value;
    LiData data = widget.data;
    Size? size = value.size;
    if (size != null && value.prepared) {
      _vWidth = size.width;
      _vHeight = size.height;
    }
    _videoRender = value.videoRenderStart;

    return LayoutBuilder(builder: (ctx, constraints) {
      // get child size
      final Size childSize = getTxSize(constraints, _fit);
      final Offset offset = getTxOffset(constraints, childSize, _fit);
      final Rect pos = Rect.fromLTWH(
          offset.dx, offset.dy, childSize.width, childSize.height);

      List ws = <Widget>[
        Container(
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          color: _color,
        ),
        Positioned.fromRect(
            rect: pos,
            child: Container(
              color: const Color(0xFF000000),
              child: buildTexture(),
            )),
      ];

      if (widget.cover != null && !value.videoRenderStart) {
        ws.add(Positioned.fromRect(
          rect: pos,
          child: Image(
            image: widget.cover!,
            fit: BoxFit.fill,
          ),
        ));
      }

      if (_panelBuilder != null) {
        ws.add(_panelBuilder!(_player, data, ctx, constraints.biggest, pos));
      }
      return Stack(
        children: ws as List<Widget>,
      );
    });
  }
}
