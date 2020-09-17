//
//  NSDate+CTSUtils.m
//  buienalarm
//
//  Created by Pavel Mazurin on 11/12/2018.
//  Copyright © 2018 CarbonTech Software LLC. All rights reserved.
//

#import "NSDate+CTSUtils.h"

@implementation NSDate (CTSUtils)

- (NSDate*) cts_nextHourDate {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *comps = [calendar components:NSCalendarUnitEra | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour
                                          fromDate:self];
    [comps setHour:[comps hour] + 1];
    return [calendar dateFromComponents:comps];
}

@end
