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
    //判断为空
    if ([@"setIOSApiKey" isEqualToString:call.method]) {
        NSString* apiKey = params[@"apiKey"];
        NSLog(@"setIOSApiKey: %@", apiKey);
        if (![apiKey isKindOfClass:[NSNull class]]) {
            NSLog(@"apikey:\(apiKey!)");
            [AMapServices sharedServices].apiKey = apiKey;
        }
    } else if ([@"initWithServiceId" isEqualToString:call.method]) {
        NSString* sid_str = params[@"sid"];
        if (![sid_str isKindOfClass:[NSNull class]]) {
            int sid = [sid_str intValue];
            AMapTrackManagerOptions * option = [[AMapTrackManagerOptions alloc] init];
            [option setServiceID:[NSString stringWithFormat:@"%d", sid]];
            NSLog(@"%@", [@"sid: " stringByAppendingString:option.serviceID]);
            trackManager = [[AMapTrackManager alloc] initWithOptions:option];
            [trackManager setDelegate:self];
        }
    } else if ([@"setCacheSize" isEqualToString:call.method]) {
        NSString* cacheSize_str = params[@"cacheSize"];
        if (![cacheSize_str isKindOfClass:[NSNull class]]) {
            int cacheSize = [cacheSize_str intValue];
            [trackManager setLocalCacheMaxSize:cacheSize];
        }
    } else if ([@"setInterval" isEqualToString:call.method]) {
        NSString* gatherInterval_str = params[@"gatherInterval"];
        NSString* packInterval_str = params[@"packInterval"];
        if (![gatherInterval_str isKindOfClass:[NSNull class]] && ![packInterval_str isKindOfClass:[NSNull class]]) {
            int gatherInterval = [gatherInterval_str intValue];
            int packInterval = [packInterval_str intValue];
            [trackManager changeGatherAndPackTimeInterval:gatherInterval packTimeInterval:packInterval];
        }
    } else if ([@"setIOSOption" isEqualToString:call.method]) {
        bool allowsBackgroundLocationUpdates = params[@"allowsBackgroundLocationUpdates"];
        bool pausesLocationUpdatesAutomatically = params[@"pausesLocationUpdatesAutomatically"];
        if (allowsBackgroundLocationUpdates != nil) {
            [trackManager setAllowsBackgroundLocationUpdates:allowsBackgroundLocationUpdates];
        }
        if (pausesLocationUpdatesAutomatically != nil) {
            [trackManager setPausesLocationUpdatesAutomatically:pausesLocationUpdatesAutomatically];
        }
        NSString* activityType_str = params[@"activityType"];
        if (![activityType_str isKindOfClass:[NSNull class]]) {
            int activityType = [activityType_str intValue];
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
        NSString* sid_str = params[@"sid"];
        NSString* terminal = params[@"terminal"];
        NSString* terminalDesc = params[@"terminalDesc"];
        AMapTrackAddTerminalRequest *request = [[AMapTrackAddTerminalRequest alloc] init];
        if (![sid_str isKindOfClass:[NSNull class]]) {
            [request setServiceID:sid_str];
        }
        if (![terminal isKindOfClass:[NSNull class]]) {
            [request setTerminalName:terminal];
            if (![terminalDesc isKindOfClass:[NSNull class]]) {
                [request setTerminalDesc:terminalDesc];
            }
            [trackManager AMapTrackAddTerminal:request];
        }
    } else if ([@"queryTerminal" isEqualToString:call.method]) {
        NSString* sid_str = params[@"sid"];
        NSString* terminal = params[@"terminal"];
        NSString* terminalId_str = params[@"terminalId"];
        AMapTrackQueryTerminalRequest * request = [[AMapTrackQueryTerminalRequest alloc] init];
        if (![sid_str isKindOfClass:[NSNull class]]) {
            [request setServiceID:sid_str];
        }
        if (![terminal isKindOfClass:[NSNull class]]) {
            [request setTerminalName:terminal];
        }
        if (![terminalId_str isKindOfClass:[NSNull class]]) {
            [request setTerminalID:terminalId_str];
        }
        [trackManager AMapTrackQueryTerminal:request];
    } else if ([@"addTrack" isEqualToString:call.method]) {
        NSString* sid_str = params[@"sid"];
        NSString* tid_str = params[@"tid"];
        AMapTrackAddTrackRequest* request = [[AMapTrackAddTrackRequest alloc] init];
        if (![sid_str isKindOfClass:[NSNull class]]) {
            [request setServiceID:sid_str];
        }
        if (![tid_str isKindOfClass:[NSNull class]]) {
            [request setTerminalID:tid_str];
        }
        [trackManager AMapTrackAddTrack:request];
    } else if ([@"deleteTrack" isEqualToString:call.method]) {
        NSString* tid_str = params[@"tid"];
        NSString* trid_str = params[@"trid"];
        AMapTrackDeleteTrackRequest *request = [[AMapTrackDeleteTrackRequest alloc] init];
        if (![tid_str isKindOfClass:[NSNull class]] && ![trid_str isKindOfClass:[NSNull class]]) {
            [request setTerminalID:tid_str];
            [request setTrackID:trid_str];
        }
        [trackManager AMapTrackDeleteTrack:request];
    } else if ([@"startTrack" isEqualToString:call.method]) {
        NSString* tid_str = params[@"tid"];
        NSString* trackId_str = params[@"trackId"];
        AMapTrackManagerServiceOption * option = [[AMapTrackManagerServiceOption alloc] init];
        if (![tid_str isKindOfClass:[NSNull class]]) {
            [option setTerminalID:tid_str];
        }
        [trackManager startServiceWithOptions:option];
        if (![trackId_str isKindOfClass:[NSNull class]]) {
            [trackManager setTrackID:trackId_str];
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
        NSString* trackId_str = params[@"trackId"];
        if (![trackId_str isKindOfClass:[NSNull class]]) {
            [trackManager setTrackID:trackId_str];
        }
    } else if ([@"queryLatestPoint" isEqualToString:call.method]) {
        NSString* sid_str = params[@"sid"];
        NSString* tid_str = params[@"tid"];
        NSString* trid_str = params[@"trid"];
        NSString* correction_str = params[@"correction"];
        AMapTrackQueryLastPointRequest * request = [[AMapTrackQueryLastPointRequest alloc] init];
        if (![sid_str isKindOfClass:[NSNull class]]) {
            [request setServiceID:sid_str];
        }
        if (![tid_str isKindOfClass:[NSNull class]]) {
            [request setTerminalID:tid_str];
        }
        if (![trid_str isKindOfClass:[NSNull class]]) {
            [request setTrackID:trid_str];
        }
        NSString* correctionMode = @"n";
        if (![correction_str isKindOfClass:[NSNull class]] && [correction_str intValue] == 1) {
            correctionMode = @"driving";
        }
        [request setCorrectionMode:correctionMode];
        [trackManager AMapTrackQueryLastPoint:request];
    } else if ([@"queryDistance" isEqualToString:call.method]) {
        NSString* sid_str = params[@"sid"];
        NSString* tid_str = params[@"tid"];
        NSString* trid_str = params[@"trid"];
        NSString* startTime_str = params[@"startTime"];
        NSString* endTime_str = params[@"endTime"];
        NSString* correction_str = params[@"correction"];
        NSString* recoup_str = params[@"recoup"];
        NSString* gap_str = params[@"gap"];
        AMapTrackQueryTrackDistanceRequest * request = [[AMapTrackQueryTrackDistanceRequest alloc] init];
        if (![sid_str isKindOfClass:[NSNull class]]) {
            [request setServiceID:sid_str];
        }
        if (![tid_str isKindOfClass:[NSNull class]] && ![trid_str isKindOfClass:[NSNull class]] && ![startTime_str isKindOfClass:[NSNull class]] && ![endTime_str isKindOfClass:[NSNull class]]) {
            [request setTerminalID:tid_str];
            [request setTrackID:trid_str];
            [request setStartTime:[startTime_str longLongValue]];
            [request setEndTime:[endTime_str longLongValue]];
            NSString* correctionMode = @"n";
            if (![correction_str isKindOfClass:[NSNull class]] && [correction_str intValue] == 1) {
                correctionMode = @"driving";
            }
            [request setCorrectionMode:correctionMode];
            if (![recoup_str isKindOfClass:[NSNull class]] && [recoup_str intValue] == 1) {
                [request setRecoupMode:AMapTrackRecoupModeDriving];
            } else {
                [request setRecoupMode:AMapTrackRecoupModeNone];
            }
            NSUInteger uint_gap = [gap_str integerValue];
            [request setRecoupGap:uint_gap];
        }
        [trackManager AMapTrackQueryTrackDistance:request];
    } else if ([@"queryHistoryTrack" isEqualToString:call.method]) {
        NSString* sid_str = params[@"sid"];
        NSString* tid_str = params[@"tid"];
        NSString* startTime_str = params[@"startTime"];
        NSString* endTime_str = params[@"endTime"];
        NSString* correction_str = params[@"correction"];
        NSString* recoup_str = params[@"recoup"];
        NSString* gap_str = params[@"gap"];
        NSString* order_str = params[@"order"];
        NSString* page_str = params[@"page"];
        NSString* pageSize_str = params[@"pageSize"];
        AMapTrackQueryTrackHistoryAndDistanceRequest *request = [[AMapTrackQueryTrackHistoryAndDistanceRequest alloc] init];
        if (![sid_str isKindOfClass:[NSNull class]]) {
            [request setServiceID:sid_str];
        }
        if (![tid_str isKindOfClass:[NSNull class]]) {
            [request setTerminalID:tid_str];
        }
        if (![startTime_str isKindOfClass:[NSNull class]] && ![endTime_str isKindOfClass:[NSNull class]]) {
            [request setStartTime:[startTime_str longLongValue]];
            [request setEndTime:[endTime_str longLongValue]];
        }
        NSString* correctionMode = @"n";
        if (![correction_str isKindOfClass:[NSNull class]] && [correction_str intValue] == 1) {
            correctionMode = @"driving";
        }
        [request setCorrectionMode:correctionMode];
        if (![recoup_str isKindOfClass:[NSNull class]] && [recoup_str intValue] == 1) {
            [request setRecoupMode:AMapTrackRecoupModeDriving];
        }else{
            [request setRecoupMode:AMapTrackRecoupModeNone];
        }
        NSUInteger uint_gap = [gap_str integerValue];
        [request setRecoupGap:uint_gap];
        if (![order_str isKindOfClass:[NSNull class]]) {
            [request setSortType:[order_str intValue]];
        }
        if (![page_str isKindOfClass:[NSNull class]] && ![pageSize_str isKindOfClass:[NSNull class]]) {
            NSUInteger uint_page = [page_str integerValue];
            NSUInteger uint_pageSize = [pageSize_str integerValue];
            [request setPageIndex:uint_page];
            [request setPageSize:uint_pageSize];
        }
        [trackManager AMapTrackQueryTrackHistoryAndDistance:request];
    } else if ([@"queryTerminalTrack" isEqualToString:call.method]) {
        NSString* sid_str = params[@"sid"];
        NSString* tid_str = params[@"tid"];
        NSString* startTime_str = params[@"startTime"];
        NSString* endTime_str = params[@"endTime"];
        NSString* correction_str = params[@"correction"];
        NSString* recoup_str = params[@"recoup"];
        NSString* gap_str = params[@"gap"];
        bool ispoint = params[@"ispoint"];
        NSString* page_str = params[@"page"];
        NSString* pageSize_str = params[@"pageSize"];
        AMapTrackQueryTrackInfoRequest *request = [[AMapTrackQueryTrackInfoRequest alloc] init];
        if (![sid_str isKindOfClass:[NSNull class]]) {
            [request setServiceID:sid_str];
        }
        if (![tid_str isKindOfClass:[NSNull class]]) {
            [request setTerminalID:tid_str];
        }
        if (![startTime_str isKindOfClass:[NSNull class]] && ![endTime_str isKindOfClass:[NSNull class]]) {
            [request setStartTime:[startTime_str longLongValue]];
            [request setEndTime:[endTime_str longLongValue]];
        }
        NSString* correctionMode = @"n";
        if (![correction_str isKindOfClass:[NSNull class]] && [correction_str intValue] == 1) {
            correctionMode = @"driving";
        }
        [request setCorrectionMode:correctionMode];
        if (![recoup_str isKindOfClass:[NSNull class]] && [recoup_str intValue] == 1) {
            [request setRecoupMode:AMapTrackRecoupModeDriving];
        }else{
            [request setRecoupMode:AMapTrackRecoupModeNone];
        }
        if (![gap_str isKindOfClass:[NSNull class]]) {
            NSUInteger uint_gap = [gap_str integerValue];
            [request setRecoupGap:uint_gap];
        }
        if (ispoint != nil) {
            [request setContainPoints:ispoint];
        }
        if (![page_str isKindOfClass:[NSNull class]] && ![pageSize_str isKindOfClass:[NSNull class]]) {
            NSUInteger uint_page = [page_str integerValue];
            NSUInteger uint_pageSize = [pageSize_str intValue];
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

- (BOOL)isNotNullValue:(NSString*)key from:(NSDictionary<NSString*,id>*) params {
    id value = params[key];
    if (value == nil || [value isEqual:[NSNull null]]) {
        return NO;
    }
    return YES;
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
                [resultData setValue:[terminal tid] forKey:@"tid"];
                [resultData setValue:[terminal name] forKey:@"name"];
                [resultData setValue:[terminal desc] forKey:@"desc"];
                [resultData setValue:[NSString stringWithFormat:@"%lld", [terminal createTime]] forKey:@"createTime"];
                [resultData setValue:[NSString stringWithFormat:@"%lld", [terminal locateTime]] forKey:@"locateTime"];
                [list addObject:resultData];
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
