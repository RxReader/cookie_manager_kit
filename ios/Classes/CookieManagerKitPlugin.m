#import "CookieManagerKitPlugin.h"
#import <WebKit/WebKit.h>
#import <time.h>
#import <xlocale.h>

@implementation CookieManagerKitPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
    FlutterMethodChannel *channel = [FlutterMethodChannel
        methodChannelWithName:@"v7lin.github.io/cookie_manager_kit"
              binaryMessenger:[registrar messenger]];
    CookieManagerKitPlugin *instance = [[CookieManagerKitPlugin alloc] init];
    [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall *)call
                  result:(FlutterResult)result {
    if ([@"saveCookies" isEqualToString:call.method]) {
        [self saveCookies:call result:result];
    } else if ([@"loadCookies" isEqualToString:call.method]) {
        [self loadCookies:call result:result];
    } else if ([@"removeAllCookies" isEqualToString:call.method]) {
        [self removeAllCookies:call result:result];
    } else {
        result(FlutterMethodNotImplemented);
    }
}

- (void)saveCookies:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSString *url = call.arguments[@"url"];
    NSArray *cookieStrs = call.arguments[@"cookies"];
    if (cookieStrs != nil && cookieStrs.count > 0) {
        for (NSString *cookieStr in cookieStrs) {
            NSMutableDictionary<NSString *, NSString *> *headerFields =
                [NSMutableDictionary dictionary];
            [headerFields setValue:cookieStr forKey:@"Set-Cookie"];
            NSArray<NSHTTPCookie *> *cookies = [NSHTTPCookie
                cookiesWithResponseHeaderFields:headerFields
                                         forURL:[NSURL URLWithString:url]];
            if (@available(iOS 11.0, *)) {
                for (NSHTTPCookie *cookie in cookies) {
                    [[[WKWebsiteDataStore defaultDataStore] httpCookieStore]
                                setCookie:cookie
                        completionHandler:nil];
                }
            } else {
                [[NSHTTPCookieStorage sharedHTTPCookieStorage]
                         setCookies:cookies
                             forURL:[NSURL URLWithString:url]
                    mainDocumentURL:nil];
            }
        }
    }
    result(nil);
}

- (void)loadCookies:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSString *url = call.arguments[@"url"];
    if (@available(iOS 11.0, *)) {
        __weak typeof(self) weakSelf = self;
        [[[WKWebsiteDataStore defaultDataStore] httpCookieStore]
            getAllCookies:^(NSArray<NSHTTPCookie *> *_Nonnull cookies) {
                __strong typeof(weakSelf) strongSelf = weakSelf;
                NSMutableArray *cookieStrs = [NSMutableArray array];
                NSURL *nsurl = [NSURL URLWithString:url];
                if (cookies != nil && cookies.count > 0) {
                    for (NSHTTPCookie *cookie in cookies) {
                        NSString *domain = cookie.domain;
                        if ([domain hasPrefix:@"."]) {
                            domain = [domain substringFromIndex:1];
                        }
                        if ([strongSelf domainMatch:nsurl.host domain:domain]) {
                            [cookieStrs addObject:[strongSelf convertCookie:cookie]];
                        }
                    }
                }
                result(cookieStrs);
            }];
    } else {
        NSMutableArray *cookieStrs = [NSMutableArray array];
        NSArray<NSHTTPCookie *> *cookies =
            [[NSHTTPCookieStorage sharedHTTPCookieStorage]
                cookiesForURL:[NSURL URLWithString:url]];
        if (cookies != nil && cookies.count > 0) {
            for (NSHTTPCookie *cookie in cookies) {
                [cookieStrs addObject:[self convertCookie:cookie]];
            }
        }
        result(cookieStrs);
    }
}

- (BOOL)domainMatch:(NSString *)urlHost domain:(NSString *)domain {
    if ([urlHost isEqualToString:domain]) {
        return YES; // As in 'example.com' matching 'example.com'.
    }
    if ([urlHost hasSuffix:domain] &&
        [urlHost characterAtIndex:(urlHost.length - domain.length - 1)] == '.' &&
        ![self verifyAsIpAddress:urlHost]) {
        return YES; // As in 'example.com' matching 'www.example.com'.
    }
    return NO;
}

- (BOOL)verifyAsIpAddress:(NSString *)host {
    NSString *regex = @"([0-9a-fA-F]*:[0-9a-fA-F:.]*)|([\\d.]+)";
    NSPredicate *predicate =
        [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [predicate evaluateWithObject:host];
}

- (NSString *)convertCookie:(NSHTTPCookie *)cookie {
    NSMutableString *cookieStr = [NSMutableString string];
    [cookieStr appendString:cookie.name];
    [cookieStr appendString:@"="];
    [cookieStr appendString:cookie.value];
    if (cookie.expiresDate != nil) {
        // RFC-1123
        time_t date = (time_t)[cookie.expiresDate timeIntervalSince1970];
        struct tm timeinfo;
        gmtime_r(&date, &timeinfo);
        char buffer[32];
        size_t ret = strftime_l(buffer, sizeof(buffer), "%a, %d %b %Y %H:%M:%S GMT",
                                &timeinfo, NULL);
        if (ret) {
            [cookieStr appendString:@"; Expires="];
            [cookieStr appendString:@(buffer)];
        }
    }
    if (cookie.domain != nil) {
        [cookieStr appendString:@"; Domain="];
        [cookieStr appendString:cookie.domain];
    }
    if (cookie.path != nil) {
        [cookieStr appendString:@"; Path="];
        [cookieStr appendString:cookie.path];
    }
    if (cookie.secure) {
        [cookieStr appendString:@"; Secure"];
    }
    if (cookie.HTTPOnly) {
        [cookieStr appendString:@"; HttpOnly"];
    }
    return cookieStr;
}

- (void)removeAllCookies:(FlutterMethodCall *)call
                  result:(FlutterResult)result {
    [[NSURLSession sharedSession] resetWithCompletionHandler:^{
    }];
    if (@available(iOS 11.0, *)) {
        NSSet<NSString *> *websiteDataTypes = [NSSet setWithObject:WKWebsiteDataTypeCookies];
        WKWebsiteDataStore *dataStore = [WKWebsiteDataStore defaultDataStore];
        void (^deleteAndNotify)(NSArray<WKWebsiteDataRecord *> *) =
            ^(NSArray<WKWebsiteDataRecord *> *cookies) {
                [dataStore removeDataOfTypes:websiteDataTypes
                              forDataRecords:cookies
                           completionHandler:^{
                           }];
            };

        [dataStore fetchDataRecordsOfTypes:websiteDataTypes completionHandler:deleteAndNotify];
    } else {
        NSSet<NSString *> *websiteDataTypes = [NSSet setWithObject:WKWebsiteDataTypeCookies];
        WKWebsiteDataStore *dataStore = [WKWebsiteDataStore defaultDataStore];
        void (^deleteAndNotify)(NSArray<WKWebsiteDataRecord *> *) =
            ^(NSArray<WKWebsiteDataRecord *> *cookies) {
                [dataStore removeDataOfTypes:websiteDataTypes
                              forDataRecords:cookies
                           completionHandler:^{
                           }];
            };
        [dataStore fetchDataRecordsOfTypes:websiteDataTypes completionHandler:deleteAndNotify];
        NSArray<NSHTTPCookie *> *cookies = [NSHTTPCookieStorage sharedHTTPCookieStorage].cookies;
        if (cookies != nil && cookies.count > 0) {
            for (NSHTTPCookie *cookie in cookies) {
                [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
            }
        }
    }
    result(nil);
}

@end
