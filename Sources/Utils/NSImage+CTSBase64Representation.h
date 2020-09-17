//
//  NSImage+Base64.h
//  buienalarm
//
//  Created by Pavel Mazurin on 11/12/2018.
//  Copyright © 2018 CarbonTech Software LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSImage (CTSBase64Representation)

- (NSString *)cts_base64Representation;

@end

NS_ASSUME_NONNULL_END
