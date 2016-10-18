//
//  NSMutableString+AddText.m
//  MyLocations
//
//  Created by Mingyuan Wang on 6/4/15.
//  Copyright (c) 2015 Mingyuan Wang. All rights reserved.
//

#import "NSMutableString+AddText.h"

@implementation NSMutableString (AddText)
-(void)addText:(NSString *)text withSeparator:(NSString *)separator
{
    if (text != nil) {
        if ([self length] > 0) {
            [self appendString:separator];
        }
        [self appendString:text];
    }
}

@end
