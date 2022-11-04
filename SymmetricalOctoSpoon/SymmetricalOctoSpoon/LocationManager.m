//
//  LocationManager.m
//  SymmetricalOctoSpoon
//
//  Created by Ariel Rodriguez on 02/11/2022.
//

#import "AppDelegate+UNUserNotificationCenterDelegate.h"
#import "LocationManager.h"
#import "Region.h"
#import <CoreLocation/CoreLocation.h>

NSNotificationName const LocationManagerDidLeaveRegionNotification = @"LocationManagerDidLeaveRegionNotification";
NSNotificationName const LocationManagerCorrectAuthorizationNotGranted = @"LocationManagerCorrectAuthorizationNotGranted";

@interface LocationManager ()
@property (nonnull, strong) CLLocationManager *locationManager;
@property (nullable, strong) CLLocation *currentLocation;
@end

@interface LocationManager (CLLocationManagerDelegate) <CLLocationManagerDelegate>

@end

@implementation LocationManager (CLLocationManagerDelegate)
- (void)propagateMessage:(NSString *)message {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate scheduleNotification:message];
}

- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray<CLLocation *> *)locations {
    [self setCurrentLocation:[locations lastObject]];
}

- (void)locationManagerDidChangeAuthorization:(CLLocationManager *)manager {
    if ([manager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways) {
        [manager startUpdatingLocation];
        return;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:LocationManagerCorrectAuthorizationNotGranted
                                                        object:nil];
}

- (void)locationManager:(CLLocationManager *)manager
          didExitRegion:(CLRegion *)region {
    [manager stopMonitoringForRegion:region];
    
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
    
    NSUserDefaults *sud = [NSUserDefaults standardUserDefaults];
    [sud setObject:data
            forKey:kRegionKey];
    [sud synchronize];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:LocationManagerDidLeaveRegionNotification
                                                        object:nil];
    [self propagateMessage:@"Leaving never easy"];
}

- (void)locationManager:(CLLocationManager *)manager
monitoringDidFailForRegion:(CLRegion *)region
              withError:(NSError *)error {
    [self propagateMessage:[error localizedDescription]];
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error {
    [self propagateMessage:[error localizedDescription]];
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
        [lm setAllowsBackgroundLocationUpdates:YES];
        [lm setDelegate:self];
        if ([lm authorizationStatus] != kCLAuthorizationStatusAuthorizedAlways) {
            [lm requestAlwaysAuthorization];
        }
        [self setLocationManager:lm];
    }
    return self;
}

- (void)start {
    CLLocationManager *lm = [self locationManager];
    if ([lm authorizationStatus] != kCLAuthorizationStatusAuthorizedAlways) {
        [lm requestAlwaysAuthorization];
        return;
    }
    [lm stopUpdatingLocation];
    [lm startUpdatingLocation];
}
@end
