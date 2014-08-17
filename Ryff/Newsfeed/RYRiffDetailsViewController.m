//
//  RYRiffDetailsViewController.m
//  Ryff
//
//  Created by Christopher Laganiere on 7/30/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import "RYRiffDetailsViewController.h"

// Data Managers
#import "RYServices.h"
#import "RYDataManager.h"

// Custom UI
#import "RYRiffDetailsTableViewCell.h"

// Associated View Controllers
#import "RYProfileViewController.h"
#import "RYRiffCreateViewController.h"

#define kRiffDetailsCellReuseID @"riffDetails"

@interface RYRiffDetailsViewController () <PostDelegate, RiffDetailsDelegate, ActionDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, weak) RYRiffDetailsTableViewCell *riffDetailsCell;

// Data
@property (nonatomic, strong) RYNewsfeedPost *post;

@end

@implementation RYRiffDetailsViewController

- (void) viewDidLoad
{
    self.riffTableView = _tableView;
    [super viewDidLoad];
    
    self.riffSection = 1;
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[RYServices sharedInstance] getFamilyForPost:_post.postId delegate:self];
    [self.tableView reloadData];
}

- (void) addBackButton
{
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(dismissButtonHit:)];
    [self.navigationItem setLeftBarButtonItem:backButton];
}

- (void) dismissButtonHit:(id)sender
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Configuring

- (void) configureForPost:(RYNewsfeedPost *)post
{
    _post = post;
    [self setTitle:post.riff.title];
    
    [[RYDataManager sharedInstance] getRiffFile:post.riff.fileName completion:nil];
}

#pragma mark - Actions

- (IBAction)backButtonHit:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark - RiffDetailsDelegate

- (void) riffUpvoteAction
{
    [[RYServices sharedInstance] upvote:YES post:_post forDelegate:self];
}

- (void) riffRepostAction
{
    RYRiffCreateViewController *riffCreateVC = [[UIStoryboard storyboardWithName:@"Main" bundle:NULL] instantiateViewControllerWithIdentifier:@"RiffCreateVC"];
    [riffCreateVC includeRiffs:@[_post.riff]];
    [self presentViewController:riffCreateVC animated:YES completion:nil];
}

- (void) riffFollowAction
{
    
}

- (void) riffProgressSliderChanged:(CGFloat)newProgress
{
    
}

- (void) riffAvatarTapAction
{
    NSString *storyboardName = isIpad ? @"Main" : @"MainIphone";
    RYProfileViewController *profileVC = [[UIStoryboard storyboardWithName:storyboardName bundle:NULL] instantiateViewControllerWithIdentifier:@"profileVC"];
    [profileVC configureForUser:_post.user];
    if (self.navigationController)
        [self.navigationController pushViewController:profileVC animated:YES];
    else
        [self presentViewController:profileVC animated:YES completion:nil];
}

- (void) riffPlayControlAction
{
    
}

#pragma mark -
#pragma mark - PostDelegate

- (void) postFailed:(NSString*)reason
{
    
}

- (void) postSucceeded:(NSArray*)posts
{
    self.feedItems = posts;
    [_tableView reloadData];
}

#pragma mark - Action Delegate

- (void) upvoteSucceeded:(RYNewsfeedPost *)updatedPost
{
    if (updatedPost.postId == _post.postId)
    {
        // upvoted main riff
        _post = updatedPost;
        [_riffDetailsCell configureWithPost:_post delegate:self];
    }
    else
    {
        // upvoted other riff in tableview
        [super upvoteSucceeded:updatedPost];
    }
}

- (void) starSucceeded:(RYNewsfeedPost *)updatedPost
{
    if (updatedPost.postId == _post.postId)
    {
        // upvoted main riff
        _post = updatedPost;
        [_riffDetailsCell configureWithPost:_post delegate:self];
    }
    else
    {
        // upvoted other riff in tableview
        [super upvoteSucceeded:updatedPost];
    }
}

- (void) upvoteFailed:(NSString *)reason post:(RYNewsfeedPost *)oldPost
{
    
}

- (void) starFailed:(NSString *)reason post:(RYNewsfeedPost *)oldPost
{
    
}

#pragma mark -
#pragma mark - TableView Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1 + [super numberOfSectionsInTableView:tableView];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numRows;
    if (section == self.riffSection)
        numRows = [super tableView:tableView numberOfRowsInSection:0];
    else
        numRows = 1;
    return numRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if (indexPath.section == self.riffSection)
        cell = [super tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:0]];
    else
        cell = [_tableView dequeueReusableCellWithIdentifier:kRiffDetailsCellReuseID];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 0;
    
    if (indexPath.section == self.riffSection)
        height = [super tableView:tableView heightForRowAtIndexPath:indexPath];
    else
    {
        // riff details cell -> calculate size with attributed text for post description
        CGFloat widthMinusText = kRiffDetailsWidthMinusText;
        height = [[RYStyleSheet createProfileAttributedTextWithPost:_post] boundingRectWithSize:CGSizeMake(self.riffTableView.frame.size.width-widthMinusText, 20000) options:NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin context:nil].size.height;
        height = MAX(height+kRiffDetailsCellHeightMinusText, kRiffDetailsCellMinimumHeight);
    }
    
    return height;
}

#pragma mark -
#pragma mark - TableView Delegate

- (void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == self.riffSection)
        [super tableView:tableView willDisplayCell:cell forRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:0]];
    else
    {
        _riffDetailsCell = (RYRiffDetailsTableViewCell *)cell;
        [_riffDetailsCell configureWithPost:_post delegate:self];
    }
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == self.riffSection)
        [super tableView:tableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:0]];
}

@end
