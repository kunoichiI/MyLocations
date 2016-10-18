//
//  HudView.h
//  MyLocations
//
//  Created by Mingyuan Wang on 5/29/15.
//  Copyright (c) 2015 Mingyuan Wang. All rights reserved.
//


@interface HudView : UIView

+(instancetype)hudInView: (UIView *)view animated:(BOOL)animated;
@property (nonatomic, strong) NSString *text;

@end
