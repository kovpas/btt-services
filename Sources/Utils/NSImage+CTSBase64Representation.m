//
//  NSImage+Base64.m
//  buienalarm
//
//  Created by Pavel Mazurin on 11/12/2018.
//  Copyright © 2018 CarbonTech Software LLC. All rights reserved.
//

#import "NSImage+CTSBase64Representation.h"

NS_ASSUME_NONNULL_BEGIN

@implementation NSImage (CTSBase64Representation)

- (NSString *)cts_base64Representation {
    NSData *imageData = self.TIFFRepresentation;
    NSBitmapImageRep *bitmapData = [NSBitmapImageRep imageRepWithData:imageData];
    NSData *pngData = [bitmapData representationUsingType:NSPNGFileType properties:@ {NSImageCompressionFactor: @1.0 }];
    NSString *base64String = [pngData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    
    return base64String;
}

@end

NS_ASSUME_NONNULL_END
