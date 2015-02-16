//
//  SOLocationManager.m
//  Heat
//
//  Created by Artur Mkrtchyan on 12/19/13.
//  Copyright (c) 2013 Artur Mkrtchyan. All rights reserved.
//

#import "SOLocationManager.h"

@implementation SOLocationManager

- (id)init
{
    self = [super init];
    if (self)
    {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        self.locationManager.distanceFilter = kCLDistanceFilterNone;
        self.locationManager.delegate = self;
        self.locationType = LocationManagerTypeNone;
    }
    
    return self;
}

+ (SOLocationManager *)sharedInstance
{
    __strong static SOLocationManager* instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    
    return instance;
}

- (void)start
{
    [self.locationManager startUpdatingLocation];
    
    if (self.locationType == LocationManagerTypeNone)
    {
        self.locationType = LocationManagerTypeStandart;
    }
    else if (self.locationType == LocationManagerTypeSignificant)
    {
        self.locationType = LocationManagerTypeSignificant | LocationManagerTypeStandart;
    }
}
- (void)startSignificant
{
    [self.locationManager startMonitoringSignificantLocationChanges];
    
    if (self.locationType == LocationManagerTypeNone)
    {
        self.locationType = LocationManagerTypeSignificant;
    }
    else if (self.locationType == LocationManagerTypeStandart)
    {
        self.locationType = LocationManagerTypeStandart | LocationManagerTypeSignificant;
    }
}

- (void)stop
{
    [self.locationManager stopUpdatingLocation];
    
    if (self.locationType & LocationManagerTypeSignificant)
    {
        //leave only significant
        self.locationType = LocationManagerTypeSignificant;
    }
    else
    {
        self.locationType = LocationManagerTypeNone;
    }
}

- (void)stopSignificant
{
    [self.locationManager stopMonitoringSignificantLocationChanges];

    if (self.locationType & LocationManagerTypeStandart)
    {
        //leave only significant
        self.locationType = LocationManagerTypeStandart;
    }
    else
    {
        self.locationType = LocationManagerTypeNone;
    }
}

#pragma mark - CLLocatiomManager Delegaet
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *location = [locations lastObject];
    self.lastLocation = location;
    self.lastCoordinate = location.coordinate;
    [[NSNotificationCenter defaultCenter] postNotificationName:LOCATION_DID_CHANGED_NOTIFICATION object:location userInfo:@{@"location":location}];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    [[NSNotificationCenter defaultCenter] postNotificationName:LOCATION_DID_FAILED_NOTIFICATION object:error userInfo:@{@"error":error}];
}

@end
