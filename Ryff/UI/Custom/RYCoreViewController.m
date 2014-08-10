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
    
    [self.navigationController.navigationBar setBarTintColor:[RYStyleSheet backgroundColor]];
    [self.navigationController.navigationBar setTranslucent:NO];
    
    NSDictionary *navbarTitleAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor],
                                            NSFontAttributeName: [UIFont fontWithName:kRegularFont size:24.0f]};
    
    [[UINavigationBar appearance] setTitleTextAttributes:navbarTitleAttributes];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

@end
