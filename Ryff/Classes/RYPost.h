//
//  RYPost.h
//  Ryff
//
//  Created by Christopher Laganiere on 4/12/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RYPost;
@class RYUser;

@protocol RYPostDelegate <NSObject>
- (void)postUpdated:(RYPost *)post;
- (void)postUpdateFailed:(RYPost *)post reason:(NSString *)reason;
@end

@interface RYPost : NSObject <NSCopying>

@property (nonatomic, assign) NSInteger postId;
@property (nonatomic, strong) RYUser *user;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSURL *riffURL;
@property (nonatomic, assign) CGFloat duration;
@property (nonatomic, strong) NSDate *dateCreated;
@property (nonatomic, assign) BOOL isStarred;
@property (nonatomic, assign) BOOL isUpvoted;
@property (nonatomic, assign) NSInteger upvotes;

// Optional
@property (nonatomic, strong) NSString *content;
@property (nonatomic, strong) NSURL *imageURL;
@property (nonatomic, strong) NSURL *imageMediumURL;
@property (nonatomic, strong) NSURL *imageSmallURL;
@property (nonatomic, strong) NSURL *riffHQURL;
@property (nonatomic, strong) NSArray *tags;

// Delegate to notify when actions occur.
@property (nonatomic, weak) id<RYPostDelegate> delegate;

- (RYPost *)initWithPostId:(NSInteger)postId User:(RYUser *)user Content:(NSString*)content title:(NSString *)title riffURL:(NSURL*)riffURL duration:(CGFloat)duration dateCreated:(NSDate*)dateCreated isUpvoted:(BOOL)isUpvoted isStarred:(BOOL)isStarred upvotes:(NSInteger)upvotes;

+ (RYPost *)postWithDict:(NSDictionary*)postDict;
+ (NSArray *)postsFromDictArray:(NSArray *)dictArray;

// Actions

- (void)toggleStarred;

@end
