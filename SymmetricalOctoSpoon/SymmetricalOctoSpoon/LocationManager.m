//
//  LocationManager.m
//  SymmetricalOctoSpoon
//
//  Created by Ariel Rodriguez on 02/11/2022.
//

#import "LocationManager.h"
#import "Region.h"
#import <CoreLocation/CoreLocation.h>

@interface LocationManager ()
@property (nonnull, strong) CLLocationManager *locationManager;
@property (nullable, strong) CLLocation *currentLocation;
@end

@interface LocationManager (CLLocationManagerDelegate) <CLLocationManagerDelegate>

@end

@implementation LocationManager (CLLocationManagerDelegate)
- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray<CLLocation *> *)locations {
    [self setCurrentLocation:[locations lastObject]];
}

- (void)locationManager:(CLLocationManager *)manager
          didExitRegion:(CLRegion *)region {
    [manager stopMonitoringForRegion:region];
    NSUserDefaults *sud = [NSUserDefaults standardUserDefaults];
    NSDate *date = [NSDate date];
    Region *currentRegion = [[Region alloc] init];
    [currentRegion setRegion:region];
    [currentRegion setTimestamp:date];
    
    NSError *error;
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:currentRegion
                                         requiringSecureCoding:YES
                                                         error:&error];
    if (!data) {
        NSLog(@"%@", error);
        return;
    }
    [sud setObject:data
            forKey:@"region"];
    [sud synchronize];
}
@end

@implementation LocationManager
+ (id)sharedManager {
    static LocationManager *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

- (BOOL)geofenceCurrentLocation {
    if ([self currentLocation] == nil) {
        return NO;
    }
    CLLocationCoordinate2D center = [[self currentLocation] coordinate];
    CLCircularRegion *region = [[CLCircularRegion alloc] initWithCenter:center
                                                                 radius:50
                                                             identifier:[[NSProcessInfo processInfo] globallyUniqueString]];
    [region setNotifyOnExit:YES];
    [[self locationManager] startMonitoringForRegion:region];
    return YES;
}

- (id)init {
    self = [super init];
    if (self) {
        CLLocationManager *lm = [[CLLocationManager alloc] init];
        [lm setDesiredAccuracy:kCLLocationAccuracyBest];
        [lm setDistanceFilter:kCLDistanceFilterNone];
        [lm requestAlwaysAuthorization];
        [lm requestWhenInUseAuthorization];
        [lm setDelegate:self];
        [self setLocationManager:lm];
    }
    return self;
}

- (void)start {
    [[self locationManager] startUpdatingLocation];
}
@end
