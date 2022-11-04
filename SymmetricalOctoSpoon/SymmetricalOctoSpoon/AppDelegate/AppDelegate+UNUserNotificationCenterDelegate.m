//
//  AppDelegate+UNUserNotificationCenterDelegate.m
//  SymmetricalOctoSpoon
//
//  Created by Ariel Rodriguez on 04/11/2022.
//

#import "AppDelegate+UNUserNotificationCenterDelegate.h"

@implementation AppDelegate (UNUserNotificationCenterDelegate)
- (void)registerNotifications {
    UNUserNotificationCenter *nc = [UNUserNotificationCenter currentNotificationCenter];
    UNAuthorizationOptions options = UNAuthorizationOptionSound | UNAuthorizationOptionBadge | UNAuthorizationOptionAlert;
    [nc requestAuthorizationWithOptions:options
                      completionHandler:^(BOOL granted, NSError * _Nullable error) {
        if (error != nil) {
            return;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UIApplication sharedApplication] registerForRemoteNotifications];
        });
    }];
    [nc setDelegate:self];
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center
       willPresentNotification:(UNNotification *)notification
         withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler {
    UNNotificationPresentationOptions options = UNNotificationPresentationOptionSound | UNNotificationPresentationOptionBadge | UNNotificationPresentationOptionList | UNNotificationPresentationOptionBanner;
    completionHandler(options);
}

- (void)scheduleNotification:(NSString *)alert {
    UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
    NSString *requestIdentifier = [[NSUUID UUID] UUIDString];
    
    [content setBadge:0];
    [content setTitle:@"Location Update"];
    [content setBody:alert];
    [content setSound:[UNNotificationSound defaultSound]];
    
    UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:1.0
                                                                                                    repeats:NO];
    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:requestIdentifier
                                                                          content:content
                                                                          trigger:trigger];
    [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:request
                                                           withCompletionHandler:nil];
}
@end
