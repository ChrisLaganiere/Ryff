//
//  RYNewsfeedContainerViewController.m
//  Ryff
//
//  Created by Christopher Laganiere on 8/16/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import "RYNewsfeedContainerViewController.h"

@interface RYNewsfeedContainerViewController ()

@property (weak, nonatomic) IBOutlet UIView *newsfeedContainerView;
@property (weak, nonatomic) IBOutlet UIView *audioDeckContainerView;

@end

@implementation RYNewsfeedContainerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [_newsfeedContainerView setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
    [_audioDeckContainerView setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self configureLayout:[[UIApplication sharedApplication] statusBarOrientation] duration:0.0f];
}

- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self configureLayout:toInterfaceOrientation duration:duration];
}

#pragma mark -
#pragma mark - Layout

- (void) configureLayout:(UIInterfaceOrientation)orientation duration:(CGFloat)duration
{
    CGSize parentSize = self.parentViewController.view.frame.size;
    CGRect newsfeedFrame;
    if (UIInterfaceOrientationIsPortrait(orientation))
    {
        // Portrait
        newsfeedFrame = CGRectMake(0, 0, MIN(parentSize.width, parentSize.height), self.view.frame.size.height);
    }
    else
    {
        // Landscape
        newsfeedFrame = CGRectMake(0, 0, MAX(parentSize.width, parentSize.height)-400, self.view.frame.size.height);
    }
    
    [UIView animateWithDuration:duration animations:^{
        
        [_audioDeckContainerView setFrame:CGRectMake(newsfeedFrame.size.width, 0, 400, newsfeedFrame.size.height)];
        [_newsfeedContainerView setFrame:newsfeedFrame];
        
    } completion:nil];
}

@end
