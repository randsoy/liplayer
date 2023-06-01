

#import <Flutter/Flutter.h>

@interface LiplayerPlugin : NSObject <FlutterPlugin, FlutterStreamHandler>

@property int playingCnt;
@property int playableCnt;

+ (LiplayerPlugin *)singleInstance;

@end