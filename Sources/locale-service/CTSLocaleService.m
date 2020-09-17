#import "CTSLocaleService.h"

#import <Carbon/Carbon.h>

#import "NSURL+CTSBetterTouchToolWebServerEndpoint.h"

#import "CTSBetterTouchToolWebServerConfiguration.h"

NS_ASSUME_NONNULL_BEGIN

static NSString * const kBetterTouchToolRefreshWidgetEndpoint = @"refresh_widget";

@interface CTSLocaleService ()

@property (nonatomic, strong, readonly) NSURLSession *URLSession;
@property (nonatomic, strong, readonly, nullable) NSString *widgetUUID;
@property (nonatomic, strong, readonly, nullable) CTSBetterTouchToolWebServerConfiguration *webServerConfiguration;

@end

@implementation CTSLocaleService

@synthesize running = _running;

- (instancetype)initWithURLSession:(NSURLSession * const)URLSession
                        widgetUUID:(nullable NSString * const)widgetUUID
            webServerConfiguration:(nullable CTSBetterTouchToolWebServerConfiguration * const)webServerConfiguration
{
    self = [super init];
    
    if (self) {
        _URLSession = URLSession;
        _widgetUUID = [widgetUUID copy];
        _webServerConfiguration = webServerConfiguration;
    }
    
    return self;
}

- (void)start
{
    _running = YES;

    [self registerInputSourceListener];
}

- (void)registerInputSourceListener
{
    [[NSDistributedNotificationCenter defaultCenter] addObserver:self
                                                        selector:@selector(selectedKeyboardInputSourceChanged:)
                                                            name:(__bridge NSString*)kTISNotifySelectedKeyboardInputSourceChanged
                                                          object:nil];
}

- (void)selectedKeyboardInputSourceChanged:(NSObject* )object
{
    [self pushUpdateToWidget];
}

- (void)pushUpdateToWidget
{
    if (!self.webServerConfiguration || !self.widgetUUID) {
        return;
    }
    
    NSURL * const URL = [NSURL cts_URLWithWebServerConfiguration:self.webServerConfiguration
                                                        endpoint:kBetterTouchToolRefreshWidgetEndpoint
                                                 queryParameters:@[[NSString stringWithFormat:@"uuid=%@",self.widgetUUID]]];
    NSURLRequest * const request = [NSURLRequest requestWithURL:URL
                                                    cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                timeoutInterval:1.0];
    NSURLSessionTask * const task = [self.URLSession dataTaskWithRequest:request];
    [task resume];
    
#if DEBUG
    NSLog(@"Pushed update to BTT web server at URL: %@", URL);
#endif
}


@end

NS_ASSUME_NONNULL_END
