//
//  ObjFlutterAmapTrackPlugin.h
//  flutter_amap_track
//
//  Created by luna on 2021/10/24.
//

#ifndef ObjFlutterAmapTrackPlugin_h
#define ObjFlutterAmapTrackPlugin_h

#import <Flutter/Flutter.h>
#import <AMapFoundationKit/AMapFoundationKit.h>
#import <AMapTrackKit/AMapTrackKit.h>

@interface ObjFlutterAmapTrackPlugin : NSObject<FlutterPlugin, AMapTrackManagerDelegate>

+ (void)registerWithRegistrar:(nonnull NSObject<FlutterPluginRegistrar> *)registrar;
- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result;
- (void)amapTrackManager:(nonnull AMapTrackManager *)manager doRequireTemporaryFullAccuracyAuth:(nonnull CLLocationManager *)locationManager completion:(nonnull void (^)(NSError * _Nonnull))completion;
- (void)didFailWithError:(NSError *)error associatedRequest:(id)request;
- (void)onAddTerminalDone:(AMapTrackAddTerminalRequest *)request response:(AMapTrackAddTerminalResponse *)response;
- (void)onQueryTerminalDone:(AMapTrackQueryTerminalRequest *)request response:(AMapTrackQueryTerminalResponse *)response;
- (void)onAddTrackDone:(AMapTrackAddTrackRequest *)request response:(AMapTrackAddTrackResponse *)response;
- (void)onDeleteTrackDone:(AMapTrackDeleteTrackRequest *)request response:(AMapTrackBaseResponse *)response;
- (void)onQueryLastPointDone:(AMapTrackQueryLastPointRequest *)request response:(AMapTrackQueryLastPointResponse *)response;
- (void)onQueryTrackDistanceDone:(AMapTrackQueryTrackDistanceRequest *)request response:(AMapTrackQueryTrackDistanceResponse *)response;
- (void)onQueryTrackHistoryAndDistanceDone:(AMapTrackQueryTrackHistoryAndDistanceRequest *)request response:(AMapTrackQueryTrackHistoryAndDistanceResponse *)response;
- (void)onQueryTrackInfoDone:(AMapTrackQueryTrackInfoRequest *)request response:(AMapTrackQueryTrackInfoResponse *)response;
- (void)onStartService:(AMapTrackErrorCode)errorCode;
- (void)onStopService:(AMapTrackErrorCode)errorCode;
- (void)onStartGatherAndPack:(AMapTrackErrorCode)errorCode;
- (void)onStopGatherAndPack:(AMapTrackErrorCode)errorCode errorMessage:(nullable NSString *)errorMessage;

@end

#endif /* ObjFlutterAmapTrackPlugin_h */
