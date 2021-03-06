/**
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "ABI34_0_0RCTAnimatedNode.h"

@class ABI34_0_0RCTUIManager;
@class ABI34_0_0RCTViewPropertyMapper;

@interface ABI34_0_0RCTPropsAnimatedNode : ABI34_0_0RCTAnimatedNode

- (void)connectToView:(NSNumber *)viewTag
             viewName:(NSString *)viewName
            uiManager:(ABI34_0_0RCTUIManager *)uiManager;

- (void)disconnectFromView:(NSNumber *)viewTag;

- (void)restoreDefaultValues;

@end
