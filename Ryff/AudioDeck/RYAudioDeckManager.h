//
//  RYAudioDeckManager.h
//  Ryff
//
//  Created by Christopher Laganiere on 8/10/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kTrackChangedNotification @"AudioDeckTrackChanged"
#define kPlaylistChangedNotification @"AudioDeckPlaylistChanged"
#define kDownloadProgressNotification @"AudioDeckDownloadProgressChanged"

@class RYNewsfeedPost;

@protocol AudioDeckDelegate <NSObject>
@optional
- (void) riffPlaylistUpdated;
- (void) trackChanged;
- (void) post:(RYNewsfeedPost *)post playbackTimeChanged:(CGFloat)time progress:(CGFloat)progress;
- (void) post:(RYNewsfeedPost *)post downloadProgressChanged:(CGFloat)progress;
@end

@interface RYAudioDeckManager : NSObject

@property (nonatomic, weak) id<AudioDeckDelegate> delegate;

+ (instancetype) sharedInstance;

// Media Control
- (void) playTrack:(BOOL)playTrack;
- (void) setPlaybackProgress:(CGFloat)progress;
- (void) setVolume:(CGFloat)volume;
- (void) skipTrack;

// Media
- (CGFloat) currentPlaybackProgress;
- (CGFloat) currentVolume;
- (BOOL) isPlaying;

// Data Control
- (void) forcePostToTop:(RYNewsfeedPost *)post;
- (void) addPostToPlaylist:(RYNewsfeedPost *)post;
- (void) movePostFromPlaylistIndex:(NSInteger)playlistIdx toIndex:(NSInteger)newPlaylistIdx;
- (void) removePostFromPlaylist:(RYNewsfeedPost *)post;
- (NSInteger) idxOfDownload:(RYNewsfeedPost *)post;
- (NSInteger) idxInPlaylistOfPost:(RYNewsfeedPost *)post;
- (BOOL) playlistContainsPost:(NSInteger)postID;
- (BOOL) playlistContainsFile:(NSString *)fileName;

// Data
- (RYNewsfeedPost *)currentlyPlayingPost;
- (NSArray *)riffPlaylist;
- (NSArray *)downloadQueue;

@end
