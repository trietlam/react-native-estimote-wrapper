//
//  RNBeaconManagerExtension.h
//  RNEstimoteWrapper
//
//  Created by lhmt on 11/01/18.
//  Copyright © 2018 lhmt. All rights reserved.
//

#ifndef RNBeaconManagerExtension_h
#define RNBeaconManagerExtension_h

#import "RNBeaconManager.h"

@interface RNBeaconManager() <ESTBeaconManagerDelegate, CLLocationManagerDelegate>

@property (nonatomic) ESTBeaconManager *beaconManager;
@property (nonatomic) CLBeaconRegion *beaconRegion;
@property (nonatomic) ESTDeviceManager *deviceManager;

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (assign, nonatomic) BOOL dropEmptyRanges;

-(CLBeaconRegion *) convertDictToBeaconRegion: (NSDictionary *) dict;
-(void) startRangingBeaconsInRegion:(NSDictionary *) dict;
@end

#endif /* RNBeaconManagerExtension_h */

