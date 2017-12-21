#import "RNNearableManager.h"

#import <EstimoteSDK/EstimoteSDK.h>

#import <React/RCTBridgeModule.h>
#import <React/RCTLog.h>
#import <React/RCTEventEmitter.h>
#import <React/RCTEventDispatcher.h>

@interface RNNearableManager() <ESTNearableManagerDelegate>

#if TARGET_IPHONE_SIMULATOR
@property (nonatomic, strong) ESTSimulatedNearableManager *nearableManager;
#else
@property (nonatomic, strong) ESTNearableManager *nearableManager;
#endif

@end

@implementation RNNearableManager

RCT_EXPORT_MODULE()

@synthesize bridge = _bridge;

#pragma mark Initialization

- (instancetype)init
{
    if (self = [super init]) {
#if TARGET_IPHONE_SIMULATOR
        self.nearableManager = [ESTSimulatedNearableManager new];
#else
        self.nearableManager = [ESTNearableManager new];
#endif
        self.nearableManager.delegate = self;
    }
    return self;
}

#pragma mark Exposed React Functions - Simulation

RCT_EXPORT_METHOD(addNearableToSimulation:(NSString *)identifier type:(NSInteger)type zone:(NSInteger)zone rssi:(NSInteger)rssi)
{
#if TARGET_IPHONE_SIMULATOR
    RCTLogInfo(@"addNearableToSimulation %@ %@ %@ %ld", identifier, [self nameForNearableType:(ESTNearableType)type], [self nameForNearableZone:zone], (long)rssi);
    [self.nearableManager addNearableToSimulation:identifier withType:(ESTNearableType)type zone:(ESTNearableZone)zone rssi: rssi];
#endif
}

RCT_EXPORT_METHOD(simulateZoneForNearable:(NSString *)identifier zone:(NSInteger)zone)
{
#if TARGET_IPHONE_SIMULATOR
    RCTLogInfo(@"simulateZoneForNearable %@ %@", identifier, [self nameForNearableZone:zone]);
    [self.nearableManager simulateZone:(ESTNearableZone)zone forNearable:identifier];
#endif
}

RCT_EXPORT_METHOD(simulateDidEnterRegionForNearable:(NSString *)identifier)
{
#if TARGET_IPHONE_SIMULATOR
    RCTLogInfo(@"simulateDidEnterRegionForNearable %@", identifier);
    for (ESTNearable *nearable in self.nearableManager.nearables){
        if([nearable.identifier isEqualToString:identifier]){
            [self.nearableManager simulateDidEnterRegionForNearable:nearable];
        }
    }
#endif
}

RCT_EXPORT_METHOD(simulateDidExitRegionForNearable:(NSString *)identifier)
{
#if TARGET_IPHONE_SIMULATOR
    RCTLogInfo(@"simulateDidExitRegionForNearable %@", identifier);
    for (ESTNearable *nearable in self.nearableManager.nearables){
        if([nearable.identifier isEqualToString:identifier]){
            [self.nearableManager simulateDidExitRegionForNearable:nearable];
        }
    }
#endif
}

#pragma mark Exposed React - Monitoring related methods

RCT_EXPORT_METHOD(startMonitoringForIdentifier:(NSString *)identifier)
{
    RCTLogInfo(@"startMonitoringForIdentifier %@", identifier);
    [self.nearableManager startMonitoringForIdentifier:identifier];
}

RCT_EXPORT_METHOD(stopMonitoringForIdentifier:(NSString *)identifier)
{
    RCTLogInfo(@"stopMonitoringForIdentifier %@", identifier);
    [self.nearableManager stopMonitoringForIdentifier:identifier];
}

RCT_EXPORT_METHOD(startMonitoringForType:(NSInteger)type)
{
    RCTLogInfo(@"startMonitoringForType %@", [self nameForNearableType:(ESTNearableType)type]);
    [self.nearableManager startMonitoringForType:(ESTNearableType)type];
}

RCT_EXPORT_METHOD(stopMonitoringForType:(NSInteger)type)
{
    RCTLogInfo(@"stopMonitoringForType %@", [self nameForNearableType:(ESTNearableType)type]);
    [self.nearableManager stopMonitoringForType:(ESTNearableType)type];
}

RCT_EXPORT_METHOD(stopMonitoring)
{
    RCTLogInfo(@"stopMonitoring");
    [self.nearableManager stopMonitoring];
}

#pragma mark Exposed React - Ranging related methods

RCT_EXPORT_METHOD(startRangingForIdentifier:(NSString *)identifier)
{
    RCTLogInfo(@"startRangingForIdentifier %@", identifier);
    [self.nearableManager startRangingForIdentifier:identifier];
}

RCT_EXPORT_METHOD(stopRangingForIdentifier:(NSString *)identifier)
{
    RCTLogInfo(@"stopRangingForIdentifier %@", identifier);
    [self.nearableManager stopRangingForIdentifier:identifier];
}

RCT_EXPORT_METHOD(startRangingForType:(NSInteger)type)
{
    RCTLogInfo(@"startRangingForType %@", [self nameForNearableType:(ESTNearableType)type]);
    [self.nearableManager startRangingForType:(ESTNearableType)type];
}

RCT_EXPORT_METHOD(stopRangingForType:(NSInteger)type)
{
    RCTLogInfo(@"stopRangingForType %@", [self nameForNearableType:(ESTNearableType)type]);
    [self.nearableManager stopRangingForType:(ESTNearableType)type];
}

RCT_EXPORT_METHOD(stopRanging)
{
    RCTLogInfo(@"stopRanging");
    [self.nearableManager stopRanging];
}


#pragma mark Dispatched React - Ranging delegates

- (void)nearableManager:(ESTNearableManager *)manager
      didRangeNearables:(NSArray *)nearables
               withType:(ESTNearableType)type
{
    RCTLogInfo(@"didRangeNearables %@", [self nameForNearableType:type]);
    
    NSMutableArray *nearableArray = [NSMutableArray new];
    for (ESTNearable *nearable in nearables){
        RCTLogInfo(@"%@ %@ %@ %ld", nearable.identifier, [self nameForNearableType:nearable.type], [self nameForNearableZone:nearable.zone], (long)nearable.rssi);
        [nearableArray addObject:[self dictionaryForNearable:nearable]];
    }
    
    NSDictionary *event = @{
                            @"nearables": nearableArray,
                            @"type": [self nameForNearableType:type]
                            };
    
    [self.bridge.eventDispatcher sendDeviceEventWithName:@"didRangeNearables" body:event];
}

- (void)nearableManager:(ESTNearableManager *)manager didRangeNearable:(ESTNearable *)nearable
{
    RCTLogInfo(@"didRangeNearable %@", nearable);
    NSDictionary *event = @{
                            @"nearable": [self dictionaryForNearable:nearable]
                            };
    
    [self.bridge.eventDispatcher sendDeviceEventWithName:@"didRangeNearable" body:event];
}

- (void)nearableManager:(ESTNearableManager *)manager rangingFailedWithError:(NSError *)error
{
    RCTLogInfo(@"rangingFailedWithError %@", error);
    NSDictionary *event = @{
                            @"error": error.localizedDescription
                            };
    
    [self.bridge.eventDispatcher sendDeviceEventWithName:@"rangingFailedWithError" body:event];
}

#pragma mark Dispatched React - Monitoring delegates

- (void)nearableManager:(ESTNearableManager *)manager didEnterTypeRegion:(ESTNearableType)type
{
    RCTLogInfo(@"didEnterTypeRegion %@", [self nameForNearableType:type]);
    NSDictionary *event = @{
                            @"type": [self nameForNearableType:type]
                            };
    
    [self.bridge.eventDispatcher sendDeviceEventWithName:@"didEnterTypeRegion" body:event];
}

- (void)nearableManager:(ESTNearableManager *)manager didExitTypeRegion:(ESTNearableType)type
{
    RCTLogInfo(@"didExitTypeRegion %@", [self nameForNearableType:type]);
    NSDictionary *event = @{
                            @"type": [self nameForNearableType:type]
                            };
    
    [self.bridge.eventDispatcher sendDeviceEventWithName:@"didExitTypeRegion" body:event];
}

- (void)nearableManager:(ESTNearableManager *)manager didEnterIdentifierRegion:(NSString *)identifier
{
    RCTLogInfo(@"didEnterIdentifierRegion %@", identifier);
    NSDictionary *event = @{
                            @"identifier": identifier
                            };
    
    [self.bridge.eventDispatcher sendDeviceEventWithName:@"didEnterIdentifierRegion" body:event];
}

- (void)nearableManager:(ESTNearableManager *)manager didExitIdentifierRegion:(NSString *)identifier
{
    RCTLogInfo(@"didExitIdentifierRegion %@", identifier);
    NSDictionary *event = @{
                            @"identifier": identifier
                            };
    
    [self.bridge.eventDispatcher sendDeviceEventWithName:@"didExitIdentifierRegion" body:event];
}

- (void)nearableManager:(ESTNearableManager *)manager monitoringFailedWithError:(NSError *)error
{
    RCTLogInfo(@"monitoringFailedWithError %@", error);
    NSDictionary *event = @{
                            @"error": error.localizedDescription
                            };
    
    [self.bridge.eventDispatcher sendDeviceEventWithName:@"monitoringFailedWithError" body:event];
}

#pragma mark Helpers - Enum Name Translations

-(NSString *)nameForNearableType:(ESTNearableType)type{
    switch (type) {
        case ESTNearableTypeUnknown:
            return @"ESTNearableTypeUnknown";
            
        case ESTNearableTypeDog:
            return @"ESTNearableTypeDog";
            
        case ESTNearableTypeCar:
            return @"ESTNearableTypeCar";
            
        case ESTNearableTypeFridge:
            return @"ESTNearableTypeFridge";
            
        case ESTNearableTypeBag:
            return @"ESTNearableTypeBag";
            
        case ESTNearableTypeBike:
            return @"ESTNearableTypeBike";
            
        case ESTNearableTypeChair:
            return @"ESTNearableTypeChair";
            
        case ESTNearableTypeBed:
            return @"ESTNearableTypeBed";
            
        case ESTNearableTypeDoor:
            return @"ESTNearableTypeDoor";
            
        case ESTNearableTypeShoe:
            return @"ESTNearableTypeShoe";
            
        case ESTNearableTypeGeneric:
            return @"ESTNearableTypeGeneric";
            
        case ESTNearableTypeAll:
            return @"ESTNearableTypeAll";
    }
}

-(NSString *)nameForNearableZone:(ESTNearableZone)zone{
    switch (zone) {
        case ESTNearableZoneUnknown:
            return @"ESTNearableZoneUnknown";
            
        case ESTNearableZoneImmediate:
            return @"ESTNearableZoneImmediate";
            
        case ESTNearableZoneNear:
            return @"ESTNearableZoneNear";
            
        case ESTNearableZoneFar:
            return @"ESTNearableZoneFar";
    }
}

-(NSString *)nameForNearableOrientation:(ESTNearableOrientation)orientation{
    switch (orientation) {
        case ESTNearableOrientationUnknown:
            return @"ESTNearableOrientationUnknown";
            
        case ESTNearableOrientationHorizontal:
            return @"ESTNearableOrientationHorizontal";
            
        case ESTNearableOrientationHorizontalUpsideDown:
            return @"ESTNearableOrientationHorizontalUpsideDown";
            
        case ESTNearableOrientationVertical:
            return @"ESTNearableOrientationVertical";
            
        case ESTNearableOrientationVerticalUpsideDown:
            return @"ESTNearableOrientationVerticalUpsideDown";
            
        case ESTNearableOrientationLeftSide:
            return @"ESTNearableOrientationLeftSide";
            
        case ESTNearableOrientationRightSide:
            return @"ESTNearableOrientationRightSide";
    }
}


-(NSDictionary *)dictionaryForNearable:(ESTNearable*)nearable{
    return @{ @"identifier" : nearable.identifier, @"type" : [self nameForNearableType:nearable.type], @"zone" : [self nameForNearableZone:nearable.zone], @"rssi": [NSNumber numberWithLong:nearable.rssi] };
}

- (NSDictionary *)constantsToExport
{
    return @{
             @"ESTNearableTypeUnknown": [NSNumber numberWithInt:ESTNearableTypeUnknown],
             @"ESTNearableTypeDog": [NSNumber numberWithInt:ESTNearableTypeDog],
             @"ESTNearableTypeCar": [NSNumber numberWithInt:ESTNearableTypeCar],
             @"ESTNearableTypeFridge": [NSNumber numberWithInt:ESTNearableTypeFridge],
             @"ESTNearableTypeBag": [NSNumber numberWithInt:ESTNearableTypeBag],
             @"ESTNearableTypeBike": [NSNumber numberWithInt:ESTNearableTypeBike],
             @"ESTNearableTypeChair": [NSNumber numberWithInt:ESTNearableTypeChair],
             @"ESTNearableTypeBed": [NSNumber numberWithInt:ESTNearableTypeBed],
             @"ESTNearableTypeDoor": [NSNumber numberWithInt:ESTNearableTypeDoor],
             @"ESTNearableTypeShoe": [NSNumber numberWithInt:ESTNearableTypeShoe],
             @"ESTNearableTypeGeneric": [NSNumber numberWithInt:ESTNearableTypeGeneric],
             @"ESTNearableTypeAll": [NSNumber numberWithInt:ESTNearableTypeAll],
             
             /**
              *  Physical orientation of the device in 3D space.
              */
             // typedef NS_ENUM(NSInteger, ESTNearableOrientation)
             @"ESTNearableOrientationUnknown": [NSNumber numberWithInt:ESTNearableOrientationUnknown],
             @"ESTNearableOrientationHorizontal": [NSNumber numberWithInt:ESTNearableOrientationHorizontal],
             @"ESTNearableOrientationHorizontalUpsideDown": [NSNumber numberWithInt:ESTNearableOrientationHorizontalUpsideDown],
             @"ESTNearableOrientationVertical": [NSNumber numberWithInt:ESTNearableOrientationVertical],
             @"ESTNearableOrientationVerticalUpsideDown": [NSNumber numberWithInt:ESTNearableOrientationVerticalUpsideDown],
             @"ESTNearableOrientationLeftSide": [NSNumber numberWithInt:ESTNearableOrientationLeftSide],
             @"ESTNearableOrientationRightSide": [NSNumber numberWithInt:ESTNearableOrientationRightSide],
             
             /**
              *  Proximity zone related to distance from the device.
              */
             // typedef NS_ENUM(NSInteger, ESTNearableZone)
             @"ESTNearableZoneUnknown": [NSNumber numberWithInt:ESTNearableZoneUnknown],
             @"ESTNearableZoneImmediate": [NSNumber numberWithInt:ESTNearableZoneImmediate],
             @"ESTNearableZoneNear": [NSNumber numberWithInt:ESTNearableZoneNear],
             @"ESTNearableZoneFar": [NSNumber numberWithInt:ESTNearableZoneFar],
             
             /**
              *  Type of firmware running on the device.
              */
             // typedef NS_ENUM(NSInteger, ESTNearableFirmwareState)
             @"ESTNearableFirmwareStateBoot": [NSNumber numberWithInt:ESTNearableFirmwareStateBoot],
             @"ESTNearableFirmwareStateApp": [NSNumber numberWithInt:ESTNearableFirmwareStateApp]
             };
}

@end


