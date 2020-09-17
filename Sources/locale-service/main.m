#import <Foundation/Foundation.h>

#import "NSDictionary+CTSCommandLineArguments.h"
#import "CTSBetterTouchToolWebServerConfiguration.h"
#import "CTSLocaleService.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        NSDictionary<NSString *, NSString *> * const dictionary =
        [NSDictionary cts_dictionaryWithCommandLineArguments:[NSProcessInfo processInfo].arguments];
        NSString * _Nullable const webServerURLString = dictionary[@"btt-url"] ?: dictionary[@"u"];
        NSString * _Nullable const webServerSharedSecret = dictionary[@"btt-secret"] ?: dictionary[@"s"];
        NSString * _Nullable const widgetUUID = dictionary[@"widget-uuid"] ?: dictionary[@"w"];
        
        if (widgetUUID && !webServerURLString) {
            fputs("Usage: ./volume-service\n"
                  "  --btt-url=<url>, -u <url>\n"
                  "        The optional base URL to BetterTouchTool's web server in the format `protocol://hostname:port`.\n"
                  "        If not specified, the service will not push updates to BetterTouchTool.\n\n"
                  
                  "  --btt-secret=<secret>, -s <secret>\n"
                  "        The optional shared secret to authenticate with BetterTouchTool's web server.\n\n"
                  
                  "  --widget-uuid=<uuid>, -w <uuid>\n"
                  "        The UUID of the BetterTouchTool widget to refresh on update pushes. If not specified, the\n"
                  "        service will not push updates to BetterTouchTool.\n\n",
                  stderr);
            return 1;
        }
        
        NSURL * const webServerURL = [NSURL URLWithString:webServerURLString];
        CTSBetterTouchToolWebServerConfiguration * const configuration =
        [[CTSBetterTouchToolWebServerConfiguration alloc] initWithURL:webServerURL
                                                         sharedSecret:webServerSharedSecret];
        
        NSURLSession * const URLSession = [NSURLSession sharedSession];
        CTSLocaleService * const service = [[CTSLocaleService alloc] initWithURLSession:URLSession
                                                                             widgetUUID:widgetUUID
                                                                 webServerConfiguration:configuration];
        [service start];
        
        NSRunLoop * const runLoop = [NSRunLoop currentRunLoop];
        [runLoop addPort:[NSMachPort port] forMode:NSDefaultRunLoopMode];
        while (service.isRunning) {
            [runLoop runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
        }
    }
    return 0;
}
