//
//  Location.h
//  MyLocations
//
//  Created by Mingyuan Wang on 5/29/15.
//  Copyright (c) 2015 Mingyuan Wang. All rights reserved.
//
#import <MapKit/MapKit.h>
#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <CoreLocation/CoreLocation.h>

extern NSString *const ManagedObjectContextSaveDidFailNotification;

#define FATAL_CORE_DATA_ERROR(__error__)\
    NSLog(@"*** Fatal error in %s: %d\n%@\n%@", \
    __FILE__, __LINE__, error, [error userInfo]);\
    [[NSNotificationCenter defaultCenter] postNotificationName:\
    ManagedObjectContextSaveDidFailNotification object: error];

@interface Location : NSManagedObject <MKAnnotation>

@property (nonatomic, retain) NSString * category;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSString * locationDescription;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) CLPlacemark* placemark;
@property (nonatomic, retain) NSNumber *photoId;

- (CLLocationCoordinate2D)coordinate;
- (NSString *)title;
- (NSString *)subtitle;
- (BOOL)hasPhoto;
- (NSString *)documentsDirectory;
- (NSString*) photoPath;
- (UIImage *)photoImage;
+ (NSInteger) nextPhotoId;
- (void)removePhotoFile;

@end
