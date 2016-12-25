//
//  UIImage+Resize.m
//  MyLocations
//
//  Created by Mingyuan Wang on 6/3/15.
//  Copyright (c) 2015 Mingyuan Wang. All rights reserved.
//

#import "UIImage+Resize.h"

@implementation UIImage (Resize)

- (UIImage *)resizedImageWithBounds:(CGSize)bounds
{
    CGFloat horizonalRatio = bounds.width/self.size.width;
    CGFloat verticalRatio = bounds.height/self.size.height;
    //CGFloat ratio = MIN(horizonalRatio, verticalRatio);
    CGSize newSize = CGSizeMake(self.size.width * horizonalRatio, self.size.height * verticalRatio);
    UIGraphicsBeginImageContextWithOptions(newSize, YES, 0);
    [self drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

@end
