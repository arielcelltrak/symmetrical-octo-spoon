//
//  Region.h
//  SymmetricalOctoSpoon
//
//  Created by Ariel Rodriguez on 02/11/2022.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class CLRegion;

@interface Region : NSObject <NSSecureCoding>
@property (nonnull, nonatomic, strong) CLRegion *region;
@property (nonnull, nonatomic, strong) NSDate *timestamp;

- (NSString *)asString;
@end

NS_ASSUME_NONNULL_END
