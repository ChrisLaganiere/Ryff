//
//  RYRiffStreamingCoreViewController.h
//  Ryff
//
//  Created by Christopher Laganiere on 4/12/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RYCoreViewController.h"

// Custom UI
#import "RYRiffCell.h"
#import "RYStyleSheet.h"

// Data Managers
#import "RYServices.h"

// Data Objects
#import "RYPost.h"
#import "RYUser.h"

#define kRiffCellReuseID @"RiffCell"
#define KRiffCellAvatarReuseID @"RiffCellAvatar"

@interface RYRiffStreamingCoreViewController : RYCoreViewController <ActionDelegate, RiffCellDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *riffTableView;
@property (nonatomic, strong) NSArray *feedItems;
@property (nonatomic, assign) NSInteger riffSection;

@end
