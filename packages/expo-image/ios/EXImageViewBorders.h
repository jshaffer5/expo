// Copyright 2020-present 650 Industries. All rights reserved.

#import <React/RCTBorderStyle.h>
#import <React/RCTBorderDrawing.h>

typedef struct {
  CGFloat width;
  CGColorRef color;
  RCTBorderStyle style;
} EXImageBorderEdge;

typedef struct {
  EXImageBorderEdge all;
  EXImageBorderEdge top;
  EXImageBorderEdge right;
  EXImageBorderEdge bottom;
  EXImageBorderEdge left;
  EXImageBorderEdge start;
  EXImageBorderEdge end;
} EXImageBorderEdges;

typedef struct {
  CGFloat all;
  CGFloat topLeft;
  CGFloat topRight;
  CGFloat topStart;
  CGFloat topEnd;
  CGFloat bottomLeft;
  CGFloat bottomRight;
  CGFloat bottomStart;
  CGFloat bottomEnd;
} EXImageCornerRadii;

EXImageBorderEdges EXImageBorderEdgesInit();
EXImageBorderEdge EXImageBorderEdgeMake(CGFloat width, CGColorRef color, RCTBorderStyle style);
EXImageBorderEdges EXImageBorderEdgesResolve(EXImageBorderEdges borderEdges, UIUserInterfaceLayoutDirection layoutDirection, BOOL swapLeftRightInRTL);
BOOL EXImageBorderEdgeEqualToEdge(EXImageBorderEdge borderEdge, EXImageBorderEdge equalToEdge);
BOOL EXImageBorderEdgesAllEqual(EXImageBorderEdges borderEdges);
BOOL EXImageBorderEdgeVisible(EXImageBorderEdge borderEdge);
void EXImageBorderEdgesRelease(EXImageBorderEdges borderEdges);

EXImageCornerRadii EXImageCornerRadiiInit();
EXImageCornerRadii EXImageCornerRadiiResolve(EXImageCornerRadii cornerRadii, UIUserInterfaceLayoutDirection layoutDirection, BOOL swapLeftRightInRTL, CGSize size);
RCTCornerInsets EXImageGetCornerInsets(EXImageCornerRadii cornerRadii, UIEdgeInsets edgeInsets);
BOOL EXImageCornerRadiiAllEqual(EXImageCornerRadii cornerRadii);
