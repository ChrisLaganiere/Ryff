//
//  RYMediaEditor.h
//  Ryff
//
//  Created by Christopher Laganiere on 6/19/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kMediaFileType @".m4a"

@interface RYMediaEditor : NSObject

+ (instancetype) sharedInstance;

+ (NSURL*) pathForNextTrack;

- (void) mergeAudioData:(NSArray*)trackURLs;

@end
