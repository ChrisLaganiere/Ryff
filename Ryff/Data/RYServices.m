//
//  RYServices.m
//  Ryff
//
//  Created by Christopher Laganiere on 4/12/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import "RYServices.h"

// Data Objects
#import "RYUser.h"
#import "RYNewsfeedPost.h"
#import "RYRiff.h"

// Data Systems
#import "SSKeychain.h"

// Custom UI
#import "RYStyleSheet.h"

// Server
#import "AFHTTPRequestOperationManager.h"
#import "AFHTTPRequestOperation.h"

@implementation RYServices

static RYServices* _sharedInstance;
static RYUser* _loggedInUser;

+ (RYServices *)sharedInstance
{
    if (_sharedInstance == NULL)
    {
        _sharedInstance = [RYServices allocWithZone:NULL];
    }
    return _sharedInstance;
}

+ (RYUser *)loggedInUser
{
    if (_loggedInUser == NULL)
    {
        NSDictionary *userDict = [[NSUserDefaults standardUserDefaults] objectForKey:kLoggedInUserKey];
        if (userDict)
            _loggedInUser = [RYUser userFromDict:userDict];
    }
    return _loggedInUser;
}

#pragma mark -
#pragma mark - Extras
+ (NSAttributedString *)createAttributedTextWithPost:(RYNewsfeedPost *)post
{
    NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:
                           [RYStyleSheet boldFont], NSFontAttributeName, nil];
    NSDictionary *subAttrs = [NSDictionary dictionaryWithObjectsAndKeys:
                              [RYStyleSheet regularFont], NSFontAttributeName, nil];
    const NSRange range = NSMakeRange(0,post.user.username.length);
    
    // Create the attributed string (text + attributes)
    NSString *fullText = [NSString stringWithFormat:@"%@\n%@",post.user.username,post.content];
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:fullText
                                                                                       attributes:subAttrs];
    [attributedText setAttributes:attrs range:range];
    return attributedText;
}

#pragma mark -
#pragma mark - Registration

- (void) registerUserWithPOSTDict:(NSDictionary*)params forDelegate:(id<POSTDelegate>)delegate
{
    dispatch_async(dispatch_get_global_queue(2, 0), ^{
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        
        NSString *action = [NSString stringWithFormat:@"%@%@",host,kRegistrationAction];
        [manager POST:action parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSDictionary *dictionary = responseObject;
            
            if (dictionary[@"success"])
                [delegate postSucceeded:responseObject];
            else
                [delegate postFailed:responseObject];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [delegate postFailed:[error localizedDescription]];
        }];
    });
}


- (void) logInUserWithUsername:(NSString*)username Password:(NSString*)password forDelegate:(id<POSTDelegate>)delegate
{
    dispatch_async(dispatch_get_global_queue(2, 0), ^{
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        
        NSString *action = [NSString stringWithFormat:@"%@%@",host,kLogIn];
        
        NSDictionary *params = @{@"auth_username":username,@"auth_password":password};
        
        [manager POST:action parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSDictionary *dictionary = responseObject;
            
            if (dictionary[@"success"])
                [delegate postSucceeded:responseObject];
            else
                [delegate postFailed:responseObject];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [delegate postFailed:[error localizedDescription]];
        }];
    });
}

#pragma mark -
#pragma mark - Edit User

- (void) updateAvatar:(UIImage*)avatar forDelegate:(id<UpdateUserDelegate>)delegate
{
    if (![RYServices loggedInUser])
        return;
    
    NSDictionary *userDict = [[NSUserDefaults standardUserDefaults] objectForKey:kLoggedInUserKey];
    RYUser *userObject = [RYUser userFromDict:userDict];
    NSString *password = [SSKeychain passwordForService:@"ryff" account:userObject.username];
    
    if (userObject.username && password)
    {
        dispatch_async(dispatch_get_global_queue(2, 0), ^{
            AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
            NSString *action = [NSString stringWithFormat:@"%@%@",host,kUpdateUserAction];
            NSDictionary *params = @{@"auth_username":userObject.username,@"auth_password":password};
            
            [manager POST:action parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                
                if (avatar)
                {
                    NSData *imageData = UIImagePNGRepresentation(avatar);
                    [formData appendPartWithFileData:imageData name:@"avatar" fileName:@"avatar" mimeType:@"image/png"];
                }
                
            } success:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSDictionary *dictionary = responseObject;
                
                if (dictionary[@"success"])
                    [delegate updateSucceeded:[RYUser userFromDict:dictionary[@"user"]]];
                else
                    [delegate updateFailed:responseObject];
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                [delegate updateFailed:[error localizedDescription]];
            }];
        });
    }
}

// not set up yet
- (void) editUserInfo:(RYUser*)user
{
    if (![RYServices loggedInUser])
        return;
    
    NSString *password = [SSKeychain passwordForService:@"ryff" account:user.username];
    
    if (user.username && password)
        dispatch_async(dispatch_get_global_queue(2, 0), ^{
            AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
            
            NSString *action = [NSString stringWithFormat:@"%@%@",host,kUpdateUserAction];
            
            NSDictionary *params = @{@"auth_username":user.username,@"auth_password":password};
            
            [manager POST:action parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSDictionary *dictionary = responseObject;
                
                if (dictionary[@"success"])
                    NSLog(@"edit succeeded");
                else
                    NSLog(@"edit failed but post succeeded");
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"edit failed");
            }];
        });
}

- (void) deletePost:(RYNewsfeedPost*)post
{
    if (![RYServices loggedInUser])
        return;
    
    NSDictionary *userDict = [[NSUserDefaults standardUserDefaults] objectForKey:kLoggedInUserKey];
    RYUser *userObject = [RYUser userFromDict:userDict];
    NSString *password = [SSKeychain passwordForService:@"ryff" account:userObject.username];
    
    UIAlertView *failureAlert = [[UIAlertView alloc] initWithTitle:@"Post delete failed" message:[NSString stringWithFormat:@"Something went wrong and post was not deleted: %@",post.riff.title] delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
    
    if (userObject.username && password)
    {
        dispatch_async(dispatch_get_global_queue(2, 0), ^{
            AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
            
            NSString *action = [NSString stringWithFormat:@"%@%@",host,kDeletePostAction];
            
            NSDictionary *params = @{@"auth_username":userObject.username,@"auth_password":password, @"id" : @(post.postId)};
            
            [manager POST:action parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSDictionary *dictionary = responseObject;
                
                if (!dictionary[@"success"])
                    [failureAlert show];
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                [failureAlert show];
            }];
        });
    }
}

#pragma mark -
#pragma mark - Artist Suggester

- (void) parseArtists:(NSArray*)artistsArray
{
    NSMutableArray *objectiveArtists = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < artistsArray.count; i++)
    {
        NSDictionary *artistDict = artistsArray[i];
        RYUser *user = [RYUser userFromDict:artistDict];
        [objectiveArtists addObject:user];
    }
    
    if (_artistsDelegate)
        [_artistsDelegate retrievedArtists:objectiveArtists];
}

- (void) moreArtistsOfCount:(NSInteger)numArtists
{
    if (![RYServices loggedInUser])
        return;
    
    NSDictionary *userDict = [[NSUserDefaults standardUserDefaults] objectForKey:kLoggedInUserKey];
    RYUser *userObject = [RYUser userFromDict:userDict];
    NSString *password = [SSKeychain passwordForService:@"ryff" account:userObject.username];
    
    if (userObject.username && password)
        dispatch_async(dispatch_get_global_queue(2, 0), ^{
            
            AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
            
            NSDictionary *params = @{@"auth_username":userObject.username,@"auth_password":password,@"id":@(userObject.userId)};
            
            NSString *action = [NSString stringWithFormat:@"%@%@",host,kGetNearby];
            [manager POST:action parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSDictionary *dictionary = responseObject;
                if (dictionary[@"success"])
                {
                    NSArray *artists = dictionary[@"users"];
                    [self parseArtists:artists];
                }
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"Post error: %@",[error localizedDescription]);
            }];
        });
}
- (void) addFriend:(NSInteger)userId forDelegate:(id<FriendsDelegate>)delegate
{
    if (![RYServices loggedInUser])
        return;
    
    NSDictionary *userDict = [[NSUserDefaults standardUserDefaults] objectForKey:kLoggedInUserKey];
    RYUser *userObject = [RYUser userFromDict:userDict];
    NSString *password = [SSKeychain passwordForService:@"ryff" account:userObject.username];
    
    
    if (userObject.username && password)
        dispatch_async(dispatch_get_global_queue(2, 0), ^{
    
            AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
            
            NSDictionary *params = @{@"auth_username":userObject.username,@"auth_password":password,@"id":@(userId)};

            NSString *action = [NSString stringWithFormat:@"%@%@",host,kAddFriendAction];
            [manager POST:action parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSDictionary *dictionary = responseObject;
                if (dictionary[@"success"])
                    [delegate friendConfirmed];
                else
                    [delegate actionFailed];
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"Post error: %@",[error localizedDescription]);
                [delegate actionFailed];
            }];
        });
}
- (void) deleteFriend:(NSInteger)userId forDelegate:(id<FriendsDelegate>)delegate
{
    if (![RYServices loggedInUser])
        return;
    
    NSDictionary *userDict = [[NSUserDefaults standardUserDefaults] objectForKey:kLoggedInUserKey];
    RYUser *userObject = [RYUser userFromDict:userDict];
    NSString *password = [SSKeychain passwordForService:@"ryff" account:userObject.username];
    
    
    if (userObject.username && password)
        dispatch_async(dispatch_get_global_queue(2, 0), ^{
            
            AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
            NSDictionary *params = @{@"auth_username":userObject.username,@"auth_password":password,@"id":@(userObject.userId)};
            
            NSString *action = [NSString stringWithFormat:@"%@%@",host,kDeleteFriendAction];
            [manager POST:action parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSDictionary *dictionary = responseObject;
                if (dictionary[@"success"])
                    [delegate friendDeleted];
                else
                    [delegate actionFailed];
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"Post error: %@",[error localizedDescription]);
                [delegate actionFailed];
            }];
        });
}

#pragma mark -
#pragma mark - Newsfeed

+ (NSURL*)urlForRiff
{
    NSArray *pathComponents = [NSArray arrayWithObjects:
                               [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject],
                               @"riff.m4a",
                               nil];
    NSURL *outputFileURL = [NSURL fileURLWithPathComponents:pathComponents];
    return outputFileURL;
}

- (void) postRiffWithContent:(NSString*)content title:(NSString*)title duration:(NSNumber*)duration ForDelegate:(id<RiffDelegate>)riffDelegate
{
    if (![RYServices loggedInUser])
        return;
    
    NSDictionary *userDict = [[NSUserDefaults standardUserDefaults] objectForKey:kLoggedInUserKey];
    RYUser *userObject = [RYUser userFromDict:userDict];
    NSString *password = [SSKeychain passwordForService:@"ryff" account:userObject.username];
    
    if (!content)
        content = @"";
    if (!duration)
        duration = @0;
    
    if (userObject.username && password)
        dispatch_async(dispatch_get_global_queue(2, 0), ^{
                    
            AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
                    
            NSDictionary *params = @{@"auth_username":userObject.username,@"auth_password":password,@"id":@(userObject.userId), @"content":content, @"title":title,@"duration":duration};
            
            NSString *action = [NSString stringWithFormat:@"%@%@",host,kPostRiffAction];
            [manager POST:action parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                
                if ([[NSFileManager defaultManager] fileExistsAtPath:[[RYServices urlForRiff] path]])
                {
                    NSData *musicData = [NSData dataWithContentsOfFile:[[RYServices urlForRiff] path]];
                    [formData appendPartWithFileData:musicData name:@"riff" fileName:@"riff" mimeType:@"audio/mp4"];
                }
                
            }  success:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSDictionary *dictionary = responseObject;
                
                if (dictionary[@"success"])
                    [riffDelegate riffPostSucceeded];
                else
                    [riffDelegate riffPostFailed];
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                [riffDelegate riffPostFailed];
            }];
        });
}

- (void) getMyPostsForDelegate:(id<POSTDelegate>)delegate
{
    if (![RYServices loggedInUser])
        return;
    
    NSDictionary *userDict = [[NSUserDefaults standardUserDefaults] objectForKey:kLoggedInUserKey];
    RYUser *userObject = [RYUser userFromDict:userDict];
    NSString *password = [SSKeychain passwordForService:@"ryff" account:userObject.username];
    
    if (userObject.username && password)
        dispatch_async(dispatch_get_global_queue(2, 0), ^{
            
            AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
            NSDictionary *params = @{@"auth_username":userObject.username,@"auth_password":password};
            
            NSString *action = [NSString stringWithFormat:@"%@%@",host,kGetPosts];
            [manager POST:action parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSDictionary *dictionary = responseObject;
                if (dictionary[@"success"])
                    [delegate postSucceeded:responseObject];
                else
                    [delegate postFailed:nil];
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"Post error: %@",[error localizedDescription]);
                [delegate postFailed:[error localizedDescription]];
            }];
        });
}

- (void) getUserPostsForUser:(NSInteger)userId Delegate:(id<POSTDelegate>)delegate
{
    if (![RYServices loggedInUser])
        return;
    
    NSDictionary *userDict = [[NSUserDefaults standardUserDefaults] objectForKey:kLoggedInUserKey];
    RYUser *userObject = [RYUser userFromDict:userDict];
    NSString *password = [SSKeychain passwordForService:@"ryff" account:userObject.username];
    
    if (userObject.username && password)
        dispatch_async(dispatch_get_global_queue(2, 0), ^{
            
            AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
            
            NSDictionary *params = @{@"auth_username":userObject.username,@"auth_password":password, @"id":@(userId)};
            
            NSString *action = [NSString stringWithFormat:@"%@%@",host,kGetPosts];
            [manager POST:action parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSDictionary *dictionary = responseObject;
                if (delegate)
                {
                    if (dictionary[@"success"])
                        [delegate postSucceeded:responseObject];
                    else
                        [delegate postFailed:nil];
                }
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"Post error: %@",[error localizedDescription]);
                if (delegate)
                    [delegate postFailed:[error localizedDescription]];
            }];
        });
}

- (void) getFriendPostsForDelegate:(id<POSTDelegate>)delegate
{
    if (![RYServices loggedInUser])
        return;
    
    NSDictionary *userDict = [[NSUserDefaults standardUserDefaults] objectForKey:kLoggedInUserKey];
    RYUser *userObject = [RYUser userFromDict:userDict];
    NSString *password = [SSKeychain passwordForService:@"ryff" account:userObject.username];
    
    if (userObject.username && password)
        dispatch_async(dispatch_get_global_queue(2, 0), ^{
            
            AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
            NSDictionary *params = @{@"auth_username":userObject.username,@"auth_password":password};
            
            NSString *action = [NSString stringWithFormat:@"%@%@",host,kGetFriendsPosts];
            [manager POST:action parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSDictionary *dictionary = responseObject;
                if (dictionary[@"success"])
                    [delegate postSucceeded:responseObject];
                else
                    [delegate postFailed:nil];
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"Post error: %@",[error localizedDescription]);
                [delegate postFailed:[error localizedDescription]];
            }];
        });
}

- (void) upvotePost:(NSInteger)postID forDelegate:(id<UpvoteDelegate>)delegate
{
    if (![RYServices loggedInUser])
        return;
    
    NSDictionary *userDict = [[NSUserDefaults standardUserDefaults] objectForKey:kLoggedInUserKey];
    RYUser *userObject = [RYUser userFromDict:userDict];
    NSString *password = [SSKeychain passwordForService:@"ryff" account:userObject.username];
    
    if (userObject.username && password)
        dispatch_async(dispatch_get_global_queue(2, 0), ^{
            
            AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
            
            NSDictionary *params = @{@"auth_username":userObject.username,@"auth_password":password, @"id":@(postID)};
            
            NSString *action = [NSString stringWithFormat:@"%@%@",host,kUpvotePostAction];
            [manager POST:action parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSDictionary *dictionary = responseObject;
                if (dictionary[@"success"] && delegate)
                    [delegate upvoteSucceeded:[RYNewsfeedPost newsfeedPostWithDict:dictionary]];
                else
                    [delegate upvoteFailed:dictionary[@"error"]];
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                [delegate upvoteFailed:[error localizedDescription]];
            }];
        });
}

@end