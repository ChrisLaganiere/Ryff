//
//  RYNewsfeedTableViewController.h
//  Ryff
//
//  Created by Christopher Laganiere on 4/11/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RYRiffStreamingCoreViewController.h"

// Custom UI
#import "RYRefreshControl.h"

@interface RYNewsfeedTableViewController : RYRiffStreamingCoreViewController <PostDelegate>

@property (nonatomic, strong) RYRefreshControl *refreshControl;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

// Data
@property (nonatomic, assign) SearchType searchType;
@property (nonatomic, assign) BOOL scrollViewActive;

@end
