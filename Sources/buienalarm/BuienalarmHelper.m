//
//  BuienalarmHelper.m
//  buienalarm
//
//  Created by Pavel Mazurin on 11/12/2018.
//  Copyright © 2018 CarbonTech Software LLC. All rights reserved.
//

#import "BuienalarmHelper.h"
#import "NSDate+CTSUtils.h"
#import <Cocoa/Cocoa.h>

static NSString * const kBuienalarmURLTemplate =
@"https://cdn-secure.buienalarm.nl/api/3.4/forecast.php?lat=%.5f&lon=%.5f&region=nl&unit=mm/u";

#define RGB(r, g, b) \
    [NSColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1]
static CGFloat const kGraphWidth = 100;
static CGFloat const kGraphHeight = 30;

@implementation BuienalarmHelper

- (void)createImageForCoordinate:(CLLocationCoordinate2D)coordinate completionHandler:(void (^)(NSImage * _Nonnull))completionHandler {
    self.running = YES;
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[self createRequestURLWithCoordintate:coordinate]];
    
    [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSImage *resultImage = nil;
        if (!error) {
            if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
                NSError *jsonError;
                NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
                
                if (jsonError) { // Error Parsing JSON
                    resultImage = [self imageForError:jsonError];
                } else {
                    NSArray *precipitation = jsonResponse[@"precip"];
                    NSDictionary *levels = jsonResponse[@"levels"];
                    NSTimeInterval startTimestamp = [jsonResponse[@"start"] doubleValue];
                    resultImage = [self imageForPrecipitation:precipitation
                                                       levels:levels
                                               startTimestamp:startTimestamp];
                }
            }  else { // Web server is returning an error
                resultImage = [self imageForError:error];
            }
        } else { // Fail
            resultImage = [self imageForError:error];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            completionHandler(resultImage);
            self.running = NO;
        });
    }] resume];
}

- (NSURL *)createRequestURLWithCoordintate:(CLLocationCoordinate2D)coordinate {
    NSString *urlString = [NSString stringWithFormat:kBuienalarmURLTemplate, coordinate.latitude, coordinate.longitude];
    NSURL *result = [NSURL URLWithString:urlString];
    return result;
}

- (NSImage *) imageForError:(NSError *)error {
    NSImage *result = [[NSImage alloc] initWithSize:NSMakeSize(kGraphWidth, kGraphHeight)];
    [result lockFocus];
    {
        [self drawString:@"Error"];
    }
    [result unlockFocus];
    
    return result;
}

- (void) drawPrecipitationPath:(NSArray<NSNumber *> *)precipitation
                           max:(NSUInteger)max {
    [RGB(76, 178, 249) setFill];
    NSBezierPath *path = [NSBezierPath bezierPath];
    
    [path moveToPoint:NSZeroPoint];
    double step = kGraphWidth / (precipitation.count - 1);
    [precipitation enumerateObjectsUsingBlock:^(NSNumber * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        double x = idx * step;
        double y = [obj doubleValue] / max * kGraphHeight;
        [path lineToPoint:NSMakePoint(x, y)];
    }];
    [path lineToPoint:NSMakePoint(kGraphWidth, 0)];
    
    [path fill];
}

- (void) drawLineFrom:(NSPoint)from to:(NSPoint)to withColor:(NSColor *)color {
    [color setStroke];
    NSBezierPath *path = [NSBezierPath bezierPath];
    [path moveToPoint:from];
    [path lineToPoint:to];
    [path stroke];
}

- (void) drawGrid:(NSTimeInterval)startTimestamp {
    NSDate *startDate = [NSDate dateWithTimeIntervalSince1970:startTimestamp];
    NSTimeInterval currentTimestamp = [[NSDate date] timeIntervalSince1970];
    NSTimeInterval nextHourTimestamp = [[startDate cts_nextHourDate] timeIntervalSince1970];
    NSTimeInterval nextTwoHoursTimestamp = [[[startDate cts_nextHourDate] cts_nextHourDate] timeIntervalSince1970];

    // forecast is for 2 hours -  -  -  -  -  -  -  -  -  -  -  -  - v
    double nowPos = (currentTimestamp - startTimestamp) / (60 * 60 * 2) * kGraphWidth;

    double nextHourPos = (nextHourTimestamp - startTimestamp) / (60 * 60 * 2) * kGraphWidth;
    double nextTwoHourPos = (nextTwoHoursTimestamp - startTimestamp) / (60 * 60 * 2) * kGraphWidth;
    
    [self drawLineFrom:NSMakePoint(0, 0) to:NSMakePoint(kGraphWidth, 0) withColor:RGB(101, 100, 100)];
    [self drawLineFrom:NSMakePoint(nowPos, 0) to:NSMakePoint(nowPos, kGraphHeight) withColor:RGB(180, 100, 121)];
    [self drawLineFrom:NSMakePoint(nextHourPos, 0) to:NSMakePoint(nextHourPos, kGraphHeight) withColor:RGB(101, 100, 100)];
    [self drawLineFrom:NSMakePoint(nextTwoHourPos, 0) to:NSMakePoint(nextTwoHourPos, kGraphHeight) withColor:RGB(101, 100, 100)];
}

- (void) drawString:(NSString *)string {
    NSDictionary *attrs = @{ NSFontAttributeName: [NSFont systemFontOfSize:13],
                             NSForegroundColorAttributeName: RGB(127, 128, 128) };
    CGSize noPrecipSize = [string sizeWithAttributes:attrs];
    [string drawAtPoint:NSMakePoint((kGraphWidth - noPrecipSize.width) / 2,
                                    (kGraphHeight - noPrecipSize.height) / 2)
                 withAttributes:attrs];
}


- (NSImage *) imageForPrecipitation:(NSArray<NSNumber *> *)precipitation
                             levels:(NSDictionary<NSString *, NSNumber*> *)levels
                     startTimestamp:(NSTimeInterval)startTimestamp {
    NSImage *result = [[NSImage alloc] initWithSize:NSMakeSize(kGraphWidth, kGraphHeight)];
    double heavy = [levels[@"heavy"] doubleValue];
    double max = [[precipitation valueForKeyPath:@"@max.doubleValue"] doubleValue];
    [result lockFocus];
    {
        if (max == 0) {
            [self drawString:@"No precipitation"];
        } else {
            max = MAX(max, heavy + 1);

            [self drawPrecipitationPath:precipitation max:max];
            [self drawGrid:startTimestamp];

            double heavyY = heavy / max * kGraphHeight;
            [self drawLineFrom:NSMakePoint(0, heavyY) to:NSMakePoint(kGraphWidth, heavyY) withColor:RGB(90, 122, 173)];
        }
    }
    [result unlockFocus];
    
    return result;
}

@end
