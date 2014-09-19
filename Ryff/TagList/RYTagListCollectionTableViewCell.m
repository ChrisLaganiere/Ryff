//
//  RYTagListCollectionTableViewCell.m
//  Ryff
//
//  Created by Christopher Laganiere on 9/15/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import "RYTagListCollectionTableViewCell.h"

// Custom UI
#import "RYTagCollectionViewCell.h"

// Data Managers
#import "RYStyleSheet.h"

// Data Objects
#import "RYTagList.h"

#define kTagCellReuseID @"tagCell"

@interface RYTagListCollectionTableViewCell () <TagListDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

// Data
@property (nonatomic, strong) RYTagList *tagList;

@end

@implementation RYTagListCollectionTableViewCell

- (void) configureWithTagList:(RYTagList *)tagList delegate:(id<TagListCollectionDelegate>)delegate
{
    _delegate         = delegate;
    _tagList          = tagList;
    _tagList.delegate = self;
    _titleLabel.text  = tagList.listTitle;
    
    self.backgroundColor = [UIColor clearColor];
}

#pragma mark -
#pragma mark - LifeCycle

- (void) awakeFromNib
{
    [super awakeFromNib];
    
    _collectionView.contentInset = UIEdgeInsetsMake(0, 17.5, 0, 17.5);
    _collectionView.backgroundColor = [UIColor clearColor];
    
    _titleLabel.textColor = [UIColor colorWithWhite:0.0f alpha:0.6f];
    _titleLabel.font = [UIFont fontWithName:kBoldFont size:21.0f];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

#pragma mark -
#pragma mark - TagList Delegate

- (void) tagsUpdated
{
    [_collectionView reloadData];
}

#pragma mark -
#pragma mark - CollectionView Data Source

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _tagList.list.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    RYTag *tag = _tagList.list[indexPath.row];
    RYTagCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kTagCellReuseID forIndexPath:indexPath];
    [cell configureWithTag:tag];
    return cell;
}
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

#pragma mark -
#pragma mark - CollectionView Delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    RYTag *selectedTag = _tagList.list[indexPath.row];
    if (_delegate && [_delegate respondsToSelector:@selector(tagSelected:)])
        [_delegate tagSelected:selectedTag];
}

#pragma mark -
#pragma mark - CollectionView Flow Delegate

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(150, 150);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsZero;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 20.0f;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 20.0f;
}

@end
