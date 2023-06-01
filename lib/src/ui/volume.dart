part of liplayer;

/// Default builder generate default LiVolToast UI
Widget defaultLiVolumeToast(double value, Stream<double> emitter) {
  return _LiSliderToast(value, 0, emitter);
}

Widget defaultLiBrightnessToast(double value, Stream<double> emitter) {
  return _LiSliderToast(value, 1, emitter);
}

class _LiSliderToast extends StatefulWidget {
  final Stream<double> emitter;
  final double initial;

  // type 0 volume
  // type 1 screen brightness
  final int type;

  const _LiSliderToast(this.initial, this.type, this.emitter);

  @override
  _LiSliderToastState createState() => _LiSliderToastState();
}

class _LiSliderToastState extends State<_LiSliderToast> {
  double value = 0;
  StreamSubscription? subs;

  @override
  void initState() {
    super.initState();
    value = widget.initial;
    subs = widget.emitter.listen((v) {
      setState(() {
        value = v;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    subs?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    IconData iconData;
    final type = widget.type;
    if (value <= 0) {
      iconData = type == 0 ? Icons.volume_mute : Icons.brightness_low;
    } else if (value < 0.5) {
      iconData = type == 0 ? Icons.volume_down : Icons.brightness_medium;
    } else {
      iconData = type == 0 ? Icons.volume_up : Icons.brightness_high;
    }

    final primaryColor = Theme.of(context).primaryColor;
    return Align(
      alignment: const Alignment(0, -0.4),
      child: Card(
        color: const Color(0x33000000),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                iconData,
                color: Colors.white,
              ),
              Container(
                width: 100,
                height: 1.5,
                margin: const EdgeInsets.only(left: 8),
                child: LinearProgressIndicator(
                  value: value,
                  backgroundColor: Colors.black,
                  valueColor: AlwaysStoppedAnimation(primaryColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
