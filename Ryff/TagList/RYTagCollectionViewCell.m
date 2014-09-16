//
//  RYTagCollectionViewCell.m
//  Ryff
//
//  Created by Christopher Laganiere on 9/15/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import "RYTagCollectionViewCell.h"

// Data Objects
#import "RYTag.h"
#import "RYPost.h"

// Categories
#import "UIImageView+SGImageCache.h"

@interface RYTagCollectionViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIView *darkenView;
@property (weak, nonatomic) IBOutlet UILabel *tagLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;

// Data
@property (nonatomic, strong) RYTag *currentTag;

@end

@implementation RYTagCollectionViewCell

- (void) configureWithTag:(RYTag *)tag
{
    _currentTag = tag;
    
    // set image
    if (tag.trendingPost)
        [_imageView setImageForURL:tag.trendingPost.imageURL.absoluteString placeholder:nil];
    else
        [tag retrieveTrendingPost];
    
    _tagLabel.text = tag.tag;
    _descriptionLabel.text = [NSString stringWithFormat:@"%ld Posts",(long)tag.numPosts];
}

#pragma mark -
#pragma mark - LifeCycle

- (void) awakeFromNib
{
    [super awakeFromNib];
    
    _tagLabel.font = [UIFont fontWithName:kBoldFont size:21.0f];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tagUpdated:) name:kRetrievedTrendingPostNotification object:nil];
}

#pragma mark - Notifications

- (void) tagUpdated:(NSNotification *)notification
{
    if (notification.userInfo[@"tag"] && [notification.userInfo[@"tag"] isEqualToString:_currentTag.tag])
        [self configureWithTag:_currentTag];
}

@end
