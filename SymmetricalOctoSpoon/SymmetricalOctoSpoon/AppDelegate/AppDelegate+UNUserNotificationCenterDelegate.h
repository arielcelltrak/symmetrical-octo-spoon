//
//  AppDelegate+UNUserNotificationCenterDelegate.h
//  SymmetricalOctoSpoon
//
//  Created by Ariel Rodriguez on 04/11/2022.
//

#import "AppDelegate.h"
#import <UserNotifications/UserNotifications.h>

NS_ASSUME_NONNULL_BEGIN

@interface AppDelegate (UNUserNotificationCenterDelegate) <UNUserNotificationCenterDelegate>
- (void)registerNotifications;
- (void)scheduleNotification:(NSString *)alert;
@end

NS_ASSUME_NONNULL_END
