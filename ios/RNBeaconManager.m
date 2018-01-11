//
//  RNBeaconManager.m
//  RNEstimote
//
//  Created by lhmt on 19/12/17.
//  Copyright © 2017 lhmt. All rights reserved.
//

#import "RNBeaconManager.h"
#import "EstimoteSDK/EstimoteSDK.h"
#import <React/RCTConvert.h>
#import "RNBeaconManagerExtension.h"

static NSString * const BEACON_DID_RANGE = @"BEACON_DID_RANGE";

@implementation RNBeaconManager
RCT_EXPORT_MODULE(RNEstimoteBeaconManager)

- (NSArray<NSString *> *)supportedEvents
{
    return @[BEACON_DID_RANGE];
}

-(instancetype)init{

    if (self = [super init]) {
        self = [super init];
        
        self.beaconManager = [ESTBeaconManager new];
        self.beaconManager.delegate = self;
        
        self.locationManager = [[CLLocationManager alloc] init];
        
        self.locationManager.delegate = self;
        self.locationManager.pausesLocationUpdatesAutomatically = NO;
        self.dropEmptyRanges = NO;
    }
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

RCT_EXPORT_METHOD(startEstimoteRangingBeaconsInRegion:(NSDictionary *) dict)
{
    NSLog(@"Start Ranging");
    CLBeaconRegion *region = [self convertDictToBeaconRegion:dict];
    [self.beaconManager startRangingBeaconsInRegion:region];
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

// Use CLLocation iBeacon ranging because Estimote Beacon is not reliable with RN
RCT_EXPORT_METHOD(startRangingBeaconsInRegion:(NSDictionary *) dict)
{
    [self.locationManager startRangingBeaconsInRegion:[self convertDictToBeaconRegion:dict]];
}

- (void)beaconManager:(id)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region {
    int count = (int)beacons.count;
    NSLog(@"Did range beacon");
    for (int i=0;i<count;i++){
        CLBeacon *beacon = beacons[i];
        NSLog(@"%@",beacon);
    }
    [self sendEventWithName:BEACON_DID_RANGE body:beacons];
}

- (void)beaconManager:(id)manager didEnterRegion:(CLBeaconRegion *)region{
    
}

- (void)beaconManager:(id)manager didExitRegion:(CLBeaconRegion *)region{
    
}

-(void)beaconManager:(id)manager didFailWithError:(NSError *)error{
    
}

-(NSString *)stringForProximity:(CLProximity)proximity {
    switch (proximity) {
        case CLProximityUnknown:    return @"unknown";
        case CLProximityFar:        return @"far";
        case CLProximityNear:       return @"near";
        case CLProximityImmediate:  return @"immediate";
        default:                    return @"";
    }
}

-(void) locationManager:(CLLocationManager *)manager didRangeBeacons:
(NSArray *)beacons inRegion:(CLBeaconRegion *)region
{
    if (self.dropEmptyRanges && beacons.count == 0) {
        return;
    }
    NSMutableArray *beaconArray = [[NSMutableArray alloc] init];
    
    for (CLBeacon *beacon in beacons) {
        [beaconArray addObject:@{
                                 @"uuid": [beacon.proximityUUID UUIDString],
                                 @"major": beacon.major,
                                 @"minor": beacon.minor,
                                 
                                 @"rssi": [NSNumber numberWithLong:beacon.rssi],
                                 @"proximity": [self stringForProximity: beacon.proximity],
                                 @"accuracy": [NSNumber numberWithDouble: beacon.accuracy]
                                 }];
    }
    
    NSDictionary *event = @{
                            @"region": @{
                                    @"identifier": region.identifier,
                                    @"uuid": [region.proximityUUID UUIDString],
                                    },
                            @"beacons": beaconArray
                            };
    NSLog(@"BeaconDidRange: %@",beacons);
    [self sendEventWithName:BEACON_DID_RANGE body:event];
}
@end

