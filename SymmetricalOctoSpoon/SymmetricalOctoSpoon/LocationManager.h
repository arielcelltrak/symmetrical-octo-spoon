//
//  LocationManager.h
//  SymmetricalOctoSpoon
//
//  Created by Ariel Rodriguez on 02/11/2022.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LocationManager : NSObject
+ (id)sharedManager;
- (void)start;
- (BOOL)geofenceCurrentLocation;
@end

NS_ASSUME_NONNULL_END
