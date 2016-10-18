//
//  LocationCell.h
//  MyLocations
//
//  Created by Mingyuan Wang on 5/31/15.
//  Copyright (c) 2015 Mingyuan Wang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LocationCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UILabel *descriptionLabel;
@property (nonatomic, weak) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;



@end
