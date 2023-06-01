part of liplayer;

class LiOption {
  final Map<int, Map<String, dynamic>> _options = {};

  final Map<String, dynamic> _hostOption = {};
  final Map<String, dynamic> _formatOption = {};
  final Map<String, dynamic> _codecOption = {};
  final Map<String, dynamic> _swsOption = {};
  final Map<String, dynamic> _playerOption = {};
  final Map<String, dynamic> _swrOption = {};

  static const int hostCategory = 0;
  static const int formatCategory = 1;
  static const int codecCategory = 2;
  static const int swsCategory = 3;
  static const int playerCategory = 4;
  static const int swrCategory = 5;

  /// return a deep copy of option datas
  Map<int, Map<String, dynamic>> get data {
    final Map<int, Map<String, dynamic>> options = {};
    options[0] = Map.from(_hostOption);
    options[1] = Map.from(_formatOption);
    options[2] = Map.from(_codecOption);
    options[3] = Map.from(_swsOption);
    options[4] = Map.from(_playerOption);
    options[5] = Map.from(_swrOption);
    LiLog.i("LiOption cloned");
    return options;
  }

  LiOption() {
    _options[0] = _hostOption;
    _options[1] = _formatOption;
    _options[2] = _codecOption;
    _options[3] = _swsOption;
    _options[4] = _playerOption;
    _options[5] = _swrOption;
  }

  /// set host option
  /// [value] must be int or String
  void setHostOption(String key, dynamic value) {
    if (value is String || value is int) {
      _hostOption[key] = value;
      LiLog.v("LiOption.setHostOption key:$key, value :$value");
    } else {
      LiLog.e("LiOption.setHostOption with invalid value:$value");
      throw ArgumentError.value(value, "value", "Must be int or String");
    }
  }

  /// set player option
  /// [value] must be int or String
  void setPlayerOption(String key, dynamic value) {
    if (value is String || value is int) {
      _playerOption[key] = value;
      LiLog.v("LiOption.setPlayerOption key:$key, value :$value");
    } else {
      LiLog.e("LiOption.setPlayerOption with invalid value:$value");
      throw ArgumentError.value(value, "value", "Must be int or String");
    }
  }

  /// set ffmpeg avformat option
  /// [value] must be int or String
  void setFormatOption(String key, dynamic value) {
    if (value is String || value is int) {
      _formatOption[key] = value;
      LiLog.v("LiOption.setFormatOption key:$key, value :$value");
    } else {
      LiLog.e("LiOption.setFormatOption with invalid value:$value");
      throw ArgumentError.value(value, "value", "Must be int or String");
    }
  }

  /// set ffmpeg avcodec option
  /// [value] must be int or String
  void setCodecOption(String key, dynamic value) {
    if (value is String || value is int) {
      _codecOption[key] = value;
      LiLog.v("LiOption.setCodecOption key:$key, value :$value");
    } else {
      LiLog.e("LiOption.setCodecOption with invalid value:$value");
      throw ArgumentError.value(value, "value", "Must be int or String");
    }
  }

  /// set ffmpeg swscale option
  /// [value] must be int or String
  void setSwsOption(String key, dynamic value) {
    if (value is String || value is int) {
      _swsOption[key] = value;
      LiLog.v("LiOption.setSwsOption key:$key, value :$value");
    } else {
      LiLog.e("LiOption.setSwsOption with invalid value:$value");
      throw ArgumentError.value(value, "value", "Must be int or String");
    }
  }

  /// set ffmpeg swresample option
  /// [value] must be int or String
  void setSwrOption(String key, dynamic value) {
    if (value is String || value is int) {
      _swrOption[key] = value;
      LiLog.v("LiOption.setSwrOption key:$key, value :$value");
    } else {
      LiLog.e("LiOption.setSwrOption with invalid value:$value");
      throw ArgumentError.value(value, "value", "Must be int or String");
    }
  }
}
