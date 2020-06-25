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

static NSString *const METHOD_SAVECOOKIES = @"saveCookies";
static NSString *const METHOD_LOADCOOKIES = @"loadCookies";
static NSString *const METHOD_REMOVEALLCOOKIES = @"removeAllCookies";

static NSString *const ARGUMENT_KEY_URL = @"url";
static NSString *const ARGUMENT_KEY_COOKIES = @"cookies";

- (void)handleMethodCall:(FlutterMethodCall *)call
                  result:(FlutterResult)result {
  if ([METHOD_SAVECOOKIES isEqualToString:call.method]) {
    [self saveCookies:call result:result];
  } else if ([METHOD_LOADCOOKIES isEqualToString:call.method]) {
    [self loadCookies:call result:result];
  } else if ([METHOD_REMOVEALLCOOKIES isEqualToString:call.method]) {
    [self removeAllCookies:call result:result];
  } else {
    result(FlutterMethodNotImplemented);
  }
}

- (void)saveCookies:(FlutterMethodCall *)call result:(FlutterResult)result {
  NSString *url = call.arguments[ARGUMENT_KEY_URL];
  NSArray *cookieStrs = call.arguments[ARGUMENT_KEY_COOKIES];
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
  NSString *url = call.arguments[ARGUMENT_KEY_URL];
  if (@available(iOS 11.0, *)) {
    [[[WKWebsiteDataStore defaultDataStore] httpCookieStore]
        getAllCookies:^(NSArray<NSHTTPCookie *> *_Nonnull cookies) {
          NSMutableArray *cookieStrs = [NSMutableArray array];
          NSURL *nsurl = [NSURL URLWithString:url];
          if (cookies != nil && cookies.count > 0) {
            for (NSHTTPCookie *cookie in cookies) {
              if ([self domainMatch:nsurl.host domain:cookie.domain]) {
                [cookieStrs addObject:[self convertCookie:cookie]];
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
  if (@available(iOS 11.0, *)) {
    NSSet<NSString *> *websiteDataTypes =
        [NSSet setWithObject:WKWebsiteDataTypeCookies];
    NSDate *dateFrom = [NSDate dateWithTimeIntervalSince1970:0];
    [[WKWebsiteDataStore defaultDataStore] removeDataOfTypes:websiteDataTypes
                                               modifiedSince:dateFrom
                                           completionHandler:^{
                                           }];
  } else {
    if (@available(iOS 9.0, *)) {
      NSSet<NSString *> *websiteDataTypes =
          [NSSet setWithObject:WKWebsiteDataTypeCookies];
      NSDate *dateFrom = [NSDate dateWithTimeIntervalSince1970:0];
      [[WKWebsiteDataStore defaultDataStore] removeDataOfTypes:websiteDataTypes
                                                 modifiedSince:dateFrom
                                             completionHandler:^{
                                             }];
    }
    NSArray<NSHTTPCookie *> *cookies =
        [NSHTTPCookieStorage sharedHTTPCookieStorage].cookies;
    if (cookies != nil && cookies.count > 0) {
      for (NSHTTPCookie *cookie in cookies) {
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
      }
    }
  }
  result(nil);
}

@end
