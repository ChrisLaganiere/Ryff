//
//  RYTagCollectionViewCell.h
//  Ryff
//
//  Created by Christopher Laganiere on 9/15/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RYTag;

@interface RYTagCollectionViewCell : UICollectionViewCell

- (void) configureWithTag:(RYTag *)tag;

@end
