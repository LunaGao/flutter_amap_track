#import <ObjFlutterAmapTrackPlugin.h>

@implementation ObjFlutterAmapTrackPlugin

static FlutterMethodChannel* channel;

+ (void)registerWithRegistrar:(nonnull NSObject<FlutterPluginRegistrar> *)registrar {
    channel = [FlutterMethodChannel methodChannelWithName:@"flutter_amap_track"
                binaryMessenger:[registrar messenger]];
    ObjFlutterAmapTrackPlugin* instance = [[ObjFlutterAmapTrackPlugin alloc] init];
    [registrar addMethodCallDelegate:instance channel:channel];
}

static AMapTrackManager* trackManager;

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSDictionary<NSString*,id>* params = call.arguments;
    if ([@"setIOSApiKey" isEqualToString:call.method]) {
        NSString* apiKey = params[@"apiKey"];
        NSLog(@"setIOSApiKey");
        if (apiKey != nil) {
            NSLog(@"apikey:\(apiKey!)");
            [AMapServices sharedServices].apiKey = apiKey;
        }
    } else if ([@"initWithServiceId" isEqualToString:call.method]) {
        int sid = params[@"sid"];
        if (sid != nil) {
            AMapTrackManagerOptions * option = [[AMapTrackManagerOptions alloc] init];
            [option setServiceID:[NSString stringWithFormat:@"%d", sid]];
            NSLog(@"%@", [@"sid: " stringByAppendingString:option.serviceID]);
            trackManager = [[AMapTrackManager alloc] initWithOptions:option];
            [trackManager setDelegate:self];
        }
    } else if ([@"setCacheSize" isEqualToString:call.method]) {
        int cacheSize = params[@"cacheSize"];
        if (cacheSize != nil) {
            [trackManager setLocalCacheMaxSize:cacheSize];
        }
    } else if ([@"setInterval" isEqualToString:call.method]) {
        int gatherInterval = params[@"gatherInterval"];
        int packInterval = params[@"packInterval"];
        if (gatherInterval != nil && packInterval != nil) {
            [trackManager changeGatherAndPackTimeInterval:gatherInterval packTimeInterval:packInterval];
        }
    } else if ([@"setIOSOption" isEqualToString:call.method]) {
        bool allowsBackgroundLocationUpdates = params[@"allowsBackgroundLocationUpdates"];
        bool pausesLocationUpdatesAutomatically = params[@"pausesLocationUpdatesAutomatically"];
        if ( allowsBackgroundLocationUpdates != nil) {
            [trackManager setAllowsBackgroundLocationUpdates:allowsBackgroundLocationUpdates];
        }
        if (pausesLocationUpdatesAutomatically != nil) {
            [trackManager setPausesLocationUpdatesAutomatically:pausesLocationUpdatesAutomatically];
        }
        int activityType = params[@"activityType"];
        if (activityType != nil) {
            switch (activityType) {
                case 0:
                    [trackManager setActivityType:CLActivityTypeAutomotiveNavigation];
                    break;
                case 1:
                    [trackManager setActivityType:CLActivityTypeFitness];
                    break;
                case 2:
                    [trackManager setActivityType:CLActivityTypeOtherNavigation];
                    break;
                case 3:
                    [trackManager setActivityType:CLActivityTypeOther];
                    break;
                default:
                    break;
            }
            [trackManager setActivityType:CLActivityTypeAutomotiveNavigation];
        }
    } else if ([@"addTerminal" isEqualToString:call.method]) {
        int sid = params[@"sid"];
        NSString* terminal = params[@"terminal"];
        NSString* terminalDesc = params[@"terminalDesc"];
        AMapTrackAddTerminalRequest *request = [[AMapTrackAddTerminalRequest alloc] init];
        if (sid != nil) {
            [request setServiceID:[NSString stringWithFormat:@"%d", sid]];
        }
        if (terminal != nil) {
            [request setTerminalName:terminal];
            if (terminalDesc != nil) {
                [request setTerminalDesc:terminalDesc];
            }
            [trackManager AMapTrackAddTerminal:request];
        }
    } else if ([@"queryTerminal" isEqualToString:call.method]) {
        int sid = params[@"sid"];
        NSString* terminal = params[@"terminal"];
        int terminalId = params[@"terminalId"];
        AMapTrackQueryTerminalRequest * request = [[AMapTrackQueryTerminalRequest alloc] init];
        if (sid != nil) {
            [request setServiceID:[NSString stringWithFormat:@"%d", sid]];
        }
        if (terminal != nil) {
            [request setTerminalName:terminal];
        }
        if (terminalId != nil) {
            [request setTerminalID:[NSString stringWithFormat:@"%d", terminalId]];
        }
        [trackManager AMapTrackAddTerminal:request];
    } else if ([@"addTrack" isEqualToString:call.method]) {
        int sid = params[@"sid"];
        int tid = params[@"tid"];
        AMapTrackAddTrackRequest* request = [[AMapTrackAddTrackRequest alloc] init];
        if (sid != nil) {
            [request setServiceID:[NSString stringWithFormat:@"%d", sid]];
        }
        if (tid != nil) {
            [request setTerminalID:[NSString stringWithFormat:@"%d", tid]];
        }
        [trackManager AMapTrackAddTrack:request];
    } else if ([@"deleteTrack" isEqualToString:call.method]) {
        int tid = params[@"tid"];
        int trid = params[@"trid"];
        AMapTrackDeleteTrackRequest *request = [[AMapTrackDeleteTrackRequest alloc] init];
        if (tid != nil && trid != nil) {
            [request setTerminalID:[NSString stringWithFormat:@"%d", tid]];
            [request setTrackID:[NSString stringWithFormat:@"%d", trid]];
        }
        [trackManager AMapTrackDeleteTrack:request];
    } else if ([@"startTrack" isEqualToString:call.method]) {
        int tid = params[@"tid"];
        int trackId = params[@"trackId"];
        AMapTrackManagerServiceOption * option = [[AMapTrackManagerServiceOption alloc] init];
        if (tid != nil) {
            [option setTerminalID:[NSString stringWithFormat:@"%d", tid]];
        }
        [trackManager startServiceWithOptions:option];
        if (trackId != nil) {
            [trackManager setTrackID:[NSString stringWithFormat:@"%d", trackId]];
        }
    } else if ([@"stopTrack" isEqualToString:call.method]) {
        [trackManager stopService];
    } else if ([@"startGather" isEqualToString:call.method]) {
        [trackManager startGatherAndPack];
    } else if ([@"stopGather" isEqualToString:call.method]) {
        [trackManager stopGaterAndPack];
    } else if ([@"getTrackId" isEqualToString:call.method]) {
        result([trackManager trackID]);
    } else if ([@"setTrackId" isEqualToString:call.method]) {
        int trackId = params[@"trackId"];
        if (trackId != nil) {
            [trackManager setTrackID:[NSString stringWithFormat:@"%d", trackId]];
        }
    } else if ([@"queryLatestPoint" isEqualToString:call.method]) {
        int sid = params[@"sid"];
        int tid = params[@"tid"];
        int trid = params[@"trid"];
        int correction = params[@"correction"];
        AMapTrackQueryLastPointRequest * request = [[AMapTrackQueryLastPointRequest alloc] init];
        if (sid != nil) {
            [request setServiceID:[NSString stringWithFormat:@"%d", sid]];
        }
        if (tid != nil) {
            [request setTerminalID:[NSString stringWithFormat:@"%d", tid]];
        }
        if (trid != nil) {
            [request setTrackID:[NSString stringWithFormat:@"%d", trid]];
        }
        NSString* correctionMode = @"n";
        if (correction != nil && correction == 1) {
            correctionMode = @"driving";
        }
        [request setCorrectionMode:correctionMode];
        [trackManager AMapTrackQueryLastPoint:request];
    } else if ([@"queryDistance" isEqualToString:call.method]) {
        int sid = params[@"sid"];
        int tid = params[@"tid"];
        int trid = params[@"trid"];
        long startTime = params[@"startTime"];
        long endTime = params[@"endTime"];
        int correction = params[@"correction"];
        int recoup = params[@"recoup"];
        int gap = params[@"gap"];
        AMapTrackQueryTrackDistanceRequest * request = [[AMapTrackQueryTrackDistanceRequest alloc] init];
        if (sid != nil) {
            [request setServiceID:[NSString stringWithFormat:@"%d", sid]];
        }
        if (tid != nil && trid != nil && startTime != nil && endTime != nil) {
            [request setTerminalID:[NSString stringWithFormat:@"%d", tid]];
            [request setTrackID:[NSString stringWithFormat:@"%d", trid]];
            [request setStartTime:startTime];
            [request setEndTime:endTime];
            NSString* correctionMode = @"n";
            if (correction != nil && correction == 1) {
                correctionMode = @"driving";
            }
            [request setCorrectionMode:correctionMode];
            if (recoup != nil && recoup == 1) {
                [request setRecoupMode:AMapTrackRecoupModeDriving];
            } else {
                [request setRecoupMode:AMapTrackRecoupModeNone];
            }
            NSUInteger uint_gap = gap;
            [request setRecoupGap:uint_gap];
        }
        [trackManager AMapTrackQueryTrackDistance:request];
    } else if ([@"queryHistoryTrack" isEqualToString:call.method]) {
        int sid = params[@"sid"];
        int tid = params[@"tid"];
        long startTime = params[@"startTime"];
        long endTime = params[@"endTime"];
        int correction = params[@"correction"];
        int recoup = params[@"recoup"];
        int gap = params[@"gap"];
        int order = params[@"order"];
        int page = params[@"page"];
        int pageSize = params[@"pageSize"];
        AMapTrackQueryTrackHistoryAndDistanceRequest *request = [[AMapTrackQueryTrackHistoryAndDistanceRequest alloc] init];
        if (sid != nil) {
            [request setServiceID:[NSString stringWithFormat:@"%d", sid]];
        }
        if (tid != nil) {
            [request setTerminalID:[NSString stringWithFormat:@"%d", tid]];
        }
        if (startTime != nil && endTime != nil) {
            [request setStartTime:startTime];
            [request setEndTime:endTime];
        }
        NSString* correctionMode = @"n";
        if (correction != nil && correction == 1) {
            correctionMode = @"driving";
        }
        [request setCorrectionMode:correctionMode];
        if (recoup != nil && recoup == 1) {
            [request setRecoupMode:AMapTrackRecoupModeDriving];
        }else{
            [request setRecoupMode:AMapTrackRecoupModeNone];
        }
        NSUInteger uint_gap = gap;
        [request setRecoupGap:uint_gap];
        if (order != nil) {
            [request setSortType:order];
        }
        if (page != nil && pageSize != nil) {
            NSUInteger uint_page = page;
            NSUInteger uint_pageSize = pageSize;
            [request setPageIndex:uint_page];
            [request setPageSize:uint_pageSize];
        }
        [trackManager AMapTrackQueryTrackHistoryAndDistance:request];
    } else if ([@"queryTerminalTrack" isEqualToString:call.method]) {
        int sid = params[@"sid"];
        int tid = params[@"tid"];
        long startTime = params[@"startTime"];
        long endTime = params[@"endTime"];
        int correction = params[@"correction"];
        int recoup = params[@"recoup"];
        int gap = params[@"gap"];
        bool ispoint = params[@"ispoint"];
        int page = params[@"page"];
        int pageSize = params[@"pageSize"];
        AMapTrackQueryTrackInfoRequest *request = [[AMapTrackQueryTrackInfoRequest alloc] init];
        if (sid != nil) {
            [request setServiceID:[NSString stringWithFormat:@"%d", sid]];
        }
        if (tid != nil) {
            [request setTerminalID:[NSString stringWithFormat:@"%d", tid]];
        }
        if (startTime != nil && endTime != nil) {
            [request setStartTime:startTime];
            [request setEndTime:endTime];
        }
        NSString* correctionMode = @"n";
        if (correction != nil && correction == 1) {
            correctionMode = @"driving";
        }
        [request setCorrectionMode:correctionMode];
        if (recoup != nil && recoup == 1) {
            [request setRecoupMode:AMapTrackRecoupModeDriving];
        }else{
            [request setRecoupMode:AMapTrackRecoupModeNone];
        }
        if (gap != nil) {
            NSUInteger uint_gap = gap;
            [request setRecoupGap:uint_gap];
        }
        if (ispoint != nil) {
            [request setContainPoints:ispoint];
        }
        if (page != nil && pageSize != nil) {
            NSUInteger uint_page = page;
            NSUInteger uint_pageSize = pageSize;
            [request setPageIndex:uint_page];
            [request setPageSize:uint_pageSize];
        }
        [trackManager AMapTrackQueryTrackInfo:request];
    } else if ([@"cancelAllRequests" isEqualToString:call.method]) {
        [trackManager cancelAllRequests];
    } else {
        result(FlutterMethodNotImplemented);
    }
    
    
}

//delegate

- (void)amapTrackManager:(nonnull AMapTrackManager *)manager doRequireTemporaryFullAccuracyAuth:(nonnull CLLocationManager *)locationManager completion:(nonnull void (^)(NSError * _Nonnull))completion {
    [locationManager requestAlwaysAuthorization];
}

//track
NSString *trackTag = @"OnTrackListener";

- (void)didFailWithError:(NSError *)error associatedRequest:(id)request {
    NSDictionary* resultData = [NSDictionary dictionaryWithObject:[@"didFailWithError -- " stringByAppendingFormat:@"%@ || associatedRequest -- %@", error, request] forKey:@"errorMsg"];
    NSLog(@"%@", [@"didFailWithError -- " stringByAppendingFormat:@"%@ || associatedRequest -- %@", error, request]);
    [channel invokeMethod:[trackTag stringByAppendingString:@"#onParamErrorCallback#error"] arguments:resultData];
}

- (void)onAddTerminalDone:(AMapTrackAddTerminalRequest *)request response:(AMapTrackAddTerminalResponse *)response {
    NSMutableDictionary * resultData = [[NSMutableDictionary alloc] init];
    if (response.code == AMapTrackErrorOK) {
        [resultData setValue:[response terminalID] forKey:@"tid"];
        [resultData setValue:@NO forKey:@"isServiceNonExist"];
        [resultData setValue:[response terminalName] forKey:@"terminalName"];
        [channel invokeMethod:[trackTag stringByAppendingString:@"#onCreateTerminalCallback"] arguments:resultData];
    }else{
        [resultData setValue:[NSString stringWithFormat:@"%ld", (long)[response code]] forKey:@"errorCode"];
        [resultData setValue:[response info] forKey:@"errorMsg"];
        [resultData setValue:[response detail] forKey:@"errorDetail"];
        [channel invokeMethod:[trackTag stringByAppendingString:@"#onCreateTerminalCallback#error"] arguments:resultData];
    }
}

- (void)onQueryTerminalDone:(AMapTrackQueryTerminalRequest *)request response:(AMapTrackQueryTerminalResponse *)response {
    NSLog(@"onQueryTerminalDone");
    NSMutableDictionary * resultData = [[NSMutableDictionary alloc] init];
    if (response.code == AMapTrackErrorOK) {
        NSMutableArray* list = [[NSMutableArray alloc] init];
        if ([response terminals] != nil) {
            for (AMapTrackTerminal *terminal in [response terminals]) {
                NSMutableDictionary * t = [[NSMutableDictionary alloc] init];
                [resultData setValue:[terminal tid] forKey:@"tid"];
                [resultData setValue:[terminal name] forKey:@"name"];
                [resultData setValue:[terminal desc] forKey:@"desc"];
                [resultData setValue:[NSString stringWithFormat:@"%lld", [terminal createTime]] forKey:@"createTime"];
                [resultData setValue:[NSString stringWithFormat:@"%lld", [terminal locateTime]] forKey:@"locateTime"];
                [list addObject:t];
            }
        }
        [channel invokeMethod:[trackTag stringByAppendingString:@"#onQueryTerminalCallback"] arguments:list];
    } else {
        [resultData setValue:[NSString stringWithFormat:@"%ld", (long)[response code]] forKey:@"errorCode"];
        [resultData setValue:[response info] forKey:@"errorMsg"];
        [resultData setValue:[response detail] forKey:@"errorDetail"];
        [channel invokeMethod:[trackTag stringByAppendingString:@"#onQueryTerminalCallback#error"] arguments:resultData];
    }
}

- (void)onAddTrackDone:(AMapTrackAddTrackRequest *)request response:(AMapTrackAddTrackResponse *)response {
    NSMutableDictionary * resultData = [[NSMutableDictionary alloc] init];
    if (response.code == AMapTrackErrorOK) {
        [resultData setValue:[response trackID] forKey:@"trid"];
        [channel invokeMethod:[trackTag stringByAppendingString:@"#onAddTrackCallback"] arguments:resultData];
    } else {
        [resultData setValue:[NSString stringWithFormat:@"%ld", (long)[response code]] forKey:@"errorCode"];
        [resultData setValue:[response info] forKey:@"errorMsg"];
        [resultData setValue:[response detail] forKey:@"errorDetail"];
        [channel invokeMethod:[trackTag stringByAppendingString:@"#onAddTrackCallback"] arguments:resultData];
    }
}

- (void)onDeleteTrackDone:(AMapTrackDeleteTrackRequest *)request response:(AMapTrackBaseResponse *)response {
    NSMutableDictionary * resultData = [[NSMutableDictionary alloc] init];
    if (response.code == AMapTrackErrorOK) {
        [channel invokeMethod:[trackTag stringByAppendingString:@"#onDeleteTrackDone"] arguments:resultData];
    } else {
        [resultData setValue:[NSString stringWithFormat:@"%ld", (long)[response code]] forKey:@"errorCode"];
        [resultData setValue:[response info] forKey:@"errorMsg"];
        [resultData setValue:[response detail] forKey:@"errorDetail"];
        [channel invokeMethod:[trackTag stringByAppendingString:@"#onDeleteTrackDone#error"] arguments:resultData];
    }
}

- (void)onQueryLastPointDone:(AMapTrackQueryLastPointRequest *)request response:(AMapTrackQueryLastPointResponse *)response {
    NSMutableDictionary * resultData = [[NSMutableDictionary alloc] init];
    if (response.code == AMapTrackErrorOK) {
        // 这里之前有一个 convertPoint 方法，用来转换这个[response lastPoint]，这里没有实现。 之前的swift代码放到了这个函数后面
        [resultData setValue:[response lastPoint] forKey:@"latestPoint"];
        [channel invokeMethod:[trackTag stringByAppendingString:@"#onLatestPointCallback"] arguments:resultData];
    } else {
        [resultData setValue:[NSString stringWithFormat:@"%ld", (long)[response code]] forKey:@"errorCode"];
        [resultData setValue:[response info] forKey:@"errorMsg"];
        [resultData setValue:[response detail] forKey:@"errorDetail"];
        [channel invokeMethod:[trackTag stringByAppendingString:@"#onLatestPointCallback#error"] arguments:resultData];
    }
}

//    func convertPoint(point: AMapTrackPoint?) -> Any {
//        if point == nil {
//            return NSNull()
//        }
//        var dict = [String: Any?]()
//        dict["lat"] = point!.coordinate.latitude
//        dict["lng"] = point!.coordinate.longitude
//        dict["time"] = point!.locateTime
//        dict["accuracy"] = point!.accuracy
//        dict["direction"] = point!.direction
//        dict["height"] = point!.height
//        return dict
//    }

- (void)onQueryTrackDistanceDone:(AMapTrackQueryTrackDistanceRequest *)request response:(AMapTrackQueryTrackDistanceResponse *)response {
    NSMutableDictionary * resultData = [[NSMutableDictionary alloc] init];
    if (response.code == AMapTrackErrorOK) {
        [resultData setValue:[NSString stringWithFormat:@"%ld", (long)[response distance]] forKey:@"distance"];
        [channel invokeMethod:[trackTag stringByAppendingString:@"#onDistanceCallback"] arguments:resultData];
    } else {
        [resultData setValue:[NSString stringWithFormat:@"%ld", (long)[response code]] forKey:@"errorCode"];
        [resultData setValue:[response info] forKey:@"errorMsg"];
        [resultData setValue:[response detail] forKey:@"errorDetail"];
        [channel invokeMethod:[trackTag stringByAppendingString:@"#onLatestPointCallback#error"] arguments:resultData];
    }
}

- (void)onQueryTrackHistoryAndDistanceDone:(AMapTrackQueryTrackHistoryAndDistanceRequest *)request response:(AMapTrackQueryTrackHistoryAndDistanceResponse *)response {
    NSMutableDictionary * resultData = [[NSMutableDictionary alloc] init];
    if (response.code == AMapTrackErrorOK) {
        // 这里之前有一个 convertHistoryTrack 方法，用来转换这个 response ，这里没有实现。 之前的swift代码放到了这个函数后面
        [resultData setValue:response forKey:@"historyTrack"];
        [channel invokeMethod:[trackTag stringByAppendingString:@"#onHistoryTrackCallback"] arguments:resultData];
    } else {
        [resultData setValue:[NSString stringWithFormat:@"%ld", (long)[response code]] forKey:@"errorCode"];
        [resultData setValue:[response info] forKey:@"errorMsg"];
        [resultData setValue:[response detail] forKey:@"errorDetail"];
        [channel invokeMethod:[trackTag stringByAppendingString:@"#onHistoryTrackCallback#error"] arguments:resultData];
    }
}

//    func convertHistoryTrack(track: AMapTrackQueryTrackHistoryAndDistanceResponse?) -> Any {
//        if track == nil {
//            return NSNull()
//        }
//        var dict = [String: Any?]()
//        dict["count"] = track!.count
//        dict["distance"] = track!.distance
//        dict["startPoint"] = convertPoint(point: track!.startPoint)
//        dict["endPoint"] = convertPoint(point: track!.endPoint)
//        var pList = [Any]()
//        if track!.points != nil {
//            for p in track!.points {
//                pList.append(convertPoint(point: p))
//            }
//        }
//        dict["points"] = pList
//
//        return dict
//    }

- (void)onQueryTrackInfoDone:(AMapTrackQueryTrackInfoRequest *)request response:(AMapTrackQueryTrackInfoResponse *)response {
    NSMutableDictionary * resultData = [[NSMutableDictionary alloc] init];
    if (response.code == AMapTrackErrorOK) {
        [resultData setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[response counts]] forKey:@"historyTrack"];
        NSMutableArray *trackList = [[NSMutableArray alloc] init];
        if ([response tracks] != nil) {
            for (AMapTrackBasicTrack *track in [response tracks]) {
                // 这里之前有一个 convertTrack 方法，用来转换这个 track ，这里没有实现。 之前的swift代码放到了这个函数后面
                [trackList addObject:track];
            }
        }
        [resultData setValue:trackList forKey:@"tracks"];
        [channel invokeMethod:[trackTag stringByAppendingString:@"#onQueryTrackCallback"] arguments:resultData];
    } else {
        [resultData setValue:[NSString stringWithFormat:@"%ld", (long)[response code]] forKey:@"errorCode"];
        [resultData setValue:[response info] forKey:@"errorMsg"];
        [resultData setValue:[response detail] forKey:@"errorDetail"];
        [channel invokeMethod:[trackTag stringByAppendingString:@"#onQueryTrackCallback#error"] arguments:resultData];
    }
}

//    func convertTrack(track: AMapTrackBasicTrack?) -> Any {
//        if track == nil {
//            return NSNull()
//        }
//        var dict = [String: Any?]()
//        dict["count"] = track!.counts
//        dict["distance"] = track!.distance
//        dict["trid"] = Int(track!.trackID)
//        dict["startPoint"] = convertPoint(point: track!.startPoint)
//        dict["endPoint"] = convertPoint(point: track!.endPoint)
//        var pList = [Any]()
//        for p in track!.points {
//            pList.append(convertPoint(point: p))
//        }
//        dict["points"] = pList
//        dict["lastingTime"] = track!.lastingTime
//
//        return dict
//    }


// lifecycle

NSString *lifecycleTag = @"OnTrackLifecycleListener";

- (void)onStartService:(AMapTrackErrorCode)errorCode {
    NSMutableDictionary * resultData = [[NSMutableDictionary alloc] init];
    if (errorCode == AMapTrackErrorOK) {
        [resultData setValue:[NSString stringWithFormat:@"%ld", (long)errorCode] forKey:@"status"];
        [resultData setValue:@"轨迹同步 启动成功" forKey:@"message"];
        [channel invokeMethod:[lifecycleTag stringByAppendingString:@"#onStartTrackCallback"] arguments:resultData];
    } else {
        [resultData setValue:[NSString stringWithFormat:@"%ld", (long)errorCode] forKey:@"errorCode"];
        [channel invokeMethod:[lifecycleTag stringByAppendingString:@"#onParamErrorCallback#error"] arguments:resultData];
    }
}

- (void)onStopService:(AMapTrackErrorCode)errorCode {
    NSMutableDictionary * resultData = [[NSMutableDictionary alloc] init];
    if (errorCode == AMapTrackErrorOK) {
        [resultData setValue:[NSString stringWithFormat:@"%ld", (long)errorCode] forKey:@"status"];
        [resultData setValue:@"轨迹同步 停止成功" forKey:@"message"];
        [channel invokeMethod:[lifecycleTag stringByAppendingString:@"#onStopTrackCallback"] arguments:resultData];
    } else {
        [resultData setValue:[NSString stringWithFormat:@"%ld", (long)errorCode] forKey:@"errorCode"];
        [channel invokeMethod:[lifecycleTag stringByAppendingString:@"#onParamErrorCallback#error"] arguments:resultData];
    }
}

- (void)onStartGatherAndPack:(AMapTrackErrorCode)errorCode {
    NSMutableDictionary * resultData = [[NSMutableDictionary alloc] init];
    if (errorCode == AMapTrackErrorOK) {
        [resultData setValue:[NSString stringWithFormat:@"%ld", (long)errorCode] forKey:@"status"];
        [resultData setValue:@"定位采集 启动成功" forKey:@"message"];
        [channel invokeMethod:[lifecycleTag stringByAppendingString:@"#onStartGatherCallback"] arguments:resultData];
    } else {
        [resultData setValue:[NSString stringWithFormat:@"%ld", (long)errorCode] forKey:@"errorCode"];
        [channel invokeMethod:[lifecycleTag stringByAppendingString:@"#onParamErrorCallback#error"] arguments:resultData];
    }
}

- (void)onStopGatherAndPack:(AMapTrackErrorCode)errorCode errorMessage:(nullable NSString *)errorMessage {
    NSMutableDictionary * resultData = [[NSMutableDictionary alloc] init];
    if (errorCode == AMapTrackErrorOK) {
        [resultData setValue:[NSString stringWithFormat:@"%ld", (long)errorCode] forKey:@"status"];
        [resultData setValue:@"定位采集 停止成功" forKey:@"message"];
        [channel invokeMethod:[lifecycleTag stringByAppendingString:@"#onStopGatherCallback"] arguments:resultData];
    } else {
        [resultData setValue:[NSString stringWithFormat:@"%ld", (long)errorCode] forKey:@"errorCode"];
        [resultData setValue:[NSString stringWithFormat:@"%@", errorMessage] forKey:@"errorMsg"];
        [channel invokeMethod:[lifecycleTag stringByAppendingString:@"#onParamErrorCallback#error"] arguments:resultData];
    }
}

@end
