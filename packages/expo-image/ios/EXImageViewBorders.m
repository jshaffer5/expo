// Copyright 2020-present 650 Industries. All rights reserved.

#import <expo-image/EXImageViewBorders.h>
#import <React/RCTUtils.h>

static CGFloat EXImageDefaultIfNegativeTo(CGFloat defaultValue, CGFloat x)
{
  return x >= 0 ? x : defaultValue;
};

static const CGFloat EXImageViewBorderThreshold = 0.001;


EXImageBorderEdge EXImageBorderEdgeMake(CGFloat width, CGColorRef color, RCTBorderStyle style)
{
  EXImageBorderEdge edge;
  edge.width = width;
  edge.color = color;
  edge.style = style;
  return edge;
}

EXImageBorderEdges EXImageBorderEdgesInit()
{
  EXImageBorderEdges borderEdges;
  EXImageBorderEdge edge = EXImageBorderEdgeMake(-1, nil, RCTBorderStyleUnset);
  borderEdges.all = EXImageBorderEdgeMake(-1, nil, RCTBorderStyleSolid);
  borderEdges.top = edge;
  borderEdges.right = edge;
  borderEdges.bottom = edge;
  borderEdges.left = edge;
  borderEdges.start = edge;
  borderEdges.end = edge;
  return borderEdges;
}

void EXImageBorderEdgesRelease(EXImageBorderEdges borderEdges)
{
  CGColorRelease(borderEdges.all.color);
  CGColorRelease(borderEdges.top.color);
  CGColorRelease(borderEdges.right.color);
  CGColorRelease(borderEdges.bottom.color);
  CGColorRelease(borderEdges.left.color);
  CGColorRelease(borderEdges.start.color);
  CGColorRelease(borderEdges.end.color);
}

EXImageBorderEdge EXImageBorderEdgeResolve(EXImageBorderEdge borderEdge, EXImageBorderEdge defaultEdge)
{
  return EXImageBorderEdgeMake(
                               (borderEdge.width > -1) ?borderEdge.width : defaultEdge.width,
                               borderEdge.color ? borderEdge.color : defaultEdge.color,
                               (borderEdge.style != RCTBorderStyleUnset) ? borderEdge.style : defaultEdge.style
                               );
}

EXImageBorderEdges EXImageBorderEdgesResolve(EXImageBorderEdges borderEdges, UIUserInterfaceLayoutDirection layoutDirection, BOOL swapLeftRightInRTL)
{
  EXImageBorderEdge edge = EXImageBorderEdgeMake(-1, nil, RCTBorderStyleSolid);
  EXImageBorderEdges edges;
  edges.all = edge;
  edges.start = edge;
  edges.end = edge;
  
  edges.top = EXImageBorderEdgeResolve(borderEdges.top, borderEdges.all);
  edges.bottom = EXImageBorderEdgeResolve(borderEdges.bottom, borderEdges.all);
  
  const BOOL isRTL = layoutDirection == UIUserInterfaceLayoutDirectionRightToLeft;
  if (swapLeftRightInRTL) {
    EXImageBorderEdge startEdge = EXImageBorderEdgeResolve(borderEdges.left, borderEdges.start);
    EXImageBorderEdge endEdge = EXImageBorderEdgeResolve(borderEdges.right, borderEdges.end);
    EXImageBorderEdge leftEdge = isRTL ? endEdge : startEdge;
    EXImageBorderEdge rightEdge = isRTL ? startEdge : endEdge;
    edges.left = EXImageBorderEdgeResolve(leftEdge, borderEdges.all);
    edges.right = EXImageBorderEdgeResolve(rightEdge, borderEdges.all);
  } else {
    EXImageBorderEdge leftEdge = isRTL ? borderEdges.end : borderEdges.start;
    EXImageBorderEdge rightEdge = isRTL ? borderEdges.start : borderEdges.end;
    edges.left = EXImageBorderEdgeResolve(EXImageBorderEdgeResolve(leftEdge, borderEdges.left), borderEdges.all);
    edges.right = EXImageBorderEdgeResolve(EXImageBorderEdgeResolve(rightEdge, borderEdges.right), borderEdges.all);
  }
  return edges;
}

BOOL EXImageBorderEdgeEqualToEdge(EXImageBorderEdge borderEdge, EXImageBorderEdge equalToEdge)
{
  return (ABS(borderEdge.width - equalToEdge.width) < EXImageViewBorderThreshold)
  && (borderEdge.style == equalToEdge.style)
  && CGColorEqualToColor(borderEdge.color, equalToEdge.color);
}

BOOL EXImageBorderEdgesAllEqual(EXImageBorderEdges borderEdges)
{
  return EXImageBorderEdgeEqualToEdge(borderEdges.top, borderEdges.right)
  && EXImageBorderEdgeEqualToEdge(borderEdges.top, borderEdges.bottom)
  && EXImageBorderEdgeEqualToEdge(borderEdges.top, borderEdges.left);
}

BOOL EXImageBorderEdgeVisible(EXImageBorderEdge borderEdge)
{
  return borderEdge.color
  && (borderEdge.width >= EXImageViewBorderThreshold)
  && (borderEdge.style != RCTBorderStyleUnset);
}



EXImageCornerRadii EXImageCornerRadiiInit()
{
  EXImageCornerRadii cornerRadii;
  cornerRadii.all = -1;
  cornerRadii.topLeft = -1;
  cornerRadii.topRight = -1;
  cornerRadii.topStart = -1;
  cornerRadii.topEnd = -1;
  cornerRadii.bottomLeft = -1;
  cornerRadii.bottomRight = -1;
  cornerRadii.bottomStart = -1;
  cornerRadii.bottomEnd = -1;
  return cornerRadii;
}

BOOL EXImageCornerRadiiAllEqual(EXImageCornerRadii cornerRadii)
{
  return ABS(cornerRadii.topLeft - cornerRadii.topRight) < EXImageViewBorderThreshold &&
  ABS(cornerRadii.topLeft - cornerRadii.bottomLeft) < EXImageViewBorderThreshold &&
  ABS(cornerRadii.topLeft - cornerRadii.bottomRight) < EXImageViewBorderThreshold;
}

RCTCornerInsets EXImageGetCornerInsets(EXImageCornerRadii cornerRadii, UIEdgeInsets edgeInsets)
{
  return (RCTCornerInsets){{
    MAX(0, cornerRadii.topLeft - edgeInsets.left),
    MAX(0, cornerRadii.topLeft - edgeInsets.top),
  },
    {
      MAX(0, cornerRadii.topRight - edgeInsets.right),
      MAX(0, cornerRadii.topRight - edgeInsets.top),
    },
    {
      MAX(0, cornerRadii.bottomLeft - edgeInsets.left),
      MAX(0, cornerRadii.bottomLeft - edgeInsets.bottom),
    },
    {
      MAX(0, cornerRadii.bottomRight - edgeInsets.right),
      MAX(0, cornerRadii.bottomRight - edgeInsets.bottom),
    }};
}

EXImageCornerRadii EXImageCornerRadiiResolve(EXImageCornerRadii cornerRadii, UIUserInterfaceLayoutDirection layoutDirection, BOOL swapLeftRightInRTL, CGSize size)
{
  const BOOL isRTL = layoutDirection == UIUserInterfaceLayoutDirectionRightToLeft;
  const CGFloat radius = MAX(0, cornerRadii.all);
  
  EXImageCornerRadii result = EXImageCornerRadiiInit();
  
  if (swapLeftRightInRTL) {
    const CGFloat topStartRadius = EXImageDefaultIfNegativeTo(cornerRadii.topLeft, cornerRadii.topStart);
    const CGFloat topEndRadius = EXImageDefaultIfNegativeTo(cornerRadii.topRight, cornerRadii.topEnd);
    const CGFloat bottomStartRadius = EXImageDefaultIfNegativeTo(cornerRadii.bottomLeft, cornerRadii.bottomStart);
    const CGFloat bottomEndRadius = EXImageDefaultIfNegativeTo(cornerRadii.bottomRight, cornerRadii.bottomEnd);
    
    const CGFloat directionAwareTopLeftRadius = isRTL ? topEndRadius : topStartRadius;
    const CGFloat directionAwareTopRightRadius = isRTL ? topStartRadius : topEndRadius;
    const CGFloat directionAwareBottomLeftRadius = isRTL ? bottomEndRadius : bottomStartRadius;
    const CGFloat directionAwareBottomRightRadius = isRTL ? bottomStartRadius : bottomEndRadius;
    
    result.topLeft = EXImageDefaultIfNegativeTo(radius, directionAwareTopLeftRadius);
    result.topRight = EXImageDefaultIfNegativeTo(radius, directionAwareTopRightRadius);
    result.bottomLeft = EXImageDefaultIfNegativeTo(radius, directionAwareBottomLeftRadius);
    result.bottomRight = EXImageDefaultIfNegativeTo(radius, directionAwareBottomRightRadius);
  } else {
    const CGFloat directionAwareTopLeftRadius = isRTL ? cornerRadii.topEnd : cornerRadii.topStart;
    const CGFloat directionAwareTopRightRadius = isRTL ? cornerRadii.topStart : cornerRadii.topEnd;
    const CGFloat directionAwareBottomLeftRadius = isRTL ? cornerRadii.bottomEnd : cornerRadii.bottomStart;
    const CGFloat directionAwareBottomRightRadius = isRTL ? cornerRadii.bottomStart : cornerRadii.bottomEnd;
    
    result.topLeft =
    EXImageDefaultIfNegativeTo(radius, EXImageDefaultIfNegativeTo(cornerRadii.topLeft, directionAwareTopLeftRadius));
    result.topRight =
    EXImageDefaultIfNegativeTo(radius, EXImageDefaultIfNegativeTo(cornerRadii.topRight, directionAwareTopRightRadius));
    result.bottomLeft =
    EXImageDefaultIfNegativeTo(radius, EXImageDefaultIfNegativeTo(cornerRadii.bottomLeft, directionAwareBottomLeftRadius));
    result.bottomRight = EXImageDefaultIfNegativeTo(
                                                    radius, EXImageDefaultIfNegativeTo(cornerRadii.bottomRight, directionAwareBottomRightRadius));
  }
  
  // Get scale factors required to prevent radii from overlapping
  const CGFloat topScaleFactor = RCTZeroIfNaN(MIN(1, size.width / (result.topLeft + result.topRight)));
  const CGFloat bottomScaleFactor = RCTZeroIfNaN(MIN(1, size.width / (result.bottomLeft + result.bottomRight)));
  const CGFloat rightScaleFactor = RCTZeroIfNaN(MIN(1, size.height / (result.topRight + result.bottomRight)));
  const CGFloat leftScaleFactor = RCTZeroIfNaN(MIN(1, size.height / (result.topLeft + result.bottomLeft)));
  
  result.topLeft *= MIN(topScaleFactor, leftScaleFactor);
  result.topRight *= MIN(topScaleFactor, rightScaleFactor);
  result.bottomLeft *= MIN(bottomScaleFactor, leftScaleFactor);
  result.bottomRight *= MIN(bottomScaleFactor, rightScaleFactor);
  
  return result;
}

