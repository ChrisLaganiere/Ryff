//
//  RYTag.m
//  Ryff
//
//  Created by Christopher Laganiere on 8/19/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import "RYTag.h"

@implementation RYTag

- (RYTag *)initWithTag:(NSString *)tag numUsers:(NSInteger)numUsers numPosts:(NSInteger)numPosts
{
    if (self = [super init])
    {
        _tag        = tag;
        _numPosts   = numPosts;
        _numUsers   = numUsers;
    }
    return self;
}

+ (RYTag *)tagFromDict:(NSDictionary *)tagDict
{
    NSString *tag = tagDict[@"tag"];
    NSInteger numUsers = [tagDict[@"num_users"] integerValue];
    NSInteger numPosts = [tagDict[@"num_posts"] integerValue];
    return [[RYTag alloc] initWithTag:tag numUsers:numUsers numPosts:numPosts];
}

+ (NSArray *)tagsFromDictArray:(NSArray *)tagDictArray
{
    NSMutableArray *tagArray = [[NSMutableArray alloc] initWithCapacity:tagDictArray.count];
    for (NSDictionary *tagDict in tagDictArray)
    {
        [tagArray addObject:[RYTag tagFromDict:tagDict]];
    }
    return tagArray;
}

+ (NSArray *)getTagTags:(NSArray *)tags
{
    NSMutableArray *tagTagArray = [[NSMutableArray alloc] initWithCapacity:tags.count];
    for (RYTag *tag in tags)
    {
        [tagTagArray addObject:tag.tag];
    }
    return tagTagArray;
}

@end
