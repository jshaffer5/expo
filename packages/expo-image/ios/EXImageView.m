// Copyright 2020-present 650 Industries. All rights reserved.

#import <expo-image/EXImageView.h>
#import <React/RCTConvert.h>

static NSString * const sourceUriKey = @"uri";
static NSString * const sourceScaleKey = @"scale";

@interface EXImageView ()

@property (nonatomic, strong) NSDictionary *source;
@property (nonatomic, assign) RCTResizeMode resizeMode;
@property (nonatomic, assign) BOOL needsReload;

@end

@implementation EXImageView

- (instancetype)init
{
  if (self = [super init]) {
    _needsReload = NO;
    _resizeMode = RCTResizeModeCover;
    self.contentMode = (UIViewContentMode)_resizeMode;
  }
  return self;
}

- (void)dealloc
{
  // Stop any active operations or downloads
  [self sd_setImageWithURL:nil];
}

# pragma mark -  Custom prop setters

- (void)setSource:(NSDictionary *)source
{
  _source = source;
  // TODO: Implement equatable image source abstraction
  _needsReload = YES;
}

- (void)setResizeMode:(RCTResizeMode)resizeMode
{
  if (_resizeMode == resizeMode) {
    return;
  }
  
  // Image needs to be reloaded whenever repeat is enabled or disabled
  _needsReload = _needsReload || (resizeMode == RCTResizeModeRepeat) || (_resizeMode == RCTResizeModeRepeat);
  _resizeMode = resizeMode;
  
  // Repeat resize mode is handled by the UIImage. Use scale to fill
  // so the repeated image fills the UIImageView.
  self.contentMode = resizeMode == RCTResizeModeRepeat
    ? UIViewContentModeScaleToFill
    : (UIViewContentMode)resizeMode;
}

- (void)didSetProps:(NSArray<NSString *> *)changedProps;
{
  if (_needsReload) {
    [self reloadImage];
  }
}

- (void)reloadImage
{
  _needsReload = NO;
  
  NSURL *imageUrl = _source ? [RCTConvert NSURL:_source[sourceUriKey]] : nil;
  NSNumber *scale = _source && _source[sourceScaleKey] ? _source[sourceScaleKey] : nil;
  RCTResizeMode resizeMode = _resizeMode;
  
  NSMutableDictionary *context = [NSMutableDictionary new];
  
  // Only apply custom scale factors when neccessary. The scale factor
  // affects how the image is rendered when resizeMode `center` and `repeat`
  // are used. On animated images, applying a scale factor may cause
  // re-encoding of the data, which should be avoided when possible.
  if (scale && scale.doubleValue != 1.0) {
    [context setValue:scale forKey:SDWebImageContextImageScaleFactor];
  }
  
  __weak EXImageView *weakSelf = self;
  [self sd_setImageWithURL:imageUrl
          placeholderImage:nil
                   options:SDWebImageAvoidAutoSetImage
                   context:context
                  progress:nil
                 completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
    __strong EXImageView *strongSelf = weakSelf;
    if (!strongSelf) {
      return;
    }
    
    // Modifications to the image like changing the resizing-mode or cap-insets
    // cannot be handled using a SDWebImage transformer, because they don't change
    // the image-data and this causes this "meta" data to be lost in the SDWebImage caching process.
    if (image) {
      if (resizeMode == RCTResizeModeRepeat) {
        image = [image resizableImageWithCapInsets:UIEdgeInsetsZero resizingMode:UIImageResizingModeTile];
      }
    }
    strongSelf.image = image;
  }];
}

@end
