//
//  RYArtistViewController.m
//  Ryff
//
//  Created by Christopher Laganiere on 4/11/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import "RYArtistViewController.h"

// Data Managers
#import "RYServices.h"

// Data objects
#import "RYUser.h"

// Custom UI
#import "RYStyleSheet.h"
#import "BlockAlertView.h"

@interface RYArtistViewController () <FriendsDelegate>

@end

@implementation RYArtistViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // setup navbar buttons
    UIBarButtonItem *friends = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:self action:@selector(friendsHit:)];
    [friends setImage:[UIImage imageNamed:@"friend"]];
    [friends setTintColor:[RYStyleSheet baseColor]];
    [self.navigationItem setLeftBarButtonItem:friends];
    
    // setup navbar buttons
    UIBarButtonItem *next = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:self action:@selector(nextHit:)];
    [next setImage:[UIImage imageNamed:@"next"]];
    [next setTintColor:[RYStyleSheet baseColor]];
    [self.navigationItem setRightBarButtonItem:next];
    
    [self configureForArtist];
}

#pragma mark -
#pragma mark - Setup UI

- (void) setupFriendBarButtonItem:(UIImage*)image;
{
    UIButton* newButton =[UIButton buttonWithType:UIButtonTypeCustom];
    [newButton addTarget:self action:@selector(friendsHit:)
       forControlEvents:UIControlEventTouchUpInside];
    [newButton setImage:image forState:UIControlStateNormal];
    newButton.frame = CGRectMake(0, 0, image.size.width, image.size.height);
    UIBarButtonItem *butt4 = [[UIBarButtonItem alloc]initWithCustomView:newButton];
    
    [self.navigationItem setLeftBarButtonItem:butt4];
}

#pragma mark -
#pragma mark - Prep

- (void) configureForArtist
{
    [_profileImage setImage:_artist.profileImage];
    [_nameText setText:_artist.firstName];
    [_bioText setText:_artist.bio];
}

#pragma mark -
#pragma mark - Bar Button Methods

- (void) friendsHit:(UIBarButtonItem*)sender
{
    NSInteger numImages = 3;
    NSMutableArray *images = [[NSMutableArray alloc] init];
    
    // load all rotations of these images
    for (NSInteger i = 0; i < 4; i++)
    {
        for (NSInteger imNum = 1; imNum <= numImages; imNum++)
        {
            UIImage *loadingImage = [RYStyleSheet maskWithColor:[RYStyleSheet baseColor] forImageNamed:[NSString stringWithFormat:@"Cylindric_%d",imNum]];
            loadingImage = [RYStyleSheet image:loadingImage RotatedByRadians:M_PI_2*i];
            [images addObject:loadingImage];
        }
    }
    
    UIImage *workingCycle = [UIImage animatedImageWithImages:images duration:1.5];
    [self setupFriendBarButtonItem:workingCycle];
    
    [self toggleFriendStatus];
}

#pragma mark -
#pragma mark - Friend Delegate

- (void) friendConfirmed
{
    [self setupFriendBarButtonItem:[RYStyleSheet maskWithColor:[RYStyleSheet baseColor] forImageNamed:@"checkmark"]];
    _friends = YES;
}
- (void) friendDeleted
{
    [self setupFriendBarButtonItem:[RYStyleSheet maskWithColor:[RYStyleSheet baseColor] forImageNamed:@"friend"]];
    _friends = NO;
}
- (void) actionFailed
{
    if (_friends)
        [self setupFriendBarButtonItem:[RYStyleSheet maskWithColor:[RYStyleSheet baseColor] forImageNamed:@"checkmark"]];
    else
        [self setupFriendBarButtonItem:[RYStyleSheet maskWithColor:[RYStyleSheet baseColor] forImageNamed:@"friend"]];
}

- (void) toggleFriendStatus
{
    if (!_friends)
        [[RYServices sharedInstance] addFriend:_artist.userId forDelegate:self];
    else
        [[RYServices sharedInstance] deleteFriend:_artist.userId forDelegate:self];
}

- (void) nextHit:(UIBarButtonItem*)sender
{
    
}

@end
