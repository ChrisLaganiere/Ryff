//
//  RYServices.h
//  Ryff
//
//  Created by Christopher Laganiere on 4/12/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RYUser;

@interface RYServices : NSObject

+ (RYServices *)sharedInstance;

+ (RYUser *) loggedInUser;

@end
