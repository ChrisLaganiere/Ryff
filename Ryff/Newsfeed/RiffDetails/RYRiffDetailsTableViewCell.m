//
//  RYRiffDetailsTableViewCell.m
//  Ryff
//
//  Created by Christopher Laganiere on 7/30/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import "RYRiffDetailsTableViewCell.h"

// Data Managers
#import "RYStyleSheet.h"
#import "RYServices.h"

// Data Objects
#import "RYNewsfeedPost.h"
#import "RYRiff.h"
#import "RYUser.h"

// Custom UI
#import "RYPlayControl.h"

// Categories
#import "UIImageView+SGImageCache.h"

@interface RYRiffDetailsTableViewCell () <UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UIView *wrapperView;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UIView *actionsWrapperView;
@property (weak, nonatomic) IBOutlet UIButton *upvoteButton;
@property (weak, nonatomic) IBOutlet UIButton *repostButton;
@property (weak, nonatomic) IBOutlet UIButton *followButton;
@property (weak, nonatomic) IBOutlet UILabel *karmaLabel;
@property (weak, nonatomic) IBOutlet UILabel *postLabel;
@property (weak, nonatomic) IBOutlet RYPlayControl *playControl;
@property (weak, nonatomic) IBOutlet UISlider *progressSlider;
@property (weak, nonatomic) IBOutlet UILabel *durationLabel;

// Data
@property (nonatomic, weak) id<RiffDetailsDelegate> delegate;

@end

@implementation RYRiffDetailsTableViewCell

- (void) awakeFromNib
{
    [super awakeFromNib];
    
    [_repostButton setTintColor:[RYStyleSheet audioActionColor]];
    [_followButton setTintColor:[RYStyleSheet audioActionColor]];
    [_progressSlider setTintColor:[RYStyleSheet audioActionColor]];
    
    [_karmaLabel setFont:[UIFont fontWithName:kRegularFont size:21.0f]];
    [_usernameLabel setFont:[UIFont fontWithName:kRegularFont size:24.0f]];
    
    [_playControl configureWithFrame:_playControl.bounds];
    
    UITapGestureRecognizer *playControlGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(playControlHit:)];
    [_playControl addGestureRecognizer:playControlGesture];
    [_playControl setBackgroundColor:[UIColor clearColor]];
    
    UITapGestureRecognizer *avatarGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(avatarImageTapped:)];
    [_avatarImageView addGestureRecognizer:avatarGesture];
    [_avatarImageView setUserInteractionEnabled:YES];
    [_avatarImageView.layer setCornerRadius:_avatarImageView.frame.size.width/2];
    [_avatarImageView setClipsToBounds:YES];
}

- (void) configureWithPost:(RYNewsfeedPost *)post delegate:(id<RiffDetailsDelegate>)delegate
{
    _delegate = delegate;
    
    [_postLabel setAttributedText:[RYStyleSheet createProfileAttributedTextWithPost:post]];
    
    NSString *usernameText = (post.user.nickname && post.user.nickname.length > 0) ? post.user.nickname : post.user.username;
    [_usernameLabel setText:usernameText];
    
    if (post.user.avatarURL)
        [_avatarImageView setImageForURL:post.user.avatarURL placeholder:[UIImage imageNamed:@"user"]];
    else
        [_avatarImageView setImage:[UIImage imageNamed:@"user"]];
    
    if (post.isUpvoted)
    {
        [_upvoteButton setTintColor:[RYStyleSheet audioActionHighlightedColor]];
        [_karmaLabel setTextColor:[RYStyleSheet audioActionHighlightedColor]];
    }
    else
    {
        [_upvoteButton setTintColor:[RYStyleSheet audioActionColor]];
        [_karmaLabel setTextColor:[RYStyleSheet audioActionColor]];
    }
    
    if (post.user && (post.user.userId == [RYServices loggedInUser].userId))
        [_followButton setHidden:YES];
    else
        [_followButton setHidden:NO];
    
    [_karmaLabel setText:[NSString stringWithFormat:@"%ld",(long)post.upvotes]];
}

- (void) setPlayProgress:(CGFloat)progress
{
    [_progressSlider setValue:progress];
}

- (void) shouldPause:(BOOL)pause
{
    if (pause)
        [_playControl stopPlaying];
    else
        [_playControl animatePlaying];
}

#pragma mark -
#pragma mark - Actions

- (IBAction)upvoteButtonHit:(id)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(riffUpvoteAction)])
        [_delegate riffUpvoteAction];
}

- (IBAction)repostButtonHit:(id)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(riffRepostAction)])
        [_delegate riffRepostAction];
}

- (IBAction)followButtonHit:(id)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(riffFollowAction)])
        [_delegate riffFollowAction];
}

- (IBAction)progressSliderChanged:(id)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(riffProgressSliderChanged:)])
        [_delegate riffProgressSliderChanged:((UISlider *)sender).value];
}

- (void) playControlHit:(UITapGestureRecognizer *)tapGesture
{
    if (_delegate && [_delegate respondsToSelector:@selector(riffPlayControlAction)])
        [_delegate riffPlayControlAction];
}

- (void) avatarImageTapped:(UITapGestureRecognizer *)tapGesture
{
    if (_delegate && [_delegate respondsToSelector:@selector(riffAvatarTapAction)])
        [_delegate riffAvatarTapAction];
}

@end
