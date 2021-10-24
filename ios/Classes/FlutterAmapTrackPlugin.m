#import "FlutterAmapTrackPlugin.h"
#import <ObjFlutterAmapTrackPlugin.h>

@implementation FlutterAmapTrackPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    [ObjFlutterAmapTrackPlugin registerWithRegistrar:registrar];
}

@end
