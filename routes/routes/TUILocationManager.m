//
//  TUILocationManager.m
//  decarta
//
//  Created by Diego Lafuente on 22/08/13.
//  Copyright (c) 2013 Tui Travel A&D. All rights reserved.
//

#import "TUILocationManager.h"
#import "config.h"

#pragma mark - Private interface
@interface TUILocationManager () <CLLocationManagerDelegate>

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong,nonatomic) NSUserDefaults *userDefaults;
@property (strong,nonatomic) NSMutableSet *delegates;

/**
 * Stores user locatiopn
 */
-(void)storeUserLocation:(CLLocation *)location;

/**
 * Calls all delegates' method locationReady with the current location
 */
-(void)callDelegatesWithLocation:(CLLocation *)location;

@end

#pragma mark - Implementation
@implementation TUILocationManager

#pragma mark - Public methods
+ (TUILocationManager *)sharedInstance
{
    static TUILocationManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[TUILocationManager alloc] init];
        // Do any other initialisation stuff here
    });
    return sharedInstance;
}

-(void)getUserLocation {
    [_locationManager startUpdatingLocation];
}

-(deCartaPosition *)getHomeLocation {
    return [[deCartaPosition alloc] initWithLat:DEF_LATITUDE andLon:DEF_LONGITUDE];
}

-(void)storeMapCenter:(CLLocation *)location {
    NSDictionary *locationToStore = @{@"latitude": [NSNumber numberWithDouble:location.coordinate.latitude],
                                      @"longitude": [NSNumber numberWithDouble:location.coordinate.longitude]};
    [_userDefaults setObject:locationToStore forKey:@"mapCenter"];
}

-(void)storeUserLocation:(CLLocation *)location {
    NSDictionary *locationToStore = @{@"latitude": [NSNumber numberWithDouble:location.coordinate.latitude],
                                      @"longitude": [NSNumber numberWithDouble:location.coordinate.longitude]};
    [_userDefaults setObject:locationToStore forKey:@"userLocation"];
}

-(float)getZoomLevel {
    float result = [_userDefaults floatForKey:@"zoomLevel"];
    if (result == 0) {
        result = DEF_ZOOM_LEVEL;
    }
    return result;
}

-(void)storeZoomLevel:(float)zoomLevel {
    [_userDefaults setFloat:zoomLevel forKey:@"zoomLevel"];
}

-(void)addDelegate:(id<TUILocationManagerDelegate>)delegate {
    [_delegates addObject:delegate];
}

#pragma mark - Private methods
-(void)callDelegatesWithLocation:(CLLocation *)location {
    for (id<TUILocationManagerDelegate> delegate in _delegates) {
        [delegate userLocationReady:location];
    }
    
}

#pragma mark - NSObject methods
-(TUILocationManager *)init {
    self = [super init];
    if (self) {
        _userDefaults = [NSUserDefaults standardUserDefaults];
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        _locationManager.distanceFilter = kCLDistanceFilterNone;
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        _delegates = [NSMutableSet set];
    }
    return self;
}

#pragma mark - CLLocationManagerDelegate Methods
- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations {
    [_locationManager stopUpdatingLocation];
    CLLocation *location = [locations lastObject];
    [self storeUserLocation:location];
    [self callDelegatesWithLocation:location];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    CLLocation *location = nil;
    //No location available, let's try usersDefault
    NSDictionary *locationStored = [_userDefaults objectForKey:@"userLocation"];
    if (locationStored) {
        location = [[CLLocation alloc] initWithLatitude:[locationStored[@"latitude"] doubleValue]
                                              longitude:[locationStored[@"longitude"] doubleValue]];
    } else {
        //No location stored, go to defaults
        location = [[CLLocation alloc] initWithLatitude:DEF_LATITUDE longitude:DEF_LONGITUDE];
    }
    [self callDelegatesWithLocation:location];
}

@end
