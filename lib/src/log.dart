// ignore_for_file: constant_identifier_names

part of liplayer;

class LiLogLevel {
  final int level;
  final String name;

  const LiLogLevel._(int l, String n)
      : level = l,
        name = n;

  /// Priority constant for the [LiLog.log] method;
  static const LiLogLevel All = LiLogLevel._(000, 'all');

  /// Priority constant for the [LiLog.log] method;
  static const LiLogLevel Detail = LiLogLevel._(100, 'det');

  /// Priority constant for the [LiLog.log] method;
  static const LiLogLevel Verbose = LiLogLevel._(200, 'veb');

  /// Priority constant for the [LiLog.log] method; use [LiLog.d(msg)]
  static const LiLogLevel Debug = LiLogLevel._(300, 'dbg');

  /// Priority constant for the [LiLog.log] method; use [LiLog.i(msg)]
  static const LiLogLevel Info = LiLogLevel._(400, 'inf');

  /// Priority constant for the [LiLog.log] method; use [LiLog.w(msg)]
  static const LiLogLevel Warn = LiLogLevel._(500, 'war');

  /// Priority constant for the [LiLog.log] method; use [LiLog.e(msg)]
  static const LiLogLevel Error = LiLogLevel._(600, 'err');
  static const LiLogLevel Fatal = LiLogLevel._(700, 'fal');
  static const LiLogLevel Silent = LiLogLevel._(800, 'sil');

  @override
  String toString() {
    return 'LiLogLevel{level:$level, name:$name}';
  }
}

/// API for sending log output
///
/// Generally, you should use the [LiLog.d(msg)], [LiLog.i(msg)],
/// [LiLog.w(msg)], and [LiLog.e(msg)] methods to write logs.
/// You can then view the logs in console/logcat.
///
/// The order in terms of verbosity, from least to most is ERROR, WARN, INFO, DEBUG, VERBOSE.
/// Verbose should always be skipped in an application except during development.
/// Debug logs are compiled in but stripped at runtime.
/// Error, warning and info logs are always kept.
class LiLog {
  static LiLogLevel _level = LiLogLevel.Info;

  /// Make constructor private
  const LiLog._();

  /// Set global whole log level
  ///
  /// Call this method on Android platform will load natvie shared libraries.
  /// If you care about app boot performance,
  /// you should call this method as late as possiable. Call this method before the first time you consturctor new [LiPlayer]
  static setLevel(final LiLogLevel level) {
    _level = level;
    log(LiLogLevel.Silent, "set log level $level", "Li");
    LiPlugin._setLogLevel(level.level).then((_) {
      log(LiLogLevel.Silent, "native log level ${level.level}", "Li");
    });
  }

  /// log [msg] with [level] and [tag] to console
  static log(LiLogLevel level, String msg, String tag) {
    if (level.level >= _level.level) {
      DateTime now = DateTime.now();
      if (kDebugMode) {
        print("[${level.name}] ${now.toLocal()} [$tag] $msg");
      }
    }
  }

  /// log [msg] with [LiLogLevel.Verbose] level
  static v(String msg, {String tag = 'Li'}) {
    log(LiLogLevel.Verbose, msg, tag);
  }

  /// log [msg] with [LiLogLevel.Debug] level
  static d(String msg, {String tag = 'Li'}) {
    log(LiLogLevel.Debug, msg, tag);
  }

  /// log [msg] with [LiLogLevel.Info] level
  static i(String msg, {String tag = 'Li'}) {
    log(LiLogLevel.Info, msg, tag);
  }

  /// log [msg] with [LiLogLevel.Warn] level
  static w(String msg, {String tag = 'Li'}) {
    log(LiLogLevel.Warn, msg, tag);
  }

  /// log [msg] with [LiLogLevel.Error] level
  static e(String msg, {String tag = 'Li'}) {
    log(LiLogLevel.Error, msg, tag);
  }
}
