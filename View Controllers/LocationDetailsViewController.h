//
//  LocationDetailsViewController.h
//  MyLocations
//
//  Created by Mingyuan Wang on 5/27/15.
//  Copyright (c) 2015 Mingyuan Wang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@class Location;
@interface LocationDetailsViewController : UITableViewController

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, strong) CLPlacemark *placemark;

@property (nonatomic, strong)Location *locationToEdit;


@end
