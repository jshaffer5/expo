// Copyright 2020-present 650 Industries. All rights reserved.

#import <expo-image/EXImageViewManager.h>
#import <expo-image/EXImageView.h>

@implementation EXImageViewManager

RCT_EXPORT_MODULE(ExpoImage)

RCT_EXPORT_VIEW_PROPERTY(source, NSDictionary)
RCT_EXPORT_VIEW_PROPERTY(resizeMode, RCTResizeMode)

RCT_EXPORT_VIEW_PROPERTY(borderWidth, NSNumber*)
RCT_EXPORT_VIEW_PROPERTY(borderTopWidth, NSNumber*)
RCT_EXPORT_VIEW_PROPERTY(borderRightWidth, NSNumber*)
RCT_EXPORT_VIEW_PROPERTY(borderBottomWidth, NSNumber*)
RCT_EXPORT_VIEW_PROPERTY(borderLeftWidth, NSNumber*)
RCT_EXPORT_VIEW_PROPERTY(borderStartWidth, NSNumber*)
RCT_EXPORT_VIEW_PROPERTY(borderEndWidth, NSNumber*)

RCT_EXPORT_VIEW_PROPERTY(borderRadius, NSNumber)
RCT_EXPORT_VIEW_PROPERTY(borderTopLeftRadius, NSNumber)
RCT_EXPORT_VIEW_PROPERTY(borderTopRightRadius, NSNumber)
RCT_EXPORT_VIEW_PROPERTY(borderTopStartRadius, NSNumber)
RCT_EXPORT_VIEW_PROPERTY(borderTopEndRadius, NSNumber)
RCT_EXPORT_VIEW_PROPERTY(borderBottomLeftRadius, NSNumber)
RCT_EXPORT_VIEW_PROPERTY(borderBottomRightRadius, NSNumber)
RCT_EXPORT_VIEW_PROPERTY(borderBottomStartRadius, NSNumber)
RCT_EXPORT_VIEW_PROPERTY(borderBottomEndRadius, NSNumber)

- (UIView *)view
{
  return [[EXImageView alloc] init];
}

@end
