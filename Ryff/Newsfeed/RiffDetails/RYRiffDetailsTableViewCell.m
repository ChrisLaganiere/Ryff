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

// Data Objects
#import "RYNewsfeedPost.h"
#import "RYRiff.h"
#import "RYUser.h"

// Categories
#import "UIImageView+SGImageCache.h"

@interface RYRiffDetailsTableViewCell () <UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *actionLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@end

@implementation RYRiffDetailsTableViewCell

- (void) awakeFromNib
{
    [super awakeFromNib];
    
    UITapGestureRecognizer *avatarGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(avatarImageTapped:)];
    [_avatarImageView addGestureRecognizer:avatarGesture];
    [_avatarImageView setUserInteractionEnabled:YES];
    [RYStyleSheet styleProfileImageView:_avatarImageView];
}

- (void) configureWithPost:(RYNewsfeedPost *)post actionString:(NSString *)actionString delegate:(id<RiffDetailsDelegate>)delegate
{
    _delegate = delegate;
    
    NSMutableAttributedString *username = [[NSMutableAttributedString alloc] initWithString:post.user.username attributes:@{NSFontAttributeName: [UIFont fontWithName:kBoldFont size:18.0f]}];
    NSAttributedString *action   = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" %@ %@", actionString, post.riff.title] attributes:@{NSFontAttributeName : [UIFont fontWithName:kRegularFont size:18.0f]}];
    
    [username appendAttributedString:action];
    [_actionLabel setAttributedText:username];
    
    [_timeLabel setAttributedText:[[NSAttributedString alloc] initWithString:@"2 minutes ago" attributes:@{NSFontAttributeName: [UIFont fontWithName:kItalicFont size:18.0f]}]];
    
    [_avatarImageView setImageForURL:post.user.avatarURL placeholder:[UIImage imageNamed:@"user"]];
    
    [self setBackgroundColor:[UIColor clearColor]];
}

#pragma mark -
#pragma mark - Actions

- (void) avatarImageTapped:(UITapGestureRecognizer *)tapGesture
{
    if (_delegate && [_delegate respondsToSelector:@selector(riffAvatarTapAction)])
        [_delegate riffAvatarTapAction];
}

@end