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

// Data Systems
#import "SSKeychain.h"

// Custom UI
#import "RYStyleSheet.h"

// Server
#import "AFHTTPRequestOperationManager.h"
#import "AFHTTPRequestOperation.h"

@implementation RYServices

static RYServices* _sharedInstance;

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
    return [RYUser patrick];
}

#pragma mark -
#pragma mark - Extras
+ (NSAttributedString *)createAttributedTextWithPost:(RYNewsfeedPost *)post
{
    NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:
                           [RYStyleSheet boldFont], NSFontAttributeName, nil];
    NSDictionary *subAttrs = [NSDictionary dictionaryWithObjectsAndKeys:
                              [RYStyleSheet baseFont], NSFontAttributeName, nil];
    const NSRange range = NSMakeRange(0,post.username.length);
    
    // Create the attributed string (text + attributes)
    NSString *fullText = [NSString stringWithFormat:@"%@ %@",post.username,post.mainText];
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:fullText
                                                                                       attributes:subAttrs];
    [attributedText setAttributes:attrs range:range];
    return attributedText;
}

#pragma mark -
#pragma mark - Server

- (void) registerUserWithPOSTDict:(NSDictionary*)params avatar:(UIImage*)image forDelegate:(id<POSTDelegate>)delegate
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    NSString *action = [NSString stringWithFormat:@"%@%@",host,kRegistrationAction];
    [manager POST:action parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        
        if (image)
        {
            NSData *imageData = UIImagePNGRepresentation(image);
            [formData appendPartWithFileData:imageData name:@"avatar" fileName:@"avatar" mimeType:@"image/png"];
        }
        
    }  success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *dictionary = responseObject;
        
        if (dictionary[@"success"])
            [delegate postSucceeded:responseObject];
        else
            [delegate postFailed];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Post error: %@",[error localizedDescription]);
        [delegate postFailed];
    }];
}

- (void) submitPOST:(NSString *)actionDestination withDict:(NSDictionary*)params forDelegate:(id<POSTDelegate>)delegate
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    //manager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    NSString *action = [NSString stringWithFormat:@"%@%@",host,actionDestination];
    [manager POST:action parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *dictionary = responseObject;
        
        if (dictionary[@"success"])
            [delegate postSucceeded:responseObject];
        else
            [delegate postFailed];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Post error: %@",[error localizedDescription]);
        [delegate postFailed];
    }];
}

- (void) submitAuthenticatedRest_POST:(NSString *)actionDestination withDict:(NSDictionary*)jsonDict forDelegate:(id<POSTDelegate>)delegate
{
    NSString *username = [[NSUserDefaults standardUserDefaults] valueForKey:@"loggedInUser"];
    NSString *password = @"";
    if (!username)
        username = @"";
    else
    {
        password = [SSKeychain passwordForService:@"ryff" account:username];
    }
    
    // it all starts with a manager
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    // in my case, I'm in prototype mode, I own the network being used currently,
    // so I can use a self generated cert key, and the following line allows me to use that
    manager.securityPolicy.allowInvalidCertificates = YES;
    
    // No matter the serializer, they all inherit a battery of header setting APIs
    // Here we do Basic Auth, never do this outside of HTTPS
    [manager.requestSerializer
     setAuthorizationHeaderFieldWithUsername:username
     password:password];
    
    // Now we can just POST it to our target URL (soon to be https).
    // This will return immediately, when the transaction has finished,
    // one of either the success or failure blocks will fire
    [manager
     POST: [NSString stringWithFormat:@"%@",actionDestination]
     parameters: jsonDict
     success:^(AFHTTPRequestOperation *operation, id responseObject){
         [delegate postSucceeded:responseObject];
     } failure:^(AFHTTPRequestOperation *operation, NSError *error){
         [delegate postFailed];
     }];
}




/*
- (NSMutableDictionary*) jsonDict
{
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    result[@"serial_id"] = self.serialID;
    result[@"latitude"] = [NSNumber numberWithDouble: self.location.latitude];
    result[@"longitude"] = [NSNumber numberWithDouble: self.location.longitude];
    result[@"name"] = self.name;
    if ([self hasPhoto])
    {
        result[@"photo-jpeg"] = [UIImageJPEGRepresentation(self.photo, 0.5)
                                 base64EncodedStringWithOptions: NSDataBase64Encoding76CharacterLineLength];
    }
    return result;
}
*/

@end