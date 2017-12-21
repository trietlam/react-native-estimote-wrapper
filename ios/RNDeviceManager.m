//
//  RNEstimote.m
//  RNEstimote
//
//  Created by Admin on 18/12/17.
//  Copyright © 2017 Admin. All rights reserved.
//

#import "RNDeviceManager.h"
#import "EstimoteSDK/EstimoteSDK.h"
#import <React/RCTBridgeModule.h>
#import <React/RCTLog.h>

@interface RNDeviceManager() <ESTDeviceManagerDelegate>

@property (nonatomic) ESTDeviceManager *deviceManager;
@property (nonatomic) CLBeaconRegion *beaconRegion;

@end

static NSString * const TELEMETRY_RECEIVED = @"TELEMETRY_RECEIVED";
static NSString * const DEVICE_DISCOVERED = @"DEVICE_DISCOVERED";

@implementation RNDeviceManager
RCT_EXPORT_MODULE()

- (NSArray<NSString *> *)supportedEvents
{
    return @[TELEMETRY_RECEIVED,DEVICE_DISCOVERED];
}

-(instancetype)init{
    self = [super init];
    
    self.deviceManager = [ESTDeviceManager new];
    self.deviceManager.delegate = self;
    
    return self;
}

- (void)deviceManager:(ESTDeviceManager *)manager didDiscoverDevices:(NSArray<ESTDevice *> *)devices{
    int count = (int)devices.count;
    for (int i=0;i<count;i++){
        ESTDevice *device = devices[i];
    }
}

RCT_EXPORT_METHOD(startDiscoverDevices){
    //replace init with initWithIdentifier if required
    //ESTDeviceFilterLocationBeacon *filter = [[ESTDeviceFilterLocationBeacon alloc] initWithIdentifier:@"d4e2077dd7d7668ea44a421a9b333738"];
    ESTDeviceFilterLocationBeacon *filter = [[ESTDeviceFilterLocationBeacon alloc] init];
    
    [self.deviceManager startDeviceDiscoveryWithFilter:filter];
}

//RCT_EXPORT_METHOD(unregisterForTelemetryNotification){
//    [self.deviceManager unregisterForTelemetryNotification];
//}

RCT_EXPORT_METHOD(registerForTelemetryNotifications){
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
    
    ESTTelemetryNotificationTemperature *temperatureNotification = [[ESTTelemetryNotificationTemperature alloc] initWithNotificationBlock: tempTelemetryBlock];
    
    ESTTelemetryNotificationAmbientLight *lightNotification = [[ESTTelemetryNotificationAmbientLight alloc] initWithNotificationBlock:lightTelemetryBlock];
    
    ESTTelemetryNotificationSystemStatus *systemNotification = [[ESTTelemetryNotificationSystemStatus alloc]initWithNotificationBlock:systemTelemetryBlock];
    
    [self.deviceManager registerForTelemetryNotifications:(NSArray<ESTTelemetryNotificationProtocol>*)@[temperatureNotification,lightNotification, systemNotification]];
    
}


@end

