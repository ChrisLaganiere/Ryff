//
//  RYRefreshControl.m
//  Ryff
//
//  Created by Christopher Laganiere on 9/7/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import "RYRefreshControl.h"

#define kRefreshPullHeight 55.0f
#define kRefreshControlHeight 55.0f
#define kRefreshControlWidth 200.0f

#define kRefreshTitle @"Pull to Refresh"
#define kRefreshingTitle @"Refreshing"

@interface RYRefreshControl ()

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) CAShapeLayer *circleShape;
@property (nonatomic, strong) UILabel *hintLabel;

// Data
@property (nonatomic, assign) UIEdgeInsets originalContentInset;
@property (nonatomic, assign) BOOL canRefresh;
@property (nonatomic, assign) BOOL ignoreEdges;
@property (nonatomic, assign) BOOL dontAdjustInsets;

@end

@implementation RYRefreshControl

#pragma mark -
#pragma mark - Life Cycle

static int scrollObservanceContext;
- (id) initInScrollView:(UIScrollView *)scrollView
{
    if (self = [super initWithFrame:CGRectMake(0.5*(scrollView.frame.size.width-kRefreshControlWidth), -(kRefreshControlHeight + scrollView.contentInset.top), kRefreshControlWidth, kRefreshControlHeight)])
    {
        _scrollView             = scrollView;
        _originalContentInset   = scrollView.contentInset;
        
        _tintColor = [UIColor whiteColor];
        
        self.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
        
        [_scrollView addSubview:self];
        [_scrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:&scrollObservanceContext];
        [_scrollView addObserver:self forKeyPath:@"contentInset" options:NSKeyValueObservingOptionNew context:&scrollObservanceContext];
        
        [self setupRefresh];
    }
    return self;
}

- (void)dealloc
{
    [_scrollView removeObserver:self forKeyPath:@"contentOffset" context:&scrollObservanceContext];
    [_scrollView removeObserver:self forKeyPath:@"contentInset"context:&scrollObservanceContext];
    _scrollView = nil;
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
    if (!newSuperview)
    {
        [_scrollView removeObserver:self forKeyPath:@"contentOffset" context:&scrollObservanceContext];
        [_scrollView removeObserver:self forKeyPath:@"contentInset" context:&scrollObservanceContext];
        _scrollView = nil;
    }
}

#pragma mark -
#pragma mark - Styling

- (void) setupRefresh
{
    CGRect circleFrame          = CGRectMake(0.5f*(self.frame.size.width-25.0f), 5, 25.0f, 25.0f);
    CGPoint circleCenter        = CGPointMake(circleFrame.size.width/2, circleFrame.size.height/2);
    CGFloat outerStrokeWidth    = 4.0f;
    _circleShape                = [CAShapeLayer layer];
    _circleShape.path           = [UIBezierPath bezierPathWithArcCenter:circleCenter radius:(circleFrame.size.width-outerStrokeWidth/2) / 2 startAngle:-M_PI_2 endAngle:-M_PI_2 + 2 * M_PI clockwise:YES].CGPath;
    _circleShape.strokeColor    = _tintColor.CGColor;
    _circleShape.fillColor      = nil;
    _circleShape.lineWidth      = outerStrokeWidth;
    _circleShape.strokeEnd      = 0.75f;
    _circleShape.position       = circleFrame.origin;
    [self.layer addSublayer:_circleShape];
    
    _activityIndicator                  = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _activityIndicator.center           = CGPointMake(_circleShape.position.x + circleFrame.size.width/2, _circleShape.position.y + circleFrame.size.height/2);
    _activityIndicator.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    _activityIndicator.hidesWhenStopped = NO;
    _activityIndicator.hidden           = YES;
    _activityIndicator.color            = _tintColor;
    [self addSubview:_activityIndicator];
    
    _hintLabel               = [[UILabel alloc] initWithFrame:CGRectMake(0, kRefreshControlHeight-20.0f, kRefreshControlWidth, 20.0f)];
    _hintLabel.textAlignment = NSTextAlignmentCenter;
    _hintLabel.font          = [UIFont fontWithName:kRegularFont size:16.0f];
    _hintLabel.textColor     = [UIColor lightGrayColor];
    _hintLabel.text          = kRefreshTitle;
    [self addSubview:_hintLabel];
}

- (void) styleForPullProgress:(CGFloat)progress
{
    [self animateFill:_circleShape toStrokeEnd:progress];
}

#pragma mark -
#pragma mark - Members

- (void) setTintColor:(UIColor *)tintColor
{
    _tintColor                      = tintColor;
    _activityIndicator.color        = tintColor;
    _circleShape.strokeColor        = tintColor.CGColor;
}

#pragma mark -
#pragma mark - Shape Helpers

- (void) animateFill:(CAShapeLayer*)shapeLayer toStrokeEnd:(CGFloat)strokeEnd
{
    [shapeLayer removeAnimationForKey:@"strokeEnd"];
    
    CGFloat animationDuration = 0.1f;
    
    CABasicAnimation *fillStroke = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    fillStroke.duration          = animationDuration;
    fillStroke.fromValue         = @(shapeLayer.strokeEnd);
    fillStroke.toValue           = @(strokeEnd);
    shapeLayer.strokeEnd         = strokeEnd;
    [shapeLayer addAnimation:fillStroke forKey:@"fill stroke"];
}

//- (void) animateOpacity:(CAShapeLayer *)shapeLayer toOpacity:(CGFloat)opacity duration:(CGFloat)duration
//{
//    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
//    animation.fromValue = shapeLayer.opacity;
//    animation.toValue   = [NSNumber numberWithFloat:1.0];
//    animation.duration = duration;        // 1 second
//    
//    [shapeLayer addAnimation:animation forKey:@"flashAnimation"];
//}

#pragma mark -
#pragma mark - Actions

- (void) beginRefreshing
{
    if (!_isRefreshing)
    {
        _canRefresh = NO;
        _isRefreshing = YES;
        
        if (!_dontAdjustInsets)
        {
            _ignoreEdges = YES;
            CGPoint offset = self.scrollView.contentOffset;
            UIEdgeInsets scrollViewInsets = _originalContentInset;
            scrollViewInsets.top += kRefreshControlHeight;
            offset.y -= kRefreshControlHeight;
            [_scrollView setContentInset:scrollViewInsets];
            [_scrollView setContentOffset:offset animated:NO];
            _ignoreEdges = NO;
        }
        
        [UIView animateWithDuration:0.4f animations:^{
            _circleShape.opacity = 0.0f;
        }];
        
        _activityIndicator.hidden = NO;
        [_activityIndicator startAnimating];
        [self animateFill:_circleShape toStrokeEnd:1.0f];
        _circleShape.fillColor = _tintColor.CGColor;
        [_hintLabel setText:kRefreshingTitle];
    }
}

- (void) endRefreshing
{
    if (_isRefreshing)
    {
        _isRefreshing = NO;
        _circleShape.fillColor = [UIColor clearColor].CGColor;
        
        __weak UIScrollView *blockScrollView = self.scrollView;
        [UIView animateWithDuration:0.4 animations:^{
            
            _ignoreEdges = YES;
            [blockScrollView setContentInset:self.originalContentInset];
            _ignoreEdges = NO;
            
            _activityIndicator.layer.transform = CATransform3DMakeScale(0.1, 0.1, 1);
        } completion:^(BOOL finished) {
            
            _activityIndicator.hidden = YES;
            [_activityIndicator stopAnimating];
            _activityIndicator.layer.transform = CATransform3DIdentity;
            [_hintLabel setText:kRefreshTitle];
        }];
    }
}

#pragma mark - Internal

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"contentInset"])
    {
        if (!_ignoreEdges)
            _originalContentInset = [[change objectForKey:@"new"] UIEdgeInsetsValue];
    }
    else if ([keyPath isEqualToString:@"contentOffset"])
    {
        if (_ignoreEdges)
            return;
        
        CGFloat offset = [[change objectForKey:@"new"] CGPointValue].y + self.originalContentInset.top;
        
        if (_isRefreshing)
        {
            // already refreshing
            if (offset < 0.0f && offset >= -kRefreshControlHeight)
            {
                _ignoreEdges = YES;
                if (!self.scrollView.dragging)
                {
                    // was released above tipping point
                    UIEdgeInsets scrollViewInsets = _originalContentInset;
                    scrollViewInsets.top += kRefreshControlHeight;
                    [self.scrollView setContentInset:scrollViewInsets];
                }
                else
                {
                    // still touching
                    UIEdgeInsets scrollViewInsets = _originalContentInset;
                    scrollViewInsets.top -= offset;
                    [self.scrollView setContentInset:scrollViewInsets];
                }
                _ignoreEdges = NO;
            }
        }
        else
        {
            // not refreshing yet
            BOOL shouldDraw = YES;
            if (!_canRefresh)
            {
                if (offset >= -5.0f)
                {
                    // We can refresh again after the control is scrolled out of view
                    _canRefresh = YES;
                    
                    // show subviews again
                    _circleShape.opacity = 1.0f;
                }
                else
                    shouldDraw = NO;
            }
            else
            {
                if (offset >= 0.0f)
                {
                    // Don't draw if the control is not visible
                    shouldDraw = NO;
                }
            }
            
            if (shouldDraw)
            {
                CGFloat percentPulled = MIN(-kRefreshControlHeight-offset,kRefreshPullHeight)/kRefreshPullHeight;
                if (percentPulled == 1.0f)
                {
                    // triggered refresh
                    _dontAdjustInsets = YES;
                    [self beginRefreshing];
                    [self sendActionsForControlEvents:UIControlEventValueChanged];
                    _dontAdjustInsets = NO;
                }
                else
                {
                    // approaching refresh
                    [self styleForPullProgress:percentPulled];
                }
            }
        }
    }
}

@end
