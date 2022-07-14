#import "MediaThumbnailPlugin.h"
#if __has_include(<media_thumbnail/media_thumbnail-Swift.h>)
#import <media_thumbnail/media_thumbnail-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "media_thumbnail-Swift.h"
#endif

@implementation MediaThumbnailPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftMediaThumbnailPlugin registerWithRegistrar:registrar];
}
@end
