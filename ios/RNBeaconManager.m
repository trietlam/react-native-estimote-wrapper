//
//  RNBeaconManager.m
//  RNEstimote
//
//  Created by Admin on 19/12/17.
//  Copyright © 2017 Admin. All rights reserved.
//

#import "RNBeaconManager.h"
#import "EstimoteSDK/EstimoteSDK.h"
#import <React/RCTConvert.h>

@interface RNBeaconManager() <ESTBeaconManagerDelegate>

@property (nonatomic) ESTBeaconManager *beaconManager;
@property (nonatomic) CLBeaconRegion *beaconRegion;

@end

static NSString * const BEACON_DID_RANGE = @"BEACON_DID_RANGE";

@implementation RNBeaconManager
RCT_EXPORT_MODULE()

- (NSArray<NSString *> *)supportedEvents
{
    return @[BEACON_DID_RANGE];
}

-(instancetype)init{
    self = [super init];
    
    self.beaconManager = [ESTBeaconManager new];
    self.beaconManager.delegate = self;
    
    return self;
}

RCT_EXPORT_METHOD(requestAlwaysAuthorization){
    [self.beaconManager requestAlwaysAuthorization];
}

RCT_EXPORT_METHOD(requestWhenInUseAuthorization){
    [self.beaconManager requestWhenInUseAuthorization];
}

//RCT_EXPORT_METHOD(getAuthorizationStatus:(RCTResponseSenderBlock)callback)
//{
//    callback(@[[self nameForAuthorizationStatus:[CLLocationManager authorizationStatus]]]);
//}

RCT_EXPORT_METHOD(startMonitoringForRegion:(NSDictionary *) dict)
{
    [self.beaconManager startMonitoringForRegion:[self convertDictToBeaconRegion:dict]];
}

RCT_EXPORT_METHOD(startRangingBeaconsInRegion:(NSDictionary *) dict)
{
    [self.beaconManager startRangingBeaconsInRegion:[self convertDictToBeaconRegion:dict]];
}

RCT_EXPORT_METHOD(stopMonitoringForRegion:(NSDictionary *) dict)
{
    [self.beaconManager stopMonitoringForRegion:[self convertDictToBeaconRegion:dict]];
}

RCT_EXPORT_METHOD(stopRangingBeaconsInRegion:(NSDictionary *) dict)
{
    [self.beaconManager stopRangingBeaconsInRegion:[self convertDictToBeaconRegion:dict]];
}

-(CLBeaconRegion *) convertDictToBeaconRegion: (NSDictionary *) dict
{
    NSString *uuid = [RCTConvert NSString:dict[@"uuid"]];
    NSString *identifier = [RCTConvert NSString:dict[@"identifier"]];
    if (dict[@"minor"] == nil) {
        if (dict[@"major"] == nil) {
            return [[CLBeaconRegion alloc] initWithProximityUUID:
                    [[NSUUID alloc] initWithUUIDString:uuid] identifier:identifier];
        } else {
            return [[CLBeaconRegion alloc] initWithProximityUUID:
                    [[NSUUID alloc] initWithUUIDString:uuid]  major:[RCTConvert NSInteger:dict[@"major"]] identifier:identifier];
        }
    } else {
        return [[CLBeaconRegion alloc] initWithProximityUUID:
                [[NSUUID alloc] initWithUUIDString:uuid]
                                                       major:[RCTConvert NSInteger:dict[@"major"]]
                                                       minor: [RCTConvert NSInteger:dict[@"minor"]]
                                                  identifier:identifier];
    }
}

- (void)beaconManager:(id)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region {
    int count = (int)beacons.count;
    for (int i=0;i<count;i++){
        CLBeacon *beacon = beacons[i];
        //NSLog(@"%@",beacon);
    }
    [self sendEventWithName:BEACON_DID_RANGE body:beacons];
    //    CLBeacon *nearestBeacon = beacons.firstObject;
    //    if (nearestBeacon) {
    //        NSArray *places = [self placesNearBeacon:nearestBeacon];
    //        // TODO: update the UI here
    //        NSLog(@"%@", places); // TODO: remove after implementing the UI
    //    }
}

- (void)beaconManager:(id)manager didEnterRegion:(CLBeaconRegion *)region{
    
}

- (void)beaconManager:(id)manager didExitRegion:(CLBeaconRegion *)region{
    
}

-(void)beaconManager:(id)manager didFailWithError:(NSError *)error{
    
}
@end

