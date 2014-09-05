//
//  RYRiffCell.h
//  Ryff
//
//  Created by Christopher Laganiere on 7/24/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kRiffCellWidthMinusText isIpad ? 380.0f : 85.0f
#define kRiffCellWidthMinusTextNoImage isIpad ? 195.0f : 85.0f
#define kRiffCellHeightMinusText 130.0f
#define kRiffCellMinimumHeight 250.0f

@protocol RiffCellDelegate <NSObject>
- (void) playerControlAction:(NSInteger)riffIndex;
- (void) avatarAction:(NSInteger)riffIndex;
- (void) upvoteAction:(NSInteger)riffIndex;
- (void) repostAction:(NSInteger)riffIndex;
- (void) starAction:(NSInteger)riffIndex;
@end

@class RYNewsfeedPost;
@class RYSocialTextView;

@interface RYRiffCell : UITableViewCell

@property (nonatomic, weak) id<RiffCellDelegate> delegate;

@property (nonatomic, assign) NSInteger riffIndex;

@property (weak, nonatomic) IBOutlet RYSocialTextView *socialTextView;

- (void) configureForPost:(RYNewsfeedPost *)post riffIndex:(NSInteger)riffIndex delegate:(id<RiffCellDelegate>)delegate;

@end
