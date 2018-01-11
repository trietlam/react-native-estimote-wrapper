//
//  RNBeaconManager+DeviceManager.m
//  RNEstimoteWrapper
//
//  Created by lhmt on 11/01/18.
//  Copyright © 2018 lhmt. All rights reserved.
//


#import <React/RCTBridgeModule.h>
#import <React/RCTLog.h>
#import "RNBeaconManager+DeviceManager.h"
#import "RNBeaconManagerExtension.h"

@implementation RNBeaconManager (DeviceManager)

static NSString * const TELEMETRY_RECEIVED = @"TELEMETRY_RECEIVED";
static NSString * const DEVICE_DISCOVERED = @"DEVICE_DISCOVERED";
static NSString * const BEACON_DID_RANGE = @"BEACON_DID_RANGE";

ESTTelemetryNotificationTemperature *_temperatureNotification;
ESTTelemetryNotificationAmbientLight *_lightNotification;
ESTTelemetryNotificationSystemStatus *_systemNotification;;

- (NSArray<NSString *> *)supportedEvents
{
    return @[TELEMETRY_RECEIVED,DEVICE_DISCOVERED, BEACON_DID_RANGE];
}

//-(instancetype)init{
//    if(self = [super init]){
//        self.deviceManager = [ESTDeviceManager new];
//        self.deviceManager.delegate = self;
//
//        self.beaconManager = [ESTBeaconManager new];
//        self.beaconManager.delegate = self;
//    }
//    return self;
//}

- (void)deviceManager:(ESTDeviceManager *)manager didDiscoverDevices:(NSArray<ESTDevice *> *)devices{
    //int count = (int)devices.count;
    NSLog(@"%@",devices);
    [self sendEventWithName:BEACON_DID_RANGE body:devices];
}

RCT_EXPORT_METHOD(startDiscoverDevices){
    //replace init with initWithIdentifier if required
    //ESTDeviceFilterLocationBeacon *filter = [[ESTDeviceFilterLocationBeacon alloc] initWithIdentifier:@"d4e2077dd7d7668ea44a421a9b333738"];
    ESTDeviceFilterLocationBeacon *filter = [[ESTDeviceFilterLocationBeacon alloc] init];
    
    [self.deviceManager startDeviceDiscoveryWithFilter:filter];
}

RCT_EXPORT_METHOD(startTelemetryListeningAndRanging:(NSDictionary *) dict){
    
    [self.deviceManager registerForTelemetryNotifications:(NSArray<ESTTelemetryNotificationProtocol>*)@[_temperatureNotification,_lightNotification]];    
    [self startRangingBeaconsInRegion:dict];
}



RCT_EXPORT_METHOD(unregisterForTelemetryNotification){
    [self.deviceManager unregisterForTelemetryNotification:(NSArray<ESTTelemetryNotificationProtocol>*)@[_temperatureNotification,_lightNotification]];
}

RCT_EXPORT_METHOD(configureTelemetryListener:(NSString*) appId andToken:(NSString*) appToken){
    self.deviceManager = [ESTDeviceManager new];
    self.deviceManager.delegate = self;
    
    void (^tempTelemetryBlock)(ESTTelemetryInfoTemperature*) = ^(ESTTelemetryInfoTemperature *tempInfo){
        NSLog(@"Temperature");
        [self sendEventWithName:TELEMETRY_RECEIVED body:@{@"shortId": tempInfo.shortIdentifier, @"temperature":tempInfo.temperatureInCelsius}];
        
    };
    
    void (^lightTelemetryBlock)(ESTTelemetryInfoAmbientLight*) = ^(ESTTelemetryInfoAmbientLight *lightInfo){
        NSLog(@"Light");
        [self sendEventWithName:TELEMETRY_RECEIVED body:@{@"shortId": lightInfo.shortIdentifier, @"light":lightInfo.ambientLightLevelInLux}];
        
    };
    
    void(^systemTelemetryBlock)(ESTTelemetryInfoSystemStatus*) = ^(ESTTelemetryInfoSystemStatus *systemInfo){
        NSLog(@"System");
        [self sendEventWithName:TELEMETRY_RECEIVED body:@{@"shortId": systemInfo.shortIdentifier, @"uptime":systemInfo.uptimeInSeconds}];
    };
    
    _temperatureNotification = [[ESTTelemetryNotificationTemperature alloc] initWithNotificationBlock: tempTelemetryBlock];
    
    _lightNotification = [[ESTTelemetryNotificationAmbientLight alloc] initWithNotificationBlock:lightTelemetryBlock];
    
    _systemNotification = [[ESTTelemetryNotificationSystemStatus alloc]initWithNotificationBlock:systemTelemetryBlock];
    
}


@end


