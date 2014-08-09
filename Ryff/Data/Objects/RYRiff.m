//
//  RYRiff.m
//  Ryff
//
//  Created by Christopher Laganiere on 4/12/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import "RYRiff.h"

@implementation RYRiff

- (RYRiff*)initWithTitle:(NSString*)title duration:(NSTimeInterval)duration url:(NSURL*)url
{
    if (self = [super init])
    {
        _title    = title;
        _duration = duration;
        _URL      = url;
        _fileName = [[url pathComponents] lastObject];
    }
    return self;
}

+ (RYRiff*)riffFromDict:(NSDictionary *)riffDict
{
    NSString *title     = [riffDict objectForKey:@"title"];
    NSNumber *duration  = [riffDict objectForKey:@"duration"];
    NSURL *url          = [NSURL URLWithString:[riffDict objectForKey:@"link"]];
    
    RYRiff *newRiff = [[RYRiff alloc] initWithTitle:title duration:[duration floatValue] url:url];
    return newRiff;
}

@end
