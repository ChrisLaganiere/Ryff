//
//  RYRiffDetailsViewController.h
//  Ryff
//
//  Created by Christopher Laganiere on 7/30/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RYRiffStreamingCoreViewController.h"

@interface RYRiffDetailsViewController : RYRiffStreamingCoreViewController

- (void) configureForPost:(RYPost *)post;
- (void) addBackButton;

@property (nonatomic, assign) BOOL shouldPreventNavigation;

@end
