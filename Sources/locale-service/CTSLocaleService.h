#import <Foundation/Foundation.h>

#import "CTSService.h"

NS_ASSUME_NONNULL_BEGIN

@class CTSBetterTouchToolWebServerConfiguration;

@interface CTSLocaleService : NSObject <CTSService>

/**
 Create a service.
 
 @param URLSession The URL session to use when pushing requests to BetterTouchTool.
 @param widgetUUID An optional widget UUID to push refresh updates after an event changes. If nil, no pushes occur.
 @param webServerConfiguration The optional BetterTouchTool web server configuration object. If nil, no pushes occur.
 @return A new volume service instance.
 */
- (instancetype)initWithURLSession:(NSURLSession * const)URLSession
                        widgetUUID:(nullable NSString * const)widgetUUID
            webServerConfiguration:(nullable CTSBetterTouchToolWebServerConfiguration * const)webServerConfiguration NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
