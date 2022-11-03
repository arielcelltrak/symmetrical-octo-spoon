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
    NSData *data = [sud objectForKey:@"region"];
    if (data == nil) {
        [[self regionLabel] setText:nil];
        return;
    }
    Region *region = [NSKeyedUnarchiver unarchivedObjectOfClass:[Region class]
                                                       fromData:data
                                                          error:nil];
    [[self regionLabel] setText:[region asString]];
    [sud removeObjectForKey:@"region"];
    [sud synchronize];
}

- (void)handleEnterForegroundNotification {
    [self loadRegionIfAvailable];
}

- (void)setupNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleEnterForegroundNotification)
                                                 name:UIApplicationWillEnterForegroundNotification
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
