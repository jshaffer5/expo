// Copyright 2020-present 650 Industries. All rights reserved.

#import <expo-image/EXImageView.h>
#import <expo-image/EXImageViewBorders.h>
#import <React/RCTConvert.h>
#import <React/RCTI18nUtil.h>
#import <React/RCTBorderDrawing.h>

static NSString * const sourceUriKey = @"uri";
static NSString * const sourceScaleKey = @"scale";

@interface EXImageView ()

@property (nonatomic, strong) SDAnimatedImageView *imageView;

@property (nonatomic, assign) EXImageBorderEdges borderEdges;
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
    _borderEdges = EXImageBorderEdgesInit();
    _cornerRadii = EXImageCornerRadiiInit();
    
    _imageView = [SDAnimatedImageView new];
    _imageView.frame = self.bounds;
    _imageView.contentMode = (UIViewContentMode)_resizeMode;
    _imageView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    _imageView.layer.masksToBounds = YES;
    
    /*_borderAllLayer = [CAShapeLayer layer];
    _borderAllLayer.hidden = YES;
    [_imageView.layer addSublayer:_borderAllLayer];*/
    
    [self addSubview:_imageView];
  }
  return self;
}

- (void)dealloc
{
  // Stop any active operations or downloads
  [_imageView sd_setImageWithURL:nil];
  
  EXImageBorderEdgesRelease(_borderEdges);
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
  EXImageBorderEdges borderEdges = EXImageBorderEdgesResolve(_borderEdges, _reactLayoutDirection, swapLeftRightInRTL);
  RCTCornerInsets cornerInsets = EXImageGetCornerInsets(cornerRadii, UIEdgeInsetsZero);
  
  CGPathRef clipPath = RCTPathCreateWithRoundedRect(bounds, cornerInsets, NULL);
  [self updateClipBoundsForCornerRadii:cornerRadii bounds:bounds path:clipPath];
  CGPathRelease(clipPath);
  
  CGRect borderRect = UIEdgeInsetsInsetRect(bounds, UIEdgeInsetsMake(borderEdges.top.width / 2, borderEdges.left.width / 2, borderEdges.bottom.width / 2, borderEdges.right.width / 2));
  CGPathRef borderPath = RCTPathCreateWithRoundedRect(borderRect, cornerInsets, NULL);
  [self updateBorderLayersForBorderEdges:borderEdges cornerRadii:cornerRadii bounds:bounds path:borderPath];
  CGPathRelease(borderPath);
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

- (void)updateClipBoundsForCornerRadii:(EXImageCornerRadii)cornerRadii bounds:(CGRect)bounds path:(CGPathRef)path
{
  CALayer *mask = nil;
  CGFloat cornerRadius = 0;
  
  if (EXImageCornerRadiiAllEqual(cornerRadii)) {
    cornerRadius = cornerRadii.topLeft;
  } else {
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.path = path;
    mask = shapeLayer;
  }

  _imageView.layer.cornerRadius = cornerRadius;
  _imageView.layer.mask = mask;
  _imageView.layer.masksToBounds = YES;
}

- (CALayer *)getSimpleBorderLayer:(CALayer *)layer borderEdge:(EXImageBorderEdge)borderEdge cornerRadius:(CGFloat)cornerRadius bounds:(CGRect)bounds
{
  cornerRadius = MAX(cornerRadius, 0);
  if (layer
    && ![layer isKindOfClass:[CAShapeLayer class]]
    && CGRectEqualToRect(layer.frame, bounds)
    && (layer.borderWidth == borderEdge.width)
    && CGColorEqualToColor(layer.borderColor, borderEdge.color)
    && (layer.cornerRadius == cornerRadius)) {
    return layer;
  }
  
  layer = [CALayer layer];
  layer.frame = bounds;
  layer.borderColor = borderEdge.color;
  layer.borderWidth = borderEdge.width;
  layer.cornerRadius = cornerRadius;
  
  return layer;
}

- (CALayer *)getShapeBorderLayer:(CALayer *)layer borderEdge:(EXImageBorderEdge)borderEdge cornerRadii:(EXImageCornerRadii)cornerRadii bounds:(CGRect)bounds path:(CGPathRef)path
{
  /*cornerRadius = MAX(cornerRadius, 0);
  if (layer
    && ![layer isKindOfClass:[CAShapeLayer class]]
    && CGRectEqualToRect(layer.frame, bounds)
    && (layer.borderWidth == borderEdge.width)
    && CGColorEqualToColor(layer.borderColor, borderEdge.color)
    && (layer.cornerRadius == cornerRadius)) {
    return layer;
  }*/
  
  CAShapeLayer *shapeLayer = [CAShapeLayer layer];
  shapeLayer.frame = bounds;
  shapeLayer.fillColor = UIColor.clearColor.CGColor;
  shapeLayer.strokeColor = borderEdge.color;
  shapeLayer.lineWidth = borderEdge.width;
  shapeLayer.path = path;
  
  switch (borderEdge.style) {
    case RCTBorderStyleDashed:
      shapeLayer.lineCap = kCALineCapSquare;
      shapeLayer.lineDashPattern = @[@(shapeLayer.lineWidth * 2), @(shapeLayer.lineWidth * 2)];
      break;
    case RCTBorderStyleDotted:
      shapeLayer.lineCap = kCALineCapRound;
      shapeLayer.lineDashPattern = @[@0, @(shapeLayer.lineWidth * 2)];
    break;
  }
  
  return shapeLayer;
}


- (void)updateBorderLayersForBorderEdges:(EXImageBorderEdges)borderEdges cornerRadii:(EXImageCornerRadii)cornerRadii bounds:(CGRect)bounds path:(CGPathRef)path
{
  CALayer *borderLayer;
  CALayer *borderTopLayer;
  CALayer *borderRightLayer;
  CALayer *borderBottomLayer;
  CALayer *borderLeftLayer;
  
  if (EXImageBorderEdgesAllEqual(borderEdges)) {
    EXImageBorderEdge borderEdge = borderEdges.top;
    if (EXImageBorderEdgeVisible(borderEdge)) {
      if ((borderEdge.style == RCTBorderStyleSolid) &&
        EXImageCornerRadiiAllEqual(cornerRadii)) {
        CGFloat cornerRadius = cornerRadii.topLeft;
        borderLayer = [self getSimpleBorderLayer:_borderLayer borderEdge:borderEdge cornerRadius:cornerRadius bounds:bounds];
      } else {
        borderLayer = [self getShapeBorderLayer:_borderLayer borderEdge:borderEdge cornerRadii:cornerRadii bounds:bounds path:path];
      }
    }
  } else {
    // TODO
  }
  
  if (_borderLayer != borderLayer) {
    if (_borderLayer) [_borderLayer removeFromSuperlayer];
    _borderLayer = borderLayer;
    if (borderLayer) [_imageView.layer addSublayer:_borderLayer];
  }
}

#pragma mark - Border Radius

#define setBorderRadius(side, var)                 \
  -(void)setBorder##side##Radius : (CGFloat)radius \
  {                                                \
    if (_cornerRadii.var == radius) {              \
      return;                                      \
    }                                              \
    _cornerRadii.var = radius;                     \
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

#define setBorderEdge(side, var)                                \
  -(void)setBorder##side##Color : (CGColorRef)color             \
  {                                                             \
    if (CGColorEqualToColor(_borderEdges.var.color, color)) {   \
      return;                                                   \
    }                                                           \
    CGColorRelease(_borderEdges.var.color);                     \
    _borderEdges.var.color = CGColorRetain(color);              \
    [self.layer setNeedsDisplay];                               \
  }                                                             \
  -(void)setBorder##side##Width : (CGFloat)width                \
  {                                                             \
    if (_borderEdges.var.width == width) {                      \
      return;                                                   \
    }                                                           \
    _borderEdges.var.width = width;                             \
    [self.layer setNeedsDisplay];                               \
  }                                                             \
  -(void)setBorder##side##Style : (RCTBorderStyle)style         \
  {                                                             \
    if (_borderEdges.var.style == style) {                      \
      return;                                                   \
    }                                                           \
    _borderEdges.var.style = style;                             \
    [self.layer setNeedsDisplay];                               \
  }

setBorderEdge(,all)
setBorderEdge(Top,top)
setBorderEdge(Right,right)
setBorderEdge(Bottom,bottom)
setBorderEdge(Left,left)
setBorderEdge(Start,start)
setBorderEdge(End,end)

@end
