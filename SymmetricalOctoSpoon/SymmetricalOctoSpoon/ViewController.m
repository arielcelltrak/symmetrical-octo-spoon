//
//  ViewController.m
//  SymmetricalOctoSpoon
//
//  Created by Ariel Rodriguez on 02/11/2022.
//

#import "LocationManager.h"
#import "Region.h"
#import "ViewController.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UILabel *regionLabel;

- (IBAction)startMonitoringRegion:(id)sender;
@end

@implementation ViewController
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)loadRegionIfAvailable {
    NSUserDefaults *sud = [NSUserDefaults standardUserDefaults];
    NSData *data = [sud objectForKey:kRegionKey];
    if (data == nil) {
        [[self regionLabel] setText:nil];
        return;
    }
    Region *region = [NSKeyedUnarchiver unarchivedObjectOfClass:[Region class]
                                                       fromData:data
                                                          error:nil];
    [[self regionLabel] setText:[region asString]];
    [sud removeObjectForKey:kRegionKey];
    [sud synchronize];
}

- (void)handleEnterForegroundNotification {
    [self loadRegionIfAvailable];
}

- (void)handleLeavesRegionNotification {
    [self loadRegionIfAvailable];
}

- (void)handleIncorrectAuthorization {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Please authorize the location services"
                                                                   message:@"We need to be notified about location changes even in the background."
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * _Nonnull action) {
        NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        [[UIApplication sharedApplication] openURL:url
                                           options:@{}
                                 completionHandler:nil];
    }];
    [alert addAction:okAction];
    [self presentViewController:alert
                       animated:YES
                     completion:nil];
}

- (void)setupNotifications {
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self
                           selector:@selector(handleEnterForegroundNotification)
                               name:UIApplicationWillEnterForegroundNotification
                             object:nil];
    [notificationCenter addObserver:self
                           selector:@selector(handleLeavesRegionNotification)
                               name:LocationManagerDidLeaveRegionNotification
                             object:nil];
    [notificationCenter addObserver:self
                           selector:@selector(handleIncorrectAuthorization)
                               name:LocationManagerCorrectAuthorizationNotGranted
                             object:nil];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self setupNotifications];
}

- (IBAction)startMonitoringRegion:(id)sender {
    BOOL success = [[LocationManager sharedManager] geofenceCurrentLocation];
    NSString *alertTitle;
    NSString *alertMessage;
    NSString *actionTitle = @"OK";
    if (success) {
        alertTitle = @"Monitoring Region";
        alertMessage = @"Let's find out when you leave this region";
    } else {
        alertTitle = @"No location";
        alertMessage = @"We don't know (yet) our current location";
    }
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:alertTitle
                                                                   message:alertMessage
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:actionTitle
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * _Nonnull action) {
        [self dismissViewControllerAnimated:YES
                                 completion:nil];
    }];
    [alert addAction:okAction];
    [self presentViewController:alert
                       animated:YES
                     completion:nil];
}
@end
