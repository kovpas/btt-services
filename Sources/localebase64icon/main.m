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

@interface NSImage (Resize)

+ (NSImage *)resizedImage:(NSImage *)sourceImage toPixelDimensions:(NSSize)newSize;
@end

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        TISInputSourceRef currentSource = TISCopyCurrentKeyboardInputSource();
        IconRef iconRef = (IconRef)TISGetInputSourceProperty(currentSource, kTISPropertyIconRef);
        NSImage *image = [[NSImage alloc] initWithIconRef:iconRef];
        NSImageRep *rep = nil;//image.representations[0];
        for (NSImageRep *oneRep in image.representations) {
            if (CGSizeEqualToSize(oneRep.size, CGSizeMake(512, 512))) {
                rep = oneRep;
                break;
            }
        }
        NSImage *newImage = [[NSImage alloc] initWithSize:rep.size];
        [newImage addRepresentation:rep];
        
        newImage = [NSImage resizedImage:newImage toPixelDimensions:NSMakeSize(256, 256)];
        
        NSBitmapImageRep *bitmapRep = [NSBitmapImageRep imageRepWithData:[newImage TIFFRepresentation]];
        NSData *pngData = [bitmapRep representationUsingType:NSBitmapImageFileTypePNG
                                                  properties:@{NSImageCompressionFactor: @0}];
        NSString *base64 = [pngData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
        printf("%s", [base64 UTF8String]);
    }
    return 0;
}

@implementation NSImage (Resize)

+ (NSImage *)resizedImage:(NSImage *)sourceImage toPixelDimensions:(NSSize)newSize
{
    if (! sourceImage.isValid) return nil;

    NSBitmapImageRep *rep = [[NSBitmapImageRep alloc]
              initWithBitmapDataPlanes:NULL
                            pixelsWide:newSize.width
                            pixelsHigh:newSize.height
                         bitsPerSample:8
                       samplesPerPixel:4
                              hasAlpha:YES
                              isPlanar:NO
                        colorSpaceName:NSCalibratedRGBColorSpace
                           bytesPerRow:0
                          bitsPerPixel:0];
    rep.size = newSize;

    [NSGraphicsContext saveGraphicsState];
    [NSGraphicsContext setCurrentContext:[NSGraphicsContext graphicsContextWithBitmapImageRep:rep]];
    [sourceImage drawInRect:NSMakeRect(0, 0, newSize.width, newSize.height) fromRect:NSZeroRect operation:NSCompositeCopy fraction:1.0];
    [NSGraphicsContext restoreGraphicsState];

    NSImage *newImage = [[NSImage alloc] initWithSize:newSize];
    [newImage addRepresentation:rep];
    return newImage;
}

@end
