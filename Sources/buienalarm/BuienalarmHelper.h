//
//  BuienalarmHelper.h
//  buienalarm
//
//  Created by Pavel Mazurin on 11/12/2018.
//  Copyright © 2018 CarbonTech Software LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BuienalarmHelper : NSObject

@property (nonatomic, assign, getter = isRunning) BOOL running;
- (void) createImageForCoordinate:(CLLocationCoordinate2D)coordinate completionHandler:(void (^)(NSImage *))completionHandler;

@end

NS_ASSUME_NONNULL_END
