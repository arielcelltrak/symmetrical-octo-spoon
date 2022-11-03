//
//  Region.m
//  SymmetricalOctoSpoon
//
//  Created by Ariel Rodriguez on 02/11/2022.
//

#import "Region.h"
#import <CoreLocation/CoreLocation.h>

NSString * const kRegionKey = @"location";
NSString * const kRegionTimestampKey = @"timestamp";

@implementation Region
+ (BOOL)supportsSecureCoding {
    return YES;
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        CLRegion *region = [coder decodeObjectOfClass:[CLRegion class]
                                                   forKey:kRegionKey];
        NSDate *timestamp = [coder decodeObjectOfClass:[NSDate class]
                                                forKey:kRegionTimestampKey];
        if (region == nil || timestamp == nil) {
            return nil;
        }
        [self setRegion:region];
        [self setTimestamp:timestamp];
    }
    return self;
}

- (void)encodeWithCoder:(nonnull NSCoder *)coder {
    [coder encodeObject:[self region]
                 forKey:kRegionKey];
    [coder encodeObject:[self timestamp]
                 forKey:kRegionTimestampKey];
}

- (NSString *)asString {
    return [NSString stringWithFormat:@"Region: %@\n\n%@", [[self region] identifier], [self timestamp]];
}

@end
