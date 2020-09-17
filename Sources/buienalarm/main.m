//
//  main.m
//  LocaleIcon
//
//  Created by Pavel Mazurin on 09/12/2018.
//  Copyright © 2018 Pavel Mazurin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import <Carbon/Carbon.h>
#import <CoreLocation/CoreLocation.h>

#import "NSDictionary+CTSCommandLineArguments.h"
#import "NSImage+CTSBase64Representation.h"

#import "BuienalarmHelper.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        NSDictionary<NSString *, NSString *> * const dictionary =
        [NSDictionary cts_dictionaryWithCommandLineArguments:[NSProcessInfo processInfo].arguments];
        NSString * _Nullable const coordinateString = dictionary[@"coordinate"] ?: dictionary[@"c"];
        NSArray<NSString *> * const coordinateStringComponents = [coordinateString componentsSeparatedByString:@","];

        if ([coordinateStringComponents count] != 2) {
            fputs("Usage: ./buienalarm\n"
                  "  --coordinate=lat,lon, -c lat,lon\n"
                  "        The coordinate to fetch precipitation data for.\n",
                  stderr);
            return 1;
        }
        
        CLLocationCoordinate2D coordinate;
        coordinate.latitude = [coordinateStringComponents[0] doubleValue];
        coordinate.longitude = [coordinateStringComponents[1] doubleValue];

        BuienalarmHelper *buienalarmHelper = [[BuienalarmHelper alloc] init];
        [buienalarmHelper createImageForCoordinate:coordinate completionHandler:^(NSImage * _Nonnull resultImage) {
            NSString *base64 = [resultImage cts_base64Representation];
            printf("%s", [base64 UTF8String]);
        }];

        NSRunLoop * const runLoop = [NSRunLoop currentRunLoop];
        [runLoop addPort:[NSMachPort port] forMode:NSDefaultRunLoopMode];
        while (buienalarmHelper.isRunning) {
            [runLoop runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
        }
    }
    return 0;
}
