//
//  RYDataManager.m
//  Ryff
//
//  Created by Christopher Laganiere on 7/2/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import "RYDataManager.h"

// Data Managers
#import "RYMediaEditor.h"

// Frameworks
#import "AFHTTPRequestOperation.h"

@implementation RYDataManager

static RYDataManager *_sharedInstance;
+ (instancetype)sharedInstance
{
    if (_sharedInstance == NULL)
    {
        _sharedInstance = [RYDataManager allocWithZone:NULL];
    }
    return _sharedInstance;
}

/*
 Helper function that gives NSURL to next available track path, incrementing name of track (track3.m4a, for example) until not taken.
 */
+ (NSURL*) urlForNextTrack
{
    NSURL *trackPath;
    
    NSString *documentDirPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *trackDir        = [documentDirPath stringByAppendingPathComponent:@"UserTracks"];
    NSError *error            = nil;
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:trackDir isDirectory:nil])
        [[NSFileManager defaultManager] createDirectoryAtPath:trackDir withIntermediateDirectories:NO attributes:nil error:&error];
    
    NSInteger trackNum = 0;
    do {
        trackNum++;
        NSString *trackString = [[trackDir stringByAppendingPathComponent:[NSString stringWithFormat:@"track%ld%@",(long)trackNum,kMediaFileType]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];;
        trackPath = [NSURL fileURLWithPath:trackString];
    } while ([[NSFileManager defaultManager] fileExistsAtPath:[trackPath path]]);
    return trackPath;
}

/*
 Helper method to save a remote riff file to the device, as a track for use in creating a new riff.
 */
- (void) saveRiffAsTrack:(NSURL*)riffURL forDelegate:(id<TrackDownloadDelegate>)delegate
{
    NSURLRequest *request = [NSURLRequest requestWithURL:riffURL];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    NSURL* localURL = [RYDataManager urlForNextTrack];
    operation.outputStream = [NSOutputStream outputStreamToFileAtPath:[localURL path] append:NO];
    
    [operation setDownloadProgressBlock:^(NSUInteger bytesRead, NSInteger totalBytesRead, NSInteger totalBytesExpectedToRead) {
        if (delegate && [delegate respondsToSelector:@selector(track:DownloadProgressed:)])
        {
            CGFloat downloadProgress = totalBytesRead / (CGFloat)totalBytesExpectedToRead;
            [delegate track:riffURL DownloadProgressed:downloadProgress];
        }
    }];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (delegate && [delegate respondsToSelector:@selector(track:FinishedDownloading:)])
            [delegate track:riffURL FinishedDownloading:localURL];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (delegate && [delegate respondsToSelector:@selector(track:DownloadFailed:)])
            [delegate track:riffURL DownloadFailed:[error localizedDescription]];
    }];
    [operation start];
}

@end