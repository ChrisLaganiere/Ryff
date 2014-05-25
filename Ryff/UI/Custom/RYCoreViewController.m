//
//  RYCoreViewController.m
//  Ryff
//
//  Created by Christopher Laganiere on 4/12/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import "RYCoreViewController.h"

// Custom UI
#import "RYStyleSheet.h"

@interface RYCoreViewController ()

@end

@implementation RYCoreViewController

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.view setBackgroundColor:[RYStyleSheet backgroundColor]];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

@end
