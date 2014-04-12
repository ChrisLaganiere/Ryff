//
//  RYRiffTrackTableViewCell.h
//  Ryff
//
//  Created by Christopher Laganiere on 4/11/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RYRiff;
@class RMDownloadIndicator;

@interface RYRiffTrackTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *statusImageView;
@property (weak, nonatomic) IBOutlet UILabel *riffTitleText;
@property (weak, nonatomic) IBOutlet UILabel *riffLengthText;

@property (nonatomic, strong) RMDownloadIndicator *downloadIndicator;

// Duration objects
@property (nonatomic, assign) NSInteger riffDuration;
@property (nonatomic, assign) NSInteger durationCountdown;
@property (nonatomic, assign) BOOL paused, playing, shouldBePlaying;
@property (nonatomic, strong) NSTimer *durationTimer;
@property (nonatomic, strong) NSTimer *refreshTimer;

- (void) configureForRiff:(RYRiff *)riff;
- (void) startDownloading;
- (void) updateDownloadIndicatorWithBytes:(CGFloat)bytesFinished outOf:(CGFloat)totalBytes;
- (void) finishDownloading:(BOOL)success;
- (void) shouldPause:(BOOL)shouldPause;
- (void) clearAudio;

@end
