#import "MbautomationPlugin.h"
#if __has_include(<mbautomation/mbautomation-Swift.h>)
#import <mbautomation/mbautomation-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "mbautomation-Swift.h"
#endif

@implementation MbautomationPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftMbautomationPlugin registerWithRegistrar:registrar];
}
@end
