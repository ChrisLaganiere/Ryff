//
//  RYStyleSheet.m
//  Ryff
//
//  Created by Christopher Laganiere on 4/12/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import "RYStyleSheet.h"

// Categories
#import "UIColor+Hex.h"
#import "UIFontDescriptor+RYCustomFont.h"

@implementation RYStyleSheet

#pragma mark -
#pragma mark - Colors

+ (UIColor *)audioActionColor
{
    return [UIColor colorWithHexString:@"fe9900"];
}

+ (UIColor *)availableActionColor
{
    return [UIColor colorWithHexString:@"b8b8b8"];
}

+ (UIColor *)postActionColor
{
    return [UIColor colorWithHexString:@"00b6da"];
}

+ (UIColor *)tabBarColor
{
    return [UIColor colorWithHexString:@"383838"];
}

+ (UIColor *)audioBackgroundColor
{
    return [UIColor colorWithHexString:@"282828"];
}

+ (UIColor *)lightBackgroundColor
{
    return [UIColor colorWithHexString:@"cee5ea"];
}

+ (UIColor *)profileBackgroundColor
{
    return [UIColor colorWithHexString:@"f2f3ed"];
}

+ (UIColor *)darkTextColor
{
    return [UIColor colorWithHexString:@"5c5c5c"];
}

#pragma mark -
#pragma mark - Fonts

+ (UIFont *)customFontForTextStyle:(NSString *)textStyle
{
    return [UIFont fontWithDescriptor:[UIFontDescriptor preferredCustomFontDescriptorWithTextStyle:textStyle] size: 0];
}

+ (UIFont *)boldCustomFontForTextStyle:(NSString *)textStyle
{
    return [UIFont fontWithDescriptor:[UIFontDescriptor preferredCustomBoldFontDescriptorWithTextStyle:textStyle] size: 0];
}

#pragma mark -
#pragma mark - Image Utilities

+ (UIImage *)image:(UIImage*)imageToRotate RotatedByRadians:(CGFloat)radians
{
    // calculate the size of the rotated view's containing box for our drawing space
    UIView *rotatedViewBox = [[UIView alloc] initWithFrame:CGRectMake(0,0,imageToRotate.size.width, imageToRotate.size.height)];
    CGAffineTransform t = CGAffineTransformMakeRotation(radians);
    rotatedViewBox.transform = t;
    CGSize rotatedSize = rotatedViewBox.frame.size;
    
    // Create the bitmap context
    UIGraphicsBeginImageContext(rotatedSize);
    CGContextRef bitmap = UIGraphicsGetCurrentContext();
    
    // Move the origin to the middle of the image so we will rotate and scale around the center.
    CGContextTranslateCTM(bitmap, rotatedSize.width/2, rotatedSize.height/2);
    
    //   // Rotate the image context
    CGContextRotateCTM(bitmap, radians);
    
    // Now, draw the rotated/scaled image into the context
    CGContextScaleCTM(bitmap, 1.0, -1.0);
    CGContextDrawImage(bitmap, CGRectMake(-imageToRotate.size.width / 2, -imageToRotate.size.height / 2, imageToRotate.size.width, imageToRotate.size.height), [imageToRotate CGImage]);
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

+ (void) styleProfileImageView:(UIView *)view
{
    [view.layer setCornerRadius:10];
    [view setClipsToBounds:YES];
}

#pragma mark -
#pragma mark - Extras

+ (NSString *)convertSecondsToDisplayTime:(CGFloat)totalSeconds
{
    NSInteger hours = (totalSeconds / 3600);
    totalSeconds -= (hours * 3600);
    
    NSInteger minutes = (totalSeconds / 60);
    NSInteger seconds = (totalSeconds - (minutes * 60));
    
    NSString* displayTime;
    if (hours > 0)
        displayTime = [NSString stringWithFormat:@"%02ld:%02ld:%02ld", (long)hours, (long)minutes, (long)seconds];
    else if (hours == 0)
        displayTime = [NSString stringWithFormat:@"%02ld:%02ld", (long)minutes, (long)seconds];
    
    return displayTime;
}

+ (NSString *)displayTimeWithSeconds:(CGFloat)totalSeconds
{
    NSInteger hours = (totalSeconds / 3600);
    totalSeconds -= (hours * 3600);
    
    NSInteger minutes = (totalSeconds / 60);
    NSInteger seconds = (totalSeconds - (minutes * 60));
    
    NSString* displayTime;
    if (hours > 48)
        displayTime = [NSString stringWithFormat:@"%ld days ago",(long)(hours/24.0f)];
    else if (hours > 24)
        displayTime = @"1 day ago";
    else if (hours > 1)
        displayTime = [NSString stringWithFormat:@"%ld hours ago",(long)(hours)];
    else if (hours > 0)
        displayTime = @"1 hour ago";
    else if (minutes > 1)
        displayTime = [NSString stringWithFormat:@"%ld minutes ago",(long)(minutes)];
    else if (minutes > 0)
        displayTime = @"1 minute ago";
    else if (seconds > 1)
        displayTime = [NSString stringWithFormat:@"%ld seconds ago",(long)(seconds)];
    else
        displayTime = @"1 second ago";
    
    return displayTime;
}

@end
