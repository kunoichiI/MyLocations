//
//  UITabBarController+MyTabBarController.m
//  MyLocations
//
//  Created by Mingyuan Wang on 6/4/15.
//  Copyright (c) 2015 Mingyuan Wang. All rights reserved.
//

#import "UITabBarController+MyTabBarController.h"

@implementation UITabBarController (MyTabBarController)
- (UIStatusBarStyle) preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (UIViewController *)childViewControllerForStatusBarStyle
{
    return nil;
}
@end
