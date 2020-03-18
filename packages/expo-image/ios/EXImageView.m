// Copyright 2020-present 650 Industries. All rights reserved.

#import <expo-image/EXImageView.h>
#import <expo-image/EXImageBorders.h>
#import <expo-image/EXImageCornerRadii.h>
#import <React/RCTConvert.h>
#import <React/RCTI18nUtil.h>
#import <React/RCTBorderDrawing.h>

static NSString * const sourceUriKey = @"uri";
static NSString * const sourceScaleKey = @"scale";

@interface EXImageView ()

@property (nonatomic, strong) SDAnimatedImageView *imageView;

@property (nonatomic, assign) EXImageBorders borders;
@property (nonatomic, assign) EXImageCornerRadii cornerRadii;
@property (nonatomic, strong) CALayer *borderLayer;
@property (nonatomic, strong) CALayer *borderTopLayer;
@property (nonatomic, strong) CALayer *borderRightLayer;
@property (nonatomic, strong) CALayer *borderBottomLayer;
@property (nonatomic, strong) CALayer *borderLeftLayer;

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
    _borders = EXImageBordersInit();
    _cornerRadii = EXImageCornerRadiiInit();

    _imageView = [SDAnimatedImageView new];
    _imageView.frame = self.bounds;
    _imageView.contentMode = (UIViewContentMode)_resizeMode;
    _imageView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    _imageView.layer.masksToBounds = YES;
    
    [self addSubview:_imageView];
  }
  return self;
}

- (void)dealloc
{
  // Stop any active operations or downloads
  [_imageView sd_setImageWithURL:nil];
  
  EXImageBordersRelease(_borders);
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
  _imageView.contentMode = resizeMode == RCTResizeModeRepeat
  ? UIViewContentModeScaleToFill
  : (UIViewContentMode)resizeMode;
}

- (void)didSetProps:(NSArray<NSString *> *)changedProps;
{
  if (_needsReload) {
    [self reloadImage];
  }
  [self updateStyle];
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
  [_imageView sd_setImageWithURL:imageUrl
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
    strongSelf.imageView.image = image;
  }];
}

- (void)updateStyle
{
  // TODO ?
}

- (void)displayLayer:(CALayer *)layer
{
  if (CGSizeEqualToSize(layer.bounds.size, CGSizeZero)) {
    return;
  }
  
  CGRect bounds = self.bounds;
  BOOL swapLeftRightInRTL = [[RCTI18nUtil sharedInstance] doLeftAndRightSwapInRTL];
  EXImageCornerRadii cornerRadii = EXImageCornerRadiiResolve(_cornerRadii, _reactLayoutDirection, swapLeftRightInRTL, bounds.size);
  EXImageBorders borders = EXImageBordersResolve(_borders, _reactLayoutDirection, swapLeftRightInRTL);
  
  [self updateClipBoundsForCornerRadii:cornerRadii bounds:bounds];
  [self updateBorderLayersForborders:borders cornerRadii:cornerRadii bounds:bounds];
}

- (void)setReactLayoutDirection:(UIUserInterfaceLayoutDirection)layoutDirection
{
  if (_reactLayoutDirection != layoutDirection) {
    _reactLayoutDirection = layoutDirection;
    [self.layer setNeedsDisplay];
  }
  
  if ([self respondsToSelector:@selector(setSemanticContentAttribute:)]) {
    self.semanticContentAttribute = layoutDirection == UIUserInterfaceLayoutDirectionLeftToRight
    ? UISemanticContentAttributeForceLeftToRight
    : UISemanticContentAttributeForceRightToLeft;
  }
}

- (void)updateClipBoundsForCornerRadii:(EXImageCornerRadii)cornerRadii bounds:(CGRect)bounds
{
  CALayer *mask = nil;
  CGFloat cornerRadius = 0;
  
  if (EXImageCornerRadiiAllEqual(cornerRadii)) {
    cornerRadius = cornerRadii.topLeft;
  } else {
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    RCTCornerInsets cornerInsets = EXImageGetCornerInsets(cornerRadii, UIEdgeInsetsZero);
    CGPathRef path = RCTPathCreateWithRoundedRect(bounds, cornerInsets, NULL);
    shapeLayer.path = path;
    mask = shapeLayer;
    CGPathRelease(path);
  }
  
  _imageView.layer.cornerRadius = cornerRadius;
  _imageView.layer.mask = mask;
  _imageView.layer.masksToBounds = YES;
}

- (void)updateBorderLayersForborders:(EXImageBorders)borders cornerRadii:(EXImageCornerRadii)cornerRadii bounds:(CGRect)bounds
{
  CALayer *borderLayer = nil;
  CALayer *borderTopLayer = nil;
  CALayer *borderRightLayer = nil;
  CALayer *borderBottomLayer = nil;
  CALayer *borderLeftLayer = nil;
  
  // Shape-layers draw the stroke in the middle of the path. The border should
  // however be drawn on the inside of the outer edge. Therefore calculate the path
  // for CAShapeLayer with an inset to the center so that it draws the outer edge
  // of the stroke
  UIEdgeInsets edgeInsets = UIEdgeInsetsMake(borders.top.width * 0.5, borders.left.width * 0.5, borders.bottom.width * 0.5, borders.right.width * 0.5);
  RCTCornerInsets cornerInsets = EXImageGetCornerInsets(cornerRadii, edgeInsets);
  CGPathRef shapeLayerPath = RCTPathCreateWithRoundedRect(UIEdgeInsetsInsetRect(bounds, edgeInsets), cornerInsets, NULL);
  
  
  // TEST
  /*CAShapeLayer *bkLayer;
   bkLayer = [CAShapeLayer layer];
   bkLayer.fillColor = UIColor.clearColor.CGColor;
   bkLayer.strokeColor = [UIColor redColor].CGColor;
   bkLayer.lineWidth = 1;
   bkLayer.path = shapeLayerPath;
   bkLayer.frame = bounds;
   borderTopLayer = bkLayer;*/
  
  // Optimized code-path using a single layer when with no required masking
  if (EXImageBordersAllEqual(borders)) {
    EXImageBorder border = borders.top;
    if (EXImageBorderVisible(border)) {
      if ((border.style == RCTBorderStyleSolid) &&
          EXImageCornerRadiiAllEqual(cornerRadii)) {
        borderLayer = EXImageBorderSimpleLayer(_borderLayer, border, bounds, cornerRadii.topLeft);
      } else {
        borderLayer = EXImageBorderShapeLayer(_borderLayer, border, bounds, shapeLayerPath, nil);
      }
    }
  } else {
    
    // Define a layer for each border-edge.
    if (EXImageBorderVisible(borders.top)) {
      borderTopLayer = EXImageBorderShapeLayer(_borderTopLayer, borders.top, bounds, shapeLayerPath, EXImageBorderMask(bounds, EXImageBorderLocationTop));
    }
    if (EXImageBorderVisible(borders.right)) {
      borderRightLayer = EXImageBorderShapeLayer(_borderRightLayer, borders.right, bounds, shapeLayerPath, EXImageBorderMask(bounds, EXImageBorderLocationRight));
    }
    if (EXImageBorderVisible(borders.bottom)) {
      borderBottomLayer = EXImageBorderShapeLayer(_borderBottomLayer, borders.bottom, bounds, shapeLayerPath, EXImageBorderMask(bounds, EXImageBorderLocationBottom));
    }
    if (EXImageBorderVisible(borders.left)) {
      borderLeftLayer = EXImageBorderShapeLayer(_borderLeftLayer, borders.left, bounds, shapeLayerPath, EXImageBorderMask(bounds, EXImageBorderLocationLeft));
    }
  }
  
#define updateLayer(instanceVar, localVar) \
if (instanceVar != localVar) { \
if (instanceVar) [instanceVar removeFromSuperlayer]; \
instanceVar = localVar; \
if (localVar) [_imageView.layer addSublayer:localVar]; \
}
  updateLayer(_borderLayer, borderLayer);
  updateLayer(_borderTopLayer, borderTopLayer);
  updateLayer(_borderRightLayer, borderRightLayer);
  updateLayer(_borderBottomLayer, borderBottomLayer);
  updateLayer(_borderLeftLayer, borderLeftLayer);
  
  CGPathRelease(shapeLayerPath);
}

#pragma mark - Border Radius

#define setBorderRadius(side, var)                 \
-(void)setBorder##side##Radius : (NSNumber *)radius \
{                                                \
CGFloat val = (radius != nil) ? radius.doubleValue : -1; \
if (_cornerRadii.var == val) {              \
return;                                      \
}                                              \
_cornerRadii.var = val;                     \
[self.layer setNeedsDisplay];                  \
}

setBorderRadius(,all)
setBorderRadius(TopLeft, topLeft)
setBorderRadius(TopRight, topRight)
setBorderRadius(TopStart, topStart)
setBorderRadius(TopEnd, topEnd)
setBorderRadius(BottomLeft, bottomLeft)
setBorderRadius(BottomRight, bottomRight)
setBorderRadius(BottomStart, bottomStart)
setBorderRadius(BottomEnd, bottomEnd)


#pragma mark Border Color / Width / Style

#define setBorder(side, var)                                \
-(void)setBorder##side##Color : (CGColorRef)color             \
{                                                             \
if (CGColorEqualToColor(_borders.var.color, color)) {   \
return;                                                   \
}                                                           \
CGColorRelease(_borders.var.color);                     \
_borders.var.color = CGColorRetain(color);              \
[self.layer setNeedsDisplay];                               \
}                                                             \
-(void)setBorder##side##Width : (NSNumber *)width                \
{                                                             \
CGFloat val = (width != nil) ? width.doubleValue : -1; \
if (_borders.var.width == val) {                      \
return;                                                   \
}                                                           \
_borders.var.width = val;                             \
[self.layer setNeedsDisplay];                               \
}                                                             \
-(void)setBorder##side##Style : (RCTBorderStyle)style         \
{                                                             \
if (_borders.var.style == style) {                      \
return;                                                   \
}                                                           \
_borders.var.style = style;                             \
[self.layer setNeedsDisplay];                               \
}

setBorder(,all)
setBorder(Top,top)
setBorder(Right,right)
setBorder(Bottom,bottom)
setBorder(Left,left)
setBorder(Start,start)
setBorder(End,end)

@end
